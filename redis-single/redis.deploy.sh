# Create a Redis Master Pod
kubectl create -f redis.master.controller.yaml

# Create a Redis Master Service
kubectl create -f redis.master.service.yaml