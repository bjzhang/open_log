/*---------------------------------------------------------------------------*/
/*  Copyright (C) 2006-2012 Red Hat, Inc.
 *  Copyright (c) 2011 SUSE LINUX Products GmbH, Nuernberg, Germany.
 *  Copyright (C) 2011 Univention GmbH.
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307  USA
 *
 * Authors:
 *     Jim Fehlig <jfehlig@novell.com>
 *     Markus Groß <gross@univention.de>
 *     Daniel P. Berrange <berrange@redhat.com>
 */
/*---------------------------------------------------------------------------*/

#include <config.h>

#include <sys/utsname.h>
#include <math.h>
#include <libxl.h>
#include <fcntl.h>
#include <stdlib.h>
#include <string.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <arpa/inet.h>
#include <netdb.h>

#include "internal.h"
#include "logging.h"
#include "virterror_internal.h"
#include "conf.h"
#include "datatypes.h"
#include "virfile.h"
#include "memory.h"
#include "uuid.h"
#include "command.h"
#include "libxl_driver.h"
#include "libxl_conf.h"
#include "xen_xm.h"
#include "virtypedparam.h"
#include "viruri.h"
#include "virtime.h"
#include "rpc/virnetsocket.h"

#define VIR_FROM_THIS VIR_FROM_LIBXL

#define LIBXL_DOM_REQ_POWEROFF 0
#define LIBXL_DOM_REQ_REBOOT   1
#define LIBXL_DOM_REQ_SUSPEND  2
#define LIBXL_DOM_REQ_CRASH    3
#define LIBXL_DOM_REQ_HALT     4

#define LIBXL_CONFIG_FORMAT_XM "xen-xm"

/* Number of Xen scheduler parameters */
#define XEN_SCHED_CREDIT_NPARAM   2

static libxlDriverPrivatePtr libxl_driver = NULL;

typedef struct migrate_receive_args {
    virConnectPtr conn;
    virDomainObjPtr vm;
    int sockfd;
} migrate_receive_args;

typedef struct migrate_send_args {
    libxlDriverPrivatePtr driver;
    virDomainObjPtr vm;
    unsigned long flags;
    int sockfd;
} migrate_send_args;

/* Function declarations */
static int
libxlVmStart(libxlDriverPrivatePtr driver, virDomainObjPtr vm,
             bool start_paused, int restore_fd, bool driver_locked);

/* Function definitions */
static void
libxlDriverLock(libxlDriverPrivatePtr driver)
{
    virMutexLock(&driver->lock);
}

static void
libxlDriverUnlock(libxlDriverPrivatePtr driver)
{
    virMutexUnlock(&driver->lock);
}

/* job */
VIR_ENUM_IMPL(libxlDomainJob, LIBXL_JOB_LAST,
              "none",
              "destroy",
              "modify",
              "abort",
              "migration operation",
              "none",   /* async job is never stored in job.active */
);

VIR_ENUM_IMPL(libxlDomainAsyncJob, LIBXL_ASYNC_JOB_LAST,
              "none",
              "migration out",
              "migration in",
              "save",
              "restore",
              "dump",
);

static int
libxlDomainObjInitJob(libxlDomainObjPrivatePtr priv)
{
    memset(&priv->job, 0, sizeof(priv->job));

    if (virCondInit(&priv->job.cond) < 0)
        return -1;

    if (virCondInit(&priv->job.asyncCond) < 0) {
        ignore_value(virCondDestroy(&priv->job.cond));
        return -1;
    }

    return 0;
}

static void
libxlDomainObjResetJob(libxlDomainObjPrivatePtr priv)
{
    struct libxlDomainJobObj *job = &priv->job;

    job->active = LIBXL_JOB_NONE;
    job->owner = 0;
}

static void
libxlDomainObjResetAsyncJob(libxlDomainObjPrivatePtr priv)
{
    struct libxlDomainJobObj *job = &priv->job;

    job->asyncJob = LIBXL_ASYNC_JOB_NONE;
    job->asyncOwner = 0;
    job->phase = 0;
    job->mask = DEFAULT_JOB_MASK;
    job->start = 0;
    memset(&job->info, 0, sizeof(job->info));
}

static void
libxlDomainObjFreeJob(libxlDomainObjPrivatePtr priv)
{
    ignore_value(virCondDestroy(&priv->job.cond));
    ignore_value(virCondDestroy(&priv->job.asyncCond));
}

static bool
libxlDomainTrackJob(enum libxlDomainJob job)
{
    return (LIBXL_DOMAIN_TRACK_JOBS & JOB_MASK(job)) != 0;
}

static void
libxlDomainObjSaveJob(libxlDriverPrivatePtr driver, virDomainObjPtr obj)
{
    if (!virDomainObjIsActive(obj)) {
        /* don't write the state file yet, it will be written once the domain
         * gets activated */
        return;
    }

    if (virDomainSaveStatus(driver->caps, driver->stateDir, obj) < 0)
        VIR_WARN("Failed to save status on vm %s", obj->def->name);
}

static bool
libxlDomainNestedJobAllowed(libxlDomainObjPrivatePtr priv, enum libxlDomainJob job)
{
    return !priv->job.asyncJob || (priv->job.mask & JOB_MASK(job)) != 0;
}

static void
libxlDomainObjSetAsyncJobMask(virDomainObjPtr obj,
                             unsigned long long allowedJobs)
{
    libxlDomainObjPrivatePtr priv = obj->privateData;

    if (!priv->job.asyncJob)
        return;

    priv->job.mask = allowedJobs | JOB_MASK(LIBXL_JOB_DESTROY);
}

/* Give up waiting for mutex after 30 seconds */
#define LIBXL_JOB_WAIT_TIME (1000ull * 30)

/*
 * obj must be locked before calling; driver_locked says if libxlDriverPrivatePtr 
 * is locked or not.
 */
static int ATTRIBUTE_NONNULL(1)
libxlDomainObjBeginJobInternal(libxlDriverPrivatePtr driver,
                              bool driver_locked,
                              virDomainObjPtr obj,
                              enum libxlDomainJob job,
                              enum libxlDomainAsyncJob asyncJob)
{
    libxlDomainObjPrivatePtr priv = obj->privateData;
    unsigned long long now;
    unsigned long long then;

    priv->jobs_queued++;

    if (virTimeMillisNow(&now) < 0)
        return -1;
    then = now + LIBXL_JOB_WAIT_TIME;

    virDomainObjRef(obj);
    if (driver_locked) {
        libxlDriverUnlock(driver);
    }

retry:
    if (driver->max_queued &&
        priv->jobs_queued > driver->max_queued) {
        goto error;
    }

    while (!libxlDomainNestedJobAllowed(priv, job)) {
        VIR_INFO("Wait async job condition for starting job: %s (async=%s)",
                   libxlDomainJobTypeToString(job),
                   libxlDomainAsyncJobTypeToString(priv->job.asyncJob));
        if (virCondWaitUntil(&priv->job.asyncCond, &obj->lock, then) < 0)
            goto error;
    }

    while (priv->job.active) {
        VIR_INFO("Wait normal job condition for starting job: %s (async=%s)",
                   libxlDomainJobTypeToString(job),
                   libxlDomainAsyncJobTypeToString(priv->job.asyncJob));
        if (virCondWaitUntil(&priv->job.cond, &obj->lock, then) < 0)
            goto error;
    }

    /* No job is active but a new async job could have been started while obj
     * was unlocked, so we need to recheck it. */
    if (!libxlDomainNestedJobAllowed(priv, job))
        goto retry;

    libxlDomainObjResetJob(priv);

    if (job != LIBXL_JOB_ASYNC) {
        VIR_DEBUG("Starting job: %s (async=%s)",
                   libxlDomainJobTypeToString(job),
                   libxlDomainAsyncJobTypeToString(priv->job.asyncJob));
        priv->job.active = job;
        priv->job.owner = virThreadSelfID();
    } else {
        VIR_DEBUG("Starting async job: %s",
                  libxlDomainAsyncJobTypeToString(asyncJob));
        libxlDomainObjResetAsyncJob(priv);
        priv->job.asyncJob = asyncJob;
        priv->job.asyncOwner = virThreadSelfID();
        priv->job.start = now;
    }

    if (driver_locked) {
        virDomainObjUnlock(obj);
        libxlDriverLock(driver);
        virDomainObjLock(obj);
    }

    if (libxlDomainTrackJob(job))
        libxlDomainObjSaveJob(driver, obj);

    return 0;

error:
    VIR_WARN("Cannot start job (%s, %s) for domain %s;"
             " current job is (%s, %s) owned by (%d, %d)",
             libxlDomainJobTypeToString(job),
             libxlDomainAsyncJobTypeToString(asyncJob),
             obj->def->name,
             libxlDomainJobTypeToString(priv->job.active),
             libxlDomainAsyncJobTypeToString(priv->job.asyncJob),
             priv->job.owner, priv->job.asyncOwner);

    if (errno == ETIMEDOUT)
        libxlError(VIR_ERR_OPERATION_TIMEOUT,
                        "%s", _("cannot acquire state change lock"));
    else if (driver->max_queued &&
             priv->jobs_queued > driver->max_queued)
        libxlError(VIR_ERR_OPERATION_FAILED,
                        "%s", _("cannot acquire state change lock "
                                "due to max_queued limit"));
    else
        virReportSystemError(errno,
                             "%s", _("cannot acquire job mutex"));
    priv->jobs_queued--;
    if (driver_locked) {
        virDomainObjUnlock(obj);
        libxlDriverLock(driver);
        virDomainObjLock(obj);
    }
    /* Safe to ignore value since ref count was incremented above */
    ignore_value(virDomainObjUnref(obj));
    return -1;
}

/*
 * obj must be locked before calling, libxlDriverPrivatePtr must NOT be locked
 *
 * This must be called by anything that will change the VM state
 * in any way, or anything that will use the LIBXL monitor.
 *
 * Upon successful return, the object will have its ref count increased,
 * successful calls must be followed by EndJob eventually
 */
static int
libxlDomainObjBeginJob(libxlDriverPrivatePtr driver,
                          virDomainObjPtr obj,
                          enum libxlDomainJob job)
{
    return libxlDomainObjBeginJobInternal(driver, false, obj, job,
                                         LIBXL_ASYNC_JOB_NONE);
}

static int
libxlDomainObjBeginAsyncJob(libxlDriverPrivatePtr driver,
                               virDomainObjPtr obj,
                               enum libxlDomainAsyncJob asyncJob)
{
    return libxlDomainObjBeginJobInternal(driver, false, obj, LIBXL_JOB_ASYNC,
                                         asyncJob);
}

/*
 * obj must be locked before calling. If libxlDriverPrivatePtr is passed, it 
 * MUST be locked; otherwise it MUST NOT be locked.
 *
 * This must be called by anything that will change the VM state
 * in any way, or anything that will use the LIBXL monitor.
 *
 * Upon successful return, the object will have its ref count increased,
 * successful calls must be followed by EndJob eventually
 */
static int
libxlDomainObjBeginJobWithDriver(libxlDriverPrivatePtr driver,
                                    virDomainObjPtr obj,
                                    enum libxlDomainJob job)
{
    if (job <= LIBXL_JOB_NONE || job >= LIBXL_JOB_ASYNC) {
        libxlError(VIR_ERR_INTERNAL_ERROR, "%s",
                        _("Attempt to start invalid job"));
        return -1;
    }

    return libxlDomainObjBeginJobInternal(driver, true, obj, job,
                                         LIBXL_ASYNC_JOB_NONE);
}

static int
libxlDomainObjBeginAsyncJobWithDriver(libxlDriverPrivatePtr driver,
                                         virDomainObjPtr obj,
                                         enum libxlDomainAsyncJob asyncJob)
{
    return libxlDomainObjBeginJobInternal(driver, true, obj, LIBXL_JOB_ASYNC,
                                         asyncJob);
}

/*
 * obj must be locked before calling, libxlDriverPrivatePtr does not matter
 *
 * To be called after completing the work associated with the
 * earlier libxlDomainBeginJob() call
 *
 * Returns remaining refcount on 'obj', maybe 0 to indicated it
 * was deleted
 */
static int
libxlDomainObjEndJob(libxlDriverPrivatePtr driver, virDomainObjPtr obj)
{
    libxlDomainObjPrivatePtr priv = obj->privateData;
    enum libxlDomainJob job = priv->job.active;

    priv->jobs_queued--;

    VIR_DEBUG("Stopping job: %s (async=%s)",
              libxlDomainJobTypeToString(job),
              libxlDomainAsyncJobTypeToString(priv->job.asyncJob));

    libxlDomainObjResetJob(priv);
    if (libxlDomainTrackJob(job))
        libxlDomainObjSaveJob(driver, obj);
    virCondSignal(&priv->job.cond);

    return virDomainObjUnref(obj);
}

static int
libxlDomainObjEndAsyncJob(libxlDriverPrivatePtr driver, virDomainObjPtr obj)
{
    libxlDomainObjPrivatePtr priv = obj->privateData;

    priv->jobs_queued--;

    VIR_DEBUG("Stopping async job: %s",
              libxlDomainAsyncJobTypeToString(priv->job.asyncJob));

    libxlDomainObjResetAsyncJob(priv);
    libxlDomainObjSaveJob(driver, obj);
    virCondBroadcast(&priv->job.asyncCond);

    return virDomainObjUnref(obj);
}

static int
libxlMigrationJobStart(libxlDriverPrivatePtr driver,
                      virDomainObjPtr vm,
                      enum libxlDomainAsyncJob job)
{
    libxlDomainObjPrivatePtr priv = vm->privateData;

    if (libxlDomainObjBeginAsyncJobWithDriver(driver, vm, job) < 0)
        return -1;

    if (job == LIBXL_ASYNC_JOB_MIGRATION_IN) {
        libxlDomainObjSetAsyncJobMask(vm, LIBXL_JOB_NONE);
    } else {
        libxlDomainObjSetAsyncJobMask(vm, DEFAULT_JOB_MASK |
                                     JOB_MASK(LIBXL_JOB_MIGRATION_OP));
    }

    priv->job.info.type = VIR_DOMAIN_JOB_UNBOUNDED;

    return 0;
}

static int
libxlMigrationJobFinish(libxlDriverPrivatePtr driver, virDomainObjPtr vm)
{
    return libxlDomainObjEndAsyncJob(driver, vm);
}
/* job function finish */

static void *
libxlDomainObjPrivateAlloc(void)
{
    libxlDomainObjPrivatePtr priv;

    if (VIR_ALLOC(priv) < 0)
        return NULL;

    if (libxlDomainObjInitJob(priv) < 0)
        goto error;

    libxl_ctx_init(&priv->ctx, LIBXL_VERSION, libxl_driver->logger);
    priv->waiterFD = -1;
    priv->eventHdl = -1;

    return priv;

error:
    VIR_FREE(priv);
    return NULL;
}

static void
libxlDomainObjPrivateFree(void *data)
{
    libxlDomainObjPrivatePtr priv = data;

    if (priv->eventHdl >= 0)
        virEventRemoveHandle(priv->eventHdl);

    if (priv->dWaiter) {
        libxl_stop_waiting(&priv->ctx, priv->dWaiter);
        libxl_free_waiter(priv->dWaiter);
        VIR_FREE(priv->dWaiter);
    }

    libxl_ctx_free(&priv->ctx);
    libxlDomainObjFreeJob(priv);
    VIR_FREE(priv);
}


/* driver must be locked before calling */
static void
libxlDomainEventQueue(libxlDriverPrivatePtr driver, virDomainEventPtr event)
{
    virDomainEventStateQueue(driver->domainEventState, event);
}

/*
 * Remove reference to domain object.
 */
static void
libxlDomainObjUnref(void *data)
{
    virDomainObjPtr vm = data;

    ignore_value(virDomainObjUnref(vm));
}

static void
libxlAutostartDomain(void *payload, const void *name ATTRIBUTE_UNUSED,
                     void *opaque)
{
    libxlDriverPrivatePtr driver = opaque;
    virDomainObjPtr vm = payload;
    virErrorPtr err;

    virDomainObjLock(vm);
    virResetLastError();

    if (vm->autostart && !virDomainObjIsActive(vm) &&
        libxlVmStart(driver, vm, false, -1, false) < 0) {
        err = virGetLastError();
        VIR_ERROR(_("Failed to autostart VM '%s': %s"),
                  vm->def->name,
                  err ? err->message : _("unknown error"));
    }

    if (vm)
        virDomainObjUnlock(vm);
}

static int
libxlDoNodeGetInfo(libxlDriverPrivatePtr driver, virNodeInfoPtr info)
{
    libxl_physinfo phy_info;
    const libxl_version_info* ver_info;
    struct utsname utsname;

    if (libxl_get_physinfo(&driver->ctx, &phy_info)) {
        libxlError(VIR_ERR_INTERNAL_ERROR,
                   _("libxl_get_physinfo_info failed"));
        return -1;
    }

    if ((ver_info = libxl_get_version_info(&driver->ctx)) == NULL) {
        libxlError(VIR_ERR_INTERNAL_ERROR,
                   _("libxl_get_version_info failed"));
        return -1;
    }

    uname(&utsname);
    if (virStrncpy(info->model,
                   utsname.machine,
                   strlen(utsname.machine),
                   sizeof(info->model)) == NULL) {
        libxlError(VIR_ERR_INTERNAL_ERROR,
                   _("machine type %s too big for destination"),
                   utsname.machine);
        return -1;
    }

    info->memory = phy_info.total_pages * (ver_info->pagesize / 1024);
    info->cpus = phy_info.nr_cpus;
    info->nodes = phy_info.nr_nodes;
    info->cores = phy_info.cores_per_socket;
    info->threads = phy_info.threads_per_core;
    info->sockets = 1;
    info->mhz = phy_info.cpu_khz / 1000;
    return 0;
}

static char *
libxlDomainManagedSavePath(libxlDriverPrivatePtr driver, virDomainObjPtr vm) {
    char *ret;

    if (virAsprintf(&ret, "%s/%s.save", driver->saveDir, vm->def->name) < 0) {
        virReportOOMError();
        return NULL;
    }

    return ret;
}

/* This internal function expects the driver lock to already be held on
 * entry. */
static int ATTRIBUTE_NONNULL(3) ATTRIBUTE_NONNULL(4)
libxlSaveImageOpen(libxlDriverPrivatePtr driver, const char *from,
                     virDomainDefPtr *ret_def, libxlSavefileHeaderPtr ret_hdr)
{
    int fd;
    virDomainDefPtr def = NULL;
    libxlSavefileHeader hdr;
    char *xml = NULL;

    if ((fd = virFileOpenAs(from, O_RDONLY, 0, -1, -1, 0)) < 0) {
        libxlError(VIR_ERR_OPERATION_FAILED,
                   "%s", _("cannot read domain image"));
        goto error;
    }

    if (saferead(fd, &hdr, sizeof(hdr)) != sizeof(hdr)) {
        libxlError(VIR_ERR_OPERATION_FAILED,
                   "%s", _("failed to read libxl header"));
        goto error;
    }

    if (memcmp(hdr.magic, LIBXL_SAVE_MAGIC, sizeof(hdr.magic))) {
        libxlError(VIR_ERR_INVALID_ARG, "%s", _("image magic is incorrect"));
        goto error;
    }

    if (hdr.version > LIBXL_SAVE_VERSION) {
        libxlError(VIR_ERR_OPERATION_FAILED,
                   _("image version is not supported (%d > %d)"),
                   hdr.version, LIBXL_SAVE_VERSION);
        goto error;
    }

    if (hdr.xmlLen <= 0) {
        libxlError(VIR_ERR_OPERATION_FAILED,
                   _("invalid XML length: %d"), hdr.xmlLen);
        goto error;
    }

    if (VIR_ALLOC_N(xml, hdr.xmlLen) < 0) {
        virReportOOMError();
        goto error;
    }

    if (saferead(fd, xml, hdr.xmlLen) != hdr.xmlLen) {
        libxlError(VIR_ERR_OPERATION_FAILED, "%s", _("failed to read XML"));
        goto error;
    }

    if (!(def = virDomainDefParseString(driver->caps, xml,
                                        1 << VIR_DOMAIN_VIRT_XEN,
                                        VIR_DOMAIN_XML_INACTIVE)))
        goto error;

    VIR_FREE(xml);

    *ret_def = def;
    *ret_hdr = hdr;

    return fd;

error:
    VIR_FREE(xml);
    virDomainDefFree(def);
    VIR_FORCE_CLOSE(fd);
    return -1;
}

/*
 * Cleanup function for domain that has reached shutoff state.
 *
 * virDomainObjPtr should be locked on invocation
 */
static void
libxlVmCleanup(libxlDriverPrivatePtr driver,
               virDomainObjPtr vm,
               virDomainShutoffReason reason)
{
    libxlDomainObjPrivatePtr priv = vm->privateData;
    int vnc_port;
    char *file;
    int i;

    if (priv->eventHdl >= 0) {
        virEventRemoveHandle(priv->eventHdl);
        priv->eventHdl = -1;
    }

    if (priv->dWaiter) {
        libxl_stop_waiting(&priv->ctx, priv->dWaiter);
        libxl_free_waiter(priv->dWaiter);
        VIR_FREE(priv->dWaiter);
    }

    if (vm->persistent) {
        vm->def->id = -1;
        virDomainObjSetState(vm, VIR_DOMAIN_SHUTOFF, reason);
    }

    if ((vm->def->ngraphics == 1) &&
        vm->def->graphics[0]->type == VIR_DOMAIN_GRAPHICS_TYPE_VNC &&
        vm->def->graphics[0]->data.vnc.autoport) {
        vnc_port = vm->def->graphics[0]->data.vnc.port;
        if (vnc_port >= LIBXL_VNC_PORT_MIN) {
            if (virBitmapClearBit(driver->reservedVNCPorts,
                                  vnc_port - LIBXL_VNC_PORT_MIN) < 0)
                VIR_DEBUG("Could not mark port %d as unused", vnc_port);
        }
    }

    /* Remove any cputune settings */
    if (vm->def->cputune.nvcpupin) {
        for (i = 0; i < vm->def->cputune.nvcpupin; ++i) {
            VIR_FREE(vm->def->cputune.vcpupin[i]->cpumask);
            VIR_FREE(vm->def->cputune.vcpupin[i]);
        }
        VIR_FREE(vm->def->cputune.vcpupin);
        vm->def->cputune.nvcpupin = 0;
    }

    if (virAsprintf(&file, "%s/%s.xml", driver->stateDir, vm->def->name) > 0) {
        if (unlink(file) < 0 && errno != ENOENT && errno != ENOTDIR)
            VIR_DEBUG("Failed to remove domain XML for %s", vm->def->name);
        VIR_FREE(file);
    }

    if (vm->newDef) {
        virDomainDefFree(vm->def);
        vm->def = vm->newDef;
        vm->def->id = -1;
        vm->newDef = NULL;
    }
}

