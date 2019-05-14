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
