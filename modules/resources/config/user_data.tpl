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
$DomainPrefix = $DomainName.Split(".")[0]
$DomainSuffix = $DomainName.Split(".")[1]
$ForestMode = "${ForestMode}"
$DomainMode = "${DomainMode}"
$ADSecurityGroup = "${ADSecurityGroup}"
$SecureAdminSafeModePassword = ConvertTo-SecureString -String "${AdminSafeModePassword}" -AsPlainText -Force
$currentDomain=(Get-CimInstance -ClassName Win32_Computersystem).Domain

###$defaultgateway = Get-NetRoute -InterfaceIndex (Get-NetAdapter).ifIndex

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

$v3Ext = @"
keyUsage=digitalSignature,keyEncipherment
extendedKeyUsage=serverAuth
subjectKeyIdentifier=hash
subjectAltName = @alt_names
[alt_names]
IP.1= $HostIp
"@

$ldapRenewCert = @"
dn:
changetype: modify
add: renewServerCertificate
renewServerCertificate: 1
-
"@

if ($DomainName -eq $currentDomain) {
    $gpoName = "block_control_panel_gpo"
    $currentGpo = (Get-GPO -Name $gpoName).DisplayName
    if ($gpoName -ne $currentGpo) {
        Write-Output "Domain Prefix:" $DomainPrefix
        Write-Output "Domain Suffix:" $DomainSuffix
        New-ADGroup -Name "$ADSecurityGroup" -SamAccountName $ADSecurityGroup -GroupCategory Security -GroupScope Global -DisplayName "$ADSecurityGroup" -Path "CN=Users,DC=$DomainPrefix,DC=$DomainSuffix" -Description "Members of this group are prohibited Control Panel Access"
        New-GPO -Name $gpoName | New-GPLink -Target "dc=$DomainPrefix,dc=$DomainSuffix"
        Set-GPPermissions -Name $gpoName -PermissionLevel GpoRead -TargetName "Authenticated Users" -TargetType Group -replace
        Set-GPPermissions -Name $gpoName -PermissionLevel GpoRead -TargetName "$ADSecurityGroup" -TargetType Group
        Set-GPPermissions -Name $gpoName -PermissionLevel GpoApply -TargetName "$ADSecurityGroup" -TargetType Group
        Set-GPRegistryValue -Name $gpoName -Key "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" -Type "DWord" -ValueName "NoControlPanel" -Value 1
    }
} else {
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

    ### Write files
    $requestInf | Out-File c:\\certs\\request.inf
    $v3Ext | Out-File c:\\certs\\v3ext.txt -Encoding UTF8
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
}
</powershell>
<persist>true</persist>