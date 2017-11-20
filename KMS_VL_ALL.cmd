@echo off
:: Set Title of the Script
set "title=KMS_VL_ALL"
title %title%
::===================
:: Color [Background][Text] in hex (0 to F)
color 0A
::===================
:: Get Fully Qualified FileName of the Script
set "_FilePath=%~f0"
:: Get Drive and Path containing the Script
set "_FileDir=%~dp0"
::===================
:: Enable Extensions and DelayedExpansion of variables
setlocal EnableExtensions EnableDelayedExpansion
::===================
:: Set LogFileName of the Script. Recommend using Fully Qualified FileName.
set "LogFile=!_FileDir!KMS_VL_ALL.log"
echo Log Start at %date% %time%>%LogFile% 2>nul
REM If LogFile does not work, then LogFile is redirected to nul.
find ":" %LogFile% >nul 2>&1
if '%ERRORLEVEL%' NEQ '0' set "LogFile=nul"
echo %title% >>%LogFile% 2>nul
::===================
:: Set Display Support Products List
:: Can be 1 (True) | 0 (False)
set "_ShowList=1"
::============================================================================================================================================================
:: Set Parameters for Task
::===================
:: Can be 0 (Delete Auto-Renewal-Task OR Manual-Mode) | 1 (Create Auto-Renewal-Task)
set /a _Task=1
::------------------------------------------------------------------------------------------------------------------------------------------------------------
REM Change '_Task' value to 1 to enable the following parameters.
:: Can be ONSTART | ONLOGON | MINUTE(1 - 1439) | HOURLY(1 - 23) | DAILY(1 - 365) | WEEKLY(1 - 52) | MONTHLY(1 - 12)
set _TaskFrequency=MONTHLY
:: Can be numbers in the range shown above
set /a _Modifier=3
:: Set TaskLogFileName of the Script. It is fail to set TaskLogFile equal to LogFile, but not 'nul'. Recommend using Fully Qualified FileName.
set "TaskLogFile=!_FileDir!TaskLogFile.log"
:: Set Task Command Line for the Script
set "_TaskCmd=cmd /c !_FilePath! >!TaskLogFile! 2>&1"
:: Set Task Name for the Script
set "_TaskName=KMS_VL_ALL"
::============================================================================================================================================================
:: Can be 0 (Online Mode - Used for External KMS Server) | 1 (Offline Mode - Used for Internal KMS Server)
set /a _OfflineMode=1
::------------------------------------------------------------------------------------------------------------------------------------------------------------
REM Change '_OfflineMode' value to 0 to enable the following parameters.
:: Set Parameters for KMS Client
::===================
:: _KMSHost Can be (0-255.0-255.0-255.0-255), but NOT 127.x.x.x/Localhost IPs [Offline Mode] | KMS ServerName/IP [Online Mode]
set "_KMSHost=172.16.0.4"
set "_KMSLocalHost=127.0.0.2"
::===================
:: Can be (1 to 65535) [Offline Mode]; 1688 [Online Mode]
set /a _KMSPort=1686
::------------------------------------------------------------------------------------------------------------------------------------------------------------
REM Change '_OfflineMode' value to 1 to enable the following parameters.
:: Set Parameters for KMS Server
::===================
:: Can be (15 to 43200) minutes; Default - 2 hours, Maximum - 30 days
set /a _KMSActivationInterval=120
:: Can be (15 to 43200) minutes; Default - 7 days, Maximum - 30 days
set /a _KMSRenewalInterval=10080
:: Can be Custom HardwareID obtained from a Real KMS Server Host
set "_HardwareID=3A1C049600B60076"
::===================
:: Can be 0 (Custom ePIDs) | 1 (Randomized ePIDs for every Session) | 2 (Randomized ePIDs for every Request)
set /a _RandomLevel=1
::===================
REM Change '_RandomLevel' value to 0 to enable the following parameters.
:: Custom Windows ePID
set "_WindowsEPID=03612-00206-471-452343-03-1033-14393.0000-1082017"
:: Custom Windows 10 Enterprise G/GN ePID
set "_WindowsGEPID=03612-00206-471-452343-03-1033-14393.0000-1082017"
:: Custom Office 2010 ePID
set "_Office2010EPID=03612-00096-199-303490-03-1033-14393.0000-1082017"
:: Custom Office 2013 ePID
set "_Office2013EPID=03612-00206-234-394838-03-1033-14393.0000-1082017"
:: Custom Office 2016 ePID
set "_Office2016EPID=03612-00206-437-938923-03-1033-14393.0000-1082017"
::============================================================================================================================================================
:: Set Registry Key for DLL Hook
set "_regKey=HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options"
::============================================================================================================================================================
:: Set Registry Keys for SPP and OSPP
set "_hkSPP=HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\SoftwareProtectionPlatform"
set "_huSPP=HKEY_USERS\S-1-5-20\Software\Microsoft\Windows NT\CurrentVersion\SoftwareProtectionPlatform"
set "_hkOSPP=HKLM\SOFTWARE\Microsoft\OfficeSoftwareProtectionPlatform"
::============================================================================================================================================================
:: Set KMS Genuine Ticket Validation Parameters
::===================
:: Can be 0 (Enable Genuine Ticket) | 1 (Disable Genuine Ticket)
set /a _KMSNoGenTicket=1
::===================
:: Registry Key for KMS Genuine Ticket
set "_KMSGenuineKey=HKLM\SOFTWARE\Policies\Microsoft\Windows NT\CurrentVersion\Software Protection Platform"
::============================================================================================================================================================
:: Get Administrator Rights
fltmc >>nul 2>&1 || (
    echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\GetAdmin.vbs"
    echo UAC.ShellExecute "!_FilePath!", "", "", "runas", 1 >> "%temp%\GetAdmin.vbs"
    cmd /u /c type "%temp%\GetAdmin.vbs" > "%temp%\GetAdminUnicode.vbs"
    cscript //nologo "%temp%\GetAdminUnicode.vbs"
    del /f /q "%temp%\GetAdmin.vbs" >>%LogFile% 2>&1
    del /f /q "%temp%\GetAdminUnicode.vbs" >>%LogFile% 2>&1
    exit
)
goto :Main
::============================================================================================================================================================
:: Main Function
:Main
chcp 437 >>%LogFile% 2>&1
if %_ShowList% EQU 1 call :ListSupport
::===================
echo.
echo Activation Procces will be run in 5 seconds... 
ping 127.0.0.1 -n 6 >>nul 2>&1
echo.
echo Activation Procces is running...Please wait...
echo.
::===================
REM Go to the Path of the Script
pushd "!_FileDir!"
::===================
REM Get Information of Windows
call :GetWindowsInfomation
::===================
REM Visual Studio Activation
call :ActiavateVisualStudioMain
::===================
REM Get Information of Office 
call :CheckOfficeInstalledMain
::===================
REM Goto Main blocks according to Windows BuildNumber
if %_WinBuild% GEQ 9600 (
    echo OS: Windows 8.1 or Later,Build %_WinBuild%^(%_EditionID%^) %_OSarch% >>%LogFile% 2>&1
    goto :Win8.1AndLaterMain
) else if %_WinBuild% GEQ 2600 (
    echo OS: Windows 8 or Earlier,Build %_WinBuild%^(%_EditionID%^) %_OSarch% >>%LogFile% 2>&1
    goto :Win8AndEarlierMain
) else (
    echo OS: Windows version is too low,Build %_WinBuild%^(%_EditionID%^) %_OSarch% >>%LogFile% 2>&1
    echo KMS_VL_ALL does not support this OS.
    goto :Close
)
::============================================================================================================================================================
:Win8.1AndLaterMain
::===================
REM Offline Mode(Start KMS Server)
if %_OfflineMode% EQU 1 (
    REM Stop service 'sppsvc' and 'osppsvc'
    echo Stop service 'sppsvc' and 'osppsvc' >>%LogFile% 2>&1
    call :StopService "sppsvc"
    if %_OSPS% NEQ 0 (
        call :StopService "osppsvc"
    )
    REM Copy the DLL Injection files to system32 folder based on OS architecture
    echo Copy DLL >>%LogFile% 2>&1
    xcopy "%_OSarch%\SppExtComObjPatcher.exe" "%SystemRoot%\system32\" /y /q >>%LogFile% 2>&1
    xcopy "%_OSarch%\SppExtComObjHook.dll" "%SystemRoot%\system32\" /y /q >>%LogFile% 2>&1

    REM Create registry keys for DLL Hook
    echo Create DLL Hook registry keys for DLL Hook >>%LogFile% 2>&1
    call :CreateIFEOEntry "SppExtComObj.exe"
    if %_OSPS% NEQ 0 (
        call :CreateIFEOEntry "osppsvc.exe"
    )

    REM Add Firewall Exceptions for VLMCSD
    echo Add Firewall Exceptions for VLMCSD >>%LogFile% 2>&1
    call :AddFirewallRule

    REM Start KMS Server
    echo Start KMS Server >>%LogFile% 2>&1
    call :StartKMS
)
::===================
REM 呼叫 Enable/Disable KMS Genuine Ticket Validation
REM Enable/Disable KMS Genuine Ticket Validation for Windows 8.1 and above
if %_WinBuild% GEQ 9600 (
    call :KMSGenuineTicket
)
::===================
REM Call Windows and Office Activation Main Functions
if %_OSPS% NEQ 0 (
    call :OSPSActivation
)
call :SLSActivation
::===================
REM Offline Mode(Erase traces)
if %_OfflineMode% EQU 1 (
    REM Stop KMS Server
    echo Stop KMS Server >>%LogFile% 2>&1
    call :StopKMS

    REM Remove Firewall Exceptions for VLMCSD
    echo Remove Firewall Exceptions for VLMCSD >>%LogFile% 2>&1
    call :RemoveFirewallRule

    REM Stop service 'sppsvc' and 'osppsvc'
    echo Stop service 'sppsvc' 和 'osppsvc' >>%LogFile% 2>&1
    call :StopService "sppsvc"
    if %_OSPS% NEQ 0 (
        call :StopService "osppsvc"
    )

    REM Delete the DLL Injection files from system32 folder
    echo Delete DLL >>%LogFile% 2>&1
    del /f /q "%SystemRoot%\system32\SppExtComObjPatcher.exe" >>%LogFile% 2>&1
    del /f /q "%SystemRoot%\system32\SppExtComObjHook.dll" >>%LogFile% 2>&1

    REM Remove registry keys for DLL Hook
    echo Remove registry keys for DLL Hook >>%LogFile% 2>&1
    call :RemoveIFEOEntry "SppExtComObj.exe"
    if %_OSPS% NEQ 0 (
        call :RemoveIFEOEntry "osppsvc.exe"
    )
    REM Start service 'sppsvc'
    echo Start service 'sppsvc' >>%LogFile% 2>&1
    sc start sppsvc trigger=timer;sessionid=0 >>%LogFile% 2>&1
)
::===================
REM Create/Delete Auto-Renewal Task
call :SetSchtasks
::===================
goto :Close
::============================================================================================================================================================
:Win8AndEarlierMain
::===================
REM Exit if No Office 2010 product is installed on Windows XP SP3/Server 2003 R2
if %_OSPS% EQU 0 (
    if %_WinBuild% LSS 6000 (
        echo.
        echo OS is Windows XP SP3/Server 2003 R2, and No Office 2010 Product Detected...
        goto :Close
    )
)
::===================
REM Offline Mode(Start KMS Server)
if %_OfflineMode% EQU 1 (
    REM Localhost IP can be used for Windows 8 and Below
    set "_KMSHost=%_KMSLocalHost%"

    REM Add Firewall Exceptions for VLMCSD
    echo Add Firewall Exceptions for VLMCSD >>%LogFile% 2>&1
    call :AddFirewallRule

    REM Start KMS Server
    echo Start KMS Server >>%LogFile% 2>&1
    call :StartKMS
)
::===================
REM Call Windows and Office Activation Main Functions
if %_OSPS% NEQ 0 (
    call :OSPSActivation
)
if %_WinBuild% GEQ 6000 (
    call :SLSActivation
)
::===================
REM Offline Mode(Erase traces)
if %_OfflineMode% EQU 1 (
    REM Stop KMS Server
    echo Stop KMS Server >>%LogFile% 2>&1
    call :StopKMS

    REM Remove Firewall Exceptions for VLMCSD
    echo Remove Firewall Exceptions for VLMCSD >>%LogFile% 2>&1
    call :RemoveFirewallRule
)
::===================
REM Create/Delete Auto-Renewal Task
call :SetSchtasks
::===================
goto :Close
::============================================================================================================================================================
:Close
echo.
echo Closing in 5 Seconds...
ping 127.0.0.1 -n 6 >>nul 2>&1
echo Log  End  %date% %time%>>%LogFile% 2>&1
exit
::============================================================================================================================================================
:: Create/Delete Auto-Renewal Task based on parameter; Windows XP SP3 or Later Compatible
:SetSchtasks
if %_Task% EQU 1 (
    schtasks /query /fo list 2>nul | findstr /i "%_TaskName%" >>%LogFile% 2>&1 && (
        schtasks /delete /tn "%_TaskName%" /f >>%LogFile% 2>&1
    )
    if /i %_TaskFrequency% EQU ONSTART (
        schtasks /create /tn "%_TaskName%" /ru "SYSTEM" /sc "%_TaskFrequency%" /tr "%_TaskCmd%" >>%LogFile% 2>&1 && (
            echo.
            echo Auto-Renewal Task is Created.
        )
    ) else if /i %_TaskFrequency% EQU ONLOGON (
        schtasks /create /tn "%_TaskName%" /ru "SYSTEM" /sc "%_TaskFrequency%" /tr "%_TaskCmd%" >>%LogFile% 2>&1 && (
            echo.
            echo Auto-Renewal Task is Created.
        )
    ) else (
        schtasks /create /tn "%_TaskName%" /ru "SYSTEM" /sc "%_TaskFrequency%" /mo "%_Modifier%" /tr "%_TaskCmd%" >>%LogFile% 2>&1 && (
            echo.
            echo Auto-Renewal Task is Created.
        )
    )
) else (
    schtasks /query /fo list 2>nul | findstr /i "%_TaskName%" >>%LogFile% 2>&1 && (
        schtasks /delete /tn "%_TaskName%" /f >>%LogFile% 2>&1 && (
            echo.
            echo Auto-Renewal Task is Deleted.
        )
    )
)
exit /b
::============================================================================================================================================================
:ListSupport
echo Supported Microsoft Products:
echo (32-bit and 64-bit)
echo Windows Vista/7/8/8.1/10 (build 1709) All VL Editions
echo Windows Server 2008/2008R2/2012/2012R2/2016 (build 1607) All Editions
echo Office 2010 Family on Windows XP SP3 or later
echo Office Family on Windows 7 or later
echo Office Family on Windows 7 SP1 or later
echo Visual Studio 2012 (v11) Ultimate/Premium/Professional
echo Visual Studio 2013 (v12) Ultimate/Premium/Professional
echo Visual Studio 2015 (v14) Enterprise/Professional
echo Visual Studio 2017 (v15) Enterprise/Professional
echo.
echo Retail/OEM/MAK Genuine Activations are UNAFFECTED.
echo Converts Notice Period/OOBE-Grace period windows to VL IF they are supported and are then activated.
echo.
echo Supported Retail/MAK Unactivated Editions:
echo Win Vista(Business/Enterprise) 7/8/8.1/10 Pro Retail/MAK and their Enterprise editions
echo Server 2008/2008 R2/2012/2012R2/2016 Retail, MAK editions
echo Office 2010/2013/2016 MAK editions
echo Office 2016 C2R edition
echo.
exit /b
::============================================================================================================================================================
:GetWindowsInfomation
echo Getting Windows Infomation...
echo.
::===================
REM Get Windows OS build number
for /f "tokens=2 delims==" %%G in ('wmic path Win32_OperatingSystem get BuildNumber /value') do set /a _WinBuild=%%G
set _WinBuild>>%LogFile% 2>&1
::===================
REM Get Windows License Status for Vista or above AND Installed Windows Edition
if %_WinBuild% GEQ 6000 (
    if %_WinBuild% GEQ 9200 (
        for /f "tokens=3 delims=: " %%G in ('dism /Online /Get-CurrentEdition /English ^| findstr /i "Current Edition :"') do set "_EditionID=%%G"
    ) else (
        for /f "tokens=2 delims== " %%G in ('"wmic path SoftwareLicensingProduct where (PartialProductKey is not NULL) get LicenseStatus /value" 2^>nul') do set /a _LicenseStatus=%%G
        for /f "tokens=3 delims= " %%G in ('"wmic path SoftwareLicensingProduct where LicenseStatus='%_LicenseStatus%' get Name" 2^>nul') do set "_EditionID=%%G"
    )
    set _EditionID>>%LogFile% 2>&1
    set _LicenseStatus>>%LogFile% 2>&1
)
::===================
REM Get Architecture of the OS installed; OS Locale/Language Independent from Windows XP / Server 2003 and Later
for /f "tokens=2 delims==" %%G in ('wmic path Win32_Processor get AddressWidth /value') do set "_OSarch=%%G-bit"
set _OSarch>>%LogFile% 2>&1
::===================
REM Check if GVLK is installed for Windows
wmic path SoftwareLicensingProduct where (Description like '%%KMSCLIENT%%' and PartialProductKey is not NULL) get Name /value 2>nul | findstr /i "Windows" >>%LogFile% 2>&1 && (
    set /a _WindowsGVLK=1
) || (
    set /a _WindowsGVLK=0
)
set _WindowsGVLK>>%LogFile% 2>&1
::===================
exit /b
::============================================================================================================================================================
:CheckOfficeInstalledMain
echo ===================Check Office Install Status Start=================== >>%LogFile% 2>&1
echo Detecting Office installed information...
echo.
::===================
REM Check if [Office 2010 on Windows XP SP3 or Later] OR [Office 2013 or Later on Windows 7 / Server 2008 R2] is Installed
wmic path OfficeSoftwareProtectionService get Version /value >>%LogFile% 2>&1 && (
    set /a _OSPS=1
) || (
    set /a _OSPS=0
)
echo.>>%LogFile% 2>&1
set _OSPS>>%LogFile% 2>&1
::===================
REM Check if 2010(14)/2013(15)/Office 2016(16) products are ACTUALLY installed
call :CheckOfficeInstalled 14 2010
call :CheckOfficeInstalled 15 2013
call :CheckOfficeInstalled 16 2016
::===================
echo ===================Check Office Install Status  End =================== >>%LogFile% 2>&1
exit /b
::============================================================================================================================================================
:: Check Office is Installed based on parameter(14/15/16, 2010/2013/2016)
:CheckOfficeInstalled
echo Check Office %2 is Installed...
::===================
set /a _Office%1=0
set /a _msi=0
set /a _msiwow=0
set /a _ctr=0
for /f "tokens=2*" %%G in ('"reg query HKLM\SOFTWARE\Microsoft\Office\%1.0\Common\InstallRoot /v Path 2>>%LogFile%"') do set "_msi=%%H"
for /f "tokens=2*" %%G in ('"reg query HKLM\SOFTWARE\Wow6432Node\Microsoft\Office\%1.0\Common\InstallRoot /v Path 2>>%LogFile%"') do set "_msiwow=%%H"
for /f "tokens=2*" %%G in ('"reg query HKLM\SOFTWARE\Microsoft\Office\ClickToRun /v InstallPath 2>>%LogFile%"') do set "_ctr=%%H\Office%1"
if exist "%_msi%\OSPP.VBS" (
    set /a _Office%1=1
) else if exist "%_msiwow%\OSPP.VBS" (
    set /a _Office%1=1
) else if exist "%_ctr%\OSPP.VBS" (
    set /a _Office%1=1
) else if exist "C:\Program Files\Microsoft Office\Office%1\OSPP.VBS" (
    set /a _Office%1=1
) else if exist "C:\Program Files (x86)\Microsoft Office\Office%1\OSPP.VBS" (
    set /a _Office%1=1
)
set _Office%1>>%LogFile% 2>&1
::===================
if !_Office%1! EQU 1 (
    echo     Result:Yes.
) else (
    echo     Result:No.
)
echo.
::===================
exit /b
::============================================================================================================================================================
:ActiavateVisualStudioMain
echo ===================Check Visual Studio Install Status Start=================== >>%LogFile% 2>&1
echo Detecting Visual Studio installed information And trying to activate...
echo.
::===================
REM Check if Visual Studio 2012(11)/2013(12)/2015(14)/2017(15) products are ACTUALLY installed
call :ActiavateVisualStudio 11 2012
call :ActiavateVisualStudio 12 2013
call :ActiavateVisualStudio 14 2015
call :ActiavateVisualStudio 15 2017
echo.
echo ===================Check Visual Studio Install Status  End =================== >>%LogFile% 2>&1
exit /b
::============================================================================================================================================================
:: Activate if Visual Studio is Installed based on parameter(11/12/14/15, 2012/2013/2015/2017)
:ActiavateVisualStudio
echo Check Visual Studio %2 is Installed...
::===================
REM Get Install Path
if "%_OSarch%" EQU "64-bit" (
    set "_H64=SOFTWARE\WOW6432Node"
) else (
    set "_H64=SOFTWARE"
)
for /f "skip=2 tokens=2*" %%G in ('"reg query HKLM\%_H64%\Microsoft\VisualStudio\SxS\VS7 /v %1.0" 2^>nul') do (
    set "_VS%1=%%HCommon7\IDE"
)
set _VS%1>>%LogFile% 2>&1
::===================
REM Activate if StorePID.exe exist.
if exist "!_VS%1!\StorePID.exe" (
    echo     Result:Yes. Activating...
    set VSstatus=
    call :ActivateVisualStudio%2
    set VSstatus>>%LogFile% 2>&1
    if defined VSstatus (
        echo     Result: !VSstatus! Success.
    ) else (
        echo     Result: Failed.
    )
) else (
    echo     Result:No.
)
echo.
::===================
exit /b
::============================================================================================================================================================
:: Visual Studio 2012(v11) Activation
:ActivateVisualStudio2012
"%_VS11%\StorePID.exe" RBCXF-CVBGR-382MK-DFHJ4-C69G8 04940 >>%LogFile% 2>&1 && (
    set VSstatus=Ultimate
) || (
    "%_VS11%\StorePID.exe" MH2FR-BC9R2-84433-47M63-KQVWC 04941 >>%LogFile% 2>&1 && (
        set VSstatus=Premium
    ) || (
        "%_VS11%\StorePID.exe" 4D974-9QX42-9Y43G-YJ7JG-JDYBP 04938 >>%LogFile% 2>&1 && (
            set VSstatus=Professional
        )
    )
)
exit /b
::============================================================================================================================================================
:: Visual Studio 2013(v12) Activation
:ActivateVisualStudio2013
"%_VS12%\StorePID.exe" 87DQC-G8CYR-CRPJ4-QX9K8-RFV2B 06181 >>%LogFile% 2>&1 && (
    set VSstatus=Ultimate
) || (
    "%_VS12%\StorePID.exe" FBJVC-3CMTX-D8DVP-RTQCT-92494 06191 >>%LogFile% 2>&1 && (
        set VSstatus=Premium
    ) || (
        "%_VS12%\StorePID.exe" XDM3T-W3T3V-MGJWK-8BFVD-GVPKY 06177 >>%LogFile% 2>&1 && (
            set VSstatus=Professional
        )
    )
)
exit /b
::============================================================================================================================================================
:: Visual Studio 2015(v14) Activation
:ActivateVisualStudio2015
"%_VS14%\StorePID.exe" HM6NR-QXX7C-DFW2Y-8B82K-WTYJV 07060 >>%LogFile% 2>&1 && (
    set VSstatus=Enterprise
) || (
    "%_VS14%\StorePID.exe" HMGNV-WCYXV-X7G9W-YCX63-B98R2 07062 >>%LogFile% 2>&1 && (
        set VSstatus=Professional
    )
)
exit /b
::============================================================================================================================================================
:: Visual Studio 2017(v15) Activation
:ActivateVisualStudio2017
"%_VS15%\StorePID.exe" NJVYC-BMHX2-G77MM-4XJMR-6Q8QF 08860 >>%LogFile% 2>&1 && (
    set VSstatus=Enterprise
) || (
    "%_VS15%\StorePID.exe" KBJFW-NXHK6-W4WJM-CRMQB-G3CDH 08862 >>%LogFile% 2>&1 && (
        set VSstatus=Professional
    )
)
exit /b
::============================================================================================================================================================
:: Add VLMCSD KMS Exception to Windows Firewall; Windows XP SP3 or Later Compatible
:AddFirewallRule
netsh firewall delete allowedprogram "!_FileDir!32-bit\vlmcsd.exe" >>%LogFile% 2>&1
netsh firewall add allowedprogram "!_FileDir!32-bit\vlmcsd.exe" "vlmcsd" >>%LogFile% 2>&1
exit /b
::============================================================================================================================================================
:: Remove VLMCSD KMS Exception from Windows Firewall
:RemoveFirewallRule
netsh firewall delete allowedprogram "!_FileDir!32-bit\vlmcsd.exe" >>%LogFile% 2>&1
exit /b
::============================================================================================================================================================
:: Start VLMCSD KMS Server
:StartKMS
::===================
if %_RandomLevel% EQU 0 (
    start "" /b "!_FileDir!32-bit\vlmcsd.exe" -P %_KMSPort% -0 %_Office2010EPID% -3 %_Office2013EPID% -6 %_Office2016EPID% -w %_WindowsEPID% -G %_WindowsGEPID% -H %_HardwareID% -R %_KMSRenewalInterval% -A %_KMSActivationInterval% -T0 -e >"%temp%\KMS.log" 2>&1
) else (
    start "" /b "!_FileDir!32-bit\vlmcsd.exe" -r%_RandomLevel% -P %_KMSPort% -H%_HardwareID% -R %_KMSRenewalInterval% -A %_KMSActivationInterval% -T0 -e >"%temp%\KMS.log" 2>&1
)
::===================
REM Mind boggling BUG Fix; Windows Vista or below takes some time to start KMS Server which prevents Activation; So add delay for it to successfully start
if %_WinBuild% LSS 7600 (
    ping 127.0.0.1 -n 12 >>nul 2>&1
)
::===================
exit /b
::============================================================================================================================================================
:: Stop VLMCSD KMS Server
:StopKMS
::===================
taskkill /im "vlmcsd.exe" /t /f >>%LogFile% 2>&1
::===================
REM Merge Log of KMS Server to LogFile
echo ===================vlmcsd KMS.log Start=================== >>%LogFile% 2>&1
type "%temp%\KMS.log" >>%LogFile%
echo ===================vlmcsd KMS.log  End =================== >>%LogFile% 2>&1
del /f /q "%temp%\KMS.log" >>%LogFile% 2>&1
::===================
exit /b
::============================================================================================================================================================
:: Enable/Disable KMS Genuine Ticket Validation for Windows 8.1 and above
:KMSGenuineTicket
reg add "%_KMSGenuineKey%" /v NoGenTicket /t REG_DWORD /d %_KMSNoGenTicket% /f >>%LogFile% 2>&1
exit /b
::============================================================================================================================================================
:: Create DLL Injection Registry keys based on parameter
:CreateIFEOEntry
reg add "%_regKey%\%~1" /f /v "Debugger" /t REG_SZ /d "SppExtComObjPatcher.exe" >>%LogFile% 2>&1
::===================
REM Set KMS_Emulation to 0 since we use external (vlmcsd) KMS Server; 1 for internal KMS Server in Injector files
reg add "%_regKey%\%~1" /f /v "KMS_Emulation" /t REG_DWORD /d 0 >>%LogFile% 2>&1
::===================
exit /b
::============================================================================================================================================================
:: Remove DLL Injection Registry keys based on parameter
:RemoveIFEOEntry
if '%~1' NEQ 'osppsvc.exe' (
    reg delete "%_regKey%\%~1" /f >>%LogFile% 2>&1
)
if '%~1' EQU 'osppsvc.exe' (
    reg delete "%_regKey%\osppsvc.exe" /f /v "Debugger" >>%LogFile% 2>&1
    reg delete "%_regKey%\osppsvc.exe" /f /v "KMS_Emulation" >>%LogFile% 2>&1
)
exit /b
::============================================================================================================================================================
:: Stop service based on parameter
:StopService
sc query "%1" 2>nul | findstr /i "STOPPED" >>%LogFile% 2>&1 || (
    net stop "%1" /y >>%LogFile% 2>&1
)
sc query "%1" 2>nul | findstr /i "STOPPED" >>%LogFile% 2>&1 || (
    sc stop "%1" >>%LogFile% 2>&1
)
exit /b
::============================================================================================================================================================
::Clear Application Data(_hkSPP/_huSPP/_hkOSPP)
:ClearAPPData
echo     ===================Clear APP Data Start=================== >>%LogFile% 2>&1
REM Delete registry key AppID
echo Delete registry key %1\AppID >>%LogFile% 2>&1
REM APPID : Windows
reg delete "%1\55c92734-d682-4d71-983e-d6ec3f16059f" /f >>%LogFile% 2>&1
REM APPID : Office 14 (2010)
reg delete "%1\59a52881-a989-479d-af46-f275c6370663" /f >>%LogFile% 2>&1
REM APPID : Office 15 (2013)
reg delete "%1\0ff1ce15-a989-479d-af46-f275c6370663" /f >>%LogFile% 2>&1
echo     ===================Clear APP Data  End =================== >>%LogFile% 2>&1
exit /b
::============================================================================================================================================================
::SoftwareLicensingService Activation
:SLSActivation
set "_MicrosoftProduct=SoftwareLicensingProduct"
set "_MicrosoftService=SoftwareLicensingService"
::===================
echo ===================%_MicrosoftService% Activation Start=================== >>%LogFile% 2>&1
call :ClearAPPData %_hkSPP%
call :ClearAPPData %_huSPP%
::===================
REM Detect if Office 2013 [Volume Licensed] or Later is Installed
echo Detecting KMS Client Office...>>%LogFile% 2>&1
wmic path %_MicrosoftProduct% where (Description like '%%KMSCLIENT%%') get Name /value 2>nul | findstr /i "Office" >>%LogFile% 2>&1 && (
    set /a _OfficeVL=1
) || (
    set /a _OfficeVL=0
    echo     Result: No...>>%LogFile% 2>&1
    if %_WinBuild% GEQ 9200 (
        echo No Office 2013 or Later VL Product Detected; Retail Versions need to be converted to VL first.
    )
)
set _OfficeVL>>%LogFile% 2>&1
::===================
REM Detect if installed Windows supports KMS Activation; Exit if there are no VolumeLicensed Windows or Office
echo Detecting KMS Client Windows...>>%LogFile% 2>&1
wmic path %_MicrosoftProduct% where (Description like '%%KMSCLIENT%%') get Name /value 2>nul | findstr /i "Windows" >>%LogFile% 2>&1 || (
    echo     Result: No...>>%LogFile% 2>&1
    echo No Supported KMS Client Windows Detected...
    if %_OfficeVL% EQU 0 (
        echo ===================%_MicrosoftService% Activation  End =================== >>%LogFile% 2>&1
        exit /b
    )
)
::===================
REM Call Common Core Activation Routines
call :CommonSLSandOSPS
::===================
call :ClearAPPData %_hkSPP%
call :ClearAPPData %_huSPP%
echo.
echo ===================SoftwareLicensingService Activation  End =================== >>%LogFile% 2>&1
::===================
exit /b
::============================================================================================================================================================
::OfficeSoftwareProtectionService Activation
:OSPSActivation
set "_MicrosoftProduct=OfficeSoftwareProtectionProduct"
set "_MicrosoftService=OfficeSoftwareProtectionService"
::===================
echo ===================%_MicrosoftService% Activation Start=================== >>%LogFile% 2>&1
call :ClearAPPData %_hkOSPP%
::===================
REM Determine if installed Office product is Retail or VL version; Exit if no VolumeLicensed Office is detected
echo Detecting KMS Client Office...>>%LogFile% 2>&1
wmic path %_MicrosoftProduct% where (Description like '%%KMSCLIENT%%') get Name /value 2>nul | findstr /i "Office" >>%LogFile% 2>&1 || (
    echo     Result: No...>>%LogFile% 2>&1
    if %_WinBuild% LSS 9200 (
        echo No Office 2010 or Later VL Product Detected; Retail Versions need to be converted to VL first.
    ) else (
        echo No Office 2010 VL Product Detected; Retail Versions need to be converted to VL first.
    )
    exit /b
)
::===================
REM Call Common Core Activation Routines
call :CommonSLSandOSPS
::===================
call :ClearAPPData %_hkOSPP%
echo.
echo ===================%_MicrosoftService% Activation  End =================== >>%LogFile% 2>&1
::===================
exit /b
::============================================================================================================================================================
:: Called by SLSActivation/OSPSActivation, _MicrosoftProduct/_MicrosoftService based on caller
:CommonSLSandOSPS
::===================
REM Get SoftwareLicensingService/OfficeSoftwareProtectionService version to set 'KMSHost' and 'KMSPort' values
for /f "tokens=2 delims==" %%G in ('"wmic path %_MicrosoftService% get Version /value 2>>%LogFile%"') do set _ver=%%G
::===================
REM Set KMS Server details from KMS Client
echo     ===================%_MicrosoftService% Set KMS Server details Start=================== >>%LogFile% 2>&1
wmic path %_MicrosoftService% where version='%_ver%' call SetKeyManagementServiceMachine MachineName="%_KMSHost%" >>%LogFile% 2>&1
wmic path %_MicrosoftService% where version='%_ver%' call SetKeyManagementServicePort %_KMSPort% >>%LogFile% 2>&1
REM This is available only on SoftwareLicensingService version 6.2 and later; Not available for OfficeSoftwareProtectionService
wmic path %_MicrosoftService% where version='%_ver%' call SetVLActivationTypeEnabled 2 >>%LogFile% 2>&1
echo     ===================%_MicrosoftService% Set KMS Server details  End =================== >>%LogFile% 2>&1
::===================
REM For all the supported KMS Clients in SoftwareLicensingProduct/OfficeSoftwareProtectionProduct call 'CheckProduct'
for /f "tokens=2 delims==" %%G in ('"wmic path %_MicrosoftProduct% where (Description like '%%KMSCLIENT%%') get ID /value 2>>%LogFile%"') do (
    echo.
    echo     ===================%_MicrosoftProduct% CheckProduct %%G Start=================== >>%LogFile% 2>&1
    call :CheckProduct %%G
    echo     ===================%_MicrosoftProduct% CheckProduct %%G  End =================== >>%LogFile% 2>&1
)
::===================
REM Clear KMS Server details from KMS Client
echo     ===================%_MicrosoftService% Clear KMS Server details Start=================== >>%LogFile% 2>&1
wmic path %_MicrosoftService% where version='%_ver%' call ClearKeyManagementServiceMachine >>%LogFile% 2>&1
wmic path %_MicrosoftService% where version='%_ver%' call ClearKeyManagementServicePort >>%LogFile% 2>&1
REM This is available only on SoftwareLicensingService version 6.2 and later; Not available for OfficeSoftwareProtectionService
wmic path %_MicrosoftService% where version='%_ver%' call ClearVLActivationTypeEnabled >>%LogFile% 2>&1
wmic path %_MicrosoftService% where version='%_ver%' call DisableKeyManagementServiceDnsPublishing 1 >>%LogFile% 2>&1
wmic path %_MicrosoftService% where version='%_ver%' call DisableKeyManagementServiceHostCaching 1 >>%LogFile% 2>&1
echo     ===================%_MicrosoftService% Clear KMS Server details  End =================== >>%LogFile% 2>&1
::===================
exit /b
::============================================================================================================================================================
:CheckProduct
::===================
for /f "tokens=2 delims==" %%G in ('"wmic path %_MicrosoftProduct% where ID='%1' get Name /value 2>>%LogFile%"') do set _ProductName=%%G
set _ProductName>>%LogFile% 2>&1
echo Checking %_ProductName% ^(SKU-ID %1^) ...
::===================
REM If Detected KMS Client is already activated earlier, call Activate function
wmic path %_MicrosoftProduct% where ID='%1' get LicenseStatus 2>nul | findstr "1" 1>nul 2>&1 && (
    echo     It is already activated earlier, call Activate function... >> %LogFile% 2>&1
    call :ActivateProduct %1
    exit /b
)
::===================
REM If Detected KMS Client has GVLK, call Activate function
wmic path %_MicrosoftProduct% where (PartialProductKey is not NULL) get ID 2>nul | findstr /i "%1" 1>>%LogFile% 2>&1 && (
    echo     The SKU-ID has been installed GVLK, call Activate function... >> %LogFile% 2>&1
    call :ActivateProduct %1
    exit /b
)
::===================
REM Detecting the SKU-ID is Office product.
set /a _OfficeSLP=0
wmic path %_MicrosoftProduct% where ID='%1' get Name /value 2>nul | findstr /i "Office" 1>>%LogFile% 2>&1 && (
    set /a _OfficeSLP=1
)
set _OfficeSLP >> %LogFile% 2>&1
::===================
REM Skip for UnNecessary Products[This Product is not Office, but Windows has been installed GVLK. It should be activated before. Thus this product is incorrect edition windows. Hence we skip it.]
if %_OfficeSLP% EQU 0 (
    if %_WindowsGVLK% EQU 1 (
        echo     Skip error Windows edition. >> %LogFile% 2>&1
        echo     Skip error Windows edition.
        exit /b
    )
)
::===================
REM Ugly hack for multiple Windows 10 SKU-IDs
for %%G in (
    b71515d9-89a2-4c60-88c8-656fbcca7f3a
    af43f7f0-3b1e-4266-a123-1fdb53f4323b
    075aca1f-05d7-42e5-a3ce-e349e7be7078
    2cf5af84-abab-4ff0-83f8-f040fb2576eb
    11a37f09-fb7f-4002-bd84-f3ae71d11e90
    43f2ab05-7c87-4d56-b27c-44d0f9a3dabd
    6ae51eeb-c268-4a21-9aae-df74c38b586d
    ff808201-fec6-4fd4-ae16-abbddade5706
    34260150-69ac-49a3-8a0d-4a403ab55763
    903663f7-d2ab-49c9-8942-14aa9e0a9c72
    4dfd543d-caa6-4f69-a95f-5ddfe2b89567
    5fe40dd6-cf1f-4cf2-8729-92121ac2e997
    2cc171ef-db48-4adc-af09-7c574b37f139
) do (
    if /i '%1' EQU '%%G' (
        echo     This SKU-ID %1 is not supported. >> %LogFile% 2>&1
        echo     This SKU-ID %1 is not supported. 
        exit /b
    )
)
::===================
REM If Detected KMS Client do not have GVLK, do checks for permanent activation, then install GVLK and activate it
for /f "tokens=3 delims==, " %%G in ('"wmic path %_MicrosoftProduct% where ID='%1' get Name /value 2>>%LogFile%"') do set _OfficeVer=%%G
if !_Office%_OfficeVer%! EQU 1 (
    if '%_OfficeVer%' EQU '16' (
        call :CheckOffice16 %1
    ) else if '%_OfficeVer%' EQU '15' (
        call :CheckOffice15 %1
    ) else if '%_OfficeVer%' EQU '14' (
        call :CheckOffice14 %1
    ) else (
        set _Office%_OfficeVer% >> %LogFile% 2>&1
    )
) else (
    call :CheckWindows %1
)
::===================
exit /b
::============================================================================================================================================================
:ActivateProduct
::===================
REM Clear any manually set KMSHostIP and KMSPort with /skms or /sethst; Since they override KMSHostIP and KMSPort values set for SLS/OSPS
wmic path %_MicrosoftProduct% where ID='%1' call ClearKeyManagementServiceMachine >>%LogFile% 2>&1
wmic path %_MicrosoftProduct% where ID='%1' call ClearKeyManagementServicePort >>%LogFile% 2>&1
::===================
REM Call Activate method of the corresponding KMS Client
echo     %_MicrosoftProduct% trying to activate %_ProductName% ...
wmic path %_MicrosoftProduct% where ID='%1' call Activate >>%LogFile% 2>&1
::===================
REM Get Remaining Grace Period of the KMS Client
for /f "tokens=2 delims==" %%G in ('"wmic path %_MicrosoftProduct% where ID='%1' get GracePeriodRemaining /value"') do set /a _gprMinutes=%%G
set /a _gprDays=%_gprMinutes%/1440
::===================
if %_gprMinutes% EQU 43200 (
    if %_WinBuild% EQU 9200 (
        echo     Result: Windows Core/ProfessionalWMC Activation Successful
    )
) else if %_gprMinutes% EQU 64800 (
    echo     Result: Windows Core/ProfessionalWMC Activation Successful
) else if %_gprMinutes% EQU 259200 (
    echo     Result: Successful.
) else (
    echo     Result: Failed.
)
echo     Remaining Period: %_gprDays% days ^(%_gprMinutes% minutes^)
::===================
exit /b
::============================================================================================================================================================
:CheckOffice16
::===================
REM Detect if Office product edition is permanently MAK activated based on SKU-ID
if '%1' EQU '9caabccb-61b1-4b4b-8bec-d10a3c3ac2ce' (
    set "OfficeEdition=Office16MondoVL_MAK"
    set "OfficeEditionDescription=Office 2016 Mondo"
    goto :CheckOfficeMAK_1 %1
)
if '%1' EQU 'd450596f-894d-49e0-966a-fd39ed4c4c64' (
    set "OfficeEdition=Office16ProPlusVL_MAK"
    set "OfficeEditionDescription=Office 2016 ProPlus"
    goto :CheckOfficeMAK_1 %1
)
if '%1' EQU '6bf301c1-b94a-43e9-ba31-d494598c47fb' (
    set "OfficeEdition=Office16VisioProVL_MAK"
    set "OfficeEditionDescription=Visio 2016 Pro"
    goto :CheckOfficeMAK_1 %1
)
if '%1' EQU '4f414197-0fc2-4c01-b68a-86cbb9ac254c' (
    set "OfficeEdition=Office16ProjectProVL_MAK"
    set "OfficeEditionDescription=Project 2016 Pro"
    goto :CheckOfficeMAK_1 %1
)
if '%1' EQU 'dedfa23d-6ed1-45a6-85dc-63cae0546de6' (
    set "OfficeEdition=Office16StandardVL_MAK"
    set "OfficeEditionDescription=Office 2016 Standard"
    goto :CheckOfficeMAK_1 %1
)
if '%1' EQU 'aa2a7821-1827-4c2c-8f1d-4513a34dda97' (
    set "OfficeEdition=Office16VisioStdVL_MAK"
    set "OfficeEditionDescription=Visio 2016 Standard"
    goto :CheckOfficeMAK_1 %1
)
if '%1' EQU 'da7ddabc-3fbe-4447-9e01-6ab7440b4cd4' (
    set "OfficeEdition=Office16ProjectStdVL_MAK"
    set "OfficeEditionDescription=Project 2016 Standard"
    goto :CheckOfficeMAK_1 %1
)
::===================
REM If Office 2016 product is not permanently activated, Install GVLK and Activate
call :SelectKey %1
::===================
exit /b
::============================================================================================================================================================
:CheckOffice15
::===================
REM Detect if Office product edition is permanently MAK activated based on SKU-ID
if '%1' EQU 'dc981c6b-fc8e-420f-aa43-f8f33e5c0923' (
    set "OfficeEdition=OfficeMondoVL_MAK"
    set "OfficeEditionDescription=Office 2013 Mondo"
    goto :CheckOfficeMAK_1 %1
)
if '%1' EQU 'b322da9c-a2e2-4058-9e4e-f59a6970bd69' (
    set "OfficeEdition=OfficeProPlusVL_MAK"
    set "OfficeEditionDescription=Office 2013 ProPlus"
    goto :CheckOfficeMAK_1 %1
)
if '%1' EQU 'e13ac10e-75d0-4aff-a0cd-764982cf541c' (
    set "OfficeEdition=OfficeVisioProVL_MAK"
    set "OfficeEditionDescription=Visio 2013 Pro"
    goto :CheckOfficeMAK_1 %1
)
if '%1' EQU '4a5d124a-e620-44ba-b6ff-658961b33b9a' (
    set "OfficeEdition=OfficeProjectProVL_MAK"
    set "OfficeEditionDescription=Project 2013 Pro"
    goto :CheckOfficeMAK_1 %1
)
if '%1' EQU 'b13afb38-cd79-4ae5-9f7f-eed058d750ca' (
    set "OfficeEdition=OfficeStandardVL_MAK"
    set "OfficeEditionDescription=Office 2013 Standard"
    goto :CheckOfficeMAK_1 %1
)
if '%1' EQU 'ac4efaf0-f81f-4f61-bdf7-ea32b02ab117' (
    set "OfficeEdition=OfficeVisioStdVL_MAK"
    set "OfficeEditionDescription=Visio 2013 Standard"
    goto :CheckOfficeMAK_1 %1
)
if '%1' EQU '427a28d1-d17c-4abf-b717-32c780ba6f07' (
    set "OfficeEdition=OfficeProjectStdVL_MAK"
    set "OfficeEditionDescription=Project 2013 Standard"
    goto :CheckOfficeMAK_1 %1
)
::===================
REM If Office 2013 product is not permanently activated, Install GVLK and Activate
call :SelectKey %1
::===================
exit /b
::============================================================================================================================================================
:CheckOffice14
::===================
for /f "tokens=2 delims==" %%G in ('"wmic path %_spp% where (Name like '%%OfficeVisioPrem-MAK%%') get LicenseStatus /value 2>>%LogFile%"') do set /a _vPrem=%%G
for /f "tokens=2 delims==" %%G in ('"wmic path %_spp% where (Name like '%%OfficeVisioPro-MAK%%') get LicenseStatus /value 2>>%LogFile%"') do set /a _vPro=%%G
set _vPrem>>%LogFile% 2>&1
set _vPro>>%LogFile% 2>&1
::===================
REM Detect if Office product edition is permanently MAK activated based on SKU-ID
if '%1' EQU '09ed9640-f020-400a-acd8-d7d867dfd9c2' (
    set "OfficeEdition=OfficeMondo-MAK"
    set "OfficeEditionDescription=Office 2010 Mondo"
    goto :CheckOfficeMAK_1 %1
)
if '%1' EQU 'df133ff7-bf14-4f95-afe3-7b48e7e331ef' (
    set "OfficeEdition=OfficeProjectPro-MAK"
    set "OfficeEditionDescription=Project 2010 Pro"
    goto :CheckOfficeMAK_1 %1
)
if '%1' EQU '5dc7bf61-5ec9-4996-9ccb-df806a2d0efe' (
    set "OfficeEdition=OfficeProjectStd-MAK"
    set "OfficeEditionDescription=Project 2010 Standard"
    goto :CheckOfficeMAK_1 %1
)
if '%1' EQU '9da2a678-fb6b-4e67-ab84-60dd6a9c819a' (
    set "OfficeEdition=OfficeStandard-MAK"
    set "OfficeEditionDescription=Office 2010 Standard"
    goto :CheckOfficeMAK_1 %1
)
if '%1' EQU 'ea509e87-07a1-4a45-9edc-eba5a39f36af' (
    set "OfficeEdition=OfficeSmallBusBasics-MAK"
    set "OfficeEditionDescription=Office 2010 Small Business"
    goto :CheckOfficeMAK_1 %1
)
if '%1' EQU '6f327760-8c5c-417c-9b61-836a98287e0c' (
    set "OfficeEdition1=OfficeProPlus-MAK"
    set "OfficeEdition2=OfficeProPlusAcad-MAK"
    set "OfficeEditionDescription1=Office 2010 ProPlus"
    set "OfficeEditionDescription2=Office 2010 ProPlus Academic"
    goto :CheckOfficeMAK_2 %1
)
if '%1' EQU '92236105-bb67-494f-94c7-7f7a607929bd' (
    set "OfficeEdition1=OfficeVisioPrem-MAK"
    set "OfficeEdition2=OfficeVisioPro-MAK"
    set "OfficeEditionDescription1=Visio 2010 Premium"
    set "OfficeEditionDescription2=Visio 2010 Pro"
    goto :CheckOfficeMAK_2 %1
)
if defined _vPrem exit /b
if '%1' EQU 'e558389c-83c3-4b29-adfe-5e4d7f46c358' (
    set "OfficeEdition1=OfficeVisioPro-MAK"
    set "OfficeEdition2=OfficeVisioStd-MAK"
    set "OfficeEditionDescription1=Visio 2010 Pro"
    set "OfficeEditionDescription2=Visio 2010 Standard"
    goto :CheckOfficeMAK_2 %1
)
if defined _vPro exit /b
if '%1' EQU '9ed833ff-4f92-4f36-b370-8683a4f13275' (
    set "OfficeEdition=OfficeVisioStd-MAK"
    set "OfficeEditionDescription=Visio 2010 Standard"
    goto :CheckOfficeMAK_1 %1
)
::===================
REM If Office 2010 product is not permanently activated, Install GVLK and Activate
call :SelectKey %1
::===================
exit /b
::============================================================================================================================================================
:: Called by CheckOffice16/CheckOffice15/CheckOffice14, OfficeEdition/OfficeEditionDescription based on caller
:CheckOfficeMAK_1
set /a _ls=0
for /f "tokens=2 delims==" %%G in ('"wmic path %_spp% where (Name like '%%%OfficeEdition%%%') get LicenseStatus /value 2>>%LogFile%"') do set /a _ls=%%G
if !_ls! EQU 1 (
    echo     Detected %OfficeEditionDescription% is permanently MAK activated.
) else (
    REM If Office product is not permanently activated, Install GVLK and Activate
    call :SelectKey %1
)
::===================
exit /b
::============================================================================================================================================================
:: Called by CheckOffice14, OfficeEdition/OfficeEditionDescription based on caller
:CheckOfficeMAK_2
set /a _ls1=0
set /a _ls2=0
for /f "tokens=2 delims==" %%G in ('"wmic path %_spp% where (Name like '%%%OfficeEdition1%%%') get LicenseStatus /value 2>>%LogFile%"') do set /a _ls1=%%G
for /f "tokens=2 delims==" %%G in ('"wmic path %_spp% where (Name like '%%%OfficeEdition2%%%') get LicenseStatus /value 2>>%LogFile%"') do set /a _ls2=%%G
if !_ls1! EQU 1 (
    echo     Detected %OfficeEditionDescription1% is permanently MAK activated.
) else if !_ls2! EQU 1 (
    echo     Detected %OfficeEditionDescription2% is permanently MAK activated.
) else (
    REM If Office product is not permanently activated, Install GVLK and Activate
    call :SelectKey %1
)
::===================
exit /b
::============================================================================================================================================================
:CheckWindows
::===================
wmic path %_MicrosoftProduct% where (LicenseStatus='1' and GracePeriodRemaining='0') get Name 2>nul | findstr /i "Windows" 1>>%LogFile% 2>&1 && (
    echo.
    echo     Detected Windows %_EditionID% is permanently MAK activated.
    exit /b
)
::===================
REM If Windows is not permanently activated, Install GVLK and Activate
call :SelectKey %1
::===================
exit /b
::============================================================================================================================================================
:: Select GenericVolumeLicenseKey based on Activation-ID (SKU-ID) and Install it, if found
:SelectKey
echo     Selecting GenericVolumeLicenseKey %_ProductName% >>%LogFile% 2>&1
echo     Selecting GenericVolumeLicenseKey %_ProductName%
goto :%1 2>>%LogFile% || goto :KeyNotFound
::============================================================================================================================================================
:: If GVLK is not found for the current SKU-ID, attempt Activation as GVLK might be present in OS by default
:KeyNotFound
echo.
echo     Result: Success. GVLK of %_ProductName%^(SKU-ID %1^) is not found. >>%LogFile% 2>&1
echo     Result: Success. GVLK of %_ProductName%^(SKU-ID %1^) is not found.
echo             If Activation Fails Now, Please enter GVLK for this Product manually and re-run KMS_VL_ALL.
call :ActivateProduct %1
exit /b
::============================================================================================================================================================
:: Call InstallProductKey method of SLS/OSPS to install GVLK, and activate it
:InstallKey
echo     Result: Success. Installing GVLK for %_ProductName%^(SKU-ID %1^)... >>%LogFile% 2>&1
echo     Result: Success. Installing GVLK for %_ProductName%^(SKU-ID %1^)... 
wmic path %_MicrosoftService% where version='%_ver%' call InstallProductKey ProductKey="%_key%" >>%LogFile% 2>&1
call :ActivateProduct %1
exit /b
::============================================================================================================================================================
:: Exit If SKU-ID not equal to EditionID
:ErrorEdition
echo     Result: Failed. %_ProductName% is not equal to %_EditionID% Edition. >>%LogFile% 2>&1
echo     Result: Failed. %_ProductName% is not equal to %_EditionID% Edition.
exit /b
::============================================================================================================================================================
:: Office Professional Plus 2016
:d450596f-894d-49e0-966a-fd39ed4c4c64 
set "_key=XQNVK-8JYDB-WJ9W3-YJ8YR-WFG99"
goto :InstallKey
:: Office Standard 2016
:dedfa23d-6ed1-45a6-85dc-63cae0546de6 
set "_key=JNRGM-WHDWX-FJJG3-K47QV-DRTFM"
goto :InstallKey
:: Office Mondo 2016
:9caabccb-61b1-4b4b-8bec-d10a3c3ac2ce 
set "_key=HFTND-W9MK4-8B7MJ-B6C4G-XQBR2"
goto :InstallKey
:: Office Project Pro 2016
:4f414197-0fc2-4c01-b68a-86cbb9ac254c 
set "_key=YG9NW-3K39V-2T3HJ-93F3Q-G83KT"
goto :InstallKey
:: Office Project Standard 2016
:da7ddabc-3fbe-4447-9e01-6ab7440b4cd4 
set "_key=GNFHQ-F6YQM-KQDGJ-327XX-KQBVC"
goto :InstallKey
:: Office Visio Pro 2016
:6bf301c1-b94a-43e9-ba31-d494598c47fb 
set "_key=PD3PC-RHNGV-FXJ29-8JK7D-RJRJK"
goto :InstallKey
:: Office Visio Standard 2016
:aa2a7821-1827-4c2c-8f1d-4513a34dda97 
set "_key=7WHWN-4T7MP-G96JF-G33KR-W8GF4"
goto :InstallKey
:: Office Access 2016
:67c0fc0c-deba-401b-bf8b-9c8ad8395804 
set "_key=GNH9Y-D2J4T-FJHGG-QRVH7-QPFDW"
goto :InstallKey
:: Office Excel 2016
:c3e65d36-141f-4d2f-a303-a842ee756a29 
set "_key=9C2PK-NWTVB-JMPW8-BFT28-7FTBF"
goto :InstallKey
:: Office OneNote 2016
:d8cace59-33d2-4ac7-9b1b-9b72339c51c8 
set "_key=DR92N-9HTF2-97XKM-XW2WJ-XW3J6"
goto :InstallKey
:: Office Outlook 2016
:ec9d9265-9d1e-4ed0-838a-cdc20f2551a1 
set "_key=R69KK-NTPKF-7M3Q4-QYBHW-6MT9B"
goto :InstallKey
:: Office Powerpoint 2016
:d70b1bba-b893-4544-96e2-b7a318091c33 
set "_key=J7MQP-HNJ4Y-WJ7YM-PFYGF-BY6C6"
goto :InstallKey
:: Office Publisher 2016
:041a06cb-c5b8-4772-809f-416d03d16654 
set "_key=F47MM-N3XJP-TQXJ9-BP99D-8K837"
goto :InstallKey
:: Office Skype for Business 2016
:83e04ee1-fa8d-436d-8994-d31a862cab77 
set "_key=869NQ-FJ69K-466HW-QYCP2-DDBV6"
goto :InstallKey
:: Office Word 2016
:bb11badf-d8aa-470e-9311-20eaf80fe5cc 
set "_key=WXY84-JN2Q9-RBCCQ-3Q3J3-3PFJ6"
goto :InstallKey
:: Office Mondo R 2016
:e914ea6e-a5fa-4439-a394-a9bb3293ca09
set "_key=DMTCJ-KNRKX-26982-JYCKT-P7KB6"
goto :InstallKey
:: Office Project Pro 2016 XC2R
:829b8110-0e6f-4349-bca4-42803577788d
set "_key=WGT24-HCNMF-FQ7XH-6M8K7-DRTW9"
goto :InstallKey
:: Office Project Standard 2016 XC2R
:cbbaca45-556a-4416-ad03-bda598eaa7c8
set "_key=D8NRQ-JTYM3-7J2DX-646CT-6836M"
goto :InstallKey
:: Office Visio Pro 2016 XC2R
:b234abe3-0857-4f9c-b05a-4dc314f85557
set "_key=69WXN-MBYV6-22PQG-3WGHK-RM6XC"
goto :InstallKey
:: Office Visio Standard 2016 XC2R
:361fe620-64f4-41b5-ba77-84f8e079b1f7
set "_key=NY48V-PPYYH-3F4PX-XJRKJ-W4423"
goto :InstallKey
::============================================================================================================================================================
:: Office Professional Plus 2013
:b322da9c-a2e2-4058-9e4e-f59a6970bd69 
set "_key=YC7DK-G2NP3-2QQC3-J6H88-GVGXT"
goto :InstallKey
:: Office Standard 2013
:b13afb38-cd79-4ae5-9f7f-eed058d750ca 
set "_key=KBKQT-2NMXY-JJWGP-M62JB-92CD4"
goto :InstallKey
:: Office Project Pro 2013
:4a5d124a-e620-44ba-b6ff-658961b33b9a 
set "_key=FN8TT-7WMH6-2D4X9-M337T-2342K"
goto :InstallKey
:: Office Project Standard 2013
:427a28d1-d17c-4abf-b717-32c780ba6f07 
set "_key=6NTH3-CW976-3G3Y2-JK3TX-8QHTT"
goto :InstallKey
:: Office Visio Pro 2013
:e13ac10e-75d0-4aff-a0cd-764982cf541c 
set "_key=C2FG9-N6J68-H8BTJ-BW3QX-RM3B3"
goto :InstallKey
:: Office Visio Standard 2013
:ac4efaf0-f81f-4f61-bdf7-ea32b02ab117 
set "_key=J484Y-4NKBF-W2HMG-DBMJC-PGWR7"
goto :InstallKey
:: Office Access 2013
:6ee7622c-18d8-4005-9fb7-92db644a279b 
set "_key=NG2JY-H4JBT-HQXYP-78QH9-4JM2D"
goto :InstallKey
:: Office Excel 2013
:f7461d52-7c2b-43b2-8744-ea958e0bd09a 
set "_key=VGPNG-Y7HQW-9RHP7-TKPV3-BG7GB"
goto :InstallKey
:: Office InfoPath 2013
:a30b8040-d68a-423f-b0b5-9ce292ea5a8f 
set "_key=DKT8B-N7VXH-D963P-Q4PHY-F8894"
goto :InstallKey
:: Office Lync 2013
:1b9f11e3-c85c-4e1b-bb29-879ad2c909e3 
set "_key=2MG3G-3BNTT-3MFW9-KDQW3-TCK7R"
goto :InstallKey
:: Office OneNote 2013
:efe1f3e6-aea2-4144-a208-32aa872b6545 
set "_key=TGN6P-8MMBC-37P2F-XHXXK-P34VW"
goto :InstallKey
:: Office OutLook 2013
:771c3afa-50c5-443f-b151-ff2546d863a0 
set "_key=QPN8Q-BJBTJ-334K3-93TGY-2PMBT"
goto :InstallKey
:: Office PowerPoint 2013
:8c762649-97d1-4953-ad27-b7e2c25b972e 
set "_key=4NT99-8RJFH-Q2VDH-KYG2C-4RD4F"
goto :InstallKey
:: Office Publisher 2013
:00c79ff1-6850-443d-bf61-71cde0de305f 
set "_key=PN2WF-29XG2-T9HJ7-JQPJR-FCXK4"
goto :InstallKey
:: Office Word 2013
:d9f5b1c6-5386-495a-88f9-9ad6b41ac9b3 
set "_key=6Q7VD-NX8JD-WJ2VH-88V73-4GBJ7"
goto :InstallKey
:: (KMS server unsupported)SharePoint Designer 2013 Retail
:ba3e3833-6a7e-445a-89d0-7802a9a68588 
set "_key=GYJRG-NMYMF-VGBM4-T3QD4-842DW"
goto :InstallKey
:: Office Mondo 2013
:dc981c6b-fc8e-420f-aa43-f8f33e5c0923 
set "_key=42QTK-RN8M7-J3C4G-BBGYM-88CYV"
goto :InstallKey
::============================================================================================================================================================
:: Office Professional Plus 2010
:6f327760-8c5c-417c-9b61-836a98287e0c 
set "_key=VYBBJ-TRJPB-QFQRF-QFT4D-H3GVB"
goto :InstallKey
:: Office Standard 2010
:9da2a678-fb6b-4e67-ab84-60dd6a9c819a 
set "_key=V7QKV-4XVVR-XYV4D-F7DFM-8R6BM"
goto :InstallKey
:: (KMS server unsupported)Office 2010 Starter Retail
:2745e581-565a-4670-ae90-6bf7c57ffe43 
set "_key=VXHHB-W7HBD-7M342-RJ7P8-CHBD6"
goto :InstallKey
:: Office Access 2010
:8ce7e872-188c-4b98-9d90-f8f90b7aad02 
set "_key=V7Y44-9T38C-R2VJK-666HK-T7DDX"
goto :InstallKey
:: Office Excel 2010
:cee5d470-6e3b-4fcc-8c2b-d17428568a9f 
set "_key=H62QG-HXVKF-PP4HP-66KMR-CW9BM"
goto :InstallKey
:: Office Groove 2010
:8947d0b8-c33b-43e1-8c56-9b674c052832 
set "_key=QYYW6-QP4CB-MBV6G-HYMCJ-4T3J4"
goto :InstallKey
:: (KMS server 尚未提供支援)SharePoint Designer 2010 Retail
:b78df69e-0966-40b1-ae85-30a5134dedd0 
set "_key=H48K6-FB4Y6-P83GH-9J7XG-HDKKX"
goto :InstallKey
:: Office InfoPath 2010
:ca6b6639-4ad6-40ae-a575-14dee07f6430 
set "_key=K96W8-67RPQ-62T9Y-J8FQJ-BT37T"
goto :InstallKey
:: Office OneNote 2010
:ab586f5c-5256-4632-962f-fefd8b49e6f4 
set "_key=Q4Y4M-RHWJM-PY37F-MTKWH-D3XHX"
goto :InstallKey
:: Office OutLook 2010
:ecb7c192-73ab-4ded-acf4-2399b095d0cc 
set "_key=7YDC2-CWM8M-RRTJC-8MDVC-X3DWQ"
goto :InstallKey
:: Office PowerPoint 2010
:45593b1d-dfb1-4e91-bbfb-2d5d0ce2227a 
set "_key=RC8FX-88JRY-3PF7C-X8P67-P4VTT"
goto :InstallKey
:: Office Project Pro 2010
:df133ff7-bf14-4f95-afe3-7b48e7e331ef 
set "_key=YGX6F-PGV49-PGW3J-9BTGG-VHKC6"
goto :InstallKey
:: Office Project Standard 2010
:5dc7bf61-5ec9-4996-9ccb-df806a2d0efe 
set "_key=4HP3K-88W3F-W2K3D-6677X-F9PGB"
goto :InstallKey
:: Office Publisher 2010
:b50c4f75-599b-43e8-8dcd-1081a7967241 
set "_key=BFK7F-9MYHM-V68C7-DRQ66-83YTP"
goto :InstallKey
:: Office Word 2010
:2d0882e7-a4e7-423b-8ccc-70d91e0158b1 
set "_key=HVHB3-C6FV7-KQX9W-YQG79-CRY7T"
goto :InstallKey
:: Office Visio Premium 2010
:92236105-bb67-494f-94c7-7f7a607929bd 
set "_key=D9DWC-HPYVV-JGF4P-BTWQB-WX8BJ"
goto :InstallKey
:: Office Visio Pro 2010
:e558389c-83c3-4b29-adfe-5e4d7f46c358 
set "_key=7MCW8-VRQVK-G677T-PDJCM-Q8TCP"
goto :InstallKey
:: Office Visio Standard 2010
:9ed833ff-4f92-4f36-b370-8683a4f13275 
set "_key=767HD-QGMWX-8QTDB-9G3R2-KHFGJ"
goto :InstallKey
:: Office Small Business Basics 2010
:ea509e87-07a1-4a45-9edc-eba5a39f36af 
set "_key=D6QFG-VBYP2-XQHM7-J97RH-VVRCK"
goto :InstallKey
:: Office Mondo 1 2010
:09ed9640-f020-400a-acd8-d7d867dfd9c2 
set "_key=YBJTT-JG6MD-V9Q7P-DBKXJ-38W9R"
goto :InstallKey
:: Office Mondo 2 2010
:ef3d4e49-a53d-4d81-a2b1-2ca6c2556b2c 
set "_key=7TC2V-WXF6P-TD7RT-BQRXR-B8K32"
goto :InstallKey
::============================================================================================================================================================
:: Windows 10 Professional
:2de67392-b7a7-462a-b1ca-108dd189f588 
if '%_EditionID%' neq 'Professional' goto :ErrorEdition
set "_key=W269N-WFGWX-YVC9B-4J6C9-T83GX"
goto :InstallKey
:: Windows 10 Professional N
:a80b5abf-76ad-428b-b05d-a47d2dffeebf 
if '%_EditionID%' neq 'ProfessionalN' goto :ErrorEdition
set "_key=MH37W-N47XK-V7XM9-C7227-GCQG9"
goto :InstallKey
:: Windows 10 Professional Education
:3f1afc82-f8ac-4f6c-8005-1d233e606eee 
if '%_EditionID%' neq 'ProfessionalEducation' goto :ErrorEdition
set "_key=6TP4R-GNPTD-KYYHQ-7B7DP-J447Y"
goto :InstallKey
:: Windows 10 Professional Education N
:5300b18c-2e33-4dc2-8291-47ffcec746dd 
if '%_EditionID%' neq 'ProfessionalEducationN' goto :ErrorEdition
set "_key=YVWGF-BXNMC-HTQYQ-CPQ99-66QFC"
goto :InstallKey
:: (KMS server unsupported)Windows 10 Professional for Advanced PCs
:82bbc092-bc50-4e16-8e18-b74fc486aec3
if '%_Edition%' neq 'ProfessionalWorkstation' goto :ErrorEdition
set "_key=NRG8B-VKK3Q-CXVCJ-9G2XF-6Q84J"
goto :InstallKey
:: (KMS server unsupported)Windows 10 Professional for Advanced PCs N
:4b1571d3-bafb-4b40-8087-a961be2caf65
if '%_Edition%' neq 'ProfessionalWorkstationN' goto :ErrorEdition
set "_key=9FNHH-K3HBT-3W4TD-6383H-6XYWF"
goto :InstallKey
:: Windows 10 Enterprise
:73111121-5638-40f6-bc11-f1d7b0d64300 
if '%_EditionID%' neq 'Enterprise' goto :ErrorEdition
set "_key=NPPR9-FWDCX-D2C8J-H872K-2YT43"
goto :InstallKey
:: Windows 10 Enterprise N
:e272e3e2-732f-4c65-a8f0-484747d0d947 
if '%_EditionID%' neq 'EnterpriseN' goto :ErrorEdition
set "_key=DPH2V-TTNVB-4X9Q3-TJR4H-KHJW4"
goto :InstallKey
:: Windows 10 Education
:e0c42288-980c-4788-a014-c080d2e1926e 
if '%_EditionID%' neq 'Education' goto :ErrorEdition
set "_key=NW6C2-QMPVW-D7KKK-3GKT6-VCFB2"
goto :InstallKey
:: Windows 10 Education N
:3c102355-d027-42c6-ad23-2e7ef8a02585 
if '%_EditionID%' neq 'EducationN' goto :ErrorEdition
set "_key=2WH4N-8QGBV-H22JP-CT43Q-MDWWJ"
goto :InstallKey
:: Windows 10 Enterprise 2015 LTSB
:7b51a46c-0c04-4e8f-9af4-8496cca90d5e 
if '%_EditionID%' neq 'Enterprise' goto :ErrorEdition
set "_key=WNMTR-4C88C-JK8YV-HQ7T2-76DF9"
goto :InstallKey
:: Windows 10 Enterprise 2015 LTSB N
:87b838b7-41b6-4590-8318-5797951d8529 
if '%_EditionID%' neq 'EnterpriseN' goto :ErrorEdition
set "_key=2F77B-TNFGY-69QQF-B8YKP-D69TJ"
goto :InstallKey
:: Windows 10 Enterprise 2016 LTSB
:2d5a5a60-3040-48bf-beb0-fcd770c20ce0 
if '%_EditionID%' neq 'Enterprise' goto :ErrorEdition
set "_key=DCPHK-NFMTC-H88MJ-PFHPY-QJ4BJ"
goto :InstallKey
:: Windows 10 Enterprise 2016 LTSB N
:9f776d83-7156-45b2-8a5c-359b9c9f22a3 
if '%_EditionID%' neq 'EnterpriseN' goto :ErrorEdition
set "_key=QFFDN-GRT3P-VKWWX-X7T3R-8B639"
goto :InstallKey
:: Windows 10 Home
:58e97c99-f377-4ef1-81d5-4ad5522b5fd8 
if '%_EditionID%' neq 'Home' goto :ErrorEdition
set "_key=TX9XD-98N7V-6WMQ6-BX7FG-H8Q99"
goto :InstallKey
:: Windows 10 Home N
:7b9e1751-a8da-4f75-9560-5fadfe3d8e38 
if '%_EditionID%' neq 'HomeN' goto :ErrorEdition
set "_key=3KHY7-WNT83-DGQKR-F7HPR-844BM"
goto :InstallKey
:: Windows 10 Enterprise G
:e0b2d383-d112-413f-8a80-97f373a5820c 
set "_key=YYVX9-NTFWV-6MDM3-9PT4T-4M68B"
goto :InstallKey
:: Windows 10 Enterprise GN
:e38454fb-41a4-4f59-a5dc-25080e354730 
set "_key=44RPN-FTY23-9VTTB-MP9BX-T84FV"
goto :InstallKey
:: Windows 10 Home Single Language
:cd918a57-a41b-4c82-8dce-1a538e221a83 
set "_key=7HNRX-D7KGG-3K4RQ-4WPJ4-YTDFH"
goto :InstallKey
:: Windows 10 Home Country Specific
:a9107544-f4a0-4053-a96a-1479abdef912 
set "_key=PVMJN-6DFY6-9CCP6-7BKTT-D3WVR"
goto :InstallKey
::============================================================================================================================================================
:: Windows Server 2016 Azure Core
:3dbf341b-5f6c-4fa7-b936-699dce9e263f 
set "_key=VP34G-4NPPG-79JTQ-864T4-R3MQX"
goto :InstallKey
:: Windows Server 2016 Essentials
:2b5a1b0f-a5ab-4c54-ac2f-a6d94824a283 
set "_key=JCKRF-N37P4-C2D82-9YXRT-4M63B"
goto :InstallKey
:: Windows Server 2016 Standard
:8c1c5410-9f39-4805-8c9d-63a07706358f 
set "_key=WC2BQ-8NRM3-FDDYY-2BFGV-KHKQY"
goto :InstallKey
:: Windows Server 2016 Datacenter
:21c56779-b449-4d20-adfc-eece0e1ad74b 
set "_key=CB7KF-BWN84-R7R2Y-793K2-8XDDG"
goto :InstallKey
:: (KMS server unsupported)Windows Server 2016 Standard ACor
:61c5ef22-f14f-4553-a824-c4b31e84b100
set "_key=PTXN8-JFHJM-4WC78-MPCBR-9W4KR"
goto :InstallKey
:: (KMS server unsupported)Windows Server 2016 Datacenter ACor
:e49c08e7-da82-42f8-bde2-b570fbcae76c
set "_key=2HXDN-KRXHB-GPYC7-YCKFJ-7FVDG"
goto :InstallKey
:: Windows Server 2016 Cloud Storage
:7b4433f4-b1e7-4788-895a-c45378d38253 
set "_key=QN4C6-GBJD2-FB422-GHWJK-GJG2R"
goto :InstallKey
:: (KMS server unsupported)Windows Server 2016 RDSH
:e4db50ea-bda1-4566-b047-0ca50abc6f07
set "_key=7NBT4-WGBQX-MP4H7-QXFF8-YP3KX"
goto :InstallKey
::============================================================================================================================================================
:: Windows 8.1 Professional
:c06b6981-d7fd-4a35-b7b4-054742b7af67 
set "_key=GCRJD-8NW9H-F2CDX-CCM8D-9D6T9"
goto :InstallKey
:: Windows 8.1 Professional N
:7476d79f-8e48-49b4-ab63-4d0b813a16e4 
set "_key=HMCNV-VVBFX-7HMBH-CTY9B-B4FXY"
goto :InstallKey
:: Windows 8.1 Enterprise
:81671aaf-79d1-4eb1-b004-8cbbe173afea 
set "_key=MHF9N-XY6XB-WVXMC-BTDCT-MKKG7"
goto :InstallKey
:: Windows 8.1 Enterprise N
:113e705c-fa49-48a4-beea-7dd879b46b14 
set "_key=TT4HM-HN7YT-62K67-RGRQJ-JFFXW"
goto :InstallKey
:: Windows 8.1 Professional WMC
:096ce63d-4fac-48a9-82a9-61ae9e800e5f 
set "_key=789NJ-TQK6T-6XTH8-J39CJ-J8D3P"
goto :InstallKey
:: Windows 8.1 Professional Student
:e58d87b5-8126-4580-80fb-861b22f79296 
set "_key=MX3RK-9HNGX-K3QKC-6PJ3F-W8D7B"
goto :InstallKey
:: Windows 8.1 Professional Student N
:cab491c7-a918-4f60-b502-dab75e334f40 
set "_key=TNFGH-2R6PB-8XM3K-QYHX2-J4296"
goto :InstallKey
:: Windows 8.1 Core Connected
:e9942b32-2e55-4197-b0bd-5ff58cba8860 
set "_key=3PY8R-QHNP9-W7XQD-G6DPH-3J2C9"
goto :InstallKey
:: Windows 8.1 Core Connected N
:c6ddecd6-2354-4c19-909b-306a3058484e 
set "_key=Q6HTR-N24GM-PMJFP-69CD8-2GXKR"
goto :InstallKey
:: Windows 8.1 Core Connected Single Language
:b8f5e3a3-ed33-4608-81e1-37d6c9dcfd9c 
set "_key=KF37N-VDV38-GRRTV-XH8X6-6F3BB"
goto :InstallKey
:: Windows 8.1 Core Connected Country Specific
:ba998212-460a-44db-bfb5-71bf09d1c68b 
set "_key=R962J-37N87-9VVK2-WJ74P-XTMHR"
goto :InstallKey
:: Windows 8.1 Core
:fe1c3238-432a-43a1-8e25-97e7d1ef10f3 
set "_key=M9Q9P-WNJJT-6PXPY-DWX8H-6XWKK"
goto :InstallKey
:: Windows 8.1 Core N
:78558a64-dc19-43fe-a0d0-8075b2a370a3 
set "_key=7B9N3-D94CG-YTVHR-QBPX3-RJP64"
goto :InstallKey
:: Windows 8.1 Core ARM
:ffee456a-cd87-4390-8e07-16146c672fd0 
set "_key=XYTND-K6QKT-K2MRH-66RTM-43JKP"
goto :InstallKey
:: Windows 8.1 Core Single Language
:c72c6a1d-f252-4e7e-bdd1-3fca342acb35 
set "_key=BB6NG-PQ82V-VRDPW-8XVD2-V8P66"
goto :InstallKey
:: Windows 8.1 Core Country Specific
:db78b74f-ef1c-4892-abfe-1e66b8231df6 
set "_key=NCTT7-2RGK8-WMHRF-RY7YQ-JTXG3"
goto :InstallKey
:: Windows Server 2012 R2 Standard
:b3ca044e-a358-4d68-9883-aaa2941aca99 
set "_key=D2N9P-3P6X9-2R39C-7RTCD-MDVJX"
goto :InstallKey
:: Windows Server 2012 R2 Datacenter
:00091344-1ea4-4f37-b789-01750ba6988c 
set "_key=W3GGN-FT8W3-Y4M27-J84CP-Q3VJ9"
goto :InstallKey
:: Windows Server 2012 R2 Essentials
:21db6ba4-9a7b-4a14-9e29-64a60c59301d 
set "_key=KNC87-3J2TX-XB4WP-VCPJV-M4FWM"
goto :InstallKey
:: Windows Server 2012 R2 Cloud Storage
:b743a2be-68d4-4dd3-af32-92425b7bb623 
set "_key=3NPTF-33KPT-GGBPR-YX76B-39KDD"
goto :InstallKey
:: Windows 8.1 Embedded Industry Professional
:0ab82d54-47f4-4acb-818c-cc5bf0ecb649 
set "_key=NMMPB-38DD4-R2823-62W8D-VXKJB"
goto :InstallKey
:: Windows 8.1 Embedded Industry Enterprise
:cd4e2d9f-5059-4a50-a92d-05d5bb1267c7 
set "_key=FNFKF-PWTVT-9RC8H-32HB2-JB34X"
goto :InstallKey
:: Windows 8.1 Embedded Industry Automotive
:f7e88590-dfc7-4c78-bccb-6f3865b99d1a 
set "_key=VHXM3-NR6FT-RY6RT-CK882-KW2CJ"
goto :InstallKey
::============================================================================================================================================================
:: Windows 8 Professional
:a98bcd6d-5343-4603-8afe-5908e4611112 
set "_key=NG4HW-VH26C-733KW-K6F98-J8CK4"
goto :InstallKey
:: Windows 8 Professional N
:ebf245c1-29a8-4daf-9cb1-38dfc608a8c8 
set "_key=XCVCF-2NXM9-723PB-MHCB7-2RYQQ"
goto :InstallKey
:: Windows 8 Enterprise
:458e1bec-837a-45f6-b9d5-925ed5d299de 
set "_key=32JNW-9KQ84-P47T8-D8GGY-CWCK7"
goto :InstallKey
:: Windows 8 Enterprise N
:e14997e7-800a-4cf7-ad10-de4b45b578db 
set "_key=JMNMF-RHW7P-DMY6X-RF3DR-X2BQT"
goto :InstallKey
:: Windows 8 Professional WMC
:a00018a3-f20f-4632-bf7c-8daa5351c914 
set "_key=GNBB8-YVD74-QJHX6-27H4K-8QHDG"
goto :InstallKey
:: Windows 8 Core
:c04ed6bf-55c8-4b47-9f8e-5a1f31ceee60 
set "_key=BN3D2-R7TKB-3YPBD-8DRP2-27GG4"
goto :InstallKey
:: Windows 8 Core N
:197390a0-65f6-4a95-bdc4-55d58a3b0253 
set "_key=8N2M2-HWPGY-7PGT9-HGDD8-GVGGY"
goto :InstallKey
:: (KMS server unsupported)Windows 8 Core ARM
:af35d7b7-5035-4b63-8972-f0b747b9f4dc 
set "_key=DXHJF-N9KQX-MFPVR-GHGQK-Y7RKV"
goto :InstallKey
:: Windows Server 2012 Single Language / Windows 8 Core Single Language
:8860fcd4-a77b-4a20-9045-a150ff11d609 
set "_key=2WN2H-YGCQR-KFX6K-CD6TF-84YXQ"
goto :InstallKey
:: Windows Server 2012 Country Specific / Windows 8 Core Country Specific
:9d5584a2-2d85-419a-982c-a00888bb9ddf 
set "_key=4K36P-JN4VD-GDC6V-KDT89-DYFKP"
goto :InstallKey
::============================================================================================================================================================
:: Windows Server 2012 Standard
:f0f5ec41-0d55-4732-af02-440a44a3cf0f 
set "_key=XC9B7-NBPP2-83J2H-RHMBY-92BT4"
goto :InstallKey
:: Windows Server 2012 MultiPoint Standard
:7d5486c7-e120-4771-b7f1-7b56c6d3170c 
set "_key=HM7DN-YVMH3-46JC3-XYTG7-CYQJJ"
goto :InstallKey
:: Windows Server 2012 MultiPoint Premium
:95fd1c83-7df5-494a-be8b-1300e1c9d1cd 
set "_key=XNH6W-2V9GX-RGJ4K-Y8X6F-QGJ2G"
goto :InstallKey
:: Windows Server 2012 Datacenter
:d3643d60-0c42-412d-a7d6-52e6635327f6 
set "_key=48HP8-DN98B-MYWDG-T2DCC-8W83P"
goto :InstallKey
:: Windows 8 Embedded Industry Professional
:10018baf-ce21-4060-80bd-47fe74ed4dab 
set "_key=RYXVT-BNQG7-VD29F-DBMRY-HT73M"
goto :InstallKey
:: Windows 8 Embedded Industry Enterprise
:18db1848-12e0-4167-b9d7-da7fcda507db 
set "_key=NKB3R-R2F8T-3XCDP-7Q2KW-XWYQ2"
goto :InstallKey
::============================================================================================================================================================
:: Windows 7 Professional
:b92e9980-b9d5-4821-9c94-140f632f6312 
set "_key=FJ82H-XT6CR-J8D7P-XQJJ2-GPDD4"
goto :InstallKey
:: Windows 7 Professional N
:54a09a0d-d57b-4c10-8b69-a842d6590ad5 
set "_key=MRPKT-YTG23-K7D7T-X2JMM-QY7MG"
goto :InstallKey
:: Windows 7 Professional E
:5a041529-fef8-4d07-b06f-b59b573b32d2 
set "_key=W82YF-2Q76Y-63HXB-FGJG9-GF7QX"
goto :InstallKey
:: Windows 7 Enterprise
:ae2ee509-1b34-41c0-acb7-6d4650168915 
set "_key=33PXH-7Y6KF-2VJC9-XBBR8-HVTHH"
goto :InstallKey
:: Windows 7 Enterprise N
:1cb6d605-11b3-4e14-bb30-da91c8e3983a 
set "_key=YDRBP-3D83W-TY26F-D46B2-XCKRJ"
goto :InstallKey
:: Windows 7 Enterprise E
:46bbed08-9c7b-48fc-a614-95250573f4ea 
set "_key=C29WB-22CC8-VJ326-GHFJW-H9DH4"
goto :InstallKey
:: Windows 7 Embedded POSReady
:db537896-376f-48ae-a492-53d0547773d0 
set "_key=YBYF6-BHCR3-JPKRB-CDW7B-F9BK4"
goto :InstallKey
:: Windows 7 ThinPC
:aa6dd3aa-c2b4-40e2-a544-a6bbb3f5c395 
set "_key=73KQT-CD9G6-K7TQG-66MRP-CQ22C"
goto :InstallKey
:: Windows 7 Embedded Standard
:e1a8296a-db37-44d1-8cce-7bc961d59c54 
set "_key=XGY72-BRBBT-FF8MH-2GG8H-W7KCW"
goto :InstallKey
::============================================================================================================================================================
:: Windows Server 2008 R2 Web
:a78b8bd9-8017-4df5-b86a-09f756affa7c 
set "_key=6TPJF-RBVHG-WBW2R-86QPH-6RTM4"
goto :InstallKey
:: Windows Server 2008 R2 HPC Edition
:cda18cf3-c196-46ad-b289-60c072869994 
set "_key=TT8MH-CG224-D3D7Q-498W2-9QCTX"
goto :InstallKey
:: Windows Server 2008 R2 Standard
:68531fb9-5511-4989-97be-d11a0f55633f 
set "_key=YC6KT-GKW9T-YTKYR-T4X34-R7VHC"
goto :InstallKey
:: Windows Server 2008 R2 Enterprise
:620e2b3d-09e7-42fd-802a-17a13652fe7a 
set "_key=489J6-VHDMP-X63PK-3K798-CPX3Y"
goto :InstallKey
:: Windows Server 2008 R2 Datacenter
:7482e61b-c589-4b7f-8ecc-46d455ac3b87 
set "_key=74YFP-3QFB3-KQT8W-PMXWJ-7M648"
goto :InstallKey
:: Windows Server 2008 R2 for Itanium Enterprise
:8a26851c-1c7e-48d3-a687-fbca9b9ac16b 
set "_key=GT63C-RJFQ3-4GMB6-BRFB9-CB83V"
goto :InstallKey
:: Windows MultiPoint Server 2010
:f772515c-0e87-48d5-a676-e6962c3e1195 
set "_key=736RG-XDKJK-V34PF-BHK87-J6X3K"
goto :InstallKey
::============================================================================================================================================================
:: Windows Vista Business
:4f3d1606-3fea-4c01-be3c-8d671c401e3b 
set "_key=YFKBB-PQJJV-G996G-VWGXY-2V3X8"
goto :InstallKey
:: Windows Vista Business N
:2c682dc2-8b68-4f63-a165-ae291d4cf138 
set "_key=HMBQG-8H2RH-C77VX-27R82-VMQBT"
goto :InstallKey
:: Windows Vista Enterprise
:cfd8ff08-c0d7-452b-9f60-ef5c70c32094 
set "_key=VKK3X-68KWM-X2YGT-QR4M6-4BWMV"
goto :InstallKey
:: Windows Vista Enterprise N
:d4f54950-26f2-4fb4-ba21-ffab16afcade 
set "_key=VTC42-BM838-43QHV-84HX6-XJXKV"
goto :InstallKey
::============================================================================================================================================================
:: Windows Server 2008 Web
:ddfa9f7c-f09e-40b9-8c1a-be877a9a7f4b 
set "_key=WYR28-R7TFJ-3X2YQ-YCY4H-M249D"
goto :InstallKey
:: Windows Server 2008 Standard
:ad2542d4-9154-4c6d-8a44-30f11ee96989 
set "_key=TM24T-X9RMF-VWXK6-X8JC9-BFGM2"
goto :InstallKey
:: Windows Server 2008 Standard without Hyper-V
:2401e3d0-c50a-4b58-87b2-7e794b7d2607 
set "_key=W7VD6-7JFBR-RX26B-YKQ3Y-6FFFJ"
goto :InstallKey
:: Windows Server 2008 Enterprise
:c1af4d90-d1bc-44ca-85d4-003ba33db3b9 
set "_key=YQGMW-MPWTJ-34KDK-48M3W-X4Q6V"
goto :InstallKey
:: Windows Server 2008 Enterprise without Hyper-V
:8198490a-add0-47b2-b3ba-316b12d647b4 
set "_key=39BXF-X8Q23-P2WWT-38T2F-G3FPG"
goto :InstallKey
:: Windows Server 2008 Compute Cluster
:7afb1156-2c1d-40fc-b260-aab7442b62fe 
set "_key=RCTX3-KWVHP-BR6TB-RB6DM-6X7HP"
goto :InstallKey
:: Windows Server 2008 Datacenter
:68b6e220-cf09-466b-92d3-45cd964b9509 
set "_key=7M67G-PC374-GR742-YH8V4-TCBY3"
goto :InstallKey
:: Windows Server 2008 Datacenter without Hyper-V
:fd09ef77-5647-4eff-809c-af2b64659a45 
set "_key=22XQ2-VRXRG-P8D42-K34TD-G3QQC"
goto :InstallKey
:: Windows Server 2008 for Itanium
:01ef176b-3e0d-422a-b4f8-4ea880035e8f 
set "_key=4DWFP-JF3DJ-B7DTH-78FJB-PDRHK"
goto :InstallKey
::============================================================================================================================================================
REM the following SKU-ID are supported by VLMCSD KMS server, but not found GVLK
:: Windows 10 Professional Preview
:ff808201-fec6-4fd4-ae16-abbddade5706
set _key=
goto :KeyNotFound
:: Windows 10 Enterprise Preview
:43f2ab05-7c87-4d56-b27c-44d0f9a3dabd
set _key=
goto :KeyNotFound
:: Windows 10 Enterprise Preview
:cde952c7-2f96-4d9d-8f2b-2d349f64fc51
set _key=
goto :KeyNotFound
:: Windows 10 Professional Preview
:a4383e6b-dada-423d-a43d-f25678429676
set _key=
goto :KeyNotFound
:: Windows 10 Professional WMC Preview
:cf59a07b-1a2a-4be0-bfe0-423b5823e663
set _key=
goto :KeyNotFound
:: Windows 8.x Preview
:2b9c337f-7a1d-4271-90a3-c6855a2b8a1c
set _key=
goto :KeyNotFound
:: Windows 8.x Preview ARM
:631ead72-a8ab-4df8-bbdf-372029989bdd
set _key=
goto :KeyNotFound
:: Windows Server 2016 Datacenter Preview
:ba947c44-d19d-4786-b6ae-22770bc94c54
set _key=
goto :KeyNotFound
:: Office Access 2013 (Pre-Release)
:44b538e2-fb34-4732-81e4-644c17d2e746
set _key=
goto :KeyNotFound
:: Office Excel 2013 (Pre-Release)
:9373bfa0-97b3-4587-ab73-30934461d55c
set _key=
goto :KeyNotFound
:: Office Groove 2013 (Pre-Release)
:aa286eb4-556f-4eeb-967c-c1b771b7673e
set _key=
goto :KeyNotFound
:: Office InfoPath 2013 (Pre-Release)
:7ccc8256-fbaa-49c6-b2a9-f5afb4257cd2
set _key=
goto :KeyNotFound
:: Office Lync 2013 (Pre-Release)
:c53dfe17-cc00-4967-b188-a088a965494d
set _key=
goto :KeyNotFound
:: Office Mondo 2013 (Pre-Release)
:2816a87d-e1ed-4097-b311-e2341c57b179
set _key=
goto :KeyNotFound
:: Office OneNote 2013 (Pre-Release)
:67c0f908-184f-4f64-8250-12db797ab3c3
set _key=
goto :KeyNotFound
:: Office Outlook 2013 (Pre-Release)
:7bce4e7a-dd80-4682-98fa-f993725803d2
set _key=
goto :KeyNotFound
:: Office PowerPoint 2013 (Pre-Release)
:1ec10c0a-54f6-453e-b85a-6fa1bbfea9b7
set _key=
goto :KeyNotFound
:: Office Professional Plus 2013 (Pre-Release)
:87d2b5bf-d47b-41fb-af62-71c382f5cc85
set _key=
goto :KeyNotFound
:: Office Project Pro 2013 (Pre-Release)
:3cfe50a9-0e03-4b29-9754-9f193f07b71f
set _key=
goto :KeyNotFound
:: Office Project Standard 2013 (Pre-Release)
:39e49e57-ae68-4ee3-b098-26480df3da96
set _key=
goto :KeyNotFound
:: Office Publisher 2013 (Pre-Release)
:15aa2117-8f79-49a8-8317-753026d6a054
set _key=
goto :KeyNotFound
:: Office Visio Pro 2013 (Pre-Release)
:cfbfd60e-0b5f-427d-917c-a4df42a80e44
set _key=
goto :KeyNotFound
:: Office Visio Standard 2013 (Pre-Release)
:7012cc81-8887-42e9-b17d-4e5e42760f0d
set _key=
goto :KeyNotFound
:: Office Word 2013 (Pre-Release)
:de9c7eb6-5a85-420d-9703-fff11bdd4d43
set _key=
goto :KeyNotFound
