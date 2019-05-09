Configuration Main
{
    Param (
        [string] $nodeName,
        [string] $Certificate,
        [string] $CertificatePK,
        [string] $Thumbprint,
        [PSCredential] $Credintial
    )
    
    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Import-DscResource -ModuleName xPSDesiredStateConfiguration
    Import-DscResource -ModuleName xCertificate
    Import-DscResource -ModuleName xWebAdministration
    Node $AllNodes.NodeName {

        File CertFolder {
            Type            = "Directory"
            DestinationPath = "C:\Cert"
            Ensure          = "Present"
            MatchSource     = $true
        }   
        xRemoteFile CopyCert {
            Uri             = $Certificate
            DestinationPath = "C:\Cert\DscPrivateKey.pfx"
            MatchSource     = $true
            DependsOn       = "[File]CertFolder"
        }
        xRemoteFile CopyPK {
            Uri             = $CertificatePK
            DestinationPath = "C:\Cert\DscPublicKey.cer"
            MatchSource     = $true
            DependsOn       = "[File]CertFolder"
        }
        WindowsFeature IIS {
            Ensure = "Present"
            Name   = "Web-Server"
        }
        xWebsite DefaultSite {
            Ensure       = "Present"
            Name         = "Default Web Site"
            State        = "Stopped"
            PhysicalPath = "C:\inetpub\wwwroot"
            DependsOn    = "[WindowsFeature]IIS"
        }
        xPfxImport PfxVM {
            Thumbprint = "$Thumbprint"
            Path       = "C:\Cert\DscPrivateKey.pfx"
            Location   = "LocalMachine"
            Store      = "WebHosting"
            Credential = $Credintial
            DependsOn  = "[xRemoteFile]CopyCert"
        }
        xWebsite Site {
            Ensure       = "Present"
            Name         = "task6.westeurope.cloudapp.azure.com"
            State        = "Started"
            PhysicalPath = "C:\inetpub\wwwroot"
            DependsOn    = @("[xPfxImport]PfxVM", "[WindowsFeature]IIS")
            BindingInfo  = MSFT_xWebBindingInformation {
                Protocol              = "https"
                Port                  = 443
                HostName              = "task6.westeurope.cloudapp.azure.com"
                CertificateThumbprint = "$Thumbprint"
                CertificateStoreName  = "WebHosting"
            }
        }
        LocalConfigurationManager
        {
            CertificateId = $Thumbprint
        }
    }
}
# $ConfigData=    @{ 
#     AllNodes = @(     
#                     @{  
#                         NodeName = "VM"
#                         CertificateFile = "C:\Cert\DscPublicKey.cer"
#                         Thumbprint = $Thumbprint 
#                     }; 
#                 );    
# } 