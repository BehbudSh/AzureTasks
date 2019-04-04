Connect-AzAccount

# Create a new resource group.

$resourceGroup = "azureResource"
$location = "eastus"
New-AzResourceGroup -Name $resourceGroup -Location $location 

# Set the name of the storage account and the SKU name. 

$storageAccountName = "behbud"
$skuName = "Standard_LRS"

# Create the storage account.

New-AzStorageAccount -ResourceGroupName $resourceGroup -Name $storageAccountName -Location $location -SkuName $skuName

#Create the blob container

$StorageAccountName = "behbud" 
$StorageAccountKey = (Get-AzStorageAccountKey -ResourceGroupName $resourceGroup -Name $storageAccountName).Value[0]
$ctx = New-AzStorageContext -StorageAccountName $StorageAccountName -StorageAccountKey $StorageAccountKey
$ContainerName = "upload"
New-AzStorageContainer -Name $ContainerName -Context $ctx -Permission Blob

#Uploading files and folders to Container

$localDir = "C:\Users\Behbuds\Desktop\upload\"
foreach($file in (Get-ChildItem $localDir -File -Recurse)){
   $blobName = $file.FullName.Remove(0,24).Replace("\","/")
   Set-AzStorageBlobContent -Blob $blobName -Container $ContainerName -File $($file.FullName) -Context $ctx
}