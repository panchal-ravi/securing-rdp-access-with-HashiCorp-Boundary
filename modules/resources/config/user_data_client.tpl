<powershell>
###Variables for  server installation###
$private_ip = "${private_ip}"
$TimeZoneID = "${TimeZoneID}"
$DomainName = "${DomainName}"
$DomainUser = "${DomainUser}"
$DomainPassword = "${DomainPassword}"
$currentDomain=(Get-CimInstance -ClassName Win32_Computersystem).Domain

#Set DNS address
Set-DnsClientServerAddress -InterfaceIndex (Get-NetAdapter).ifIndex -ServerAddresses ($private_ip)

if ($DomainName -eq $currentDomain) {
    Add-LocalGroupMember -Group 'Remote Desktop Users'  -Member "$DomainName\Domain Users"
} else {
    Add-Computer -DomainName "$DomainName" -Credential (New-Object -TypeName PSCredential -ArgumentList "$DomainUser",(ConvertTo-SecureString -String "$DomainPassword" -AsPlainText -Force)[0]) -Restart
}
</powershell>
<persist>true</persist>