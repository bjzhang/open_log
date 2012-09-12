set breakpoint pending on


break qemudOpen
commands
silent
shell date +%H%M%S
printf "qemudOpen"
cont
end

break qemudClose
commands
silent
shell date +%H%M%S
printf "qemudClose"
cont
end

break qemudSupportsFeature
commands
silent
shell date +%H%M%S
printf "qemudSupportsFeature"
cont
end

break qemudGetType
commands
silent
shell date +%H%M%S
printf "qemudGetType"
cont
end

break qemudGetVersion
commands
silent
shell date +%H%M%S
printf "qemudGetVersion"
cont
end

break virGetHostname
commands
silent
shell date +%H%M%S
printf "virGetHostname"
cont
end

break qemuGetSysinfo
commands
silent
shell date +%H%M%S
printf "qemuGetSysinfo"
cont
end

break qemudGetMaxVCPUs
commands
silent
shell date +%H%M%S
printf "qemudGetMaxVCPUs"
cont
end

break nodeGetInfo
commands
silent
shell date +%H%M%S
printf "nodeGetInfo"
cont
end

break qemudGetCapabilities
commands
silent
shell date +%H%M%S
printf "qemudGetCapabilities"
cont
end

break qemudListDomains
commands
silent
shell date +%H%M%S
printf "qemudListDomains"
cont
end

break qemudNumDomains
commands
silent
shell date +%H%M%S
printf "qemudNumDomains"
cont
end

break qemudDomainCreate
commands
silent
shell date +%H%M%S
printf "qemudDomainCreate"
cont
end

break qemudDomainLookupByID
commands
silent
shell date +%H%M%S
printf "qemudDomainLookupByID"
cont
end

break qemudDomainLookupByUUID
commands
silent
shell date +%H%M%S
printf "qemudDomainLookupByUUID"
cont
end

break qemudDomainLookupByName
commands
silent
shell date +%H%M%S
printf "qemudDomainLookupByName"
cont
end

break qemudDomainSuspend
commands
silent
shell date +%H%M%S
printf "qemudDomainSuspend"
cont
end

break qemudDomainResume
commands
silent
shell date +%H%M%S
printf "qemudDomainResume"
cont
end

break qemuDomainShutdown
commands
silent
shell date +%H%M%S
printf "qemuDomainShutdown"
cont
end

break qemuDomainShutdownFlags
commands
silent
shell date +%H%M%S
printf "qemuDomainShutdownFlags"
cont
end

break qemuDomainReboot
commands
silent
shell date +%H%M%S
printf "qemuDomainReboot"
cont
end

break qemuDomainReset
commands
silent
shell date +%H%M%S
printf "qemuDomainReset"
cont
end

break qemuDomainDestroy
commands
silent
shell date +%H%M%S
printf "qemuDomainDestroy"
cont
end

break qemuDomainDestroyFlags
commands
silent
shell date +%H%M%S
printf "qemuDomainDestroyFlags"
cont
end

break qemudDomainGetOSType
commands
silent
shell date +%H%M%S
printf "qemudDomainGetOSType"
cont
end

break qemuDomainGetMaxMemory
commands
silent
shell date +%H%M%S
printf "qemuDomainGetMaxMemory"
cont
end

break qemudDomainSetMaxMemory
commands
silent
shell date +%H%M%S
printf "qemudDomainSetMaxMemory"
cont
end

break qemudDomainSetMemory
commands
silent
shell date +%H%M%S
printf "qemudDomainSetMemory"
cont
end

break qemudDomainSetMemoryFlags
commands
silent
shell date +%H%M%S
printf "qemudDomainSetMemoryFlags"
cont
end

break qemuDomainSetMemoryParameters
commands
silent
shell date +%H%M%S
printf "qemuDomainSetMemoryParameters"
cont
end

break qemuDomainGetMemoryParameters
commands
silent
shell date +%H%M%S
printf "qemuDomainGetMemoryParameters"
cont
end

break qemuDomainSetBlkioParameters
commands
silent
shell date +%H%M%S
printf "qemuDomainSetBlkioParameters"
cont
end

break qemuDomainGetBlkioParameters
commands
silent
shell date +%H%M%S
printf "qemuDomainGetBlkioParameters"
cont
end

break qemudDomainGetInfo
commands
silent
shell date +%H%M%S
printf "qemudDomainGetInfo"
cont
end

