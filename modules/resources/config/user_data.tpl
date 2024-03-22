<powershell>
$HostIp = (Invoke-RestMethod -URI 'http://169.254.169.254/latest/meta-data/local-ipv4' -UseBasicParsing)

###Variables for  server installation###
$ServerName = hostname
$TimeZoneID = "${TimeZoneID}"
$CAKey = "${CAKey}"
$CACert = "${CACert}"

#Create variables for ADDS installation
$DomainName = "${DomainName}"
$DomainNetbiosName = $DomainName.Split(".") | Select -First 1
$ForestMode = "${ForestMode}"
$DomainMode = "${DomainMode}"
$SecureAdminSafeModePassword = ConvertTo-SecureString -String "${AdminSafeModePassword}" -AsPlainText -Force
###$defaultgateway = Get-NetRoute -InterfaceIndex (Get-NetAdapter).ifIndex

Set-TimeZone -Id $TimeZoneID
mkdir c:\\certs
##Write-Output "....................Installing OpenSSL.................."
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
choco install openssl.light -y
Import-Module $env:ChocolateyInstall\helpers\chocolateyProfile.psm1
refreshenv

Write-Output "ServerName:" $ServerName
#### Installation of Active Directory Domain Services ###
Install-WindowsFeature -Name AD-Domain-Services -IncludeAllSubFeature -IncludeManagementTools

### Promoting Server to Domain Controller ###
Import-Module ADDSDeployment
Install-ADDSForest `
-confirm:$false `
-CreateDnsDelegation:$false `
-DomainMode $DomainMode `
-DomainName $DomainName `
-DomainNetbiosName $DomainNetbiosName `
-ForestMode $ForestMode `
-InstallDns:$true `
-SkipAutoConfigureDns:$false `
-SkipPreChecks:$false `
-SafeModeAdministratorPassword $SecureAdminSafeModePassword `
-NoRebootOnCompletion:$true `
-Force:$true

### Create request.inf
$requestInf = @"
[Version]

Signature="$Windows NT$"

[NewRequest]

Subject = `"CN=$ServerName.hashidemo.com`"
KeySpec = 1
KeyLength = 1024
Exportable = TRUE
MachineKeySet = TRUE
SMIME = False
PrivateKeyArchive = FALSE
UserProtected = FALSE
UseExistingKeySet = FALSE
ProviderName = `"Microsoft RSA SChannel Cryptographic Provider`"
ProviderType = 12
RequestType = PKCS10
KeyUsage = 0xa0

[Extensions]
2.5.29.17 = `"{text}`"
_continue_ = `"IP Address=$HostIp`"

[EnhancedKeyUsageExtension]
OID=1.3.6.1.5.5.7.3.1 ; this is for Server Authentication
"@

$requestInf | Out-File c:\\certs\\request.inf

$v3Ext = @"
keyUsage=digitalSignature,keyEncipherment
extendedKeyUsage=serverAuth
subjectKeyIdentifier=hash
subjectAltName = @alt_names
[alt_names]
IP.1= $HostIp
"@

$v3Ext | Out-File c:\\certs\\v3ext.txt -Encoding UTF8

$ldapRenewCert = @"
dn:
changetype: modify
add: renewServerCertificate
renewServerCertificate: 1
-
"@

$ldapRenewCert | Out-File c:\\certs\\ldap-renewcert.txt

$CAKey | Out-File c:\\certs\\ca.key -Encoding UTF8
$CACert | Out-File c:\\certs\\ca.crt -Encoding UTF8

Set-Location -Path C:\\certs
#openssl.exe genrsa -out ca.key 4096
#openssl.exe req -new -x509 -days 3650 -key ca.key -out ca.crt -subj "/CN=My Root CA/emailAddress=admin@$DomainName/C=SG/ST=Singapore/L=Singapore/O=$DomainNetbiosName/OU=$DomainNetbiosName"


### Import root certificate into trusted store of domain controller
Get-Item "ca.crt" | Import-Certificate -CertStoreLocation "Cert:\LocalMachine\Root"

certreq -new request.inf client.csr


openssl.exe x509 -req -days 3650 -in client.csr -CA ca.crt -CAkey ca.key -extfile v3ext.txt -set_serial 01 -out client.crt
openssl.exe x509 -in client.crt -text

### Accept and import certificate
certreq -accept client.crt

#ldifde -i -f ldap-renewservercert.txt

Restart-Computer
</powershell>
