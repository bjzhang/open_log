set breakpoint pending on

set logging on

break virDomainObjSetState
commands
silent
printf "virDomainObjSetState: %u, %s, %s\n", dom, virDomainStateTypeToString(state), virDomainStateReasonToString(state, reason)
#where
cont
end

break libxlDomainMigrateBegin3
commands
silent
printf "libxlDomainMigrateBegin3\n"
cont
end

break libxlDomainMigratePrepare3
commands
silent
printf "libxlDomainMigratePrepare3\n"
cont
end

break libxlDomainMigratePerform3
commands
silent
printf "libxlDomainMigratePerform3\n"
cont
end

break libxlDomainMigrateFinish3
commands
silent
printf "libxlDomainMigrateFinish3\n"
cont
end

break libxlDomainMigrateConfirm3
commands
silent
printf "libxlDomainMigrateConfirm3\n"
cont
end

break libxlClose
commands
silent
printf "libxlClose\n"
#where
cont
end

break libxlMigrationJobStart
commands
silent
printf "libxlMigrationJobStart: %s\n", libxlDomainAsyncJobTypeToString(job)
cont
end

break libxl/libxl_driver.c:236
commands
silent
printf "libxlDomainObjBeginJobInternal wait async cond: async job: %s, job mask: %x, job: %s\n", libxlDomainAsyncJobTypeToString(priv->job.asyncJob), priv->job.mask, libxlDomainJobTypeToString(job)
cont
end

break libxl/libxl_driver.c:244
commands
silent
printf "libxlDomainObjBeginJobInternal wait cond: job active: %x, job: %s\n", priv->job.active, libxlDomainJobTypeToString(job)
cont
end

break libxlVmReap
commands
silent
printf "libxlVmReap: %d\n", vm->def->id
cont
end


#break doMigrateReceive
cont
