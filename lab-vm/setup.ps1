# install Chocolatey 
Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

# install Compose
iwr -useb https://raw.githubusercontent.com/sixeyed/docker-init/master/windows/install-docker-compose.ps1 | iex
# TODO - add path

# install tools
choco install -y poshgit
choco install -y visualstudiocode
choco install -y firefox

refreshenv
$env:PATH=$env:PATH + ';C:\Program Files\Mozilla Firefox'
[Environment]::SetEnvironmentVariable('PATH', $env:PATH, [EnvironmentVariableTarget]::Machine)

# configure Server Manager 
New-ItemProperty -Path HKLM:\Software\Microsoft\ServerManager -Name DoNotOpenServerManagerAtLogon -PropertyType DWORD -Value "1" -Force
New-ItemProperty -Path HKLM:\Software\Microsoft\ServerManager\Oobe -Name DoNotOpenInitialConfigurationTasksAtLogon -PropertyType DWORD -Value "1" -Force

# turn off firewall and Defender *this is meant for short-lived lab VMs*
Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled False
Set-MpPreference -DisableRealtimeMonitoring $true

# clone lab repo
mkdir C:\scm -ErrorAction Ignore
cd C:\scm
git clone https://github.com/sixeyed/docker-windows-workshop.git

# pull lab images
$images = 
'microsoft/windowsservercore:ltsc2016',
'microsoft/nanoserver:sac2016',
'microsoft/dotnet-framework:4.7.2-sdk',
'microsoft/dotnet-framework:4.7.2-runtime',
'microsoft/dotnet:2.0-sdk-nanoserver-sac2016',
'microsoft/dotnet:2.0-runtime-nanoserver-sac2016',
'microsoft/aspnetcore:2.0-nanoserver-sac2016',
'microsoft/iis:nanoserver-sac2016',
'microsoft/aspnet:4.7.2-windowsservercore-ltsc2016',
'microsoft/mssql-server-windows-express:2016-sp1',
'nats:1.1.0-nanoserver'

foreach ($tag in $images) {
    Write-Output "** Processing tag: $tag"
    & docker image pull $tag
}