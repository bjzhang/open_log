set breakpoint pending on

set logging on

break libxlTimerCallback
commands
silent
printf "libxlTimerCallback: info<%p>\n", timer_info
cont
end

break libxlFDEventCallback
commands
silent
printf "libxlFDEventCallback: info<%p>\n", fd_info
cont
end

#break libxl_driver.c:152
#commands
#silent
#print info
#end
#
#break libxl_driver.c:279
#commands
#silent
#print info
#end

break virObjectRef
commands
silent
printf "virObjectRef<%p>\n", anyobj
where 2
cont
end

break virObjectUnref
commands
silent
printf "virObjectUnref<%p>\n", anyobj
where 2
cont
end

#break util/event_poll.c:450

break virEventAddTimeout
commands
cont
end

break libxlDomainObjPrivateFree
commands
silent
print "libxlDomainObjPrivateFree\n"
cont
end

break libxlEventInfoFree
commands
silent
print "libxlEventInfoFree\n"
cont
end

break libxlFreeEventInfo
commands
silent
print "libxlFreeEventInfo\n"
cont
end

break libxlTimeoutDeregisterEventHook
commands
silent
print "libxlTimeoutDeregisterEventHook\n"
cont
end

break libxlFDDeregisterEventHook
commands
silent
print "libxlFDDeregisterEventHook\n"
cont
end

cont

