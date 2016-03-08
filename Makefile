NUM_REPLICAS=$(shell kubectl get rc -l role=mongo -o template --template='{{ len .items }}')
NEW_REPLICA_NUM=$(shell expr $(NUM_REPLICAS) + 1 )
ENV=FLOCKERAWS
CREATE_SERVICE=FALSE

DISK_SIZE=100G
KUBECONFIG=clusters/<K8s Cluster Name>/kubeconfig
CONTROL_DNS=<FLOCKER CONTROL DNS>
INITIAL_NODE_ID=<A FLOCKER NODE ID TO SEED A VOLUME>

count:
	@echo 'Current Number of MongoDB Replicas: $(NUM_REPLICAS)'
create-volume:
	-flockerctl --control-service=$(CONTROL_DNS) create -m name=flockermongorc-$(NEW_REPLICA_NUM) -s $(DISK_SIZE) --node=$(INITIAL_NODE_ID)
add-replica:
ifeq ($(ENV),GoogleCloudPlatform)
	@echo 'Hello'
	-gcloud compute disks create mongo-persistent-storage-node-$(NEW_REPLICA_NUM)-disk --size $(DISK_SIZE) --zone $(ZONE)

	@echo 'Adding Replica'
	-touch mongo-rc-$(NEW_REPLICA_NUM).yaml
	-ls
	-sed -e 's~<num>~$(NEW_REPLICA_NUM)~g' mongo-controller-template.yaml | tee mongo-rc-$(NEW_REPLICA_NUM).yaml
	-kubectl create -f mongo-rc-$(NEW_REPLICA_NUM).yaml
endif
ifeq ($(ENV),AWS)
	@echo 'AWS not supported yet'
endif
ifeq ($(ENV),FLOCKERAWS)
	@echo 'Adding Replica'

	-touch mongo-rc-$(NEW_REPLICA_NUM).yaml
	-ls
	-sed -e 's~<num>~$(NEW_REPLICA_NUM)~g' mongo-controller-template.yaml | tee mongo-rc-$(NEW_REPLICA_NUM).yaml
	-kubectl create -f mongo-rc-$(NEW_REPLICA_NUM).yaml
endif

add-service:
ifeq ($(CREATE_SERVICE),TRUE)
	@echo 'Creating Service'
	-touch mongo-svc-$(NEW_REPLICA_NUM).yaml
	-ls
	-sed -e 's~<num>~$(NEW_REPLICA_NUM)~g' mongo-service-template.yaml | tee mongo-svc-$(NEW_REPLICA_NUM).yaml
	kubectl create -f mongo-svc-$(NEW_REPLICA_NUM).yaml
endif

# delete-replica:
# 	@echo 'Deleting Service'
# 	-kubectl delete svc mongo-$(NUM_REPLICAS)
# ifeq ($(ENV),GoogleCloudPlatform)
# 	@echo 'Deleting Replic'
# 	-kubectl delete rc mongo-$(NUM_REPLICAS)

# 	@echo 'Deleting Disk'
# 	sleep 60
# 	-yes | gcloud compute disks delete mongo-persistent-storage-node-$(NUM_REPLICAS)-disk --zone $(ZONE)
# endif
# ifeq ($(ENV),AWS)
# 	@echo 'AWS not supported yet'
# endif
