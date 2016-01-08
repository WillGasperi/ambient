# Ambient


# How-to Install

Just open Prompt and go to the folder where you want to instal copy this:

    powershell (New-Object System.Net.WebClient).DownloadFile('https://raw.githubusercontent.com/vanuatu/ambient/master/install.cmd', 'install.cmd') & install.cmd & del install.cmd
    
ou

    powershell "Invoke-WebRequest https://raw.githubusercontent.com/vanuatu/ambient/master/install.cmd -OutFile install.cmd" & install.cmd & del install.cmd
    
and press enter
