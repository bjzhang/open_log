set breakpoint pending on

set logging on

#function in libvirt libxl driver
break libxlDoDomainSave
commands
silent
print "libxlDoDomainSave"
shell date +%m%d_%M%H%S_%N
cont
end

break libxlSuspendCallback
commands
silent
print "libxlSuspendCallback"
shell date +%m%d_%M%H%S_%N
cont
end

break libxl_domain_suspend
commands
silent
print "libxl_domain_suspend"
shell date +%m%d_%M%H%S_%N
#set ao_how=0
cont
end

break virDomainEventNewFromObj
commands
silent
print "virDomainEventNewFromObj"
shell date +%m%d_%M%H%S_%N
cont
end

break libxlEventHandler
commands
silent
print "libxlEventHandler"
shell date +%m%d_%M%H%S_%N
where
cont
end

#function in xenlight
break libxl__domain_suspend
commands
silent
print "libxl__domain_suspend"
shell date +%m%d_%M%H%S_%N
cont
end

break libxl__xc_domain_save
commands
silent
print "libxl__xc_domain_save"
shell date +%m%d_%M%H%S_%N
cont
end

#break in libxl__xc_domain_save
#break libxl__srm_callout_received_save
#commands
#silent
#print "libxl__srm_callout_received_save"
#shell date +%m%d_%M%H%S_%N
#where 2
#cont
#end

break _libxl_save_msgs_callout.c:108
commands
silent
print "_libxl_save_msgs_callout.c:108:log"
shell date +%m%d_%M%H%S_%N
cont
end

break _libxl_save_msgs_callout.c:122
commands
silent
print "_libxl_save_msgs_callout.c:122:progress"
shell date +%m%d_%M%H%S_%N
cont
end

break _libxl_save_msgs_callout.c:131
commands
silent
print "_libxl_save_msgs_callout.c:131:suspend"
shell date +%m%d_%M%H%S_%N
cont
end

break _libxl_save_msgs_callout.c:141
commands
silent
print "_libxl_save_msgs_callout.c:141:postcopy"
shell date +%m%d_%M%H%S_%N
cont
end

break _libxl_save_msgs_callout.c:150
commands
silent
print "_libxl_save_msgs_callout.c:150:checkpoint"
shell date +%m%d_%M%H%S_%N
cont
end

break _libxl_save_msgs_callout.c:162
commands
silent
print "_libxl_save_msgs_callout.c:162:switch_qemu_logdirty"
shell date +%m%d_%M%H%S_%N
cont
end

break _libxl_save_msgs_callout.c:173
commands
silent
print "_libxl_save_msgs_callout.c:173:complete"
shell date +%m%d_%M%H%S_%N
cont
end

break libxl__srm_callout_callback_complete
command
silent
print "libxl__srm_callout_callback_complete"
shell date +%m%d_%M%H%S_%N
where 3
cont
end

break libxl__srm_callout_sendreply
commands
silent
print "libxl__srm_callout_sendreply"
shell date +%m%d_%M%H%S_%N
cont
end

break libxl__xc_domain_save_done
commands
silent
print "libxl__xc_domain_save_done"
shell date +%m%d_%M%H%S_%N
cont
end

break libxl__domain_suspend_device_model
commands
silent
print "libxl__domain_suspend_device_model"
shell date +%m%d_%M%H%S_%N
cont
end

break libxl__domain_save_device_model
commands
silent
print "libxl__domain_save_device_model"
shell date +%m%d_%M%H%S_%N
cont
end
##break in libxl__xc_domain_save end

break libxl__toolstack_save
commands
silent
print "libxl__toolstack_save"
shell date +%m%d_%M%H%S_%N
cont
end

break run_helper
commands
silent
print "run_helper"
shell date +%m%d_%M%H%S_%N
#print "enable gdb reverse debug"
#target record
cont
end