/*
 * Reap a domain from libxenlight.
 *
 * virDomainObjPtr should be locked on invocation
 */
static int
libxlVmReap(libxlDriverPrivatePtr driver,
            virDomainObjPtr vm,
            int force,
            virDomainShutoffReason reason)
{
    libxlDomainObjPrivatePtr priv = vm->privateData;

    if (libxl_domain_destroy(&priv->ctx, vm->def->id, force) < 0) {
        libxlError(VIR_ERR_INTERNAL_ERROR,
                   _("Unable to cleanup domain %d"), vm->def->id);
        return -1;
    }

    libxlVmCleanup(driver, vm, reason);
    return 0;
}

/*
 * Handle previously registered event notification from libxenlight
 */
static void libxlEventHandler(int watch,
                              int fd,
                              int events,
                              void *data)
{
    libxlDriverPrivatePtr driver = libxl_driver;
    virDomainObjPtr vm = data;
    libxlDomainObjPrivatePtr priv;
    virDomainEventPtr dom_event = NULL;
    libxl_event event;
    libxl_dominfo info;

    libxlDriverLock(driver);
    virDomainObjLock(vm);
    libxlDriverUnlock(driver);

    priv = vm->privateData;

    memset(&event, 0, sizeof(event));
    memset(&info, 0, sizeof(info));

    if (priv->waiterFD != fd || priv->eventHdl != watch) {
        virEventRemoveHandle(watch);
        priv->eventHdl = -1;
        goto cleanup;
    }

    if (!(events & VIR_EVENT_HANDLE_READABLE))
        goto cleanup;

    if (libxl_get_event(&priv->ctx, &event))
        goto cleanup;

    if (event.type == LIBXL_EVENT_DOMAIN_DEATH) {
        virDomainShutoffReason reason;

        /* libxl_event_get_domain_death_info returns 1 if death
         * event was for this domid */
        if (libxl_event_get_domain_death_info(&priv->ctx,
                                              vm->def->id,
                                              &event,
                                              &info) != 1)
            goto cleanup;

        virEventRemoveHandle(watch);
        priv->eventHdl = -1;
        switch (info.shutdown_reason) {
            case SHUTDOWN_poweroff:
            case SHUTDOWN_crash:
                if (info.shutdown_reason == SHUTDOWN_crash) {
                    dom_event = virDomainEventNewFromObj(vm,
                                              VIR_DOMAIN_EVENT_STOPPED,
                                              VIR_DOMAIN_EVENT_STOPPED_CRASHED);
                    reason = VIR_DOMAIN_SHUTOFF_CRASHED;
                } else {
                    reason = VIR_DOMAIN_SHUTOFF_SHUTDOWN;
                }
                libxlVmReap(driver, vm, 0, reason);
                if (!vm->persistent) {
                    virDomainRemoveInactive(&driver->domains, vm);
                    vm = NULL;
                }
                break;
            case SHUTDOWN_reboot:
                libxlVmReap(driver, vm, 0, VIR_DOMAIN_SHUTOFF_SHUTDOWN);
                libxlVmStart(driver, vm, 0, -1, false);
                break;
            default:
                VIR_INFO("Unhandled shutdown_reason %d", info.shutdown_reason);
                break;
        }
    }

cleanup:
    if (vm)
        virDomainObjUnlock(vm);
    if (dom_event) {
        libxlDriverLock(driver);
        libxlDomainEventQueue(driver, dom_event);
        libxlDriverUnlock(driver);
    }
    libxl_free_event(&event);
}

/*
 * Register domain events with libxenlight and insert event handles
 * in libvirt's event loop.
 */
static int
libxlCreateDomEvents(virDomainObjPtr vm)
{
    libxlDomainObjPrivatePtr priv = vm->privateData;
    int fd;

    if (VIR_ALLOC(priv->dWaiter) < 0) {
        virReportOOMError();
        return -1;
    }

    if (libxl_wait_for_domain_death(&priv->ctx, vm->def->id, priv->dWaiter))
        goto error;

    libxl_get_wait_fd(&priv->ctx, &fd);
    if (fd < 0)
        goto error;

    priv->waiterFD = fd;
    /* Add a reference to the domain object while it is injected in
     * the event loop.
     */
    virDomainObjRef(vm);
    if ((priv->eventHdl = virEventAddHandle(
             fd,
             VIR_EVENT_HANDLE_READABLE | VIR_EVENT_HANDLE_ERROR,
             libxlEventHandler,
             vm, libxlDomainObjUnref)) < 0) {
        ignore_value(virDomainObjUnref(vm));
        goto error;
    }

    return 0;

error:
    libxl_free_waiter(priv->dWaiter);
    VIR_FREE(priv->dWaiter);
    priv->eventHdl = -1;
    return -1;
}

static int
libxlDomainSetVcpuAffinites(libxlDriverPrivatePtr driver, virDomainObjPtr vm)
{
    libxlDomainObjPrivatePtr priv = vm->privateData;
    virDomainDefPtr def = vm->def;
    libxl_cpumap map;
    uint8_t *cpumask = NULL;
    uint8_t *cpumap = NULL;
    virNodeInfo nodeinfo;
    size_t cpumaplen;
    int vcpu, i;
    int ret = -1;

    if (libxlDoNodeGetInfo(driver, &nodeinfo) < 0)
        goto cleanup;

    cpumaplen = VIR_CPU_MAPLEN(VIR_NODEINFO_MAXCPUS(nodeinfo));

    for (vcpu = 0; vcpu < def->cputune.nvcpupin; ++vcpu) {
        if (vcpu != def->cputune.vcpupin[vcpu]->vcpuid)
            continue;

        if (VIR_ALLOC_N(cpumap, cpumaplen) < 0) {
            virReportOOMError();
            goto cleanup;
        }

        cpumask = (uint8_t*) def->cputune.vcpupin[vcpu]->cpumask;

        for (i = 0; i < VIR_DOMAIN_CPUMASK_LEN; ++i) {
            if (cpumask[i])
                VIR_USE_CPU(cpumap, i);
        }

        map.size = cpumaplen;
        map.map = cpumap;

        if (libxl_set_vcpuaffinity(&priv->ctx, def->id, vcpu, &map) != 0) {
            libxlError(VIR_ERR_INTERNAL_ERROR,
                       _("Failed to pin vcpu '%d' with libxenlight"), vcpu);
            goto cleanup;
        }

        VIR_FREE(cpumap);
    }

    ret = 0;

cleanup:
    VIR_FREE(cpumap);
    return ret;
}

static int
libxlFreeMem(libxlDomainObjPrivatePtr priv, libxl_domain_config *d_config)
{
    uint32_t needed_mem;
    uint32_t free_mem;
    int i;
    int ret = -1;
    int tries = 3;
    int wait_secs = 10;

    if ((ret = libxl_domain_need_memory(&priv->ctx, &d_config->b_info,
                                        &d_config->dm_info,
                                        &needed_mem)) >= 0) {
        for (i = 0; i < tries; ++i) {
            if ((ret = libxl_get_free_memory(&priv->ctx, &free_mem)) < 0)
                break;

            if (free_mem >= needed_mem) {
                ret = 0;
                break;
            }

            if ((ret = libxl_set_memory_target(&priv->ctx, 0,
                                               free_mem - needed_mem,
                                               /* relative */ 1, 0)) < 0)
                break;

            ret = libxl_wait_for_free_memory(&priv->ctx, 0, needed_mem,
                                             wait_secs);
            if (ret == 0 || ret != ERROR_NOMEM)
                break;

            if ((ret = libxl_wait_for_memory_target(&priv->ctx, 0, 1)) < 0)
                break;
        }
    }

    return ret;
}

/*
 * Start a domain through libxenlight.
 *
 * virDomainObjPtr should be locked on invocation; driver_locked says if 
 * libxlDriverPrivatePtr is locked or not.
 */
static int
libxlVmStart(libxlDriverPrivatePtr driver, virDomainObjPtr vm,
             bool start_paused, int restore_fd, bool driver_locked)
{
    libxl_domain_config d_config;
    virDomainDefPtr def = NULL;
    virDomainEventPtr event = NULL;
    libxlSavefileHeader hdr;
    int ret;
    uint32_t domid = 0;
    char *dom_xml = NULL;
    char *managed_save_path = NULL;
    int managed_save_fd = -1;
    pid_t child_console_pid = -1;
    libxlDomainObjPrivatePtr priv = vm->privateData;


    /* If there is a managed saved state restore it instead of starting
     * from scratch. The old state is removed once the restoring succeeded. */
    if (restore_fd < 0) {
        managed_save_path = libxlDomainManagedSavePath(driver, vm);
        if (managed_save_path == NULL)
            goto error;

        if (virFileExists(managed_save_path)) {

            managed_save_fd = libxlSaveImageOpen(driver, managed_save_path,
                                                 &def, &hdr);
            if (managed_save_fd < 0)
                goto error;

            restore_fd = managed_save_fd;

            if (STRNEQ(vm->def->name, def->name) ||
                memcmp(vm->def->uuid, def->uuid, VIR_UUID_BUFLEN)) {
                char vm_uuidstr[VIR_UUID_STRING_BUFLEN];
                char def_uuidstr[VIR_UUID_STRING_BUFLEN];
                virUUIDFormat(vm->def->uuid, vm_uuidstr);
                virUUIDFormat(def->uuid, def_uuidstr);
                libxlError(VIR_ERR_OPERATION_FAILED,
                           _("cannot restore domain '%s' uuid %s from a file"
                             " which belongs to domain '%s' uuid %s"),
                           vm->def->name, vm_uuidstr, def->name, def_uuidstr);
                goto error;
            }

            virDomainObjAssignDef(vm, def, true);
            def = NULL;

            if (unlink(managed_save_path) < 0) {
                VIR_WARN("Failed to remove the managed state %s",
                         managed_save_path);
            }
        }
        VIR_FREE(managed_save_path);
    }

    memset(&d_config, 0, sizeof(d_config));

    if (libxlBuildDomainConfig(driver, vm->def, &d_config) < 0 )
        return -1;

    if (libxlFreeMem(priv, &d_config) < 0) {
        libxlError(VIR_ERR_INTERNAL_ERROR,
                   _("libxenlight failed to get free memory for domain '%s'"),
                   d_config.c_info.name);
        goto error;
    }

    if ( driver_locked ) {
        libxlDriverUnlock(driver);
    }
    VIR_INFO("");
    if (restore_fd < 0)
        ret = libxl_domain_create_new(&priv->ctx, &d_config,
                                      NULL, &child_console_pid, &domid);
    else
        ret = libxl_domain_create_restore(&priv->ctx, &d_config, NULL,
                                          &child_console_pid, &domid,
                                          restore_fd);
    if ( driver_locked ) {
        VIR_INFO("");
        virDomainObjUnlock(vm);
        VIR_INFO("");
        libxlDriverLock(driver);
        VIR_INFO("");
        virDomainObjLock(vm);
        VIR_INFO("");
    }

    if (ret) {
        if (restore_fd < 0)
            libxlError(VIR_ERR_INTERNAL_ERROR,
                       _("libxenlight failed to create new domain '%s'"),
                       d_config.c_info.name);
        else
            libxlError(VIR_ERR_INTERNAL_ERROR,
                       _("libxenlight failed to restore domain '%s'"),
                       d_config.c_info.name);
        goto error;
    }

    vm->def->id = domid;
    if ((dom_xml = virDomainDefFormat(vm->def, 0)) == NULL)
        goto error;

    if (libxl_userdata_store(&priv->ctx, domid, "libvirt-xml",
                             (uint8_t *)dom_xml, strlen(dom_xml) + 1)) {
        libxlError(VIR_ERR_INTERNAL_ERROR,
                   _("libxenlight failed to store userdata"));
        goto error;
    }

    if (libxlCreateDomEvents(vm) < 0)
        goto error;

    if (libxlDomainSetVcpuAffinites(driver, vm) < 0)
        goto error;

    if (!start_paused) {
        libxl_domain_unpause(&priv->ctx, domid);
        virDomainObjSetState(vm, VIR_DOMAIN_RUNNING, VIR_DOMAIN_RUNNING_BOOTED);
    } else {
        virDomainObjSetState(vm, VIR_DOMAIN_PAUSED, VIR_DOMAIN_PAUSED_USER);
    }


    if (virDomainSaveStatus(driver->caps, driver->stateDir, vm) < 0)
        goto error;

    event = virDomainEventNewFromObj(vm, VIR_DOMAIN_EVENT_STARTED,
                                     restore_fd < 0 ?
                                         VIR_DOMAIN_EVENT_STARTED_BOOTED :
                                         VIR_DOMAIN_EVENT_STARTED_RESTORED);
    libxlDomainEventQueue(driver, event);

    libxl_domain_config_destroy(&d_config);
    VIR_FREE(dom_xml);
    VIR_FORCE_CLOSE(managed_save_fd);
    return 0;

error:
    if (domid > 0) {
        libxl_domain_destroy(&priv->ctx, domid, 0);
        vm->def->id = -1;
        virDomainObjSetState(vm, VIR_DOMAIN_SHUTOFF, VIR_DOMAIN_SHUTOFF_FAILED);
    }
    libxl_domain_config_destroy(&d_config);
    VIR_FREE(dom_xml);
    VIR_FREE(managed_save_path);
    virDomainDefFree(def);
    VIR_FORCE_CLOSE(managed_save_fd);
    return -1;
}


/*
 * Reconnect to running domains that were previously started/created
 * with libxenlight driver.
 */
static void
libxlReconnectDomain(void *payload,
                     const void *name ATTRIBUTE_UNUSED,
                     void *opaque)
{
    virDomainObjPtr vm = payload;
    libxlDriverPrivatePtr driver = opaque;
    int rc;
    libxl_dominfo d_info;
    int len;
    uint8_t *data = NULL;

    virDomainObjLock(vm);

    /* Does domain still exist? */
    rc = libxl_domain_info(&driver->ctx, &d_info, vm->def->id);
    if (rc == ERROR_INVAL) {
        goto out;
    } else if (rc != 0) {
        VIR_DEBUG("libxl_domain_info failed (code %d), ignoring domain %d",
                  rc, vm->def->id);
        goto out;
    }

    /* Is this a domain that was under libvirt control? */
    if (libxl_userdata_retrieve(&driver->ctx, vm->def->id,
                                "libvirt-xml", &data, &len)) {
        VIR_DEBUG("libxl_userdata_retrieve failed, ignoring domain %d", vm->def->id);
        goto out;
    }

    /* Update domid in case it changed (e.g. reboot) while we were gone? */
    vm->def->id = d_info.domid;
    virDomainObjSetState(vm, VIR_DOMAIN_RUNNING, VIR_DOMAIN_RUNNING_UNKNOWN);

    /* Recreate domain death et. al. events */
    libxlCreateDomEvents(vm);
    virDomainObjUnlock(vm);
    return;

out:
    libxlVmCleanup(driver, vm, VIR_DOMAIN_SHUTOFF_UNKNOWN);
    if (!vm->persistent)
        virDomainRemoveInactive(&driver->domains, vm);
    else
        virDomainObjUnlock(vm);
}

static void
libxlReconnectDomains(libxlDriverPrivatePtr driver)
{
    virHashForEach(driver->domains.objs, libxlReconnectDomain, driver);
}

static int
libxlShutdown(void)
{
    if (!libxl_driver)
        return -1;

    libxlDriverLock(libxl_driver);
    virCapabilitiesFree(libxl_driver->caps);
    virDomainObjListDeinit(&libxl_driver->domains);
    libxl_ctx_free(&libxl_driver->ctx);
    xtl_logger_destroy(libxl_driver->logger);
    if (libxl_driver->logger_file)
        VIR_FORCE_FCLOSE(libxl_driver->logger_file);

    virBitmapFree(libxl_driver->reservedVNCPorts);
    virBitmapFree(libxl_driver->reservedMigPorts);

    VIR_FREE(libxl_driver->configDir);
    VIR_FREE(libxl_driver->autostartDir);
    VIR_FREE(libxl_driver->logDir);
    VIR_FREE(libxl_driver->stateDir);
    VIR_FREE(libxl_driver->libDir);
    VIR_FREE(libxl_driver->saveDir);

    virDomainEventStateFree(libxl_driver->domainEventState);

    libxlDriverUnlock(libxl_driver);
    virMutexDestroy(&libxl_driver->lock);
    VIR_FREE(libxl_driver);

    return 0;
}

static int
libxlStartup(int privileged) {
    const libxl_version_info *ver_info;
    char *log_file = NULL;
    virCommandPtr cmd;
    int status, ret = 0;
    char ebuf[1024];

    /* Disable libxl driver if non-root */
    if (!privileged) {
        VIR_INFO("Not running privileged, disabling libxenlight driver");
        return 0;
    }

    /* Disable driver if legacy xen toolstack (xend) is in use */
    cmd = virCommandNewArgList("/usr/sbin/xend", "status", NULL);
    if (virCommandRun(cmd, &status) == 0 && status == 0) {
        VIR_INFO("Legacy xen tool stack seems to be in use, disabling "
                  "libxenlight driver.");
        virCommandFree(cmd);
        return 0;
    }
    virCommandFree(cmd);

    if (VIR_ALLOC(libxl_driver) < 0)
        return -1;

    if (virMutexInit(&libxl_driver->lock) < 0) {
        VIR_ERROR(_("cannot initialize mutex"));
        VIR_FREE(libxl_driver);
        return -1;
    }
    libxlDriverLock(libxl_driver);

    /* Allocate bitmap for vnc port reservation */
    if ((libxl_driver->reservedVNCPorts =
         virBitmapAlloc(LIBXL_VNC_PORT_MAX - LIBXL_VNC_PORT_MIN)) == NULL)
        goto out_of_memory;

    if ((libxl_driver->reservedMigPorts =
         virBitmapAlloc(LIBXL_MIGRATION_MAX_PORT - LIBXL_MIGRATION_MIN_PORT)) == NULL)
        goto out_of_memory;

    if (virDomainObjListInit(&libxl_driver->domains) < 0)
        goto out_of_memory;

    if (virAsprintf(&libxl_driver->configDir,
                    "%s", LIBXL_CONFIG_DIR) == -1)
        goto out_of_memory;

    if (virAsprintf(&libxl_driver->autostartDir,
                    "%s", LIBXL_AUTOSTART_DIR) == -1)
        goto out_of_memory;

    if (virAsprintf(&libxl_driver->logDir,
                    "%s", LIBXL_LOG_DIR) == -1)
        goto out_of_memory;

    if (virAsprintf(&libxl_driver->stateDir,
                    "%s", LIBXL_STATE_DIR) == -1)
        goto out_of_memory;

    if (virAsprintf(&libxl_driver->libDir,
                    "%s", LIBXL_LIB_DIR) == -1)
        goto out_of_memory;

    if (virAsprintf(&libxl_driver->saveDir,
                    "%s", LIBXL_SAVE_DIR) == -1)
        goto out_of_memory;

    if (virFileMakePath(libxl_driver->logDir) < 0) {
        VIR_ERROR(_("Failed to create log dir '%s': %s"),
                  libxl_driver->logDir, virStrerror(errno, ebuf, sizeof(ebuf)));
        goto error;
    }
    if (virFileMakePath(libxl_driver->stateDir) < 0) {
        VIR_ERROR(_("Failed to create state dir '%s': %s"),
                  libxl_driver->stateDir, virStrerror(errno, ebuf, sizeof(ebuf)));
        goto error;
    }
    if (virFileMakePath(libxl_driver->libDir) < 0) {
        VIR_ERROR(_("Failed to create lib dir '%s': %s"),
                  libxl_driver->libDir, virStrerror(errno, ebuf, sizeof(ebuf)));
        goto error;
    }
    if (virFileMakePath(libxl_driver->saveDir) < 0) {
        VIR_ERROR(_("Failed to create save dir '%s': %s"),
                  libxl_driver->saveDir, virStrerror(errno, ebuf, sizeof(ebuf)));
        goto error;
    }

    if (virAsprintf(&log_file, "%s/libxl.log", libxl_driver->logDir) < 0) {
        goto out_of_memory;
    }

    if ((libxl_driver->logger_file = fopen(log_file, "a")) == NULL)  {
        virReportSystemError(errno,
                             _("failed to create logfile %s"),
                             log_file);
        goto error;
    }
    VIR_FREE(log_file);

    libxl_driver->domainEventState = virDomainEventStateNew();
    if (!libxl_driver->domainEventState)
        goto error;

    libxl_driver->logger =
            (xentoollog_logger *)xtl_createlogger_stdiostream(libxl_driver->logger_file, XTL_DEBUG,  0);
    if (!libxl_driver->logger) {
        VIR_INFO("cannot create logger for libxenlight, disabling driver");
        goto fail;
    }

    if (libxl_ctx_init(&libxl_driver->ctx,
                       LIBXL_VERSION,
                       libxl_driver->logger)) {
        VIR_INFO("cannot initialize libxenlight context, probably not running in a Xen Dom0, disabling driver");
        goto fail;
    }

    if ((ver_info = libxl_get_version_info(&libxl_driver->ctx)) == NULL) {
        VIR_INFO("cannot version information from libxenlight, disabling driver");
        goto fail;
    }
    libxl_driver->version = (ver_info->xen_version_major * 1000000) +
            (ver_info->xen_version_minor * 1000);

    if ((libxl_driver->caps =
         libxlMakeCapabilities(&libxl_driver->ctx)) == NULL) {
        VIR_ERROR(_("cannot create capabilities for libxenlight"));
        goto error;
    }

    libxl_driver->caps->privateDataAllocFunc = libxlDomainObjPrivateAlloc;
    libxl_driver->caps->privateDataFreeFunc = libxlDomainObjPrivateFree;

    /* Load running domains first. */
    if (virDomainLoadAllConfigs(libxl_driver->caps,
                                &libxl_driver->domains,
                                libxl_driver->stateDir,
                                libxl_driver->autostartDir,
                                1, 1 << VIR_DOMAIN_VIRT_XEN,
                                NULL, NULL) < 0)
        goto error;

    libxlReconnectDomains(libxl_driver);

    /* Then inactive persistent configs */
    if (virDomainLoadAllConfigs(libxl_driver->caps,
                                &libxl_driver->domains,
                                libxl_driver->configDir,
                                libxl_driver->autostartDir,
                                0, 1 << VIR_DOMAIN_VIRT_XEN,
                                NULL, NULL) < 0)
        goto error;

    virHashForEach(libxl_driver->domains.objs, libxlAutostartDomain,
                   libxl_driver);

    libxl_driver->max_queued = 0;

    libxlDriverUnlock(libxl_driver);

    return 0;

out_of_memory:
    virReportOOMError();
error:
    ret = -1;
fail:
    VIR_FREE(log_file);
    if (libxl_driver)
        libxlDriverUnlock(libxl_driver);
    libxlShutdown();
    return ret;
}

