param(
    [Parameter(Mandatory = $true)]
    [string]$ResourceGroupName,
    [Parameter(Mandatory = $true)]
    [string]$Location,
    [Parameter(Mandatory = $true)]
    [string]$StorageAccountName,
    [Parameter(Mandatory = $true)]
    [string]$ContainerName,
    [Parameter(Mandatory = $true)]
    [string]$FirstServerName,
    [Parameter(Mandatory = $true)]
    [string]$SecondServerName,
    [Parameter(Mandatory = $true)]
    [string]$FirstDatabaseName,
    [Parameter(Mandatory = $true)]
    [string]$SecondDatabaseName,
    [Parameter(Mandatory = $true)]
    [string]$ThirdDatabaseName,
    [Parameter(Mandatory = $true)]
    [string]$DatabaseForSecondSqlName
)
$Credential1 = Get-Credential -Message "Write username and password for first SQL server"
$Credential2 = Get-Credential -Message "Write username and password for second SQL server"
$SkuName = "Standard_LRS"
$StorageKeyType = "StorageAccessKey"
$StartIP = "0.0.0.0"
$EndIP = "0.0.0.0"
# Create a new resource group
New-AzureRmResourceGroup -Name $ResourceGroupName -Location $Location
#Storage Account.
New-AzureRmStorageAccount -ResourceGroupName $ResourceGroupName -Name $StorageAccountName -Location $Location -SkuName $SkuName
$StorageKey = (Get-AzureRmStorageAccountKey -ResourceGroupName $ResourceGroupName -Name $StorageAccountName).Value[0]
#Storage Containers
New-AzureRmStorageContainer -ResourceGroupName $ResourceGroupName -StorageAccountName $StorageAccountName -ContainerName $ContainerName
$BacpacUri = (Get-AzureRmStorageAccount -ResourceGroupName $ResourceGroupName -StorageAccountName $StorageAccountName).Context.BlobEndPoint
#First SQL server
New-AzureRmSqlServer -ResourceGroupName $ResourceGroupName -ServerName $FirstServerName -Location $Location -SqlAdministratorCredentials $Credential1
#Second SQL server
New-AzureRmSqlServer -ResourceGroupName $ResourceGroupName -ServerName $SecondServerName -Location $Location -SqlAdministratorCredentials $Credential2
#Databases for first SQL server
New-AzureRmSqlDatabase  -ResourceGroupName $ResourceGroupName `
    -ServerName $FirstServerName `
    -DatabaseName $FirstDatabaseName `
    -RequestedServiceObjectiveName "S1"
New-AzureRmSqlDatabase  -ResourceGroupName $ResourceGroupName `
    -ServerName $FirstServerName `
    -DatabaseName $SecondDatabaseName `
    -RequestedServiceObjectiveName "S1"
New-AzureRmSqlDatabase  -ResourceGroupName $ResourceGroupName `
    -ServerName $FirstServerName `
    -DatabaseName $ThirdDatabaseName `
    -RequestedServiceObjectiveName "S1"
#Database for second SQL server
New-AzureRmSqlDatabase  -ResourceGroupName $ResourceGroupName `
    -ServerName $SecondServerName `
    -DatabaseName $DatabaseForSecondSqlName `
    -RequestedServiceObjectiveName "S1"
#Firewall rule for First servers
New-AzureRmSqlServerFirewallRule -ResourceGroupName $ResourceGroupName -ServerName $FirstServerName -FirewallRuleName "Rule01" -StartIpAddress $StartIP -EndIpAddress $EndIP
#Export
$ExportRequest = New-AzureRmSqlDatabaseExport `
    -ResourceGroupName $ResourceGroupName `
    -ServerName $FirstServerName `
    -DatabaseName $FirstDatabaseName `
    -StorageKeyType $StorageKeytype `
    -StorageKey $StorageKey `
    -StorageUri $("$BacpacUri" + "$ContainerName/" + "$FirstDatabaseName.bacpac") `
    -AdministratorLogin $Credential1.UserName `
    -AdministratorLoginPassword $Credential1.Password
#ExportStatus
$exportStatus = Get-AzureRmSqlDatabaseImportExportStatus -OperationStatusLink $ExportRequest.OperationStatusLink
[Console]::Write("Exporting")
while ($ExportStatus.Status -eq "InProgress") {
    Start-Sleep -s 20
    $ExportStatus = Get-AzureRmSqlDatabaseImportExportStatus -OperationStatusLink $ExportRequest.OperationStatusLink
    [Console]::Write(".")
}
[Console]::WriteLine("")
Write-Output "Export succeeded"
#Firewall rule for second server
New-AzureRmSqlServerFirewallRule -ResourceGroupName $ResourceGroupName -ServerName $SecondServerName -FirewallRuleName "Rule02" -StartIpAddress $StartIP -EndIpAddress $EndIP
#Import
$ImportRequest = New-AzureRmSqlDatabaseImport `
    -ResourceGroupName $ResourceGroupName `
    -ServerName $SecondServerName `
    -DatabaseName $FirstDatabaseName `
    -DatabaseMaxSizeBytes 5000000 `
    -StorageKeyType $StorageKeyType `
    -StorageKey $StorageKey `
    -StorageUri $("$BacpacUri" + "$ContainerName/" + "$FirstDatabaseName.bacpac") `
    -Edition "Standard" `
    -ServiceObjectiveName "S1" `
    -AdministratorLogin $Credential2.UserName `
    -AdministratorLoginPassword $Credential2.Password
#Import Status
$importStatus = Get-AzureRmSqlDatabaseImportExportStatus -OperationStatusLink $ImportRequest.OperationStatusLink
[Console]::Write("Importing")
while ($ImportStatus.Status -eq "InProgress") {
    $ImportStatus = Get-AzureRmSqlDatabaseImportExportStatus -OperationStatusLink $ImportRequest.OperationStatusLink
    [Console]::Write(".")
    Start-Sleep -s 20
}
[Console]::WriteLine("")
Write-Output "Import Succeeded"