## Running a

- requirements

A Kubernetes cluster with Flocker installed

1.setup environment variables
```
export FLOCKER_CONTROL_SERVICE=
export KUBECONFIG=clusters/<NAME OF K8s CLUSTER>/kubeconfig
```

2. replace the following variables in the makefile
```
DISK_SIZE=100G
KUBECONFIG=clusters/replica-m3-2xlarge-set/kubeconfig
CONTROL_DNS=<Flocker Control DNS>
INITIAL_NODE_ID=ec570512
```

3. create volumes
I created a make file to make creation of volumes easier based on how many active mongo pods are currently deployed`
```
`make create-volume`

flockerctl --control-service=ec2-52-86-240-175.compute-1.amazonaws.com create -m name=flockermongorc-3 -s 100G --node=ec570512
created dataset in configuration, manually poll state with 'flocker-volumes list' to see it show up.
```

4. deploy a replica pod
`make add-replica`

This will deploy a pod to your cluster and create a copy of the spec file for you to manually use if needed from a template file.

kubectl create -f mongo-rc-1.yaml
kubectl delete -f mongo-rc-1.yaml


## To use emptydir (no flocker)

There are no make commands yet for this I have included 4 example replication controller templates for using emptydir in /emptydir

`kubectl create -f emptydir/mongo-rc-1.yaml`