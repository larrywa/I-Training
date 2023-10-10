$uuid = (Get-CimInstance -ClassName Win32_ComputerSystemProduct).UUID
$suffix = $uuid.ToLower().Substring($uuid.Length-7, 7)

$location = $args[0]
$resourceGroupName = $args[1]

Write-Host $location
Write-Host $suffix
Write-Host $resourceGroupName


$uuid = (Get-CimInstance -ClassName Win32_ComputerSystemProduct).UUID

Write-Host "Deploying Resources to Azure..."
az deployment sub create --location $location --template-file ..\main.bicep --parameters location=$location suffix=$suffix -o none
Write-Host "Completed deploying of resources to Azure"