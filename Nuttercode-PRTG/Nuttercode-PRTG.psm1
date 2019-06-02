########################################################################################################################
#
# Author: Johannes B. Latzel
# 
# Version: 2019.05.30
#
########################################################################################################################
#
# Description:
#
#     provides CMDlets to create PRTG sensor objects, add channels, and convert them to PRTG exexml sensor output
#
########################################################################################################################
#
# Dependencies:
#
#     Powershell 5.0 (or higher)
#
########################################################################################################################

Enum PRTGChannelMode {
	Absolute
	Difference
}

Enum PRTGChannelUnit {
	BytesBandwidth
	BytesMemory
	BytesDisk
	Temperature
	Percent
	TimeResponse
	TimeSeconds
	Custom
	Count
	CPU	
	BytesFile
	SpeedDisk
	SpeedNet
	TimeHours
}


Class PRTGChannelLimit {
    [float]$warning_min
    [float]$warning_max
    [float]$error_min
    [float]$error_max
    [bool]$DisableMin
    [bool]$DisableMax
    [bool]$DisableWarningMin
    [bool]$DisableWarningMax
    [bool]$DisableErrorMin
    [bool]$DisableErrorMax
    PRTGChannelLimit([float]$warning_min, [float]$warning_max, [float]$error_min, [float]$error_max, [bool]$DisableMin, [bool]$DisableMax, [bool]$DisableWarningMin, [bool]$DisableWarningMax, [bool]$DisableErrorMin, [bool]$DisableErrorMax) {
        $this.warning_min = $warning_min
        $this.warning_max = $warning_max
        $this.error_min = $error_min
        $this.error_max = $error_max
        $this.DisableMin = $DisableMin
        $this.DisableMax = $DisableMax
        $this.DisableWarningMin = $DisableWarningMin
        $this.DisableWarningMax = $DisableWarningMax
        $this.DisableErrorMin = $DisableErrorMin
        $this.DisableErrorMax = $DisableErrorMax
        if( $DisableWarningMin -and $DisableErrorMin ) {
            $this.DisableMin = $true
        }
        if( $DisableWarningMax -and $DisableErrorMax ) {
            $this.DisableMax = $true
        }
    }
}


Class PRTGChannel {
	[string]$name
	[string]$value
	[PRTGChannelUnit]$unit
    [string]$custom_unit
	[PRTGChannelMode]$mode
    [PRTGChannelLimit]$limit
    [string]$value_lookup_id
    [bool]$is_float
	PRTGChannel([string]$name, [string]$value, [PRTGChannelUnit]$unit, [PRTGChannelMode]$mode, [PRTGChannelLimit]$limit, [string]$value_lookup_id, [bool]$is_float, [string]$custom_unit) {
		$this.name = $name
		$this.value = $value
		$this.unit = $unit
		$this.mode = $mode
        $this.limit = $limit
        $this.value_lookup_id = $value_lookup_id
        $this.is_float = $is_float
        $this.custom_unit = $custom_unit
	}
}


