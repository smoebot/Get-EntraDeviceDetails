# Get-EntraDeviceDetails

Powershell. Get information about an Entra/AzureAD Device by asset name

Given an assetname, filters the list of devices in Azure AD by checking the DisplayName field

_Currently uses the Beta cmdlets, for the V2 Microsoft API_

---

**Parameters**

_AssetName_

The asset you are searching for.  This should be the DisplayName

---

**Examples**

```powershell
Get-DeviceDetails -AssetName costanza-laptop
```
