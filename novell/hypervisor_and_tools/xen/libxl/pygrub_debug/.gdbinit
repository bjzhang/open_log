set breakpoint pending on

set logging on

break xl.c:245
commands
silent
print "GDB_DEBUG: set msg level as DEBUG"
set minmsglevel=XTL_DEBUG
print minmsglevel
cont
end

#break bootloader_gotptys

break libxl__ao_inprogress
commands
silent
print "GDB_DEBUG: libxl__ao_inprogress\n"
where 2
cont
end

break libxl__device_disk_local_init
commands
silent
print "GDB_DEBUG: libxl__device_disk_local_init\n"
cont
end

break libxl__device_disk_local_initiate_attach
commands
silent
print "GDB_DEBUG: libxl__device_disk_local_initiate_attach\n"
cont
end

break bootloader_setpaths
commands
silent
print "GDB_DEBUG: bootloader_setpaths\n"
cont
end

break bootloader_callback
commands
silent
print "GDB_DEBUG: bootloader_callback\n"
cont
end


#all the callback function
break bootloader_disk_attached_cb
commands
silent
print "GDB_DEBUG: bootloader_disk_attached_cb\n"
cont
end

break bootloader_local_detached_cb
commands
silent
print "GDB_DEBUG: bootloader_local_detached_cb\n"
cont
end

break libxl__device_disk_local_initiate_detach
commands
silent
print "GDB_DEBUG: libxl__device_disk_local_initiate_detach\n"
cont
end

break libxl__device_disk_local_init
commands
silent
print "GDB_DEBUG: libxl__device_disk_local_init\n"
cont
end

break bootloader_gotptys
commands
silent
print "GDB_DEBUG: bootloader_gotptys\n"
cont
end

break bootloader_domaindeath
commands
silent
print "GDB_DEBUG: bootloader_domaindeath\n"
cont
end

break bootloader_stop
commands
silent
print "GDB_DEBUG: bootloader_stop\n"
cont
end

break bootloader_keystrokes_copyfail
commands
silent
print "GDB_DEBUG: bootloader_keystrokes_copyfail\n"
cont
end

break bootloader_display_copyfail
commands
silent
print "GDB_DEBUG: bootloader_display_copyfail\n"
cont
end

break remus_failover_cb
commands
silent
print "GDB_DEBUG: remus_failover_cb\n"
cont
end

break domain_suspend_cb
commands
silent
print "GDB_DEBUG: domain_suspend_cb\n"
cont
end

break domain_destroy_cb
commands
silent
print "GDB_DEBUG: domain_destroy_cb\n"
cont
end

break stubdom_destroy_callback
commands
silent
print "GDB_DEBUG: stubdom_destroy_callback\n"
cont
end

break domain_destroy_callback
commands
silent
print "GDB_DEBUG: domain_destroy_callback\n"
cont
end

break devices_destroy_cb
commands
silent
print "GDB_DEBUG: devices_destroy_cb\n"
cont
end

break local_device_attach_cb
commands
silent
print "GDB_DEBUG: local_device_attach_cb\n"
cont
end

break local_device_detach_cb
commands
silent
print "GDB_DEBUG: local_device_detach_cb\n"
cont
end

break device_addrm_aocomplete
commands
silent
print "GDB_DEBUG: device_addrm_aocomplete\n"
cont
end

break domcreate_bootloader_done
commands
silent
print "GDB_DEBUG: domcreate_bootloader_done\n"
cont
end

break domcreate_devmodel_started
commands
silent
print "GDB_DEBUG: domcreate_devmodel_started\n"
cont
end

break domcreate_devmodel_started
commands
silent
print "GDB_DEBUG: domcreate_devmodel_started\n"
cont
end

break domcreate_launch_dm
commands
silent
print "GDB_DEBUG: domcreate_launch_dm\n"
cont
end

break domcreate_attach_vtpms
commands
silent
print "GDB_DEBUG: domcreate_attach_vtpms\n"
cont
end

break domcreate_attach_pci
commands
silent
print "GDB_DEBUG: domcreate_attach_pci\n"
cont
end

break domcreate_destruction_cb
commands
silent
print "GDB_DEBUG: domcreate_destruction_cb\n"
cont
end

break domain_create_cb
commands
silent
print "GDB_DEBUG: domain_create_cb\n"
cont
end

break multidev_one_callback
commands
silent
print "GDB_DEBUG: multidev_one_callback\n"
cont
end

break devices_remove_callback
commands
silent
print "GDB_DEBUG: devices_remove_callback\n"
cont
end

break spawn_stub_launch_dm
commands
silent
print "GDB_DEBUG: spawn_stub_launch_dm\n"
cont
end

break spawn_stubdom_pvqemu_cb
commands
silent
print "GDB_DEBUG: spawn_stubdom_pvqemu_cb\n"
cont
end

break stubdom_pvqemu_cb
commands
silent
print "GDB_DEBUG: stubdom_pvqemu_cb\n"
cont
end

break spaw_stubdom_pvqemu_destroy_cb
commands
silent
print "GDB_DEBUG: spaw_stubdom_pvqemu_destroy_cb\n"
cont
end

break save_device_model_datacopier_done
commands
silent
print "GDB_DEBUG: save_device_model_datacopier_done\n"
cont
end

break libxl__srm_callout_received_restore
commands
silent
print "GDB_DEBUG: libxl__srm_callout_received_restore\n"
cont
end

break libxl__xc_domain_restore_done
commands
silent
print "GDB_DEBUG: libxl__xc_domain_restore_done\n"
cont
end

break libxl__srm_callout_received_save
commands
silent
print "GDB_DEBUG: libxl__srm_callout_received_save\n"
cont
end

break libxl__xc_domain_save_done
commands
silent
print "GDB_DEBUG: libxl__xc_domain_save_done\n"
cont
end

break autoconnect_console
commands
silent
print "GDB_DEBUG: autoconnect_console\n"
cont
end

break dummy_asyncprogress_callback_ignore
commands
silent
print "GDB_DEBUG: dummy_asyncprogress_callback_ignore\n"
cont
end

break initiate_domain_create
commands
silent
print "GDB_DEBUG: initiate_domain_create\n"
cont
end

#in initiate_domain_create

break libxl__domain_create_info_setdefault
commands
silent
print "GDB_DEBUG: libxl__domain_create_info_setdefault\n"
cont
end

break libxl__domain_make
commands
silent
print "GDB_DEBUG: libxl__domain_make\n"
cont
end

break libxl__domain_build_info_setdefault
commands
silent
print "GDB_DEBUG: libxl__domain_build_info_setdefault\n"
cont
end

break libxl__device_disk_setdefault
commands
silent
print "GDB_DEBUG: libxl__device_disk_setdefault\n"
cont
end

break domcreate_bootloader_console_available
commands
silent
print "GDB_DEBUG: domcreate_bootloader_console_available\n"
cont
end

#exit initiate_domain_create

#in main_create
break libxl_evenable_domain_death
commands
silent
print "GDB_DEBUG: libxl_evenable_domain_death\n"
cont
end

break domain_wait_event
commands
silent
print "GDB_DEBUG: domain_wait_event\n"
cont
end

break libxl_event_wait
commands
silent
print "GDB_DEBUG: libxl_event_wait\n"
cont
end

break eventloop_iteration
commands
silent
print "GDB_DEBUG: eventloop_iteration\n"
cont
end

run
