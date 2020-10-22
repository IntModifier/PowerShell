#get current date/time
$now = Get-Date
#Get al type 1 maintenance windows
$MaintenanceWindow = Get-WmiObject -ErrorACtion Stop -Namespace root\ccm\clientsdk -ClassName CCM_ServiceWindow | Where-Object{ $_.type -eq 1 }
#Find the naimtenance window with the lowest start time
$NextMaintenancewindow = $MaintenanceWindow | Sort-Object StartTime | Select-Object -First 1
#Calculate the start of that maintenance window
$MW_Year = ($NextMaintenancewindow.starttime).Substring('0','4')
$MW_Month = ($NextMaintenancewindow.starttime).Substring('4','2')
$MW_Day = ($NextMaintenancewindow.starttime).Substring('6','2')
$MW_Hour = ($NextMaintenancewindow.starttime).Substring('8','2')
$MW_Minute = ($NextMaintenancewindow.starttime).Substring('10','2')
#Build Date Time String
$StartString = "$MW_Year-$MW_Month-$MW_Day $MW_Hour`:$MW_Minute`:00"
#Convert to DateTime Format
$MWstart = [datetime]$StartString
#Find Patch Start Time. 4 hours before MW start
$patchstart = $MWstart.AddHours(-4)
#only check for 2 hours before MW Start
$patchend = $MWstart.AddHours(-3)
#Create EventLog Source if needed
New-EventLog -Source "Automated Patching" -LogName Application -ErrorAction SilentlyContinue
#Is it time to start patching?
if ($now -gt $patchstart -AND $now -lt $patchend) {
    #Find all pending patches via WMI
   $Application = (Get-WmiObject -Namespace "root\ccm\clientSDK" -Class CCM_SoftwareUpdate | Where-Object { $_.EvaluationState -like "0"})
   $PatchCount = $Application.count
   #Start Install for all found patches
   Invoke-WmiMethod -Class CCM_SoftwareUpdatesManager -Name InstallUpdates -ArgumentList (, $Application) -Namespace root\ccm\clientsdk
   Write-EventLog -LogName Application -Source "Automated Patching" -EntryType Information -EventId 0 -Message "Automated Patching was triggerd at $now and started $PatchCount patches"
}