static int
libxlReload(void)
{
    if (!libxl_driver)
        return 0;

    libxlDriverLock(libxl_driver);
    virDomainLoadAllConfigs(libxl_driver->caps,
                            &libxl_driver->domains,
                            libxl_driver->configDir,
                            libxl_driver->autostartDir,
                            1, 1 << VIR_DOMAIN_VIRT_XEN,
                            NULL, libxl_driver);

    virHashForEach(libxl_driver->domains.objs, libxlAutostartDomain,
                   libxl_driver);

    libxlDriverUnlock(libxl_driver);

    return 0;
}

static int
libxlActive(void)
{
    if (!libxl_driver)
        return 0;

    return 1;
}

static virDrvOpenStatus
libxlOpen(virConnectPtr conn,
          virConnectAuthPtr auth ATTRIBUTE_UNUSED,
          unsigned int flags)
{
    virCheckFlags(VIR_CONNECT_RO, VIR_DRV_OPEN_ERROR);

    if (conn->uri == NULL) {
        if (libxl_driver == NULL)
            return VIR_DRV_OPEN_DECLINED;

        if (!(conn->uri = virURIParse("xen:///")))
            return VIR_DRV_OPEN_ERROR;
    } else {
        /* Only xen scheme */
        if (conn->uri->scheme == NULL || STRNEQ(conn->uri->scheme, "xen"))
            return VIR_DRV_OPEN_DECLINED;

        /* If server name is given, its for remote driver */
        if (conn->uri->server != NULL)
            return VIR_DRV_OPEN_DECLINED;

        /* Error if xen or libxl scheme specified but driver not started. */
        if (libxl_driver == NULL) {
            libxlError(VIR_ERR_INTERNAL_ERROR, "%s",
                       _("libxenlight state driver is not active"));
            return VIR_DRV_OPEN_ERROR;
        }

        /* /session isn't supported in libxenlight */
        if (conn->uri->path &&
            STRNEQ(conn->uri->path, "") &&
            STRNEQ(conn->uri->path, "/") &&
            STRNEQ(conn->uri->path, "/system")) {
            libxlError(VIR_ERR_INTERNAL_ERROR,
                       _("unexpected Xen URI path '%s', try xen:///"),
                       NULLSTR(conn->uri->path));
            return VIR_DRV_OPEN_ERROR;
        }
    }

    conn->privateData = libxl_driver;

    return VIR_DRV_OPEN_SUCCESS;
};

static int
libxlClose(virConnectPtr conn ATTRIBUTE_UNUSED)
{
    libxlDriverPrivatePtr driver = conn->privateData;

    libxlDriverLock(driver);
    virDomainEventStateDeregisterConn(conn,
                                      driver->domainEventState);
    libxlDriverUnlock(driver);
    conn->privateData = NULL;
    return 0;
}

static int
libxlSupportsFeature(virConnectPtr conn ATTRIBUTE_UNUSED, int feature)
{
    switch (feature) {
    case VIR_DRV_FEATURE_MIGRATION_V3:
        return 1;
    default:
        return 0;
    }
}

static const char *
libxlGetType(virConnectPtr conn ATTRIBUTE_UNUSED)
{
    return "xenlight";
}

static int
libxlGetVersion(virConnectPtr conn, unsigned long *version)
{
    libxlDriverPrivatePtr driver = conn->privateData;

    libxlDriverLock(driver);
    *version = driver->version;
    libxlDriverUnlock(driver);
    return 0;
}

static int
libxlGetMaxVcpus(virConnectPtr conn, const char *type ATTRIBUTE_UNUSED)
{
    int ret;
    libxlDriverPrivatePtr driver = conn->privateData;

    ret = libxl_get_max_cpus(&driver->ctx);
    /* libxl_get_max_cpus() will return 0 if there were any failures,
       e.g. xc_physinfo() failing */
    if (ret == 0)
        return -1;

    return ret;
}

static int
libxlNodeGetInfo(virConnectPtr conn, virNodeInfoPtr info)
{
    return libxlDoNodeGetInfo(conn->privateData, info);
}

static char *
libxlGetCapabilities(virConnectPtr conn)
{
    libxlDriverPrivatePtr driver = conn->privateData;
    char *xml;

    libxlDriverLock(driver);
    if ((xml = virCapabilitiesFormatXML(driver->caps)) == NULL)
        virReportOOMError();
    libxlDriverUnlock(driver);

    return xml;
}

static int
libxlListDomains(virConnectPtr conn, int *ids, int nids)
{
    libxlDriverPrivatePtr driver = conn->privateData;
    int n;

    libxlDriverLock(driver);
    n = virDomainObjListGetActiveIDs(&driver->domains, ids, nids);
    libxlDriverUnlock(driver);

    return n;
}

static int
libxlNumDomains(virConnectPtr conn)
{
    libxlDriverPrivatePtr driver = conn->privateData;
    int n;

    libxlDriverLock(driver);
    n = virDomainObjListNumOfDomains(&driver->domains, 1);
    libxlDriverUnlock(driver);

    return n;
}

static virDomainPtr
libxlDomainCreateXML(virConnectPtr conn, const char *xml,
                     unsigned int flags)
{
    libxlDriverPrivatePtr driver = conn->privateData;
    virDomainDefPtr def;
    virDomainObjPtr vm = NULL;
    virDomainPtr dom = NULL;

    virCheckFlags(VIR_DOMAIN_START_PAUSED, NULL);

    libxlDriverLock(driver);
    if (!(def = virDomainDefParseString(driver->caps, xml,
                                        1 << VIR_DOMAIN_VIRT_XEN,
                                        VIR_DOMAIN_XML_INACTIVE)))
        goto cleanup;

    if (virDomainObjIsDuplicate(&driver->domains, def, 1) < 0)
        goto cleanup;

    if (!(vm = virDomainAssignDef(driver->caps,
                                  &driver->domains, def, false)))
        goto cleanup;
    def = NULL;

    if (libxlDomainObjBeginJobWithDriver(driver, vm, LIBXL_JOB_MODIFY) < 0)
        goto cleanup;

    if (libxlVmStart(driver, vm, (flags & VIR_DOMAIN_START_PAUSED) != 0,
                     -1, false) < 0) {
        if (libxlDomainObjEndJob(driver, vm) > 0)
            virDomainRemoveInactive(&driver->domains, vm);
        vm = NULL;
        goto cleanup;
    }

    dom = virGetDomain(conn, vm->def->name, vm->def->uuid);
    if (dom)
        dom->id = vm->def->id;

    if (libxlDomainObjEndJob(driver, vm) == 0)
        vm = NULL;
cleanup:
    virDomainDefFree(def);
    if (vm)
        virDomainObjUnlock(vm);
    libxlDriverUnlock(driver);
    return dom;
}

static virDomainPtr
libxlDomainLookupByID(virConnectPtr conn, int id)
{
    libxlDriverPrivatePtr driver = conn->privateData;
    virDomainObjPtr vm;
    virDomainPtr dom = NULL;

    libxlDriverLock(driver);
    vm = virDomainFindByID(&driver->domains, id);
    libxlDriverUnlock(driver);

    if (!vm) {
        libxlError(VIR_ERR_NO_DOMAIN, NULL);
        goto cleanup;
    }

    dom = virGetDomain(conn, vm->def->name, vm->def->uuid);
    if (dom)
        dom->id = vm->def->id;

  cleanup:
    if (vm)
        virDomainObjUnlock(vm);
    return dom;
}

static virDomainPtr
libxlDomainLookupByUUID(virConnectPtr conn, const unsigned char *uuid)
{
    libxlDriverPrivatePtr driver = conn->privateData;
    virDomainObjPtr vm;
    virDomainPtr dom = NULL;

    libxlDriverLock(driver);
    vm = virDomainFindByUUID(&driver->domains, uuid);
    libxlDriverUnlock(driver);

    if (!vm) {
        libxlError(VIR_ERR_NO_DOMAIN, NULL);
        goto cleanup;
    }

    dom = virGetDomain(conn, vm->def->name, vm->def->uuid);
    if (dom)
        dom->id = vm->def->id;

  cleanup:
    if (vm)
        virDomainObjUnlock(vm);
    return dom;
}

static virDomainPtr
libxlDomainLookupByName(virConnectPtr conn, const char *name)
{
    libxlDriverPrivatePtr driver = conn->privateData;
    virDomainObjPtr vm;
    virDomainPtr dom = NULL;

    libxlDriverLock(driver);
    vm = virDomainFindByName(&driver->domains, name);
    libxlDriverUnlock(driver);

    if (!vm) {
        libxlError(VIR_ERR_NO_DOMAIN, NULL);
        goto cleanup;
    }

    dom = virGetDomain(conn, vm->def->name, vm->def->uuid);
    if (dom)
        dom->id = vm->def->id;

  cleanup:
    if (vm)
        virDomainObjUnlock(vm);
    return dom;
}

static int
libxlDomainSuspend(virDomainPtr dom)
{
    libxlDriverPrivatePtr driver = dom->conn->privateData;
    virDomainObjPtr vm;
    libxlDomainObjPrivatePtr priv;
    virDomainEventPtr event = NULL;
    int ret = -1;
//    virDomainPausedReason reason;
//    int eventDetail;

    libxlDriverLock(driver);
    vm = virDomainFindByUUID(&driver->domains, dom->uuid);
    libxlDriverUnlock(driver);

    if (!vm) {
        char uuidstr[VIR_UUID_STRING_BUFLEN];
        virUUIDFormat(dom->uuid, uuidstr);
        libxlError(VIR_ERR_NO_DOMAIN,
                   _("No domain with matching uuid '%s'"), uuidstr);
        goto cleanup;
    }
    if (!virDomainObjIsActive(vm)) {
        libxlError(VIR_ERR_OPERATION_INVALID, "%s", _("Domain is not running"));
        goto cleanup;
    }

    priv = vm->privateData;

//    if (priv->job.asyncJob == LIBXL_ASYNC_JOB_MIGRATION_OUT) {
//        reason = VIR_DOMAIN_PAUSED_MIGRATION;
//        eventDetail = VIR_DOMAIN_EVENT_SUSPENDED_MIGRATED;
//    } else {
//        reason = VIR_DOMAIN_PAUSED_USER;
//        eventDetail = VIR_DOMAIN_EVENT_SUSPENDED_PAUSED;
//    }
//
//    if (libxlDomainObjBeginJob(driver, vm, LIBXL_JOB_MODIFY) < 0)
//        goto cleanup;
//
//    if (!virDomainObjIsActive(vm)) {
//        libxlError(VIR_ERR_OPERATION_INVALID, "%s", _("Domain is not running"));
//        goto endjob;
//    }
//
    if (virDomainObjGetState(vm, NULL) != VIR_DOMAIN_PAUSED) {
        if (libxl_domain_pause(&priv->ctx, dom->id) != 0) {
            libxlError(VIR_ERR_INTERNAL_ERROR,
                       _("Failed to suspend domain '%d' with libxenlight"),
                       dom->id);
            goto endjob;
        }

        virDomainObjSetState(vm, VIR_DOMAIN_PAUSED, VIR_DOMAIN_PAUSED_USER);
//        virDomainObjSetState(vm, VIR_DOMAIN_PAUSED, reason);

        event = virDomainEventNewFromObj(vm, VIR_DOMAIN_EVENT_SUSPENDED,
                                         VIR_DOMAIN_EVENT_SUSPENDED_PAUSED);
//                                         eventDetail);
    }

    if (virDomainSaveStatus(driver->caps, driver->stateDir, vm) < 0)
        goto endjob;

    ret = 0;

endjob:
    if (libxlDomainObjEndJob(driver, vm) == 0)
        vm = NULL;

cleanup:
    if (vm)
        virDomainObjUnlock(vm);
    if (event) {
        libxlDriverLock(driver);
        libxlDomainEventQueue(driver, event);
        libxlDriverUnlock(driver);
    }
    return ret;
}


static int
libxlDomainResume(virDomainPtr dom)
{
    libxlDriverPrivatePtr driver = dom->conn->privateData;
    virDomainObjPtr vm;
    libxlDomainObjPrivatePtr priv;
    virDomainEventPtr event = NULL;
    int ret = -1;

    libxlDriverLock(driver);
    vm = virDomainFindByUUID(&driver->domains, dom->uuid);
    libxlDriverUnlock(driver);

    if (!vm) {
        char uuidstr[VIR_UUID_STRING_BUFLEN];
        virUUIDFormat(dom->uuid, uuidstr);
        libxlError(VIR_ERR_NO_DOMAIN,
                   _("No domain with matching uuid '%s'"), uuidstr);
        goto cleanup;
    }

    priv = vm->privateData;

    if (libxlDomainObjBeginJob(driver, vm, LIBXL_JOB_MODIFY) < 0)
        goto cleanup;

    if (!virDomainObjIsActive(vm)) {
        libxlError(VIR_ERR_OPERATION_INVALID, "%s", _("Domain is not running"));
        goto endjob;
    }

    if (virDomainObjGetState(vm, NULL) == VIR_DOMAIN_PAUSED) {
        if (libxl_domain_unpause(&priv->ctx, dom->id) != 0) {
            libxlError(VIR_ERR_INTERNAL_ERROR,
                       _("Failed to resume domain '%d' with libxenlight"),
                       dom->id);
            goto endjob;
        }

        virDomainObjSetState(vm, VIR_DOMAIN_RUNNING,
                             VIR_DOMAIN_RUNNING_UNPAUSED);

        event = virDomainEventNewFromObj(vm, VIR_DOMAIN_EVENT_RESUMED,
                                         VIR_DOMAIN_EVENT_RESUMED_UNPAUSED);
    }

    if (virDomainSaveStatus(driver->caps, driver->stateDir, vm) < 0)
        goto endjob;

    ret = 0;

endjob:
    if (libxlDomainObjEndJob(driver, vm) == 0)
        vm = NULL;

cleanup:
    if (vm)
        virDomainObjUnlock(vm);
    if (event) {
        libxlDriverLock(driver);
        libxlDomainEventQueue(driver, event);
        libxlDriverUnlock(driver);
    }
    return ret;
}

static int
libxlDomainShutdownFlags(virDomainPtr dom, unsigned int flags)
{
    libxlDriverPrivatePtr driver = dom->conn->privateData;
    virDomainObjPtr vm;
    int ret = -1;
    libxlDomainObjPrivatePtr priv;

    virCheckFlags(0, -1);

    libxlDriverLock(driver);
    vm = virDomainFindByUUID(&driver->domains, dom->uuid);
    if (!vm) {
        char uuidstr[VIR_UUID_STRING_BUFLEN];
        virUUIDFormat(dom->uuid, uuidstr);
        libxlError(VIR_ERR_NO_DOMAIN,
                   _("No domain with matching uuid '%s'"), uuidstr);
        goto cleanup;
    }

    if (libxlDomainObjBeginJobWithDriver(driver, vm, LIBXL_JOB_MODIFY) < 0)
        goto cleanup;

    if (!virDomainObjIsActive(vm)) {
        libxlError(VIR_ERR_OPERATION_INVALID,
                   "%s", _("Domain is not running"));
        goto endjob;
    }

    priv = vm->privateData;

    if (libxl_domain_shutdown(&priv->ctx, dom->id, LIBXL_DOM_REQ_POWEROFF) != 0) {
        libxlError(VIR_ERR_INTERNAL_ERROR,
                   _("Failed to shutdown domain '%d' with libxenlight"),
                   dom->id);
        goto endjob;
    }

    /* vm is marked shutoff (or removed from domains list if not persistent)
     * in shutdown event handler.
     */
    ret = 0;

endjob:
    if (libxlDomainObjEndJob(driver, vm) == 0)
        vm = NULL;

cleanup:
    if (vm)
        virDomainObjUnlock(vm);
    libxlDriverUnlock(driver);
    return ret;
}

static int
libxlDomainShutdown(virDomainPtr dom)
{
    return libxlDomainShutdownFlags(dom, 0);
}


static int
libxlDomainReboot(virDomainPtr dom, unsigned int flags)
{
    libxlDriverPrivatePtr driver = dom->conn->privateData;
    virDomainObjPtr vm;
    int ret = -1;
    libxlDomainObjPrivatePtr priv;

    virCheckFlags(0, -1);

    libxlDriverLock(driver);
    vm = virDomainFindByUUID(&driver->domains, dom->uuid);
    if (!vm) {
        char uuidstr[VIR_UUID_STRING_BUFLEN];
        virUUIDFormat(dom->uuid, uuidstr);
        libxlError(VIR_ERR_NO_DOMAIN,
                   _("No domain with matching uuid '%s'"), uuidstr);
        goto cleanup;
    }

    if (libxlDomainObjBeginJobWithDriver(driver, vm, LIBXL_JOB_MODIFY) < 0)
        goto cleanup;

    if (!virDomainObjIsActive(vm)) {
        libxlError(VIR_ERR_OPERATION_INVALID,
                   "%s", _("Domain is not running"));
        goto endjob;
    }

    priv = vm->privateData;

    if (libxl_domain_shutdown(&priv->ctx, dom->id, LIBXL_DOM_REQ_REBOOT) != 0) {
        libxlError(VIR_ERR_INTERNAL_ERROR,
                   _("Failed to reboot domain '%d' with libxenlight"),
                   dom->id);
        goto endjob;
    }
    ret = 0;

endjob:
    if (libxlDomainObjEndJob(driver, vm) == 0)
        vm = NULL;

cleanup:
    if (vm)
        virDomainObjUnlock(vm);
    libxlDriverUnlock(driver);
    return ret;
}

static int
libxlDomainDestroyFlags(virDomainPtr dom,
                        unsigned int flags)
{
    libxlDriverPrivatePtr driver = dom->conn->privateData;
    virDomainObjPtr vm;
    int ret = -1;
    virDomainEventPtr event = NULL;

    virCheckFlags(0, -1);

    libxlDriverLock(driver);
    vm = virDomainFindByUUID(&driver->domains, dom->uuid);
    if (!vm) {
        char uuidstr[VIR_UUID_STRING_BUFLEN];
        virUUIDFormat(dom->uuid, uuidstr);
        libxlError(VIR_ERR_NO_DOMAIN,
                   _("No domain with matching uuid '%s'"), uuidstr);
        goto cleanup;
    }

    if (libxlDomainObjBeginJobWithDriver(driver, vm, LIBXL_JOB_DESTROY) < 0)
        goto cleanup;

    if (!virDomainObjIsActive(vm)) {
        libxlError(VIR_ERR_OPERATION_INVALID,
                   "%s", _("Domain is not running"));
        goto endjob;
    }

    event = virDomainEventNewFromObj(vm,VIR_DOMAIN_EVENT_STOPPED,
                                     VIR_DOMAIN_EVENT_STOPPED_DESTROYED);

    if (libxlVmReap(driver, vm, 1, VIR_DOMAIN_SHUTOFF_DESTROYED) != 0) {
        libxlError(VIR_ERR_INTERNAL_ERROR,
                   _("Failed to destroy domain '%d'"), dom->id);
        goto endjob;
    }

    if (!vm->persistent) {
        if ( libxlDomainObjEndJob(driver, vm) > 0 ) 
            virDomainRemoveInactive(&driver->domains, vm);
        vm = NULL;
    }

    ret = 0;

endjob:
    if ( vm && libxlDomainObjEndJob(driver, vm) == 0)
        vm = NULL;

cleanup:
    if (vm)
        virDomainObjUnlock(vm);
    if (event)
        libxlDomainEventQueue(driver, event);
    libxlDriverUnlock(driver);
    return ret;
}

static int
libxlDomainDestroy(virDomainPtr dom)
{
    return libxlDomainDestroyFlags(dom, 0);
}

static char *
libxlDomainGetOSType(virDomainPtr dom)
{
    libxlDriverPrivatePtr driver = dom->conn->privateData;
    virDomainObjPtr vm;
    char *type = NULL;

    libxlDriverLock(driver);
    vm = virDomainFindByUUID(&driver->domains, dom->uuid);
    libxlDriverUnlock(driver);
    if (!vm) {
        char uuidstr[VIR_UUID_STRING_BUFLEN];
        virUUIDFormat(dom->uuid, uuidstr);
        libxlError(VIR_ERR_NO_DOMAIN,
                   _("No domain with matching uuid '%s'"), uuidstr);
        goto cleanup;
    }

    if (!(type = strdup(vm->def->os.type)))
        virReportOOMError();

cleanup:
    if (vm)
        virDomainObjUnlock(vm);
    return type;
}

