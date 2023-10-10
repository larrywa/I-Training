$uuid = (Get-CimInstance -ClassName Win32_ComputerSystemProduct).UUID
$suffix = $uuid.ToLower().Substring($uuid.Length-7, 7)

# Get the acr credentials 
$acrRegistryName = -join("oasacr", $suffix)

$acrusername = az acr credential show -n $acrRegistryName --query username
$acrpassword = az acr credential show -n $acrRegistryName --query passwords[0].value

#login to acr 
az acr login --name $acrRegistryName -u $acrusername -p $acrpassword

$acrurl = -join($acrRegistryName, ".azurecr.io")

$auctionServiceTaggedName = -join($acrurl,"/auctionservice:1.0")
$bidServiceTaggedName = -join($acrurl,"/bidservice:1.0")
$paymentServiceTaggedName = -join($acrurl,"/paymentservice:1.0")
$bidListenerTaggedName = -join($acrurl,"/bidlistener:1.0")
$auctionPaymentListenerTaggedName = -join($acrurl,"/auctionpaymentlistener:1.0")
$notificationListenerTaggedName = -join($acrurl,"/notificationlistener:1.0")
$identityServiceTaggedName = -join($acrurl,"/identityservice:1.0")
$notificationServiceTaggedName = -join($acrurl,"/notificationservice:1.0")
$oasAppTaggedName = -join($acrurl,"/oasapp:1.0")
$apiGatewayTaggedName = -join($acrurl,"/apigateway:1.0")


docker tag auctionservice:1.0 $auctionServiceTaggedName
docker tag bidservice:1.0 $bidServiceTaggedName
docker tag paymentservice:1.0 $paymentServiceTaggedName
docker tag bidlistener:1.0 $bidListenerTaggedName
docker tag auctionpaymentlistener:1.0 $auctionPaymentListenerTaggedName
docker tag notificationlistener:1.0 $notificationListenerTaggedName
docker tag identityservice:1.0 $identityServiceTaggedName
docker tag notificationservice:1.0 $notificationServiceTaggedName
docker tag oasapp:1.0 $oasAppTaggedName
docker tag apigateway:1.0 $apiGatewayTaggedName

docker push $auctionServiceTaggedName
docker push $bidServiceTaggedName
docker push $paymentServiceTaggedName
docker push $bidListenerTaggedName
docker push $auctionPaymentListenerTaggedName
docker push $notificationListenerTaggedName
docker push $identityServiceTaggedName
docker push $notificationServiceTaggedName
docker push $oasAppTaggedName
docker push $apiGatewayTaggedName

#generate secret file
kubectl create secret docker-registry --dry-run=client oassecret --docker-server=$acrurl --docker-username=$acrusername --docker-password=$acrpassword --docker-email=testemail@email.com -o yaml > docker-secret.yaml