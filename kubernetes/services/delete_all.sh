#! /bin/bash

DELETE_COMMAND="kubectl -n kube-system delete"


${DELETE_COMMAND} deployment kubernetes-dashboard

${DELETE_COMMAND} rc heapster

${DELETE_COMMAND} rc kube-dns-v20

${DELETE_COMMAND} svc heapster

${DELETE_COMMAND} svc kube-dns

${DELETE_COMMAND} svc kubernetes-dashboard

