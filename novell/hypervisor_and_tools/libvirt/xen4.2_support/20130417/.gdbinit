set breakpoint pending on

set logging on

break libxlEventHookInfoFree
commands
silent
printf "libxlEventHookInfoFree: info<%p>, info->priv<%p>\n", (libxlEventHookInfoPtr)obj, ((libxlEventHookInfoPtr)obj)->priv
where 4
cont
end

break libxlFDRegisterEventHook
commands
silent
printf "libxlFDRegisterEventHook: priv<%p>\n", priv
print *((libxlDomainObjPrivatePtr)priv)
where
cont
end

break libxl/libxl_driver.c:192
commands
silent
printf "libxlFDRegisterEventHook: virEventAddHandle fail\n"
cont
end

break libxlFDDeregisterEventHook
commands
silent
printf "libxlFDDeregisterEventHook: info<%p>, info->id<%d>\n", (libxlEventHookInfoPtr)hnd, ((libxlEventHookInfoPtr)hnd)->id
print *(libxlEventHookInfoPtr)hnd
where
cont
end

break virEventPollAddHandle
commands
silent
printf "virEventPollAddHandle: nextWatch<%d>, info<%p>, info->priv<%p>\n", nextWatch, (libxlEventHookInfoPtr)opaque, ((libxlEventHookInfoPtr)opaque)->priv
#print *((libxlEventHookInfoPtr)opaque)->priv
where 4
cont
end

#break util/vireventpoll.c:192
#commands
#silent
#printf "mark delete: i<%d>, fd<%d>\n", i, eventLoop.handles[i].fd
#where 4
#cont
#end
#
#break util/vireventpoll.c:193
#commands
#silent
#printf "mark delete: i<%d>, fd<%d>\n", i, eventLoop.handles[i].fd
#where 4
#cont
#end
#
break util/vireventpoll.c:582
commands
silent
printf "cleanup handler: i<%d>, fd<%d>, watch<%d>, info<%p>\n", i, eventLoop.handles[i].fd, eventLoop.handles[i].watch, eventLoop.handles[i].opaque
where 4
cont
end

break conf/domain_conf.c:1929
commands
silent
printf "virDomainObjDispose call privateDataFreeFunc\n"
where 4
cont
end

break virDomainObjDispose
commands
silent
printf "virDomainObjDispose\n"
where 4
cont
end

break libxlDomainObjPrivateAlloc
commands
silent
printf "libxlDomainObjPrivateAlloc\n"
where 2
cont
end

break libxl_osevent_register_hooks
commands
silent
printf "libxl_osevent_register_hooks: priv<%p>, priv->lock<%p>\n", priv, priv->lock
cont
end

break libxlDomainObjPrivateFree
commands
silent
printf "libxlDomainObjPrivateFree"
where 2
cont
end

break libxlVmReap
commands
silent
printf "libxlVmReap"
where 4
cont
end

break libxl_osevent_occurred_fd
commands
silent
printf "libxl_osevent_occurred_fd"
cont
end

cont

