# https://docs.sharpsnmp.com/tutorials/introduction.html
# https://github.com/lextudio/sharpsnmplib

$TIME_ZONE = (Get-Timezone)

class SnmpTarget {
    [IPEndpoint]$EndPoint = $null
    [int]$Timeout = 60000
    [Lextm.SharpSnmpLib.VersionCode]$VersionCode = [Lextm.SharpSnmpLib.VersionCode]::V1
    [Lextm.SharpSnmpLib.OctetString]$Community = [Lextm.SharpSnmpLib.OctetString]::new("public")
}

Function New-SnmpTarget() {
    [cmdletbinding()]
    param(
        [Parameter(Mandatory = $true)][string]$Hostname,
        [Parameter()][int]$Port,
        [Parameter()][int]$Timeout,
        [Parameter()][string]$Community,
        [Parameter()][Lextm.SharpSnmpLib.VersionCode]$VersionCode
    )
    Process {
        [SnmpTarget]$snmpTarget = [SnmpTarget]::new()
        if ( $Community ) {
            $snmpTarget.Community = [Lextm.SharpSnmpLib.OctetString]::new($Community)
        }
        if ( $VersionCode ) {
            $snmpTarget.VersionCode = $VersionCode
        }
        $targetPort = 161
        if ( $Port ) {
            $targetPort = $Port
        }
        if ( $Timeout ) {
            $snmpTarget.Timeout = $Timeout
        }
        [ipaddress]$targetAddress = $null
        if ( $Hostname ) {
            try {
                $targetAddress = [ipaddress]::Parse($Hostname)
            }
            catch {
                try {
                    $targetAddress = (Resolve-DnsName $Hostname -QuickTimeout)[0].IPAddress
                }
                catch {
                    throw [Exception]::new("cannot parse or resolve Hostname `"$Hostname`"")
                }
            }
        }
        else {
            throw [Exception]::new("missing argument Hostname")
        }
        if ( -not $targetAddress ) {
            throw [Exception]::new("can not create ipaddress")
        }
        $snmpTarget.EndPoint = [IPEndpoint]::new($targetAddress, $targetPort)
        return $snmpTarget
    }
}

Function Invoke-SnmpGet() {
    [cmdletbinding()]
    param(  
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)][SnmpTarget]$SnmpTarget,
        [Parameter(Mandatory = $true)][string]$Oid
    )
    Process {
        [System.Collections.Generic.List[Lextm.SharpSnmpLib.Variable]]$variables = [System.Collections.Generic.List[Lextm.SharpSnmpLib.Variable]]::new()
        $variables.Add([Lextm.SharpSnmpLib.Variable]::new([Lextm.SharpSnmpLib.ObjectIdentifier]::new($Oid)))
        [Lextm.SharpSnmpLib.Messaging.Messenger]::Get($SnmpTarget.VersionCode, $SnmpTarget.Endpoint, $SnmpTarget.Community, $variables, $SnmpTarget.Timeout)
    }
}

Function Invoke-SnmpGetValue() {
    [cmdletbinding()]
    param(  
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)][SnmpTarget]$SnmpTarget,
        [Parameter(Mandatory = $true)][string]$Oid
    )
    Process {
        $SnmpTarget | Invoke-SnmpGet -Oid $Oid | Foreach-Object { $_.Data.ToString() }
    }
}

Function Invoke-SnmpWalk() {
    [cmdletbinding()]
    param(  
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)][SnmpTarget]$SnmpTarget,
        [Parameter(Mandatory = $true)][string]$Oid,
        [Parameter()][Lextm.SharpSnmpLib.Messaging.WalkMode]$WalkMode = [Lextm.SharpSnmpLib.Messaging.WalkMode]::WithinSubtree,
        [Parameter()][int]$MaxRepititions = 10
    )
    Process {
        [Lextm.SharpSnmpLib.ObjectIdentifier]$targetOid = [Lextm.SharpSnmpLib.ObjectIdentifier]::new($Oid)
        [System.Collections.Generic.List[Lextm.SharpSnmpLib.Variable]]$result = [System.Collections.Generic.List[Lextm.SharpSnmpLib.Variable]]::new()
        switch ( $SnmpTarget.VersionCode ) {
            V1 {
                $garbage = [Lextm.SharpSnmpLib.Messaging.Messenger]::Walk($SnmpTarget.VersionCode, $SnmpTarget.EndPoint, $SnmpTarget.Community, $targetOid, $result, $SnmpTarget.Timeout, $WalkMode)
            }
            V2 {
                $garbage = [Lextm.SharpSnmpLib.Messaging.Messenger]::BulkWalk($SnmpTarget.VersionCode, $SnmpTarget.EndPoint, $SnmpTarget.Community, $targetOid, $result, $SnmpTarget.Timeout, $MaxRepititions, $WalkMode, $null, $null)
            }
            default {
                throw [Exception]::new("the VersionCode `"$($snmpTarget.VersionCode)`" is not supported for this operation")
            }
        }
        return $result
    }
}

Function Invoke-SnmpWalkValue() {
    [cmdletbinding()]
    param(  
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)][SnmpTarget]$SnmpTarget,
        [Parameter(Mandatory = $true)][string]$Oid,
        [Parameter()][Lextm.SharpSnmpLib.Messaging.WalkMode]$WalkMode = [Lextm.SharpSnmpLib.Messaging.WalkMode]::WithinSubtree,
        [Parameter()][int]$MaxRepititions = 10
    )
    Process {
        $SnmpTarget | Invoke-SnmpWalk -Oid $Oid -WalkMode $WalkMode -MaxRepititions $MaxRepititions | Foreach-Object { $_.Data.ToString() }
    }
}

# http://www.mibdepot.com/cgi-bin/getmib3.cgi?win=mib_a&i=1&n=NETSERVER-MIB&r=auspex&f=Auspex_Mib.my&v=v1&t=def#DateAndTime
Function ConvertFrom-SnmpDateAndTime() {
    [cmdletbinding()]
    param(  
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)][Lextm.SharpSnmpLib.Variable]$Variable
    )
    Process {
        if ( -not $Variable.Data -or $Variable.Data.TypeCode -ne "OctetString" ) {
            throw [exception]::new("Variable does not have OctetString data")
        }
        [byte[]]$data = ([Lextm.SharpSnmpLib.OctetString]$Variable.Data).GetRaw()
        [bool]$hasTimeZone = $data.Count -eq 11
        if ( $data.Count -eq 8 -or $hasTimeZone ) {
            [datetime]$dateTime = [datetime]::New($data[0] * 256 + $data[1], $data[2], $data[3], $data[4], $data[5], $data[6], $data[7] * 100)
            if ($hasTimeZone) {
                [int]$sign = 0
                switch ([char]$data[8]) {
                    "+" { $sign = 1 }
                    "-" { $sign = -1 }
                    default {
                        throw [Exception]::new("direction from UTC is neither `"+`" nor `"-`"")
                    }
                }
                return $dateTime.AddMinutes($TIME_ZONE.BaseUtcOffset.TotalMinutes - $sign * ($data[9] * 60 + $data[10]))
            }
            return $dateTime
        }
        throw [Exception]::new("8 or 11 bytes expected and got $($data.Count) instead")
    }
}