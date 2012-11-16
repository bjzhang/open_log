set breakpoint pending on

set logging on

#function in libvirt
#break evhook_fd_register
#commands
#silent
#printf "evhook_fd_register\n"
#where 3
#cont
#end
#
#break evhook_fd_deregister
#commands
#silent
#printf "evhook_fd_deregister\n"
#where 3
#cont
#end

#break util/event_poll.c:121
#commands
#silent
#printf "virEventPollAddHandle: watch<%d>, fd<%d>, cb<%p>, ff<%p>, opaque<%p>\n", watch, fd, cb, ff, opaque
#cont
#end
#
#break util/event_poll.c:188
#commands
#silent
#printf "virEventPollRemoveHandle: watch<%d>\n", watch
#cont
#end
#
#break virEventPollCleanupHandles
#commands
#silent
#printf "virEventPollCleanupHandles"
#cont
#end
#
#break util/event_poll.c:471
#commands
#silent
#printf "virEventPollDispatchHandles: skip the delete watch\n"
#cont
#end
#
#break util/event_poll.c:485
#commands
#silent
#printf "virEventPollDispatchHandles: call cb\n"
#cont
#end
#
#function in xenlight 
break libxl_osevent_occurred_timeout
commands
silent
printf "libxl_osevent_occurred_timeout: func<%p>, infinite<%d>\n", ((libxl__ev_time*)for_libxl)->func, ((libxl__ev_time*)for_libxl)->infinite
cont
end

#break libxl__ev_time_register_rel
#commands
#silent
#printf "libxl__ev_time_register_rel: ev_time=%p register ms=%d\n", ev, milliseconds
#cont
#end
#
#break libxl__ev_time_modify_rel
#commands
#silent
#printf "libxl__ev_time_modify_rel\n"
#cont
#end
#
#break time_insert_finite
#commands
#silent
#printf "time_insert_finite\n"
#cont
#end
#
#break time_register_finite
#commands
#silent
#printf "time_register_finite\n"
#cont
#end
#
#break libxl__ev_time_modify_abs
#commands
#silent
#printf "libxl__ev_time_modify_abs\n"
#cont
#end
#
##break virEventPollAddHandle
##commands
##cont
##end
##
##break virEventPollDispatchHandles
##commands
##cont
##end
##
#
#break libxl__ev_fd_register
#commands
##silent
#printf "libxl__ev_fd_register\n"
#where 3
#cont
#end
#
break libxl__ev_fd_deregister
commands
silent
printf "libxl__ev_fd_deregister: fd<%d>\n", ev->fd
#where 3
cont
end

break libxl_osevent_occurred_fd
commands
silent
printf "libxl_osevent_occurred_fd: fd<%d>, ev->fd<%d>, revents<%d>, ev->events<%d>\n", fd, ((libxl__ev_fd*)for_libxl)->fd, revents, ((libxl__ev_fd*)for_libxl)->events
cont
end

cont

