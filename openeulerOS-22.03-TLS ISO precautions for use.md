* openeulerOS-22.03-TLS ISO使用注意事项

  > Edit: 2022-08

1. openeulerOS-22.03-LTS 网卡使用systemctl NetworkManager 进行管理

   ```
   systemctl status NetworkManager 
   ```

2. 使用openeulerOS-22.03-LTS 替换现有arm架构主机系统后，主机可能会出现网卡无ip地址的情况，此时需要修改网卡信息：使其网卡名称与ifconfig 显示一致;无ifconfig时，使用ip add 查看network-name；

   ```
    /etc/sysconfig/network-scripts/<network-name>
   ```

3. 同时需要添加/etc/ssh/sshd_config中的ssh 协商规则

   ```
   HostkeyAlgorithms ssh-rsa
   ```

   /etc/ssh/sshd_config 中没有HostkeyAlgorithms 字段时，单独添加上面一行信息；

   /etc/ssh/sshd_config 中有HostkeyAlgorithms  字段时，在行尾追加ssh-rsa ;

