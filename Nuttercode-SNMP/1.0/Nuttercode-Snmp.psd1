#
# Modulmanifest f�r das Modul "PSGet_Nuttercode-Snmp"
#
# Generiert von: Johannes.Latzel
#
# Generiert am: 18.03.2022
#

@{

    # Die diesem Manifest zugeordnete Skript- oder Bin�rmoduldatei.
    RootModule         = 'Nuttercode-Snmp.psm1'

    # Die Versionsnummer dieses Moduls
    ModuleVersion      = '1.0'

    # Unterst�tzte PSEditions
    # CompatiblePSEditions = @()

    # ID zur eindeutigen Kennzeichnung dieses Moduls
    GUID               = '9fc8ebbf-678d-497e-8722-0dad53066cd5'

    # Autor dieses Moduls
    Author             = 'Johannes.Latzel'

    # Unternehmen oder Hersteller dieses Moduls
    CompanyName        = 'Unbekannt'

    # Urheberrechtserkl�rung f�r dieses Modul
    Copyright          = '(c) 2022 Johannes.Latzel. Alle Rechte vorbehalten.'

    # Beschreibung der von diesem Modul bereitgestellten Funktionen
    Description        = 'Provides functions to query Snmp agents by wrapping functions from #Snmp.'

    # Die f�r dieses Modul mindestens erforderliche Version des Windows PowerShell-Moduls
    PowerShellVersion  = '5.0'

    # Der Name des f�r dieses Modul erforderlichen Windows PowerShell-Hosts
    # PowerShellHostName = ''

    # Die f�r dieses Modul mindestens erforderliche Version des Windows PowerShell-Hosts
    # PowerShellHostVersion = ''

    # Die f�r dieses Modul mindestens erforderliche Microsoft .NET Framework-Version. Diese erforderliche Komponente ist nur f�r die PowerShell Desktop-Edition g�ltig.
    # DotNetFrameworkVersion = ''

    # Die f�r dieses Modul mindestens erforderliche Version der CLR (Common Language Runtime). Diese erforderliche Komponente ist nur f�r die PowerShell Desktop-Edition g�ltig.
    # CLRVersion = ''

    # Die f�r dieses Modul erforderliche Prozessorarchitektur ("Keine", "X86", "Amd64").
    # ProcessorArchitecture = ''

    # Die Module, die vor dem Importieren dieses Moduls in die globale Umgebung geladen werden m�ssen
    # RequiredModules = @()

    # Die Assemblys, die vor dem Importieren dieses Moduls geladen werden m�ssen
    RequiredAssemblies = 'SharpSnmpLib.dll'

    # Die Skriptdateien (PS1-Dateien), die vor dem Importieren dieses Moduls in der Umgebung des Aufrufers ausgef�hrt werden.
    # ScriptsToProcess = @()

    # Die Typdateien (.ps1xml), die beim Importieren dieses Moduls geladen werden sollen
    # TypesToProcess = @()

    # Die Formatdateien (.ps1xml), die beim Importieren dieses Moduls geladen werden sollen
    # FormatsToProcess = @()

    # Die Module, die als geschachtelte Module des in "RootModule/ModuleToProcess" angegebenen Moduls importiert werden sollen.
    # NestedModules = @()

    # Aus diesem Modul zu exportierende Funktionen. Um optimale Leistung zu erzielen, verwenden Sie keine Platzhalter und l�schen den Eintrag nicht. Verwenden Sie ein leeres Array, wenn keine zu exportierenden Funktionen vorhanden sind.
    FunctionsToExport  = 'New-SnmpTarget', 'Invoke-SnmpGet', 'Invoke-SnmpGetValue', 'Invoke-SnmpWalk', 'Invoke-SnmpWalkValue', 
    'ConvertFrom-SnmpDateAndTime'

    # Aus diesem Modul zu exportierende Cmdlets. Um optimale Leistung zu erzielen, verwenden Sie keine Platzhalter und l�schen den Eintrag nicht. Verwenden Sie ein leeres Array, wenn keine zu exportierenden Cmdlets vorhanden sind.
    CmdletsToExport    = @()

    # Die aus diesem Modul zu exportierenden Variablen
    # VariablesToExport = @()

    # Aus diesem Modul zu exportierende Aliase. Um optimale Leistung zu erzielen, verwenden Sie keine Platzhalter und l�schen den Eintrag nicht. Verwenden Sie ein leeres Array, wenn keine zu exportierenden Aliase vorhanden sind.
    AliasesToExport    = @()

    # Aus diesem Modul zu exportierende DSC-Ressourcen
    # DscResourcesToExport = @()

    # Liste aller Module in diesem Modulpaket
    # ModuleList = @()

    # Liste aller Dateien in diesem Modulpaket
    # FileList = @()

    # Die privaten Daten, die an das in "RootModule/ModuleToProcess" angegebene Modul �bergeben werden sollen. Diese k�nnen auch eine PSData-Hashtabelle mit zus�tzlichen von PowerShell verwendeten Modulmetadaten enthalten.
    PrivateData        = @{

        PSData = @{

            # Tags applied to this module. These help with module discovery in online galleries.
            Tags       = 'snmp, get, walk, sharpsnmp'

            # A URL to the license for this module.
            LicenseUri = 'https://github.com/johanneslatzel/powershellmodules/blob/master/LICENSE'

            # A URL to the main website for this project.
            ProjectUri = 'https://github.com/johanneslatzel/powershellmodules'

            # A URL to an icon representing this module.
            # IconUri = ''

            # ReleaseNotes of this module
            # ReleaseNotes = ''

            # External dependent modules of this module
            # ExternalModuleDependencies = ''

        } # End of PSData hashtable
    
    } # End of PrivateData hashtable

    # HelpInfo-URI dieses Moduls
    # HelpInfoURI = ''

    # Standardpr�fix f�r Befehle, die aus diesem Modul exportiert werden. Das Standardpr�fix kann mit "Import-Module -Prefix" �berschrieben werden.
    # DefaultCommandPrefix = ''

}

