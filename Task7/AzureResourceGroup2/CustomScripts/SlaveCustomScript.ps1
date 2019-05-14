[xml]$SlaveXml=@"
<requestHandler name="/replication" class="solr.ReplicationHandler" > 
    <!--
       To enable simple master/slave replication, uncomment one of the 
       sections below, depending on whether this solr instance should be
       the "master" or a "slave".  If this instance is a "slave" you will 
       also need to fill in the masterUrl to point to a real machine.
    -->
 
   <!--
   <lst name="master">
         <str name="replicateAfter">commit</str>
         <str name="replicateAfter">startup</str>
         <str name="confFiles">schema.xml,stopwords.txt</str>
       </lst>
   -->
 
       <lst name="slave">
         <str name="masterUrl">http://10.0.0.4:8983/solr</str>
         <str name="pollInterval">00:00:60</str>
       </lst>
    
</requestHandler>
"@
$PathToSolr = "F:\Solr\solr-6.6.5"
$SolrConfigFiles=Get-ChildItem -Path $PathToSolr -Recurse | Where-Object {$_.Name -like "solrconfig.xml"}
foreach ($SolrConfigFile in $SolrConfigFiles) {
[xml]$SolrConfigXml=Get-Content $SolrConfigFile.PSPath
$SolrConfigXml.Config.AppendChild($SolrConfigXml.ImportNode($SlaveXml.RequestHandler, $true))
$Directory = $SolrConfigFile.DirectoryName
$SolrconfigXml.Save("$Directory\solrconfig.xml")
}
$Array=@("enable.master=false","enable.slave=true")
$SolrConfigFiles=Get-ChildItem -Path $PathToSolr -Recurse | Where-Object {$_.Name -like "core.properties"}
foreach ($SolrConfigFile in $SolrConfigFiles) {
Set-Content -Path $SolrconfigFile.PSPath -Value $Array
}