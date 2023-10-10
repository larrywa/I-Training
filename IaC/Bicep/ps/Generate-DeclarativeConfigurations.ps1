#Parameters
$suffix = $args[0]
$resourceGroupName = $args[1]
$appinsightskey = $args[2]
$primaryKeyKafka = $args[3]

#Getting Information from Azure Resources
$rootPath = $PSScriptRoot
$cosmosAccountName= -join('bidacc',$suffix)
$cosmosPrimaryDbConnection  = (az cosmosdb keys list --type connection-strings --name $cosmosAccountName --resource-group $resourceGroupName --query 'connectionStrings[0].connectionString') 
$cosmosPrimaryDbConnection = $cosmosPrimaryDbConnection.substring(1,$cosmosPrimaryDbConnection.IndexOf('&retrywrites'))
$mysqlhost= -join('auctiondbsrv-', ${suffix}, '.mysql.database.azure.com')  
$mysqlusername = -join('mydbuser',$suffix)  
$mysqlpassword = -join('P@ssw0rd!@#')  
$mysqldbname = -join('auctionservicedb') 
$bootstrapservers= -join('eventhub', $suffix, '.servicebus.windows.net:9093')
$kakfkaendpoint= -join('sb://','eventhub',$suffix, '.servicebus.windows.net/')
$kafkasharedaccesskey= $primaryKeyKafka
$kafkasharedaccesskeytoprint= -join($primaryKeyKafka) 
$ConnectionStrings__PaymentServiceContext = -join ('Server=tcp:oas-', $suffix, '-sql.database.windows.net,1433;Initial Catalog=AuctionPaymentDB;Persist Security Info=False;User ID=',$suffix,'sqllogin;Password=P@ssw0rd!@#;MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;')
$SaslPassword= -join('Endpoint=', 'sb://','eventhub',$suffix, '.servicebus.windows.net/',';SharedAccessKeyName=RootManageSharedAccessKey;SharedAccessKey=',$kafkasharedaccesskey)
# Setting up images
$acrRegistryName = -join('oasacr',$suffix)  
$auctionServiceImage = -join($acrRegistryName,".azurecr.io/auctionservice:1.0")
$bidServiceImage = -join($acrRegistryName,".azurecr.io/bidservice:1.0")
$paymentServiceImage = -join($acrRegistryName,".azurecr.io/paymentservice:1.0")
$notificationServiceImage = -join($acrRegistryName,".azurecr.io/notificationservice:1.0")
$bidListenerImage = -join($acrRegistryName,".azurecr.io/bidlistener:1.0")
$auctionPaymentListenerImage = -join($acrRegistryName,".azurecr.io/auctionpaymentlistener:1.0")
$notificationListenerImage = -join($acrRegistryName,".azurecr.io/notificationlistener:1.0")
$apiGatewayImage = -join($acrRegistryName,".azurecr.io/apigateway:1.0")
$oasappImage = -join($acrRegistryName,".azurecr.io/oasapp:1.0")
$identityServiceImage = -join($acrRegistryName,".azurecr.io/identityservice:1.0")

#Generate Docker Compose
Write-Host 'Generating Docker Compose...'
$DockerComposeTemplatePath = -join($rootPath,'\Docker-compose-template.yml')
$DockerComposeDestPath = -join($rootPath,'\Docker-compose.yml')
Copy-Item $DockerComposeTemplatePath -Destination $DockerComposeDestPath

((Get-Content -Path $DockerComposeDestPath -Raw) -replace 'replaceinstrumentationkeyoas', $appinsightskey )| Set-Content -Path $DockerComposeDestPath
((Get-Content -Path $DockerComposeDestPath -Raw) -replace 'replaceinstrumentationkeyauction', $appinsightskey )| Set-Content -Path $DockerComposeDestPath
((Get-Content -Path $DockerComposeDestPath -Raw) -replace 'replaceinstrumentationkeybid', $appinsightskey )| Set-Content -Path $DockerComposeDestPath
((Get-Content -Path $DockerComposeDestPath -Raw) -replace 'replaceinstrumentationkeypayment', $appinsightskey )| Set-Content -Path $DockerComposeDestPath
((Get-Content -Path $DockerComposeDestPath -Raw) -replace 'replaceinstrumentationkeylistener', $appinsightskey )| Set-Content -Path $DockerComposeDestPath
((Get-Content -Path $DockerComposeDestPath -Raw) -replace 'replacemysqlhost', $mysqlhost )| Set-Content -Path $DockerComposeDestPath
((Get-Content -Path $DockerComposeDestPath -Raw) -replace 'replacemysqlusername', $mysqlusername )| Set-Content -Path $DockerComposeDestPath
((Get-Content -Path $DockerComposeDestPath -Raw) -replace 'replacemysqlpassword', $mysqlpassword ) | Set-Content -Path $DockerComposeDestPath
((Get-Content -Path $DockerComposeDestPath -Raw) -replace 'replacemysqldbname', $mysqldbname ) | Set-Content -Path $DockerComposeDestPath
((Get-Content -Path $DockerComposeDestPath -Raw) -replace 'replacecosmosdbconnectionstring', $cosmosPrimaryDbConnection) | Set-Content -Path $DockerComposeDestPath
((Get-Content -Path $DockerComposeDestPath -Raw) -replace 'replacebootstrapservers',$bootstrapservers ) | Set-Content -Path $DockerComposeDestPath
((Get-Content -Path $DockerComposeDestPath -Raw) -replace 'replacekakfkaendpoint',$kakfkaendpoint) | Set-Content -Path $DockerComposeDestPath
((Get-Content -Path $DockerComposeDestPath -Raw) -replace 'replacekafkasharedaccesskey',$kafkasharedaccesskeytoprint) | Set-Content -Path $DockerComposeDestPath
((Get-Content -Path $DockerComposeDestPath -Raw) -replace 'replaceConnectionStringsPaymentServiceContext',$ConnectionStrings__PaymentServiceContext) | Set-Content -Path $DockerComposeDestPath
((Get-Content -Path $DockerComposeDestPath -Raw) -replace 'replaceSaslPassword', $SaslPassword )| Set-Content -Path $DockerComposeDestPath

