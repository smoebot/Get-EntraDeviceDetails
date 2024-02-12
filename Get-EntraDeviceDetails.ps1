function Get-EntraDeviceDetails {
    <#
    .SYNOPSIS
        Get information about an Entra/AzureAD Device by asset name
    .DESCRIPTION
        Get information about an Entra/AzureAD Device by asset name
        Given an assetname, filters the list of devices in Azure AD by checking the DisplayName field
    .PARAMETER AssetName
        The asset you are searching for.  This should be the DisplayName
    .NOTES
        Author: Joel Ashman
        v0.1 - (2023-12-20) Initial version
        v0.2 - (2024-02-08) Added better error handling
    .EXAMPLE
        Get-EntraDeviceDetails -AssetName yellowbus.petermanrealitytour.com
    #>

    #requires -version 7

    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]$AssetName
    )
    
    function Get-DeviceInfo{
        $BaseDeviceInfo = try{
            Get-MgDevice -Filter "startswith(DisplayName, '$($AssetName)')" | Select-Object Id,DisplayName,OperatingSystem,OperatingSystemVersion,DeviceCategory,DeviceOwnership,IsManaged,DeviceID,ProfileType,TrustType,ApproximateLastSignInDateTime
        }
        catch{
            Write-Host -ForegroundColor Red "`r`nCouldn't find $($AssetName).  Exiting`r`n"
        }
        $DeviceOwnerInfo = try{
            (Get-MgDeviceRegisteredOwner -DeviceId $BaseDeviceInfo.Id).AdditionalProperties
        }
        catch{
            Write-Host -ForegroundColor Red "Couldn't find the registered owner.  Probably due to $($AssetName) not being found.  Exiting"
        }
        $DeviceInfo = [pscustomobject]@{
            "DisplayName" = $BaseDeviceInfo.DisplayName
            "Id" = $BaseDeviceInfo.Id
            "OperatingSystem" = $BaseDeviceInfo.OperatingSystem
            "OperatingSystemVersion" = $BaseDeviceInfo.OperatingSystemVersion
            "DeviceCategory" = $BaseDeviceInfo.DeviceCategory
            "DeviceOwnership" = $BaseDeviceInfo.DeviceOwnership
            "IsManaged" = $BaseDeviceInfo.IsManaged
            "DeviceId" = $BaseDeviceInfo.DeviceId
            "ProfileType" = $BaseDeviceInfo.ProfileType
            "TrustType" = $BaseDeviceInfo.TrustType
            "ApproximateLastSignInDateTime" = $BaseDeviceInfo.ApproximateLastSignInDateTime
            "OwnerDisplayName" = $DeviceOwnerInfo.displayName
            "OwnerJobTitle" = $DeviceOwnerInfo.jobTitle
            "OwnerMail" = $DeviceOwnerInfo.mail
            "OwnerGivenName" = $DeviceOwnerInfo.givenName
            "OwnerSurname" = $DeviceOwnerInfo.surname
            "OwnerUserPrincipalName" = $DeviceOwnerInfo.userPrincipalName
        }
        # Show the Device details if the first lookup was successful, exit otherwise
        if ($BaseDeviceInfo){
            $DeviceInfo
        }
        else {
            Return
        }
    }

    # Check if the user is connected to Microsoft Graph first
    $ConnectedCheck = Get-MgContext

    if($ConnectedCheck -eq $null){
        Write-Host -ForegroundColor Yellow "Not connected to MS Graph API"

        # If there's no connection to Microsoft Graph, connect, prompt for auth, then run as normal
        try{
            Write-Host -ForegroundColor Cyan "Running Connect-Graph cmdlet and attempting authentication.  Use Sys account"
            Connect-Graph
            Get-DeviceInfo
        }
        # Bail out if we didn't authenticate properly
        catch{
            Write-Host -ForegroundColor Red "`r`nSomething went wrong.  Not authenticated to MS Graph API.  Exiting`r`n"
        }
    }

    # If we are already authenticated, then run as normal
    else{
        Write-Host -ForegroundColor Green "Connected to MS Graph API"
        Write-Host -ForegroundColor Cyan "Authentication Type: $($ConnectedCheck.AuthType)"
        Get-DeviceInfo        
    }
 }
