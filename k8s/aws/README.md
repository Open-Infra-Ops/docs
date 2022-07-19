# AWS eks集群创建及使用
Kubernetes版本1.22<br>
## 环境
kubectl 1.22版本（建议与Kubernetes版本保持一致）<br>
aws cli   2.7.16（安装最新版本即可）<br>
**kubectl安装**<br>
curl -o kubectl https://s3.us-west-2.amazonaws.com/amazon-eks/1.22.6/2022-03-09/bin/linux/amd64/kubectl
chmod +x ./kubectl
mkdir -p $HOME/bin && cp ./kubectl $HOME/bin/kubectl && export PATH=$PATH:$HOME/bin
kubectl version --short --client<br>

**aws cli安装**<br>
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
 ./aws/install -i `/usr/local/aws-cli` -b `/usr/local/bin`
 aws --version<br>


# 创建 Amazon EKS 集群
可以使用 `eksctl`、AWS Management Console 或 AWS CLI 创建集群<br>
本次实践中采用**AWS管理控制台**创建集群的方式<br>
详细步骤参考 [# eks集群创建](https://docs.aws.amazon.com/zh_cn/eks/latest/userguide/create-cluster.html)

# 创建集群Kubeconfig
注意：集群创建完成后，在linux机器上需要通过aws cli配置用户信息，由于在管理控制台创建的集群，<br>
所以，集群创建用户为**AWS 根用户**<br>
**aws configure**<br>
**AWS Access Key ID**：<根用户AK><br>
**AWS Secret Access Key**：<根用户SK><br>
**Default region name**：<集群region><br>
**Default output format**：json<br>
**aws sts get-caller-identity** #配置完成，可使用该命令查询当前aws cli使用用户信息，显示格式类似<br>
{
    "UserId": "xxx",
    "Account": "xxx",
    "Arn": "arn:aws:iam::xxx:root"
}<br>
Kubeconfig创建分为**自动和手动**两种方式，本次实践采用**自动创建**<br>
**aws eks update-kubeconfig --region [region-name] --name [cluster-name]**<br>
输出如下<br>
Updated context arn:aws:eks:[region-name]:[account-id]:cluster/<cluster-name> in /root/.kube/config

# 问题处理
## **error: You must be logged in to the server (Unauthorized)**
出现场景<br>
**kubectl get svc --kubeconfig=./config**<br>
该问题表明aws cli未登陆，分析发现，aws cli配置的用户信息非集群的创建者，而是登陆aws根用户在aws控制台手动创建集群后，使用IAM用户登陆aws cli，虽然该IAM用户具有eks集群的部分权限，但是由于该用户并非集群的创建用户，集群的role信息中没未对该用户授权。<br>
**官方解释**<br>
创建 Amazon EKS 集群后，创建集群的 IAM 实体（用户或角色）将添加到 Kubernetes RBAC 授权表中作为管理员（具有 `system:masters` 权限）。最初，仅该 IAM 用户可以使用 `kubectl` 调用 Kubernetes API 服务器。有关更多信息，请参阅 [让 IAM 用户和角色有权访问您的集群](https://docs.aws.amazon.com/zh_cn/eks/latest/userguide/add-user-role.html)。如果使用控制台创建集群，则必须确保在集群上运行 `kubectl` 命令时，相同的 IAM 用户凭证位于AWS开发工具包凭证链中。<br>
**解决办法**<br>
使用aws 根用户ak、sk登陆cli，再生成kubeconfig文件，即可访问集群资源<br>
## **Kubeconfig user entry is using deprecated API version client.authentication.k8s.io/v1alpha1. Run 'aws eks update-kubeconfig' to update.**

**出现场景**：**kubectl get svc --kubeconfig=./config**<br>
该问题表明k8s api版本不对，需要更新kubeconfig文件，查看生成的kubeconfig文件发现，**users.user.exec.apiVersion**为**client.authentication.k8s.io/v1alpha1**，但是该版本在kubernetes v1.22已不再支持<br>
**解决办法**：手动修改**apiVersion**为**client.authentication.k8s.io/v1beta1**<br>

# 参考文献

[# eks集群创建](https://docs.aws.amazon.com/zh_cn/eks/latest/userguide/create-cluster.html)<br>

[# Kubeconfig创建](https://docs.aws.amazon.com/zh_cn/eks/latest/userguide/create-kubeconfig.html)<br>