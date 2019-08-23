#Create new self signed certificate
New-SelfSignedCertificate `
    -certstorelocation cert:\localmachine\my `
    -dnsname appgatewaypip.westeurope.cloudapp.azure.com
#converting to pfx
$pwd = ConvertTo-SecureString -String "A123456a" -Force -AsPlainText
Export-PfxCertificate `
    -cert cert:\localMachine\my\8016D8726510BEAA66EFCE2DA0E707BBD5B01473 `
    -FilePath c:\appgwcert.pfx `
    -Password $pwd

#converting .pfx file to base64
$fileContentBytes = get-content 'cert:\localMachine\my\8016D8726510BEAA66EFCE2DA0E707BBD5B01473' -Encoding Byte
[System.Convert]::ToBase64String($fileContentBytes) | Out-File 'c:\pfx-bytes.txt'

#converting .cer file to base64
Export-Certificate -FilePath c:\cer-bytes.cer -Cert '8016D8726510BEAA66EFCE2DA0E707BBD5B01473' -Type CERT -NoClobber
certutil.exe -encode .\cer-bytes.cer base64cer.txt