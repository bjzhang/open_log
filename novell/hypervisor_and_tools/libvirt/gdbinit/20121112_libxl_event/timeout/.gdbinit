set breakpoint pending on

set logging on

break libxl_osevent_occurred_timeout
commands
silent
printf "libxl_osevent_occurred_timeout\n"
p *(libxl__ev_time*)for_libxl
cont
end

break libxl__ev_time_register_rel
commands
silent
printf "libxl__ev_time_register_rel: ev_time=%p register ms=%d\n", ev, milliseconds
cont
end

break libxl__ev_time_modify_rel
commands
silent
printf "libxl__ev_time_modify_rel\n"
cont
end

break time_insert_finite
commands
silent
printf "time_insert_finite\n"
cont
end

break time_register_finite
commands
silent
printf "time_register_finite\n"
cont
end

break libxl__ev_time_modify_abs
commands
silent
printf "libxl__ev_time_modify_abs\n"
cont
end

#break virEventPollAddHandle
#commands
#cont
#end
#
#break virEventPollDispatchHandles
#commands
#cont
#end
#
cont

#frame 3
#p *(libxl__ev_fd*)for_libxl

