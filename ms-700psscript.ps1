Param (
    [Parameter(Mandatory = $true)]
    [string]
    $AzureUserName,

    [string]
    $AzurePassword,

    [string]
    $AzureTenantID,

    [string]
    $AzureSubscriptionID,

    [string]
    $ODLID,

    [string]
    $InstallCloudLabsShadow,
    
    [string]
    $vmAdminUsername,

    [string]
    $trainerUserName,

    [string]
    $trainerUserPassword
)

Start-Transcript -Path C:\WindowsAzure\Logs\CloudLabsCustomScriptExtension.txt -Append
[Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls
[Net.ServicePointManager]::SecurityProtocol = "tls12, tls11, tls" 

#Import Common Functions
$path = pwd
$path=$path.Path
$commonscriptpath = "$path" + "\cloudlabs-common\cloudlabs-windows-functions.ps1"
. $commonscriptpath

#Create C:\CloudLabs
New-Item -ItemType directory -Path C:\CloudLabs -Force

# Run Imported functions from cloudlabs-windows-functions.ps1
WindowsServerCommon
InstallCloudLabsShadow $ODLID $InstallCloudLabsShadow
Enable-CloudLabsEmbeddedShadow $vmAdminUsername $trainerUserName $trainerUserPassword
#CreateCredFile $AzureUserName $AzurePassword $AzureTenantID $AzureSubscriptionID

sleep 5

InstallEdgeChromium

$WebClient = New-Object System.Net.WebClient
$WebClient.DownloadFile("https://experienceazure.blob.core.windows.net/templates/moc/ms700/psscript/logontask.ps1","C:\Packages\logontask.ps1")

#Install teams
$WebClient = New-Object System.Net.WebClient
$WebClient.DownloadFile("https://go.microsoft.com/fwlink/p/?LinkID=869426&clcid=0x409&culture=en-us&country=US&lm=deeplink&lmsrc=groupChatMarketingPageWeb&cmpid=directDownloadWin64","C:\Packages\Teams_windows_x64.exe")

#logontask
$AutoLogonRegPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon"
Set-ItemProperty -Path $AutoLogonRegPath -Name "AutoAdminLogon" -Value "1" -type String 
Set-ItemProperty -Path $AutoLogonRegPath -Name "DefaultUsername" -Value "$($env:ComputerName)\azureuser" -type String  
Set-ItemProperty -Path $AutoLogonRegPath -Name "DefaultPassword" -Value "Pa$$w0rd1234" -type String
Set-ItemProperty -Path $AutoLogonRegPath -Name "AutoLogonCount" -Value "1" -type DWord

#scheduled task
$Trigger= New-ScheduledTaskTrigger -AtLogOn
$User= "$($env:ComputerName)\azureuser" 
$Action= New-ScheduledTaskAction -Execute "C:\Windows\System32\WindowsPowerShell\v1.0\Powershell.exe" -Argument "-executionPolicy Unrestricted -File C:\Packages\logontask.ps1"
Register-ScheduledTask -TaskName "setup" -Trigger $Trigger -User $User -Action $Action -RunLevel Highest -Force

Restart-Computer -Force 

# Silently install Microsoft Teams with PowerShell Script.
# Download Microsoft Teams from https://teams.microsoft.com/downloads
# This script to install Microsoft Teams 64 bits if you want 32 bits you need to change on line 19, 20 & 27 to path of Teams 32 bits
# $source = "https://statics.teams.microsoft.com/production-windows-x64/1.1.00.29068/Teams_windows.exe"
# $destination = "$Installdir\Teams_windows.exe"
# Start-Process -FilePath "$Installdir\Teams_windows.exe" -ArgumentList "-s"

# Check if Software is installed already in registry.
#$CheckTeamsReg = Get-ItemProperty HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* | where {$_.DisplayName -like "Microsoft Teams*"}

# If Microsoft Teams is not installed continue with script. If it's istalled already script will exit.
#If ($CheckTeamsReg -eq $null) {

#$Installdir = "c:\Apps\install_Teams"    #path to download Microsoft Teams##New-Item -Path $Installdir -ItemType directory

# Download the installer from the Microsoft website. Check URL because it can be changed for new versions
#$source = "https://statics.teams.microsoft.com/production-windows-x64/1.1.00.29068/Teams_windows_x64.exe"
#$destination = "$Installdir\Teams_windows_x64.exe"
#Invoke-WebRequest $source -OutFile $destination

# Wait for the installation to finish. I've set it to 15 min. to take enough time until source of Microsoft Teams download from internet
#Start-Sleep -s 900

# Start the installation of Microsoft Teams
#Start-Process -FilePath "$Installdir\Teams_windows_x64.exe"

#}
