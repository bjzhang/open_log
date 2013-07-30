set breakpoint pending on

set logging on

break libxl__ao_complete_check_progress_reports
commands
silent
printf "libxl__ao_complete_check_progress_reports\n"
where 4
cont
end

break domain_suspend_cb
commands
silent
printf "domain_suspend_cb\n"
where 4
cont
end


break libxl__domain_suspend_common_callback
commands
silent
printf "libxl__domain_suspend_common_callback\n"
where 3
cont
end

break xc_evtchn_notify
commands
silent
printf "xc_evtchn_notify\n"
where 3
cont
end

break xc_await_suspend
commands
silent
printf "xc_await_suspend\n"
where 3
cont
end

break xc_domain_shutdown
commands
silent
printf "xc_domain_shutdown\n"
where 3
cont
end

break libxl__domain_pvcontrol_write
commands
silent
printf "libxl__domain_pvcontrol_write\n"
where 3
cont
end

break libxl__domain_pvcontrol_read
commands
silent
printf "libxl__domain_pvcontrol_read\n"
where 3
cont
end

break libxl__domain_suspend_device_model
commands
silent
printf "libxl__domain_suspend_device_model\n"
where 3
cont
end



break libxl__xc_domain_save 
commands
silent
printf "libxl__xc_domain_save \n"
where 3
cont
end

break libxl__toolstack_save
commands
silent
printf "libxl__toolstack_save\n"
where 3
cont
end

break libxl__srm_callout_received_save;
commands
silent
printf "libxl__srm_callout_received_save;\n"
where 3
cont
end

break libxl__xc_domain_save_done;
commands
silent
printf "libxl__xc_domain_save_done;\n"
where 3
cont
end



break run_helper
commands
silent
printf "run_helper\n"
where 3
cont
end

break libxl__ev_fd_register
commands
silent
printf "libxl__ev_fd_register\n"
where 3
cont
end

#break helper_stdout_readable
#commands
#silent
#printf "helper_stdout_readable\n"
#where 3
#cont
#end

break recv_callback
commands
silent
printf "recv_callback\n"
where 3
cont
end



break libxl__srm_callout_callback_complete
commands
silent
printf "libxl__srm_callout_callback_complete\n"
where 3
cont
end

break libxl__srm_callout_sendreply
commands
silent
printf "libxl__srm_callout_sendreply\n"
where 3
cont
end



break helper_exited
commands
silent
printf "helper_exited\n"
where 3
cont
end

#datecopier
break datacopier_callback
commands
silent
printf "datacopier_callback\n"
where 3
cont
end

break save_device_model_datacopier_done
commands
silent
printf "save_device_model_datacopier_done\n"
where 3
cont
end


break libxl__fork_selfpipe_woken
commands
silent
printf "libxl__fork_selfpipe_woken\n"
where 3
cont
end


cont