#in function run_helper
break libxl__exec
commands
silent
print "libxl__exec"
shell date +%m%d_%M%H%S_%N
cont
end

break libxl__carefd_close
commands
silent
print "libxl__carefd_close"
shell date +%m%d_%M%H%S_%N
cont
end

break libxl__ev_fd_register
commands
silent
print "libxl__ev_fd_register"
shell date +%m%d_%M%H%S_%N
cont
end

break helper_exited
commands
silent
print "helper_exited"
shell date +%m%d_%M%H%S_%N
cont
end

#function run_helper end

break libxl__ao_complete
commands
silent
where 2
print "libxl__ao_complete"
shell date +%m%d_%M%H%S_%N
print egc->gc->owner->event_hooks
print egc->gc->owner->occurred
print egc->gc->owner->pollers_event
cont
end

break domain_suspend_cb
commands
silent
print "domain_suspend_cb"
shell date +%m%d_%M%H%S_%N
cont
end

break libxl__domain_suspend_common_callback
commands
silent
print "libxl__domain_suspend_common_callback"
shell date +%m%d_%M%H%S_%N
where 3
#record stop
cont
end

break libxl__toolstack_save
commands
silent
print "libxl__toolstack_save"
shell date +%m%d_%M%H%S_%N
cont
end

break libxl__event_occurred
commands
silent
print "libxl__event_occurred"
shell date +%m%d_%M%H%S_%N
print egc->gc->owner->event_hooks
print egc->gc->owner->occurred
print egc->gc->owner->pollers_event
print event
print *event
where 2
cont
end

break libxl__poller_wakeup
commands
silent
print "libxl__poller_wakeup"
shell date +%m%d_%M%H%S_%N
where 2
cont
end

##break point for libxl_save_helper
break startup
commands
silent
print "startup"
shell date +%m%d_%M%H%S_%N
cont
end

break xc_domain_save
commands
silent
print "xc_domain_save"
shell date +%m%d_%M%H%S_%N
cont
end

break toolstack_save_cb
commands
silent
print "toolstack_save_cb"
shell date +%m%d_%M%H%S_%N
cont
end

break complete
commands
silent
print "complete"
shell date +%m%d_%M%H%S_%N
cont
end

break helper_stub_complete
commands
silent
print "helper_stub_complete"
shell date +%m%d_%M%H%S_%N
cont
end
##break point for libxl_save_helper end

#break eventloop_iteration
#commands
#silent
#print "eventloop_iteration"
#shell date +%m%d_%M%H%S_%N
#cont
#end

break libxl_event.c:995
commands
silent
print "tools/libxl/libxl_event.c:995"
shell date +%m%d_%M%H%S_%N
print efd
print efd->func
cont
end

break libxl_event.c:1027
commands
silent
print "libxl/libxl_event.c:1027"
shell date +%m%d_%M%H%S_%N
print etime
print etime->func
cont
end

break libxl__ao_complete_check_progress_reports
commands
silent
print "libxl__ao_complete_check_progress_reports"
shell date +%m%d_%M%H%S_%N
where
cont
end

#about pipe wakeup
#break afterpoll_check_fd
#commands
#silent
#print "afterpoll_check_fd"
#shell date +%m%d_%M%H%S_%N
#where 2
#cont
#end
#
break libxl__self_pipe_eatall
commands
silent
print "libxl__self_pipe_eatall"
shell date +%m%d_%M%H%S_%N
where 2
cont
end

break libxl__fork_selfpipe_woken
commands
silent
print "libxl__fork_selfpipe_woken"
shell date +%m%d_%M%H%S_%N
where 2
cont
end

#
break libxl__sigchld_installhandler
commands
silent
print "libxl__sigchld_installhandler"
shell date +%m%d_%M%H%S_%N
where 2
cont
end

#break sigchld_handler
#commands
#silent
#print "sigchld_handler"
#shell date +%m%d_%M%H%S_%N
##where 2
#cont
#end

cont

