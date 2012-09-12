set breakpoint pending on

set logging on


break virDomainObjSetState
commands
silent
printf "virDomainObjSetState: %u, %s, %s\n", dom, virDomainStateTypeToString(state), virDomainStateReasonToString(state, reason)
#where
cont
end

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

break qemudClose
commands
silent
printf "qemudClose\n"
#where
cont
end

break qemuDriverCloseCallbackSet
commands
silent
printf "qemuDriverCloseCallbackSet\n"
#where
cont
end

break qemuMigrationWaitForCompletion
commands
silent
printf "qemuMigrationWaitForCompletion\n"
cont
end

break daemonShutdownHandler
commands
silent
printf "daemonShutdownHandler\n"
cont
end

break daemonReloadHandler
commands
silent
printf "daemonReloadHandler\n"
cont
end

#break qemuProcessStart

cont
