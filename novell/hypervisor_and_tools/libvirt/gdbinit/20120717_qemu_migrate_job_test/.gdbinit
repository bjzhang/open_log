set breakpoint pending on

set logging on


break virDomainObjSetState
commands
silent
printf "virDomainObjSetState: %u, %s, %s\n", dom, virDomainStateTypeToString(state), virDomainStateReasonToString(state, reason)
#where
cont
end

break qemuDomainMigrateBegin3
commands
silent
printf "qemuDomainMigrateBegin3\n"
cont
end

break qemuDomainMigratePrepare3
commands
silent
printf "qemuDomainMigratePrepare3\n"
cont
end

break qemuDomainMigratePerform3
commands
silent
printf "qemuDomainMigratePerform3\n"
cont
end

break qemuDomainMigrateFinish3
commands
silent
printf "qemuDomainMigrateFinish3\n"
cont
end

break qemuDomainMigrateConfirm3
commands
silent
printf "qemuDomainMigrateConfirm3\n"
cont
end

break qemudClose
commands
silent
printf "qemudClose\n"
#where
cont
end

break qemuDriverCloseCallbackSet
commands
silent
printf "qemuDriverCloseCallbackSet\n"
#where
cont
end

break qemuMigrationWaitForCompletion
commands
silent
printf "qemuMigrationWaitForCompletion\n"
cont
end

break daemonShutdownHandler
commands
silent
printf "daemonShutdownHandler\n"
cont
end

break daemonReloadHandler
commands
silent
printf "daemonReloadHandler\n"
cont
end

break qemuMigrationJobStart
commands
silent
printf "qemuMigrationJobStart: %s\n", qemuDomainAsyncJobTypeToString(job)
cont
end

break qemu/qemu_domain.c:788
commands
silent
printf "qemuDomainObjBeginJobInternal wait async cond: async job: %s, job mask: %x, job: %s\n", qemuDomainAsyncJobTypeToString(priv->job.asyncJob), priv->job.mask, qemuDomainJobTypeToString(job)
cont
end

break qemu/qemu_domain.c:793
commands
silent
printf "qemuDomainObjBeginJobInternal wait cond: job active: %x, job: %s\n", priv->job.active, qemuDomainJobTypeToString(job)
cont
end

#break qemuProcessStart

cont
