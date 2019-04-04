Import-AzureRmContext -Path D:\credintial.json
#Resource group name and location for server
$resourcegroupname = "BehbudRG-$(Get-Random)"
$location = "Central US"
#Storage and blob container
$StorageName = "behbudstorage"
$FirstContainerName = "blobcontainer1"
$SkuName = "Standard_LRS"
$StorageKeytype = "StorageAccessKey"
# The logical server names
$firstservername = "sqlserver1-$(Get-Random)"
$secondservername = "sqlserver2-$(Get-Random)"
# The database names
$firstdatabasename = "FirstDatabase"
$seconddatabasename = "SecondDatabase"
$thirddatabasename = "ThirdDatabase"
$databaseforsecondsqlname = "SecondSqlDatabase"
$StartIP = "0.0.0.0"
$EndIP = "0.0.0.0"
# Create a new resource group
New-AzureRmResourceGroup -Name $resourcegroupname -Location $location
#Storage account.
New-AzureRmStorageAccount -ResourceGroupName $resourcegroupname -Name $StorageName -Location $location -SkuName $SkuName
$StorageKey = (Get-AzureRmStorageAccountKey -ResourceGroupName $resourcegroupname -Name $StorageName).Value[0]
#Storage Containers
New-AzureRmStorageContainer -ResourceGroupName $resourcegroupname -StorageAccountName $StorageName -ContainerName $FirstContainerName
$BacpacUri = (Get-AzureRmStorageAccount -ResourceGroupName $resourcegroupname -StorageAccountName $StorageName).Context.BlobEndPoint
#Credintials for SQL servers
$credential1 = Get-Credential
$credential2 = Get-Credential
#First SQL server
New-AzureRmSqlServer -ResourceGroupName $resourcegroupname -ServerName $firstservername -Location $location -SqlAdministratorCredentials $credential1
#Second SQL server
New-AzureRmSqlServer -ResourceGroupName $resourcegroupname -ServerName $secondservername -Location $location -SqlAdministratorCredentials $credential2
#Databases for first SQL server
New-AzureRmSqlDatabase  -ResourceGroupName $resourcegroupname `
    -ServerName $firstservername `
    -DatabaseName $firstdatabasename `
    -RequestedServiceObjectiveName "S1"
New-AzureRmSqlDatabase  -ResourceGroupName $resourcegroupname `
    -ServerName $firstservername `
    -DatabaseName $seconddatabasename `
    -RequestedServiceObjectiveName "S1"
New-AzureRmSqlDatabase  -ResourceGroupName $resourcegroupname `
    -ServerName $firstservername `
    -DatabaseName $thirddatabasename `
    -RequestedServiceObjectiveName "S1"
#Database for second SQL server
New-AzureRmSqlDatabase  -ResourceGroupName $resourcegroupname `
    -ServerName $secondservername `
    -DatabaseName $databaseforsecondsqlname `
    -RequestedServiceObjectiveName "S1"
#Firewall rule for First servers
New-AzureRmSqlServerFirewallRule -ResourceGroupName $resourcegroupname -ServerName $firstservername -FirewallRuleName "Rule01" -StartIpAddress $StartIP -EndIpAddress $EndIP
#Export
$exportRequest = New-AzureRmSqlDatabaseExport `
    -ResourceGroupName $resourcegroupname `
    -ServerName $firstservername `
    -DatabaseName $firstdatabasename `
    -StorageKeyType $StorageKeytype `
    -StorageKey $StorageKey `
    -StorageUri $("$BacpacUri" + "$FirstContainerName/" + "$firstdatabasename.bacpac") `
    -AdministratorLogin $credential1.UserName `
    -AdministratorLoginPassword $credential1.Password
#ExportStatus
$exportStatus = Get-AzureRmSqlDatabaseImportExportStatus -OperationStatusLink $exportRequest.OperationStatusLink
[Console]::Write("Exporting")
while ($exportStatus.Status -eq "InProgress") {
    Start-Sleep -s 20
    $exportStatus = Get-AzureRmSqlDatabaseImportExportStatus -OperationStatusLink $exportRequest.OperationStatusLink
    [Console]::Write(".")
}
[Console]::WriteLine("")
Echo "Export succeeded"
#Firewall rule for second server
New-AzureRmSqlServerFirewallRule -ResourceGroupName $resourcegroupname -ServerName $secondservername -FirewallRuleName "Rule02" -StartIpAddress $StartIP -EndIpAddress $EndIP
#Import
$importRequest = New-AzureRmSqlDatabaseImport `
    -ResourceGroupName $resourcegroupname `
    -ServerName $secondservername `
    -DatabaseName $firstdatabasename `
    -DatabaseMaxSizeBytes 5000000 `
    -StorageKeyType "StorageAccessKey" `
    -StorageKey $StorageKey `
    -StorageUri $("$BacpacUri" + "$FirstContainerName/" + "$firstdatabasename.bacpac") `
    -Edition "Standard" `
    -ServiceObjectiveName "S1" `
    -AdministratorLogin $credential2.UserName `
    -AdministratorLoginPassword $credential2.Password
#Import Status
$importStatus = Get-AzureRmSqlDatabaseImportExportStatus -OperationStatusLink $importRequest.OperationStatusLink
[Console]::Write("Importing")
while ($importStatus.Status -eq "InProgress") {
    $importStatus = Get-AzureRmSqlDatabaseImportExportStatus -OperationStatusLink $importRequest.OperationStatusLink
    [Console]::Write(".")
    Start-Sleep -s 20
}
[Console]::WriteLine("")
Echo "Import Succeeded"