set breakpoint pending on

#break libxlCheckMessageBanner
#commands 
#print libxlCheckMessageBanner
#cont
#end

break virDispatchError
commands 
silent
print virDispatchError
if ( 0 ==  virLastErrorObject()->code ) 
    where
end
continue
end

break libxl/libxl_driver.c:4093
commands
silent
p "libxlCheckMessageBanner 1st"
continue
end

#break libxl/libxl_driver.c:4102
#commands
#silent
#p "libxl_domain_suspend"
#continue
#end
break libxl_domain_suspend
commands
silent
p "libxl_domain_suspend"
continue
end

break libxl/libxl_driver.c:4110
commands
silent
p "libxlCheckMessageBanner 2nd"
target record
continue
end 

break libxl_domain_resume
commands
silent
p "libxl_domain_resume"
#continue
end

break libxl/libxl_driver.c:4324
commands
silent
p "virNetSocketGetFD"
continue
end 

break libxl/libxl_driver.c:4331
commands
silent
printf "ret is %d\n", ret
continue
end 

#break libxlEventHandler
#commands
#silent
#p "libxlEventHandler"
#where
#cont
#end

#breakpoints for saferead
#break util/util.c:104
#commands
#silent
#printf "104: buf is %s, errno is %d, ret is %d\n", buf, errno, r
#cont
#end
#
#break util/util.c:106
#commands
#silent
#printf "106: buf is %s, errno is %d, ret is %d\n", buf, errno, nread
#cont
#end
#
#break util/util.c:111
#commands
#silent
#printf "111: buf is %s, errno is %d, ret is %d\n", buf, errno, nread
#cont
#end
#
