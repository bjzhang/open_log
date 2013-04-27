set breakpoint pending on

set logging on

break libxl_dm.c:459
commands
silent
printf "avail_vcpus.size. b_info->max_vcpus<%d>, nr_set_cpus<%d>\n", b_info->max_vcpus, nr_set_cpus
cont
end

break libxl_dm.c:463
commands
silent
printf "avail_vcpus.size is zero\n"
cont
end

cont

