########################################################################################################################
#
# Author: Johannes B. Latzel
# 
# Version: 1.1
# 
########################################################################################################################
#
# Description:
#
#     provides functions for writing to the eventlog
#     creates new eventlogs if needed
#
########################################################################################################################
#
# Dependencies:
#
#  Powershell 4.0 and above
#     
#
########################################################################################################################


Function Initialize-EventLogSource([string]$EventLogName, [string]$EventSource) {
	if( -not [System.Diagnostics.EventLog]::Exists($EventLogName + "\" + $EventSource) ) {
		New-EventLog -LogName $EventLogName -Source $EventSource
	}
}


<# 
 .Synopsis
  writes an error-event to an eventlog

 .Description
  the specific error-event will be written in the eventlog $EventLogName with the source $EventSource
  additionally the name of the calling script and the line of the call will be added to the event-message

 .Parameter EventLogName
  the name of the eventlog

 .Parameter EventSource
  the source of the event

 .Parameter EventID
  the id of the event

 .Parameter Message
  the message of the event

 .Example
   Write-ErrorEvent -EventID 10 -Message "error 15 - wrong password"
   
#>
function Write-ErrorEvent {
	param(
		[string]$EventLogName = "Windows PowerShell",
		[string]$EventSource = "Powershell",
		[Parameter(Mandatory=$true)]
		[int]$EventID,
		[Parameter(Mandatory=$true)]
		[string]$Message
	)
	Initialize-EventLogSource -EventLogName $EventLogName -EventSource $EventSource
	Write-EventLog -EntryType "Error" -EventID $EventID -LogName $EventLogName -Message (
		$Message + "`n`n" + "Script Name:`t`t" + $MyInvocation.ScriptName + "`nLine:`t`t`t" + $MyInvocation.ScriptLineNumber + "`nOrigin:`t`t`t" + $MyInvocation.CommandOrigin
	) -Source $EventSource
}
export-modulemember -function Write-ErrorEvent



<# 
 .Synopsis
  writes an information-event to an eventlog

 .Description
  the specific information-event will be written in the eventlog $EventLogName with the source $EventSource
  additionally the name of the calling script and the line of the call will be added to the event-message

 .Parameter EventLogName
  the name of the eventlog

 .Parameter EventSource
  the source of the event

 .Parameter EventID
  the id of the event

 .Parameter Message
  the message of the event

 .Example
   Write-InformationEvent -EventID 10 -Message "initializing portals - continue testing..."
   
#>
function Write-InformationEvent {
	param(
		[string]$EventLogName = "Windows PowerShell",
		[string]$EventSource = "Powershell",
		[Parameter(Mandatory=$true)]
		[int]$EventID,
		[Parameter(Mandatory=$true)]
		[string]$Message
	)
	Initialize-EventLogSource -EventLogName $EventLogName -EventSource $EventSource
	Write-EventLog -EntryType "Information" -EventID $EventID -LogName $EventLogName -Message (
		$Message + "`n`n" + "Skriptname:`t`t" + $MyInvocation.ScriptName + "`nZeile:`t`t`t" + $MyInvocation.ScriptLineNumber + "`nOrigin:`t`t`t" + $MyInvocation.CommandOrigin
	) -Source $EventSource
}
export-modulemember -function Write-InformationEvent
