@echo off
title what?

fltmc >nul 2>&1
if %errorlevel%==0 goto gotAdmin

echo Request administrator privileges...
powershell -NoProfile -Command "Start-Process -FilePath '%~f0' -Verb RunAs"
exit /B

:gotAdmin
cd /d "%~dp0"

:langsel
echo ====================================================
echo 'Choose Language'
echo [Chinese][English]
echo ^<c^>^<e^>
echo ====================================================
set "lang="
set /p lang=:/
if not defined lang goto langsel
if /i "%lang%"=="c" goto menu_cn
if /i "%lang%"=="e" goto menu_en
echo  [!] Invalid input
pause
goto langsel

:menu_cn
echo ====================================================
echo '网络修复工具'
echo [网络诊断][扫描内置计算机][扫描外置设备与打印机][下载系统镜像文件]
echo ^<f^>^<g^>^<h^>^<j^>^{z返回语言选择^0退出}
echo ====================================================
set choice=
set /p choice=:/
if /i %choice%==f goto diag
if /i %choice%==g goto scanpc
if /i %choice%==h goto scanext
if /i %choice%==j goto dl
if /i %choice%==z goto langsel
if /i %choice%==0 goto end
echo  [!] Invalid input
pause
goto menu_cn

:menu_en
echo ====================================================
echo 'Network Repair Tool'
echo [Diagnose][Scan PC][Scan Devices/Printers][Download Image]
echo ^<f^>^<g^>^<h^>^<j^>^{z^to^language^0^exit}
echo ====================================================
set choice=
set /p choice=:/
if /i %choice%==f goto diag
if /i %choice%==g goto scanpc
if /i %choice%==h goto scanext
if /i %choice%==j goto dl
if /i %choice%==z goto langsel
if /i %choice%==0 goto end
echo  [!] Invalid input, please retry.
pause
goto menu_en

