$vnet1 = Get-AzureRmVirtualNetwork -ResourceGroupName VM1RG -Name vm1
$vnet2 = Get-AzureRmVirtualNetwork -ResourceGroupName VM2RG -Name vm2
Add-AzureRmVirtualNetworkPeering -Name 'Vnet1ToVnet2' -VirtualNetwork $vnet1 -RemoteVirtualNetworkId $vnet2.Id
Add-AzureRmVirtualNetworkPeering -Name 'Vnet2ToVnet1' -VirtualNetwork $vnet2 -RemoteVirtualNetworkId $vnet1.Id