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
printf "libxlFDRegisterEventHook\n"
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
printf "virEventPollAddHandle: nextWatch<%d>\n", nextWatch
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
printf "cleanup handler: i<%d>, fd<%d>, watch<%d>, info<%p>\n", i, eventLoop.handles[i].fd, eventLoop.handles[i].watch, eventLoop.handles[i].opaque
where 4
cont
end

break conf/domain_conf.c:1929
commands
printf "virDomainObjDispose call privateDataFreeFunc\n"
where 4
cont
end

break libxlDomainObjPrivateFree
commands
printf "libxlDomainObjPrivateFree"
where 2
cont
end

cont