break qemuDomainGetState
commands
silent
shell date +%H%M%S
printf "qemuDomainGetState"
cont
end

break qemuDomainGetControlInfo
commands
silent
shell date +%H%M%S
printf "qemuDomainGetControlInfo"
cont
end

break qemuDomainSave
commands
silent
shell date +%H%M%S
printf "qemuDomainSave"
cont
end

break qemuDomainSaveFlags
commands
silent
shell date +%H%M%S
printf "qemuDomainSaveFlags"
cont
end

break qemuDomainRestore
commands
silent
shell date +%H%M%S
printf "qemuDomainRestore"
cont
end

break qemuDomainRestoreFlags
commands
silent
shell date +%H%M%S
printf "qemuDomainRestoreFlags"
cont
end

break qemuDomainSaveImageGetXMLDesc
commands
silent
shell date +%H%M%S
printf "qemuDomainSaveImageGetXMLDesc"
cont
end

break qemuDomainSaveImageDefineXML
commands
silent
shell date +%H%M%S
printf "qemuDomainSaveImageDefineXML"
cont
end

break qemudDomainCoreDump
commands
silent
shell date +%H%M%S
printf "qemudDomainCoreDump"
cont
end

break qemuDomainScreenshot
commands
silent
shell date +%H%M%S
printf "qemuDomainScreenshot"
cont
end

break qemuDomainSetVcpus
commands
silent
shell date +%H%M%S
printf "qemuDomainSetVcpus"
cont
end

break qemuDomainSetVcpusFlags
commands
silent
shell date +%H%M%S
printf "qemuDomainSetVcpusFlags"
cont
end

break qemudDomainGetVcpusFlags
commands
silent
shell date +%H%M%S
printf "qemudDomainGetVcpusFlags"
cont
end

break qemudDomainPinVcpu
commands
silent
shell date +%H%M%S
printf "qemudDomainPinVcpu"
cont
end

break qemudDomainPinVcpuFlags
commands
silent
shell date +%H%M%S
printf "qemudDomainPinVcpuFlags"
cont
end

break qemudDomainGetVcpuPinInfo
commands
silent
shell date +%H%M%S
printf "qemudDomainGetVcpuPinInfo"
cont
end

break qemudDomainGetVcpus
commands
silent
shell date +%H%M%S
printf "qemudDomainGetVcpus"
cont
end

break qemudDomainGetMaxVcpus
commands
silent
shell date +%H%M%S
printf "qemudDomainGetMaxVcpus"
cont
end

break qemudDomainGetSecurityLabel
commands
silent
shell date +%H%M%S
printf "qemudDomainGetSecurityLabel"
cont
end

break qemudNodeGetSecurityModel
commands
silent
shell date +%H%M%S
printf "qemudNodeGetSecurityModel"
cont
end

break qemuDomainGetXMLDesc
commands
silent
shell date +%H%M%S
printf "qemuDomainGetXMLDesc"
cont
end

break qemuDomainXMLFromNative
commands
silent
shell date +%H%M%S
printf "qemuDomainXMLFromNative"
cont
end

break qemuDomainXMLToNative
commands
silent
shell date +%H%M%S
printf "qemuDomainXMLToNative"
cont
end

break qemudListDefinedDomains
commands
silent
shell date +%H%M%S
printf "qemudListDefinedDomains"
cont
end

break qemudNumDefinedDomains
commands
silent
shell date +%H%M%S
printf "qemudNumDefinedDomains"
cont
end

break qemuDomainStart
commands
silent
shell date +%H%M%S
printf "qemuDomainStart"
cont
end

break qemuDomainStartWithFlags
commands
silent
shell date +%H%M%S
printf "qemuDomainStartWithFlags"
cont
end

break qemudDomainDefine
commands
silent
shell date +%H%M%S
printf "qemudDomainDefine"
cont
end

break qemudDomainUndefine
commands
silent
shell date +%H%M%S
printf "qemudDomainUndefine"
cont
end

break qemuDomainUndefineFlags
commands
silent
shell date +%H%M%S
printf "qemuDomainUndefineFlags"
cont
end

break qemuDomainAttachDevice
commands
silent
shell date +%H%M%S
printf "qemuDomainAttachDevice"
cont
end

break qemuDomainAttachDeviceFlags
commands
silent
shell date +%H%M%S
printf "qemuDomainAttachDeviceFlags"
cont
end

