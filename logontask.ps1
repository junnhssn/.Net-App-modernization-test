Set-ExecutionPolicy -ExecutionPolicy bypass -Force
Start-Transcript -Path C:\WindowsAzure\Logs\logontasklogs.txt -Append

#Install teams
Start-Process -FilePath "C:\Packages\Teams_windows_x64.exe" -ArgumentList '-quiet','ACCEPT_EULA=1'

Sleep 60

Stop-Process -Name "Teams"

sleep 2

Unregister-ScheduledTask -TaskName "setup" -Confirm:$false 
Stop-Transcript
