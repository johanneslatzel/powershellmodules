# Powershell Modules

Have a look at the specific modules for dependencies like the minimum version of powershell. Use [bug report](https://github.com/johanneslatzel/powershellmodules/issues/new?assignees=&labels=&template=bug_report.md&title=) to report bugs or to ask questions.

Available modules:

| name | tested |
| :-: | :-: |
| Nuttercode-PRTG | ✅ |
| Nuttercode-SNMP | ✅ |

## Nuttercode-PRTG

The Nuttercode-PRTG module provides functions to create Prtg [EXE/XML sensor](https://www.paessler.com/manuals/prtg/custom_sensors#exe_script) results in Powershell. Please refer to [advanced custom prtg sensors](https://www.paessler.com/manuals/prtg/exe_script_advanced_sensor) for more information on EXE/XML sensors themselves.

To see all available functions
```powershell
Import-Module Nuttercode-Prtg
Get-Command -Module Nuttercode-Prtg
```
To get help for individual functions use
```powershell
{name of the function} | help
```

### Example 1
Creates a sensor with a channel "Fan Speed" with the custom unit "rpm" and value "1500".
```powershell
$sensor = New-PrtgSensor
$sensor = $sensor | Add-PrtgChannel -Name "Fan Speed" -Value 1500 -Unit Custom -CustomUnit "rpm"
$sensor | ConvertTo-PrtgXml
```
Or in short
```powershell
New-PrtgSensor | Add-PrtgChannel -Name "Fan Speed" -Value 1500 -Unit Custom -CustomUnit "rpm" | ConvertTo-PrtgXml
```

## Nuttercode-SNMP

The Nuttercode-SNMP module provides easy to use functions to get Snmp data from a local or remote maschine with powershell. This module uses [SharpSnmpLib]{https://github.com/lextudio/sharpsnmplib} and distributes this dependency with it.

To see all available functions
```powershell
Import-Module Nuttercode-Snmp
Get-Command -Module Nuttercode-Snmp
```
To get help for individual functions use
```powershell
{name of the function} | help
```

### Example 1
Reads the snmp value with oid "1.3.6.1.2.1.25.1.1.0" from server "server1"
```powershell
$snmpTarget = New-SnmpTarget -Hostname "server1"
Invoke-SnmpGet -SnmpTarget $snmpTarget -Oid "1.3.6.1.2.1.25.1.1.0"
```
Or in short
```powershell
New-SnmpTarget -Hostname "server1" | Invoke-SnmpGet -Oid "1.3.6.1.2.1.25.1.1.0"
```