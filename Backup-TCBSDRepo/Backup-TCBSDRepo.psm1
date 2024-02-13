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
    if(!$OutputPath.EndsWith('\')){
        $OutputPath = $OutputPath + '\'
    }
    Download-Repofiles -DownloadUrl $Url -DownloadPath $OutputPath
}


function Download-Repofiles {
    Param ([string] $DownloadUrl, [string] $DownloadPath)
    $indexhtml = Invoke-WebRequest -Uri $DownloadUrl -UseBasicParsing
    foreach ($link in $indexhtml.Links){
        if (($link.href -like "*.*") -and ($link.href -notlike "*../")){
            Write-Host ("Downloading: " + $DownloadUrl + $link.href)
            Start-BitsTransfer -Source ($DownloadUrl + $link.href) -Destination ($DownloadPath + $link.href.Replace('/', '\'))
        } elseif ($link.href -notlike "*../"){
            New-Item -ItemType Directory -Force -Path ($DownloadPath + $link.href.Replace('/', '\'))
            Download-Repofiles -DownloadUrl ($DownloadUrl + $link.href) -DownloadPath ($DownloadPath + $link.href.Replace('/', '\'))
        }
    }
}

Export-ModuleMember -Function Backup-TCBSDRepo