break qemuDomainDetachDevice
commands
silent
shell date +%H%M%S
printf "qemuDomainDetachDevice"
cont
end

break qemuDomainDetachDeviceFlags
commands
silent
shell date +%H%M%S
printf "qemuDomainDetachDeviceFlags"
cont
end

break qemuDomainUpdateDeviceFlags
commands
silent
shell date +%H%M%S
printf "qemuDomainUpdateDeviceFlags"
cont
end

break qemudDomainGetAutostart
commands
silent
shell date +%H%M%S
printf "qemudDomainGetAutostart"
cont
end

break qemudDomainSetAutostart
commands
silent
shell date +%H%M%S
printf "qemudDomainSetAutostart"
cont
end

break qemuGetSchedulerType
commands
silent
shell date +%H%M%S
printf "qemuGetSchedulerType"
cont
end

break qemuGetSchedulerParameters
commands
silent
shell date +%H%M%S
printf "qemuGetSchedulerParameters"
cont
end

break qemuGetSchedulerParametersFlags
commands
silent
shell date +%H%M%S
printf "qemuGetSchedulerParametersFlags"
cont
end

break qemuSetSchedulerParameters
commands
silent
shell date +%H%M%S
printf "qemuSetSchedulerParameters"
cont
end

break qemuSetSchedulerParametersFlags
commands
silent
shell date +%H%M%S
printf "qemuSetSchedulerParametersFlags"
cont
end

break qemudDomainMigratePerform
commands
silent
shell date +%H%M%S
printf "qemudDomainMigratePerform"
cont
end

break qemuDomainBlockResize
commands
silent
shell date +%H%M%S
printf "qemuDomainBlockResize"
cont
end

break qemuDomainBlockStats
commands
silent
shell date +%H%M%S
printf "qemuDomainBlockStats"
cont
end

break qemuDomainBlockStatsFlags
commands
silent
shell date +%H%M%S
printf "qemuDomainBlockStatsFlags"
cont
end

break qemudDomainInterfaceStats
commands
silent
shell date +%H%M%S
printf "qemudDomainInterfaceStats"
cont
end

break qemudDomainMemoryStats
commands
silent
shell date +%H%M%S
printf "qemudDomainMemoryStats"
cont
end

break qemudDomainBlockPeek
commands
silent
shell date +%H%M%S
printf "qemudDomainBlockPeek"
cont
end

break qemudDomainMemoryPeek
commands
silent
shell date +%H%M%S
printf "qemudDomainMemoryPeek"
cont
end

break qemuDomainGetBlockInfo
commands
silent
shell date +%H%M%S
printf "qemuDomainGetBlockInfo"
cont
end

break nodeGetCPUStats
commands
silent
shell date +%H%M%S
printf "nodeGetCPUStats"
cont
end

break nodeGetMemoryStats
commands
silent
shell date +%H%M%S
printf "nodeGetMemoryStats"
cont
end

break nodeGetCellsFreeMemory
commands
silent
shell date +%H%M%S
printf "nodeGetCellsFreeMemory"
cont
end

break nodeGetFreeMemory
commands
silent
shell date +%H%M%S
printf "nodeGetFreeMemory"
cont
end

break qemuDomainEventRegister
commands
silent
shell date +%H%M%S
printf "qemuDomainEventRegister"
cont
end

break qemuDomainEventDeregister
commands
silent
shell date +%H%M%S
printf "qemuDomainEventDeregister"
cont
end

break qemudDomainMigratePrepare2
commands
silent
shell date +%H%M%S
printf "qemudDomainMigratePrepare2"
cont
end

break qemudDomainMigrateFinish2
commands
silent
shell date +%H%M%S
printf "qemudDomainMigrateFinish2"
cont
end

break qemudNodeDeviceDettach
commands
silent
shell date +%H%M%S
printf "qemudNodeDeviceDettach"
cont
end

break qemudNodeDeviceReAttach
commands
silent
shell date +%H%M%S
printf "qemudNodeDeviceReAttach"
cont
end

break qemudNodeDeviceReset
commands
silent
shell date +%H%M%S
printf "qemudNodeDeviceReset"
cont
end

break qemudDomainMigratePrepareTunnel
commands
silent
shell date +%H%M%S
printf "qemudDomainMigratePrepareTunnel"
cont
end

break qemuIsEncrypted
commands
silent
shell date +%H%M%S
printf "qemuIsEncrypted"
cont
end

