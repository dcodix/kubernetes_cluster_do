#! /bin/bash

#Check variables
PATH_TO_CERTIFICATES_XX="${PATH_TO_CERTIFICATES}_XX"
if [ ${PATH_TO_CERTIFICATES_XX} == "_XX" ]; then
{
    echo "ERROR: PATH_TO_CERTIFICATES not set."
    exit 1
}; fi

K8S_AUTH_TOKEN_XX="${K8S_AUTH_TOKEN}_XX"
if [ ${K8S_AUTH_TOKEN_XX} == "_XX" ]; then
{
    echo "ERROR: K8S_AUTH_TOKEN not set."
    exit 1
}; fi

NUMBER_OF_NODES_XX="${NUMBER_OF_NODES}_XX"
if [ ${NUMBER_OF_NODES_XX} == "_XX" ]; then
{
    echo "INFO: Number of nodes default to 1."
    NUMBER_OF_NODES=1
}; fi

#Run terraform
terraform apply -var "n_nodes=${NUMBER_OF_NODES}"
if [ $? -ne 0 ]; then
{
    echo "ERROR: Failed to to launch infrastructure with terraform"
}; fi

#Setup kubectl config file
if [ ${SETUP_KUBECTL} -eq 1 ]; then
{
    kubectl config set-cluster default-cluster --server=https://kubernetes-master:6443 --insecure-skip-tls-verify=true

    kubectl config unset clusters

    kubectl config set-cluster default-cluster --certificate-authority=${PATH_TO_CERTIFICATES}/ca.crt --embed-certs=true --server=https://kubernetes-master:6443 --token=${K8S_AUTH_TOKEN}
    if [ $? -ne 0 ]; then
    {
        echo "ERROR: Failed at kubectl set-cluster step"
        exit 1
    }; fi

    kubectl config set-credentials kubelet --client-certificate=${PATH_TO_CERTIFICATES}/mykubectl.crt --client-key=${PATH_TO_CERTIFICATES}/mykubectl.key --embed-certs=true --token=${K8S_AUTH_TOKEN}
    if [ $? -ne 0 ]; then
    {
        echo "ERROR: Failed at kubectl set-credentials step"
        exit 1
    }; fi

    kubectl config set-context default-context --namespace=default --cluster=default-cluster --user=kubelet

    kubectl config use-context default-context
}; fi

#REMEMBER
echo
echo "**** REMEMBER: kubernetes-master should resolve to the master public IP.****"
echo

#Launch all services
cd kubernetes/services
if [ $? -ne 0 ]; then
{
    echo "ERROR: Could not chdir to services directory."
    exit 1
}; fi

SERVICE_FILES="dns-svc.yaml dns.yaml heapster-controller.yaml heapster-service.yaml kubernetes-dashboard.yaml"

for i in $(echo ${SERVICE_FILES}) ; do
{
    kubectl apply -f  $i
    if [ $? -ne 0 ]; then
    {
        echo "WARNING: Could not launch ${i} ."
    }; fi
}; done