<#
    .Synopsis
        Create automation to remove snapshots from VMs older than 30 days. The automation should send a report via email on the operations it performed. 
    .Description
        Connect to a vCenter and look for any snapshots older the X days (Defaults to 30 days) and delete them. Email report is sent out with results of the run
    .Example
        PS> .\FindandRemoveOldSnapshots.ps1 -vCenterName vcsa.test.lab -daysold 30 -Credential (Get-Credential) -EmailTo sysadmin@test.lab -smtpserver smtp.test.lab
    .Notes
        Created by Eric Stacey
        Verison 1.0
        June 26th 2021
#>
[CmdletBinding()]
Param (
    [Parameter(Mandatory=$true,HelpMessage="Enter vCenter FQDN")]
    [string]$vCenterName,
    [Parameter(Mandatory=$true,HelpMessage="Look for snapshots older then this many days")]
    [int]$Daysold =30,
    [Parameter(Mandatory=$true)]
    [System.Management.Automation.PSCredential]$Credential,
    [Parameter(Mandatory=$true,HelpMessage="Enter Email Address to Deliver Report To")]
    [string]$EmailTo,
    [Parameter(Mandatory=$true,HelpMessage="Enter FQDN of your SMTP relay")]
    [string]$Smtpserver
)
#Empty vars to use later
$oldsnapshots = ""
$msg = ""

Write-Verbose "Generating Filename"
$filename = "SnapshotCleanup_" + $daysold + "days.csv"

Write-verbose "Checking for PowerCLI"
if (!(Get-Module -ListAvailable vmware.powercli)) {
    Write-Verbose "Installing PowerCLI if missing and making sure the NuGet provider is registered."
    Get-PackageProvider -Name NuGet | Install-PackageProvider -Scope CurrentUser -Force
    Find-Module -Name VMware.PowerCLI | Install-Module -Scope CurrentUser -Confirm:$false -erroraction Stop
}
Write-Verbose "PowerCLI installed"
Write-verbose "Checking for Existing vCenter Connection"
if (!($null = $global.DefaultVIServers)){
    Write-Verbose "Connecting to vCenter server $vCenterName"
    Connect-VIServer -Server $vCenterName -Credential $Credential -ErrorAction Stop
}
    $msg = "Connected to $vcenterName as " + $Credential.Username
    Write-Verbose $msg
    Write-Output "Checking for snapshots older then $Daysold days"
$oldsnapshots = Get-VM | Get-Snapshot | Where-Object {$_.Created -lt (Get-Date).AddDays("-$Daysold")}
if (!($null = $oldsnapshots)) {
    Write-Output "No Snapsshots Found! Hurray! Sendig Email to $EmailTo"
    Send-MailMessage -SmtpServer $Smtpserver -To $EmailTo -From "SnapshotCleanup_NoReply@test.lab" -Subject "Results of Snapshot Cleanup Script - Older then 30 days" -Body "No snapshots older then $aysold were found"
}
else {
    Write-Verbose "Generating Report"
    $oldsnapshots | Select-Object VM,Name,Description,Created | Export-Csv -LiteralPath $env:temp\$filename -NoTypeInformation
    $msg = "Found" + $oldsnapshots.count + "snapshots. Removeing Snapshots..."
    Write-Output $msg
    Remove-snapshot -Confirm:$false -Snapshot $oldsnapshots -RunAsync
    Write-Output "Sending Email with info of removed snapshots"
    Send-MailMessage -SmtpServer $Smtpserver -To $EmailTo -From "SnapshotCleanup_NoReply@test.lab" -Subject "Results of Snapshot Cleanup Script - Older then 30 days" -Attachments $env:temp\$filename
}
Write-Verbose "Cleaning up report file"
Get-Item $env:temp\$filename | Remove-Item -Confirm:$false -Force
Write-Verbose "Disconnecting from vCenter servers"
Disconnect-VIServer -Confirm:$false
