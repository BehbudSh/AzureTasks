Configuration Main
{
    Param ( 
        [string] $nodeName,
        [string] $Certificate,
        [string] $Thumbprint,
        [PSCredential] $certcredential
    )
    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Import-DscResource -ModuleName xPSDesiredStateConfiguration
    Import-DscResource -ModuleName xCertificate
    Import-DscResource -ModuleName xWebAdministration
    Import-DscResource -ModuleName xNetworking
    Node $AllNodes.NodeName {
        xFirewall FirewallHTTP {
            Name        = "Firewall Rule For HTTP"
            DisplayName = "Firewall Rule For HTTP"
            Ensure      = "Present"
            Profile     = ("Public" , "Private")
            Direction   = "Inbound"
            LocalPort   = 80       
            Protocol    = "TCP"
            Description = "Firewall Rule For HTTP"
            Enabled     = $true
            Action =  'Allow'
        }
        xFirewall FirewallHTTPS {
            Name        = "Firewall Rule For HTTPS"
            DisplayName = "Firewall Rule For HTTPS"
            Ensure      = "Present"
            Profile     = ("Public" , "Private")
            Direction   = "Inbound"
            LocalPort   = 443       
            Protocol    = "TCP"
            Description = "Firewall Rule For HTTPS"
            Enabled     = $true
            Action =  'Allow'
        }
        File CertFolder {
            Type            = "Directory"
            DestinationPath = "C:\Cert"
            Ensure          = "Present"
            MatchSource     = $true
        } 
        xRemoteFile CopyCert {
            Uri             = $Certificate
            DestinationPath = "C:\Cert\appgwcert.pfx"
            MatchSource     = $true
            DependsOn       = "[File]CertFolder"
        }
        WindowsFeature IIS {
            Ensure = "Present"
            Name   = "Web-Server"
        }
        WindowsFeature HTTPRedirection {
            Name   = "Web-Http-Redirect"
            Ensure = "Present"
        }
        Package UrlRewrite {
            Ensure    = "Present"
            Name      = "IIS URL Rewrite Module 2"
            Path      = "https://download.microsoft.com/download/C/9/E/C9E8180D-4E51-40A6-A9BF-776990D8BCA9/rewrite_amd64.msi"
            ProductId = "08F0318A-D113-4CF0-993E-50F191D397AD"
            DependsOn = "[WindowsFeature]IIS"
        }
        xPfxImport PfxVM {
            Thumbprint = "$Thumbprint"
            Path       = "C:\Cert\appgwcert.pfx"
            Location   = "LocalMachine"
            Store      = "WebHosting"
            Credential = $certcredential
            DependsOn  = "[xRemoteFile]CopyCert"
        }
        xWebsite DefaultSite {
            Ensure       = "Present"
            Name         = "Default Web Site"
            State        = "Started"
            PhysicalPath = "C:\inetpub\wwwroot"
            DependsOn    = @("[xPfxImport]PfxVM", "[WindowsFeature]IIS")
            BindingInfo  = @(
                MSFT_xWebBindingInformation {
                    Protocol              = "https"
                    Port                  = 443
                    HostName              = "*"
                    CertificateThumbprint = "$Thumbprint"
                    CertificateStoreName  = "WebHosting"
                }
                MSFT_xWebBindingInformation {
                    Protocol = "http"
                    Port     = 80
                    HostName = "*" 

                }
            )
        }
        LocalConfigurationManager {
            CertificateId = $Thumbprint
        }
    }
}