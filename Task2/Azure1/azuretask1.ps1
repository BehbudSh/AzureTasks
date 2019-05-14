param(
    [Parameter(Mandatory = $true)]
    [String]$ResourceGroup,
    [Parameter(Mandatory = $true)]
    [String]$StorageAccountName,
    [Parameter(Mandatory = $true)]
    [String]$ContainerName,
    [Parameter(Mandatory = $true)]
    [String]$LocalDir
)
Import-AzContext -Path D:\credintial.json
# Create a new resource group.
$Location = "WestEurope"
New-AzResourceGroup -Name $ResourceGroup -Location $Location 
# Set the name of the storage account and the SKU name. 
$SkuName = "Standard_LRS"
# Create the storage account.
New-AzStorageAccount -ResourceGroupName $ResourceGroup -Name $StorageAccountName -Location $Location -SkuName $SkuName
#Create the blob container
$StorageAccountKey = (Get-AzStorageAccountKey -ResourceGroupName $ResourceGroup -Name $StorageAccountName).Value[0]
$Ctx = New-AzStorageContext -StorageAccountName $StorageAccountName -StorageAccountKey $StorageAccountKey
New-AzStorageContainer -Name $ContainerName -Context $Ctx -Permission Blob
#Uploading files and folders to Container
foreach ($File in (Get-ChildItem $LocalDir -File -Recurse)) {
    $BlobName = $File.FullName.Remove(0, 24).Replace("\", "/")
    Set-AzStorageBlobContent -Blob $BlobName -Container $ContainerName -File $($File.FullName) -Context $Ctx
}