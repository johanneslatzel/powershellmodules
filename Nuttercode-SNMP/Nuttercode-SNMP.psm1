########################################################################################################################
#
# Author: Johannes B. Latzel
# 
# Version: 2019.09.09
#
########################################################################################################################
#
# Description:
#
#     uses "http://www.snmpsharpnet.com/" SnmpSharpNet to provide easy-to-use Snmp Powershell-CMDlets
#
########################################################################################################################
#
# Dependencies:
#
#     Powershell 5.0 (or higher)
#
########################################################################################################################

Add-Type -Path "SnmpSharpNet.dll"

class SNMPResult {
	[string]$Oid
    [string]$Value
    SNMPResult([string]$Oid, [string]$Value) {
        $this.Oid = $Oid
        $this.Value = $Value
    }
}

function Get-IpAddress([string]$Hostname) {
    [System.Net.IPHostEntry]$hostEntry = [System.Net.Dns]::GetHostEntry($Hostname)
    if( $hostEntry.AddressList.Length -gt 0 ) {
        return $hostEntry.AddressList[0]
    }
    else {
        throw [Exception]::new("$Hostname could not be resolved")
    }
}

function Get-SnmpWalk() {
	[cmdletbinding()] Param(
		[Parameter(Position=0, Mandatory=$true)][string]$Hostname,
		[Parameter(Position=1, Mandatory=$true)][string]$Oid,
		[Parameter(Position=2, Mandatory=$false)][string]$Community = "public"
	)
    $resultArray = @()
    $udpTarget = [SnmpSharpNet.UdpTarget]::new((Get-IpAddress -Hostname $Hostname), 161, 5000, 1)
    $pdu = [SnmpSharpNet.Pdu]::new([SnmpSharpNet.PduType]::GetBulk)
    $agentParameters = [SnmpSharpNet.AgentParameters]::new([SnmpSharpNet.OctetString]::new($Community))
    $agentParameters.Version = [SnmpSharpNet.SnmpVersion]::Ver2
    $rootOid = [SnmpSharpNet.Oid]::new($Oid)
    $lastOid = [SnmpSharpNet.Oid]::new($Oid)
    $resultArray = @()
    while( $lastOid -ne $null ) {
        if( $pdu.RequestId -ne 0 ) {
            $pdu.RequestId++
        }
        $pdu.VbList.Clear()
        $pdu.VbList.Add($lastOid)
        $result = [SnmpSharpNet.SnmpV2Packet] $udpTarget.Request($pdu, $agentParameters)
        $lastOid = $null
        if( $result -ne $null ) {
            foreach( $v in $result.Pdu.VbList ) {
                if( $rootOid.IsRootOf($v.Oid) ) {
                    if( $v.Value.Type -ne [SnmpSharpNet.SnmpConstants]::SMI_ENDOFMIBVIEW ) {
                        try {
                            $resultArray += [SNMPResult]::new([string]::Join(".", $v.Oid.ToString().Split(" ")), $v.Value.ToString())
                        }
                        catch {}
                        $lastOid = $v.Oid
                    }
                }
            }

        }
    }
    $udpTarget.Close()
    $resultArray
}


function Get-SnmpWalkValue() {
	[cmdletbinding()] Param(
		[Parameter(Position=0, Mandatory=$true)][string]$Hostname,
		[Parameter(Position=1, Mandatory=$true)][string]$Oid,
		[Parameter(Position=2, Mandatory=$false)][string]$Community = "public"
	)
	Get-SNMPWalk -Hostname $Hostname -Oid $Oid -Community $Community | % {$_.Value}
}


function Get-Snmp() {
	[cmdletbinding()] Param(
		[Parameter(Position=0, Mandatory=$true)][string]$Hostname,
		[Parameter(Position=1, Mandatory=$true)][string]$Oid,
		[Parameter(Position=2, Mandatory=$false)][string]$Community = "public"
	)
    try {
        $udpTarget = [SnmpSharpNet.UdpTarget]::new((Get-IpAddress -Hostname $Hostname), 161, 5000, 1)
        $pdu = [SnmpSharpNet.Pdu]::new([SnmpSharpNet.PduType]::Get)
        $pdu.VbList.Add($Oid)
        $agentParameters = [SnmpSharpNet.AgentParameters]::new([SnmpSharpNet.OctetString]::new($Community))
        $agentParameters.Version = [SnmpSharpNet.SnmpVersion]::Ver2
        $result = ([SnmpSharpNet.SnmpV2Packet] $udpTarget.Request($pdu, $agentParameters)).Pdu.VbList[0].Value.ToString()
        $udpTarget.Close()
    }
    catch {
        Write-Host $_
        $result = ""
    }
    [SNMPResult]::new($Oid, $result)
}


function Get-SnmpValue() {
	[cmdletbinding()] Param(
		[Parameter(Position=0, Mandatory=$true)][string]$Hostname,
		[Parameter(Position=1, Mandatory=$true)][string]$Oid,
		[Parameter(Position=2, Mandatory=$false)][string]$Community = "public"
	)
    $result = Get-SNMP -Hostname $Hostname -Oid $Oid -Community $Community
    if( ($result -ne $null) -and ($result.Value -ne $null) ) {
        return $result.Value
    }
	return ""
}