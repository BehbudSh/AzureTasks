$Modules = @('xPSDesiredStateConfiguration', 'xNetworking', 'StorageDsc', 'ComputerManagementDsc')
foreach ($Module in $Modules) {
    if (!(Find-Module $Module)) {
        Install-Module $Module
    }
}