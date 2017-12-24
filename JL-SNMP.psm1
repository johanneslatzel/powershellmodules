########################################################################################################################
#
# Author: Johannes B. Latzel
# 
# Version: 1.3
# 
########################################################################################################################
#
# Description:
#
#     provides an easy-to-use powershell-wrapper for net-snmp
#
########################################################################################################################
#
# Dependencies:
#
#     Powershell 5.0 and above
#     net-snmp 5.7.3 rc3 and above
#         (the binaries "snmpwalk.exe" und "snmpget.exe" are expected to be in C:\Program Files\Net-SNMP\bin)
#
########################################################################################################################


# a result of an snmp-query
Class SNMPResult {
	[string]$oid
    [string]$type
    [string]$value
    SNMPResult([string]$snmp_result_string) {
        $split = $snmp_result_string.Split("=")
        $this.oid = $split[0].Trim()
        $split = $split[1].Split(":")
        $this.type = $split[0].Trim()
        $this.value = ""
        for($a=1;$a -lt $split.Count;$a++) {
            $this.value += $split[$a]
        }
        if( $this.value -eq $null ) {
            $this.value = ""
        }
        else {
            $this.value = $this.value.Trim()
        }
    }
}


<# 
 .Synopsis
  performs a snmpwalk

 .Description
  performs a snmpwalk and returns the result as a [SNMPResult[]]
  
 .Parameter hostname
  the hostname or ip adress of the target
  
 .Parameter oid
  the oid
  
 .Parameter community
  the community
  
 .Parameter version
  the snmp-version to use
  
 .Outputs
  [SNMPResult[]]

 .Example
  [SNMPResult[]]$snmp_result = Get-SNMPWalk -hostname "localhost" -oid ".1" -community "public"
   
#>
function Get-SNMPWalk() {
	[cmdletbinding()]
	Param(
		[Parameter(
			Position=0,
			Mandatory=$true
		)]
		[string]$hostname,
		[Parameter(
			Position=1,
			Mandatory=$true
		)]
		[string]$oid,
		[Parameter(
			Position=2,
			Mandatory=$false
		)]
		[string]$community="public",
		[Parameter(
			Position=3,
			Mandatory=$false
		)]
		[string]$version="2c"
	)
	$snmp_walk = ."C:\Program Files\Net-SNMP\bin\snmpwalk.exe" -v $version -c $community -O f $hostname $oid
    $snmp_walk | % {
        [SNMPResult]::new($_)
    }
}
export-modulemember -function Get-SNMPWalk


<# 
 .Synopsis
  performs a snmpwalk

 .Description
  performs a snmpwalk and returns the result-values as a [string[]]
  
 .Parameter hostname
  the hostname or ip adress of the target
  
 .Parameter oid
  the oid
  
 .Parameter community
  the community
  
 .Parameter version
  the snmp-version to use
  
 .Outputs
  [string[]]

 .Example
  [string[]]$snmp_result = Get-SNMPWalkValue -hostname "localhost" -oid ".1" -community "public"
   
#>
function Get-SNMPWalkValue() {
	[cmdletbinding()]
	Param(
		[Parameter(
			Position=0,
			Mandatory=$true
		)]
		[string]$hostname,
		[Parameter(
			Position=1,
			Mandatory=$true
		)]
		[string]$oid,
		[Parameter(
			Position=2,
			Mandatory=$false
		)]
		[string]$community="public",
		[Parameter(
			Position=3,
			Mandatory=$false
		)]
		[string]$version="2c"
	)
	Get-SNMPWalk -hostname $hostname -oid $oid -community $community -version $version | % {$_.Value}
}
export-modulemember -function Get-SNMPWalkValue

<# 
 .Synopsis
  performs a snmpget

 .Description
  performs a snmpget and returns the result as a [SNMPResult]
  
 .Parameter hostname
  the hostname or ip adress of the target
  
 .Parameter oid
  the oid
  
 .Parameter community
  the community
  
 .Parameter version
  the snmp-version to use
  
 .Outputs
  [SNMPResult]

 .Example
  [SNMPResult]$snmp_result = Get-SNMPGet -hostname "localhost" -oid ".1" -community "public"
   
#>
function Get-SNMP() {
	[cmdletbinding()]
	Param(
		[Parameter(
			Position=0,
			Mandatory=$true
		)]
		[string]$hostname,
		[Parameter(
			Position=1,
			Mandatory=$true
		)]
		[string]$oid,
		[Parameter(
			Position=2,
			Mandatory=$false
		)]
		[string]$community="public",
		[Parameter(
			Position=3,
			Mandatory=$false
		)]
		[string]$version="2c"
	)
	$snmp_get = ."C:\Program Files\Net-SNMP\bin\snmpget.exe" -v $version -c $community -O f $hostname $oid
    [SNMPResult]::new($snmp_get)
}
export-modulemember -function Get-SNMP

<# 
 .Synopsis
  performs a snmpget

 .Description
  performs a snmpget and returns the result as a [string]
  
 .Parameter hostname
  the hostname or ip adress of the target
  
 .Parameter oid
  the oid
  
 .Parameter community
  the community
  
 .Parameter version
  the snmp-version to use
  
 .Outputs
  [string]

 .Example
  [string]$snmp_result = Get-SNMPGetValue -hostname "localhost" -oid ".1" -community "public"
   
#>
function Get-SNMPValue() {
	[cmdletbinding()]
	Param(
		[Parameter(
			Position=0,
			Mandatory=$true
		)]
		[string]$hostname,
		[Parameter(
			Position=1,
			Mandatory=$true
		)]
		[string]$oid,
		[Parameter(
			Position=2,
			Mandatory=$false
		)]
		[string]$community="public",
		[Parameter(
			Position=3,
			Mandatory=$false
		)]
		[string]$version="2c"
	)
	(Get-SNMP -hostname $hostname -oid $oid -community $community -version $version).Value
}
export-modulemember -function Get-SNMPValue