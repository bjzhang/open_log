set breakpoint pending on

set logging on

break libxl__domain_suspend
commands
silent
printf "libxl__domain_suspend\n"
where 2
cont
end

break libxl__xc_domain_save
commands
silent
printf "libxl__xc_domain_save\n"
where 2
cont
end

#in libxl__xc_domain_save
break run_helper
commands
silent
printf "run_helper\n"
where 2
cont
end

break libxl__xc_domain_save_done
commands
silent
printf "libxl__xc_domain_save_done\n"
where 2
cont
end

#in libxl__xc_domain_save_done
break libxl__domain_suspend_device_model
commands
silent
printf "libxl__domain_suspend_device_model\n"
where 2
cont
end

break libxl__domain_save_device_model
commands
silent
printf "libxl__domain_save_device_model\n"
where 2
cont
end

#out libxl__xc_domain_save_done
#out libxl__xc_domain_save
break domain_suspend_done
commands
silent
printf "domain_suspend_done\n"
where 2
cont
end

break domain_suspend_cb
commands
silent
printf "domain_suspend_cb\n"
where 2
cont
end

break libxl__ev_fd_register
commands
silent
printf "libxl__ev_fd_register\n"
where 2
cont
end

#break helper_stdout_readable
#commands
#silent
#printf "helper_stdout_readable\n"
#where 2
#cont
#end

break libxl__ao_inprogress
commands
silent
printf "libxl__ao_inprogress\n"
where 2
cont
end

run

