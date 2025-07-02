# SPDX-License-Identifier: 0BSD
# Copyright (c) 2022 Beckhoff Automation GmbH & Co. KG

<#
 .Synopsis
  Download the TwinCAT/BSD Repository to the local file system.

 .Description
  Download the TwinCAT/BSD Repository to the local file system.
  This is helpful in case you want to setup your own internal package server. 
 
 .Parameter Url
  The Url of the TwinCAT/BSD repository server.
  Usually it should be something like this:
  https://tcbsd.beckhoff.com/TCBSD/13/stable/packages/

 .Parameter OutputPath
  The path where to save the TwinCAT/BSD repository.

 .Example
  # Download repo.
  Backup-TCBSDRepo -Url "https://tcbsd.beckhoff.com/TCBSD/13/stable/" -OutputPath "C:\tcbsd\repository"
#>

function Backup-TCBSDRepo {
    param(
        [parameter(Mandatory=$true)]
        [ValidatePattern('([a-zA-Z]{3,})://([\w_-]+(?:(?:\.[\w_-]+)+))([\w.,@?^=%&:/~+#-]*[\w@?^=%&/~+#-])?')]
        [string]$Url,
    
        [parameter(Mandatory=$true)]
        [ValidateScript({Test-Path $_})]
        [string]$OutputPath
    )
    try {
        $indexhtml = Invoke-WebRequest -Uri $Url -UseBasicParsing
    } catch {
        if ($_.Exception.Message.Contains("401")) {
            $credentials = Get-Credential -Message "Please enter your myBeckhoff credentials:"
        } else {
            return $_.Exception.Message
        }
    }
    Download-Repofiles -DownloadUrl $Url -DownloadPath $OutputPath -Credentials $credentials
}


function Download-Repofiles {
    Param ([string] $DownloadUrl, [string] $DownloadPath, [pscredential] $Credentials)
    $indexhtml = Invoke-WebRequest -Credential $Credentials -Uri $DownloadUrl -UseBasicParsing
    foreach ($link in $indexhtml.Links){
        if (($link.href -like "*.*") -and ($link.href -notlike "*/") -and ($link.href -notlike "http*")){
            Write-Host ("Downloading: " + $DownloadUrl + $link.href)
            Start-BitsTransfer -Authentication Basic -Credential $Credentials -Source ($DownloadUrl + $link.href) -Destination ($DownloadPath + $link.href.Replace('/', '\'))
        } elseif (($link.href -notlike "*../")  -and ($link.href -notlike "http*")){
            New-Item -ItemType Directory -Force -Path ($DownloadPath + $link.href.Replace('/', '\'))
            Download-Repofiles -DownloadUrl ($DownloadUrl + $link.href) -DownloadPath ($DownloadPath + $link.href.Replace('/', '\')) -Credentials $Credentials
        }
    }
}

Export-ModuleMember -Function Backup-TCBSDRepo