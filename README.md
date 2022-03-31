Kubernetes Cluster
=================

Overview
---------
- The cluster is capable of horizontally autoscale as demand increases.
- Use EFS storage so state are persisted across nodes. 
- Use EFS CSI Driver (but currently using **statically** provisioned EFS volumes)
- Currently using Fargate for the k8s nodes - will add EC2 support soon.

Workstation Setup
-----------------
- You'll need tools :
    - kubectl
    - eksctl
    - helm
    - docker
These should be installed via ```prpl/deploy/aws/scripts/cloud-dev-install.sh```


Deploying the Cluster for 1st time
-----------------------------------
- The cluster is deployed via terraform.
- It does not use helm or kubernetes provider - since this would be a circular dependancy.
- The other k8s modules used for deploying things into this EKS e.g. EFS CSI Driver from Amazon. 
- Run the terraform.
 

Configure kubectl for the new Cluster
-------------------------------------
Note: replace instances (below) of :
- <ENV> with applicable aws account e.g. backbone, core, prod, etc...
- <CLUSTER-NAME> with your cluster name e.g. prpl-backbone-k8s

# Configure kubectl to connect to the EKS Cluster :
```shell script
aws-vault exec prpl-$(basename $(realpath .)) -- aws eks update-kubeconfig --region eu-west-1 --name <CLUSTER-NAME>
# To see what clusters have configured :
kubectl config get-contexts 
# and set the current context to our cluster : 
kubectl config use-context arn:aws:eks:eu-west-1:462010250684:cluster/<CLUSTER-NAME>
# and then test with :
aws-vault exec prpl-$(basename $(realpath .)) -- kubectl get svc
```


Initialise Cluster with Metrics, Dashboard
------------------------------------------
Deploy the module ```terraform-module-k8s-dashboard```


Initialise Cluster with EFS CSI Driver
---------------------------------------
Deploy the module ```terraform-module-aws-k8s-efs-csi```


Using K8s Dashboard
--------------------
The full-featured [Dashboard](https://docs.aws.amazon.com/eks/latest/userguide/dashboard-tutorial.html) should already be installed in the cluster (from prior section).
To use it do :
```shell script
# Get our login token
kubectl -n kube-system describe secret $(kubectl -n kube-system get secret | grep dashboard-admin | awk '{print $1}')
# Invoke the Proxy to give access to the Dashboard
kubectl proxy
```

then open in [browser](http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/#!/login)

and use the Token as displayed in your terminal for login. 

Note: The token is short-lived and may expire. You will then need to repeat **ALL** of the above steps, to get login again.

**NOTE : In the Dashboard you need to switch namespace to ```prpl``` to see Jenkins pods, PV's etc...** 


Build Docker images
-------------------
```shell script
cd prpl/deploy/docker/image/prpl-builder
source ../docker-config.sh
./docker-build-image.sh
```
These will build locally and can then be tagged and pushed to the ECR registry in Core as below :
```shell script

```


Configure Helm for use with this Cluster
-----------------------------------------
- Helm would be installed by ```prpl/deploy/aws/scripts/cloud-dev-install.sh```
- Configure it for AWS EKS as here :
```shell script
./scripts/helm-ecr-login.sh
```
- See for more info : https://docs.aws.amazon.com/AmazonECR/latest/userguide/ECR_on_EKS.html 
