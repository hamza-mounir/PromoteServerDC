# PromoteServerDC PowerShell Script

This PowerShell script, created by Hamza Mounir, is designed to promote a server to a domain controller. It's a comprehensive script that takes into account several parameters, some of which are mandatory while others are optional.

## Author
**Hamza Mounir**
- LinkedIn: [https://www.linkedin.com/in/hamzamounir/](https://www.linkedin.com/in/hamzamounir/)

## Synopsis
The PromoteServerDC script promotes a server to a domain controller.

## Description
The PromoteServerDC script uses several parameters to promote a server to a domain controller. Some parameters are mandatory while others are optional. The password parameter refers to the Directory Services Restore Mode (DSRM) password.

## Parameters
- `mode`: The domain and forest mode. You can enter either the mode name or its corresponding number. This parameter is **mandatory**.
- `domain`: Your domain name. This parameter is **mandatory**.
- `databasepath`: The path to your database. This parameter is optional with a default value of 'C:\\Windows\\NTDS'.
- `sysvolpath`: The path to your SYSVOL. This parameter is optional with a default value of 'C:\\Windows\\SYSVOL'.
- `netbiosname`: The NetBIOS name of the domain. This parameter is optional. If not provided, the first part of your domain name will be used.

## Example
```powershell
.\PromoteServerDC.ps1 -mode 7 -domain company.local
.\PromoteServerDC.ps1 -mode <DomainAndForestMode> -domain <YourDomain> -databasepath <DatabasePath> -sysvolpath <SysvolPath> -netbiosname <NetBIOSName>
```
Replace `<DomainAndForestMode>`, `<YourDomain>`, `<DatabasePath>`, `<SysvolPath>`, and `<NetBIOSName>` with your actual values.

## Note
This script must be run as an administrator.

## Disclaimer
Please use this script responsibly. Always test scripts in a controlled environment before deploying them in production. The author of this script bears no responsibility for any issues or damages caused by the use of this script.

I hope you find this script useful. If you have any questions or need further assistance, feel free to reach out. 😊