break qemuIsSecure
commands
silent
shell date +%H%M%S
printf "qemuIsSecure"
cont
end

break qemuDomainIsActive
commands
silent
shell date +%H%M%S
printf "qemuDomainIsActive"
cont
end

break qemuDomainIsPersistent
commands
silent
shell date +%H%M%S
printf "qemuDomainIsPersistent"
cont
end

break qemuDomainIsUpdated
commands
silent
shell date +%H%M%S
printf "qemuDomainIsUpdated"
cont
end

break qemuCPUCompare
commands
silent
shell date +%H%M%S
printf "qemuCPUCompare"
cont
end

break qemuCPUBaseline
commands
silent
shell date +%H%M%S
printf "qemuCPUBaseline"
cont
end

break qemuDomainGetJobInfo
commands
silent
shell date +%H%M%S
printf "qemuDomainGetJobInfo"
cont
end

break qemuDomainAbortJob
commands
silent
shell date +%H%M%S
printf "qemuDomainAbortJob"
cont
end

break qemuDomainMigrateSetMaxDowntime
commands
silent
shell date +%H%M%S
printf "qemuDomainMigrateSetMaxDowntime"
cont
end

break qemuDomainMigrateSetMaxSpeed
commands
silent
shell date +%H%M%S
printf "qemuDomainMigrateSetMaxSpeed"
cont
end

break qemuDomainMigrateGetMaxSpeed
commands
silent
shell date +%H%M%S
printf "qemuDomainMigrateGetMaxSpeed"
cont
end

break qemuDomainEventRegisterAny
commands
silent
shell date +%H%M%S
printf "qemuDomainEventRegisterAny"
cont
end

break qemuDomainEventDeregisterAny
commands
silent
shell date +%H%M%S
printf "qemuDomainEventDeregisterAny"
cont
end

break qemuDomainManagedSave
commands
silent
shell date +%H%M%S
printf "qemuDomainManagedSave"
cont
end

break qemuDomainHasManagedSaveImage
commands
silent
shell date +%H%M%S
printf "qemuDomainHasManagedSaveImage"
cont
end

break qemuDomainManagedSaveRemove
commands
silent
shell date +%H%M%S
printf "qemuDomainManagedSaveRemove"
cont
end

break qemuDomainSnapshotCreateXML
commands
silent
shell date +%H%M%S
printf "qemuDomainSnapshotCreateXML"
cont
end

break qemuDomainSnapshotGetXMLDesc
commands
silent
shell date +%H%M%S
printf "qemuDomainSnapshotGetXMLDesc"
cont
end

break qemuDomainSnapshotNum
commands
silent
shell date +%H%M%S
printf "qemuDomainSnapshotNum"
cont
end

break qemuDomainSnapshotListNames
commands
silent
shell date +%H%M%S
printf "qemuDomainSnapshotListNames"
cont
end

break qemuDomainSnapshotNumChildren
commands
silent
shell date +%H%M%S
printf "qemuDomainSnapshotNumChildren"
cont
end

break qemuDomainSnapshotListChildrenNames
commands
silent
shell date +%H%M%S
printf "qemuDomainSnapshotListChildrenNames"
cont
end

break qemuDomainSnapshotLookupByName
commands
silent
shell date +%H%M%S
printf "qemuDomainSnapshotLookupByName"
cont
end

break qemuDomainHasCurrentSnapshot
commands
silent
shell date +%H%M%S
printf "qemuDomainHasCurrentSnapshot"
cont
end

break qemuDomainSnapshotGetParent
commands
silent
shell date +%H%M%S
printf "qemuDomainSnapshotGetParent"
cont
end

break qemuDomainSnapshotCurrent
commands
silent
shell date +%H%M%S
printf "qemuDomainSnapshotCurrent"
cont
end

break qemuDomainRevertToSnapshot
commands
silent
shell date +%H%M%S
printf "qemuDomainRevertToSnapshot"
cont
end

break qemuDomainSnapshotDelete
commands
silent
shell date +%H%M%S
printf "qemuDomainSnapshotDelete"
cont
end

break qemuDomainMonitorCommand
commands
silent
shell date +%H%M%S
printf "qemuDomainMonitorCommand"
cont
end

break qemuDomainAttach
commands
silent
shell date +%H%M%S
printf "qemuDomainAttach"
cont
end

break qemuDomainOpenConsole
commands
silent
shell date +%H%M%S
printf "qemuDomainOpenConsole"
cont
end

