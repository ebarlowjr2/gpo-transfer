#########################################################################

# Enable/disable output in screen/file
$LOG_SCREEN=$True
$LOG_FILE=$False

# logs.txt file is generated in the same path as the script.
$LOG_FILE_PATH="$PSScriptRoot\logs.txt"

#########################################################################

Function Log ($MSG) 
{
    $DATE=Get-Date -Format "yyyy-MM-dd hh:mm"
    
    If ($LOG_SCREEN) {    
        Write-Host "$DATE - $MSG"
    }

    If ($LOG_FILE) {    
        "$DATE - $MSG" | Out-File -Append $LOG_FILE_PATH
    }
}

$DATETIMESTAMP = Get-Date -Format "yyyyMMdd-HHmmss"
$DIRNAME="C:\GPOUpdate-$DATETIMESTAMP"

Log "Creating folder $DIRNAME ..."
try { New-Item $DIRNAME -ItemType Directory -ErrorAction Stop | Out-Null }
Catch { 
    Log "Could not create folder $DIRNAME ($_)" 
    Exit
}

Log "Copying contents of $env:windir\System32\GroupPolicy ..."
try { Copy-Item -Recurse "$env:windir\System32\GroupPolicy\*" $DIRNAME -ErrorAction Stop | Out-Null }
Catch { 
    Log "Could not copy contents of %windir%\System32\GroupPolicy ($_)" 
    Exit
}



$SECEDIT_ARGUMENTS = "/export /cfg $DIRNAME\Security.csv"
Log "Running secedit $SECEDIT_ARGUMENTS..."
try {
    Start-Process "secedit.exe" -ArgumentList $SECEDIT_ARGUMENTS -Wait -NoNewWindow 
}
catch {
    Log "Error running secedit ($_)"
    Exit
}


$AUDITPOL_ARGUMENTS = "/backup /file:$DIRNAME\Audit.ini"
Log "Running auditpol $AUDITPOL_ARGUMENTS..."

try {
    Start-Process "auditpol" -ArgumentList $AUDITPOL_ARGUMENTS -Wait -NoNewWindow 
}
catch {
    Log "Error running auditpol ($_)"
    Exit
}

Log "Compressing folder to generate ${DIRNAME}.zip"

try {
    Compress-Archive -Path "$DIRNAME\*" -DestinationPath "${DIRNAME}.zip" 
}
catch {
    Log "Error compressing $DIRNAME ($_)"
}


