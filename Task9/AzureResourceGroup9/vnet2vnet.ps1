param(
    [string]$RG1 = 'firstRG',
    [string]$RG2 = 'secondRG',
    [string]$GWName1 = 'vnetgateway1',
    [string]$GWName2 = 'vnetgateway2',
    [string]$Location = 'West Europe',
    [string]$Connection12 = 'Vnet1toVnet2',
    [string]$Connection21 = 'Vnet2toVnet1'
)

#Get both virtual network gateways
$vnet1gw = Get-AzureRmVirtualNetworkGateway -Name $GWName1 -ResourceGroupName $RG1
$vnet2gw = Get-AzureRmVirtualNetworkGateway -Name $GWName2 -ResourceGroupName $RG2

#Create the VNet1 to VNet2 connection.
New-AzureRmVirtualNetworkGatewayConnection -Name $Connection12 -ResourceGroupName $RG1 `
    -VirtualNetworkGateway1 $vnet1gw -VirtualNetworkGateway2 $vnet2gw -Location $Location `
    -ConnectionType Vnet2Vnet -SharedKey 'AzureA1b2C3'

#Create the VNet2 to VNet1 connection.    
New-AzureRmVirtualNetworkGatewayConnection -Name $Connection21 -ResourceGroupName $RG2 `
    -VirtualNetworkGateway1 $vnet2gw -VirtualNetworkGateway2 $vnet1gw -Location $Location `
    -ConnectionType Vnet2Vnet -SharedKey 'AzureA1b2C3'