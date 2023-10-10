# Create an empty bicep file
Write-Output '' > ..\delete.bicep

Write-Host 'Warning: Deleting the entire deployment might take 10-15 minutes to complete. Please be patient and do not cancel the task.'
# Deploy it into the resource group in 'complete' mode
az deployment group create --template-file ..\delete.bicep -g oas-msvcs-rg --mode complete

az deployment sub delete -n main

az group delete --resource-group oas-msvcs-rg --yes

# Clean up
Remove-Item ..\delete.bicep -Recurse -Force
Remove-Item .\Docker-compose.yml -Force