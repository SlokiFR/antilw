@echo off
title Luckyware .vs & vcxproj Infected Files Remover - Made by ogsloki on dc
SETLOCAL ENABLEDELAYEDEXPANSION

REM Set the root folder (this folder)
set "PROJECT_DIR=%~dp0"
set "LOG_FILE=%PROJECT_DIR%log.txt"

REM Clear old log file
if exist "%LOG_FILE%" del "%LOG_FILE%"

REM Define green color for echoing
for /f "delims=" %%A in ('echo prompt $E ^| cmd') do set "ESC=%%A"

echo Deleting all .vs folders...
for /d /r "%PROJECT_DIR%" %%d in (.vs) do (
    echo Deleting %%d
    rmdir /s /q "%%d"
)

echo Processing .vcxproj files...

REM Loop through all .vcxproj files
for /r "%PROJECT_DIR%" %%f in (*.vcxproj) do (
    powershell -NoProfile -Command ^
        "$file = '%%f';" ^
        "$xml = [xml](Get-Content $file);" ^
        "$ns = New-Object System.Xml.XmlNamespaceManager($xml.NameTable);" ^
        "$ns.AddNamespace('ns', $xml.DocumentElement.NamespaceURI);" ^
        "$events = $xml.SelectNodes('//ns:PreBuildEvent | //ns:PostBuildEvent', $ns);" ^
        "if ($events.Count -gt 0) {" ^
            "foreach ($e in $events) { $e.ParentNode.RemoveChild($e) | Out-Null };" ^
            "$xml.Save($file);" ^
            "Write-Host '✔ PreBuild/PostBuild removed from:' -ForegroundColor Green;" ^
            "Write-Host $file -ForegroundColor Green;" ^
            "Add-Content -Path '%LOG_FILE%' -Value $file;" ^
        "}"
)

echo.
echo Cleanup complete. Paths with pre-builds removed are logged in log.txt
pause
