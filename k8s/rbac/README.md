# 通过配置kubeconfig文件实现集群权限精细化管理

#### 问题场景
kubernetes管理员需对namespace下的资源进行权限精细化管控，资源包括deployment、service、secret、
configmap、pod等，操作包括创建、删除、获取等。


# 配置方法
1. 编辑rbac.yaml文件，修改待编辑的参数，执行**kubectl apply -f rbac.yaml**。
**参数说明**
**my-sa**             serviceaccount名称
**namespace**    需进行权限管控的命名空间
**my-role**          role名称
**resources**       k8s资源，如pod、pod/logs、pod/exec、deployment、secret、configmap
**verbs**              权限，如get、watch、list、delete、create、exec

2. 通过serviceaccount的名称**my-sa**获取对应的密钥，第一列的**my-sa-token-5gpl4**即为密钥名
kubectl get secret -n **namespace** | grep **my-sa**

3. 生成kubeconfig文件
其中**test-arm**为需要访问的集群，**10.0.1.100**为集群apiserver地址，通常需要从外网访问集群，
一般配置apiserver的公网ip。
kubectl config set-cluster **test-arm** --server=https://**10.0.1.100**:5443 --kubeconfig=**./test.config** --insecure-skip-tls-verify=true

4. 获取集群token
token=$(kubectl describe secret **my-sa-token-5gpl4** -n **test** | awk '/token:/{print $2}')

5. 设置集群用户
kubectl config set-credentials **ui-admin** --token=$token --kubeconfig=**./test.config**

6. 配置集群用户访问的上下文信息
kubectl config set-context **ui-admin@namespace** --cluster=**test-arm** --user=**ui-admin** --kubeconfig=**./test.config**

7. 设置上下文信息
kubectl config use-context **ui-admin@namespace** --kubeconfig=**./test.config**

# 参考文献
[# 通过配置kubeconfig文件实现集群权限精细化管理](https://support.huaweicloud.com/bestpractice-cce/cce_bestpractice_00221.html)
[# Authenticating](https://kubernetes.io/docs/reference/access-authn-authz/authentication/)