:diag
echo Network Diagnosis
echo ====================================================
echo.
echo ----- Automatically detect the names of connected physical network cards（Compatible win7 win8 win8.1 win10 win11）-----
set ADAPTER=
for /f "tokens=1,2,3,4,*" %%a in ('netsh interface show interface ^| findstr /i "connected"') do (
  echo %%e | find /i "loopback" >nul
  if errorlevel 1 (
    set ADAPTER=%%e
    goto gotadapter
  )
)
:gotadapter
if %ADAPTER%=="" (
    echo Network card not automatically detected, fallback to Ethernet
    set ADAPTER=以太网
)
echo This time, the network card will be operated：%ADAPTER%
echo.
echo ----- Automatically detect the current default gateway（Compatible win7 win8 win8.1 win10 win11）-----
set GATEWAY=
for /f "tokens=1,2,3" %%a in ('route print ^| find "0.0.0.0"') do (
  if %%a==0.0.0.0 (
    set GATEWAY=%%c
    goto gotgw
  )
)
:gotgw
echo Current Default Gateway：%GATEWAY%
echo.
echo  Automatically opening the properties window of %ADAPTER% and bringing it to the front...
echo Set oShell = CreateObject(Chr(34) ^& "Shell.Application" ^& Chr(34)) > %temp%\openprop.vbs
echo Set oCP = oShell.Namespace(Chr(34) ^& "::{7007ACC7-3202-11D1-AAD2-00805FC1270E}" ^& Chr(34)).Self >> %temp%\openprop.vbs
echo Set oItem = oCP.GetFolder.Items.Item(Chr(34) ^& "%ADAPTER%" ^& Chr(34)) >> %temp%\openprop.vbs
echo oItem.InvokeVerb Chr(34) ^& "properties" ^& Chr(34) >> %temp%\openprop.vbs
echo Set oWsh = CreateObject(Chr(34) ^& "WScript.Shell" ^& Chr(34)) >> %temp%\openprop.vbs
echo oWsh.AppActivate Chr(34) ^& "%ADAPTER%" ^& Chr(34) >> %temp%\openprop.vbs
cscript //nologo %temp%\openprop.vbs
echo.
echo [01] netsh interface show interface
netsh interface show interface
echo.
echo [02] ipconfig /all
ipconfig /all
echo.
echo [03] ipconfig /displaydns
ipconfig /displaydns
echo.
echo [04] getmac
getmac
echo.
echo [05] hostname
hostname
echo.
echo [06] nslookup www.microsoft.com
nslookup www.microsoft.com
echo.
echo [07] ping 127.0.0.1
ping 127.0.0.1
echo.
echo [08] ping %GATEWAY%（Automatically read gateway）
if defined GATEWAY (
    ping %GATEWAY%
) else (
    echo No gateway detected, skipping ping gateway test
)
echo.
echo [09] ping 223.5.5.5
ping 223.5.5.5
echo.
echo [10] ping www.microsoft.com
ping www.microsoft.com
echo.
echo [11] tracert www.microsoft.com
tracert www.microsoft.com
echo.
echo [12] pathping www.microsoft.com
pathping www.microsoft.com
echo.
echo [13] arp -a
arp -a
echo.
echo [14] netstat -an
netstat -an
echo.
echo [15] netstat -ano
netstat -ano
echo.
echo [16] netstat -e
netstat -e
echo.
echo [17] netstat -rn
netstat -rn
echo.
echo [18] nbtstat -n
nbtstat -n
echo.
echo [19] nbtstat -c
nbtstat -c
echo.
echo [20] netsh interface show interface
netsh interface show interface
echo.
echo [21] disable then re-enable %ADAPTER% (Win7/Win10 dual syntax)
netsh interface set interface %ADAPTER% admin=disable 2>nul
if errorlevel 1 netsh interface set interface %ADAPTER% DISABLE 2>nul
netsh interface set interface %ADAPTER% admin=enable 2>nul
if errorlevel 1 netsh interface set interface %ADAPTER% ENABLE 2>nul
echo.
echo [22] netsh winsock reset
netsh winsock reset
echo.
echo [23] netsh int ip reset
netsh int ip reset
echo.
echo [24] ipconfig /release
ipconfig /release
echo.
echo [25] ipconfig /renew
ipconfig /renew
echo.
echo [26] ipconfig /flushdns
ipconfig /flushdns
echo.
echo [27] ipconfig /registerdns
ipconfig /registerdns
echo.
echo [28] Temporarily set the DNS to Alibaba 223.5.5.5（DHCP will be restored afterward）
netsh interface ip set dns %ADAPTER% static 223.5.5.5
echo.
echo [29] Address Restore DHCP
netsh interface ip set address %ADAPTER% dhcp
echo.
echo [30] DNS Restore DHCP
netsh interface ip set dns %ADAPTER% dhcp
echo.
echo [31] route print
route print
echo.
echo [32] Add default route（Automatically read the gateway %GATEWAY%）
if not defined ADAPTER (
    route add 0.0.0.0 mask 0.0.0.0 %GATEWAY%
) else (
    echo No gateway detected, skipping adding default route
)
echo.
echo [33] route delete 0.0.0.0
route delete 0.0.0.0
echo.
echo [34] net view
net view
echo.
echo [35] net share
net share
echo.
echo [36] net use
net use
echo.
echo [37] net start dhcp
net start dhcp
echo.
echo [38] netsh advfirewall show allprofiles
netsh advfirewall show allprofiles
echo.
echo [39] turn off firewall
netsh advfirewall set allprofiles state off
echo.
echo [40] turn on firewall
netsh advfirewall set allprofiles state on
echo.
echo [41] systeminfo
systeminfo
echo.
echo [42] netsh trace start
netsh trace start
echo.
echo [43] netsh trace stop
netsh trace stop
echo.
echo [44] netstat -ano | findstr "3389"
netstat -ano | findstr "3389"
echo.
echo [45] tasklist | findstr "1234"
tasklist | findstr "1234"
echo.
echo [46] ipconfig /all | findstr "IPv4"
ipconfig /all | findstr "IPv4"
echo.
echo ====================================================
echo  Diagnosis complete
echo ====================================================
echo.
echo  Press any key to return to the menu...
pause >nul
if /i %lang%==e (goto menu_en) else (goto menu_cn)