static unsigned long long
libxlDomainGetMaxMemory(virDomainPtr dom)
{
    libxlDriverPrivatePtr driver = dom->conn->privateData;
    virDomainObjPtr vm;
    unsigned long long ret = 0;

    libxlDriverLock(driver);
    vm = virDomainFindByUUID(&driver->domains, dom->uuid);
    libxlDriverUnlock(driver);

    if (!vm) {
        libxlError(VIR_ERR_NO_DOMAIN, "%s", _("no domain with matching uuid"));
        goto cleanup;
    }
    ret = vm->def->mem.max_balloon;

cleanup:
    if (vm)
        virDomainObjUnlock(vm);
    return ret;
}

static int
libxlDomainSetMemoryFlags(virDomainPtr dom, unsigned long newmem,
                          unsigned int flags)
{
    libxlDriverPrivatePtr driver = dom->conn->privateData;
    libxlDomainObjPrivatePtr priv;
    virDomainObjPtr vm;
    virDomainDefPtr persistentDef = NULL;
    bool isActive;
    int ret = -1;

    virCheckFlags(VIR_DOMAIN_MEM_LIVE |
                  VIR_DOMAIN_MEM_CONFIG |
                  VIR_DOMAIN_MEM_MAXIMUM, -1);

    libxlDriverLock(driver);
    vm = virDomainFindByUUID(&driver->domains, dom->uuid);
    libxlDriverUnlock(driver);

    if (!vm) {
        libxlError(VIR_ERR_NO_DOMAIN, "%s", _("no domain with matching uuid"));
        goto cleanup;
    }

    if (libxlDomainObjBeginJob(driver, vm, LIBXL_JOB_MODIFY) < 0)
        goto cleanup;

    isActive = virDomainObjIsActive(vm);

    if (flags == VIR_DOMAIN_MEM_CURRENT) {
        if (isActive)
            flags = VIR_DOMAIN_MEM_LIVE;
        else
            flags = VIR_DOMAIN_MEM_CONFIG;
    }
    if (flags == VIR_DOMAIN_MEM_MAXIMUM) {
        if (isActive)
            flags = VIR_DOMAIN_MEM_LIVE | VIR_DOMAIN_MEM_MAXIMUM;
        else
            flags = VIR_DOMAIN_MEM_CONFIG | VIR_DOMAIN_MEM_MAXIMUM;
    }

    if (!isActive && (flags & VIR_DOMAIN_MEM_LIVE)) {
        libxlError(VIR_ERR_OPERATION_INVALID, "%s",
                   _("cannot set memory on an inactive domain"));
        goto endjob;
    }

    if (flags & VIR_DOMAIN_MEM_CONFIG) {
        if (!vm->persistent) {
            libxlError(VIR_ERR_OPERATION_INVALID, "%s",
                       _("cannot change persistent config of a transient domain"));
            goto endjob;
        }
        if (!(persistentDef = virDomainObjGetPersistentDef(driver->caps, vm)))
            goto endjob;
    }

    if (flags & VIR_DOMAIN_MEM_MAXIMUM) {
        /* resize the maximum memory */

        if (flags & VIR_DOMAIN_MEM_LIVE) {
            priv = vm->privateData;
            if (libxl_domain_setmaxmem(&priv->ctx, dom->id, newmem) < 0) {
                libxlError(VIR_ERR_INTERNAL_ERROR,
                           _("Failed to set maximum memory for domain '%d'"
                             " with libxenlight"), dom->id);
                goto endjob;
            }
        }

        if (flags & VIR_DOMAIN_MEM_CONFIG) {
            /* Help clang 2.8 decipher the logic flow.  */
            sa_assert(persistentDef);
            persistentDef->mem.max_balloon = newmem;
            if (persistentDef->mem.cur_balloon > newmem)
                persistentDef->mem.cur_balloon = newmem;
            ret = virDomainSaveConfig(driver->configDir, persistentDef);
            goto endjob;
        }

    } else {
        /* resize the current memory */

        if (newmem > vm->def->mem.max_balloon) {
            libxlError(VIR_ERR_INVALID_ARG, "%s",
                        _("cannot set memory higher than max memory"));
            goto endjob;
        }

        if (flags & VIR_DOMAIN_MEM_LIVE) {
            priv = vm->privateData;
            if (libxl_set_memory_target(&priv->ctx, dom->id, newmem, 0,
                                        /* force */ 1) < 0) {
                libxlError(VIR_ERR_INTERNAL_ERROR,
                           _("Failed to set memory for domain '%d'"
                             " with libxenlight"), dom->id);
                goto endjob;
            }
        }

        if (flags & VIR_DOMAIN_MEM_CONFIG) {
            sa_assert(persistentDef);
            persistentDef->mem.cur_balloon = newmem;
            ret = virDomainSaveConfig(driver->configDir, persistentDef);
            goto endjob;
        }
    }

    ret = 0;
endjob:
    if (libxlDomainObjEndJob(driver, vm) == 0)
        vm = NULL;

cleanup:
    if (vm)
        virDomainObjUnlock(vm);
    return ret;
}

static int
libxlDomainSetMemory(virDomainPtr dom, unsigned long memory)
{
    return libxlDomainSetMemoryFlags(dom, memory, VIR_DOMAIN_MEM_LIVE);
}

static int
libxlDomainSetMaxMemory(virDomainPtr dom, unsigned long memory)
{
    return libxlDomainSetMemoryFlags(dom, memory, VIR_DOMAIN_MEM_MAXIMUM);
}

static int
libxlDomainGetInfo(virDomainPtr dom, virDomainInfoPtr info)
{
    libxlDriverPrivatePtr driver = dom->conn->privateData;
    virDomainObjPtr vm;
    libxl_dominfo d_info;
    int ret = -1;

    libxlDriverLock(driver);
    vm = virDomainFindByUUID(&driver->domains, dom->uuid);
    libxlDriverUnlock(driver);

    if (!vm) {
        libxlError(VIR_ERR_NO_DOMAIN, "%s",
                   _("no domain with matching uuid"));
        goto cleanup;
    }

    if (!virDomainObjIsActive(vm)) {
        info->cpuTime = 0;
        info->memory = vm->def->mem.cur_balloon;
        info->maxMem = vm->def->mem.max_balloon;
    } else {
        if (libxl_domain_info(&driver->ctx, &d_info, dom->id) != 0) {
            libxlError(VIR_ERR_INTERNAL_ERROR,
                       _("libxl_domain_info failed for domain '%d'"), dom->id);
            goto cleanup;
        }
        info->cpuTime = d_info.cpu_time;
        info->memory = d_info.current_memkb;
        info->maxMem = d_info.max_memkb;
    }

    info->state = virDomainObjGetState(vm, NULL);
    info->nrVirtCpu = vm->def->vcpus;
    ret = 0;

cleanup:
    if (vm)
        virDomainObjUnlock(vm);
    return ret;
}

static int
libxlDomainGetState(virDomainPtr dom,
                    int *state,
                    int *reason,
                    unsigned int flags)
{
    libxlDriverPrivatePtr driver = dom->conn->privateData;
    virDomainObjPtr vm;
    int ret = -1;

    virCheckFlags(0, -1);

    libxlDriverLock(driver);
    vm = virDomainFindByUUID(&driver->domains, dom->uuid);
    libxlDriverUnlock(driver);

    if (!vm) {
        libxlError(VIR_ERR_NO_DOMAIN, "%s",
                   _("no domain with matching uuid"));
        goto cleanup;
    }

    *state = virDomainObjGetState(vm, reason);
    ret = 0;

  cleanup:
    if (vm)
        virDomainObjUnlock(vm);
    return ret;
}

/* This internal function expects the driver lock to already be held on
 * entry and the vm must be active. */
static int
libxlDoDomainSave(libxlDriverPrivatePtr driver, virDomainObjPtr vm,
                  const char *to)
{
    libxlDomainObjPrivatePtr priv = vm->privateData;
    libxlSavefileHeader hdr;
    virDomainEventPtr event = NULL;
    char *xml = NULL;
    uint32_t xml_len;
    int fd;
    int ret = -1;

    if (libxlDomainObjBeginAsyncJobWithDriver(driver, vm,
                                             LIBXL_ASYNC_JOB_SAVE) < 0)
        goto cleanup;


    if (virDomainObjGetState(vm, NULL) == VIR_DOMAIN_PAUSED) {
        libxlError(VIR_ERR_OPERATION_INVALID,
                   _("Domain '%d' has to be running because libxenlight will"
                     " suspend it"), vm->def->id);
        goto endjob;
    }

    if ((fd = virFileOpenAs(to, O_CREAT|O_TRUNC|O_WRONLY, S_IRUSR|S_IWUSR,
                            -1, -1, 0)) < 0) {
        virReportSystemError(-fd,
                             _("Failed to create domain save file '%s'"), to);
        goto endjob;
    }

    if ((xml = virDomainDefFormat(vm->def, 0)) == NULL)
        goto endjob;
    xml_len = strlen(xml) + 1;

    memset(&hdr, 0, sizeof(hdr));
    memcpy(hdr.magic, LIBXL_SAVE_MAGIC, sizeof(hdr.magic));
    hdr.version = LIBXL_SAVE_VERSION;
    hdr.xmlLen = xml_len;

    if (safewrite(fd, &hdr, sizeof(hdr)) != sizeof(hdr)) {
        libxlError(VIR_ERR_OPERATION_FAILED,
                    _("Failed to write save file header"));
        goto endjob;
    }

    if (safewrite(fd, xml, xml_len) != xml_len) {
        libxlError(VIR_ERR_OPERATION_FAILED,
                    _("Failed to write xml description"));
        goto endjob;
    }

#if 0
    libxlDriverUnlock(driver);
    ret = libxl_domain_suspend(&priv->ctx, NULL, vm->def->id, fd);
    virDomainObjUnlock(vm);
    libxlDriverLock(driver);
    virDomainObjLock(vm);
#else
    virDomainObjUnlock(vm);
    libxlDriverUnlock(driver);
    ret = libxl_domain_suspend(&priv->ctx, NULL, vm->def->id, fd);
    libxlDriverLock(driver);
    virDomainObjLock(vm);
#endif
 
    if (ret != 0) {
        libxlError(VIR_ERR_INTERNAL_ERROR,
                    _("Failed to save domain '%d' with libxenlight"),
                    vm->def->id);
        goto endjob;
    }

    event = virDomainEventNewFromObj(vm, VIR_DOMAIN_EVENT_STOPPED,
                                         VIR_DOMAIN_EVENT_STOPPED_SAVED);

    if (libxlVmReap(driver, vm, 1, VIR_DOMAIN_SHUTOFF_SAVED) != 0) {
        libxlError(VIR_ERR_INTERNAL_ERROR,
                    _("Failed to destroy domain '%d'"), vm->def->id);
        goto endjob;
    }

    if (!vm->persistent) {
        if (libxlDomainObjEndAsyncJob(driver, vm) > 0)
            virDomainRemoveInactive(&driver->domains, vm);
        vm = NULL;
    }

    ret = 0;

endjob:
    if ( vm && libxlDomainObjEndAsyncJob(driver, vm) == 0)
        vm = NULL;
cleanup:
    VIR_FREE(xml);
    if (VIR_CLOSE(fd) < 0)
        virReportSystemError(errno, "%s", _("cannot close file"));
    if (event)
        libxlDomainEventQueue(driver, event);
    return ret;
}

static int
libxlDomainSaveFlags(virDomainPtr dom, const char *to, const char *dxml,
                     unsigned int flags)
{
    libxlDriverPrivatePtr driver = dom->conn->privateData;
    virDomainObjPtr vm;
    int ret = -1;

    virCheckFlags(0, -1);
    if (dxml) {
        libxlError(VIR_ERR_ARGUMENT_UNSUPPORTED, "%s",
                   _("xml modification unsupported"));
        return -1;
    }

    libxlDriverLock(driver);
    vm = virDomainFindByUUID(&driver->domains, dom->uuid);

    if (!vm) {
        char uuidstr[VIR_UUID_STRING_BUFLEN];
        virUUIDFormat(dom->uuid, uuidstr);
        libxlError(VIR_ERR_NO_DOMAIN,
                   _("No domain with matching uuid '%s'"), uuidstr);
        goto cleanup;
    }

    if (!virDomainObjIsActive(vm)) {
        libxlError(VIR_ERR_OPERATION_INVALID, "%s", _("Domain is not running"));
        goto cleanup;
    }

    ret = libxlDoDomainSave(driver, vm, to);

cleanup:
    if (vm)
        virDomainObjUnlock(vm);
    libxlDriverUnlock(driver);
    return ret;
}

static int
libxlDomainSave(virDomainPtr dom, const char *to)
{
    return libxlDomainSaveFlags(dom, to, NULL, 0);
}

static int
libxlDomainRestoreFlags(virConnectPtr conn, const char *from,
                        const char *dxml, unsigned int flags)
{
    libxlDriverPrivatePtr driver = conn->privateData;
    virDomainObjPtr vm = NULL;
    virDomainDefPtr def = NULL;
    libxlSavefileHeader hdr;
    int fd = -1;
    int ret = -1;

    virCheckFlags(0, -1);
    if (dxml) {
        libxlError(VIR_ERR_ARGUMENT_UNSUPPORTED, "%s",
                   _("xml modification unsupported"));
        return -1;
    }

    libxlDriverLock(driver);

    fd = libxlSaveImageOpen(driver, from, &def, &hdr);
    if (fd < 0)
        goto cleanup;

    if (virDomainObjIsDuplicate(&driver->domains, def, 1) < 0)
        goto cleanup;

    if (!(vm = virDomainAssignDef(driver->caps, &driver->domains, def, true)))
        goto cleanup;

    def = NULL;

    if (libxlDomainObjBeginAsyncJobWithDriver(driver, vm, LIBXL_ASYNC_JOB_RESTORE) < 0)
        goto cleanup;

    if ((ret = libxlVmStart(driver, vm, false, fd, false)) < 0 &&
        !vm->persistent) {
        if (libxlDomainObjEndAsyncJob(driver, vm) > 0) 
            virDomainRemoveInactive(&driver->domains, vm);
        vm = NULL;
    }

    if (vm && libxlDomainObjEndAsyncJob(driver, vm) == 0)
        vm = NULL;
cleanup:
    if (VIR_CLOSE(fd) < 0)
        virReportSystemError(errno, "%s", _("cannot close file"));
    virDomainDefFree(def);
    if (vm)
        virDomainObjUnlock(vm);
    libxlDriverUnlock(driver);
    return ret;
}

static int
libxlDomainRestore(virConnectPtr conn, const char *from)
{
    return libxlDomainRestoreFlags(conn, from, NULL, 0);
}

static int
libxlDomainCoreDump(virDomainPtr dom, const char *to, unsigned int flags)
{
    libxlDriverPrivatePtr driver = dom->conn->privateData;
    libxlDomainObjPrivatePtr priv;
    virDomainObjPtr vm;
    virDomainEventPtr event = NULL;
    bool paused = false;
    int ret = -1;

    virCheckFlags(VIR_DUMP_LIVE | VIR_DUMP_CRASH, -1);

    libxlDriverLock(driver);
    vm = virDomainFindByUUID(&driver->domains, dom->uuid);
    libxlDriverUnlock(driver);

    if (!vm) {
        char uuidstr[VIR_UUID_STRING_BUFLEN];
        virUUIDFormat(dom->uuid, uuidstr);
        libxlError(VIR_ERR_NO_DOMAIN,
                   _("No domain with matching uuid '%s'"), uuidstr);
        goto cleanup;
    }

    if (libxlDomainObjBeginAsyncJobWithDriver(driver, vm,
                                             LIBXL_ASYNC_JOB_DUMP) < 0)
        goto cleanup;

    if (!virDomainObjIsActive(vm)) {
        libxlError(VIR_ERR_OPERATION_INVALID, "%s", _("Domain is not running"));
        goto endjob;
    }

    priv = vm->privateData;

    if (!(flags & VIR_DUMP_LIVE) &&
        virDomainObjGetState(vm, NULL) == VIR_DOMAIN_RUNNING) {
        if (libxl_domain_pause(&priv->ctx, dom->id) != 0) {
            libxlError(VIR_ERR_INTERNAL_ERROR,
                       _("Before dumping core, failed to suspend domain '%d'"
                         " with libxenlight"),
                       dom->id);
            goto endjob;
        }
        virDomainObjSetState(vm, VIR_DOMAIN_PAUSED, VIR_DOMAIN_PAUSED_DUMP);
        paused = true;
    }

    if (libxl_domain_core_dump(&priv->ctx, dom->id, to) != 0) {
        libxlError(VIR_ERR_INTERNAL_ERROR,
                   _("Failed to dump core of domain '%d' with libxenlight"),
                   dom->id);
        goto endjob_unpause;
    }

    libxlDriverLock(driver);
    if (flags & VIR_DUMP_CRASH) {
        if (libxlVmReap(driver, vm, 1, VIR_DOMAIN_SHUTOFF_CRASHED) != 0) {
            libxlError(VIR_ERR_INTERNAL_ERROR,
                       _("Failed to destroy domain '%d'"), dom->id);
            goto endjob_unlock;
        }

        event = virDomainEventNewFromObj(vm, VIR_DOMAIN_EVENT_STOPPED,
                                         VIR_DOMAIN_EVENT_STOPPED_CRASHED);
    }

    if ((flags & VIR_DUMP_CRASH) && !vm->persistent) {
        if (libxlDomainObjEndAsyncJob(driver, vm) > 0)
            virDomainRemoveInactive(&driver->domains, vm);
        vm = NULL;
    }

    ret = 0;

endjob_unlock:
    libxlDriverUnlock(driver);
endjob_unpause:
    if (virDomainObjIsActive(vm) && paused) {
        if (libxl_domain_unpause(&priv->ctx, dom->id) != 0) {
            libxlError(VIR_ERR_INTERNAL_ERROR,
                       _("After dumping core, failed to resume domain '%d' with"
                         " libxenlight"), dom->id);
        } else {
            virDomainObjSetState(vm, VIR_DOMAIN_RUNNING,
                                 VIR_DOMAIN_RUNNING_UNPAUSED);
        }
    }
endjob:
    if (vm && libxlDomainObjEndAsyncJob(driver, vm) == 0)
        vm = NULL;
cleanup:
    if (vm)
        virDomainObjUnlock(vm);
    if (event) {
        libxlDriverLock(driver);
        libxlDomainEventQueue(driver, event);
        libxlDriverUnlock(driver);
    }
    return ret;
}

static int
libxlDomainManagedSave(virDomainPtr dom, unsigned int flags)
{
    libxlDriverPrivatePtr driver = dom->conn->privateData;
    virDomainObjPtr vm = NULL;
    char *name = NULL;
    int ret = -1;

    virCheckFlags(0, -1);

    libxlDriverLock(driver);
    vm = virDomainFindByUUID(&driver->domains, dom->uuid);
    if (!vm) {
        char uuidstr[VIR_UUID_STRING_BUFLEN];
        virUUIDFormat(dom->uuid, uuidstr);
        libxlError(VIR_ERR_NO_DOMAIN,
                   _("No domain with matching uuid '%s'"), uuidstr);
        goto cleanup;
    }

    if (!virDomainObjIsActive(vm)) {
        libxlError(VIR_ERR_OPERATION_INVALID, "%s", _("Domain is not running"));
        goto cleanup;
    }
    if (!vm->persistent) {
        libxlError(VIR_ERR_OPERATION_INVALID, "%s",
                   _("cannot do managed save for transient domain"));
        goto cleanup;
    }

    name = libxlDomainManagedSavePath(driver, vm);
    if (name == NULL)
        goto cleanup;

    VIR_INFO("Saving state to %s", name);

    ret = libxlDoDomainSave(driver, vm, name);

cleanup:
    if (vm)
        virDomainObjUnlock(vm);
    libxlDriverUnlock(driver);
    VIR_FREE(name);
    return ret;
}

static int
libxlDomainHasManagedSaveImage(virDomainPtr dom, unsigned int flags)
{
    libxlDriverPrivatePtr driver = dom->conn->privateData;
    virDomainObjPtr vm = NULL;
    int ret = -1;
    char *name = NULL;

    virCheckFlags(0, -1);

    libxlDriverLock(driver);
    vm = virDomainFindByUUID(&driver->domains, dom->uuid);
    if (!vm) {
        char uuidstr[VIR_UUID_STRING_BUFLEN];
        virUUIDFormat(dom->uuid, uuidstr);
        libxlError(VIR_ERR_NO_DOMAIN,
                   _("No domain with matching uuid '%s'"), uuidstr);
        goto cleanup;
    }

    name = libxlDomainManagedSavePath(driver, vm);
    if (name == NULL)
        goto cleanup;

    ret = virFileExists(name);

cleanup:
    VIR_FREE(name);
    if (vm)
        virDomainObjUnlock(vm);
    libxlDriverUnlock(driver);
    return ret;
}

static int
libxlDomainManagedSaveRemove(virDomainPtr dom, unsigned int flags)
{
    libxlDriverPrivatePtr driver = dom->conn->privateData;
    virDomainObjPtr vm = NULL;
    int ret = -1;
    char *name = NULL;

    virCheckFlags(0, -1);

    libxlDriverLock(driver);
    vm = virDomainFindByUUID(&driver->domains, dom->uuid);
    if (!vm) {
        char uuidstr[VIR_UUID_STRING_BUFLEN];
        virUUIDFormat(dom->uuid, uuidstr);
        libxlError(VIR_ERR_NO_DOMAIN,
                   _("No domain with matching uuid '%s'"), uuidstr);
        goto cleanup;
    }

    name = libxlDomainManagedSavePath(driver, vm);
    if (name == NULL)
        goto cleanup;

    ret = unlink(name);

cleanup:
    VIR_FREE(name);
    if (vm)
        virDomainObjUnlock(vm);
    libxlDriverUnlock(driver);
    return ret;
}

