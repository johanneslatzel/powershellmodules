[string]$SENSOR_CHANNEL_STORAGE_FOLDER = "C:\temp\prtg\sensor\channel"
[string]$CSV_SEPERATOR_CHAR = ";"


Enum PrtgChannelMode {
	Absolute
	Difference
}

Enum PrtgChannelUnit {
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
	TimeHours;
}


Class PrtgChannelLimit {

	# explicitaly no [float] even tho they are to make them $null-able
	$WarningMin
	$WarningMax
	$ErrorMin
	$ErrorMax

	PrtgChannelLimit($WarningMin, $WarningMax, $ErrorMin, $ErrorMax) {
		$this.WarningMin = $WarningMin
		$this.WarningMax = $WarningMax
		$this.ErrorMin = $ErrorMin
		$this.ErrorMax = $ErrorMax
	}

}


Class PrtgChannel {

	[string]$Name
	[string]$Value
	[PrtgChannelUnit]$Unit
	[string]$CustomUnit
	[PrtgChannelMode]$Mode
	[PrtgChannelLimit]$Limit
	[string]$ValueLookupId
	[bool]$IsFloat

	PrtgChannel([string]$Name, [string]$Value) {
		$this.Name = $Name
		$this.Value = $Value
		$this.Unit = [PrtgChannelUnit]::Count
		$this.CustomUnit = ""
		$this.Mode = [PrtgChannelMode]::Absolute
		$this.Limit = $null
		$this.ValueLookupId = ""
		$this.IsFloat = $false
	}

}


Class PrtgSensor {

	[System.Collections.ArrayList]$ChannelList
	[int]$ErrorCode
	[string]$Text
	[int]$Id

	PrtgSensor() {
		$this.ChannelList = New-Object System.Collections.ArrayList
		$this.ErrorCode = 0
		$this.Text = ""
		$this.Id = 0
	}
	
}


function ConvertTo-PrtgXml() {
	[cmdletbinding()]
	param(  
		[Parameter(Position = 0, Mandatory = $true, ValueFromPipeline = $true)][PrtgSensor]$Sensor
	)
	Process {
		[System.Text.StringBuilder]$builder = [System.Text.StringBuilder]::new(500)
		$builder = $builder.Append("<prtg>")
		foreach ( $channel in $Sensor.ChannelList ) {
			$builder = $builder.Append("<result><channel>").Append($channel.Name).Append("</channel><value>").
			Append($channel.Value).Append("</value><unit>").Append($channel.Unit).Append("</unit>")
			if ($channel.unit -eq [PrtgChannelUnit]::Custom) {
				
				$builder = $builder.Append("<customunit>").Append($channel.CustomUnit).Append("</customunit>")
			}
			$builder = $builder.Append("<mode>").Append($channel.Mode).Append("</mode>")
			if ($channel.IsFloat) {
				
				$builder = $builder.Append("<float>1</float>")
			}
			if ( $channel.Limit ) {
				if ( $channel.Limit.ErrorMin ) {
					
					$builder = $builder.Append("<limitminerror>").Append($channel.Limit.ErrorMin).
					Append("</limitminerror>")
				}
				if ( $channel.Limit.WarningMin ) {
					
					$builder = $builder.Append("<limitminwarning>").Append($channel.Limit.WarningMin).
					Append("</limitminwarning>")
				}
				if ( $channel.Limit.ErrorMax ) {
					
					$builder = $builder.Append("<limitmaxerror>").Append($channel.Limit.ErrorMax).
					Append("</limitmaxerror>")
				}
				if ( $channel.Limit.WarningMax ) {
					$builder = $builder.Append("<limitmaxwarning>").Append($channel.Limit.WarningMax).
					Append("</limitmaxwarning>")
				}
				# assume it has any limit since a limit object is present
				$builder = $builder.Append("<limitmode>1</limitmode>")
			}
			else {
				$builder = $builder.Append("<limitmode>0</limitmode>")
			}
			if ( $Channel.ValueLookupId ) {
				$builder = $builder.Append("<ValueLookup>").Append($Channel.ValueLookupId).Append("</ValueLookup>")
			}
			$builder = $builder.Append("</result>")
		}
		if ( $Sensor.ErrorCode ) {
			$builder = $builder.Append("<error>").Append($Sensor.ErrorCode).Append("</error>")
		}
		if ( $Sensor.Text ) {
			$builder = $builder.Append("<text>").Append($Sensor.Text).Append("</text>")
		}
		return $builder.Append("</prtg>").ToString()
	}
}


