########################################################################################################################
#
# Author: Johannes B. Latzel
# 
# Version: 1.7
# 
########################################################################################################################
#
# Description:
#
#     wrapper for easy creation of PRTG-XML-sensors in powershell
#
########################################################################################################################
#
# Dependencies:
#
#     Powershell 5.1 and above
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


# represents the limit-values of a channel
Class PRTGChannelLimit {
    [float]$warning_min
    [float]$warning_max
    [float]$error_min
    [float]$error_max
    PRTGChannelLimit([float]$warning_min, [float]$warning_max, [float]$error_min, [float]$error_max) {
        $this.warning_min = $warning_min
        $this.warning_max = $warning_max
        $this.error_min = $error_min
        $this.error_max = $error_max
    }
}


# contains channel-parameters, like name, value, unit of measurement, etc.
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


# sensor contains all channels
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
                        $xml += "<limitminwarning>"
						    $xml += $_.limit.warning_min
					    $xml += "</limitminwarning>"
                        $xml += "<limitmaxwarning>"
						    $xml += $_.limit.warning_max
					    $xml += "</limitmaxwarning>"
                        $xml += "<limitminerror>"
						    $xml += $_.limit.error_min
					    $xml += "</limitminerror>"
                        $xml += "<limitmaxerror>"
						    $xml += $_.limit.error_max
					    $xml += "</limitmaxerror>"
					    $xml += "<limitmode>"
						    $xml += 1
					    $xml += "</limitmode>"                        
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


# converts [PRTGChannelUnit] to string-value
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


# converts [PRTGChannelMode] to string-value
Function Convert-PRTGChannelModeToString([PRTGChannelMode]$mode) {
	switch($mode) {
		Absolute {return "Absolute"}
		Difference {return "Difference"}
		default {return "Absolute"}
	}
}


<# 
 .Synopsis
  converts a [PRTGSensor] to an xml-formatted string

 .Description
  converts a [PRTGSensor] to an xml-formatted string - readable for a PRTG-probe
 
 .Parameter sensor
  the sensor - can be piped in
  
 .Inputs
  the sensor
  
 .Outputs
  xml-representation of the sensor as a string

 .Example 1
  New-Sensor | Add-PRTGChannel -name "Test" -value "42" | Convert-PRTGSensorToXML
   
#>
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


<# 
 .Synopsis
  adds a new channel to a sensor

 .Description
  adds a new channel to a sensor - sensor can be piped in
 
 .Parameter sensor
  the sensor
 
 .Parameter name
  the name of the channel
 
 .Parameter value
  the current value of the channel
 
 .Parameter unit
  the [PRTGChannelUnit] unit of measurement
 
 .Parameter mode
  the [PRTGChannelMode] mode
 
 .Parameter limit
  value limits for warning/error events
 
 .Parameter value_lookup_id
  id of the value-lookup, if used - the [PRTGChannnelUnit]::Custom must be used for value-lookups

 .Parameter is_float
  switch determines if the value is a floating-point value or integer value

 .Parameter custom_unit
  the name of the unit if [PRTGChannelUnit]::Custom is chosen
  
 .Inputs
  a sensor
  
 .Outputs
  the put-in sensor with a new channel

 .Example 1
  # saves a new sensor in $sensor with one channel
  $sensor = New-PRTGSensor | Add-PRTGChannel -name "Battery Capacity" -value 15 -unit "Percent"
   
#>
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


<# 
 .Synopsis
  creates a new [PRTGSensor] sensor

 .Description
  creates a new [PRTGSensor] sensor
  
 .Outputs
  a new [PRTGSensor] sensor

 .Example
  [PRTGSensor]$sensor = New-PRTGSensor
   
#>
function New-PRTGSensor() {
	return [PRTGSensor]::new()
}
export-modulemember -function New-PRTGSensor


<# 
 .Synopsis
  sets the text of a sensor

 .Description
  sets the text of a sensor
 
 .Parameter sensor
  the sensor

 .Parameter text
  the text
  
 .Inputs
  the sensor
  
 .Outputs
  the sensor

 .Example 1
  $sensor = New-PRTGSensor | Set-PRTGSensorText -text "00101010"
   
#>
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


<# 
 .Synopsis
  creates a new [PRtGChannelLimit] limit

 .Description
  creates a new [PRtGChannelLimit] limit
 
 .Parameter warning_min
  lower warning limit
 
 .Parameter warning_max
  upper warning limit
 
 .Parameter error_min
  lower error limit
 
 .Parameter error_max
  upper error limit
  
 .Outputs
  a new [PRTGChannelLimit]

 .Example 1
  $limit = New-PRTGChannelLimit -warning_min 10 -warning_max 100 -warning_error 5 -warning_max 100
   
#>
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
		[float]$error_max
    )
	Process {
		return [PRTGChannelLimit]::new($warning_min, $warning_max, $error_min, $error_max)
	}
}
export-modulemember -function New-PRTGChannelLimit