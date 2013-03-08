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
shell date +%m%d_%M%H%S_%N
print "libxlSuspendCallback"
cont
end

break libxl_domain_suspend
commands
silent
shell date +%m%d_%M%H%S_%N
print "libxl_domain_suspend"
#set ao_how=0
cont
end

break virDomainEventNewFromObj
commands
silent
shell date +%m%d_%M%H%S_%N
print "virDomainEventNewFromObj"
cont
end

#function in xenlight
break libxl__domain_suspend
commands
silent
shell date +%m%d_%M%H%S_%N
print "libxl__domain_suspend"
cont
end

break libxl__xc_domain_save
commands
silent
shell date +%m%d_%M%H%S_%N
print "libxl__xc_domain_save"
cont
end

break libxl__toolstack_save
commands
silent
shell date +%m%d_%M%H%S_%N
print "libxl__toolstack_save"
cont
end

break run_helper
commands
silent
shell date +%m%d_%M%H%S_%N
print "run_helper"
cont
end

#in function run_helper
break libxl__exec
commands
silent
shell date +%m%d_%M%H%S_%N
print "libxl__exec"
cont
end

break libxl__carefd_close
commands
silent
shell date +%m%d_%M%H%S_%N
print "libxl__carefd_close"
cont
end

break libxl__ev_fd_register
commands
silent
shell date +%m%d_%M%H%S_%N
print "libxl__ev_fd_register"
cont
end

break helper_exited
commands
silent
shell date +%m%d_%M%H%S_%N
print "helper_exited"
cont
end

#function run_helper end

break libxl__ao_complete
commands
silent
where 2
shell date +%m%d_%M%H%S_%N
print "libxl__ao_complete"
print egc->gc->owner->event_hooks
print egc->gc->owner->occurred
print egc->gc->owner->pollers_event
cont
end

break domain_suspend_cb
commands
silent
shell date +%m%d_%M%H%S_%N
print "domain_suspend_cb"
cont
end

break libxl__domain_suspend_common_callback
commands
silent
shell date +%m%d_%M%H%S_%N
print "libxl__domain_suspend_common_callback"
cont
end

break libxl__toolstack_save
commands
silent
shell date +%m%d_%M%H%S_%N
print "libxl__toolstack_save"
cont
end

break libxl__event_occurred
commands
silent
where 2
shell date +%m%d_%M%H%S_%N
print "libxl__event_occurred"
print egc->gc->owner->event_hooks
print egc->gc->owner->occurred
print egc->gc->owner->pollers_event
print event
cont
end

break libxl__poller_wakeup
commands
silent
shell date +%m%d_%M%H%S_%N
print "libxl__event_occurred"
cont
end

##break point for libxl_save_helper
break startup
commands
silent
shell date +%m%d_%M%H%S_%N
print "startup"
cont
end

break xc_domain_save
commands
silent
shell date +%m%d_%M%H%S_%N
print "xc_domain_save"
cont
end

break toolstack_save_cb
commands
silent
shell date +%m%d_%M%H%S_%N
print "toolstack_save_cb"
cont
end

break complete
commands
silent
shell date +%m%d_%M%H%S_%N
print "complete"
cont
end

break helper_stub_complete
commands
silent
shell date +%m%d_%M%H%S_%N
print "helper_stub_complete"
cont
end
##break point for libxl_save_helper end

cont