function Add-PrtgChannel() {
	[cmdletbinding()]
	param(
		[Parameter(Position = 0, Mandatory = $true, ValueFromPipeline = $true)][PrtgSensor]$Sensor,
		[Parameter(Position = 1, Mandatory = $true)][string]$Name,
		[Parameter(Position = 2, Mandatory = $true)][string]$Value,
		[Parameter(Position = 3, Mandatory = $false)][PrtgChannelUnit]$Unit = [PrtgChannelUnit]::Count,
		[Parameter(Position = 4, Mandatory = $false)][PrtgChannelMode]$Mode = [PrtgChannelMode]::Absolute,
		[Parameter(Position = 5, Mandatory = $false)][string]$ValueLookupId = "",
		[Parameter(Position = 6, Mandatory = $false)][switch]$Float = $false,
		[Parameter(Position = 7, Mandatory = $false)][string]$CustomUnit = "",
		[Parameter(Position = 8, Mandatory = $false)]$WarningMin = $null,
		[Parameter(Position = 9, Mandatory = $false)]$WarningMax = $null,
		[Parameter(Position = 10, Mandatory = $false)]$ErrorMin = $null,
		[Parameter(Position = 11, Mandatory = $false)]$ErrorMax = $null
	)
	Process {
		$channel = [PrtgChannel]::new($Name, $Value)
		$channel.Unit = $Unit
		$channel.Mode = $Mode
		$channel.ValueLookupId = $ValueLookupId
		$channel.IsFloat = $Float
		$channel.CustomUnit = $CustomUnit
		if( $WarningMin -or $WarningMax -or $ErrorMin -or $ErrorMax ) {
			$channel.Limit = [PrtgChannelLimit]::new($WarningMin, $WarningMax, $ErrorMin, $ErrorMax)
		}
		$garbage = $sensor.ChannelList.Add($channel)
		return $sensor
	}
}


function New-PrtgSensor() {
	[cmdletbinding()]
	param(
		[Parameter(Position = 0, Mandatory = $false)][int]$Id
	)
	Process {
		[PrtgSensor]$sensor = [PrtgSensor]::new()
		if ( $Id ) {
			$sensor.Id = $Id
		}
		return $sensor
	}
}


function Set-PrtgSensorText() {
	[cmdletbinding()]
	param(  
		[Parameter(Position = 0, Mandatory = $true, ValueFromPipeline = $true)][PrtgSensor]$sensor,
		[Parameter(Position = 1, Mandatory = $false)][string]$Text = ""
	)
	Process {
		$sensor.Text = $Text
		return $sensor
	}
}


function Push-PrtgSensor() {
	[cmdletbinding()]
	param(  
		[Parameter(Mandatory = $True, ValueFromPipeline = $true, Position = 0)][PrtgSensor]$Sensor,
		[Parameter(Mandatory = $True, Position = 1)][string]$Guid,
		[Parameter(Mandatory = $True, Position = 2)][string]$ProbeName,
		[Parameter(Mandatory = $False, Position = 3)][string]$Port = 5050,
		[Parameter(Mandatory = $False, Position = 3)][Microsoft.PowerShell.Commands.WebRequestMethod]$Method = [Microsoft.PowerShell.Commands.WebRequestMethod]::Get
	)
	Process {
		Write-Verbose "GUID: $Guid"
		Write-Verbose "ProbeName: $ProbeName"
		Write-Verbose "Port: $Port"
		Write-Verbose "Method: $Method"
		$content = [uri]::EscapeDataString(($Sensor | ConvertTo-PrtgXml))
		Write-Verbose "content: $content"
		if ( $Method -eq [Microsoft.PowerShell.Commands.WebRequestMethod]::Get ) {
			$uri = "http://$($ProbeName):$Port/$($Guid)?content=$content"
			Write-Verbose "uri: $uri"
			Invoke-WebRequest -Uri $uri -Method $Method -UseBasicParsing -ContentType "application/xml"
		}
		elseif ( $Method -eq [Microsoft.PowerShell.Commands.WebRequestMethod]::Post ) {
			$uri = "http://$($ProbeName):$Port/$Guid"
			Write-Verbose "uri: $uri"
			Invoke-WebRequest -Uri $uri -Method $Method -Body $content -UseBasicParsing
		}
		else {
			throw [exception]::new("method $Method not supported")
		}
	}
}

