set breakpoint pending on

set logging on

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

break libxlDomainMigratePrepareTunnel3
commands
silent
printf "libxlDomainMigratePrepareTunnel3\n"
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

##############lock######################################
#break libxlDriverLock
#commands
#silent
#printf "libxlDriverLock\n"
#cont
#end
#
#break libxlDriverUnlock
#commands
#silent
#printf "libxlDriverUnlock\n"
#cont
#end
#
#break virMutexLock
#commands
#silent
#printf "virMutexLock\n"
#cont
#end
#
#break virMutexUnlock
#commands
#silent
#printf "virMutexUnlock\n"
#cont
#end
#
#break virDomainObjLock
#commands
#silent
#printf "virDomainObjLock\n"
#cont
#end
#
#break virDomainObjUnlock
#commands
#silent
#printf "virDomainObjUnlock\n"
#cont
#end


#break libxlDomainObjEndAsyncJob
#commands
#silent
#printf "libxlDomainObjEndAsyncJob\n"
#cont
#end

#break libxlDomainObjBeginJobInternal
#commands
#silent
#printf "libxlDomainObjBeginJobInternal\n"
#cont
#end

#break libxlDomainObjBeginJob
#commands
#silent
#printf "libxlDomainObjBeginJob\n"
#cont
#end
#

##############virsh list relative function##############
break libxlNumDomains
commands
silent
printf "libxlNumDomains\n"
cont
end

break virDomainObjListNumOfDomains
commands
silent
printf "virDomainObjListNumOfDomains\n"
cont
end

break virDomainObjListCountActive
commands
silent
printf "virDomainObjListCountActive\n"
cont
end

break libxlListDomains
commands
silent
printf "libxlListDomains\n"
cont
end

break virDomainObjListGetActiveIDs
commands
silent
printf "virDomainObjListGetActiveIDs\n"
cont
end

break virDomainObjListCopyActiveIDs
commands
silent
printf "virDomainObjListCopyActiveIDs\n"
cont
end

cont


