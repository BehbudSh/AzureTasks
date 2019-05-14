Import-AzContext -Path D:\credintial.json
#Resource group name and location for server
$resourcegroupname = "BehbudRG-$(Get-Random)"
$location = "centralus"
#Elastic poool names
$firstpoolname = "MyFirstPool"
$secondpoolname = "MySecondPool"
#Admin logins and passwords for servers
$adminlogin1 = "ServerAdmin"
$password1 = "A123456a"
$adminlogin2 = "ServerAdmin"
$password2 = "B123456b"
# The logical server names
$firstservername = "SQLserver1-$(Get-Random)"
$secondservername = "SQLserver2-$(Get-Random)"
# The database names
$firstdatabasename = 'FirstDatabase'
$seconddatabasename = 'SecondDatabase'
$thirddatabasename = 'ThirdDatabase'
$databaseforsecondsqlname = 'SecondSqlDatabase'
#Storage and blob container
$Blobname = "filename.bacpac"
$FirstStorageName = "storage1"
$FirstContainerName = "blobcontainer1"
$SecondtStorageName = "storage2"
$SecondContainerName = "blobcontainer2"
#Credintials for SQL servers
# $credential1 = Get-Credential
# $credential2 = Get-Credential
#SKU names
$FirstSkuName = "Standard_LRS"
$SecondSkuName = "Standard_LRS"
# Create a new resource group
$resourcegroup = New-AzResourceGroup -Name $resourcegroupname -Location $location
# First SQL server
$server1 = New-AzSqlServer -ResourceGroupName $resourcegroupname `
    -ServerName $firstservername `
    -Location $location `
    -SqlAdministratorCredentials $(New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $adminlogin1, $(ConvertTo-SecureString -String $password1 -AsPlainText -Force))
# Second SQL server
$server2 = New-AzSqlServer -ResourceGroupName $resourcegroupname `
    -ServerName $secondservername `
    -Location $location `
    -SqlAdministratorCredentials $(New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $adminlogin2, $(ConvertTo-SecureString -String $password2 -AsPlainText -Force))
# First Elastic pool
$firstpool = New-AzSqlElasticPool -ResourceGroupName $resourcegroupname `
    -ServerName $firstservername `
    -ElasticPoolName $firstpoolname `
    -Edition "Standard" `
    -Dtu 50 `
    -DatabaseDtuMin 10 `
    -DatabaseDtuMax 20
$secondpool = New-AzSqlElasticPool -ResourceGroupName $resourcegroupname `
    -ServerName $secondservername `
    -ElasticPoolName $secondpoolname `
    -Edition "Standard" `
    -Dtu 50 `
    -DatabaseDtuMin 10 `
    -DatabaseDtuMax 50
#Databases for first SQL server
$firstdatabase = New-AzSqlDatabase  -ResourceGroupName $resourcegroupname `
    -ServerName $firstservername `
    -DatabaseName $firstdatabasename `
    -ElasticPoolName $firstpoolname
$seconddatabase = New-AzSqlDatabase  -ResourceGroupName $resourcegroupname `
    -ServerName $firstservername `
    -DatabaseName $seconddatabasename `
    -ElasticPoolName $firstpoolname
$thirddatabase = New-AzSqlDatabase  -ResourceGroupName $resourcegroupname `
    -ServerName $firstservername `
    -DatabaseName $thirddatabasename `
    -ElasticPoolName $firstpoolname
#Database for second SQL server
$databaseforsecondsql = New-AzSqlDatabase  -ResourceGroupName $resourcegroupname `
    -ServerName $secondservername `
    -DatabaseName $databaseforsecondsqlname `
    -ElasticPoolName $secondpoolname
#Pointer for SQL servers
# $SqlCtx1 = New-AzureSqlDatabaseServerContext -ServerName $firstservername -Credential $credential1
# $SqlCtx2 = New-AzureSqlDatabaseServerContext -ServerName $secondservername -Credential $credential2
#Storage account.
$FirstStorage = New-AzStorageAccount -ResourceGroupName $resourcegroupname -Name $FirstStorageName -Location $location -SkuName $FirstSkuName
$FirstStorageKey = (Get-AzStorageAccountKey -ResourceGroupName $resourcegroupname -Name $FirstStorageName).Value[0]
$SecondStorage = New-AzStorageAccount -ResourceGroupName $resourcegroupname -Name $SecondtStorageName -Location $location -SkuName $SecondSkuName
$SecondStorageKey = (Get-AzStorageAccountKey -ResourceGroupName $resourcegroupname -Name $SecondtStorageName).Value[0]
#Storage Contexts
$StorageCtx1 = New-AzStorageContext -StorageAccountName $FirstStorageName -StorageAccountKey $FirstStorageKey
$StorageCtx2 = New-AzStorageContext -StorageAccountName $SecondtStorageName -StorageAccountKey $SecondStorageKey
#Storage Containers
$Container1 = New-AzStorageContainer -Name $FirstContainerName -Context $StorageCtx1 -Permission Blob
$Container2 = New-AzStorageContainer -Name $SecondContainerName -Context $StorageCtx2 -Permission Blob
#Get-Container
# $GetContainer1 = Get-AzStorageContainer -Name $FirstContainerName -Context $StorageCtx1
# $GetContainer2 = Get-AzStorageContainer -Name $SecondContainerName -Context $StorageCtx2