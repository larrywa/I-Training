$uuid = (Get-CimInstance -ClassName Win32_ComputerSystemProduct).UUID
$suffix = $uuid.ToLower().Substring($uuid.Length-7, 7)

$location =$args[0]

Write-Host "Deploying Resources to Azure..."
az deployment sub create --location $location --template-file ..\main.bicep --parameters location=$location suffix=$suffix -o none
Write-Host "Completed deploying of resources to Azure"
$resourceGroupName = "oas-msvcs-rg"


#turn off the ssl for mysql
Write-Host "Updating Mysql Flexible Server configurations"
az mysql flexible-server parameter set --resource-group $resourceGroupName --server-name auctiondbsrv-${suffix} --name require_secure_transport --value OFF -o none
az mysql flexible-server parameter set --resource-group $resourceGroupName --server-name auctiondbsrv-${suffix} --name sql_mode --value NO_ENGINE_SUBSTITUTION -o none
Write-Host "Completed updating Mysql Flexible Server configurations"

Write-Host "Setting up the Auction DB"
$HostNameAuctionDB = "auctiondbsrv-${suffix}.mysql.database.azure.com"
$AuctionDBUserName = "mydbuser${suffix}"
Write-Host "AuctionDBUserName" + $AuctionDBUserName
Invoke-Expression -Command ".\mysql.ps1 $HostNameAuctionDB $AuctionDBUserName"
   
Write-Host "Setting up the Payment DB"
$HostNamePaymentDB = "oas-${suffix}-sql.database.windows.net"
$PaymentDBUserName = "${suffix}sqllogin"
Invoke-Expression -Command  ".\azuresql.ps1 $HostNamePaymentDB $PaymentDBUserName"
        
Write-Host "Retrieving configurations from Deployments"
$eventHubPrimaryKey = az deployment group show -g oas-msvcs-rg -n event-hub-deployment --query properties.outputs.eventHubPrimaryKey.value
$appInsightsKey = az deployment group show -g oas-msvcs-rg -n app-insights-deployment --query properties.outputs.instrumentationKey.value

Write-Host "Generating Declarative Configurations (Docker-compose.yaml, Kubernetes.yaml)"
Invoke-Expression -Command  ".\Generate-DeclarativeConfigurations.ps1 $suffix $resourceGroupName $appInsightsKey $eventHubPrimaryKey"

Set-Location -Path C:\Labs\oas\src
        
Write-Host "Spinning up Containers"

Docker-compose up

