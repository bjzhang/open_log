set breakpoint pending on

set logging on

break qemuDomainMigrateBegin3
commands
silent
printf "qemuDomainMigrateBegin3\n"
cont
end

break qemuDomainMigratePrepare3
commands
silent
printf "qemuDomainMigratePrepare3\n"
cont
end

break qemuDomainMigratePrepareTunnel3
commands
silent
printf "qemuDomainMigratePrepareTunnel3\n"
cont
end

break qemuDomainMigratePerform3
commands
silent
printf "qemuDomainMigratePerform3\n"
cont
end

break qemuDomainMigrateFinish3
commands
silent
printf "qemuDomainMigrateFinish3\n"
cont
end

break qemuDomainMigrateConfirm3
commands
silent
printf "qemuDomainMigrateConfirm3\n"
cont
end

break qemuDomainObjEndAsyncJob
commands
silent
printf "qemuDomainObjEndAsyncJob\n"
cont
end

break qemuDomainObjBeginJobInternal
commands
silent
printf "qemuDomainObjBeginJobInternal\n"
cont
end

#break qemuDomainObjBeginJob
#commands
#silent
#printf "qemuDomainObjBeginJob\n"
#cont
#end
#

break qemuDriverLock
commands
silent
printf "qemuDriverLock\n"
where
cont
end

break qemuDriverUnlock
commands
silent
printf "qemuDriverUnlock\n"
where
cont
end

break qemu/qemu_driver.c:8943
commands
silent
printf "qemuDomainMigrateBegin3 exit\n"
cont
end

break qemu/qemu_driver.c:9000
commands
silent
printf "qemuDomainMigratePrepare3 exit\n"
cont
end

break qemu/qemu_driver.c:9085
commands
silent
printf "qemuDomainMigratePerform3 exit\n"
cont
end

break qemu/qemu_driver.c:9122
commands
silent
printf "qemuDomainMigrateFinish3 exit\n"
cont
end

break qemu/qemu_driver.c:9178
commands
silent
printf "qemuDomainMigrateConfirm3 exit\n"
cont
end

break qemu/qemu_domain.c:825
commands
silent
printf "qemuDomainObjBeginJobInternal exit\n"
cont
end


cont

