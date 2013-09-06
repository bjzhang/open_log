set breakpoint pending on

set logging on

break libxl__ao_complete_check_progress_reports
commands
silent
shell date +%H%M%S_%N
printf "libxl__ao_complete_check_progress_reports\n"
where 3
cont
end

break domain_suspend_cb
commands
silent
shell date +%H%M%S_%N
printf "domain_suspend_cb\n"
where 3
cont
end


break libxl__domain_suspend_common_callback
commands
silent
shell date +%H%M%S_%N
printf "libxl__domain_suspend_common_callback\n"
where 3
cont
end

break xc_evtchn_notify
commands
silent
shell date +%H%M%S_%N
printf "xc_evtchn_notify\n"
where 3
cont
end

break xc_await_suspend
commands
silent
shell date +%H%M%S_%N
printf "xc_await_suspend\n"
where 3
cont
end

break xc_domain_shutdown
commands
silent
shell date +%H%M%S_%N
printf "xc_domain_shutdown\n"
where 3
cont
end

break libxl__domain_pvcontrol_write
commands
silent
shell date +%H%M%S_%N
printf "libxl__domain_pvcontrol_write\n"
where 3
cont
end

break libxl__domain_pvcontrol_read
commands
silent
shell date +%H%M%S_%N
printf "libxl__domain_pvcontrol_read\n"
where 3
cont
end

break libxl__domain_suspend_device_model
commands
silent
shell date +%H%M%S_%N
printf "libxl__domain_suspend_device_model\n"
where 3
cont
end



break libxl__xc_domain_save 
commands
silent
shell date +%H%M%S_%N
printf "libxl__xc_domain_save \n"
where 3
cont
end

break libxl__toolstack_save
commands
silent
shell date +%H%M%S_%N
printf "libxl__toolstack_save\n"
where 3
cont
end

break libxl__srm_callout_received_save;
commands
silent
shell date +%H%M%S_%N
printf "libxl__srm_callout_received_save;\n"
where 3
cont
end

break libxl__xc_domain_save_done;
commands
silent
shell date +%H%M%S_%N
printf "libxl__xc_domain_save_done;\n"
where 3
cont
end



break run_helper
commands
silent
shell date +%H%M%S_%N
printf "run_helper\n"
where 3
cont
end

break libxl__ev_fd_register
commands
silent
shell date +%H%M%S_%N
printf "libxl__ev_fd_register\n"
where 3
cont
end

#break helper_stdout_readable
#commands
#silent
#shell date +%H%M%S_%N
#printf "helper_stdout_readable\n"
#where 3
#cont
#end

break recv_callback
commands
silent
shell date +%H%M%S_%N
printf "recv_callback\n"
where 3
cont
end



break libxl__srm_callout_callback_complete
commands
silent
shell date +%H%M%S_%N
printf "libxl__srm_callout_callback_complete\n"
where 3
cont
end

break libxl__srm_callout_sendreply
commands
silent
shell date +%H%M%S_%N
printf "libxl__srm_callout_sendreply\n"
where 3
cont
end



break helper_exited
commands
silent
shell date +%H%M%S_%N
printf "helper_exited\n"
where 3
cont
end

#datecopier
break datacopier_callback
commands
silent
shell date +%H%M%S_%N
printf "datacopier_callback\n"
where 3
cont
end

break save_device_model_datacopier_done
commands
silent
shell date +%H%M%S_%N
printf "save_device_model_datacopier_done\n"
where 3
cont
end


break libxl__fork_selfpipe_woken
commands
silent
shell date +%H%M%S_%N
printf "libxl__fork_selfpipe_woken\n"
where 3
cont
end

#break eventloop_iteration
#commands
#silent
#shell date +%H%M%S_%N
#printf "eventloop_iteration\n"
#where 3
##cont
#end


#break libxl_event_wait

#break sigchld_handler
#commands
#silent
#shell date +%H%M%S_%N
#printf "sigchld_handler\n"
#where 3
##cont
#end

