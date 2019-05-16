$Modules = @('xPSDesiredStateConfiguration', 'xNetworking', 'StorageDsc', 'ComputerManagementDsc','xCertificate','xWebAdministration')
foreach ($Module in $Modules) {
    if (!(Get-Module $Module)) {
        Install-Module -Verbose $Module -Force
    }
}