static int
libxlDomainSetVcpusFlags(virDomainPtr dom, unsigned int nvcpus,
                         unsigned int flags)
{
    libxlDriverPrivatePtr driver = dom->conn->privateData;
    libxlDomainObjPrivatePtr priv;
    virDomainDefPtr def;
    virDomainObjPtr vm;
    libxl_cpumap map;
    uint8_t *bitmask = NULL;
    unsigned int maplen;
    unsigned int i, pos;
    int max;
    int ret = -1;

    virCheckFlags(VIR_DOMAIN_VCPU_LIVE |
                  VIR_DOMAIN_VCPU_CONFIG |
                  VIR_DOMAIN_VCPU_MAXIMUM, -1);

    /* At least one of LIVE or CONFIG must be set.  MAXIMUM cannot be
     * mixed with LIVE.  */
    if ((flags & (VIR_DOMAIN_VCPU_LIVE | VIR_DOMAIN_VCPU_CONFIG)) == 0 ||
        (flags & (VIR_DOMAIN_VCPU_MAXIMUM | VIR_DOMAIN_VCPU_LIVE)) ==
         (VIR_DOMAIN_VCPU_MAXIMUM | VIR_DOMAIN_VCPU_LIVE)) {
        libxlError(VIR_ERR_INVALID_ARG,
                   _("invalid flag combination: (0x%x)"), flags);
        return -1;
    }

    if (!nvcpus) {
        libxlError(VIR_ERR_INVALID_ARG, _("nvcpus is zero"));
        return -1;
    }

    libxlDriverLock(driver);
    vm = virDomainFindByUUID(&driver->domains, dom->uuid);
    libxlDriverUnlock(driver);

    if (!vm) {
        libxlError(VIR_ERR_NO_DOMAIN, "%s", _("no domain with matching uuid"));
        goto cleanup;
    }

    if (libxlDomainObjBeginJob(driver, vm, LIBXL_JOB_MODIFY) < 0)
        goto cleanup;

    if (!virDomainObjIsActive(vm) && (flags & VIR_DOMAIN_VCPU_LIVE)) {
        libxlError(VIR_ERR_OPERATION_INVALID, "%s",
                   _("cannot set vcpus on an inactive domain"));
        goto endjob;
    }

    if (!vm->persistent && (flags & VIR_DOMAIN_VCPU_CONFIG)) {
        libxlError(VIR_ERR_OPERATION_INVALID, "%s",
                   _("cannot change persistent config of a transient domain"));
        goto endjob;
    }

    if ((max = libxlGetMaxVcpus(dom->conn, NULL)) < 0) {
        libxlError(VIR_ERR_INTERNAL_ERROR, "%s",
                   _("could not determine max vcpus for the domain"));
        goto endjob;
    }

    if (!(flags & VIR_DOMAIN_VCPU_MAXIMUM) && vm->def->maxvcpus < max) {
        max = vm->def->maxvcpus;
    }

    if (nvcpus > max) {
        libxlError(VIR_ERR_INVALID_ARG,
                   _("requested vcpus is greater than max allowable"
                     " vcpus for the domain: %d > %d"), nvcpus, max);
        goto endjob;
    }

    priv = vm->privateData;

    if (!(def = virDomainObjGetPersistentDef(driver->caps, vm)))
        goto endjob;

    maplen = VIR_CPU_MAPLEN(nvcpus);
    if (VIR_ALLOC_N(bitmask, maplen) < 0) {
        virReportOOMError();
        goto endjob;
    }

    for (i = 0; i < nvcpus; ++i) {
        pos = i / 8;
        bitmask[pos] |= 1 << (i % 8);
    }

    map.size = maplen;
    map.map = bitmask;

    switch (flags) {
    case VIR_DOMAIN_VCPU_MAXIMUM | VIR_DOMAIN_VCPU_CONFIG:
        def->maxvcpus = nvcpus;
        if (nvcpus < def->vcpus)
            def->vcpus = nvcpus;
        break;

    case VIR_DOMAIN_VCPU_CONFIG:
        def->vcpus = nvcpus;
        break;

    case VIR_DOMAIN_VCPU_LIVE:
        if (libxl_set_vcpuonline(&priv->ctx, dom->id, &map) != 0) {
            libxlError(VIR_ERR_INTERNAL_ERROR,
                       _("Failed to set vcpus for domain '%d'"
                         " with libxenlight"), dom->id);
            goto endjob;
        }
        break;

    case VIR_DOMAIN_VCPU_LIVE | VIR_DOMAIN_VCPU_CONFIG:
        if (libxl_set_vcpuonline(&priv->ctx, dom->id, &map) != 0) {
            libxlError(VIR_ERR_INTERNAL_ERROR,
                       _("Failed to set vcpus for domain '%d'"
                         " with libxenlight"), dom->id);
            goto endjob;
        }
        def->vcpus = nvcpus;
        break;
    }

    ret = 0;

    if (flags & VIR_DOMAIN_VCPU_CONFIG)
        ret = virDomainSaveConfig(driver->configDir, def);

endjob:
    if (libxlDomainObjEndJob(driver, vm) == 0)
        vm = NULL;
cleanup:
    VIR_FREE(bitmask);
     if (vm)
        virDomainObjUnlock(vm);
    return ret;
}

static int
libxlDomainSetVcpus(virDomainPtr dom, unsigned int nvcpus)
{
    return libxlDomainSetVcpusFlags(dom, nvcpus, VIR_DOMAIN_VCPU_LIVE);
}

static int
libxlDomainGetVcpusFlags(virDomainPtr dom, unsigned int flags)
{
    libxlDriverPrivatePtr driver = dom->conn->privateData;
    virDomainObjPtr vm;
    virDomainDefPtr def;
    int ret = -1;
    bool active;

    virCheckFlags(VIR_DOMAIN_VCPU_LIVE |
                  VIR_DOMAIN_VCPU_CONFIG |
                  VIR_DOMAIN_VCPU_MAXIMUM, -1);

    libxlDriverLock(driver);
    vm = virDomainFindByUUID(&driver->domains, dom->uuid);
    libxlDriverUnlock(driver);

    if (!vm) {
        libxlError(VIR_ERR_NO_DOMAIN, "%s", _("no domain with matching uuid"));
        goto cleanup;
    }

    active = virDomainObjIsActive(vm);

    if ((flags & (VIR_DOMAIN_VCPU_LIVE | VIR_DOMAIN_VCPU_CONFIG)) == 0) {
        if (active)
            flags |= VIR_DOMAIN_VCPU_LIVE;
        else
            flags |= VIR_DOMAIN_VCPU_CONFIG;
    }
    if ((flags & VIR_DOMAIN_VCPU_LIVE) && (flags & VIR_DOMAIN_VCPU_CONFIG)) {
        libxlError(VIR_ERR_INVALID_ARG,
                   _("invalid flag combination: (0x%x)"), flags);
        return -1;
    }

    if (flags & VIR_DOMAIN_VCPU_LIVE) {
        if (!active) {
            libxlError(VIR_ERR_OPERATION_INVALID,
                       "%s", _("Domain is not running"));
            goto cleanup;
        }
        def = vm->def;
    } else {
        if (!vm->persistent) {
            libxlError(VIR_ERR_OPERATION_INVALID,
                       "%s", _("domain is transient"));
            goto cleanup;
        }
        def = vm->newDef ? vm->newDef : vm->def;
    }

    ret = (flags & VIR_DOMAIN_VCPU_MAXIMUM) ? def->maxvcpus : def->vcpus;

cleanup:
    if (vm)
        virDomainObjUnlock(vm);
    return ret;
}

static int
libxlDomainPinVcpu(virDomainPtr dom, unsigned int vcpu, unsigned char *cpumap,
                   int maplen)
{
    libxlDriverPrivatePtr driver = dom->conn->privateData;
    libxlDomainObjPrivatePtr priv;
    virDomainObjPtr vm;
    int ret = -1;
    libxl_cpumap map;

    libxlDriverLock(driver);
    vm = virDomainFindByUUID(&driver->domains, dom->uuid);
    libxlDriverUnlock(driver);

    if (!vm) {
        libxlError(VIR_ERR_NO_DOMAIN, "%s", _("no domain with matching uuid"));
        goto cleanup;
    }

    if (!virDomainObjIsActive(vm)) {
        libxlError(VIR_ERR_OPERATION_INVALID, "%s",
                   _("cannot pin vcpus on an inactive domain"));
        goto cleanup;
    }

    priv = vm->privateData;

    map.size = maplen;
    map.map = cpumap;
    if (libxl_set_vcpuaffinity(&priv->ctx, dom->id, vcpu, &map) != 0) {
        libxlError(VIR_ERR_INTERNAL_ERROR,
                   _("Failed to pin vcpu '%d' with libxenlight"), vcpu);
        goto cleanup;
    }

    if (virDomainVcpuPinAdd(vm->def, cpumap, maplen, vcpu) < 0) {
        libxlError(VIR_ERR_INTERNAL_ERROR,
                   "%s", _("failed to update or add vcpupin xml"));
        goto cleanup;
    }

    if (virDomainSaveStatus(driver->caps, driver->stateDir, vm) < 0)
        goto cleanup;

    ret = 0;

cleanup:
    if (vm)
        virDomainObjUnlock(vm);
    return ret;
}


static int
libxlDomainGetVcpus(virDomainPtr dom, virVcpuInfoPtr info, int maxinfo,
                    unsigned char *cpumaps, int maplen)
{
    libxlDriverPrivatePtr driver = dom->conn->privateData;
    libxlDomainObjPrivatePtr priv;
    virDomainObjPtr vm;
    int ret = -1;
    libxl_vcpuinfo *vcpuinfo;
    int maxcpu, hostcpus;
    unsigned int i;
    unsigned char *cpumap;

    libxlDriverLock(driver);
    vm = virDomainFindByUUID(&driver->domains, dom->uuid);
    libxlDriverUnlock(driver);

    if (!vm) {
        libxlError(VIR_ERR_NO_DOMAIN, "%s", _("no domain with matching uuid"));
        goto cleanup;
    }

    if (!virDomainObjIsActive(vm)) {
        libxlError(VIR_ERR_OPERATION_INVALID, "%s", _("Domain is not running"));
        goto cleanup;
    }

    priv = vm->privateData;
    if ((vcpuinfo = libxl_list_vcpu(&priv->ctx, dom->id, &maxcpu,
                                    &hostcpus)) == NULL) {
        libxlError(VIR_ERR_INTERNAL_ERROR,
                   _("Failed to list vcpus for domain '%d' with libxenlight"),
                   dom->id);
        goto cleanup;
    }

    if (cpumaps && maplen > 0)
        memset(cpumaps, 0, maplen * maxinfo);
    for (i = 0; i < maxcpu && i < maxinfo; ++i) {
        info[i].number = vcpuinfo[i].vcpuid;
        info[i].cpu = vcpuinfo[i].cpu;
        info[i].cpuTime = vcpuinfo[i].vcpu_time;
        if (vcpuinfo[i].running)
            info[i].state = VIR_VCPU_RUNNING;
        else if (vcpuinfo[i].blocked)
            info[i].state = VIR_VCPU_BLOCKED;
        else
            info[i].state = VIR_VCPU_OFFLINE;

        if (cpumaps && maplen > 0) {
            cpumap = VIR_GET_CPUMAP(cpumaps, maplen, i);
            memcpy(cpumap, vcpuinfo[i].cpumap.map,
                   MIN(maplen, vcpuinfo[i].cpumap.size));
        }

        libxl_vcpuinfo_destroy(&vcpuinfo[i]);
    }
    VIR_FREE(vcpuinfo);

    ret = maxinfo;

cleanup:
    if (vm)
        virDomainObjUnlock(vm);
    return ret;
}

static char *
libxlDomainGetXMLDesc(virDomainPtr dom, unsigned int flags)
{
    libxlDriverPrivatePtr driver = dom->conn->privateData;
    virDomainObjPtr vm;
    char *ret = NULL;

    /* Flags checked by virDomainDefFormat */

    libxlDriverLock(driver);
    vm = virDomainFindByUUID(&driver->domains, dom->uuid);
    libxlDriverUnlock(driver);

    if (!vm) {
        libxlError(VIR_ERR_NO_DOMAIN, "%s",
                   _("no domain with matching uuid"));
        goto cleanup;
    }

    ret = virDomainDefFormat(vm->def, flags);

  cleanup:
    if (vm)
        virDomainObjUnlock(vm);
    return ret;
}

static char *
libxlDomainXMLFromNative(virConnectPtr conn, const char * nativeFormat,
                         const char * nativeConfig,
                         unsigned int flags)
{
    libxlDriverPrivatePtr driver = conn->privateData;
    const libxl_version_info *ver_info;
    virDomainDefPtr def = NULL;
    virConfPtr conf = NULL;
    char *xml = NULL;

    virCheckFlags(0, NULL);

    if (STRNEQ(nativeFormat, LIBXL_CONFIG_FORMAT_XM)) {
        libxlError(VIR_ERR_INVALID_ARG,
                   _("unsupported config type %s"), nativeFormat);
        goto cleanup;
    }

    if ((ver_info = libxl_get_version_info(&driver->ctx)) == NULL) {
        VIR_ERROR(_("cannot get version information from libxenlight"));
        goto cleanup;
    }

    if (!(conf = virConfReadMem(nativeConfig, strlen(nativeConfig), 0)))
        goto cleanup;

    if (!(def = xenParseXM(conf, ver_info->xen_version_major, driver->caps))) {
        libxlError(VIR_ERR_INTERNAL_ERROR, "%s", _("parsing xm config failed"));
        goto cleanup;
    }

    xml = virDomainDefFormat(def, VIR_DOMAIN_XML_INACTIVE);

cleanup:
    virDomainDefFree(def);
    if (conf)
        virConfFree(conf);
    return xml;
}

#define MAX_CONFIG_SIZE (1024 * 65)
static char *
libxlDomainXMLToNative(virConnectPtr conn, const char * nativeFormat,
                       const char * domainXml,
                       unsigned int flags)
{
    libxlDriverPrivatePtr driver = conn->privateData;
    const libxl_version_info *ver_info;
    virDomainDefPtr def = NULL;
    virConfPtr conf = NULL;
    int len = MAX_CONFIG_SIZE;
    char *ret = NULL;

    virCheckFlags(0, NULL);

    if (STRNEQ(nativeFormat, LIBXL_CONFIG_FORMAT_XM)) {
        libxlError(VIR_ERR_INVALID_ARG,
                   _("unsupported config type %s"), nativeFormat);
        goto cleanup;
    }

    if ((ver_info = libxl_get_version_info(&driver->ctx)) == NULL) {
        VIR_ERROR(_("cannot get version information from libxenlight"));
        goto cleanup;
    }

    if (!(def = virDomainDefParseString(driver->caps, domainXml,
                                        1 << VIR_DOMAIN_VIRT_XEN, 0)))
        goto cleanup;

    if (!(conf = xenFormatXM(conn, def, ver_info->xen_version_major)))
        goto cleanup;

    if (VIR_ALLOC_N(ret, len) < 0) {
        virReportOOMError();
        goto cleanup;
    }

    if (virConfWriteMem(ret, &len, conf) < 0) {
        VIR_FREE(ret);
        goto cleanup;
    }

cleanup:
    virDomainDefFree(def);
    if (conf)
        virConfFree(conf);
    return ret;
}

static int
libxlListDefinedDomains(virConnectPtr conn,
                        char **const names, int nnames)
{
    libxlDriverPrivatePtr driver = conn->privateData;
    int n;

    libxlDriverLock(driver);
    n = virDomainObjListGetInactiveNames(&driver->domains, names, nnames);
    libxlDriverUnlock(driver);
    return n;
}

static int
libxlNumDefinedDomains(virConnectPtr conn)
{
    libxlDriverPrivatePtr driver = conn->privateData;
    int n;

    libxlDriverLock(driver);
    n = virDomainObjListNumOfDomains(&driver->domains, 0);
    libxlDriverUnlock(driver);

    return n;
}

static int
libxlDomainCreateWithFlags(virDomainPtr dom,
                           unsigned int flags)
{
    libxlDriverPrivatePtr driver = dom->conn->privateData;
    virDomainObjPtr vm;
    int ret = -1;

    virCheckFlags(VIR_DOMAIN_START_PAUSED, -1);

    libxlDriverLock(driver);
    vm = virDomainFindByUUID(&driver->domains, dom->uuid);
    if (!vm) {
        char uuidstr[VIR_UUID_STRING_BUFLEN];
        virUUIDFormat(dom->uuid, uuidstr);
        libxlError(VIR_ERR_NO_DOMAIN,
                   _("No domain with matching uuid '%s'"), uuidstr);
        goto cleanup;
    }

    if (libxlDomainObjBeginJobWithDriver(driver, vm, LIBXL_JOB_MODIFY) < 0)
        goto cleanup;

    if (virDomainObjIsActive(vm)) {
        libxlError(VIR_ERR_OPERATION_INVALID,
                   "%s", _("Domain is already running"));
        goto endjob;
    }

    ret = libxlVmStart(driver, vm, (flags & VIR_DOMAIN_START_PAUSED) != 0, -1, false);

endjob:
    if (libxlDomainObjEndJob(driver, vm) == 0)
        vm = NULL;

cleanup:
    if (vm)
        virDomainObjUnlock(vm);
    libxlDriverUnlock(driver);
    return ret;
}

static int
libxlDomainCreate(virDomainPtr dom)
{
    return libxlDomainCreateWithFlags(dom, 0);
}

static virDomainPtr
libxlDomainDefineXML(virConnectPtr conn, const char *xml)
{
    libxlDriverPrivatePtr driver = conn->privateData;
    virDomainDefPtr def = NULL;
    virDomainObjPtr vm = NULL;
    virDomainPtr dom = NULL;
    virDomainEventPtr event = NULL;
    int dupVM;

    libxlDriverLock(driver);
    if (!(def = virDomainDefParseString(driver->caps, xml,
                                        1 << VIR_DOMAIN_VIRT_XEN,
                                        VIR_DOMAIN_XML_INACTIVE)))
        goto cleanup;

   if ((dupVM = virDomainObjIsDuplicate(&driver->domains, def, 0)) < 0)
        goto cleanup;

    if (!(vm = virDomainAssignDef(driver->caps,
                                  &driver->domains, def, false)))
        goto cleanup;
    def = NULL;
    vm->persistent = 1;

    if (virDomainSaveConfig(driver->configDir,
                            vm->newDef ? vm->newDef : vm->def) < 0) {
        virDomainRemoveInactive(&driver->domains, vm);
        vm = NULL;
        goto cleanup;
    }

    dom = virGetDomain(conn, vm->def->name, vm->def->uuid);
    if (dom)
        dom->id = vm->def->id;

    event = virDomainEventNewFromObj(vm, VIR_DOMAIN_EVENT_DEFINED,
                                     !dupVM ?
                                     VIR_DOMAIN_EVENT_DEFINED_ADDED :
                                     VIR_DOMAIN_EVENT_DEFINED_UPDATED);

cleanup:
    virDomainDefFree(def);
    if (vm)
        virDomainObjUnlock(vm);
    if (event)
        libxlDomainEventQueue(driver, event);
    libxlDriverUnlock(driver);
    return dom;
}

static int
libxlDomainUndefineFlags(virDomainPtr dom,
                         unsigned int flags)
{
    libxlDriverPrivatePtr driver = dom->conn->privateData;
    virDomainObjPtr vm;
    virDomainEventPtr event = NULL;
    char *name = NULL;
    int ret = -1;

    virCheckFlags(VIR_DOMAIN_UNDEFINE_MANAGED_SAVE, -1);

    libxlDriverLock(driver);
    vm = virDomainFindByUUID(&driver->domains, dom->uuid);

    if (!vm) {
        char uuidstr[VIR_UUID_STRING_BUFLEN];

        virUUIDFormat(dom->uuid, uuidstr);
        libxlError(VIR_ERR_NO_DOMAIN,
                   _("no domain with matching uuid '%s'"), uuidstr);
        goto cleanup;
    }

    if (!vm->persistent) {
        libxlError(VIR_ERR_OPERATION_INVALID,
                   "%s", _("cannot undefine transient domain"));
        goto cleanup;
    }

    name = libxlDomainManagedSavePath(driver, vm);
    if (name == NULL)
        goto cleanup;

    if (virFileExists(name)) {
        if (flags & VIR_DOMAIN_UNDEFINE_MANAGED_SAVE) {
            if (unlink(name) < 0) {
                libxlError(VIR_ERR_INTERNAL_ERROR,
                           _("Failed to remove domain managed save image"));
                goto cleanup;
            }
        } else {
            libxlError(VIR_ERR_OPERATION_INVALID, "%s",
                       _("Refusing to undefine while domain managed "
                         "save image exists"));
            goto cleanup;
        }
    }

    if (virDomainDeleteConfig(driver->configDir,
                              driver->autostartDir,
                              vm) < 0)
        goto cleanup;

    event = virDomainEventNewFromObj(vm, VIR_DOMAIN_EVENT_UNDEFINED,
                                     VIR_DOMAIN_EVENT_UNDEFINED_REMOVED);

    if (virDomainObjIsActive(vm)) {
        vm->persistent = 0;
    } else {
        virDomainRemoveInactive(&driver->domains, vm);
        vm = NULL;
    }

    ret = 0;

  cleanup:
    VIR_FREE(name);
    if (vm)
        virDomainObjUnlock(vm);
    if (event)
        libxlDomainEventQueue(driver, event);
    libxlDriverUnlock(driver);
    return ret;
}

static int
libxlDomainUndefine(virDomainPtr dom)
{
    return libxlDomainUndefineFlags(dom, 0);
}

