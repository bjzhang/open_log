
1.  Personal statement
I am looking for an opportunity which I could have a passion in it: Linux kernel, open source and ARM.

* I installed Linux in my computer when I am in high school which is the same year I get my first PC.
* I was curious about how does people port Linux to an architecture or a SOC in my graduate. And I finally get a chance to port Nucleus and Linux to our arm SOC 5 years ago.
* I fall in love with open source after I join SUSE in 2011.

All I want to say is that I am not an early bird, but working on Linux kernel and contributing to upstream is my passion.

BTW, I am interested in learning new language. I learned very basic words for German and Japanese from my friend.

1.  HUAWEI(07/2014- ):
    1.  Job title: Senior software engineer
    2.  Organizaiton: HUAWEI
    3.  Responsibilities
        1.  (From April): HUAWEI linaro assignee in kwg(Kernel working group).
            * Join the development for y2038, focus on the ioctl in driver code.
            * Bugfix for kselftest for arm and arm64. There are 7 patches under review in LKML.

        2.  Internal ILP32 maintainer for kernel and glibc.
            Develop the aarch64 ILP32 of kernel and glibc base on the very early patches from commnunity, fix handreds of failures in LTP test. Compare with the lastest community patches(kernel and glibc part is not upstream yet), there are **12** patches(bugfix) for kernel, glibc, LTP and buildroot in our git repo.

        3.  As a consultant, provide suggestion and troubleshooting for migration from old Linux kernel or arm 32bit hardware to lastest Linux on arm64 hardware, including kernel abi selection(aarch32, aarch64 ILP32, aarch64 LP64), kernel abi changes and update suggestion, glibc changes and suggestion.

        4.  Join openSUSE Asia Submit 2014 and give the presentation named "[openSUSE on ARM](https://github.com/openSUSE-CN/oSA2014-slides/blob/master/Bamvor_Jian_Zhang-openSUSE_on_Arm.pdf)"
    4.  Explanation
        I like the work in here(Linux kernel, arm, open source), But too many hours to work(ten hours per day in three month). It is hard to work here in long time.

2.  SUSE(01/2011-07/2014):
    1.  Job title: Software engineer
    2.  Organizaiton: SUSE(Beijing)
    3.  Responsibilities
        1.  Develop new feature and fix bug in virtualzation management tools, including libvirt, xen and qemu.
            Features including migration, snapshot and so on.
            Fix critical bug in libvirt libxl drivers after the xen package upgrade.
        2.  Play openSUSE on my arm board in hackweek and my spare time. Our opensuse arm team got an reward in hackweek.
            The first person port cubietruck(Cortex-A7 powered SOC) to [xen](http://wiki.xen.org/wiki/Xen_ARM_with_Virtualization_Extensions/Allwinner).
        3.  Totally 11 patches got accept.
    4.  Explanation
        Want to look for the job which could focus on Linux kernel

3.  Vimicro(12/2008-01/2011):
    1.  Job title: Software engineer
    2.  Organizaiton: Vimicro
    3.  Responsibilities
        1.  As a key member join the first Cortex-A8 powered arm SOC project from pre-research to the mass production of the Android pad.
        2.  Porting Nucleus and Linux to our SOC.
        3.  Due to the deep knowlege of the software stack and SOC design, fix **a critical bug** during SOC mass produciton. This bug is a power management bug. I write a small piece of hacking code to trigger special boot and suspend/resume sequence with our rom bootloader, u-boot and kernel.
    4.  Explanation
        The company do not want to update the lastest arm processs core anymore which block my technique patch.

19:59 2015-08-26
----------------
1.  recommandation letter.
Hi Axel,
I trust everything is going great over there. I miss OpenSynergy and Berlin a lot but I'm very happy to be back with my family.

My friend Bamvor Zhang wants to move to Germany from Beijing and I thought he can be a great addition to your team. He has several years of experience with ARM, the Linux kernel and Xen, having worked porting them to different SoCs. He has also been very active in open source communities. His English is quite good, he is friendly, and he loves what he does.

You can find a short CV from him in https://careers.stackoverflow.com/bamvor and his mail address is <bamv2005@gmail.com>

best regards,
Alejandro Mery

1.  cover letter for opensynergy
Dear Manager

I am very excited to hear of your available Software Engineer – Embedded Linux (f/m) position, and formally submit my resume for consideration.

I work on Linux, arm and virtualization more than 7 years after I got Master Degree.

I installed Linux in my computer when I am in high school which is the same year I get my first PC. I was curious about how does people port Linux to an architecture or a SOC in university. And I finally get a chance to port Nucleus and Linux to our arm SOC 5 years ago. I am definitely not an early bird, but working on Linux kernel is my passion.

When I work for vimicro, I take the responsibility for verifying the arm processor(not SOC) and upgrade our development environment from arm 9 to Cortex-A8. Thanks to this opportunity, I got plenty of time to dig into the arm architecture, debug tools and arm SOC. I also write assembly code for initialization the soc or finding out the failure of the soc. With the deep knowledge of arm and SOC, life is eaiser to understand the device driver and virtualization things.

I learn differenct part of Linux kernel, including memory management, architecture relative code, device driver and so on.

I experience in virtualization area(hypervisor and tools) more than two years.

BTW, I am interested in learning new language. I learned very basic words for German and Japanese from my friends.

Salary expertation: First of all, the opportunity is more important than the salary. My current package is 400k RMB per year(20000 x 12 month plus 8 month bonus). If this job is in China, I would say that I want roughly 30% more salary. But I have no idea the salary in Germany. Basically, I want to move the Germany because I hope we could work-life-balance: My wife will not work in Germany(My second daughter is 7 month at this moment).

I could on boarding one month later(for resigning from HUAWEI) after I got the offer and visa.

BTW: I have sent them in the website, but no response on website nor email. So, I send them again. Sorry for inconvenience.

2.  resume for opensynergy
You have completed a BS or MS in Computer Science, Electrical Engineering or in a related field
You have experience in the development of embedded software and development of operating systems
Excellent programming skills in C/C++ and optionally low-level assembly programming, especially on the ARM architecture
You understand the overall architecture of the Linux Kernel and have already done kernel-level programming in Linux or comparable operating systems
We are specifically interested in candidates who have additional experience in virtualization technologies
You are familiar with professional software development processes and tools
You are able to develop creative solutions for complex software problems
You feel happy in a cooperatively managed team environment
You have a good command of English (for technical work) and at least basic German (for day to day interaction)
You are goal-oriented and can work independently but are ready to adjust quickly to the demands of our customers.

00:46 2015-09-23
----------------
1.  In Huawei
    I focus on the features we need when we migratie from the old arm32 with old kernel(2.6.x or 3.x) to the our lastest stable kernel(4.x). E.g. ILP32 on aarch64, binary compatability when upgrade the kernel and glibc.

2.  In Vimicro
    The main of issue of the project we encountered is we upgraded the cpu from arm9 to Cortex-A8.

