set breakpoint pending on

set logging on

break libxlVmStart
commands
silent
printf "libxlVmStart\n"
cont
end

break libxl_domain_config_init
commands
silent
printf "libxl_domain_config_init\n"
cont
end

break libxlBuildDomainConfig
commands
silent
printf "libxlBuildDomainConfig\n"
cont
end

#break libxlFreeMem
#commands
#silent
#printf "libxlFreeMem\n"
#cont
#end

#sub function in libxlFreeMem
break libxl_domain_need_memory
commands
silent
printf "libxl_domain_need_memory\n"
cont
end

break libxl_get_free_memory
commands
silent
printf "libxl_get_free_memory\n"
cont
end

break libxl_set_memory_target
commands
silent
printf "libxl_set_memory_target\n"
cont
end

break libxl_wait_for_free_memory
commands
silent
printf "libxl_wait_for_free_memory\n"
cont
end

break libxl_wait_for_memory_target
commands
silent
printf "libxl_wait_for_memory_target\n"
cont
end

#sub function in libxlFreeMem end

break libxl_domain_create_new
commands
silent
printf "libxl_domain_create_new\n"
cont
end

#sub function in libxl_domain_create_new
break libxl__domain_firmware
commands
silent
printf "libxl__domain_firmware\n"
cont
end

break xc_hvm_build_target_mem
commands
silent
printf "xc_hvm_build_target_mem\n"
cont
end

#break hvm_build_set_params
#commands
#silent
#printf "hvm_build_set_params\n"
#cont
#end
#sub function in hvm_build_set_params
#break libxl/libxl_dom.c:491
#commands
#silent
#printf "libxl/libxl_dom.c:491\n"
#cont
#end
#
#break libxl/libxl_dom.c:492
#commands
#silent
#printf "libxl/libxl_dom.c:492\n"
#cont
#end
#
#break libxl/libxl_dom.c:493
#commands
#silent
#printf "libxl/libxl_dom.c:493\n"
#cont
#end
#
#break libxl/libxl_dom.c:496
#commands
#silent
#printf "libxl/libxl_dom.c:496\n"
#cont
#end
#
#break libxl/libxl_dom.c:498
#commands
#silent
#printf "libxl/libxl_dom.c:498\n"
#cont
#end
#
#break libxl/libxl_dom.c:501
#commands
#silent
#printf "libxl/libxl_dom.c:501\n"
#cont
#end
#
#break libxl/libxl_dom.c:502
#commands
#silent
#printf "libxl/libxl_dom.c:502\n"
#cont
#end
#
#break libxl/libxl_dom.c:504
#commands
#silent
#printf "libxl/libxl_dom.c:504\n"
#cont
#end
#
#break libxl/libxl_dom.c:506
#commands
#silent
#printf "libxl/libxl_dom.c:506\n"
#cont
#end
#
#break libxl/libxl_dom.c:507
#commands
#silent
#printf "libxl/libxl_dom.c:507\n"
#cont
#end
#
#break libxl/libxl_dom.c:509
#commands
#silent
#printf "libxl/libxl_dom.c:509\n"
#cont
#end
#
#break xc_map_foreign_range
#commands
#silent
#printf "xc_map_foreign_range\n"
#cont
#end
#
#break xc_get_hvm_param
#commands
#silent
#printf "xc_get_hvm_param\n"
#cont
#end
#
#break xc_set_hvm_param
#commands
#silent
#printf "xc_set_hvm_param\n"
##printf "xc_set_hvm_param: handle<%lu>, domid<%u>, param<%ld>, value<%lu>\n", handle, dom, param, value
#where 2
#cont
#end
#
#break do_xen_hypercall
#commands
#silent
#printf "do_xen_hypercall\n"
#cont
#end
#
#break ioctl
#commands
#silent
#printf "ioctl\n"
#cont
#end
#
#break xc__hypercall_buffer_free
#commands
#silent
#printf "xc__hypercall_buffer_free\n"
#cont
#end
#
#break xc_dom_gnttab_hvm_seed
#commands
#silent
#printf "xc_dom_gnttab_hvm_seed\n"
#cont
#end
#
#sub function in hvm_build_set_params end

#sub function in libxl_domain_create_new end

break virDomainDefFormat
commands
silent
printf "virDomainDefFormat\n"
cont
end

cont

