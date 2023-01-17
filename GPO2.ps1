#########################################################################

# Enable/disable output in screen/file
$LOG_SCREEN=$True
$LOG_FILE=$False

# logs.txt file is generated in the same path as the script.
$LOG_FILE_PATH="$PSScriptRoot\logs.txt"

# Zip file with GPO folder contents
$GPO_ZIP_FILE="C:\GPOUpdate-20230116-222246.zip"

#########################################################################

Log "Decompressing ZIP file ($GPO_ZIP_FILE) into $env:windir\System32\GroupPolicy"
try {
    Expand-Archive -Path "$GPO_ZIP_FILE" -DestinationPath "$env:windir\System32\GroupPolicy"
}
catch {
    Log "Error decompressing $GPO_ZIP_FILE ($_)"
    Exit
}


$SECEDIT_ARGUMENTS = "/configure /cfg Security.csv /db defltbase.sdb /verbose"
Log "Running secedit $SECEDIT_ARGUMENTS..."
try {
    Start-Process "secedit.exe" -ArgumentList $SECEDIT_ARGUMENTS -Wait -NoNewWindow 
}
catch {
    Log "Error running secedit ($_)"
    Exit
}


$AUDITPOL_ARGUMENTS = "/restore /file:C:\audit.ini"
Log "Running auditpol $AUDITPOL_ARGUMENTS..."
try {
    Start-Process "auditpol" -ArgumentList $AUDITPOL_ARGUMENTS -Wait -NoNewWindow 
}
catch {
    Log "Error running auditpol ($_)"
    Exit
}
