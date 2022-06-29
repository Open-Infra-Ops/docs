#!/bin/bash
# this script is for auto create kubeconfig by k8s administrator
# example: ./script.sh namespace cluster_name kubeconfig_path apiserver_url cluster_user
# Note: install kubectl

namespace=$1
sa=$1-sa
role=$1-role
cluster=$2
path=$3
server=$4
user=$5

sed -i "s|<namespace>|$namespace|g" ./rbac.yaml
sed -i "s|<my-sa>|$sa|g" ./rbac.yaml
sed -i "s|<my-role>|$role|g" ./rbac.yaml

kubectl apply -f ./rbac.yaml
secret_name=$(kubectl get secret -n $namespace | grep $sa | awk '{print $1}')
echo "secret_name=$secret_name"

token=$(kubectl describe secret $secret_name -n $namespace | awk '/token:/{print $2}')
echo "token=$token"

kubectl config set-cluster $cluster --server=$server --kubeconfig=$path --insecure-skip-tls-verify=true
kubectl config set-credentials $user --token=$token --kubeconfig=$path
kubectl config set-context $user@$namespace --cluster=$cluster --user=$user --kubeconfig=$path
kubectl config use-context $user@$namespace --kubeconfig=$path