
add-auto-load-safe-path /home/bamvor/log/novell/hypervisor_and_tools/libvirt/kvm_win7_save_hang/20130617/.gdbinit

set breakpoint pending on

set logging on

break qemuMonitorGetMigrationStatus
commands
silent
printf "qemuMonitorGetMigrationStatus\n"
#where
cont
end

break qemuMonitorJSONGetMigrationStatus
commands
silent
printf "qemuMonitorJSONGetMigrationStatus\n"
#where
cont
end

break qemuMonitorSend
commands
silent
printf "qemuMonitorSend\n"
#where
cont
end

break qemuMonitorIOWrite
commands
silent
printf "qemuMonitorIOWrite\n"
#where
cont
end

break qemuMonitorIOProcess
commands
silent
printf "qemuMonitorIOProcess\n"
#where
cont
end

break qemuMonitorJSONIOProcessLine
commands
silent
printf "qemuMonitorJSONIOProcessLine\n"
#where
cont
end

break qemuMonitorMigrateToFile
commands
silent
printf "qemuMonitorMigrateToFile\n"
#where
cont
end

break qemuMigrationWaitForCompletion
commands
silent
printf "qemuMigrationWaitForCompletion\n"
#where
cont
end

break qemuMigrationUpdateJobStatus
commands
silent
printf "qemuMigrationUpdateJobStatus\n"
#where
cont
end

break qemuMonitorIOWriteWithFD
commands
silent
printf "qemuMonitorIOWriteWithFD\n"
cont
end

break qemuMonitorGetMigrationStatus
commands
silent
printf "qemuMonitorGetMigrationStatus\n"
cont
end

break qemuDomainObjEnterMonitorAsync
commands
silent
printf "qemuDomainObjEnterMonitorAsync\n"
#where
cont
end

break qemuDomainObjExitMonitorAsync
commands
silent
printf "qemuDomainObjExitMonitorAsync\n"
#where
cont
end

break qemu/qemu_monitor.c:411
commands
silent
printf "qemuMonitorIOWriteWithFD:411\n"
#where
cont
end

break qemu/qemu_monitor.c:412
commands
silent
printf "qemuMonitorIOWriteWithFD:412: %d, %d\n", ret, errno
#where
cont
end

break qemu/qemu_monitor.c:437
commands
silent
printf "qemuMonitorIOWrite:write\n"
#where
cont
end

break qemu/qemu_monitor.c:441
commands
silent
printf "qemuMonitorIOWrite:qemuMonitorIOWriteWithFD\n"
#where
cont
end

break qemu/qemu_monitor.c:446
commands
silent
printf "qemuMonitorIOWrite: %d, %d\n", done, errno
#where
cont
end

break qemu/qemu_monitor.c:341
commands
silent
printf "qemuMonitorIOProcess: before process\n"
#where
cont
end

break qemu/qemu_monitor.c:353
commands
silent
printf "qemuMonitorIOProcess: after process\n"
#where
cont
end

cont

