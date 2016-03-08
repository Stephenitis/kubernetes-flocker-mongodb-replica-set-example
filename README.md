## Running a Mongo Replica Set on Kubernetes

### requirements
- A Kubernetes cluster
- Flocker installed

### 1. setup environment variables in your local client terminal
```
export FLOCKER_CONTROL_SERVICE=
export KUBECONFIG=clusters/<NAME OF K8s CLUSTER>/kubeconfig
```

###  2. replace the following variables in the Makefile
```
DISK_SIZE=100G
KUBECONFIG=clusters/replica-m3-2xlarge-set/kubeconfig
CONTROL_DNS=<Flocker Control DNS>
INITIAL_NODE_ID=ec570512
```

###  3. create volumes
I created a make file to make creation of volumes easier based on how many active mongo pods are currently deployed`
```
$ make create-volume

# flockerctl --control-service=ec2-52-86-240-175.compute-1.amazonaws.com create -m name=flockermongorc-3 -s 100G --node=ec570512
# created dataset in configuration, manually poll state with 'flocker-volumes list' to see it show up.
```

###  4. deploy a replica pod
$ `make add-replica`

This will deploy a pod to your cluster and create a copy of the spec file for you to manually use if needed from a template file.

`kubectl create -f mongo-rc-1.yaml`
`kubectl delete -f mongo-rc-1.yaml`


### Useful Kubernetes commands

`kubectl get po,no -o wide`                                               
```
NAME            READY     STATUS              RESTARTS   AGE       NODE                        IP
mongo-1-w7paz   2/2       Running             0          43m       ip-10-0-0-96.ec2.internal   <none>
mongo-2-ytmn1   2/2       Running             0          2h        ip-10-0-0-97.ec2.internal   <none>
mongo-3-527pz   0/2       ContainerCreating   0          10s       ip-10-0-0-98.ec2.internal   <none>
```
`kubectl describe po mongo-1-w7paz`
This will output the pod ip address and information about the volyme
under Volumes you will see **<Volume Type Not Found>** instead of Flocker but it will be working
Volumes:
  mongo-persistent-storage:
  <Volume Type Not Found>
  default-token-y21eu:
    Type:	Secret (a secret that should populate this volume)
    SecretName:	default-token-y21eu


###  To use emptydir (no flocker)

There are no make commands yet for this I have included 4 example replication controller templates for using emptydir in /emptydir

`kubectl create -f emptydir/mongo-rc-1.yaml`