break qemuDomainOpenGraphics
commands
silent
shell date +%H%M%S
printf "qemuDomainOpenGraphics"
cont
end

break qemuDomainInjectNMI
commands
silent
shell date +%H%M%S
printf "qemuDomainInjectNMI"
cont
end

break qemuDomainMigrateBegin3
commands
silent
shell date +%H%M%S
printf "qemuDomainMigrateBegin3"
cont
end

break qemuDomainMigratePrepare3
commands
silent
shell date +%H%M%S
printf "qemuDomainMigratePrepare3"
cont
end

break qemuDomainMigratePrepareTunnel3
commands
silent
shell date +%H%M%S
printf "qemuDomainMigratePrepareTunnel3"
cont
end

break qemuDomainMigratePerform3
commands
silent
shell date +%H%M%S
printf "qemuDomainMigratePerform3"
cont
end

break qemuDomainMigrateFinish3
commands
silent
shell date +%H%M%S
printf "qemuDomainMigrateFinish3"
cont
end

break qemuDomainMigrateConfirm3
commands
silent
shell date +%H%M%S
printf "qemuDomainMigrateConfirm3"
cont
end

break qemuDomainSendKey
commands
silent
shell date +%H%M%S
printf "qemuDomainSendKey"
cont
end

break qemuDomainBlockJobAbort
commands
silent
shell date +%H%M%S
printf "qemuDomainBlockJobAbort"
cont
end

break qemuDomainGetBlockJobInfo
commands
silent
shell date +%H%M%S
printf "qemuDomainGetBlockJobInfo"
cont
end

break qemuDomainBlockJobSetSpeed
commands
silent
shell date +%H%M%S
printf "qemuDomainBlockJobSetSpeed"
cont
end

break qemuDomainBlockPull
commands
silent
shell date +%H%M%S
printf "qemuDomainBlockPull"
cont
end

break qemuDomainBlockRebase
commands
silent
shell date +%H%M%S
printf "qemuDomainBlockRebase"
cont
end

break qemuIsAlive
commands
silent
shell date +%H%M%S
printf "qemuIsAlive"
cont
end

break nodeSuspendForDuration
commands
silent
shell date +%H%M%S
printf "nodeSuspendForDuration"
cont
end

break qemuDomainSetBlockIoTune
commands
silent
shell date +%H%M%S
printf "qemuDomainSetBlockIoTune"
cont
end

break qemuDomainGetBlockIoTune
commands
silent
shell date +%H%M%S
printf "qemuDomainGetBlockIoTune"
cont
end

break qemuDomainSetNumaParameters
commands
silent
shell date +%H%M%S
printf "qemuDomainSetNumaParameters"
cont
end

break qemuDomainGetNumaParameters
commands
silent
shell date +%H%M%S
printf "qemuDomainGetNumaParameters"
cont
end

break qemuDomainGetInterfaceParameters
commands
silent
shell date +%H%M%S
printf "qemuDomainGetInterfaceParameters"
cont
end

break qemuDomainSetInterfaceParameters
commands
silent
shell date +%H%M%S
printf "qemuDomainSetInterfaceParameters"
cont
end

break qemuDomainGetDiskErrors
commands
silent
shell date +%H%M%S
printf "qemuDomainGetDiskErrors"
cont
end

break qemuDomainSetMetadata
commands
silent
shell date +%H%M%S
printf "qemuDomainSetMetadata"
cont
end

break qemuDomainGetMetadata
commands
silent
shell date +%H%M%S
printf "qemuDomainGetMetadata"
cont
end

break qemuDomainPMSuspendForDuration
commands
silent
shell date +%H%M%S
printf "qemuDomainPMSuspendForDuration"
cont
end

break qemuDomainPMWakeup
commands
silent
shell date +%H%M%S
printf "qemuDomainPMWakeup"
cont
end

break qemuDomainGetCPUStats
commands
silent
shell date +%H%M%S
printf "qemuDomainGetCPUStats"
cont
end

break qemuDomainObjBeginAsyncJobWithDriver
commands
silent
shell date +%H%M%S
printf "qemuDomainObjBeginAsyncJobWithDriver"
cont
end

break qemuDriverLock
commands
silent
shell date +%H%M%S
printf "qemuDriverLock, driver %s", driver
end

break qemuDriverUnlock
commands
silent
shell date +%H%M%S
printf "qemuDriverUnlock, driver %s", driver
cont
end