Function Export-PrtgChannelData() {
	[cmdletbinding()]
	param(  
		[Parameter(Position = 0, Mandatory = $true, ValueFromPipeline = $true)][PrtgSensor]$Sensor
	)
	Process {
		[System.Text.StringBuilder]$builder = [System.Text.StringBuilder]::new(500)
		$builder.Append((Get-Date))
		foreach( $channel in $Sensor.ChannelList ) {
			$builder.Append("`n")
			$builder.Append($channel.name)
			$builder.Append($CSV_SEPERATOR_CHAR)
			$builder.Append($channel.value)
		}
		return $data
	}
}

function Save-PrtgSensorChannels() {
	[cmdletbinding()]
	param(  
		[Parameter(Position = 0, Mandatory = $true, ValueFromPipeline = $true)][PrtgSensor]$Sensor
	)
	Process {
		if ( -not $Sensor.Id ) {
			# 0 means its the default value, so no configuration took place
			throw [Exception]::new("sensor id is 0")
		}
		if ( -not (Test-Path -Path $SENSOR_CHANNEL_STORAGE_FOLDER) ) {
			mkdir $SENSOR_CHANNEL_STORAGE_FOLDER
		}
		$garbage = Set-Content -Path "$SENSOR_CHANNEL_STORAGE_FOLDER\$($Sensor.Id).dat" -Value ($sensor | Export-PrtgChannelData) -Force
		return $Sensor
	}
}

function Invoke-PrtgChannelSubtraction() {
	[cmdletbinding()]
	param(  
		[Parameter(Position = 0, Mandatory = $true, ValueFromPipeline = $true)][PrtgSensor]$Sensor,
		[Parameter(Position = 1, Mandatory = $true)][string]$ChannelName,
		[Parameter(Position = 2, Mandatory = $true)][string]$ChannelUnitDisplayName
	)
	Process {
		if ( -not $Sensor.Id ) {
			# 0 means its the default value, so no configuration took place
			throw [System.NullReferenceException]::new("sensor id is `$null or 0")
		}
		[string]$path = "$SENSOR_CHANNEL_STORAGE_FOLDER\$($Sensor.Id).dat"
		if ( (Test-Path $path) ) {
			$data = (Get-Content -Path $path).Split("`n")
			[float]$timeDiffSeconds = ((Get-Date) - [datetime]::ParseExact($data[0], "dd.MM.yyyy HH:mm:ss", $null)).TotalSeconds
			for ($a = 1; $a -lt $data.Count; $a++) {
				$line = $data[$a].Split($CSV_SEPERATOR_CHAR)
				if ( $ChannelName.Equals($line[0]) ) {
					foreach ( $channel in $Sensor.channel_list ) {
						if ( $ChannelName.equals($channel.Name) ) {
							[float]$speedValue = ($channel.value - $line[1]) / $timeDiffSeconds
							# round to 2 floating points or less
							$speedValue = ([float]([long]($speedValue * 100))) / 100
							$Sensor = $Sensor | Add-PrtgChannel -Name "$ChannelName (Speed)" -Value $speedValue -Unit Custom -CustomUnit "$ChannelUnitDisplayName/s" -Float
							break
						}
					}
					break
				}
			}
		}
		return $Sensor
	}
}

function Set-PrtgSensorId() {
	[cmdletbinding()]
	param(  
		[Parameter(Position = 0, Mandatory = $true, ValueFromPipeline = $true)][PrtgSensor]$Sensor,
		[Parameter(Position = 1, Mandatory = $true)][int]$Id
	)
	Process {
		$Sensor.Id = $Id
		return $Sensor
	}
}

function Set-PrtgSensorError() {
	[cmdletbinding()]
	param(  
		[Parameter(Position = 0, Mandatory = $true, ValueFromPipeline = $true)][PrtgSensor]$sensor,
		[Parameter(Position = 1, Mandatory = $true)][int]$ErrorCode,
		[Parameter(Position = 2, Mandatory = $false)][string]$Text = "",
		[Parameter(Position = 3, Mandatory = $false)][System.Management.Automation.ErrorRecord]$ErrorRecord = $null
	)
	Process {
		$sensor.ErrorCode = $ErrorCode
		$localText = ""
		if( $Text ) {
			$localText = $Text
		}
		if( $ErrorRecord ) {
			if( $ErrorRecord.ErrorDetails -and $ErrorRecord.ErrorDetails.Message ) {
				$localText += ", ErrorDetails: " + $ErrorRecord.ErrorDetails.Message
			}
			elseif( $ErrorRecord.Exception -and $ErrorRecord.Exception.Message ) {
				$localText += ", Exception: " + $ErrorRecord.Exception.Message
			}
		}
		if( $localText ) {
			$sensor.Text = $localText
		}
		return $sensor
	}
}
