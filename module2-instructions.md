# Lab Module 2: Azure Kubernetes Service
![](content/lab2-title.png)   

> Estimated Duration: 60 minutes  

## Module 2 Table of Contents

[Exercise: Create AKS Cluster Using Azure CLI](#exercise-create-aks-cluster-using-azure-cli)  

[Exercise: Create AKS Cluster Using Terraform](#exercise-create-aks-cluster-using-terraform) 

[Exercise: Deploying Workloads to Nodes](#exercise-deploying-workloads-to-nodes)  

[Exercise: Scaling Nodes to Meet Demand](#exercise-scaling-nodes-to-meet-demand)  

[Exercise: Examine Container Insights](#exercise-examine-container-insights)  

[Exercise: Cleanup Resources](#exercise-cleanup-resources)  



# Exercise: Create AKS Cluster Using Azure CLI

In this exercise you will create an AKS cluster using the Azure Command-line Interface (CLI).  

### Task 1 - Create variables resource group

1. Open a Windows Terminal window (defalts to PowerShell).  

![](content/windows-terminal.png)  

> Windows Terminal allows you to open tabbed command terminals.

2. Login to Azure.

```PowerShell
az login
```

3. Set the current subscription.

```PowerShell
az account set --subscription "your-Azure-subscription-id"
```

4. Select the region closest to your location.  Use '``eastus``' for United States workshops, '``westeurope``' for European workshops.  (region)[eastus,westus,canadacentral,westeurope,centralindia,australiaeast]

5. Define variables. 

```PowerShell
$INSTANCE_ID="unique-numeric-value"
$AKS_RESOURCE_GROUP="azure-$($INSTANCE_ID)-rg"
$LOCATION="eastus"
$AKS_IDENTITY="identity-$($INSTANCE_ID)"
```

6. Get list of available VM sizes with 2 cores in your region.

```PowerShell
az vm list-sizes --location $LOCATION --query "[?numberOfCores == ``2``].{Name:name}" -o table
```

7. Set the VM SKU to one of the available values 

```PowerShell
$VM_SKU="Standard_D2as_v5"
```

8. Create Resource Group.

```PowerShell
az group create --location $LOCATION  --resource-group $AKS_RESOURCE_GROUP 
```

9. Create User Managed Identity

```PowerShell
$AKS_IDENTITY_ID=$(az identity create --name $AKS_IDENTITY --resource-group $AKS_RESOURCE_GROUP --query id -o tsv)
```




### Task 2 - Create a Virtual Network and a Subnet

1. Define variables for network resources.

```PowerShell
$AKS_VNET="aks-$($INSTANCE_ID)-vnet"
$AKS_VNET_SUBNET="aks-$($INSTANCE_ID)-subnet"
$AKS_VNET_ADDRESS_PREFIX="10.0.0.0/8"
$AKS_VNET_SUBNET_PREFIX="10.240.0.0/16"
```

2. Create an Azure Virtual Network and a Subnet. 
   
```PowerShell
az network vnet create --resource-group $AKS_RESOURCE_GROUP `
                       --name $AKS_VNET `
                       --address-prefix $AKS_VNET_ADDRESS_PREFIX `
                       --subnet-name $AKS_VNET_SUBNET `
                       --subnet-prefix $AKS_VNET_SUBNET_PREFIX 
```

3. Get virtual network default subnet id

```PowerShell
$AKS_VNET_SUBNET_ID=$(az network vnet subnet show --resource-group $AKS_RESOURCE_GROUP --vnet-name $AKS_VNET --name $AKS_VNET_SUBNET --query id -o tsv)

Write-Host "Default Subnet ID: $AKS_VNET_SUBNET_ID"

```



### Task 3 - Create a Log Analytics Workspace (if needed)

1. Create a Log Analytics Workspace.

```PowerShell
$LOG_ANALYTICS_WORKSPACE_NAME="aks-$($INSTANCE_ID)-law"
$LOG_ANALYTICS_WORKSPACE_RESOURCE_ID=$(az monitor log-analytics workspace create --resource-group $AKS_RESOURCE_GROUP --workspace-name $LOG_ANALYTICS_WORKSPACE_NAME --query id -o tsv)
Write-Host "LAW Workspace Resource ID: $LOG_ANALYTICS_WORKSPACE_RESOURCE_ID"

```



### Task 4 - Create an AKS Cluster with a System Node Pool

1. Use all the prior settings and resources to create the AKS cluster.  This step will take 5-10 minutes to complete.

``NOTE:`` See Microsoft reference: https://docs.microsoft.com/en-us/cli/azure/aks?view=azure-cli-latest#az_aks_create

```PowerShell
$AKS_NAME="aks-$($INSTANCE_ID)"
Write-Host "AKS Cluster Name: $AKS_NAME"
```


```PowerShell
az aks create --resource-group $AKS_RESOURCE_GROUP `
              --generate-ssh-keys `
              --enable-managed-identity `
              --assign-identity $AKS_IDENTITY_ID `
              --node-count 1 `
              --enable-cluster-autoscaler `
              --min-count 1 `
              --max-count 3 `
              --network-plugin azure `
              --service-cidr 10.0.0.0/16 `
              --dns-service-ip 10.0.0.10 `
              --docker-bridge-address 172.17.0.1/16 `
              --vnet-subnet-id $AKS_VNET_SUBNET_ID `
              --node-vm-size $VM_SKU `
              --nodepool-name system1 `
              --enable-addons monitoring `
              --workspace-resource-id $LOG_ANALYTICS_WORKSPACE_RESOURCE_ID `
              --enable-ahub `
              --name $AKS_NAME
```

2. Once the cluster is ready (after at least 5 minutes), connect your local machine to it.

```PowerShell
az aks get-credentials --name $AKS_NAME --resource-group $AKS_RESOURCE_GROUP
```

3. List the nodes in the cluster.  There should be ``1`` node to start with.

```PowerShell
kubectl get nodes
```

4. Get the list of system nodes only. At this point, the list should return ``1`` node.

```PowerShell
kubectl get nodes -l="kubernetes.azure.com/mode=system"
```

![](content/systempool1.png)  

5. List the node pools in the cluster.  There should be 1 node pool returned.

```PowerShell
az aks nodepool list --cluster-name $AKS_NAME --resource-group $AKS_RESOURCE_GROUP -o table
```

![](content/systemnodepoollist1.png)



### Task 5 - Create a Linux User Node Pool

1. Create a Linux user node pool.

```PowerShell
az aks nodepool add --resource-group $AKS_RESOURCE_GROUP `
                    --cluster-name $AKS_NAME `
                    --os-type Linux `
                    --name linux1 `
                    --node-count 1 `
                    --enable-cluster-autoscaler `
                    --min-count 1 `
                    --max-count 3 `
                    --mode User `
                    --node-vm-size $VM_SKU
```

2. List the nodes in the cluster.  There should be 2 nodes now.

```PowerShell
kubectl get nodes
```

3. Get the list of system nodes only. There should still be only 1 system node.

```PowerShell
kubectl get nodes -l="kubernetes.azure.com/mode=system"
```

4. List the node pools in the cluster.  Again there should be 2 now.

```PowerShell
az aks nodepool list --cluster-name $AKS_NAME --resource-group $AKS_RESOURCE_GROUP -o table
```

![](content/systemnodepoollist2.png)


### Task 6 - Create a Windows User Node Pool

1. Create a Windows user node pool.

```PowerShell
az aks nodepool add --resource-group $AKS_RESOURCE_GROUP `
                    --cluster-name $AKS_NAME `
                    --os-type Windows `
                    --name win1 `
                    --node-count 1 `
                    --mode User `
                    --node-vm-size $VM_SKU 
```

2. List the nodes in the cluster.  There should be 3 nodes.

```PowerShell
kubectl get nodes
```

![](content/nodelist2.png)

3. Get the list of system nodes only. There should still be only 1 node.

```PowerShell
kubectl get nodes -l="kubernetes.azure.com/mode=system"
```

4. Get the list of Linux nodes. There should be 2 nodes.

```PowerShell
kubectl get nodes -l="kubernetes.io/os=linux"
```

5. List the node pools in the cluster.  Again there should be 3.

```PowerShell
az aks nodepool list --cluster-name $AKS_NAME --resource-group $AKS_RESOURCE_GROUP -o table
```

![](content/systemnodepoollist3.png) 



### Task 7 - Adjust the Auto Scaler for the lab

The default settings for the AKS Auto Scaler are tuned for production environments, but take too long to scale up/down during demos and practice labs.  

1. Configure the cluster-wide auto scaling profile so all the node pool auto scalers are more responsive.  

```PowerShell
az aks update --resource-group $AKS_RESOURCE_GROUP `
              --name $AKS_NAME `
              --cluster-autoscaler-profile `
                  scale-down-delay-after-add=1m `
                  scale-down-unready-time=1m `
                  scale-down-unneeded-time=1m `
                  skip-nodes-with-system-pods=true 
```

``NOTE:`` Refer to this link for a complete description of the options available: [AKS Cluster Autoscaler](https://docs.microsoft.com/en-us/azure/aks/cluster-autoscaler)


[Module 2 Table of Contents](#module-2-table-of-contents)

[List of Modules](#modules-list)



# Exercise: Deploying Workloads to Nodes

In this exercise you will deploy different pods to various node pools in your cluster.  



### Task 1 - Deploy a simple workload with no Node Selector

1. Change current folder to ``Module2``

```PowerShell
cd  C:\Labs\module2
```

2. Deploy a workload with 6 replicas and no *Node Selector*.

```PowerShell
kubectl apply -f workload.yaml
```

3. Get a complete list of all pods and review the results.

```PowerShell
kubectl get pods -o wide
```

![](content/pods1.png) 

``NOTE:`` Notice some of the pods got created on the Linux nodes, while others got scheduled on the Windows nodes, and thus could not be run.  The Linux image specified in the Deployment is not compatible with the Windows 2019 OS running on the Windows nodes.

4. Describe any of the failed pods to see the actual error.

```PowerShell
kubectl describe pod <failed pod name>
```

![](content/describepodwin.png)  

``NOTE:`` Without any guidance, the Kubernetes scheduler does its best to distribute workloads evenly across all the nodes that have available resources.  It doesn't examine the contents of Deployments to confirm that their images are compatible with the nodes it selects.

5. Update the ``workload.yaml`` file to add the following node selector:

```yaml
  nodeSelector:
    kubernetes.io/os: linux
```

![](content/nodeselector1.png) 

6. Apply the deployment again and list the pods.

```PowerShell
kubectl apply -f workload.yaml
kubectl get pods -o wide
```

``NOTE:`` It will take a few seconds for the bad pods to be deleted, so they may show as ``Terminated`` for little some time.

![](content/pods2.png) 

> Notice that all the pods are running now, but they're spread across both the system and user nodes.  The reason for creating user nodes is to seprate your workloads from system utilities.

7. Update the ``workload.yaml`` file to add an additional label "``kubernetes.azure.com/mode: user``" to the Node Selector.  The final *nodeSelector* section should look like this:

```yaml
  nodeSelector:
    kubernetes.io/os: linux
    kubernetes.azure.com/mode: user
```

8. Apply the deployment again and list the pods.

```PowerShell
kubectl apply -f workload.yaml
kubectl get pods -o wide
```

![](content/pods3.png) 

``PERFECT!``


[Module 2 Table of Contents](#module-2-table-of-contents)

[List of Modules](#modules-list)



# Exercise: Scaling Nodes to Meet Demand

In this exercise you'll watch how the AKS Auto Scaler adjusts the number of nodes based on increased demand and then scales them back down when the load is reduced.  

  

### Task 1 - Verify the names and number of current nodes 

1. Get a list of the Linux user nodes.

```PowerShell
kubectl get nodes -l="kubernetes.azure.com/mode=user","kubernetes.io/os=linux"
```




### Task 2 - Increase the number of replicas to trigger the Auto Scaler to scale up

1. Increase the number of replicas to force the Auto Scaler to create more nodes in the Linux user node pool.

```PowerShell
kubectl scale --replicas=40 deploy/workload
```

2. Get the list of pods.

```PowerShell
kubectl get pods -o wide
```

> Notice that some pods are ``Pending`` state.

![](content/podspending.png) 

3. Describe one of the Pending pods
   
```PowerShell
kubectl describe pod <pending pod name>
```

> Notice that the Events section describes the problem and the solution.

![](content/describepod.png) 

4. Start a watch on the nodes

```PowerShell
kubectl get nodes -l="kubernetes.azure.com/mode=user","kubernetes.io/os=linux" -w
```

In a few minutes you'll see the number of nodes increase.

![](content/newnode.png) 

5. When the new nodes are in a ``Ready`` state, press *Ctrl-C* to break out of the watch and return to the console. 
   
6. Get a list of pods.

```PowerShell
kubectl get pods -o wide
```

> Notice all the pening Pods are running and they're all in the same node pool, scheduled on the new nodes.

![](content/podsrunning.png) 



### Task 3 - Reduce workload to trigger the Auto Scaler to scale down

1. Delete the workload.

```PowerShell
kubectl delete deploy/workload
```

2. Watch the nodes

```PowerShell
kubectl get nodes -l="kubernetes.azure.com/mode=user","kubernetes.io/os=linux" -w
```

``NOTE:`` In a few minutes, two of the nodes will go into a ``NotReady`` state and then disappear.  It will probably *NOT* be both the new nodes that were created.  The "victim" nodes are picked using an internal scale-in policy.

![](content/nodenotready.png)

``NOTE:`` The cluster autoscaler may be unable to scale down if pods can't be deleted, such as in the following situations:

- A pod is directly created and isn't backed by a controller object, such as a deployment or replica set.

- A pod disruption budget (PDB) is too restrictive and doesn't allow the number of pods to be fall below a certain threshold.

- A pod uses node selectors or anti-affinity that can't be honored by other nodes when the replacement Pod is scheduled.


3. Break out of the watch and keep getting the list of nodes manually.  Repeat the command below until there is only 1 node left.

```PowerShell
kubectl get nodes -l="kubernetes.azure.com/mode=user","kubernetes.io/os=linux"
```

![](content/fewernodes.png)


[Module 2 Table of Contents](#module-2-table-of-contents)

[List of Modules](#modules-list)



# Exercise: Examine Container Insights

Now that you've used your cluster for a little while, you should have some metrics and logs in Container Insights to review.



### Task 1 - Review Container Insights

1. Open the Azure Portal in a browser.
   
2. Search for "Kubernetes".  Click on your cluster.
   
3. Scroll down to ``Insights`` on the option blade.
   
4. Navigate through the various tabs.

``Cluster metrics overview:``
![](content/containerinsights1.png)


``Nodes list:``
![](content/containerinsights2.png)


``Containers:``
![](content/containerinsights3.png)

5. Scroll down to ``Logs`` on the option blade.
   
6. Copy this query into the editor and click ``Run``

```kql
KubePodInventory 
| where TimeGenerated > ago(1h)
| join ContainerLog on ContainerID
| project TimeGenerated, Computer, PodName=Name, ContainerName=split(ContainerName, "/",1)[0], LogEntry
```

![](content/loganalytics.png)

You'll see how the container logs are sent to a Log Analytics Workspace for analysis.

### Sample Kusto Queries for Container Insights

The link below list some common Kusto queries for Container Insights data:

https://docs.microsoft.com/en-us/azure/azure-monitor/containers/container-insights-log-query


[Module 2 Table of Contents](#module-2-table-of-contents)

[List of Modules](#modules-list)



# Exercise: Cleanup Resources


### Task 1 - Delete the cluster and its resources - Azure CLI

When you're done working with the cluster, you can delete it.  You have the complete instructions here on how to recreate it.

It's a good idea to repeat this lab several times, changing some of the settings, in order to get the hang of working with AKS clusters.

1. Deleting the cluster is much easier than creating it.

```PowerShell
az aks delete --resource-group $AKS_RESOURCE_GROUP --name $AKS_NAME
```

2. You can skip deleting these resources if you're planning on recreating just the cluster at a later time.

3. Delete the Log Analytics Workspace.
   
```PowerShell
az monitor log-analytics workspace delete --resource-group $AKS_RESOURCE_GROUP --workspace-name $LOG_ANALYTICS_WORKSPACE_NAME
```

4. Delete the Virtual Network 
   
```PowerShell
az network vnet delete --resource-group $AKS_RESOURCE_GROUP --name $AKS_VNET
```

``HINT: You could go through and delete individual resources above or you could delete the ENTIRE resource group, which will delete everything in it.  Only do this if you place to recreate all the supporting resources``

5. Delete the entire resource group
   
```PowerShell
az group delete --resource-group $AKS_RESOURCE_GROUP
```


### Task 2 - Delete the cluster and its resources - Terraform

1. If you used Terraform to create your cluster, you can delete the cluster and all it supporting resources with the following command:

```PowerShell
terraform destroy -auto-approve
```


[List of Modules](#modules-list)

