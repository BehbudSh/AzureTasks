Configuration Main
{
    Param ( [string] $nodeName,
            [string] $SolrCmd )

            Import-DscResource -ModuleName PSDesiredStateConfiguration
            # Import-DscResource -ModuleName xPSDesiredStateConfiguration
            Find-Module xPSDesiredStateConfiguration | Install-Module
            # Import-DscResource -ModuleName xNetworking
            Find-Module xNetworking | Install-Module
            # Import-DscResource -ModuleName StorageDsc
            Find-Module StorageDsc | Install-Module
            # Import-DscResource -ModuleName ComputerManagementDsc
            Find-Module ComputerManagementDsc | Install-Module
            
    Node $nodeName {
        xFirewall Firewall {
            Name        = "Firewall Rule For Solr"
            DisplayName = "Firewall Rule For Solr"
            Ensure      = "Present"
            Profile     = ("Public" , "Private")
            Direction   = "Inbound"
            LocalPort   = 8983       
            Protocol    = "TCP"
            Description = "Firewall Rule For Solr"
            Enabled     = $true
        }
        WaitforDisk Disk2 {
            DiskId           = 2
            DiskIdType       = 'Number'
            RetryIntervalSec = 60
            RetryCount       = 60
        }
        Disk F {
            DiskId      = 2
            DiskIdType  = 'Number'
            DriveLetter = "F"
            FSLabel     = "Data"
            FSFormat    = "NTFS"
            ClearDisk   = $true
            DependsOn   = "[WaitForDisk]Disk2"
        }
        WaitForVolume F {
            DriveLetter      = "F"
            RetryIntervalSec = 5
            RetryCount       = 10
        }
        File SolrFolder {
            Ensure          = "Present"
            DestinationPath = "F:\Solr"
            Type            = "Directory"
            DependsOn       = "[Disk]F"
        }
        File DownloadsFolder {
            Ensure          = "Present"
            DestinationPath = "C:\Downloads"
            Type            = "Directory"
        }
        xRemoteFile DownloadJRE {
            Uri             = "https://javadl.oracle.com/webapps/download/AutoDL?BundleId=238729_478a62b7d4e34b78b671c754eaaf38ab"
            DestinationPath = "C:\Downloads\jre-8u211-windows-x64.exe"
            DependsOn       = "[File]DownloadsFolder"
        }
        Package Java {
            Ensure    = 'Present'
            Name      = 'Java 8 Update 211'
            Path      = "C:\Downloads\jre-8u211-windows-x64.exe"
            Arguments = '/s'
            ProductId = '4A03706F-666A-4037-7777-5F2748764D10'
            DependsOn = "[xRemoteFile]DownloadJRE"
        }
        xRemoteFile CopyCoresConf {
            Uri             = "https://archive.apache.org/dist/lucene/solr/6.6.5/solr-6.6.5.zip"
            DestinationPath = "F:\Solr\solr-6.6.5.zip"
            DependsOn       = "[File]SolrFolder"
        }
        xRemoteFile CopySolrCmd {
            Uri             = $SolrCmd
            DestinationPath = "F:\Solr\SlaveSolrCmd.ps1"
            DependsOn       = "[File]SolrFolder"
        }
        Archive UnzipSolr {
            Path        = "F:\Solr\solr-6.6.5.zip"
            Destination = "F:\Solr"
            Ensure      = "Present"
            DependsOn   = @("[xRemoteFile]CopyCoresConf", "[File]SolrFolder")
        }
        Archive UnzipCoresConf {
            Path        = "F:\Solr\solr-6.6.5.zip"
            Destination = "F:\Solr\solr-6.6.5\server\solr\configsets"
            Ensure      = "Present"
            DependsOn   = @("[Archive]UnzipSolr", "[xRemoteFile]CopyCoresConf")
        }
        LocalConfigurationManager {
            ConfigurationModeFrequencyMins = 15
            ConfigurationMode              = "ApplyAndAutoCorrect"
            RefreshMode                    = "Push"
            RebootNodeIfNeeded             = $true
        }
        ScheduledTask ScheduledTaskDailyIndefinitelyAdd {
            TaskName           = 'Solr task AtStartUp Indefinitely'
            ActionExecutable   = "C:\windows\system32\WindowsPowerShell\v1.0\powershell.exe"
            ActionArguments    = "-File `"F:\Solr\SlaveSolrCmd.ps1`""
            ScheduleType       = 'AtStartup'
            RepeatInterval     = '00:15:00'
            RepetitionDuration = 'Indefinitely'
            WakeToRun          = $true 
            DependsOn          = @("[Archive]UnzipSolr", "[xRemoteFile]CopySolrCmd")
        }
    }
}