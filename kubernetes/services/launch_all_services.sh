#! /bin/bash

FILES="dns-svc.yaml dns.yaml heapster-controller.yaml heapster-service.yaml kubernetes-dashboard.yaml"

for i in $(echo $FILES) ; do { kubectl apply -f  $i; }; done
