
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