:scanpc
if /i %lang%==e (echo  Internal Computer Scan)
echo ====================================================
echo.
echo ----- Hardware Inventory -----
echo.
echo [1. CPU 处理器]
powershell -c "Get-WmiObject Win32_Processor | Format-Table Name,NumberOfCores,NumberOfLogicalProcessors,MaxClockSpeed -AutoSize"
echo.
echo [2. Memory 内存]
powershell -c "Get-WmiObject Win32_ComputerSystem | Format-Table TotalPhysicalMemory -AutoSize"
echo.
echo [3. Storage 存储]
powershell -c "Get-WmiObject Win32_DiskDrive | Format-Table Model,Size -AutoSize"
echo.
echo [4. BIOS Firmware 固件]
powershell -c "Get-WmiObject Win32_BIOS | Format-Table Manufacturer,Version,SMBIOSBIOSVersion,SerialNumber -AutoSize"
echo.
echo [5. GPU 显卡]
powershell -c "Get-WmiObject Win32_VideoController | Format-Table Name -AutoSize"
echo.
echo [6. Motherboard 主板]
powershell -c "Get-WmiObject Win32_BaseBoard | Format-Table Manufacturer,Product,Version -AutoSize"
echo.
echo [7. Model 电脑型号]
powershell -c "Get-WmiObject Win32_ComputerSystem | Format-Table Manufacturer,Model -AutoSize"
echo.
echo [8. Network 网卡]
powershell -c "Get-WmiObject Win32_NetworkAdapter | Where-Object { $_.NetEnabled -eq $true } | Format-Table Name,MacAddress -AutoSize"
echo.
echo [9. Audio 声卡]
powershell -c "Get-WmiObject Win32_SoundDevice | Format-Table Name -AutoSize"
echo.
echo [10. OS 操作系统]
powershell -c "Get-WmiObject Win32_OperatingSystem | Format-Table Caption,Version -AutoSize"
echo.
if /i %lang%==e (echo  Press any key to return to menu...) else (echo  Press any key to return to the menu...)
pause >nul
if /i %lang%==e (goto menu_en) else (goto menu_cn)

:scanext
if /i %lang%==e (echo  External Devices ^& Printers) else (echo  External Devices ^& Printers)
echo ====================================================
echo.
echo ----- Monitors 显示器 -----
powershell -c "Get-WmiObject Win32_DesktopMonitor | Format-Table Name -AutoSize"
echo.
echo ----- Keyboards 键盘 -----
powershell -c "Get-WmiObject Win32_Keyboard | Format-Table Name -AutoSize"
echo.
echo ----- Mouse/Pointer 鼠标/指向设备 -----
powershell -c "Get-WmiObject Win32_PointingDevice | Format-Table Name -AutoSize"
echo.
echo ----- Printers 打印机 -----
powershell -c "Get-WmiObject Win32_Printer | Format-Table Name,DeviceID,DriverName,PortName -AutoSize"
echo.
echo ----- USB Devices 外接USB设备 -----
powershell -c "Get-WmiObject Win32_USBControllerDevice | Format-Table Antecedent,Dependent -AutoSize"
echo.
if /i %lang%==e (echo  Press any key to return to menu...) else (echo  Press any key to return to the menu...)
pause >nul
if /i %lang%==e (goto menu_en) else (goto menu_cn)

:dl
echo ====================================================
echo 'System image file download'
echo windows:
echo [Windows 7 Ultimate] [Windows WES7]
echo ^<q^> ^<w^>
echo [Windows 10 22H2] [Windows 10 LTSC 2021]
echo ^<r^> ^<t^>
echo [Windows 11 25H2] [Windows 11 IoT LTSC 2024]
echo ^<y^> ^<u^>
echo linux:
echo [Linux Mint 22.3 Xfce] [Lubuntu 26.04 LTS]
echo ^<i^> ^<o^>
echo ====================================================
set /p iso=:/
if /i %iso%==q goto iso_w7u
if /i %iso%==w goto iso_wes7
if /i %iso%==r goto iso_w1022
if /i %iso%==t goto iso_w10ltsc
if /i %iso%==y goto iso_w1125
if /i %iso%==u goto iso_w11iot
if /i %iso%==i goto iso_mint
if /i %iso%==o goto iso_lubuntu
if /i %iso%==z goto langsel
echo  [!] Invalid input
pause
goto dl

