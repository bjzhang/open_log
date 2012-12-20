set breakpoint pending on

set logging on

break libxlTimerCallback
commands
silent
printf "libxlTimerCallback: info<%p>\n", timer_info
cont
end

break libxlFDEventCallback
commands
silent
printf "libxlFDEventCallback: info<%p>\n", fd_info
cont
end

#break libxl_driver.c:152
#commands
#silent
#print info
#end
#
#break libxl_driver.c:279
#commands
#silent
#print info
#end

break virObjectRef
commands
silent
printf "virObjectRef<%p>\n", anyobj
where 2
cont
end

break virObjectUnref
commands
silent
printf "virObjectUnref<%p>\n", anyobj
where 2
cont
end

#break util/event_poll.c:450

break virEventAddTimeout
commands
cont
end

break libxlDomainObjPrivateFree
commands
silent
print "libxlDomainObjPrivateFree\n"
cont
end

break libxlEventInfoFree
commands
silent
print "libxlEventInfoFree\n"
cont
end

break libxlFreeEventInfo
commands
silent
print "libxlFreeEventInfo\n"
cont
end

break libxlTimeoutDeregisterEventHook
commands
silent
print "libxlTimeoutDeregisterEventHook\n"
cont
end

break libxlFDDeregisterEventHook
commands
silent
print "libxlFDDeregisterEventHook\n"
cont
end

break libxlDomainObjPrivateFree
commands
silent
print "libxlDomainObjPrivateFree\n"
where 2
cont
end

break libxlRegisteredEventsCleanup
commands
silent
print "libxlRegisteredEventsCleanup\n"
cont
end

break libxl_ctx_free
commands
silent
print "libxl_ctx_free\n"
where 2
cont
end

break virMutexDestroy
commands
silent
print "virMutexDestroy\n"
where 2
cont
end

break libxlDomainObjPrivateAlloc
commands
silent
print "libxlDomainObjPrivateAlloc\n"
cont
end

break libxl_ctx_alloc 
commands
silent
print "libxl_ctx_alloc\n"
cont
end

break libxl_driver.c:197
commands
silent
printf "libxlFDRegisterEventHook: virMutexLock<%p>\n", &(((libxlDomainObjPrivatePtr)priv)->regLock)
cont
end

break libxl_driver.c:199
commands
silent
printf "libxlFDRegisterEventHook: virMutexUnlock<%p>\n", &(((libxlDomainObjPrivatePtr)priv)->regLock)
cont
end

break libxl_driver.c:233
commands
silent
printf "libxlFDDeregisterEventHook: virMutexLock<%p>\n", &(((libxlEventHookInfoPtr)hnd)->priv->regLock)
cont
end

break libxl_driver.c:235
commands
silent
printf "libxlFDDeregisterEventHook: virMutexUnlock<%p>\n", &(((libxlEventHookInfoPtr)hnd)->priv->regLock)
cont
end

break libxl_driver.c:248
commands
silent
printf "libxlTimerCallback: virMutexLock<%p>\n", &(((libxlEventHookInfoPtr)timer_info)->priv->regLock)
cont
end

break libxl_driver.c:250
commands
silent
printf "libxlTimerCallback: virMutexUnlock<%p>\n", &(((libxlEventHookInfoPtr)timer_info)->priv->regLock)
cont
end

break libxl_driver.c:293
commands
silent
printf "libxlTimeoutRegisterEventHook: virMutexLock<%p>\n", &(((libxlDomainObjPrivatePtr)priv)->regLock)
cont
end

break libxl_driver.c:295
commands
silent
printf "libxlTimeoutRegisterEventHook: virMutexUnlock<%p>\n", &(((libxlDomainObjPrivatePtr)priv)->regLock)
cont
end

break libxl_driver.c:322
commands
silent
printf "libxlTimeoutDeregisterEventHook: virMutexLock<%p>\n", &(((libxlEventHookInfoPtr)hnd)->priv->regLock)
cont
end

break libxl_driver.c:324
commands
silent
printf "libxlTimeoutDeregisterEventHook: virMutexUnlock<%p>\n", &(((libxlEventHookInfoPtr)hnd)->priv->regLock)
cont
end

break libxl_driver.c:369
commands
silent
printf "libxlRegisteredEventsCleanup: virMutexLock<%p>\n", &(((libxlDomainObjPrivatePtr)priv)->regLock)
cont
end

break libxl_driver.c:381
commands
silent
printf "libxlRegisteredEventsCleanup: virMutexUnlock<%p>\n", &(((libxlDomainObjPrivatePtr)priv)->regLock)
cont
end

cont
