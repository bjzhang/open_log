
1.  虚机建立后插入硬盘。 此处的vda是我们希望vm中的硬盘名称"insert_data_disk.sh vn_name vda":
        ```
        $ insert_data_disk.sh ceph_test_0.6.2_01 vda
        Target     Source
        ------------------------------------------------
        hda        /mnt/images/ceph_test_0.6.0_04.raw
        hdb        /mnt/images/Ceph-CentOS-07.0.x86_64-0.6.0.install.iso

        Device attached successfully

        Target     Source
        ------------------------------------------------
        hda        /mnt/images/ceph_test_0.6.0_04.raw
        hdb        /mnt/images/Ceph-CentOS-07.0.x86_64-0.6.0.install.iso
        vda        /mnt/images/ceph_data_0.6.0_04_vda.raw
        ```
        **libvirt实际会根据已有硬盘个数，重命名为vdX**，下述脚本操作的硬盘以日志结尾的新增的target硬盘为准，例如上面的"vda        /mnt/images/ceph_data_0.6.0_04_vda.raw"

2.  libvirt helper: vm.sh
    1.  ssh: 支持复制ss key并ssh连接。
    2.  ip: 调用get_ip.sh得到vm的ip地址。
    3.  ips: 使用grep得到一组虚机的ip地址。
    4.  list: 列出所有虚机。
    5.  tidb helper:
        1.  tidb_mysql: 连接tidb建立的mysql
        2.  pd, tikv, tidb: 重启tidb相关服务并查看日志。