:iso_w7u
echo Windows 7 Ultimate
echo · Minimum requirements/最低要求
echo   · CPU：1 GHz
echo   · Memory/内存：1 GB (32bit/位) / 2 GB (64bit/位)
echo   · Disk/硬盘：16 GB (32bit/位) / 20 GB (64bit/位)
echo   · Graphics/显卡：DX9 / WDDM 1.0
echo · Recommended requirements/推荐要求
echo   · CPU：1.8 GHz or above/及以上
echo   · Memory/内存：4 GB
echo   · Disk/硬盘：SSD
echo   · Graphics/显卡：128 MB VRAM/显存 or above/及以上
echo.
echo https://next.itellyou.cn/Original/Index#cbp=Product?ID=6f677346-0a09-43fa-b60d-e878ed7625a0
start https://next.itellyou.cn/Original/Index#cbp=Product?ID=6f677346-0a09-43fa-b60d-e878ed7625a0
goto dl

:iso_wes7
echo Windows WES7
echo · Minimum requirements/最低要求
echo   · CPU：1 GHz (x86/amd64)
echo   · Memory/内存：512 MB
echo   · Storage/存储：1 GB
echo   · Firmware/固件：Support/支持 WinPE 3.0
echo · Recommended requirements/推荐要求
echo   · CPU：Intel Atom or above/及以上
echo   · Memory/内存：1 GB (32bit/位) / 2 GB+ (64bit/位)
echo   · Storage/存储：12 GB (32bit/位)/ 16 GB (64bit/位)
echo.
echo https://www.microsoft.com/download/details.aspx?id=11887
start https://www.microsoft.com/download/details.aspx?id=11887
goto dl

:iso_w1022
echo Windows 10 22H2
echo · Minimum requirements/最低要求
echo   · CPU：1 GHz
echo   · Memory/内存：1 GB (32bit/位) / 2 GB (64bit/位)
echo   · Disk/硬盘：16 GB (32bit/位) / 20 GB (64bit/位)
echo   · Graphics/显卡：DX9 / WDDM 1.0
echo · Recommended requirements/推荐要求
echo   · CPU：dual-core/双核or above/及以上
echo   · Memory/内存：4 GB+
echo   · Disk/硬盘：30 GB SSD
echo   · Graphics/显卡：Support/支持 WDDM 1.0 of/的 integrated graphics/集成显卡 sufficient/即可
echo.
echo https://www.microsoft.com/software-download/windows10
start https://www.microsoft.com/software-download/windows10
goto dl

:iso_w10ltsc
echo Windows 10 LTSC 2021
echo · Minimum requirements/最低要求
echo   · CPU：1 GHz
echo   · Memory/内存：2 GB
echo   · Disk/硬盘：20 GB
echo   · Graphics/显卡：DX9 / WDDM 1.0
echo · Recommended requirements/推荐要求
echo   · CPU：dual-core/双核 2 GHz or above/及以上
echo   · Memory/内存：4 GB+
echo   · Disk/硬盘：64 GB SSD
echo   · Graphics/显卡：Support/支持 WDDM 1.0 of/的 integrated graphics/集成显卡 sufficient/即可
echo.
echo https://next.itellyou.cn/Original/Index#cbp=Product?ID=f905b2d9-11e7-4ee3-8b52-407a8befe8d1
start https://next.itellyou.cn/Original/Index#cbp=Product?ID=f905b2d9-11e7-4ee3-8b52-407a8befe8d1
goto dl

