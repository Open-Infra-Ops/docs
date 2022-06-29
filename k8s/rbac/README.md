# 通过配置kubeconfig文件实现集群权限精细化管理

  
  

#### 问题场景

  

kubernetes管理员需对namespace下的资源进行权限精细化管控，资源包括deployment、service、secret、

  

configmap、pod等，操作包括创建、删除、获取等。

  

# 配置方法
 - **管理员连接集群，创建serviceaccount、role、rolebinding**<br>
**kubectl apply -f rbac.yaml**<br>             # 编辑rbac.yaml文件，修改待编辑的参数
**参数说明**
**my-sa** serviceaccount名称
**namespace** 需进行权限管控的命名空间
**my-role** role名称
**resources** k8s资源，如pod、pod/logs、pod/exec、deployment、secret、configmap
**verbs** 权限，如get、watch、list、delete、create、exec

 - **生成kubeconfig文件**<br>
**kubectl get secret -n namespace | grep my-sa **<br>            # **serviceaccount**的名称**my-sa**获取对应的密钥，第一列的**my-sa-token-5gpl4**，即为密钥名<br>
**kubectl config set-cluster test-arm --server=https://10.0.1.100:5443 --kubeconfig=./test.config --insecure-skip-tls-verify=true**<br>                                                 # 生成kubeconfig文件，其中**test-arm**为需要访问的集群，**https://10.0.1.100:5443**为集群apiserver地址，通常需要从外网访问集群，一般配置apiserver的公网ip<br>
**token=$(kubectl describe secret my-sa-token-5gpl4 -n namespace | awk '/token:/{ print \$2}')**<br>           #获取集群token<br>
**kubectl config set-credentials ui-admin --token=$token --kubeconfig=./test.config**<br> # 设置集群用户**ui-admin**，此用户名任意，指定的kubeconfig路径即为生成的kubeconfig文件存放路径<br>
**kubectl config set-context ui-admin@namespace --cluster=test-arm --user=ui-admin --kubeconfig=./test.config**<br>            # 配置上下文信息，**ui-admin**、**namespace**、**test-arm**、**./test.config**分别为前文中指定的**用户名**、**命名空间**、**集群名称**、**kubeconfig路径**<br>
**kubectl config use-context ui-admin@namespace --kubeconfig=./test.config**<br>        # 设置上下文信息

 # shell脚本生成kubeconfig
 - **环境准备**
kubectl
[# Install Kubectl](https://kubernetes.io/docs/tasks/tools/)<br>

 - **使用对象**
 k8s集群管理员
 
 - **执行命令**
 ./script.sh namespace cluster_name kubeconfig_path apiserver_url cluster_user<br>      # **namespace**，授权的命名空间<br>       # **cluster_name** ，集群名称<br>      # **kubeconfig_path**，生成的kubeconfig存放路径<br>  # **apiserver_url**，集群apiserver地址，格式**https://10.0.1.100:5443**<br>     # **cluster_user**，创建的kubeconfig用户对象名


# 参考文献

  

[# 通过配置kubeconfig文件实现集群权限精细化管理](https://support.huaweicloud.com/bestpractice-cce/cce_bestpractice_00221.html)<br>

  

[# Authenticating](https://kubernetes.io/docs/reference/access-authn-authz/authentication/)<br>