static int
libxlDomainChangeEjectableMedia(libxlDomainObjPrivatePtr priv,
                                virDomainObjPtr vm, virDomainDiskDefPtr disk)
{
    virDomainDiskDefPtr origdisk = NULL;
    libxl_device_disk x_disk;
    int i;
    int ret = -1;

    for (i = 0 ; i < vm->def->ndisks ; i++) {
        if (vm->def->disks[i]->bus == disk->bus &&
            STREQ(vm->def->disks[i]->dst, disk->dst)) {
            origdisk = vm->def->disks[i];
            break;
        }
    }

    if (!origdisk) {
        libxlError(VIR_ERR_INTERNAL_ERROR,
                   _("No device with bus '%s' and target '%s'"),
                   virDomainDiskBusTypeToString(disk->bus), disk->dst);
        goto cleanup;
    }

    if (origdisk->device != VIR_DOMAIN_DISK_DEVICE_CDROM) {
        libxlError(VIR_ERR_INTERNAL_ERROR,
                   _("Removable media not supported for %s device"),
                   virDomainDiskDeviceTypeToString(disk->device));
        return -1;
    }

    if (libxlMakeDisk(vm->def, disk, &x_disk) < 0)
        goto cleanup;

    if ((ret = libxl_cdrom_insert(&priv->ctx, vm->def->id, &x_disk)) < 0) {
        libxlError(VIR_ERR_INTERNAL_ERROR,
                   _("libxenlight failed to change media for disk '%s'"),
                   disk->dst);
        goto cleanup;
    }

    VIR_FREE(origdisk->src);
    origdisk->src = disk->src;
    disk->src = NULL;
    origdisk->type = disk->type;


    virDomainDiskDefFree(disk);

    ret = 0;

cleanup:
    return ret;
}

static int
libxlDomainAttachDeviceDiskLive(libxlDomainObjPrivatePtr priv,
                                virDomainObjPtr vm, virDomainDeviceDefPtr dev)
{
    virDomainDiskDefPtr l_disk = dev->data.disk;
    libxl_device_disk x_disk;
    int ret = -1;

    switch (l_disk->device)  {
        case VIR_DOMAIN_DISK_DEVICE_CDROM:
            ret = libxlDomainChangeEjectableMedia(priv, vm, l_disk);
            break;
        case VIR_DOMAIN_DISK_DEVICE_DISK:
            if (l_disk->bus == VIR_DOMAIN_DISK_BUS_XEN) {
                if (virDomainDiskIndexByName(vm->def, l_disk->dst, true) >= 0) {
                    libxlError(VIR_ERR_OPERATION_FAILED,
                            _("target %s already exists"), l_disk->dst);
                    goto cleanup;
                }

                if (!l_disk->src) {
                    libxlError(VIR_ERR_INTERNAL_ERROR,
                            "%s", _("disk source path is missing"));
                    goto cleanup;
                }

                if (VIR_REALLOC_N(vm->def->disks, vm->def->ndisks+1) < 0) {
                    virReportOOMError();
                    goto cleanup;
                }

                if (libxlMakeDisk(vm->def, l_disk, &x_disk) < 0)
                    goto cleanup;

                if ((ret = libxl_device_disk_add(&priv->ctx, vm->def->id,
                                                &x_disk)) < 0) {
                    libxlError(VIR_ERR_INTERNAL_ERROR,
                            _("libxenlight failed to attach disk '%s'"),
                            l_disk->dst);
                    goto cleanup;
                }

                virDomainDiskInsertPreAlloced(vm->def, l_disk);

            } else {
                libxlError(VIR_ERR_CONFIG_UNSUPPORTED,
                        _("disk bus '%s' cannot be hotplugged."),
                        virDomainDiskBusTypeToString(l_disk->bus));
            }
            break;
        default:
            libxlError(VIR_ERR_CONFIG_UNSUPPORTED,
                    _("disk device type '%s' cannot be hotplugged"),
                    virDomainDiskDeviceTypeToString(l_disk->device));
            break;
    }

cleanup:
    return ret;
}

static int
libxlDomainDetachDeviceDiskLive(libxlDomainObjPrivatePtr priv,
                                virDomainObjPtr vm, virDomainDeviceDefPtr dev)
{
    virDomainDiskDefPtr l_disk = NULL;
    libxl_device_disk x_disk;
    int i;
    int wait_secs = 2;
    int ret = -1;

    switch (dev->data.disk->device)  {
        case VIR_DOMAIN_DISK_DEVICE_DISK:
            if (dev->data.disk->bus == VIR_DOMAIN_DISK_BUS_XEN) {

                if ((i = virDomainDiskIndexByName(vm->def,
                                                  dev->data.disk->dst,
                                                  false)) < 0) {
                    libxlError(VIR_ERR_OPERATION_FAILED,
                               _("disk %s not found"), dev->data.disk->dst);
                    goto cleanup;
                }

                l_disk = vm->def->disks[i];

                if (libxlMakeDisk(vm->def, l_disk, &x_disk) < 0)
                    goto cleanup;

                if ((ret = libxl_device_disk_del(&priv->ctx, &x_disk,
                                                 wait_secs)) < 0) {
                    libxlError(VIR_ERR_INTERNAL_ERROR,
                               _("libxenlight failed to detach disk '%s'"),
                               l_disk->dst);
                    goto cleanup;
                }

                virDomainDiskRemove(vm->def, i);
                virDomainDiskDefFree(l_disk);

            } else {
                libxlError(VIR_ERR_CONFIG_UNSUPPORTED,
                        _("disk bus '%s' cannot be hot unplugged."),
                        virDomainDiskBusTypeToString(dev->data.disk->bus));
            }
            break;
        default:
            libxlError(VIR_ERR_CONFIG_UNSUPPORTED,
                       _("device type '%s' cannot hot unplugged"),
                       virDomainDiskDeviceTypeToString(dev->data.disk->device));
            break;
    }

cleanup:
    return ret;
}

static int
libxlDomainAttachDeviceLive(libxlDomainObjPrivatePtr priv, virDomainObjPtr vm,
                            virDomainDeviceDefPtr dev)
{
    int ret = -1;

    switch (dev->type) {
        case VIR_DOMAIN_DEVICE_DISK:
            ret = libxlDomainAttachDeviceDiskLive(priv, vm, dev);
            if (!ret)
                dev->data.disk = NULL;
            break;

        default:
            libxlError(VIR_ERR_CONFIG_UNSUPPORTED,
                       _("device type '%s' cannot be attached"),
                       virDomainDeviceTypeToString(dev->type));
            break;
    }

    return ret;
}

static int
libxlDomainAttachDeviceConfig(virDomainDefPtr vmdef, virDomainDeviceDefPtr dev)
{
    virDomainDiskDefPtr disk;

    switch (dev->type) {
        case VIR_DOMAIN_DEVICE_DISK:
            disk = dev->data.disk;
            if (virDomainDiskIndexByName(vmdef, disk->dst, true) >= 0) {
                libxlError(VIR_ERR_INVALID_ARG,
                        _("target %s already exists."), disk->dst);
                return -1;
            }
            if (virDomainDiskInsert(vmdef, disk)) {
                virReportOOMError();
                return -1;
            }
            /* vmdef has the pointer. Generic codes for vmdef will do all jobs */
            dev->data.disk = NULL;
            break;

        default:
            libxlError(VIR_ERR_CONFIG_UNSUPPORTED, "%s",
                       _("persistent attach of device is not supported"));
            return -1;
    }
    return 0;
}

static int
libxlDomainDetachDeviceLive(libxlDomainObjPrivatePtr priv, virDomainObjPtr vm,
                            virDomainDeviceDefPtr dev)
{
    int ret = -1;

    switch (dev->type) {
        case VIR_DOMAIN_DEVICE_DISK:
            ret = libxlDomainDetachDeviceDiskLive(priv, vm, dev);
            break;

        default:
            libxlError(VIR_ERR_CONFIG_UNSUPPORTED,
                       _("device type '%s' cannot be detached"),
                       virDomainDeviceTypeToString(dev->type));
            break;
    }

    return ret;
}

static int
libxlDomainDetachDeviceConfig(virDomainDefPtr vmdef, virDomainDeviceDefPtr dev)
{
    virDomainDiskDefPtr disk, detach;
    int ret = -1;

    switch (dev->type) {
        case VIR_DOMAIN_DEVICE_DISK:
            disk = dev->data.disk;
            if (!(detach = virDomainDiskRemoveByName(vmdef, disk->dst))) {
                libxlError(VIR_ERR_INVALID_ARG,
                            _("no target device %s"), disk->dst);
                break;
            }
            virDomainDiskDefFree(detach);
            ret = 0;
            break;
        default:
            libxlError(VIR_ERR_CONFIG_UNSUPPORTED, "%s",
                       _("persistent detach of device is not supported"));
            break;
    }

    return ret;
}

static int
libxlDomainUpdateDeviceLive(libxlDomainObjPrivatePtr priv,
                            virDomainObjPtr vm, virDomainDeviceDefPtr dev)
{
    virDomainDiskDefPtr disk;
    int ret = -1;

    switch (dev->type) {
        case VIR_DOMAIN_DEVICE_DISK:
            disk = dev->data.disk;
            switch (disk->device) {
                case VIR_DOMAIN_DISK_DEVICE_CDROM:
                    ret = libxlDomainChangeEjectableMedia(priv, vm, disk);
                    if (ret == 0)
                        dev->data.disk = NULL;
                    break;
                default:
                    libxlError(VIR_ERR_CONFIG_UNSUPPORTED,
                               _("disk bus '%s' cannot be updated."),
                               virDomainDiskBusTypeToString(disk->bus));
                    break;
            }
            break;
        default:
            libxlError(VIR_ERR_CONFIG_UNSUPPORTED,
                       _("device type '%s' cannot be updated"),
                       virDomainDeviceTypeToString(dev->type));
            break;
    }

    return ret;
}

static int
libxlDomainUpdateDeviceConfig(virDomainDefPtr vmdef, virDomainDeviceDefPtr dev)
{
    virDomainDiskDefPtr orig;
    virDomainDiskDefPtr disk;
    int i;
    int ret = -1;

    switch (dev->type) {
        case VIR_DOMAIN_DEVICE_DISK:
            disk = dev->data.disk;
            if ((i = virDomainDiskIndexByName(vmdef, disk->dst, false)) < 0) {
                libxlError(VIR_ERR_INVALID_ARG,
                           _("target %s doesn't exist."), disk->dst);
                goto cleanup;
            }
            orig = vmdef->disks[i];
            if (!(orig->device == VIR_DOMAIN_DISK_DEVICE_CDROM)) {
                libxlError(VIR_ERR_INVALID_ARG,
                           _("this disk doesn't support update"));
                goto cleanup;
            }

            VIR_FREE(orig->src);
            orig->src = disk->src;
            orig->type = disk->type;
            if (disk->driverName) {
                VIR_FREE(orig->driverName);
                orig->driverName = disk->driverName;
                disk->driverName = NULL;
            }
            if (disk->driverType) {
                VIR_FREE(orig->driverType);
                orig->driverType = disk->driverType;
                disk->driverType = NULL;
            }
            disk->src = NULL;
            break;
        default:
            libxlError(VIR_ERR_CONFIG_UNSUPPORTED, "%s",
                       _("persistent update of device is not supported"));
            goto cleanup;
    }

    ret = 0;

cleanup:
    return ret;
}

/* Actions for libxlDomainModifyDeviceFlags */
enum {
    LIBXL_DEVICE_ATTACH,
    LIBXL_DEVICE_DETACH,
    LIBXL_DEVICE_UPDATE,
};

static int
libxlDomainModifyDeviceFlags(virDomainPtr dom, const char *xml,
                             unsigned int flags, int action)
{
    libxlDriverPrivatePtr driver = dom->conn->privateData;
    virDomainObjPtr vm = NULL;
    virDomainDefPtr vmdef = NULL;
    virDomainDeviceDefPtr dev = NULL;
    libxlDomainObjPrivatePtr priv;
    int ret = -1;

    virCheckFlags(VIR_DOMAIN_DEVICE_MODIFY_LIVE |
                  VIR_DOMAIN_DEVICE_MODIFY_CONFIG, -1);

    libxlDriverLock(driver);
    vm = virDomainFindByUUID(&driver->domains, dom->uuid);

    if (!vm) {
        libxlError(VIR_ERR_NO_DOMAIN, "%s", _("no domain with matching uuid"));
        goto cleanup;
    }

    if (libxlDomainObjBeginJobWithDriver(driver, vm, LIBXL_JOB_MODIFY) < 0)
        goto cleanup;

    if (virDomainObjIsActive(vm)) {
        if (flags == VIR_DOMAIN_DEVICE_MODIFY_CURRENT)
            flags |= VIR_DOMAIN_DEVICE_MODIFY_LIVE;
    } else {
        if (flags == VIR_DOMAIN_DEVICE_MODIFY_CURRENT)
            flags |= VIR_DOMAIN_DEVICE_MODIFY_CONFIG;
        /* check consistency between flags and the vm state */
        if (flags & VIR_DOMAIN_DEVICE_MODIFY_LIVE) {
            libxlError(VIR_ERR_OPERATION_INVALID,
                       "%s", _("Domain is not running"));
            goto endjob;
        }
    }

    if ((flags & VIR_DOMAIN_DEVICE_MODIFY_CONFIG) && !vm->persistent) {
         libxlError(VIR_ERR_OPERATION_INVALID,
                    "%s", _("cannot modify device on transient domain"));
         goto endjob;
    }

    priv = vm->privateData;

    if (flags & VIR_DOMAIN_DEVICE_MODIFY_CONFIG) {
        if (!(dev = virDomainDeviceDefParse(driver->caps, vm->def, xml,
                                            VIR_DOMAIN_XML_INACTIVE)))
            goto endjob;

        /* Make a copy for updated domain. */
        if (!(vmdef = virDomainObjCopyPersistentDef(driver->caps, vm)))
            goto endjob;

        switch (action) {
            case LIBXL_DEVICE_ATTACH:
                ret = libxlDomainAttachDeviceConfig(vmdef, dev);
                break;
            case LIBXL_DEVICE_DETACH:
                ret = libxlDomainDetachDeviceConfig(vmdef, dev);
                break;
            case LIBXL_DEVICE_UPDATE:
                ret = libxlDomainUpdateDeviceConfig(vmdef, dev);
            default:
                libxlError(VIR_ERR_INTERNAL_ERROR,
                           _("unknown domain modify action %d"), action);
                break;
        }
    } else
        ret = 0;

    if (flags & VIR_DOMAIN_DEVICE_MODIFY_LIVE) {
        /* If dev exists it was created to modify the domain config. Free it. */
        virDomainDeviceDefFree(dev);
        if (!(dev = virDomainDeviceDefParse(driver->caps, vm->def, xml,
                                            VIR_DOMAIN_XML_INACTIVE)))
            goto endjob;

        switch (action) {
            case LIBXL_DEVICE_ATTACH:
                ret = libxlDomainAttachDeviceLive(priv, vm, dev);
                break;
            case LIBXL_DEVICE_DETACH:
                ret = libxlDomainDetachDeviceLive(priv, vm, dev);
                break;
            case LIBXL_DEVICE_UPDATE:
                ret = libxlDomainUpdateDeviceLive(priv, vm, dev);
            default:
                libxlError(VIR_ERR_INTERNAL_ERROR,
                           _("unknown domain modify action %d"), action);
                break;
        }
        /*
         * update domain status forcibly because the domain status may be
         * changed even if we attach the device failed.
         */
        if (virDomainSaveStatus(driver->caps, driver->stateDir, vm) < 0)
            ret = -1;
    }

    /* Finally, if no error until here, we can save config. */
    if (!ret && (flags & VIR_DOMAIN_DEVICE_MODIFY_CONFIG)) {
        ret = virDomainSaveConfig(driver->configDir, vmdef);
        if (!ret) {
            virDomainObjAssignDef(vm, vmdef, false);
            vmdef = NULL;
        }
    }

endjob:
    if (libxlDomainObjEndJob(driver, vm) == 0)
        vm = NULL;

cleanup:
    virDomainDefFree(vmdef);
    virDomainDeviceDefFree(dev);
    if (vm)
        virDomainObjUnlock(vm);
    libxlDriverUnlock(driver);
    return ret;
}

static int
libxlDomainAttachDeviceFlags(virDomainPtr dom, const char *xml,
                             unsigned int flags)
{
    return libxlDomainModifyDeviceFlags(dom, xml, flags, LIBXL_DEVICE_ATTACH);
}

static int
libxlDomainAttachDevice(virDomainPtr dom, const char *xml)
{
    return libxlDomainAttachDeviceFlags(dom, xml,
                                        VIR_DOMAIN_DEVICE_MODIFY_LIVE);
}

static int
libxlDomainDetachDeviceFlags(virDomainPtr dom, const char *xml,
                             unsigned int flags)
{
    return libxlDomainModifyDeviceFlags(dom, xml, flags, LIBXL_DEVICE_DETACH);
}

static int
libxlDomainDetachDevice(virDomainPtr dom, const char *xml)
{
    return libxlDomainDetachDeviceFlags(dom, xml,
                                        VIR_DOMAIN_DEVICE_MODIFY_LIVE);
}

static int
libxlDomainUpdateDeviceFlags(virDomainPtr dom, const char *xml,
                             unsigned int flags)
{
    return libxlDomainModifyDeviceFlags(dom, xml, flags, LIBXL_DEVICE_UPDATE);
}

static unsigned long long
libxlNodeGetFreeMemory(virConnectPtr conn)
{
    libxl_physinfo phy_info;
    const libxl_version_info* ver_info;
    libxlDriverPrivatePtr driver = conn->privateData;

    if (libxl_get_physinfo(&driver->ctx, &phy_info)) {
        libxlError(VIR_ERR_INTERNAL_ERROR, _("libxl_get_physinfo_info failed"));
        return 0;
    }

    if ((ver_info = libxl_get_version_info(&driver->ctx)) == NULL) {
        libxlError(VIR_ERR_INTERNAL_ERROR, _("libxl_get_version_info failed"));
        return 0;
    }

    return phy_info.free_pages * ver_info->pagesize;
}

static int
libxlDomainEventRegister(virConnectPtr conn,
                         virConnectDomainEventCallback callback, void *opaque,
                         virFreeCallback freecb)
{
    libxlDriverPrivatePtr driver = conn->privateData;
    int ret;

    libxlDriverLock(driver);
    ret = virDomainEventStateRegister(conn,
                                      driver->domainEventState,
                                      callback, opaque, freecb);
    libxlDriverUnlock(driver);

    return ret;
}


static int
libxlDomainEventDeregister(virConnectPtr conn,
                          virConnectDomainEventCallback callback)
{
    libxlDriverPrivatePtr driver = conn->privateData;
    int ret;

    libxlDriverLock(driver);
    ret = virDomainEventStateDeregister(conn,
                                        driver->domainEventState,
                                        callback);
    libxlDriverUnlock(driver);

    return ret;
}

static int
libxlDomainGetAutostart(virDomainPtr dom, int *autostart)
{
    libxlDriverPrivatePtr driver = dom->conn->privateData;
    virDomainObjPtr vm;
    int ret = -1;

    libxlDriverLock(driver);
    vm = virDomainFindByUUID(&driver->domains, dom->uuid);
    libxlDriverUnlock(driver);

    if (!vm) {
        char uuidstr[VIR_UUID_STRING_BUFLEN];
        virUUIDFormat(dom->uuid, uuidstr);
        libxlError(VIR_ERR_NO_DOMAIN,
                   _("No domain with matching uuid '%s'"), uuidstr);
        goto cleanup;
    }

    *autostart = vm->autostart;
    ret = 0;

cleanup:
    if (vm)
        virDomainObjUnlock(vm);
    return ret;
}

static int
libxlDomainSetAutostart(virDomainPtr dom, int autostart)
{
    libxlDriverPrivatePtr driver = dom->conn->privateData;
    virDomainObjPtr vm;
    char *configFile = NULL, *autostartLink = NULL;
    int ret = -1;

    libxlDriverLock(driver);
    vm = virDomainFindByUUID(&driver->domains, dom->uuid);

    if (!vm) {
        char uuidstr[VIR_UUID_STRING_BUFLEN];
        virUUIDFormat(dom->uuid, uuidstr);
        libxlError(VIR_ERR_NO_DOMAIN,
                   _("No domain with matching uuid '%s'"), uuidstr);
        goto cleanup;
    }

    if (!vm->persistent) {
        libxlError(VIR_ERR_OPERATION_INVALID,
                   "%s", _("cannot set autostart for transient domain"));
        goto cleanup;
    }

    autostart = (autostart != 0);

    if (vm->autostart != autostart) {
        if (!(configFile = virDomainConfigFile(driver->configDir, vm->def->name)))
            goto cleanup;
        if (!(autostartLink = virDomainConfigFile(driver->autostartDir, vm->def->name)))
            goto cleanup;

        if (autostart) {
            if (virFileMakePath(driver->autostartDir) < 0) {
                virReportSystemError(errno,
                                     _("cannot create autostart directory %s"),
                                     driver->autostartDir);
                goto cleanup;
            }

            if (symlink(configFile, autostartLink) < 0) {
                virReportSystemError(errno,
                                     _("Failed to create symlink '%s to '%s'"),
                                     autostartLink, configFile);
                goto cleanup;
            }
        } else {
            if (unlink(autostartLink) < 0 && errno != ENOENT && errno != ENOTDIR) {
                virReportSystemError(errno,
                                     _("Failed to delete symlink '%s'"),
                                     autostartLink);
                goto cleanup;
            }
        }

        vm->autostart = autostart;
    }
    ret = 0;

cleanup:
    VIR_FREE(configFile);
    VIR_FREE(autostartLink);
    if (vm)
        virDomainObjUnlock(vm);
    libxlDriverUnlock(driver);
    return ret;
}

static char *
libxlDomainGetSchedulerType(virDomainPtr dom, int *nparams)
{
    libxlDriverPrivatePtr driver = dom->conn->privateData;
    libxlDomainObjPrivatePtr priv;
    virDomainObjPtr vm;
    char * ret = NULL;
    int sched_id;

    libxlDriverLock(driver);
    vm = virDomainFindByUUID(&driver->domains, dom->uuid);
    libxlDriverUnlock(driver);

    if (!vm) {
        libxlError(VIR_ERR_NO_DOMAIN, "%s", _("no domain with matching uuid"));
        goto cleanup;
    }

    if (!virDomainObjIsActive(vm)) {
        libxlError(VIR_ERR_OPERATION_INVALID, "%s", _("Domain is not running"));
        goto cleanup;
    }

    priv = vm->privateData;
    if ((sched_id = libxl_get_sched_id(&priv->ctx)) < 0) {
        libxlError(VIR_ERR_INTERNAL_ERROR,
                   _("Failed to get scheduler id for domain '%d'"
                     " with libxenlight"), dom->id);
        goto cleanup;
    }

    if (nparams)
        *nparams = 0;
    switch(sched_id) {
    case XEN_SCHEDULER_SEDF:
        ret = strdup("sedf");
        break;
    case XEN_SCHEDULER_CREDIT:
        ret = strdup("credit");
        if (nparams)
            *nparams = XEN_SCHED_CREDIT_NPARAM;
        break;
    case XEN_SCHEDULER_CREDIT2:
        ret = strdup("credit2");
        break;
    case XEN_SCHEDULER_ARINC653:
        ret = strdup("arinc653");
        break;
    default:
        goto cleanup;
    }

    if (!ret)
        virReportOOMError();

cleanup:
    if (vm)
        virDomainObjUnlock(vm);
    return ret;
}

