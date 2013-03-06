set breakpoint pending on

set logging on

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

break libxl__exec
commands
silent
shell date +%m%d_%M%H%S_%N
print "libxl__exec"
cont
end


break libxl__ao_complete
commands
silent
shell date +%m%d_%M%H%S_%N
print "libxl__ao_complete"
cont
end


break libxl__event_occurred
commands
silent
shell date +%m%d_%M%H%S_%N
print "libxl__event_occurred"
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
#xc_domain_save