:iso_w1125
echo Windows 11 25H2
echo · Minimum requirements/最低要求
echo   · CPU：1 GHz or faster/或更快，2 core/核or above/及以上 of/的 64 bit/位 processor/处理器（or/或 SoC），must be on Microsoft compatibility list/须在微软兼容列表中
echo   · Memory/内存：4 GB
echo   · Storage/存储：64 GB or larger/或更大
echo   · System firmware/系统固件：UEFI，and/且 Secure Boot/安全启动 enabled/已启用
echo   · Security module/安全模块：TPM 2.0
echo   · Graphics/显卡：compatible/兼容 DirectX 12 / WDDM 2.0
echo   · Monitor/显示器：9 inch/英寸or above/以上，720p
echo · Recommended requirements/推荐要求
echo   · CPU：Intel Gen/第 8 generation/代 Core/酷睿 / AMD Zen 2 or above/及以上
echo   · Memory/内存：8 GB
echo   · Storage/存储：SSD，128 GB or above/以上
echo   · Graphics/显卡：Support/支持 DirectX 12 of/的 integrated graphics/集成显卡 sufficient/即可
echo.
echo https://www.microsoft.com/software-download/windows11
start https://www.microsoft.com/software-download/windows11
goto dl

:iso_w11iot
echo Windows 11 IoT Enterprise edition/企业版 LTSC 2024
echo · Minimum requirements/最低要求（Preferred）
echo   · CPU：1 GHz，2 core/核
echo   · Memory/内存：2 GB
echo   · Storage/存储：16 GB
echo   · Firmware/固件：BIOS sufficient/即可
echo   · Security/安全：TPM optional/可选，Secure Boot/安全启动 optional/可选
echo   · Graphics/显卡：no/无 DirectX requirement/要求
echo   · Display/显示：custom/自定义 size/大小，or/或 no need/无需 monitor/显示器
echo · Recommended requirements/推荐要求（Optional）
echo   · CPU：1 GHz，2 core/核
echo   · Memory/内存：4 GB
echo   · Storage/存储：64 GB SSD
echo   · Firmware/固件：UEFI
echo   · Security/安全：TPM 2.0，Secure Boot/安全启动 enabled/已启用
echo   · Graphics/显卡：DirectX 12
echo   · Display/显示：9 inch/英寸 diagonal/对角线，720p HD
echo.
echo https://next.itellyou.cn/Original/Index#cbp=Product?ID=42e87ac8-9cd6-eb11-bdf8-e0d4e850c9c6
start https://next.itellyou.cn/Original/Index#cbp=Product?ID=42e87ac8-9cd6-eb11-bdf8-e0d4e850c9c6
goto dl

:iso_mint
echo Linux Mint 22.3 Xfce
echo · Minimum requirements/最低要求
echo   · CPU：64 bit/位 x86 processor/处理器
echo   · Memory/内存：2 GB
echo   · Disk/硬盘：20 GB usable space/可用空间
echo   · Graphics/显卡：Support/支持 open-source/开源 driver/驱动 of/的 integrated graphics/集成显卡 sufficient/即可，resolution/分辨率 1024×768
echo · Recommended requirements/推荐要求
echo   · CPU：dual-core/双核 2 GHz or above/及以上
echo   · Memory/内存：4 GB+
echo   · Disk/硬盘：100 GB
echo   · Graphics/显卡：Support/支持 open-source/开源 driver/驱动 of/的 integrated graphics/集成显卡 sufficient/即可
echo.
echo https://linuxmint.com/edition.php?id=327
start https://linuxmint.com/edition.php?id=327
goto dl

:iso_lubuntu
echo Lubuntu 26.04 LTS
echo · Minimum requirements/最低要求（release notes）
echo   · CPU：1.5 GHz dual-core/双核
echo   · Memory/内存：2 GB
echo   · Disk/硬盘：20 GB usable space/可用空间
echo   · Graphics/显卡：resolution/分辨率 1024×768
echo · Recommended requirements/推荐要求
echo   · CPU：4 core/核 64 bit/位 processor/处理器
echo   · Memory/内存：4 GB or above/及以上
echo   · Disk/硬盘：40 GB SSD
echo   · Graphics/显卡：resolution/分辨率 1920×1080
echo.
echo https://cdimage.ubuntu.com/lubuntu/releases/26.04/release/
start https://cdimage.ubuntu.com/lubuntu/releases/26.04/release/
goto dl

:end
echo Script ended。
pause