break libxl__self_pipe_wakeup
commands
silent
shell date +%H%M%S_%N
printf "libxl__self_pipe_wakeup\n"
where 3
cont
end

break libxl_ctx_free
commands
silent
shell date +%H%M%S_%N
printf "libxl_ctx_free\n"
where 3
cont
end

break libxl__evdisable_domain_death
commands
silent
shell date +%H%M%S_%N
printf "libxl__evdisable_domain_death\n"
where 3
cont
end

break libxl_domain_destroy
commands
silent
shell date +%H%M%S_%N
printf "libxl_domain_destroy\n"
where 3
cont
end

break domain_destroy_cb
commands
silent
shell date +%H%M%S_%N
printf "domain_destroy_cb\n"
where 3
cont
end

break domain_destroy_callback
commands
silent
shell date +%H%M%S_%N
printf "domain_destroy_callback\n"
where 3
cont
end

break destroy_finish_check
commands
silent
shell date +%H%M%S_%N
printf "destroy_finish_check\n"
where 3
cont
end

break libxl_domain_info
commands
silent
shell date +%H%M%S_%N
printf "libxl_domain_info\n"
where 3
cont
end

break libxl__destroy_device_model
commands
silent
shell date +%H%M%S_%N
printf "libxl__destroy_device_model\n"
where 3
cont
end

break devices_destroy_cb
commands
silent
shell date +%H%M%S_%N
printf "devices_destroy_cb\n"
where 3
cont
end

break libxl__userdata_destroyall
commands
silent
shell date +%H%M%S_%N
printf "libxl__userdata_destroyall\n"
where 3
cont
end

break xc_domain_destroy
commands
silent
shell date +%H%M%S_%N
printf "xc_domain_destroy\n"
where 3
cont
end

break libxl__devices_destroy
commands
silent
shell date +%H%M%S_%N
printf "libxl__devices_destroy\n"
where 3
cont
end

break devices_remove_callback
commands
silent
shell date +%H%M%S_%N
printf "devices_remove_callback\n"
where 3
cont
end

break libxl__device_destroy
commands
silent
shell date +%H%M%S_%N
printf "libxl__device_destroy\n"
where 3
cont
end

break libxl__initiate_device_remove
commands
silent
shell date +%H%M%S_%N
printf "libxl__initiate_device_remove\n"
where 3
cont
end

break libxl__ev_devstate_wait
commands
silent
shell date +%H%M%S_%N
printf "libxl__ev_devstate_wait\n"
where 3
cont
end

break libxl__device_destroy_tapdisk
commands
silent
shell date +%H%M%S_%N
printf "libxl__device_destroy_tapdisk\n"
where 3
cont
end

break childproc_reaped
commands
silent
shell date +%H%M%S_%N
printf "childproc_reaped\n"
where 3
cont
end

break libxl__ao_occurred
commands
silent
shell date +%H%M%S_%N
printf "libxl__ao_occurred\n"
where 3
cont
end


#####libvirt
#break libxlFDEventCallback
#commands
#silent
#shell date +%H%M%S_%N
#printf "libxlFDEventCallback\n"
#where 3
#cont
#end

#TBD
#break libxl/libxl_driver.c:2425
#commands
#silent
#shell date +%H%M%S_%N
#printf "after libxl_event_check\n"
#end

#break libxl_sigchld_callback
#commands
#silent
#shell date +%H%M%S_%N
#printf "libxl_sigchld_callback\n"
#where 3
#cont
#end

break libxlEventHandler
commands
silent
shell date +%H%M%S_%N
printf "libxlEventHandler\n"
where 3
cont
end

break libxl_fork_replacement
commands
silent
shell date +%H%M%S_%N
printf "libxl_fork_replacement\n"
where 3
cont
end

break ao_how_callback
commands
silent
shell date +%H%M%S_%N
printf "ao_how_callback\n"
where 3
cont
end

break libxlVmStart
commands
silent
shell date +%H%M%S_%N
printf "libxlVmStart\n"
where 3
cont
end

cont

