
add-auto-load-safe-path /home/bamvor/log/novell/hypervisor_and_tools/libvirt/kvm_win7_save_hang/20130617/.gdbinit

set breakpoint pending on

set logging on

break qemuMonitorGetMigrationStatus
commands
silent
printf "qemuMonitorGetMigrationStatus\n"
where
cont
end

break qemuMonitorJSONGetMigrationStatus
commands
silent
printf "qemuMonitorJSONGetMigrationStatus\n"
where
cont
end

break qemuMonitorSend
commands
silent
printf "qemuMonitorSend\n"
where
cont
end

break qemuMonitorIOWrite
commands
silent
printf "qemuMonitorIOWrite\n"
where
cont
end

break qemuMonitorIOProcess
commands
silent
printf "qemuMonitorIOProcess\n"
where
cont
end

break qemuMonitorJSONIOProcessLine
commands
silent
printf "qemuMonitorJSONIOProcessLine\n"
where
cont
end

cont

