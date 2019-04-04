Configuration Main
{

    Param ( [string] $nodeName )

    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Import-DscResource -ModuleName xWebAdministration

    Node $nodeName
    {
        WindowsFeature IIS {
            Name   = 'Web-Server'
            Ensure = 'Present'
        }
        WindowsFeature Management {
            Name      = 'Web-Mgmt-Service'
            Ensure    = 'Present'
            DependsOn = '[WindowsFeature]IIS'
        }
        Registry RemoteManagement {
            Key       = 'HKLM:\SOFTWARE\Microsoft\WebManagement\Server'
            ValueName = 'EnableRemoteManagement'
            ValueType = 'Dword'
            ValueData = '1'
            DependsOn = @('[WindowsFeature]IIS', '[WindowsFeature]Management')
        }
        Service StartWMSVC {
            Name        = 'WMSVC'
            StartupType = 'Automatic'
            State       = 'Running'
            DependsOn   = '[Registry]RemoteManagement'

        }
        xWebsite Website {
            Name         = 'Website'
            PhysicalPath = 'C:\inetpub\wwwroot'
            State        = 'Started'
            DependsOn    = '[WindowsFeature]IIS'
            BindingInfo  = @(
                MSFT_xWebBindingInformation {
                    Protocol = 'HTTP' 
                    Port     = '8081'
                    HostName = ''

                };
                MSFT_xWebBindingInformation {
                    Protocol = 'HTTP' 
                    Port     = '8082'
                };
               
            )
        }
    }
}