static int
libxlDomainGetSchedulerParametersFlags(virDomainPtr dom,
                                       virTypedParameterPtr params,
                                       int *nparams,
                                       unsigned int flags)
{
    libxlDriverPrivatePtr driver = dom->conn->privateData;
    libxlDomainObjPrivatePtr priv;
    virDomainObjPtr vm;
    libxl_sched_credit sc_info;
    int sched_id;
    int ret = -1;

    virCheckFlags(0, -1);

    libxlDriverLock(driver);
    vm = virDomainFindByUUID(&driver->domains, dom->uuid);
    libxlDriverUnlock(driver);

    if (!vm) {
        libxlError(VIR_ERR_NO_DOMAIN, "%s", _("no domain with matching uuid"));
        goto cleanup;
    }

    if (!virDomainObjIsActive(vm)) {
        libxlError(VIR_ERR_OPERATION_INVALID, "%s", _("Domain is not running"));
        goto cleanup;
    }

    priv = vm->privateData;

    if ((sched_id = libxl_get_sched_id(&priv->ctx)) < 0) {
        libxlError(VIR_ERR_INTERNAL_ERROR,
                   _("Failed to get scheduler id for domain '%d'"
                     " with libxenlight"), dom->id);
        goto cleanup;
    }

    if (sched_id != XEN_SCHEDULER_CREDIT) {
        libxlError(VIR_ERR_INTERNAL_ERROR,
                   _("Only 'credit' scheduler is supported"));
        goto cleanup;
    }

    if (libxl_sched_credit_domain_get(&priv->ctx, dom->id, &sc_info) != 0) {
        libxlError(VIR_ERR_INTERNAL_ERROR,
                   _("Failed to get scheduler parameters for domain '%d'"
                     " with libxenlight"), dom->id);
        goto cleanup;
    }

    if (virTypedParameterAssign(&params[0], VIR_DOMAIN_SCHEDULER_WEIGHT,
                                VIR_TYPED_PARAM_UINT, sc_info.weight) < 0)
        goto cleanup;

    if (*nparams > 1) {
        if (virTypedParameterAssign(&params[0], VIR_DOMAIN_SCHEDULER_CAP,
                                    VIR_TYPED_PARAM_UINT, sc_info.cap) < 0)
            goto cleanup;
    }

    if (*nparams > XEN_SCHED_CREDIT_NPARAM)
        *nparams = XEN_SCHED_CREDIT_NPARAM;
    ret = 0;

cleanup:
    if (vm)
        virDomainObjUnlock(vm);
    return ret;
}

static int
libxlDomainGetSchedulerParameters(virDomainPtr dom, virTypedParameterPtr params,
                                  int *nparams)
{
    return libxlDomainGetSchedulerParametersFlags(dom, params, nparams, 0);
}

static int
libxlDomainSetSchedulerParametersFlags(virDomainPtr dom,
                                       virTypedParameterPtr params,
                                       int nparams,
                                       unsigned int flags)
{
    libxlDriverPrivatePtr driver = dom->conn->privateData;
    libxlDomainObjPrivatePtr priv;
    virDomainObjPtr vm;
    libxl_sched_credit sc_info;
    int sched_id;
    int i;
    int ret = -1;

    virCheckFlags(0, -1);
    if (virTypedParameterArrayValidate(params, nparams,
                                       VIR_DOMAIN_SCHEDULER_WEIGHT,
                                       VIR_TYPED_PARAM_UINT,
                                       VIR_DOMAIN_SCHEDULER_CAP,
                                       VIR_TYPED_PARAM_UINT,
                                       NULL) < 0)
        return -1;

    libxlDriverLock(driver);
    vm = virDomainFindByUUID(&driver->domains, dom->uuid);
    libxlDriverUnlock(driver);

    if (!vm) {
        libxlError(VIR_ERR_NO_DOMAIN, "%s", _("no domain with matching uuid"));
        goto cleanup;
    }

    if (!virDomainObjIsActive(vm)) {
        libxlError(VIR_ERR_OPERATION_INVALID, "%s", _("Domain is not running"));
        goto cleanup;
    }

    priv = vm->privateData;

    if ((sched_id = libxl_get_sched_id(&priv->ctx)) < 0) {
        libxlError(VIR_ERR_INTERNAL_ERROR,
                   _("Failed to get scheduler id for domain '%d'"
                     " with libxenlight"), dom->id);
        goto cleanup;
    }

    if (sched_id != XEN_SCHEDULER_CREDIT) {
        libxlError(VIR_ERR_INTERNAL_ERROR,
                   _("Only 'credit' scheduler is supported"));
        goto cleanup;
    }

    if (libxl_sched_credit_domain_get(&priv->ctx, dom->id, &sc_info) != 0) {
        libxlError(VIR_ERR_INTERNAL_ERROR,
                   _("Failed to get scheduler parameters for domain '%d'"
                     " with libxenlight"), dom->id);
        goto cleanup;
    }

    for (i = 0; i < nparams; ++i) {
        virTypedParameterPtr param = &params[i];

        if (STREQ(param->field, VIR_DOMAIN_SCHEDULER_WEIGHT)) {
            sc_info.weight = params[i].value.ui;
        } else if (STREQ(param->field, VIR_DOMAIN_SCHEDULER_CAP)) {
            sc_info.cap = params[i].value.ui;
        }
    }

    if (libxl_sched_credit_domain_set(&priv->ctx, dom->id, &sc_info) != 0) {
        libxlError(VIR_ERR_INTERNAL_ERROR,
                   _("Failed to set scheduler parameters for domain '%d'"
                     " with libxenlight"), dom->id);
        goto cleanup;
    }

    ret = 0;

cleanup:
    if (vm)
        virDomainObjUnlock(vm);
    return ret;
}

static int
libxlDomainSetSchedulerParameters(virDomainPtr dom, virTypedParameterPtr params,
                                  int nparams)
{
    return libxlDomainSetSchedulerParametersFlags(dom, params, nparams, 0);
}

static int
libxlDomainIsActive(virDomainPtr dom)
{
    libxlDriverPrivatePtr driver = dom->conn->privateData;
    virDomainObjPtr obj;
    int ret = -1;

    libxlDriverLock(driver);
    obj = virDomainFindByUUID(&driver->domains, dom->uuid);
    libxlDriverUnlock(driver);
    if (!obj) {
        libxlError(VIR_ERR_NO_DOMAIN, NULL);
        goto cleanup;
    }
    ret = virDomainObjIsActive(obj);

  cleanup:
    if (obj)
        virDomainObjUnlock(obj);
    return ret;
}

static int
libxlDomainIsPersistent(virDomainPtr dom)
{
    libxlDriverPrivatePtr driver = dom->conn->privateData;
    virDomainObjPtr obj;
    int ret = -1;

    libxlDriverLock(driver);
    obj = virDomainFindByUUID(&driver->domains, dom->uuid);
    libxlDriverUnlock(driver);
    if (!obj) {
        libxlError(VIR_ERR_NO_DOMAIN, NULL);
        goto cleanup;
    }
    ret = obj->persistent;

cleanup:
    if (obj)
        virDomainObjUnlock(obj);
    return ret;
}

static int
libxlDomainIsUpdated(virDomainPtr dom)
{
    libxlDriverPrivatePtr driver = dom->conn->privateData;
    virDomainObjPtr vm;
    int ret = -1;

    libxlDriverLock(driver);
    vm = virDomainFindByUUID(&driver->domains, dom->uuid);
    libxlDriverUnlock(driver);
    if (!vm) {
        libxlError(VIR_ERR_NO_DOMAIN, NULL);
        goto cleanup;
    }
    ret = vm->updated;

cleanup:
    if (vm)
        virDomainObjUnlock(vm);
    return ret;
}

static int
libxlDomainGetJobInfo(virDomainPtr dom,
                      virDomainJobInfoPtr info)
{
    libxlDriverPrivatePtr driver = dom->conn->privateData;
    virDomainObjPtr vm;
    int ret = -1;
    libxlDomainObjPrivatePtr priv;

    libxlDriverLock(driver);
    vm = virDomainFindByUUID(&driver->domains, dom->uuid);
    libxlDriverUnlock(driver);
    if (!vm) {
        char uuidstr[VIR_UUID_STRING_BUFLEN];
        virUUIDFormat(dom->uuid, uuidstr);
        libxlError(VIR_ERR_NO_DOMAIN,
                        _("no domain with matching uuid '%s'"), uuidstr);
        goto cleanup;
    }

    priv = vm->privateData;

    if (virDomainObjIsActive(vm)) {
        if (priv->job.asyncJob) {
            memcpy(info, &priv->job.info, sizeof(*info));

            /* Refresh elapsed time again just to ensure it
             * is fully updated. This is primarily for benefit
             * of incoming migration which we don't currently
             * monitor actively in the background thread
             */
            if (virTimeMillisNow(&info->timeElapsed) < 0)
                goto cleanup;
            info->timeElapsed -= priv->job.start;
        } else {
            memset(info, 0, sizeof(*info));
            info->type = VIR_DOMAIN_JOB_NONE;
        }
    } else {
        libxlError(VIR_ERR_OPERATION_INVALID,
                        "%s", _("domain is not running"));
        goto cleanup;
    }

    ret = 0;

cleanup:
    if (vm)
        virDomainObjUnlock(vm);
    return ret;
}


static int
libxlDomainAbortJob(virDomainPtr dom)
{
    libxlDriverPrivatePtr driver = dom->conn->privateData;
    virDomainObjPtr vm;
    int ret = -1;
    libxlDomainObjPrivatePtr priv;

    libxlDriverLock(driver);
    vm = virDomainFindByUUID(&driver->domains, dom->uuid);
    libxlDriverUnlock(driver);
    if (!vm) {
        char uuidstr[VIR_UUID_STRING_BUFLEN];
        virUUIDFormat(dom->uuid, uuidstr);
        libxlError(VIR_ERR_NO_DOMAIN,
                        _("no domain with matching uuid '%s'"), uuidstr);
        goto cleanup;
    }

    if (libxlDomainObjBeginJob(driver, vm, LIBXL_JOB_ABORT) < 0)
        goto cleanup;

    if (!virDomainObjIsActive(vm)) {
        libxlError(VIR_ERR_OPERATION_INVALID,
                        "%s", _("domain is not running"));
        goto endjob;
    }

    priv = vm->privateData;

    if (!priv->job.asyncJob) {
        libxlError(VIR_ERR_OPERATION_INVALID,
                        "%s", _("no job is active on the domain"));
        goto endjob;
    } else if (priv->job.asyncJob == LIBXL_ASYNC_JOB_MIGRATION_IN) {
        libxlError(VIR_ERR_OPERATION_INVALID, "%s",
                        _("cannot abort incoming migration;"
                          " use virDomainDestroy instead"));
        goto endjob;
    } else if (priv->job.asyncJob == LIBXL_ASYNC_JOB_DUMP) {
        libxlError(VIR_ERR_OPERATION_INVALID, "%s",
                        _("cannot abort core dump;"
                          " use virDomainDestroy instead"));
        goto endjob;
    }

    VIR_DEBUG("Cancelling job at client request");
    // \TODO 

endjob:
    if (libxlDomainObjEndJob(driver, vm) == 0)
        vm = NULL;

cleanup:
    if (vm)
        virDomainObjUnlock(vm);
    return ret;
}


static int
libxlDomainEventRegisterAny(virConnectPtr conn, virDomainPtr dom, int eventID,
                            virConnectDomainEventGenericCallback callback,
                            void *opaque, virFreeCallback freecb)
{
    libxlDriverPrivatePtr driver = conn->privateData;
    int ret;

    libxlDriverLock(driver);
    if (virDomainEventStateRegisterID(conn,
                                      driver->domainEventState,
                                      dom, eventID, callback, opaque,
                                      freecb, &ret) < 0)
        ret = -1;
    libxlDriverUnlock(driver);

    return ret;
}


static int
libxlDomainEventDeregisterAny(virConnectPtr conn, int callbackID)
{
    libxlDriverPrivatePtr driver = conn->privateData;
    int ret;

    libxlDriverLock(driver);
    ret = virDomainEventStateDeregisterID(conn,
                                          driver->domainEventState,
                                          callbackID);
    libxlDriverUnlock(driver);

    return ret;
}


static int
libxlIsAlive(virConnectPtr conn ATTRIBUTE_UNUSED)
{
    return 1;
}

static int libxlCheckMessageBanner(int fd, const char *banner, int banner_sz)
{
    char buf[banner_sz];
    int ret = 0;

    do { 
        ret = saferead(fd, buf, banner_sz);
    } while ( -1 == ret && EAGAIN == errno );

    if ( ret != banner_sz || memcmp(buf, banner, banner_sz) ) 
        return -1;

    return 0;
}

static int doParseURI(const char *uri, char **p_hostname, int *p_port)
{
    char *p, *hostname;
    int port_nr = 0;

    if (uri == NULL)
        return -1;

    /* URI passed is a string "hostname[:port]" */
    if ((p = strrchr(uri, ':')) != NULL) { /* "hostname:port" */
        int n;

        if (virStrToLong_i(p+1, NULL, 10, &port_nr) < 0) {
            libxlError(VIR_ERR_INVALID_ARG,
                        _("Invalid port number"));
            return -1;
        }

        /* Get the hostname. */
        n = p - uri; /* n = Length of hostname in bytes. */
        if (n <= 0) {
            libxlError(VIR_ERR_INVALID_ARG,
                       _("Hostname must be specified in the URI"));
            return -1;
        }

        if (virAsprintf(&hostname, "%s", uri) < 0) {
            virReportOOMError();
            return -1;
        }

        hostname[n] = '\0';
    }
    else {/* "hostname" (or IP address) */
        if (virAsprintf(&hostname, "%s", uri) < 0) {
            virReportOOMError();
            return -1;
        }
    }
    *p_hostname = hostname;
    *p_port = port_nr;
    return 0;
}

static char *
libxlDomainMigrateBegin3(virDomainPtr domain,
                          const char *xmlin,
                          char **cookieout ATTRIBUTE_UNUSED,
                          int *cookieoutlen ATTRIBUTE_UNUSED,
                          unsigned long flags,
                          const char *dname ATTRIBUTE_UNUSED,
                          unsigned long resource ATTRIBUTE_UNUSED)
{
    libxlDriverPrivatePtr driver = domain->conn->privateData;
    virDomainObjPtr vm;
    virDomainDefPtr def = NULL;
    char *xml = NULL;
    int ret = -1;

    virCheckFlags(LIBXL_MIGRATION_FLAGS, NULL);

    libxlDriverLock(driver);
    vm = virDomainFindByUUID(&driver->domains, domain->uuid);
    if (!vm) {
        char uuidstr[VIR_UUID_STRING_BUFLEN];
        virUUIDFormat(domain->uuid, uuidstr);
        libxlError(VIR_ERR_OPERATION_INVALID,
                   _("no domain with matching uuid '%s'"), uuidstr);
        goto cleanup;
    }

    if ( libxlMigrationJobStart(driver, vm, LIBXL_ASYNC_JOB_MIGRATION_OUT) < 0)
        goto cleanup;

    if (!virDomainObjIsActive(vm)) {
        libxlError(VIR_ERR_OPERATION_INVALID,
                         _("domain is not running"));
        goto endjob;
    }

    if (xmlin) {
        if (!(def = virDomainDefParseString(driver->caps, xmlin,
                         1 << VIR_DOMAIN_VIRT_XEN,
                         VIR_DOMAIN_XML_INACTIVE)))
            goto endjob;

        xml = virDomainDefFormat(def, VIR_DOMAIN_XML_SECURE);
    } else {
        xml = virDomainDefFormat(vm->def, VIR_DOMAIN_XML_SECURE);
    }

    ret = 0;
endjob:
    if ( ret < 0 ) 
        if (libxlMigrationJobFinish(driver, vm) == 0) 
            vm = NULL;
cleanup:
    if (vm)
        virDomainObjUnlock(vm);
    libxlDriverUnlock(driver);
    return xml;
}

static void doMigrateReceive(void *opaque)
{
    migrate_receive_args *data = opaque;
    virConnectPtr conn = data->conn;
    int sockfd = data->sockfd;
    virDomainObjPtr vm = data->vm;
    libxlDriverPrivatePtr driver = conn->privateData;
    int recv_fd;
    struct sockaddr_in new_addr;
    socklen_t socklen = sizeof(new_addr);
    int len;
    int ret = -1;

    do {
        recv_fd = accept(sockfd, (struct sockaddr *)&new_addr, &socklen);
    } while(recv_fd < 0 && errno == EINTR);

    if (recv_fd < 0) {
        libxlError(VIR_ERR_OPERATION_FAILED,
                   _("Could not accept migration connection"));
        goto cleanup;
    }
    VIR_DEBUG("Accepted migration\n");

//    len = sizeof(migrate_receiver_banner);
//    if (safewrite(recv_fd, migrate_receiver_banner, len) != len) {
//        libxlError(VIR_ERR_OPERATION_FAILED,
//                         _("Failed to write migrate_receiver_banner"));
//        goto cleanup;
//    }
//
    virDomainObjUnlock(vm);
    libxlDriverUnlock(driver);
    ret = libxlVmStart(driver, vm, false, recv_fd, false);
    libxlDriverLock(driver);
    virDomainObjLock(vm);
    if ( ret < 0) {
        libxlError(VIR_ERR_INTERNAL_ERROR,
                    _("Failed to restore domain with libxenlight"));
        goto cleanup;
    }

//    len = sizeof(migrate_receiver_ready);
//    if (safewrite(recv_fd, migrate_receiver_ready, len) != len) {
//        libxlError(VIR_ERR_OPERATION_FAILED,
//                         _("Failed to write migrate_receiver_ready"));
//    }

cleanup:
    if (VIR_CLOSE(recv_fd) < 0)
        virReportSystemError(errno, "%s", _("cannot close recv_fd"));
    if (VIR_CLOSE(sockfd) < 0)
        virReportSystemError(errno, "%s", _("cannot close sockfd"));
    if (vm)
        virDomainObjUnlock(vm);
    VIR_FREE(opaque);
    libxlDriverUnlock(driver);
    return;
}

static int doMigrateSend(libxlDriverPrivatePtr driver, virDomainObjPtr vm, unsigned long flags, int sockfd)
//static void doMigrateSend(void *opaque)
{
//    migrate_send_args *data = opaque;
//    libxlDriverPrivatePtr driver = data->driver;
//    virDomainObjPtr vm = data->vm;
//    unsigned long flags = data->flags;
//    int sockfd = data->sockfd;
    libxlDomainObjPrivatePtr priv;
    libxl_domain_suspend_info suspinfo;
    virDomainEventPtr event = NULL;
    int live = 0;
    int ret = -1;

    if (flags & VIR_MIGRATE_LIVE)
        live = 1;

    priv = vm->privateData;

//    /* read fixed message from dest (ready to receive) */
//    if (libxlCheckMessageBanner(sockfd, migrate_receiver_banner,
//                              sizeof(migrate_receiver_banner))) {
//        goto cleanup;
//    }

    /* send suspend data */
    memset(&suspinfo, 0, sizeof(suspinfo));
    if (live == 1)
        suspinfo.flags |= XL_SUSPEND_LIVE;

    virDomainObjUnlock(vm);
    libxlDriverUnlock(driver);
    ret = libxl_domain_suspend(&priv->ctx, &suspinfo, vm->def->id, sockfd);
    libxlDriverLock(driver);
    virDomainObjLock(vm);
#if 1
    if (ret != 0) {
        libxlError(VIR_ERR_INTERNAL_ERROR,
                    _("Failed to save domain '%d' with libxenlight"),
                    vm->def->id);
        goto cleanup;
    }

    /* read fixed message from dest (receive completed) */
//    if (libxlCheckMessageBanner(sockfd, migrate_receiver_ready,
//                              sizeof(migrate_receiver_ready))) {
    if ( 0 ) {
        /* Src side should be resumed, but for ret < 0, virsh won't call Src side
         * Confirm3, handle it here.
         */
        if (libxl_domain_resume(&priv->ctx, vm->def->id) != 0) {
            VIR_DEBUG("Failed to resume domain '%d' with libxenlight",
                      vm->def->id);
            virDomainObjSetState(vm, VIR_DOMAIN_PAUSED, VIR_DOMAIN_PAUSED_MIGRATION);
            event = virDomainEventNewFromObj(vm, VIR_DOMAIN_EVENT_SUSPENDED,
                                             VIR_DOMAIN_EVENT_SUSPENDED_MIGRATED);
            if (virDomainSaveStatus(driver->caps, driver->stateDir, vm) < 0)
                goto cleanup;
        }
        goto cleanup;
    }
#else
    if (ret != 0) {
        libxlError(VIR_ERR_INTERNAL_ERROR,
                    _("Failed to save domain '%d' with libxenlight"),
                    vm->def->id);
        /* Src side should be resumed, but for ret < 0, virsh won't call Src side
         * Confirm3, handle it here.
         */
        if (libxl_domain_resume(&priv->ctx, vm->def->id) != 0) {
            VIR_DEBUG("Failed to resume domain '%d' with libxenlight",
                      vm->def->id);
            virDomainObjSetState(vm, VIR_DOMAIN_PAUSED, VIR_DOMAIN_PAUSED_MIGRATION);
            event = virDomainEventNewFromObj(vm, VIR_DOMAIN_EVENT_SUSPENDED,
                                             VIR_DOMAIN_EVENT_SUSPENDED_MIGRATED);
            if (virDomainSaveStatus(driver->caps, driver->stateDir, vm) < 0)
                goto cleanup;
        }
        goto cleanup;
    }
#endif
    ret = 0;

cleanup:
    if (event)
        libxlDomainEventQueue(driver, event);
    return ret;
}

