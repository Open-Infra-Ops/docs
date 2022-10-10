#!/bin/bash
# this script is for deleting exist role by k8s administrator
# example: ./deleteRoleScript.sh namespace cluster_kubeconfig_path user operateRole
# Note: install kubectl

namespace=$1
cluster_kubeconfig_path=$2
roleName=$3-$4-role
roleBingdingName=$3-$4-rolebinding
serviceaccount=$3-$4-sa
operateRole=$4

# check param whether null
if [ $1 != "" ] && [ $2 != "" ] && [ $3 != "" ] && [ $4 != "" ] ; then

    if [ $operateRole == "viewer" ]; then 
        kubectl delete role $roleName -n $namespace --kubeconfig=$cluster_kubeconfig_path
        kubectl delete rolebinding $roleBingdingName -n $namespace --kubeconfig=$cluster_kubeconfig_path
        kubectl delete sa $serviceaccount -n $namespace --kubeconfig=$cluster_kubeconfig_path

    elif [ $operateRole == "developer" ]; then
        kubectl delete role $roleName -n $namespace --kubeconfig=$cluster_kubeconfig_path
        kubectl delete rolebinding $roleBingdingName -n $namespace --kubeconfig=$cluster_kubeconfig_path
        kubectl delete sa $serviceaccount -n $namespace --kubeconfig=$cluster_kubeconfig_path

    elif [ $operateRole == "admin" ]; then
        kubectl delete sa $serviceaccount -n $namespace --kubeconfig=$cluster_kubeconfig_path
        kubectl delete ClusterRole $roleName --kubeconfig=$cluster_kubeconfig_path
        kubectl delete rolebinding $roleBingdingName -n $namespace --kubeconfig=$cluster_kubeconfig_path
    else
        echo "operateRole not exist"
        exit 1
    fi

else

    echo "param is not full"
    exit 1

fi