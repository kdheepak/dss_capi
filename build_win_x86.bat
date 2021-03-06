@echo off

where /q fpc
if errorlevel 1 (
    if exist c:\lazarus\fpc\3.0.4\bin\i386-win32\fpc.exe (
        set "PATH=%PATH%;c:\lazarus\fpc\3.0.4\bin\i386-win32"
    ) else (
        echo ERROR: Please put fpc.exe in your executable search path and try again.
        exit /B
    )
)

if not exist .\build\units_v7_x86 (
    mkdir .\build\units_v7_x86
) 

if not exist .\build\units_v8_x86 (
    mkdir .\build\units_v8_x86
) 

if exist ..\electricdss-src\Source\Common\DSSGlobals.pas (
    fpc -Pi386 @src\v7\windows-x86.cfg -B src\v7\dss_capi_v7.lpr
    if exist lib\win_x86\v7\dss_capi_v7.dll (
        where /q dumpbin
        if errorlevel 1 (
            echo WARNING: dumpbin.exe is not in your path. Be sure to run this script on 
            echo          the "x86 Native Tools Command Prompt for VS 2017" or the 
            echo          equivalent for your Visual Studio version.
            exit /B
        )
        dumpbin /exports "lib\win_x86\v7\dss_capi_v7.dll" > lib\win_x86\v7\exports.txt
        echo LIBRARY DSS_CAPI_V7 > lib\win_x86\v7\dss_capi_v7.def
        echo EXPORTS >> lib\win_x86\v7\dss_capi_v7.def
        for /f "skip=19 tokens=4" %%A in (lib\win_x86\v7\exports.txt) do echo %%A >> lib\win_x86\v7\dss_capi_v7.def
        lib /def:lib\win_x86\v7\dss_capi_v7.def /out:lib\win_x86\v7\dss_capi_v7.lib /machine:X86
        del /s lib\win_x86\v7\dss_capi_v7.exp
        del /s lib\win_x86\v7\dss_capi_v7.def
        del /s lib\win_x86\v7\exports.txt

        REM copy /Y ..\electricdss-src\Distrib\x86\klusolve.dll lib\libklusolve.dll
        echo TODO: COPY KLUSOLVE DLL!
    ) else (
        echo ERROR: DSS_CAPI_V7.DLL file not found. Check previous messages for possible causes.
        exit /B
    )

    fpc -Pi386 @src\v8\windows-x86.cfg -B src\v8\dss_capi_v8.lpr
    if exist lib\win_x86\v8\dss_capi_v8.dll (
        where /q dumpbin
        if errorlevel 1 (
            echo WARNING: dumpbin.exe is not in your path. Be sure to run this script on 
            echo          the "x86 Native Tools Command Prompt for VS 2017" or the 
            echo          equivalent for your Visual Studio version.
            exit /B
        )
        dumpbin /exports "lib\win_x86\v8\dss_capi_v8.dll" > lib\win_x86\v8\exports.txt
        echo LIBRARY DSS_CAPI_V8 > lib\win_x86\v8\dss_capi_v8.def
        echo EXPORTS >> lib\win_x86\v8\dss_capi_v8.def
        for /f "skip=19 tokens=4" %%A in (lib\win_x86\v8\exports.txt) do echo %%A >> lib\win_x86\v8\dss_capi_v8.def
        lib /def:lib\win_x86\v8\dss_capi_v8.def /out:lib\win_x86\v8\dss_capi_v8.lib /machine:X86
        del /s lib\win_x86\v8\dss_capi_v8.exp
        del /s lib\win_x86\v8\dss_capi_v8.def
        del /s lib\win_x86\v8\exports.txt
        
        REM copy /Y ..\electricdss-src\Distrib\x86\klusolve.dll lib\libklusolve.dll
        echo TODO: COPY KLUSOLVE DLL!
    ) else (
        echo ERROR: DSS_CAPI_V8.DLL file not found. Check previous messages for possible causes.
    )
    
) else (
    echo ERROR: Did you forget to clone https://github.com/PMeira/electricdss-src ?
    exit /B
)