static int
libxlDomainMigratePrepare3(virConnectPtr dconn,
                            const char *cookiein ATTRIBUTE_UNUSED,
                            int cookieinlen ATTRIBUTE_UNUSED,
                            char **cookieout ATTRIBUTE_UNUSED,
                            int *cookieoutlen ATTRIBUTE_UNUSED,
                            const char *uri_in,
                            char **uri_out,
                            unsigned long flags,
                            const char *dname,
                            unsigned long resource ATTRIBUTE_UNUSED,
                            const char *dom_xml)
{
    libxlDriverPrivatePtr driver = dconn->privateData;
    virDomainDefPtr def = NULL;
    virDomainObjPtr vm = NULL;
    char *hostname = NULL;
    int port = 0;
    int sockfd = -1;
    struct sockaddr_in addr;
    virThread migrate_receive_thread;
    migrate_receive_args *args;
    int ret = -1;

    virCheckFlags(LIBXL_MIGRATION_FLAGS, -1);

    libxlDriverLock(driver);
    if (!dom_xml) {
        libxlError(VIR_ERR_OPERATION_INVALID,
                         _("no domain XML passed"));
        goto cleanup;
    }

    def = virDomainDefParseString(driver->caps, dom_xml,
                                 1 << VIR_DOMAIN_VIRT_XEN,
                                 VIR_DOMAIN_XML_INACTIVE);

    /* Target domain name, maybe renamed. */
    if (dname) {
        def->name = strdup(dname);
        if (def->name == NULL)
            goto cleanup;
    }

    if (virDomainObjIsDuplicate(&driver->domains, def, 1) < 0)
        goto cleanup;

    if (!(vm = virDomainAssignDef(driver->caps, &driver->domains, def, true)))
        goto cleanup;

    def = NULL;

//    if ( libxlMigrationJobStart(driver, vm, LIBXL_ASYNC_JOB_MIGRATION_IN) < 0)
    if ( libxlMigrationJobStart(driver, vm, LIBXL_ASYNC_JOB_MIGRATION_OUT) < 0)
        goto cleanup;

    /* Create socket connection to receive migration data */
    if (!uri_in) {
        hostname = virGetHostname(dconn);
        if (hostname == NULL)
            goto endjob;

        port = libxlNextFreePort(driver->reservedMigPorts, LIBXL_MIGRATION_MIN_PORT,
                                 LIBXL_MIGRATION_NUM_PORTS);
        if (port < 0) {
            libxlError(VIR_ERR_INTERNAL_ERROR,
                       "%s", _("Unable to find an unused migration port"));
            goto endjob;
        }

        if (virAsprintf(uri_out, "%s:%d", hostname, port) < 0) {
            virReportOOMError();
            goto endjob;
        }
    } else {
        if (doParseURI(uri_in, &hostname, &port))
            goto endjob;

        if (port <= 0) {
            port = libxlNextFreePort(driver->reservedMigPorts, LIBXL_MIGRATION_MIN_PORT,
                                     LIBXL_MIGRATION_NUM_PORTS);
            if (port < 0) {
                libxlError(VIR_ERR_INTERNAL_ERROR,
                           "%s", _("Unable to find an unused migration port"));
                goto endjob;
            }

            if (virAsprintf(uri_out, "%s:%d", hostname, port) < 0) {
                virReportOOMError();
                goto endjob;
            }
        }
    }

    sockfd = socket(AF_INET, SOCK_STREAM, 0);
    if (sockfd == -1) {
        libxlError(VIR_ERR_OPERATION_FAILED,
                   _("Failed to create socket for incoming migration"));
        goto endjob;
    }

    memset(&addr, 0, sizeof(addr));
    addr.sin_family = AF_INET;
    addr.sin_port = htons(port);
    addr.sin_addr.s_addr = htonl(INADDR_ANY);

    if (bind(sockfd, (struct sockaddr *)&addr, sizeof(addr)) < 0) {
        libxlError(VIR_ERR_OPERATION_FAILED,
                   _("Fail to bind port for incoming migration"));
        goto endjob;
    }

    if (listen(sockfd, MAXCONN_NUM) < 0){
        libxlError(VIR_ERR_OPERATION_FAILED,
                   _("Fail to listen to incoming migration"));
        goto endjob;
    }

    if (VIR_ALLOC(args) < 0) {
        virReportOOMError();
        goto endjob;
    }

    args->conn = dconn;
    args->vm = vm;
    args->sockfd = sockfd;
    if (virThreadCreate(&migrate_receive_thread,
                        true,
                        doMigrateReceive, args) < 0 ) {
        virReportSystemError(errno, "%s",
                             _("Unable to create migration thread"));
        VIR_FREE(args);
        goto endjob;
    }
    if (vm)
        virDomainObjUnlock(vm);
    libxlDriverUnlock(driver);

    ret = 0;
    goto end;

endjob:
    if ( ret < 0 ) 
        if (libxlMigrationJobFinish(driver, vm) == 0) 
            vm = NULL;
cleanup:
    if (VIR_CLOSE(sockfd) < 0)
        virReportSystemError(errno, "%s", _("cannot close sockfd"));
end:
    VIR_FREE(hostname);
    return ret;
}

static int
libxlDomainMigratePerform3(virDomainPtr dom,
                            const char *xmlin ATTRIBUTE_UNUSED,
                            const char *cookiein ATTRIBUTE_UNUSED,
                            int cookieinlen ATTRIBUTE_UNUSED,
                            char **cookieout ATTRIBUTE_UNUSED,
                            int *cookieoutlen ATTRIBUTE_UNUSED,
                            const char *dconnuri ATTRIBUTE_UNUSED,
                            const char *uri,
                            unsigned long flags,
                            const char *dname ATTRIBUTE_UNUSED,
                            unsigned long resource ATTRIBUTE_UNUSED)
{
    libxlDriverPrivatePtr driver = dom->conn->privateData;
    char *hostname = NULL;
    int port = 0;
    char *servname = NULL;
    virNetSocketPtr sock;
    int sockfd = -1;
    int ret = -1;
    virDomainObjPtr vm;
    virThread migrate_send_thread;
    migrate_send_args *args;

    virCheckFlags(LIBXL_MIGRATION_FLAGS, -1);

    libxlDriverLock(driver);
    vm = virDomainFindByUUID(&driver->domains, dom->uuid);
    if (!vm) {
        char uuidstr[VIR_UUID_STRING_BUFLEN];
        virUUIDFormat(dom->uuid, uuidstr);
        libxlError(VIR_ERR_OPERATION_INVALID,
                         _("no domain with matching uuid '%s'"), uuidstr);
        goto cleanup;
    }

    if (doParseURI(uri, &hostname, &port))
        goto cleanup;

    VIR_DEBUG("hostname = %s, port = %d", hostname, port);

    if (port <= 0)
        goto cleanup;

    if (virAsprintf(&servname, "%d", port) < 0) {
        virReportOOMError();
        goto cleanup;
    }

    if (virNetSocketNewConnectTCP(hostname, servname, &sock) < 0 ){
        libxlError(VIR_ERR_OPERATION_FAILED,
                   _("Failed to create socket"));
        goto cleanup;
    }

    sockfd = virNetSocketGetFD(sock);
#if 1
    ret = doMigrateSend(driver, vm, flags, sockfd);
#else
    if (VIR_ALLOC(args) < 0) {
        virReportOOMError();
        goto cleanup;
    }
    args->driver = driver;
    args->vm = vm;
    args->flags = flags;
    args->sockfd = sockfd;

    virDomainObjUnlock(vm);
    libxlDriverUnlock(driver);
    if (virThreadCreate(&migrate_send_thread,
                        true,
                        doMigrateSend, args) < 0 ) {
        libxlDriverLock(driver);
        virDomainObjLock(vm);
        virReportSystemError(errno, "%s",
                             _("Unable to create migration thread"));
        VIR_FREE(args);
        goto cleanup;
    }
    libxlDriverLock(driver);
    virDomainObjLock(vm);

    virThreadJoin(&migrate_send_thread);
#endif
cleanup:
    if ( ret < 0 ) 
        if (libxlMigrationJobFinish(driver, vm) == 0) 
            vm = NULL;
    virNetSocketFree(sock);
    VIR_FREE(hostname);
    VIR_FREE(servname);
    if (vm)
        virDomainObjUnlock(vm);
    libxlDriverUnlock(driver);
    return ret;
}

static virDomainPtr
libxlDomainMigrateFinish3(virConnectPtr dconn,
                           const char *dname,
                           const char *cookiein ATTRIBUTE_UNUSED,
                           int cookieinlen ATTRIBUTE_UNUSED,
                           char **cookieout ATTRIBUTE_UNUSED,
                           int *cookieoutlen ATTRIBUTE_UNUSED,
                           const char *dconnuri ATTRIBUTE_UNUSED,
                           const char *uri,
                           unsigned long flags,
                           int cancelled)
{
    libxlDriverPrivatePtr driver = dconn->privateData;
    char *hostname = NULL;
    int port = 0;
    virDomainObjPtr vm = NULL;
    virDomainPtr dom = NULL;
    libxlDomainObjPrivatePtr priv;
    virDomainEventPtr event = NULL;
    int rc;

    virCheckFlags(LIBXL_MIGRATION_FLAGS, NULL);

    libxlDriverLock(driver);

    if (doParseURI(uri, &hostname, &port))
        VIR_DEBUG("Fail to parse port from URI");

    if (LIBXL_MIGRATION_MIN_PORT <= port && port < LIBXL_MIGRATION_MAX_PORT) {
        if (virBitmapClearBit(driver->reservedMigPorts,
                              port - LIBXL_MIGRATION_MIN_PORT) < 0)
            VIR_DEBUG("Could not mark port %d as unused", port);
    }

    vm = virDomainFindByName(&driver->domains, dname);
    if (!vm)
        goto cleanup;

    if (!cancelled) {
        if (!(flags & VIR_MIGRATE_PAUSED)) {
            priv = vm->privateData;
            rc = libxl_domain_unpause(&priv->ctx, vm->def->id);
            if (rc) {
                libxlError(VIR_ERR_OPERATION_FAILED,
                           _("Failed to unpause domain"));
                goto error;
            }

            virDomainObjSetState(vm, VIR_DOMAIN_RUNNING, VIR_DOMAIN_RUNNING_BOOTED);
            if (virDomainSaveStatus(driver->caps, driver->stateDir, vm) < 0)
                goto error;
        }

        dom = virGetDomain(dconn, vm->def->name, vm->def->uuid);
        goto cleanup;
    }

error:
    if (libxlVmReap(driver, vm, 1, VIR_DOMAIN_SHUTOFF_SAVED)) {
        libxlError(VIR_ERR_INTERNAL_ERROR,
                   _("Failed to destroy domain '%d'"), vm->def->id);
        goto cleanup;
    }
    event = virDomainEventNewFromObj(vm, VIR_DOMAIN_EVENT_STOPPED,
                                     VIR_DOMAIN_EVENT_STOPPED_SAVED);

cleanup:
    if (libxlMigrationJobFinish(driver, vm) == 0) {
        vm = NULL;
    } else if (!vm->persistent && !virDomainObjIsActive(vm)) {
        virDomainRemoveInactive(&driver->domains, vm);
        vm = NULL;
    }

    VIR_FREE(hostname);
    if (vm)
        virDomainObjUnlock(vm);
    if (event)
        libxlDomainEventQueue(driver, event);
    libxlDriverUnlock(driver);
    return dom;
}

static int
libxlDomainMigrateConfirm3(virDomainPtr domain,
                            const char *cookiein ATTRIBUTE_UNUSED,
                            int cookieinlen ATTRIBUTE_UNUSED,
                            unsigned long flags,
                            int cancelled)
{
    libxlDriverPrivatePtr driver = domain->conn->privateData;
    virDomainObjPtr vm;
    libxlDomainObjPrivatePtr priv;
    virDomainEventPtr event = NULL;
    int ret = -1;

    virCheckFlags(LIBXL_MIGRATION_FLAGS, -1);

    libxlDriverLock(driver);
    vm = virDomainFindByUUID(&driver->domains, domain->uuid);
    if (!vm) {
        char uuidstr[VIR_UUID_STRING_BUFLEN];
        virUUIDFormat(domain->uuid, uuidstr);
        libxlError(VIR_ERR_NO_DOMAIN,
                   _("no domain with matching uuid '%s'"), uuidstr);
        goto cleanup;
    }

    if (cancelled) {
        priv = vm->privateData;
        libxlError(VIR_ERR_INTERNAL_ERROR,
                   _("migration failed, try to resume on our end"));
        if (!libxl_domain_resume(&priv->ctx, vm->def->id)) {
            ret = 0;
        } else {
            VIR_DEBUG("Failed to resume domain '%d' with libxenlight",
                      vm->def->id);
            virDomainObjSetState(vm, VIR_DOMAIN_PAUSED, VIR_DOMAIN_PAUSED_MIGRATION);
            event = virDomainEventNewFromObj(vm, VIR_DOMAIN_EVENT_SUSPENDED,
                                             VIR_DOMAIN_EVENT_SUSPENDED_MIGRATED);
            if (virDomainSaveStatus(driver->caps, driver->stateDir, vm) < 0)
                goto cleanup;
        }

        goto cleanup;
    }

    if (libxlVmReap(driver, vm, 1, VIR_DOMAIN_SHUTOFF_SAVED)) {
        libxlError(VIR_ERR_INTERNAL_ERROR,
                   _("Failed to destroy domain '%d'"), vm->def->id);
        goto cleanup;
    }

    event = virDomainEventNewFromObj(vm, VIR_DOMAIN_EVENT_STOPPED,
                                     VIR_DOMAIN_EVENT_STOPPED_SAVED);

    if (flags & VIR_MIGRATE_UNDEFINE_SOURCE)
        virDomainDeleteConfig(driver->configDir, driver->autostartDir, vm);

    if ( libxlMigrationJobFinish(driver, vm) == 0 ) {
        vm = NULL;
    } else if (!vm->persistent || (flags & VIR_MIGRATE_UNDEFINE_SOURCE)) {
        virDomainRemoveInactive(&driver->domains, vm);
        vm = NULL;
    }

    VIR_DEBUG("Migration successful.\n");
    ret = 0;

cleanup:
    if (vm)
        virDomainObjUnlock(vm);
    if (event)
        libxlDomainEventQueue(driver, event);
    libxlDriverUnlock(driver);
    return ret;
}

static virDriver libxlDriver = {
    .no = VIR_DRV_LIBXL,
    .name = "xenlight",
    .open = libxlOpen, /* 0.9.0 */
    .close = libxlClose, /* 0.9.0 */
    .supports_feature = libxlSupportsFeature, /* 0.9.11 */
    .type = libxlGetType, /* 0.9.0 */
    .version = libxlGetVersion, /* 0.9.0 */
    .getHostname = virGetHostname, /* 0.9.0 */
    .getMaxVcpus = libxlGetMaxVcpus, /* 0.9.0 */
    .nodeGetInfo = libxlNodeGetInfo, /* 0.9.0 */
    .getCapabilities = libxlGetCapabilities, /* 0.9.0 */
    .listDomains = libxlListDomains, /* 0.9.0 */
    .numOfDomains = libxlNumDomains, /* 0.9.0 */
    .domainCreateXML = libxlDomainCreateXML, /* 0.9.0 */
    .domainLookupByID = libxlDomainLookupByID, /* 0.9.0 */
    .domainLookupByUUID = libxlDomainLookupByUUID, /* 0.9.0 */
    .domainLookupByName = libxlDomainLookupByName, /* 0.9.0 */
    .domainSuspend = libxlDomainSuspend, /* 0.9.0 */
    .domainResume = libxlDomainResume, /* 0.9.0 */
    .domainShutdown = libxlDomainShutdown, /* 0.9.0 */
    .domainShutdownFlags = libxlDomainShutdownFlags, /* 0.9.10 */
    .domainReboot = libxlDomainReboot, /* 0.9.0 */
    .domainDestroy = libxlDomainDestroy, /* 0.9.0 */
    .domainDestroyFlags = libxlDomainDestroyFlags, /* 0.9.4 */
    .domainGetOSType = libxlDomainGetOSType, /* 0.9.0 */
    .domainGetMaxMemory = libxlDomainGetMaxMemory, /* 0.9.0 */
    .domainSetMaxMemory = libxlDomainSetMaxMemory, /* 0.9.2 */
    .domainSetMemory = libxlDomainSetMemory, /* 0.9.0 */
    .domainSetMemoryFlags = libxlDomainSetMemoryFlags, /* 0.9.0 */
    .domainGetInfo = libxlDomainGetInfo, /* 0.9.0 */
    .domainGetState = libxlDomainGetState, /* 0.9.2 */
    .domainSave = libxlDomainSave, /* 0.9.2 */
    .domainSaveFlags = libxlDomainSaveFlags, /* 0.9.4 */
    .domainRestore = libxlDomainRestore, /* 0.9.2 */
    .domainRestoreFlags = libxlDomainRestoreFlags, /* 0.9.4 */
    .domainCoreDump = libxlDomainCoreDump, /* 0.9.2 */
    .domainSetVcpus = libxlDomainSetVcpus, /* 0.9.0 */
    .domainSetVcpusFlags = libxlDomainSetVcpusFlags, /* 0.9.0 */
    .domainGetVcpusFlags = libxlDomainGetVcpusFlags, /* 0.9.0 */
    .domainPinVcpu = libxlDomainPinVcpu, /* 0.9.0 */
    .domainGetVcpus = libxlDomainGetVcpus, /* 0.9.0 */
    .domainGetXMLDesc = libxlDomainGetXMLDesc, /* 0.9.0 */
    .domainXMLFromNative = libxlDomainXMLFromNative, /* 0.9.0 */
    .domainXMLToNative = libxlDomainXMLToNative, /* 0.9.0 */
    .listDefinedDomains = libxlListDefinedDomains, /* 0.9.0 */
    .numOfDefinedDomains = libxlNumDefinedDomains, /* 0.9.0 */
    .domainCreate = libxlDomainCreate, /* 0.9.0 */
    .domainCreateWithFlags = libxlDomainCreateWithFlags, /* 0.9.0 */
    .domainDefineXML = libxlDomainDefineXML, /* 0.9.0 */
    .domainUndefine = libxlDomainUndefine, /* 0.9.0 */
    .domainUndefineFlags = libxlDomainUndefineFlags, /* 0.9.4 */
    .domainAttachDevice = libxlDomainAttachDevice, /* 0.9.2 */
    .domainAttachDeviceFlags = libxlDomainAttachDeviceFlags, /* 0.9.2 */
    .domainDetachDevice = libxlDomainDetachDevice,    /* 0.9.2 */
    .domainDetachDeviceFlags = libxlDomainDetachDeviceFlags, /* 0.9.2 */
    .domainUpdateDeviceFlags = libxlDomainUpdateDeviceFlags, /* 0.9.2 */
    .domainGetAutostart = libxlDomainGetAutostart, /* 0.9.0 */
    .domainSetAutostart = libxlDomainSetAutostart, /* 0.9.0 */
    .domainGetSchedulerType = libxlDomainGetSchedulerType, /* 0.9.0 */
    .domainGetSchedulerParameters = libxlDomainGetSchedulerParameters, /* 0.9.0 */
    .domainGetSchedulerParametersFlags = libxlDomainGetSchedulerParametersFlags, /* 0.9.2 */
    .domainSetSchedulerParameters = libxlDomainSetSchedulerParameters, /* 0.9.0 */
    .domainSetSchedulerParametersFlags = libxlDomainSetSchedulerParametersFlags, /* 0.9.2 */
    .domainMigrateBegin3 = libxlDomainMigrateBegin3, /* 0.9.11 */
    .domainMigratePrepare3 = libxlDomainMigratePrepare3, /* 0.9.11 */
    .domainMigratePerform3 = libxlDomainMigratePerform3, /* 0.9.11 */
    .domainMigrateFinish3 = libxlDomainMigrateFinish3, /* 0.9.11 */
    .domainMigrateConfirm3 = libxlDomainMigrateConfirm3, /* 0.9.11 */
    .nodeGetFreeMemory = libxlNodeGetFreeMemory, /* 0.9.0 */
    .domainEventRegister = libxlDomainEventRegister, /* 0.9.0 */
    .domainEventDeregister = libxlDomainEventDeregister, /* 0.9.0 */
    .domainManagedSave = libxlDomainManagedSave, /* 0.9.2 */
    .domainHasManagedSaveImage = libxlDomainHasManagedSaveImage, /* 0.9.2 */
    .domainManagedSaveRemove = libxlDomainManagedSaveRemove, /* 0.9.2 */
    .domainIsActive = libxlDomainIsActive, /* 0.9.0 */
    .domainIsPersistent = libxlDomainIsPersistent, /* 0.9.0 */
    .domainIsUpdated = libxlDomainIsUpdated, /* 0.9.0 */
//    .domainGetJobInfo = libxlDomainGetJobInfo, /* 0.9.11 */
//    .domainAbortJob = libxlDomainAbortJob, /* 0.9.11 */
    .domainEventRegisterAny = libxlDomainEventRegisterAny, /* 0.9.0 */
    .domainEventDeregisterAny = libxlDomainEventDeregisterAny, /* 0.9.0 */
    .isAlive = libxlIsAlive, /* 0.9.8 */
};

static virStateDriver libxlStateDriver = {
    .name = "LIBXL",
    .initialize = libxlStartup,
    .cleanup = libxlShutdown,
    .reload = libxlReload,
    .active = libxlActive,
};


int
libxlRegister(void)
{
    if (virRegisterDriver(&libxlDriver) < 0)
        return -1;
    if (virRegisterStateDriver(&libxlStateDriver) < 0)
        return -1;

    return 0;
}
