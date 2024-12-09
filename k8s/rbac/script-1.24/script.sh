#!/bin/bash
# this script is for auto create kubeconfig by k8s administrator
# example: ./script.sh namespace cluster output_kubeconfig_path apiserver_url user role cluster_kubeconfig
# Note: install kubectl

namespace=$1
sa=$5-$6-sa
role=$5-$6-role
roleBingding=$5-$6-rolebinding
cluster=$2
path=$3
server=$4
user=$5
operateRole=$6.yaml
cluster_kubeconfig=$7

# check param whether null
if [ $1 != "" ] && [ $2 != "" ] && [ $3 != "" ] && [ $4 != "" ] && [ $5 != "" ] && [ $6 != "" ] && [ $7 != "" ]; then

    sed -i "s|<namespace>|$namespace|g" ./$operateRole
    sed -i "s|<my-sa>|$sa|g" ./$operateRole
    sed -i "s|<my-role>|$role|g" ./$operateRole
    sed -i "s|<myrolebinding>|$roleBingding|g" ./$operateRole

    kubectl apply -f ./$operateRole --kubeconfig=$cluster_kubeconfig
    secret_name=$(kubectl get secret -n $namespace --kubeconfig=$cluster_kubeconfig| grep $sa | awk 'NR==1 {print $1}')
    echo "secret_name=$secret_name"

    token=$(kubectl describe secret $secret_name -n $namespace --kubeconfig=$cluster_kubeconfig| awk '/token:/{print $2}')
    echo "token=$token"

    kubectl config set-cluster $cluster --server=$server --kubeconfig=$path --insecure-skip-tls-verify=true
    kubectl config set-credentials $user --token=$token --kubeconfig=$path
    kubectl config set-context $user@$namespace --cluster=$cluster --user=$user --kubeconfig=$path
    kubectl config use-context $user@$namespace --kubeconfig=$path

else

    echo "param is not full"
    exit 1

fi