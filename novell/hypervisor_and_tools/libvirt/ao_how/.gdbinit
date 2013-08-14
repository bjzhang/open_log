set breakpoint pending on

set logging on

break libxl__ao_complete_check_progress_reports
commands
silent
shell date +%H%M%S_%N
printf "libxl__ao_complete_check_progress_reports\n"
#where
#cont
end

break domain_suspend_cb
commands
silent
shell date +%H%M%S_%N
printf "domain_suspend_cb\n"
where
cont
end


break libxl__domain_suspend_common_callback
commands
silent
shell date +%H%M%S_%N
printf "libxl__domain_suspend_common_callback\n"
where
cont
end

break xc_evtchn_notify
commands
silent
shell date +%H%M%S_%N
printf "xc_evtchn_notify\n"
where
cont
end

break xc_await_suspend
commands
silent
shell date +%H%M%S_%N
printf "xc_await_suspend\n"
where
cont
end

break xc_domain_shutdown
commands
silent
shell date +%H%M%S_%N
printf "xc_domain_shutdown\n"
where
cont
end

break libxl__domain_pvcontrol_write
commands
silent
shell date +%H%M%S_%N
printf "libxl__domain_pvcontrol_write\n"
where
cont
end

break libxl__domain_pvcontrol_read
commands
silent
shell date +%H%M%S_%N
printf "libxl__domain_pvcontrol_read\n"
where
cont
end

break libxl__domain_suspend_device_model
commands
silent
shell date +%H%M%S_%N
printf "libxl__domain_suspend_device_model\n"
where
cont
end



break libxl__xc_domain_save 
commands
silent
shell date +%H%M%S_%N
printf "libxl__xc_domain_save \n"
where
cont
end

break libxl__toolstack_save
commands
silent
shell date +%H%M%S_%N
printf "libxl__toolstack_save\n"
where
cont
end

break libxl__srm_callout_received_save;
commands
silent
shell date +%H%M%S_%N
printf "libxl__srm_callout_received_save;\n"
where
cont
end

break libxl__xc_domain_save_done;
commands
silent
shell date +%H%M%S_%N
printf "libxl__xc_domain_save_done;\n"
where
cont
end



break run_helper
commands
silent
shell date +%H%M%S_%N
printf "run_helper\n"
where
cont
end

break libxl__ev_fd_register
commands
silent
shell date +%H%M%S_%N
printf "libxl__ev_fd_register\n"
where
cont
end

#break helper_stdout_readable
#commands
#silent
shell date +%H%M%S_%N
#printf "helper_stdout_readable\n"
#where
#cont
#end

break recv_callback
commands
silent
shell date +%H%M%S_%N
printf "recv_callback\n"
where
cont
end



break libxl__srm_callout_callback_complete
commands
silent
shell date +%H%M%S_%N
printf "libxl__srm_callout_callback_complete\n"
where
cont
end

break libxl__srm_callout_sendreply
commands
silent
shell date +%H%M%S_%N
printf "libxl__srm_callout_sendreply\n"
where
cont
end



break helper_exited
commands
silent
shell date +%H%M%S_%N
printf "helper_exited\n"
where
cont
end

#datecopier
break datacopier_callback
commands
silent
shell date +%H%M%S_%N
printf "datacopier_callback\n"
where
cont
end

break save_device_model_datacopier_done
commands
silent
shell date +%H%M%S_%N
printf "save_device_model_datacopier_done\n"
where
cont
end


break libxl__fork_selfpipe_woken
commands
silent
shell date +%H%M%S_%N
printf "libxl__fork_selfpipe_woken\n"
where
cont
end

#break eventloop_iteration
#commands
#silent
#shell date +%H%M%S_%N
#printf "eventloop_iteration\n"
#where
##cont
#end


#break libxl_event_wait

#break sigchld_handler
#commands
#silent
#shell date +%H%M%S_%N
#printf "sigchld_handler\r"
#where
##cont
#end

break libxl__self_pipe_wakeup
commands
silent
shell date +%H%M%S_%N
printf "libxl__self_pipe_wakeup\r"
where
cont
end

break libxl_ctx_free
commands
silent
shell date +%H%M%S_%N
printf "libxl_ctx_free\r"
where
cont
end

#####libvirt
#break libxlFDEventCallback
#commands
#silent
#shell date +%H%M%S_%N
#printf "libxlFDEventCallback\n"
#where
#cont
#end

#TBD
#break libxl/libxl_driver.c:2425
#commands
#silent
#shell date +%H%M%S_%N
#printf "after libxl_event_check\n"
#end

break libxl_sigchld_callback
commands
#silent
shell date +%H%M%S_%N
printf "libxl_sigchld_callback\n"
where
#cont
end

cont