Class PRTGSensor {
	[System.Collections.ArrayList]$channel_list
	[int]$error_code
    [bool]$has_error
    [string]$text
    [bool]$has_text = $false
	PRTGSensor() {
		$this.channel_list = New-Object System.Collections.ArrayList
		$this.error_code = 0
        $this.has_error = $false
        $this.text = ""
        $this.has_text = $false
	}
	[void]addChannel([string]$name, [string]$value, [PRTGChannelUnit]$unit, [PRTGChannelMode]$mode, [PRTGChannelLimit]$limit, [string]$value_lookup_id, [bool]$is_float, [string]$custom_unit) {
        $this.channel_list.Add([PRTGChannel]::new($name, $value, $unit, $mode, $limit, $value_lookup_id, $is_float, $custom_unit))
	}
	[void]setError([int]$error_code, [string]$text) {
		$this.error_code = $error_code
        $this.has_error = $true
        $this.setText($text)
	}
    [void]setText([string]$text) {
        if( $text ) {
            $this.text = $text
            $this.has_text = $true
        }
        else {
			$this.text = "no text available"
            $this.has_text = $false
		}
    }
	[string]toXML() {
		[string]$xml = "<prtg>"
			$this.channel_list | % {
				$xml += "<result>"
					$xml += "<channel>"
						$xml += $_.name
					$xml += "</channel>"
					$xml += "<value>"
						$xml += $_.value
					$xml += "</value>"
					$xml += "<unit>"
						$xml += Convert-PRTGChannelUnitToString -unit $_.unit
					$xml += "</unit>"
                    if ($_.unit -eq [PRTGChannelUnit]::Custom) {
                        $xml += "<customunit>"
                            $xml += $_.custom_unit
                        $xml += "</customunit>"
                    }
					$xml += "<mode>"
						$xml += Convert-PRTGChannelModeToString -mode $_.mode
					$xml += "</mode>"
					if ($_.is_float) {
                        $xml += "<float>1</float>"
                    }
					if( $_.limit ) {
                        if(-not $_.limit.DisableMin) {
                            if( -not $_.limit.DisableWarningMin ) {
                                $xml += "<limitminwarning>"
						            $xml += $_.limit.warning_min
					            $xml += "</limitminwarning>"
                            }
                            if( -not $_.limit.DisableErrorMin ) {
                                $xml += "<limitminerror>"
						            $xml += $_.limit.error_min
					            $xml += "</limitminerror>"
                            }
                        }
                        if(-not $_.limit.DisableMax) {
                            if( -not $_.limit.DisableWarningMax ) {
                                $xml += "<limitmaxwarning>"
						            $xml += $_.limit.warning_max
					            $xml += "</limitmaxwarning>"
                            }
                            if( -not $_.limit.DisableErrorMax ) {
                                $xml += "<limitmaxerror>"
						            $xml += $_.limit.error_max
					            $xml += "</limitmaxerror>"
                            }
                        }
					    if(-not ($_.limit.DisableMin -and $_.limit.DisableMax) ) {
                            $xml += "<limitmode>"
						        $xml += 1
					        $xml += "</limitmode>"
                        }                        
                    }
                    else {
					    $xml += "<limitmode>"
						    $xml += 0
					    $xml += "</limitmode>"
                    }
					if( ($_.value_lookup_id -ne $null) -and ($_.value_lookup_id -ne "") ) {
                        $xml += "<ValueLookup>"
						    $xml += $_.value_lookup_id
					    $xml += "</ValueLookup>"
                    }
				$xml += "</result>"
			}
			if( $this.has_error ) {
				$xml += "<error>"
					$xml += $this.error_code
				$xml += "</error>"
			}
            if( $this.has_text ) {
				$xml += "<text>"
					$xml += $this.text
				$xml += "</text>"
            }
		return $xml + "</prtg>"
	}
}


Function Convert-PRTGChannelUnitToString([PRTGChannelUnit]$unit) {
	switch($unit) {
		BytesBandwidth {return "BytesBandwidth"}
		BytesMemory {return "BytesMemory"}
		BytesDisk {return "BytesDisk"}
		Temperature {return "Temperature"}
		Percent {return "Percent"}
		TimeResponse {return "TimeResponse"}
		TimeSeconds {return "TimeSeconds"}
		Custom {return "Custom"}
		Count {return "Count"}
		CPU {return "CPU"}
		BytesFile {return "BytesFile"}
		SpeedDisk {return "SpeedDisk"}
		SpeedNet {return "SpeedNet"}
		TimeHours {return "TimeHours"}
		default {return "Count"}
	}
}


Function Convert-PRTGChannelModeToString([PRTGChannelMode]$mode) {
	switch($mode) {
		Absolute {return "Absolute"}
		Difference {return "Difference"}
		default {return "Absolute"}
	}
}