Copy-Item -Path $DockerComposeDestPath -Destination C:\labs\oas\Src\Docker-compose.yml

Write-Host 'Docker Compose Generated!'

#Generate Kubernetes Deployments
Write-Host 'Generating Kubernetes Declarative Configuration (YAML)...'

$rootPath = 'C:\labs\IaC\K8s\'
$KubernetesTemplatePath = -join($rootPath,'k8stemplate.yml')
$KubernetesDestPath = -join($rootPath,'k8s.yml')
Copy-Item $KubernetesTemplatePath -Destination $KubernetesDestPath

((Get-Content -Path $KubernetesDestPath -Raw) -replace 'replaceinstrumentationkeyoas', $appinsightskey )| Set-Content -Path $KubernetesDestPath
((Get-Content -Path $KubernetesDestPath -Raw) -replace 'replaceinstrumentationkeyauction', $appinsightskey )| Set-Content -Path $KubernetesDestPath
((Get-Content -Path $KubernetesDestPath -Raw) -replace 'replaceinstrumentationkeybid', $appinsightskey )| Set-Content -Path $KubernetesDestPath
((Get-Content -Path $KubernetesDestPath -Raw) -replace 'replaceinstrumentationkeypayment', $appinsightskey )| Set-Content -Path $KubernetesDestPath
((Get-Content -Path $KubernetesDestPath -Raw) -replace 'replaceinstrumentationkeylistener', $appinsightskey )| Set-Content -Path $KubernetesDestPath
((Get-Content -Path $KubernetesDestPath -Raw) -replace 'replacemysqlhost', $mysqlhost )| Set-Content -Path $KubernetesDestPath
((Get-Content -Path $KubernetesDestPath -Raw) -replace 'replacemysqlusername', $mysqlusername )| Set-Content -Path $KubernetesDestPath
((Get-Content -Path $KubernetesDestPath -Raw) -replace 'replacemysqlpassword', $mysqlpassword ) | Set-Content -Path $KubernetesDestPath
((Get-Content -Path $KubernetesDestPath -Raw) -replace 'replacemysqldbname', $mysqldbname ) | Set-Content -Path $KubernetesDestPath
((Get-Content -Path $KubernetesDestPath -Raw) -replace 'replacecosmosdbconnectionstring', $cosmosdbconnectionstring ) | Set-Content -Path $KubernetesDestPath
((Get-Content -Path $KubernetesDestPath -Raw) -replace 'replacebootstrapservers',$bootstrapservers ) | Set-Content -Path $KubernetesDestPath
((Get-Content -Path $KubernetesDestPath -Raw) -replace 'replacekakfkaendpoint',$kakfkaendpoint) | Set-Content -Path $KubernetesDestPath
((Get-Content -Path $KubernetesDestPath -Raw) -replace 'replacekafkasharedaccesskey',$kafkasharedaccesskeytoprint) | Set-Content -Path $KubernetesDestPath
((Get-Content -Path $KubernetesDestPath -Raw) -replace 'replaceConnectionStringsPaymentServiceContext',$ConnectionStrings__PaymentServiceContext) | Set-Content -Path $KubernetesDestPath
((Get-Content -Path $KubernetesDestPath -Raw) -replace 'replaceSaslPassword', $SaslPassword )| Set-Content -Path $KubernetesDestPath
((Get-Content -Path $KubernetesDestPath -Raw) -replace 'auctionserviceimage', $auctionServiceImage )| Set-Content -Path $KubernetesDestPath

((Get-Content -Path $KubernetesDestPath -Raw) -replace 'bidserviceimage', $bidServiceImage )| Set-Content -Path $KubernetesDestPath
((Get-Content -Path $KubernetesDestPath -Raw) -replace 'identityserviceimage', $identityServiceImage )| Set-Content -Path $KubernetesDestPath
((Get-Content -Path $KubernetesDestPath -Raw) -replace 'apigatewayimage', $apiGatewayImage )| Set-Content -Path $KubernetesDestPath
((Get-Content -Path $KubernetesDestPath -Raw) -replace 'oasappimage', $oasappImage )| Set-Content -Path $KubernetesDestPath
((Get-Content -Path $KubernetesDestPath -Raw) -replace 'paymentserviceimage', $paymentServiceImage )| Set-Content -Path $KubernetesDestPath
((Get-Content -Path $KubernetesDestPath -Raw) -replace 'notificationserviceimage', $notificationServiceImage )| Set-Content -Path $KubernetesDestPath
((Get-Content -Path $KubernetesDestPath -Raw) -replace 'bidlistenerimage', $bidListenerImage )| Set-Content -Path $KubernetesDestPath
((Get-Content -Path $KubernetesDestPath -Raw) -replace 'auctionpaymentlistenerimage', $auctionPaymentListenerImage )| Set-Content -Path $KubernetesDestPath
((Get-Content -Path $KubernetesDestPath -Raw) -replace 'notificationlistenerimage', $notificationListenerImage )| Set-Content -Path $KubernetesDestPath

Write-Host 'Kubernetes Declarative Configuration (YAML) Generated!'