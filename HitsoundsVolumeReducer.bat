@echo off
setlocal enabledelayedexpansion

rem Chck if ffmpeg is installed
ffmpeg -version >nul 2>&1
if ERRORLEVEL 1 (
    echo Could not find FFMPEG
    pause
    goto :EOF
)


set base_folder_name=original_hitsounds
set folder_name=%base_folder_name%

rem Create original_hitsounds folder
if not exist "%folder_name%" (
    mkdir "%folder_name%"
    echo Successfully created "%folder_name%"
) else (
    echo '%folder_name%' folder already exists
    set /a postfix=1
    :loop
    rem Provide up to a 100 folders
    if !postfix!==100 (
        echo Reached iteration limit. Using alternative name.
        set folder_name=original_hitsounds_alternative
        goto loop_exit
    )
    set "folder_name=%base_folder_name%_!postfix!"
    if exist "!folder_name!" (
        echo '!folder_name!' folder already exists
        set /a postfix+=1
        goto loop
    ) else (
        :loop_exit
        mkdir "!folder_name!"
        echo Successfully created '!folder_name!'
    )
)

rem Move files to hitsounds folder
for %%P in (normal soft drum) do (
    for %%F in (%%P*.wav %%P*.ogg %%P*.mp3) do (
        if exist "%%F" move %%F %folder_name%
    )
)

rem Create modified files
for %%F in ("%folder_name%\*") do (
    ffmpeg -i "%%F" -filter:a "volume=-3.5dB" "%%~nF%%~xF"
    if ERRORLEVEL 1 (
        echo ffmpeg failed for file %%~nF, copying file
        robocopy %%~dpF %cd% %%~F
    )
)

pause