function Convert-PRTGSensorToXML() {
	[cmdletbinding()]
	param(  
		[Parameter(
			Position=0, 
			Mandatory=$true, 
			ValueFromPipeline=$true)
		]
		[PRTGSensor]$sensor
    )
	Process {
		return $sensor.toXML()
	}
}
export-modulemember -function Convert-PRTGSensorToXML


function Add-PRTGChannel() {
	[cmdletbinding()]
	param(
		[Parameter(
			Position=0, 
			Mandatory=$true, 
			ValueFromPipeline=$true)
		]
		[PRTGSensor]$sensor,
		[Parameter(
			Position=1, 
			Mandatory=$true)
		]
		[string]$name,
		[Parameter(
			Position=2, 
			Mandatory=$true)
		]
		[string]$value,
		[Parameter(
			Position=3, 
			Mandatory=$false)
		]
		[PRTGChannelUnit]$unit = [PRTGChannelUnit]::Count,
		[Parameter(
			Position=4, 
			Mandatory=$false)
		]
		[PRTGChannelMode]$mode = [PRTGChannelMode]::Absolute,
		[Parameter(
			Position=4, 
			Mandatory=$false)
		]
		[PRTGChannelLimit]$limit = $null,
		[Parameter(
			Position=5, 
			Mandatory=$false)
		]
		[string]$value_lookup_id = $null,
		[Parameter(
			Position=5, 
			Mandatory=$false)
		]
		[switch]$is_float = $false,
		[Parameter(
			Position=6, 
			Mandatory=$false)
		]
		[string]$custom_unit = "units"
    )
	Process {
		$sensor.addChannel($name, $value, $unit, $mode, $limit, $value_lookup_id, $is_float, $custom_unit)
		return $sensor
	}
}
export-modulemember -function Add-PRTGChannel


function New-PRTGSensor() {
	return [PRTGSensor]::new()
}
export-modulemember -function New-PRTGSensor


function Set-PRTGSensorText() {
	[cmdletbinding()]
	param(  
		[Parameter(
			Position=0, 
			Mandatory=$true, 
			ValueFromPipeline=$true)
		]
		[PRTGSensor]$sensor,
		[Parameter(
			Position=1, 
			Mandatory=$true)
		]
		[string]$text
    )
	Process {
		$sensor.setText($text)
        return $sensor
	}
}
export-modulemember -function Set-PRTGSensorText


function New-PRTGChannelLimit() {
	[cmdletbinding()]
	param(
		[Parameter(
			Position=0, 
			Mandatory=$false)
		]
		[float]$warning_min,
		[Parameter(
			Position=1, 
			Mandatory=$false)
		]
		[float]$warning_max,
		[Parameter(
			Position=2, 
			Mandatory=$false)
		]
		[float]$error_min,
		[Parameter(
			Position=3, 
			Mandatory=$false)
		]
		[float]$error_max,
		[Parameter(
			Position=4, 
			Mandatory=$false)
		]
		[switch]$DisableMin,
		[Parameter(
			Position=5, 
			Mandatory=$false)
		]
		[switch]$DisableMax,
		[Parameter(
			Position=6, 
			Mandatory=$false)
		]
		[switch]$DisableWarningMin,
		[Parameter(
			Position=7, 
			Mandatory=$false)
		]
		[switch]$DisableWarningMax,
		[Parameter(
			Position=8, 
			Mandatory=$false)
		]
		[switch]$DisableErrorMin,
		[Parameter(
			Position=9, 
			Mandatory=$false)
		]
		[switch]$DisableErrorMax
    )
	Process {
		return [PRTGChannelLimit]::new($warning_min, $warning_max, $error_min, $error_max, $DisableMin, $DisableMax, $DisableWarningMin, $DisableWarningMax, $DisableErrorMin, $DisableErrorMax)
	}
}
export-modulemember -function New-PRTGChannelLimit