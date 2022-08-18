# Backup-TCBSDRepo Powershell module

This Powershell module downloads the TwinCAT/BSD Repository to the local file system.
It is mainly intended to be used on windows.
On Linux and TwinCAT/BSD itself you can use wget instead:

    wget --recursive --timestamping --level=inf --no-cache --no-parent --no-cookies --no-host-directories --relative --directory-prefix /tmp/mirror https://tcbsd.beckhoff.com/TCBSD/13/stable/packages/

## Install

the easiest way is to install the cmdlet persistently on your system. In this way you can always use the cmdlet as all they standard cmdlet from the powershell.
To install the module manually you need to execute the following steps:

1. Check your Module Path by entering this into a Powershell

        PS C:\Users\heikow> $Env:PSModulePath
        C:\Users\heikow\Documents\WindowsPowerShell\Modules;C:\Program Files\WindowsPowerShell\Modules;C:\Windows\system32\WindowsPowerShell\v1.0\Modules

2. Copy the folder into one of the above shown folders. I would recommend to use the User folder to only install it for your User Account.

        Copy-Item -Path .\Backup-TCBSDRepo\ -Destination C:\Users\heikow\Documents\WindowsPowerShell\Modules\Backup-TCBSDRepo -Force -Recurse

    If the Modules folder doesn't exist yet, just create it.

3. You can check if your module is now available to the powershell by typing

        Get-Module -ListAvailable


## Usage

To download a TwinCAT/BSD repository just call the powershell cmdlet

    Backup-TCBSDRepo -Url "https://tcbsd.beckhoff.com/TCBSD/13/stable/" -OutputPath "C:\tcbsd\repository"

This may take some time as the repository is a couple of gigabytes in size.