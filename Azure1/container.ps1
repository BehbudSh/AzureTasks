$StorageAccountName = "behbud" 
$StorageAccountKey = "JghUN9oP1wCxqnLB12udHNXI/d4wAL2iUR1ioLHuZPmyCDnKwgAEaQyNNfO+MnU+y+0k6PCfC2iGenfJ6qKzow=="
$ctx = New-AzStorageContext -StorageAccountName $StorageAccountName -StorageAccountKey $StorageAccountKey
$ContainerName = "upload"
New-AzStorageContainer -Name $ContainerName -Context $ctx -Permission Blob
$localFileDirectory = "C:\Users\Behbuds\Desktop\upload\"
$BlobName = "2pac.jpg" 
$localFile = $localFileDirectory +$BlobName
Set-AzStorageBlobContent -File $localFile -Container $ContainerName  -Blob $BlobName -Context $ctx
#ls –Recurse –Path $localFileDirectory |Set-AzStorageBlobContent  -Container $ContainerName -Context $ctx -BlobType Block