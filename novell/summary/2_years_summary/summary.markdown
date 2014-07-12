# overview

文档中要体现联系。
opensuse, virtualization, arm, build service.

suse tools
==========

# quilt

# osc

# zypper

## how to install a package from different vendor?
    zypper in -r your_repo_id_or_your_repo_name your_package_name

it works, but it will fail you when "your\_packge\_name" need install the dependency packages from others repo.
my suggestion is
    zypper in your_package_full_name_or_capatability
e.g.
    zypper in "xen-tools>=4.4"

# repo除了用名字还可以用id
    #zypper repos

    #  | Alias                        | Name                                                                    | Enabled | Refresh
    ---+------------------------------+-------------------------------------------------------------------------+---------+--------
     1 | Education_openSUSE_13.1      | Education_openSUSE_13.1                                                 | Yes     | Yes    
     2 | Emulators_openSUSE_13.1      | Emulators_openSUSE_13.1                                                 | Yes     | Yes    
     3 | Virtualization_openSUSE_13.1 | Virtualization_openSUSE_13.1                                            | Yes     | Yes    
    ...

下面两个命令是一样的：
    zypper ar -d 3
    zypper ar -d Virtualization_openSUSE_13

# zypper也可以指定本地rpm包安装（推荐）

# zypper ar
    addrepo (ar) [options] <URI> <alias>
    addrepo (ar) [options] <file.repo>

如果是repo都会有file.repo这个文件，比自己写alias省事，例如：
    zypper ar -c -f http://download.opensuse.org/repositories/home:/arvidjaar:/grub2-next/openSUSE_13.1/home:arvidjaar:grub2-next.repo
会加入如下repo:
     4 | home_arvidjaar_grub2-next    | Staging project for next version of grub2 and os-prober (openSUSE_13.1) | Yes     | Yes

