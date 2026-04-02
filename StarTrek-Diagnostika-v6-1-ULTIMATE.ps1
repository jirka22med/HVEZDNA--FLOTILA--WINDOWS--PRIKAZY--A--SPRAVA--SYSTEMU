# ============================================================
# HVEZDNA FLOTILA - DIAGNOSTICKY SKRIPT v3.1 ULTIMATE
# Vice admiral Jirik | Kompletni systemovy skener Windows 11
# Export: HTML Report - Star Trek LCARS styl
# v3.1 CHANGELOG:
#   - Get-WmiObject → Get-CimInstance (cele)
#   - ID 153 opraveno: Disk IO chyby (ne VBS)
#   - Kernel Power alert bez "VBS podezreni"
#   - HVCI podminka vazana na VBS stav
#   - Pridano: "Hodin bez crashe" do dashboardu
#   - Pridano: C-States stav do BIOS sekce
#   - Pridano: AMD PSP stav do BIOS sekce
# ============================================================

$ExportPath = "C:\Users\jirme\Desktop\export-slozka-pro-pokrocily-script-poweshale"
$ReportFile = "$ExportPath\StarTrek-Diagnostika-v3-$(Get-Date -Format 'yyyy-MM-dd_HH-mm').html"
$StartTime = Get-Date

If (!(Test-Path $ExportPath)) { New-Item -ItemType Directory -Path $ExportPath -Force | Out-Null }

function Write-Status { param($msg, $color="Cyan") Write-Host "  $msg" -ForegroundColor $color }

Write-Host ""
Write-Host "🖖 HVEZDNA FLOTILA v3.1 ULTIMATE - Spoustim kompletni diagnostiku..." -ForegroundColor Cyan
Write-Host ""

# ============================================================
# [1] HARDWARE - OPRAVA: Get-WmiObject → Get-CimInstance
# ============================================================
Write-Status "[01/16] Hardware – CPU, RAM, GPU, Disky..." "Yellow"
$CPU = Get-CimInstance Win32_Processor | Select-Object Name, NumberOfCores, NumberOfLogicalProcessors, MaxClockSpeed, CurrentClockSpeed, LoadPercentage, L2CacheSize, L3CacheSize
$RAM_Total = [math]::Round((Get-CimInstance Win32_ComputerSystem).TotalPhysicalMemory / 1GB, 2)
$RAM_Free  = [math]::Round((Get-CimInstance Win32_OperatingSystem).FreePhysicalMemory / 1MB, 2)
$GPU = Get-CimInstance Win32_VideoController | Select-Object Name, AdapterRAM, DriverVersion, VideoModeDescription, CurrentRefreshRate, CurrentHorizontalResolution, CurrentVerticalResolution
$Disks = Get-CimInstance Win32_LogicalDisk | Where-Object {$_.DriveType -eq 3} | Select-Object DeviceID,
    @{N="Size_GB";E={[math]::Round($_.Size/1GB,1)}},
    @{N="Free_GB";E={[math]::Round($_.FreeSpace/1GB,1)}},
    @{N="Used_Pct";E={[math]::Round((($_.Size-$_.FreeSpace)/$_.Size)*100,1)}},
    VolumeName, FileSystem
$OS  = Get-CimInstance Win32_OperatingSystem | Select-Object Caption, Version, BuildNumber, OSArchitecture, LastBootUpTime, SystemDirectory, WindowsDirectory
$MB  = Get-CimInstance Win32_BaseBoard | Select-Object Manufacturer, Product, Version, SerialNumber
$Comp = Get-CimInstance Win32_ComputerSystem | Select-Object Name, Domain, Manufacturer, Model, SystemType, NumberOfProcessors, TotalPhysicalMemory

# ============================================================
# [2] RAM MODULY - OPRAVA: Get-WmiObject → Get-CimInstance
# ============================================================
Write-Status "[02/16] RAM moduly – sloty, frekvence..." "Yellow"
$RAMModules = Get-CimInstance Win32_PhysicalMemory | Select-Object BankLabel, DeviceLocator,
    @{N="Size_GB";E={[math]::Round($_.Capacity/1GB,1)}},
    Speed, Manufacturer, PartNumber, MemoryType, FormFactor, DataWidth

# ============================================================
# [3] BIOS & FIRMWARE - OPRAVA: Get-WmiObject → Get-CimInstance
# ============================================================
Write-Status "[03/16] BIOS & Firmware..." "Yellow"
$BIOS = Get-CimInstance Win32_BIOS | Select-Object Manufacturer, Name, Version, ReleaseDate, SMBIOSBIOSVersion, SMBIOSMajorVersion, SMBIOSMinorVersion, SerialNumber
$UEFI = try { Confirm-SecureBootUEFI -ErrorAction SilentlyContinue } catch { "N/A" }

# ============================================================
# [4] TPM, VBS, SECURE BOOT + NOVE: C-States, AMD PSP
# ============================================================
Write-Status "[04/16] TPM, VBS, Secure Boot, Defender, C-States, AMD PSP..." "Yellow"
$TPM = try { Get-Tpm -ErrorAction SilentlyContinue } catch { $null }
$VBS_Status = Get-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Control\DeviceGuard" -ErrorAction SilentlyContinue
$VBS_HVCI = Get-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Control\DeviceGuard\Scenarios\HypervisorEnforcedCodeIntegrity" -ErrorAction SilentlyContinue
$SecureBoot = try { Confirm-SecureBootUEFI -ErrorAction SilentlyContinue } catch { "Nedostupne" }
$DefenderStatus = Get-MpComputerStatus -ErrorAction SilentlyContinue | Select-Object AMServiceEnabled, AntispywareEnabled, AntivirusEnabled, RealTimeProtectionEnabled, IoavProtectionEnabled, OnAccessProtectionEnabled, AMEngineVersion, AntivirusSignatureLastUpdated, QuickScanAge, FullScanAge

# NOVE v3.1: C-States stav
$CStatesRaw = powercfg -query SCHEME_CURRENT SUB_PROCESSOR IDLEDISABLE 2>&1 | Out-String
$CStatesDisabled = $CStatesRaw -match "0x00000001"
$CStatesStatus = if ($CStatesDisabled) { "VYPNUTO (doporuceno)" } else { "ZAPNUTO" }

# NOVE v3.1: AMD PSP / TPM stav z registry
$AMDPSPKey = Get-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Services\TPM" -ErrorAction SilentlyContinue
$AMDPSPStatus = if ($TPM -and $TPM.TpmPresent) { "AKTIVNI" } else { "VYPNUTO (BIOS)" }

# ============================================================
# [5] BATERIE & NAPAJENI - OPRAVA: Get-WmiObject → Get-CimInstance
# ============================================================
Write-Status "[05/16] Baterie & napajeni..." "Yellow"
$Battery = Get-CimInstance Win32_Battery -ErrorAction SilentlyContinue | Select-Object Name, EstimatedChargeRemaining, BatteryStatus, EstimatedRunTime, DesignCapacity, FullChargeCapacity
$PowerPlan = Get-CimInstance -Namespace root\cimv2\power -ClassName Win32_PowerPlan -ErrorAction SilentlyContinue | Where-Object {$_.IsActive -eq $true} | Select-Object ElementName, Description

# ============================================================
# [6] TEPLOTY & VENTILATORY - OPRAVA: Get-WmiObject → Get-CimInstance
# ============================================================
Write-Status "[06/16] Teploty & ventilatory (WMI)..." "Yellow"
$Temps = Get-CimInstance -Namespace "root/wmi" -ClassName MSAcpi_ThermalZoneTemperature -ErrorAction SilentlyContinue | Select-Object InstanceName, @{N="Temp_C";E={[math]::Round($_.CurrentTemperature/10 - 273.15, 1)}}
$Fans = Get-CimInstance Win32_Fan -ErrorAction SilentlyContinue
$CoolingDevices = Get-CimInstance Win32_CoolingDevice -ErrorAction SilentlyContinue

# ============================================================
# [7] SYSTEM LOGY
# OPRAVA: ID 153 = Disk IO chyby (NE VBS!)
# OPRAVA: Kernel Power alert bez "VBS podezreni"
# NOVE: Cas od posledniho crashe
# ============================================================
Write-Status "[07/16] System logy – chyby, Kernel Power, Disk IO..." "Yellow"
$EventErrors = Get-WinEvent -LogName System -MaxEvents 1000 -ErrorAction SilentlyContinue |
    Where-Object {$_.Level -le 2} | Select-Object -First 50 TimeCreated, Id, LevelDisplayName, Message |
    ForEach-Object { $_.Message = (($_.Message -split "`n")[0]) -replace '"',"'" -replace '<','&lt;' -replace '>','&gt;'; $_ }

$KernelPower = Get-WinEvent -LogName System -ErrorAction SilentlyContinue |
    Where-Object {$_.Id -eq 41} | Select-Object -First 15 TimeCreated, Id, Message |
    ForEach-Object { $_.Message = ($_.Message -split "`n")[0]; $_ }

$AppErrors = Get-WinEvent -LogName Application -MaxEvents 500 -ErrorAction SilentlyContinue |
    Where-Object {$_.Level -le 2} | Select-Object -First 30 TimeCreated, Id, LevelDisplayName, Message |
    ForEach-Object { $_.Message = (($_.Message -split "`n")[0]) -replace '"',"'" -replace '<','&lt;' -replace '>','&gt;'; $_ }

# OPRAVA v3.1: ID 153 = Disk IO retry chyby, PREJMENOVANO
$DiskIOEvents = Get-WinEvent -LogName System -ErrorAction SilentlyContinue |
    Where-Object {$_.Id -eq 153} | Select-Object -First 15 TimeCreated, Id, Message |
    ForEach-Object { $_.Message = ($_.Message -split "`n")[0]; $_ }

# NOVE v3.1: Skutecne VBS eventy (ID 124)
$VBSEvents = Get-WinEvent -LogName System -ErrorAction SilentlyContinue |
    Where-Object {$_.Id -eq 124} | Select-Object -First 10 TimeCreated, Id, Message |
    ForEach-Object { $_.Message = ($_.Message -split "`n")[0]; $_ }

# NOVE v3.1: Vypocet hodin bez crashe
$LastCrash = ($KernelPower | Sort-Object TimeCreated -Descending | Select-Object -First 1).TimeCreated
$HoursSinceCrash = if ($LastCrash) {
    [math]::Round((New-TimeSpan -Start $LastCrash -End (Get-Date)).TotalHours, 1)
} else { "N/A" }
$DaysSinceCrash = if ($LastCrash) {
    [math]::Round((New-TimeSpan -Start $LastCrash -End (Get-Date)).TotalDays, 1)
} else { "N/A" }

# ============================================================
# [8] SECURITY LOG
# ============================================================
Write-Status "[08/16] Security log – prihlaseni & udalosti..." "Yellow"
$SecEvents = Get-WinEvent -LogName Security -MaxEvents 200 -ErrorAction SilentlyContinue |
    Where-Object {$_.Id -in @(4624,4625,4634,4648,4720,4726,4732)} |
    Select-Object -First 30 TimeCreated, Id, Message |
    ForEach-Object {
        $desc = switch ($_.Id) {
            4624 { "Prihlaseni uspesne" } 4625 { "Prihlaseni SELHALO" }
            4634 { "Odhlaseni" } 4648 { "Prihlaseni s jinymy povereni" }
            4720 { "Vytvoreni uctu" } 4726 { "Smazani uctu" }
            4732 { "Pridan do skupiny" } default { "Bezpecnostni udalost" }
        }
        [PSCustomObject]@{ TimeCreated=$_.TimeCreated; Id=$_.Id; Popis=$desc }
    }

# ============================================================
# [9] DRIVERY - OPRAVA: Get-WmiObject → Get-CimInstance
# ============================================================
Write-Status "[09/16] Drivery & problematicke..." "Yellow"
$Drivers = Get-CimInstance Win32_PnPSignedDriver |
    Where-Object {$_.DeviceName -ne $null} |
    Select-Object DeviceName, DriverVersion, DriverDate, Manufacturer, IsSigned |
    Sort-Object DeviceName

# OPRAVA v3.1: Skutecne problematicke drivery (ConfigManagerErrorCode -ne 0 a State Running)
$ProblematicDrivers = Get-CimInstance Win32_PnPEntity |
    Where-Object {
        $_.ConfigManagerErrorCode -ne 0 -and
        $_.ConfigManagerErrorCode -ne $null -and
        $_.DeviceID -ne $null
    } |
    Select-Object Name, ConfigManagerErrorCode, DeviceID

# ============================================================
# [10] PROCESY & SLUZBY
# ============================================================
Write-Status "[10/16] Procesy & sluzby..." "Yellow"
$Processes = Get-Process | Sort-Object CPU -Descending | Select-Object -First 40 Name, Id,
    @{N="CPU_s";E={[math]::Round($_.CPU,2)}},
    @{N="RAM_MB";E={[math]::Round($_.WorkingSet/1MB,1)}},
    @{N="Threads";E={$_.Threads.Count}},
    @{N="Handles";E={$_.HandleCount}},
    Company, Path

$Services = Get-Service | Sort-Object Status | Select-Object Name, DisplayName, Status, StartType,
    @{N="CanStop";E={$_.CanStop}}, @{N="CanPause";E={$_.CanPauseAndContinue}}

# ============================================================
# [11] SIT
# ============================================================
Write-Status "[11/16] Sit – adaptery, spojeni, porty, statistiky..." "Yellow"
$NetAdapters = Get-NetAdapter | Select-Object Name, Status, LinkSpeed, MacAddress, InterfaceDescription, DriverVersion, DriverDate
$NetConnections = Get-NetTCPConnection | Where-Object {$_.State -eq "Established"} |
    Select-Object -First 30 LocalAddress, LocalPort, RemoteAddress, RemotePort, State, OwningProcess
$ListeningPorts = Get-NetTCPConnection | Where-Object {$_.State -eq "Listen"} |
    Select-Object LocalAddress, LocalPort, State, OwningProcess | Sort-Object LocalPort
$UDPPorts = Get-NetUDPEndpoint | Select-Object -First 20 LocalAddress, LocalPort, OwningProcess
$FirewallRules = Get-NetFirewallRule | Where-Object {$_.Enabled -eq "True"} |
    Select-Object -First 50 DisplayName, Direction, Action, Profile, Enabled
$DNS = Get-DnsClientServerAddress | Where-Object {$_.AddressFamily -eq 2} | Select-Object InterfaceAlias, ServerAddresses
$NetStats = Get-NetAdapterStatistics | Select-Object Name, ReceivedBytes, SentBytes, ReceivedUnicastPackets, SentUnicastPackets, ReceivedDiscardedPackets, OutboundDiscardedPackets
$IPConfig = Get-NetIPAddress | Where-Object {$_.AddressFamily -eq "IPv4" -and $_.IPAddress -ne "127.0.0.1"} | Select-Object InterfaceAlias, IPAddress, PrefixLength, SuffixOrigin

# ============================================================
# [12] SDILENE SLOZKY - OPRAVA: Get-WmiObject → Get-CimInstance
# ============================================================
Write-Status "[12/16] Sdilene slozky & opravneni..." "Yellow"
$Shares = Get-CimInstance Win32_Share | Select-Object Name, Path, Description, Type,
    @{N="MaxAllowed";E={if($_.MaximumAllowed -eq $null){"Neomezeno"}else{$_.MaximumAllowed}}}

# ============================================================
# [13] AUTOSTART
# ============================================================
Write-Status "[13/16] Autostart – registry & scheduled tasks..." "Yellow"
$AutostartReg1 = Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" -ErrorAction SilentlyContinue
$AutostartReg2 = Get-ItemProperty "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" -ErrorAction SilentlyContinue
$AutostartReg3 = Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce" -ErrorAction SilentlyContinue
$AutostartTasks = Get-ScheduledTask | Where-Object {$_.State -ne "Disabled" -and $_.TaskPath -notlike "\Microsoft\*"} |
    Select-Object TaskName, TaskPath, State, @{N="Author";E={$_.Principal.UserId}}

# ============================================================
# [14] WINDOWS UPDATE - OPRAVA: Get-WmiObject → Get-CimInstance
# ============================================================
Write-Status "[14/16] Windows Update..." "Yellow"
$Updates = Get-HotFix | Sort-Object InstalledOn -Descending | Select-Object -First 30 HotFixID, Description, InstalledOn, InstalledBy

# ============================================================
# [15] PROGRAMY
# ============================================================
Write-Status "[15/16] Instalovane programy..." "Yellow"
$Programs = @()
$Programs += Get-ItemProperty "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*" -ErrorAction SilentlyContinue |
    Where-Object {$_.DisplayName -ne $null} |
    Select-Object DisplayName, DisplayVersion, Publisher, InstallDate, EstimatedSize |
    Sort-Object DisplayName
$Programs += Get-ItemProperty "HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*" -ErrorAction SilentlyContinue |
    Where-Object {$_.DisplayName -ne $null} |
    Select-Object DisplayName, DisplayVersion, Publisher, InstallDate, EstimatedSize |
    Sort-Object DisplayName

# ============================================================
# [16] UZIVATELE & SKUPINY
# ============================================================
Write-Status "[16/16] Uzivatele & skupiny..." "Yellow"
$LocalUsers = Get-LocalUser | Select-Object Name, Enabled, LastLogon, PasswordLastSet, PasswordRequired, AccountExpires, Description
$LocalGroups = Get-LocalGroup | Select-Object Name, Description
$AdminMembers = try { Get-LocalGroupMember -Group "Administrators" -ErrorAction SilentlyContinue | Select-Object Name, PrincipalSource, ObjectClass } catch { $null }

$EndTime = Get-Date
$ScanDuration = [math]::Round(($EndTime - $StartTime).TotalSeconds, 1)

Write-Host ""
Write-Host "  ✅ Vsechna data sesbirana za $ScanDuration sekund" -ForegroundColor Green
Write-Host "  🖥️  Generuji LCARS HTML report..." -ForegroundColor Cyan

# ============================================================
# VYPOCET SKORE ZDRAVI SYSTEMU
# ============================================================
$HealthScore = 100
$HealthIssues = @()

# Disky
foreach ($d in $Disks) {
    if ($d.Used_Pct -gt 90) { $HealthScore -= 15; $HealthIssues += "⚠️ Disk $($d.DeviceID) je z $($d.Used_Pct)% plny!" }
    elseif ($d.Used_Pct -gt 80) { $HealthScore -= 8; $HealthIssues += "⚡ Disk $($d.DeviceID) je z $($d.Used_Pct)% plny" }
}
# Kernel Power pady
if ($KernelPower.Count -gt 10) { $HealthScore -= 20; $HealthIssues += "🔴 $($KernelPower.Count)x Kernel Power pad – vazny problem!" }
elseif ($KernelPower.Count -gt 5) { $HealthScore -= 12; $HealthIssues += "⚠️ $($KernelPower.Count)x Kernel Power pad" }
elseif ($KernelPower.Count -gt 0) { $HealthScore -= 6; $HealthIssues += "⚡ $($KernelPower.Count)x Kernel Power pad" }
# Disk IO chyby (ID 153)
if ($DiskIOEvents.Count -gt 10) { $HealthScore -= 10; $HealthIssues += "⚠️ $($DiskIOEvents.Count)x Disk IO chyba (ID 153) – mozny problem s diskem!" }
elseif ($DiskIOEvents.Count -gt 0) { $HealthScore -= 5; $HealthIssues += "⚡ $($DiskIOEvents.Count)x Disk IO chyba (ID 153)" }
# Problematicke drivery
if ($ProblematicDrivers.Count -gt 0) { $HealthScore -= 10; $HealthIssues += "⚠️ $($ProblematicDrivers.Count) problematicky driver" }
# VBS
if ($VBS_Status.EnableVirtualizationBasedSecurity -eq 1) { $HealthScore -= 5; $HealthIssues += "⚡ VBS zapnuto – mozny zdroj padu" }
# RAM
$RAM_UsedPct = [math]::Round((($RAM_Total - $RAM_Free) / $RAM_Total) * 100, 0)
if ($RAM_UsedPct -gt 85) { $HealthScore -= 10; $HealthIssues += "⚠️ RAM obsazena z $RAM_UsedPct%" }
# System chyby
if ($EventErrors.Count -gt 30) { $HealthScore -= 8; $HealthIssues += "⚠️ Nalezeno $($EventErrors.Count) systemovych chyb" }
# NOVE v3.1: C-States bonus
if ($CStatesDisabled) { $HealthIssues += "✅ C-States vypnuto – system optimalizovan" }
# NOVE v3.1: Cas bez crashe bonus
if ($HoursSinceCrash -ne "N/A" -and $HoursSinceCrash -gt 24) {
    $HealthIssues += "✅ System bezi $DaysSinceCrash dni bez Kernel Power padu"
}

if ($HealthScore -lt 0) { $HealthScore = 0 }
$HealthColor = if ($HealthScore -ge 80) { "#00e676" } elseif ($HealthScore -ge 60) { "#f0c040" } else { "#ef5350" }
$HealthLabel = if ($HealthScore -ge 80) { "BOJESCHOPNY" } elseif ($HealthScore -ge 60) { "POZORNOST" } else { "KRITICKE" }

# ============================================================
# HTML POMOCNE FUNKCE
# ============================================================
function New-TH { param($Headers) $h="<tr>"; foreach($x in $Headers){$h+="<th>$x</th>"}; $h+"</tr>" }

function Fmt-Badge {
    param($val, $true_text="ANO", $false_text="NE")
    if ($val -eq $true -or $val -eq "True" -or $val -eq 1) { "<span class='badge badge-green'>✅ $true_text</span>" }
    else { "<span class='badge badge-red'>❌ $false_text</span>" }
}

# Autostart HTML
$autostartHTML = ""
if ($AutostartReg1) { $AutostartReg1.PSObject.Properties | Where-Object {$_.Name -notlike "PS*"} | ForEach-Object { $autostartHTML += "<tr><td><span class='badge badge-blue'>HKLM RUN</span></td><td>$($_.Name)</td><td>$($_.Value)</td></tr>" } }
if ($AutostartReg2) { $AutostartReg2.PSObject.Properties | Where-Object {$_.Name -notlike "PS*"} | ForEach-Object { $autostartHTML += "<tr><td><span class='badge badge-yellow'>HKCU RUN</span></td><td>$($_.Name)</td><td>$($_.Value)</td></tr>" } }
if ($AutostartReg3) { $AutostartReg3.PSObject.Properties | Where-Object {$_.Name -notlike "PS*"} | ForEach-Object { $autostartHTML += "<tr><td><span class='badge badge-red'>RUNONCE</span></td><td>$($_.Name)</td><td>$($_.Value)</td></tr>" } }
foreach ($task in $AutostartTasks) { $autostartHTML += "<tr><td><span class='badge badge-green'>TASK</span></td><td>$($task.TaskName)</td><td>$($task.TaskPath) | $($task.State) | $($task.Author)</td></tr>" }

# Problematicke drivery HTML
$problDriverHTML = if ($ProblematicDrivers) {
    $ProblematicDrivers | ForEach-Object { "<tr class='danger'><td>$($_.Name)</td><td>$($_.ConfigManagerErrorCode)</td><td style='font-size:0.8em'>$($_.DeviceID)</td></tr>" }
} else { "<tr><td colspan='3' style='color:#00e676;text-align:center;padding:15px;'>✅ Zadne problematicke drivery nalezeny</td></tr>" }
$problDriverHTML = $problDriverHTML -join ""

# Kernel Power HTML - OPRAVA v3.1: bez "VBS podezreni"
$kernelHTML = ($KernelPower | ForEach-Object { "<tr class='danger'><td>$($_.TimeCreated)</td><td>$($_.Id)</td><td>$($_.Message)</td></tr>" }) -join ""
if (!$kernelHTML) { $kernelHTML = "<tr><td colspan='3' style='color:#00e676;text-align:center;padding:15px;'>✅ Zadne Kernel Power pady</td></tr>" }

# OPRAVA v3.1: Disk IO HTML (bylo VBS HTML)
$diskIOHTML = ($DiskIOEvents | ForEach-Object { "<tr class='warning'><td>$($_.TimeCreated)</td><td>$($_.Id)</td><td>$($_.Message)</td></tr>" }) -join ""
if (!$diskIOHTML) { $diskIOHTML = "<tr><td colspan='3' style='color:#00e676;text-align:center;padding:15px;'>✅ Zadne Disk IO chyby (ID 153)</td></tr>" }

# NOVE v3.1: VBS HTML (ID 124 - skutecne VBS eventy)
$vbsHTML = ($VBSEvents | ForEach-Object { "<tr class='warning'><td>$($_.TimeCreated)</td><td>$($_.Id)</td><td>$($_.Message)</td></tr>" }) -join ""
if (!$vbsHTML) { $vbsHTML = "<tr><td colspan='3' style='color:#00e676;text-align:center;padding:15px;'>✅ Zadne VBS eventy (ID 124)</td></tr>" }

# Security HTML
$secHTML = ($SecEvents | ForEach-Object {
    $cls = if ($_.Id -eq 4625) { "danger" } elseif ($_.Id -in @(4720,4726)) { "warning" } else { "" }
    "<tr class='$cls'><td>$($_.TimeCreated)</td><td>$($_.Id)</td><td>$($_.Popis)</td></tr>"
}) -join ""

# Net Stats HTML
$netStatsHTML = ($NetStats | ForEach-Object {
    $rx = [math]::Round($_.ReceivedBytes/1MB, 1)
    $tx = [math]::Round($_.SentBytes/1MB, 1)
    "<tr><td>$($_.Name)</td><td>${rx} MB</td><td>${tx} MB</td><td>$($_.ReceivedUnicastPackets)</td><td>$($_.SentUnicastPackets)</td><td>$(if($_.ReceivedDiscardedPackets -gt 0){"<span class='badge badge-red'>$($_.ReceivedDiscardedPackets)</span>"}else{"<span class='badge badge-green'>0</span>"})</td></tr>"
}) -join ""

# Teploty HTML
$tempHTML = if ($Temps) {
    ($Temps | ForEach-Object {
        $cls = if ($_.Temp_C -gt 85) { "danger" } elseif ($_.Temp_C -gt 70) { "warning" } else { "" }
        "<tr class='$cls'><td>$($_.InstanceName)</td><td>$(if($_.Temp_C -gt 85){"🔴"}elseif($_.Temp_C -gt 70){"🟡"}else{"🟢"}) $($_.Temp_C) °C</td></tr>"
    }) -join ""
} else { "<tr><td colspan='2' style='color:rgba(179,229,252,0.5);text-align:center;padding:15px;'>Teploty nejsou dostupne pres WMI – pouzij HWiNFO64 pro presne hodnoty</td></tr>" }

# RAM Moduly HTML
$ramModHTML = ($RAMModules | ForEach-Object {
    "<tr><td>$($_.DeviceLocator)</td><td>$($_.BankLabel)</td><td><strong>$($_.Size_GB) GB</strong></td><td>$($_.Speed) MHz</td><td>$($_.Manufacturer)</td><td>$($_.PartNumber)</td><td>$($_.DataWidth)-bit</td></tr>"
}) -join ""

# Sdilene slozky HTML
$sharesHTML = ($Shares | ForEach-Object {
    "<tr><td>$($_.Name)</td><td>$($_.Path)</td><td>$($_.Description)</td><td>$($_.MaxAllowed)</td></tr>"
}) -join ""

# Uzivatele HTML
$usersHTML = ($LocalUsers | ForEach-Object {
    $en = if ($_.Enabled) { "<span class='badge badge-green'>✅ Aktivni</span>" } else { "<span class='badge badge-red'>❌ Zakazano</span>" }
    "<tr><td><strong>$($_.Name)</strong></td><td>$en</td><td>$($_.LastLogon)</td><td>$($_.PasswordLastSet)</td><td>$($_.Description)</td></tr>"
}) -join ""

$adminHTML = if ($AdminMembers) {
    ($AdminMembers | ForEach-Object { "<tr class='warning'><td><strong>$($_.Name)</strong></td><td>$($_.PrincipalSource)</td><td>$($_.ObjectClass)</td></tr>" }) -join ""
} else { "<tr><td colspan='3' style='text-align:center;padding:10px;'>Data nedostupna</td></tr>" }

# Listening porty HTML
$listenHTML = ($ListeningPorts | Select-Object -First 40 | ForEach-Object {
    $proc = try { (Get-Process -Id $_.OwningProcess -ErrorAction SilentlyContinue).Name } catch { "?" }
    "<tr><td>$($_.LocalAddress)</td><td><strong>$($_.LocalPort)</strong></td><td>$($_.State)</td><td>$($_.OwningProcess)</td><td>$proc</td></tr>"
}) -join ""

# Health issues HTML
$issuesHTML = if ($HealthIssues.Count -gt 0) {
    ($HealthIssues | ForEach-Object { "<div class='issue-item'>$_</div>" }) -join ""
} else { "<div class='issue-item' style='color:#00e676;'>✅ Zadne kriticke problemy nalezeny!</div>" }

# Disk progress bary pro dashboard
$diskDashHTML = ($Disks | ForEach-Object {
    $cls = if($_.Used_Pct -lt 70){"ok"}elseif($_.Used_Pct -lt 85){"warn"}else{"danger"}
    "<div class='dash-disk'><div style='display:flex;justify-content:space-between;margin-bottom:5px;'><span style='font-family:Orbitron,monospace;font-size:0.75em;color:#f0c040;'>DISK $($_.DeviceID)</span><span style='font-family:Share Tech Mono,monospace;font-size:0.8em;'>$($_.Free_GB) GB volnych z $($_.Size_GB) GB</span></div><div class='progress-bar'><div class='progress-fill $cls' style='width:$($_.Used_Pct)%'></div></div><div style='text-align:right;font-size:0.75em;color:rgba(179,229,252,0.5);margin-top:3px;'>Obsazeno: $($_.Used_Pct)%</div></div>"
}) -join ""

# Power Plan HTML
$powerHTML = if ($PowerPlan) { $PowerPlan.ElementName } else { "Nezjisteno" }

# Battery HTML
$battHTML = if ($Battery) {
    $batPct = $Battery.EstimatedChargeRemaining
    $batCls = if($batPct -gt 50){"ok"}elseif($batPct -gt 20){"warn"}else{"danger"}
    $batStatus = switch ($Battery.BatteryStatus) { 1{"Vybijena"} 2{"Nabijeni AC"} 3{"Plne nabita"} 4{"Nizka"} 5{"Kriticka"} default{"Neznamy"} }
    "<div class='hw-card'><div class='hw-label'>Stav baterie</div><div class='hw-value'>$batStatus</div></div>
     <div class='hw-card'><div class='hw-label'>Nabiti</div><div class='hw-value highlight'>$batPct %</div><div class='progress-bar'><div class='progress-fill $batCls' style='width:$batPct%'></div></div></div>
     <div class='hw-card'><div class='hw-label'>Odhadovany cas</div><div class='hw-value'>$(if($Battery.EstimatedRunTime -and $Battery.EstimatedRunTime -lt 65535){"$($Battery.EstimatedRunTime) min"}else{"N/A"})</div></div>"
} else { "<div class='hw-card'><div class='hw-label'>Baterie</div><div class='hw-value' style='color:rgba(179,229,252,0.5);'>Nenalezena / Desktop PC</div></div>" }

# NOVE v3.1: Cas bez crashe HTML
$crashTimerColor = if ($HoursSinceCrash -eq "N/A") { "#4fc3f7" } elseif ($HoursSinceCrash -gt 72) { "#00e676" } elseif ($HoursSinceCrash -gt 24) { "#f0c040" } else { "#ef5350" }
$crashTimerHTML = if ($HoursSinceCrash -ne "N/A") {
    "<div style='text-align:center;padding:5px 0;'>
      <div style='font-family:Orbitron,monospace;font-size:2em;font-weight:900;color:${crashTimerColor};text-shadow:0 0 15px ${crashTimerColor};'>${HoursSinceCrash}h</div>
      <div style='font-family:Share Tech Mono,monospace;font-size:0.65em;color:rgba(179,229,252,0.5);margin-top:4px;'>BEZ KERNEL POWER PADU</div>
      <div style='font-family:Share Tech Mono,monospace;font-size:0.6em;color:rgba(179,229,252,0.35);margin-top:2px;'>Posledni pad: $($LastCrash.ToString('dd.MM.yyyy HH:mm'))</div>
    </div>"
} else {
    "<div style='text-align:center;color:#00e676;font-family:Orbitron,monospace;font-size:1.2em;padding:10px 0;'>✅ ZADNE PADY V HISTORII</div>"
}

# ============================================================
# GENEROVANI HTML - VZHLED ZACHOVAN 100%
# ============================================================

$HTML = @"
<!DOCTYPE html>
<html lang="cs">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>🖖 Hvezdna Flotila LCARS v3.1 - Vice Admiral Jirik</title>
<style>
  @import url('https://fonts.googleapis.com/css2?family=Orbitron:wght@400;700;900&family=Share+Tech+Mono&family=Exo+2:wght@300;400;600;700&display=swap');

  :root {
    --gold: #f0c040; --blue: #4fc3f7; --red: #ef5350; --green: #00e676;
    --orange: #ff9800; --purple: #ce93d8;
    --bg: #010d1a; --panel: #031524; --border: #0d3a6e;
    --text: #b3e5fc; --text-dim: rgba(179,229,252,0.45);
  }

  * { margin:0; padding:0; box-sizing:border-box; }

  body {
    background: var(--bg);
    color: var(--text);
    font-family: 'Exo 2', sans-serif;
    background-image:
      radial-gradient(ellipse at 15% 40%, rgba(13,58,110,0.2) 0%, transparent 55%),
      radial-gradient(ellipse at 85% 15%, rgba(21,101,192,0.12) 0%, transparent 45%),
      radial-gradient(ellipse at 50% 90%, rgba(13,58,110,0.1) 0%, transparent 50%);
  }

  body::before {
    content:''; position:fixed; inset:0;
    background: repeating-linear-gradient(0deg, transparent, transparent 3px, rgba(0,0,0,0.025) 3px, rgba(0,0,0,0.025) 4px);
    pointer-events:none; z-index:9999;
  }

  .header {
    background: linear-gradient(135deg, #020f1e 0%, #04192d 100%);
    border-bottom: 3px solid var(--gold);
    position: relative; overflow: hidden;
  }
  .header::after {
    content:''; position:absolute; top:0; left:0; right:0; bottom:0;
    background: linear-gradient(90deg, rgba(240,192,64,0.06) 0%, transparent 25%, rgba(79,195,247,0.04) 50%, transparent 75%, rgba(240,192,64,0.04) 100%);
    animation: headerShimmer 6s linear infinite;
  }
  @keyframes headerShimmer { from{background-position:0 0} to{background-position:400px 0} }
  .header-inner { display:flex; align-items:center; padding:18px 35px; gap:20px; position:relative; z-index:1; }
  .header-bars { display:flex; flex-direction:column; gap:4px; }
  .hbar { height:6px; border-radius:3px; box-shadow:0 0 12px currentColor; animation:barPulse 2s ease-in-out infinite; }
  .hbar:nth-child(1) { width:50px; background:var(--gold); color:var(--gold); }
  .hbar:nth-child(2) { width:35px; background:var(--blue); color:var(--blue); animation-delay:0.3s; }
  .hbar:nth-child(3) { width:25px; background:var(--red); color:var(--red); animation-delay:0.6s; }
  @keyframes barPulse { 0%,100%{opacity:1} 50%{opacity:0.5} }
  .header-text { flex:1; }
  .htitle { font-family:'Orbitron',monospace; font-size:2em; font-weight:900; color:var(--gold); text-shadow:0 0 25px rgba(240,192,64,0.7); letter-spacing:3px; }
  .hsub { font-family:'Share Tech Mono',monospace; font-size:0.82em; color:var(--blue); margin-top:5px; letter-spacing:2px; }
  .hmeta { font-family:'Share Tech Mono',monospace; font-size:0.7em; color:var(--text-dim); margin-top:3px; }
  .health-badge { text-align:center; padding:12px 20px; background:rgba(0,0,0,0.3); border:2px solid ${HealthColor}; border-radius:6px; box-shadow:0 0 20px ${HealthColor}40; }
  .health-score { font-family:'Orbitron',monospace; font-size:2.5em; font-weight:900; color:${HealthColor}; text-shadow:0 0 20px ${HealthColor}; line-height:1; }
  .health-label { font-family:'Share Tech Mono',monospace; font-size:0.7em; color:${HealthColor}; margin-top:4px; letter-spacing:2px; }
  .health-sub { font-size:0.65em; color:var(--text-dim); margin-top:2px; }
  .emblem { font-size:3.5em; filter:drop-shadow(0 0 15px rgba(240,192,64,0.8)); animation:float 4s ease-in-out infinite; }
  @keyframes float { 0%,100%{transform:translateY(0)} 50%{transform:translateY(-8px)} }

  .statusbar { background:#010e1c; border-bottom:1px solid rgba(13,58,110,0.6); padding:8px 35px; display:flex; gap:25px; overflow-x:auto; font-family:'Share Tech Mono',monospace; font-size:0.72em; }
  .si { display:flex; align-items:center; gap:6px; white-space:nowrap; }
  .dot { width:7px; height:7px; border-radius:50%; animation:blink 1.5s ease-in-out infinite; }
  .dot.g { background:var(--green); box-shadow:0 0 8px var(--green); }
  .dot.y { background:var(--gold); box-shadow:0 0 8px var(--gold); animation-delay:0.5s; }
  .dot.r { background:var(--red); box-shadow:0 0 8px var(--red); animation-delay:1s; }
  .dot.b { background:var(--blue); box-shadow:0 0 8px var(--blue); animation-delay:0.25s; }
  @keyframes blink { 0%,100%{opacity:1} 50%{opacity:0.25} }

  .nav { background:#010c18; border-bottom:2px solid var(--border); padding:0 35px; display:flex; gap:2px; overflow-x:auto; position:sticky; top:0; z-index:100; flex-wrap:nowrap; }
  .tab { font-family:'Orbitron',monospace; font-size:0.58em; font-weight:700; padding:11px 14px; cursor:pointer; border:none; background:transparent; color:var(--text-dim); letter-spacing:1px; text-transform:uppercase; border-bottom:3px solid transparent; transition:all 0.25s; white-space:nowrap; }
  .tab:hover { color:var(--blue); background:rgba(79,195,247,0.05); }
  .tab.active { color:var(--gold); border-bottom-color:var(--gold); background:rgba(240,192,64,0.06); }

  .content { padding:25px 35px; }
  .section { display:none; }
  .section.active { display:block; animation:fadeUp 0.3s ease; }
  @keyframes fadeUp { from{opacity:0;transform:translateY(8px)} to{opacity:1;transform:translateY(0)} }

  .panel { background:var(--panel); border:1px solid var(--border); border-radius:3px; margin-bottom:20px; overflow:hidden; position:relative; }
  .panel::before { content:''; position:absolute; top:0; left:0; right:0; height:1px; background:linear-gradient(90deg, transparent, var(--blue)60, transparent); }
  .ph { background:linear-gradient(90deg, rgba(13,58,110,0.5), rgba(3,21,36,0.9)); padding:10px 18px; display:flex; align-items:center; gap:10px; border-bottom:1px solid rgba(13,58,110,0.4); }
  .pi { font-size:1.1em; }
  .pt { font-family:'Orbitron',monospace; font-size:0.75em; font-weight:700; color:var(--gold); letter-spacing:2px; text-transform:uppercase; }
  .pc { margin-left:auto; font-family:'Share Tech Mono',monospace; font-size:0.7em; color:var(--blue); background:rgba(79,195,247,0.1); padding:2px 8px; border-radius:2px; border:1px solid rgba(79,195,247,0.25); }

  .hgrid { display:grid; grid-template-columns:repeat(auto-fit,minmax(240px,1fr)); gap:12px; padding:16px; }
  .hcard { background:rgba(2,15,28,0.8); border:1px solid rgba(13,58,110,0.35); border-radius:3px; padding:13px; position:relative; overflow:hidden; }
  .hcard::after { content:''; position:absolute; top:0; left:0; width:3px; height:100%; background:var(--gold); box-shadow:0 0 8px rgba(240,192,64,0.4); }
  .hl { font-family:'Share Tech Mono',monospace; font-size:0.65em; color:var(--text-dim); text-transform:uppercase; letter-spacing:2px; margin-bottom:4px; }
  .hv { font-size:0.9em; font-weight:600; color:var(--text); word-break:break-word; }
  .hv.big { color:var(--gold); font-size:1.2em; font-family:'Orbitron',monospace; }

  .pb { background:rgba(13,58,110,0.3); border-radius:2px; height:5px; margin-top:7px; overflow:hidden; }
  .pf { height:100%; border-radius:2px; transition:width 1.2s cubic-bezier(0.4,0,0.2,1); box-shadow:0 0 8px currentColor; }
  .pf.ok { background:var(--green); color:var(--green); }
  .pf.warn { background:var(--gold); color:var(--gold); }
  .pf.danger { background:var(--red); color:var(--red); }

  .tw { overflow-x:auto; }
  table { width:100%; border-collapse:collapse; font-family:'Share Tech Mono',monospace; font-size:0.75em; }
  th { background:rgba(13,58,110,0.45); color:var(--blue); padding:9px 11px; text-align:left; font-family:'Orbitron',monospace; font-size:0.65em; letter-spacing:1px; text-transform:uppercase; border-bottom:1px solid var(--border); white-space:nowrap; }
  td { padding:7px 11px; border-bottom:1px solid rgba(13,58,110,0.18); color:var(--text); vertical-align:top; word-break:break-word; max-width:350px; }
  tr:hover td { background:rgba(79,195,247,0.04); }
  tr.danger td { background:rgba(239,83,80,0.08) !important; border-left:2px solid var(--red); }
  tr.warning td { background:rgba(240,192,64,0.06) !important; border-left:2px solid var(--gold); }

  .badge { display:inline-block; padding:2px 7px; border-radius:2px; font-size:0.8em; font-weight:600; white-space:nowrap; }
  .badge-green { background:rgba(0,230,118,0.12); color:var(--green); border:1px solid rgba(0,230,118,0.3); }
  .badge-red { background:rgba(239,83,80,0.12); color:var(--red); border:1px solid rgba(239,83,80,0.3); }
  .badge-yellow { background:rgba(240,192,64,0.12); color:var(--gold); border:1px solid rgba(240,192,64,0.3); }
  .badge-blue { background:rgba(79,195,247,0.12); color:var(--blue); border:1px solid rgba(79,195,247,0.3); }
  .badge-purple { background:rgba(206,147,216,0.12); color:var(--purple); border:1px solid rgba(206,147,216,0.3); }

  .alert { margin:12px 18px; padding:10px 14px; border-radius:3px; font-family:'Share Tech Mono',monospace; font-size:0.78em; display:flex; align-items:center; gap:8px; }
  .alert.info { background:rgba(79,195,247,0.08); border:1px solid rgba(79,195,247,0.3); color:var(--blue); }
  .alert.danger { background:rgba(239,83,80,0.08); border:1px solid rgba(239,83,80,0.3); color:var(--red); }
  .alert.success { background:rgba(0,230,118,0.08); border:1px solid rgba(0,230,118,0.3); color:var(--green); }
  .alert.warn { background:rgba(240,192,64,0.08); border:1px solid rgba(240,192,64,0.3); color:var(--gold); }

  .dash-grid { display:grid; grid-template-columns:repeat(auto-fit,minmax(160px,1fr)); gap:12px; padding:16px; }
  .dash-card { background:rgba(2,15,28,0.9); border:1px solid var(--border); border-radius:4px; padding:15px; text-align:center; position:relative; overflow:hidden; transition:transform 0.2s, box-shadow 0.2s; }
  .dash-card:hover { transform:translateY(-2px); box-shadow:0 4px 20px rgba(79,195,247,0.15); }
  .dash-card::before { content:''; position:absolute; bottom:0; left:0; right:0; height:2px; background:var(--gold); box-shadow:0 0 10px var(--gold); }
  .dash-icon { font-size:1.8em; margin-bottom:8px; }
  .dash-val { font-family:'Orbitron',monospace; font-size:1.4em; font-weight:900; color:var(--gold); }
  .dash-lbl { font-family:'Share Tech Mono',monospace; font-size:0.65em; color:var(--text-dim); margin-top:4px; text-transform:uppercase; letter-spacing:1px; }

  .issues-panel { margin:12px 18px; }
  .issue-item { padding:7px 12px; border-left:3px solid var(--gold); margin-bottom:6px; background:rgba(240,192,64,0.05); font-family:'Share Tech Mono',monospace; font-size:0.8em; border-radius:0 3px 3px 0; }

  .dash-disk { padding:0 18px 12px; }

  .footer { background:#010c18; border-top:2px solid var(--gold); padding:12px 35px; display:flex; justify-content:space-between; align-items:center; font-family:'Share Tech Mono',monospace; font-size:0.68em; color:var(--text-dim); flex-wrap:wrap; gap:8px; }

  ::-webkit-scrollbar { width:5px; height:5px; }
  ::-webkit-scrollbar-track { background:#010d1a; }
  ::-webkit-scrollbar-thumb { background:var(--border); border-radius:3px; }
  ::-webkit-scrollbar-thumb:hover { background:var(--blue); }

  /* NOVE v3.1: Crash timer karta */
  .crash-timer-card { background:rgba(2,15,28,0.9); border:1px solid var(--border); border-radius:4px; padding:15px; position:relative; overflow:hidden; }
  .crash-timer-card::before { content:''; position:absolute; bottom:0; left:0; right:0; height:2px; background:${crashTimerColor}; box-shadow:0 0 10px ${crashTimerColor}; }
</style>
</head>
<body>

<!-- HEADER -->
<div class="header">
  <div class="header-inner">
    <div class="header-bars">
      <div class="hbar"></div><div class="hbar"></div><div class="hbar"></div>
    </div>
    <div class="header-text">
      <div class="htitle">HVEZDNA FLOTILA // LCARS v3.1</div>
      <div class="hsub">KOMPLETNI SYSTEMOVA DIAGNOSTIKA — VICE ADMIRAL JIRIK</div>
      <div class="hmeta">SKENOVANO: $(Get-Date -Format 'dd.MM.yyyy HH:mm:ss') &nbsp;|&nbsp; TRVANI: ${ScanDuration}s &nbsp;|&nbsp; STANICE: $env:COMPUTERNAME &nbsp;|&nbsp; OPERATOR: $env:USERNAME</div>
    </div>
    <div class="health-badge">
      <div class="health-score">$HealthScore</div>
      <div class="health-label">$HealthLabel</div>
      <div class="health-sub">SKORE ZDRAVI</div>
    </div>
    <div class="emblem">🖖</div>
  </div>
</div>

<!-- STATUS BAR -->
<div class="statusbar">
  <div class="si"><div class="dot g"></div> WARP: ONLINE</div>
  <div class="si"><div class="dot $(if($KernelPower.Count -gt 5){'r'}elseif($KernelPower.Count -gt 0){'y'}else{'g'})"></div> KERNEL PADY: $($KernelPower.Count)</div>
  <div class="si"><div class="dot $(if($ProblematicDrivers.Count -gt 0){'r'}else{'g'})"></div> DRIVERY: $(if($ProblematicDrivers.Count -gt 0){"$($ProblematicDrivers.Count) PROBLEMY"}else{"OK"})</div>
  <div class="si"><div class="dot g"></div> CPU: $($CPU.Name.Split(' ')[0..2] -join ' ')</div>
  <div class="si"><div class="dot $(if($RAM_UsedPct -gt 85){'r'}elseif($RAM_UsedPct -gt 70){'y'}else{'g'})"></div> RAM: $RAM_UsedPct% OBSAZENA</div>
  <div class="si"><div class="dot $(if(($Disks | Where-Object {$_.Used_Pct -gt 90}).Count -gt 0){'r'}else{'y'})"></div> DISKY: $(($Disks | Where-Object {$_.Used_Pct -gt 80}).Count) KRITICKE</div>
  <div class="si"><div class="dot g"></div> PROCESY: $($Processes.Count)</div>
  <div class="si"><div class="dot b"></div> SLUZBY: $($Services.Count)</div>
  <div class="si"><div class="dot g"></div> PROGRAMY: $($Programs.Count)</div>
  <div class="si"><div class="dot $(if($VBS_Status.EnableVirtualizationBasedSecurity -eq 1){'y'}else{'g'})"></div> VBS: $(if($VBS_Status.EnableVirtualizationBasedSecurity -eq 1){"ZAPNUTO"}else{"VYPNUTO"})</div>
  <div class="si"><div class="dot $(if($CStatesDisabled){'g'}else{'y'})"></div> C-STATES: $(if($CStatesDisabled){"VYPNUTO"}else{"ZAPNUTO"})</div>
  <div class="si"><div class="dot $(if($HoursSinceCrash -eq 'N/A' -or $HoursSinceCrash -gt 24){'g'}else{'r'})"></div> BEZ PADU: ${HoursSinceCrash}h</div>
</div>

<!-- NAV -->
<div class="nav">
  <button class="tab active" onclick="show('dashboard',this)">🏠 Dashboard</button>
  <button class="tab" onclick="show('hardware',this)">⚡ Hardware</button>
  <button class="tab" onclick="show('ram',this)">🧠 RAM Moduly</button>
  <button class="tab" onclick="show('bios',this)">🔩 BIOS & Security</button>
  <button class="tab" onclick="show('baterie',this)">🔋 Baterie</button>
  <button class="tab" onclick="show('teploty',this)">🌡️ Teploty</button>
  <button class="tab" onclick="show('logy',this)">📋 Logy</button>
  <button class="tab" onclick="show('security',this)">🔐 Security Log</button>
  <button class="tab" onclick="show('drivery',this)">🔧 Drivery</button>
  <button class="tab" onclick="show('procesy',this)">⚙️ Procesy</button>
  <button class="tab" onclick="show('sluzby',this)">🛡️ Sluzby</button>
  <button class="tab" onclick="show('sit',this)">🌐 Sit</button>
  <button class="tab" onclick="show('porty',this)">🔌 Porty</button>
  <button class="tab" onclick="show('sdileni',this)">📂 Sdileni</button>
  <button class="tab" onclick="show('autostart',this)">🚀 Autostart</button>
  <button class="tab" onclick="show('updates',this)">🔄 Updates</button>
  <button class="tab" onclick="show('programy',this)">📦 Programy</button>
  <button class="tab" onclick="show('uzivatele',this)">👤 Uzivatele</button>
</div>

<div class="content">

<!-- ===== DASHBOARD ===== -->
<div id="dashboard" class="section active">

  <!-- NOVE v3.1: Crash timer panel -->
  <div class="panel">
    <div class="ph"><span class="pi">⏱️</span><span class="pt">Stabilita systemu – cas bez Kernel Power padu</span><span class="pc" style="color:${crashTimerColor}">POSLEDNI PAD: $(if($LastCrash){$LastCrash.ToString('dd.MM.yyyy HH:mm')}else{"ZADNY"})</span></div>
    <div class="hgrid">
      <div class="hcard" style="grid-column:span 2">$crashTimerHTML</div>
      <div class="hcard"><div class="hl">Celkem Kernel Power padu</div><div class="hv big" style="color:$(if($KernelPower.Count -eq 0){'#00e676'}elseif($KernelPower.Count -lt 5){'#f0c040'}else{'#ef5350'})">$($KernelPower.Count)x</div></div>
      <div class="hcard"><div class="hl">Disk IO chyby (ID 153)</div><div class="hv big" style="color:$(if($DiskIOEvents.Count -eq 0){'#00e676'}elseif($DiskIOEvents.Count -lt 5){'#f0c040'}else{'#ef5350'})">$($DiskIOEvents.Count)x</div></div>
    </div>
  </div>

  <div class="panel">
    <div class="ph"><span class="pi">🔵</span><span class="pt">Procesor</span></div>
    <div class="hgrid">
      <div class="hcard"><div class="hl">Model</div><div class="hv">$($CPU.Name)</div></div>
      <div class="hcard"><div class="hl">Jadra / Vlakna</div><div class="hv big">$($CPU.NumberOfCores) / $($CPU.NumberOfLogicalProcessors)</div></div>
      <div class="hcard"><div class="hl">Max frekvence</div><div class="hv big">$($CPU.MaxClockSpeed) MHz</div></div>
      <div class="hcard"><div class="hl">Aktualni frekvence</div><div class="hv">$($CPU.CurrentClockSpeed) MHz</div></div>
    </div>
  </div>

  <div class="panel">
    <div class="ph"><span class="pi">🔴</span><span class="pt">Pamet RAM</span></div>
    <div class="hgrid">
      <div class="hcard"><div class="hl">Celkova RAM</div><div class="hv big">${RAM_Total} GB</div></div>
      <div class="hcard"><div class="hl">Volna RAM</div><div class="hv">${RAM_Free} GB<div class="pb"><div class="pf ok" style="width:$([math]::Round(($RAM_Free/$RAM_Total)*100,0))%"></div></div></div></div>
      <div class="hcard"><div class="hl">Obsazena RAM</div><div class="hv">$([math]::Round($RAM_Total-$RAM_Free,2)) GB ($RAM_UsedPct%)<div class="pb"><div class="pf $(if($RAM_UsedPct -lt 60){'ok'}elseif($RAM_UsedPct -lt 80){'warn'}else{'danger'})" style="width:${RAM_UsedPct}%"></div></div></div></div>
    </div>
  </div>

  <div class="panel">
    <div class="ph"><span class="pi">🟡</span><span class="pt">Graficka karta</span><span class="pc">$($GPU.Count) GPU</span></div>
    <div class="hgrid">
      $(foreach ($g in $GPU) {
        $vram = if($g.AdapterRAM -and $g.AdapterRAM -gt 0){[math]::Round($g.AdapterRAM/1GB,1)}else{"N/A"}
        "<div class='hcard'><div class='hl'>GPU</div><div class='hv'>$($g.Name)</div></div>
         <div class='hcard'><div class='hl'>VRAM</div><div class='hv big'>${vram} GB</div></div>
         <div class='hcard'><div class='hl'>Driver verze</div><div class='hv'>$($g.DriverVersion)</div></div>
         <div class='hcard'><div class='hl'>Rozliseni</div><div class='hv'>$($g.CurrentHorizontalResolution)x$($g.CurrentVerticalResolution) @ $($g.CurrentRefreshRate)Hz</div></div>"
      })
    </div>
  </div>

  <div class="panel">
    <div class="ph"><span class="pi">🟠</span><span class="pt">Disky</span><span class="pc">$($Disks.Count) disky</span></div>
    <div class="hgrid">
      $(foreach ($d in $Disks) {
        $cls = if($d.Used_Pct -lt 80){"ok"}elseif($d.Used_Pct -lt 90){"warn"}else{"danger"}
        "<div class='hcard' style='grid-column:span 2'>
          <div class='hl'>Disk $($d.DeviceID) $(if($d.VolumeName){"– $($d.VolumeName)"})</div>
          <div class='hv big'>$($d.Free_GB) GB volnych z $($d.Size_GB) GB</div>
          <div style='font-size:0.8em;color:rgba(179,229,252,0.5);margin-top:3px;'>Obsazeno: $($d.Used_Pct)% &nbsp;|&nbsp; $($d.FileSystem)</div>
          <div class='pb' style='margin-top:8px'><div class='pf $cls' style='width:$($d.Used_Pct)%'></div></div>
        </div>"
      })
    </div>
  </div>

  <div class="panel">
    <div class="ph"><span class="pi">🟢</span><span class="pt">Operacni system & Zakladni deska</span></div>
    <div class="hgrid">
      <div class="hcard"><div class="hl">OS</div><div class="hv">$($OS.Caption)</div></div>
      <div class="hcard"><div class="hl">Verze / Build</div><div class="hv big">$($OS.Version) / $($OS.BuildNumber)</div></div>
      <div class="hcard"><div class="hl">Architektura</div><div class="hv">$($OS.OSArchitecture)</div></div>
      <div class="hcard"><div class="hl">Posledni boot</div><div class="hv">$($OS.LastBootUpTime)</div></div>
      <div class="hcard"><div class="hl">Zakladni deska</div><div class="hv">$($MB.Manufacturer) $($MB.Product)</div></div>
      <div class="hcard"><div class="hl">Model pocitace</div><div class="hv">$($Comp.Model)</div></div>
      <div class="hcard"><div class="hl">Napajeci plan</div><div class="hv">$powerHTML</div></div>
      <div class="hcard"><div class="hl">VBS stav</div><div class="hv">$(if($VBS_Status.EnableVirtualizationBasedSecurity -eq 1){"<span class='badge badge-yellow'>⚡ ZAPNUTO</span>"}else{"<span class='badge badge-green'>✅ VYPNUTO</span>"})</div></div>
    </div>
  </div>

  <div class="panel">
    <div class="ph"><span class="pi">⚠️</span><span class="pt">Nalezene problemy & varovani</span><span class="pc" style="color:${HealthColor}">ZDRAVI: $HealthScore / 100 – $HealthLabel</span></div>
    <div class="issues-panel">$issuesHTML</div>
  </div>

</div>

<!-- ===== HARDWARE ===== -->
<div id="hardware" class="section">
  <div class="panel">
    <div class="ph"><span class="pi">⚡</span><span class="pt">Procesor</span></div>
    <div class="hgrid">
      <div class="hcard"><div class="hl">Model</div><div class="hv">$($CPU.Name)</div></div>
      <div class="hcard"><div class="hl">Jadra / Vlakna</div><div class="hv big">$($CPU.NumberOfCores) / $($CPU.NumberOfLogicalProcessors)</div></div>
      <div class="hcard"><div class="hl">Max frekvence</div><div class="hv big">$($CPU.MaxClockSpeed) MHz</div></div>
      <div class="hcard"><div class="hl">Aktualni frekvence</div><div class="hv">$($CPU.CurrentClockSpeed) MHz</div></div>
      <div class="hcard"><div class="hl">Zatizeni CPU</div><div class="hv big">$(if($CPU.LoadPercentage){"$($CPU.LoadPercentage) %"}else{"N/A"})</div></div>
      <div class="hcard"><div class="hl">L2 Cache</div><div class="hv">$(if($CPU.L2CacheSize){"$($CPU.L2CacheSize) KB"}else{"N/A"})</div></div>
      <div class="hcard"><div class="hl">L3 Cache</div><div class="hv">$(if($CPU.L3CacheSize){"$([math]::Round($CPU.L3CacheSize/1024,1)) MB"}else{"N/A"})</div></div>
    </div>
  </div>
  <div class="panel">
    <div class="ph"><span class="pi">🧠</span><span class="pt">Pamet RAM</span></div>
    <div class="hgrid">
      <div class="hcard"><div class="hl">Celkova RAM</div><div class="hv big">${RAM_Total} GB</div></div>
      <div class="hcard"><div class="hl">Volna RAM</div><div class="hv">${RAM_Free} GB<div class="pb"><div class="pf ok" style="width:$([math]::Round(($RAM_Free/$RAM_Total)*100,0))%"></div></div></div></div>
      <div class="hcard"><div class="hl">Obsazena RAM</div><div class="hv">$([math]::Round($RAM_Total-$RAM_Free,2)) GB ($RAM_UsedPct%)<div class="pb"><div class="pf $(if($RAM_UsedPct -lt 60){'ok'}elseif($RAM_UsedPct -lt 80){'warn'}else{'danger'})" style="width:${RAM_UsedPct}%"></div></div></div></div>
    </div>
  </div>
  <div class="panel">
    <div class="ph"><span class="pi">🖥️</span><span class="pt">Graficke karty</span><span class="pc">$($GPU.Count) GPU</span></div>
    <div class="hgrid">
      $(foreach ($g in $GPU) {
        $vram = if($g.AdapterRAM -and $g.AdapterRAM -gt 0){[math]::Round($g.AdapterRAM/1GB,1)}else{"N/A"}
        "<div class='hcard'><div class='hl'>GPU</div><div class='hv'>$($g.Name)</div></div>
         <div class='hcard'><div class='hl'>VRAM</div><div class='hv big'>${vram} GB</div></div>
         <div class='hcard'><div class='hl'>Driver</div><div class='hv'>$($g.DriverVersion)</div></div>
         <div class='hcard'><div class='hl'>Rozliseni</div><div class='hv'>$($g.CurrentHorizontalResolution)x$($g.CurrentVerticalResolution) @ $($g.CurrentRefreshRate)Hz</div></div>"
      })
    </div>
  </div>
  <div class="panel">
    <div class="ph"><span class="pi">💾</span><span class="pt">Disky</span><span class="pc">$($Disks.Count) disky</span></div>
    <div class="tw">
      <table>
        <thead>$(New-TH @("Disk","Objem (GB)","Volne (GB)","Obsazeno %","Nazev","Filesystem"))</thead>
        <tbody>
          $(foreach ($d in $Disks) {
            $cls = if($d.Used_Pct -gt 90){"danger"}elseif($d.Used_Pct -gt 80){"warning"}else{""}
            "<tr class='$cls'><td><strong>$($d.DeviceID)</strong></td><td>$($d.Size_GB)</td><td>$($d.Free_GB)</td><td><div style='display:flex;align-items:center;gap:8px;'>$($d.Used_Pct)%<div class='pb' style='flex:1;min-width:60px'><div class='pf $(if($d.Used_Pct -lt 80){"ok"}elseif($d.Used_Pct -lt 90){"warn"}else{"danger"})' style='width:$($d.Used_Pct)%'></div></div></div></td><td>$($d.VolumeName)</td><td>$($d.FileSystem)</td></tr>"
          })
        </tbody>
      </table>
    </div>
  </div>
</div>

<!-- ===== RAM MODULY ===== -->
<div id="ram" class="section">
  <div class="panel">
    <div class="ph"><span class="pi">🧠</span><span class="pt">Fyzicke RAM moduly</span><span class="pc">$($RAMModules.Count) modulu</span></div>
    <div class="tw">
      <table>
        <thead>$(New-TH @("Slot","Banka","Velikost","Frekvence","Vyrobce","Part Number","Sirka dat"))</thead>
        <tbody>$ramModHTML</tbody>
      </table>
    </div>
  </div>
</div>

<!-- ===== BIOS & SECURITY - NOVE: C-States, AMD PSP ===== -->
<div id="bios" class="section">
  <div class="panel">
    <div class="ph"><span class="pi">🔩</span><span class="pt">BIOS & Firmware</span></div>
    <div class="hgrid">
      <div class="hcard"><div class="hl">Vyrobce BIOS</div><div class="hv">$($BIOS.Manufacturer)</div></div>
      <div class="hcard"><div class="hl">Verze BIOS</div><div class="hv big">$($BIOS.SMBIOSBIOSVersion)</div></div>
      <div class="hcard"><div class="hl">Datum vydani</div><div class="hv">$($BIOS.ReleaseDate)</div></div>
      <div class="hcard"><div class="hl">SMBIOS verze</div><div class="hv">$($BIOS.SMBIOSMajorVersion).$($BIOS.SMBIOSMinorVersion)</div></div>
      <div class="hcard"><div class="hl">S/N zarizeni</div><div class="hv">$($BIOS.SerialNumber)</div></div>
      <div class="hcard"><div class="hl">Secure Boot</div><div class="hv">$(if($SecureBoot -eq $true){"<span class='badge badge-green'>✅ ZAPNUT</span>"}elseif($SecureBoot -eq $false){"<span class='badge badge-red'>❌ VYPNUT</span>"}else{"<span class='badge badge-yellow'>N/A</span>"})</div></div>
    </div>
  </div>

  <div class="panel">
    <div class="ph"><span class="pi">🛡️</span><span class="pt">TPM & Virtualizace</span></div>
    <div class="hgrid">
      <div class="hcard"><div class="hl">TPM Pritomnost</div><div class="hv">$(if($TPM -and $TPM.TpmPresent){"<span class='badge badge-green'>✅ ANO</span>"}else{"<span class='badge badge-red'>❌ NE (PSP vypnuto)</span>"})</div></div>
      <div class="hcard"><div class="hl">TPM Aktivni</div><div class="hv">$(if($TPM -and $TPM.TpmEnabled){"<span class='badge badge-green'>✅ ANO</span>"}else{"<span class='badge badge-red'>❌ NE</span>"})</div></div>
      <div class="hcard"><div class="hl">AMD PSP stav</div><div class="hv">$(if($TPM -and $TPM.TpmPresent){"<span class='badge badge-yellow'>⚡ AKTIVNI</span>"}else{"<span class='badge badge-green'>✅ VYPNUTO (BIOS)</span>"})</div></div>
      <div class="hcard"><div class="hl">VBS (Virtualizace)</div><div class="hv">$(if($VBS_Status.EnableVirtualizationBasedSecurity -eq 1){"<span class='badge badge-yellow'>⚡ ZAPNUTO</span>"}else{"<span class='badge badge-green'>✅ VYPNUTO</span>"})</div></div>
      <div class="hcard"><div class="hl">HVCI</div><div class="hv">$(
        if ($VBS_Status.EnableVirtualizationBasedSecurity -ne 1) {
          "<span class='badge badge-green'>✅ N/A (VBS vypnuto)</span>"
        } elseif ($VBS_HVCI -and $VBS_HVCI.Enabled -eq 1) {
          "<span class='badge badge-yellow'>⚡ ZAPNUTO</span>"
        } else {
          "<span class='badge badge-green'>✅ VYPNUTO</span>"
        }
      )</div></div>
    </div>
  </div>

  <!-- NOVE v3.1: C-States panel -->
  <div class="panel">
    <div class="ph"><span class="pi">⚡</span><span class="pt">CPU Power Management – C-States</span><span class="pc" style="color:$(if($CStatesDisabled){'#00e676'}else{'#f0c040'})">$CStatesStatus</span></div>
    <div class="hgrid">
      <div class="hcard"><div class="hl">C-States stav</div><div class="hv">$(if($CStatesDisabled){"<span class='badge badge-green'>✅ VYPNUTO – doporuceno pro NVMe stabilitu</span>"}else{"<span class='badge badge-yellow'>⚡ ZAPNUTO – mozny zdroj IO stallů</span>"})</div></div>
      <div class="hcard"><div class="hl">Vliv na system</div><div class="hv">$(if($CStatesDisabled){"CPU komunikuje s diskem bez prodlevy usporu energie"}else{"CPU muze zpozdovat IO pri probuzeni ze sleep stavu"})</div></div>
      <div class="hcard"><div class="hl">Jak zmenit</div><div class="hv" style="font-size:0.8em;">powercfg -setacvalueindex SCHEME_CURRENT SUB_PROCESSOR IDLEDISABLE 1</div></div>
    </div>
  </div>

  <div class="panel">
    <div class="ph"><span class="pi">🦠</span><span class="pt">Windows Defender</span></div>
    <div class="hgrid">
      <div class="hcard"><div class="hl">Real-time ochrana</div><div class="hv">$(if($DefenderStatus -and $DefenderStatus.RealTimeProtectionEnabled){"<span class='badge badge-green'>✅ AKTIVNI</span>"}else{"<span class='badge badge-red'>❌ NEAKTIVNI</span>"})</div></div>
      <div class="hcard"><div class="hl">Antivirus</div><div class="hv">$(if($DefenderStatus -and $DefenderStatus.AntivirusEnabled){"<span class='badge badge-green'>✅ ZAPNUT</span>"}else{"<span class='badge badge-red'>❌ VYPNUT</span>"})</div></div>
      <div class="hcard"><div class="hl">Antispyware</div><div class="hv">$(if($DefenderStatus -and $DefenderStatus.AntispywareEnabled){"<span class='badge badge-green'>✅ ZAPNUT</span>"}else{"<span class='badge badge-red'>❌ VYPNUT</span>"})</div></div>
      <div class="hcard"><div class="hl">Verze enginu</div><div class="hv">$(if($DefenderStatus){$DefenderStatus.AMEngineVersion}else{"N/A"})</div></div>
      <div class="hcard"><div class="hl">Podpisy aktualizovany</div><div class="hv">$(if($DefenderStatus){$DefenderStatus.AntivirusSignatureLastUpdated}else{"N/A"})</div></div>
      <div class="hcard"><div class="hl">Posledni rychly sken</div><div class="hv">$(if($DefenderStatus){"Pred $($DefenderStatus.QuickScanAge) dny"}else{"N/A"})</div></div>
    </div>
  </div>
</div>

<!-- ===== BATERIE ===== -->
<div id="baterie" class="section">
  <div class="panel">
    <div class="ph"><span class="pi">🔋</span><span class="pt">Baterie & Napajeni</span></div>
    <div class="hgrid">
      $battHTML
      <div class="hcard"><div class="hl">Napajeci plan</div><div class="hv big">$powerHTML</div></div>
    </div>
  </div>
</div>

<!-- ===== TEPLOTY ===== -->
<div id="teploty" class="section">
  <div class="alert warn">⚡ WMI teploty mohou byt nepresne. Pro presne hodnoty pouzij HWiNFO64 nebo HWMonitor.</div>
  <div class="panel">
    <div class="ph"><span class="pi">🌡️</span><span class="pt">Teplotni zony (ACPI)</span><span class="pc">$($Temps.Count) zon</span></div>
    <div class="tw">
      <table>
        <thead>$(New-TH @("Zona","Teplota"))</thead>
        <tbody>$tempHTML</tbody>
      </table>
    </div>
  </div>
</div>

<!-- ===== LOGY - OPRAVENO v3.1 ===== -->
<div id="logy" class="section">
  $(if($KernelPower.Count -gt 0){"<div class='alert danger'>🔴 KRITICKE: $($KernelPower.Count)x Kernel Power Event ID 41 – mozny HW nebo SW problem! Zkontroluj sekci BIOS & Security.</div>"})
  $(if($DiskIOEvents.Count -gt 5){"<div class='alert warn'>⚠️ $($DiskIOEvents.Count)x Disk IO chyba (ID 153) – disk mel problem s IO operacemi.</div>"})

  <div class="panel">
    <div class="ph"><span class="pi">⚡</span><span class="pt">Kernel Power – ID 41 (pady)</span><span class="pc">$($KernelPower.Count) zaznamu</span></div>
    <div class="tw"><table><thead>$(New-TH @("Cas","ID","Zprava"))</thead><tbody>$kernelHTML</tbody></table></div>
  </div>

  <!-- OPRAVA v3.1: Disk IO chyby (bylo "VBS udalosti ID 153") -->
  <div class="panel">
    <div class="ph"><span class="pi">💾</span><span class="pt">Disk IO chyby – ID 153 (retry operace)</span><span class="pc">$($DiskIOEvents.Count) zaznamu</span></div>
    <div class="tw"><table><thead>$(New-TH @("Cas","ID","Zprava"))</thead><tbody>$diskIOHTML</tbody></table></div>
  </div>

  <!-- NOVE v3.1: Skutecne VBS eventy ID 124 -->
  <div class="panel">
    <div class="ph"><span class="pi">🛡️</span><span class="pt">VBS udalosti – ID 124 (skutecne VBS eventy)</span><span class="pc">$($VBSEvents.Count) zaznamu</span></div>
    <div class="tw"><table><thead>$(New-TH @("Cas","ID","Zprava"))</thead><tbody>$vbsHTML</tbody></table></div>
  </div>

  <div class="panel">
    <div class="ph"><span class="pi">📋</span><span class="pt">Systemove chyby & varovani</span><span class="pc">$($EventErrors.Count) zaznamu</span></div>
    <div class="tw">
      <table>
        <thead>$(New-TH @("Cas","ID","Uroven","Zprava"))</thead>
        <tbody>
          $(($EventErrors | ForEach-Object {
            $cls = if($_.LevelDisplayName -match "Chyb|Error|Critic"){"danger"}else{"warning"}
            "<tr class='$cls'><td>$($_.TimeCreated)</td><td>$($_.Id)</td><td>$($_.LevelDisplayName)</td><td>$($_.Message)</td></tr>"
          }) -join "")
        </tbody>
      </table>
    </div>
  </div>

  <div class="panel">
    <div class="ph"><span class="pi">📱</span><span class="pt">Aplikacni chyby</span><span class="pc">$($AppErrors.Count) zaznamu</span></div>
    <div class="tw">
      <table>
        <thead>$(New-TH @("Cas","ID","Uroven","Zprava"))</thead>
        <tbody>$(($AppErrors | ForEach-Object { "<tr class='danger'><td>$($_.TimeCreated)</td><td>$($_.Id)</td><td>$($_.LevelDisplayName)</td><td>$($_.Message)</td></tr>" }) -join "")</tbody>
      </table>
    </div>
  </div>
</div>

<!-- ===== SECURITY LOG ===== -->
<div id="security" class="section">
  <div class="panel">
    <div class="ph"><span class="pi">🔐</span><span class="pt">Security Log – Prihlaseni & Udalosti</span><span class="pc">$($SecEvents.Count) zaznamu</span></div>
    <div class="tw"><table><thead>$(New-TH @("Cas","ID","Popis"))</thead><tbody>$secHTML</tbody></table></div>
  </div>
</div>

<!-- ===== DRIVERY ===== -->
<div id="drivery" class="section">
  <div class="panel">
    <div class="ph"><span class="pi">🚨</span><span class="pt">Problematicke drivery</span><span class="pc">$($ProblematicDrivers.Count) problemu</span></div>
    <div class="tw"><table><thead>$(New-TH @("Nazev","Chybovy kod","Device ID"))</thead><tbody>$problDriverHTML</tbody></table></div>
  </div>
  <div class="panel">
    <div class="ph"><span class="pi">🔧</span><span class="pt">Vsechny drivery</span><span class="pc">$($Drivers.Count) driveru</span></div>
    <div class="tw">
      <table>
        <thead>$(New-TH @("Zarizeni","Verze","Datum","Vyrobce","Podepsano"))</thead>
        <tbody>
          $(($Drivers | ForEach-Object {
            $s = if($_.IsSigned){"<span class='badge badge-green'>✅ ANO</span>"}else{"<span class='badge badge-red'>❌ NE</span>"}
            "<tr><td>$($_.DeviceName)</td><td>$($_.DriverVersion)</td><td>$($_.DriverDate)</td><td>$($_.Manufacturer)</td><td>$s</td></tr>"
          }) -join "")
        </tbody>
      </table>
    </div>
  </div>
</div>

<!-- ===== PROCESY ===== -->
<div id="procesy" class="section">
  <div class="panel">
    <div class="ph"><span class="pi">⚙️</span><span class="pt">Top 40 procesu (CPU)</span><span class="pc">$($Processes.Count) procesu</span></div>
    <div class="tw">
      <table>
        <thead>$(New-TH @("Nazev","PID","CPU (s)","RAM (MB)","Vlakna","Handles","Spolecnost","Cesta"))</thead>
        <tbody>
          $(($Processes | ForEach-Object {
            $cls = if($_.CPU_s -gt 100){"danger"}elseif($_.CPU_s -gt 30){"warning"}else{""}
            "<tr class='$cls'><td><strong>$($_.Name)</strong></td><td>$($_.Id)</td><td>$($_.CPU_s)</td><td>$($_.RAM_MB)</td><td>$($_.Threads)</td><td>$($_.Handles)</td><td style='font-size:0.85em'>$($_.Company)</td><td style='font-size:0.8em;color:rgba(179,229,252,0.4)'>$($_.Path)</td></tr>"
          }) -join "")
        </tbody>
      </table>
    </div>
  </div>
</div>

<!-- ===== SLUZBY ===== -->
<div id="sluzby" class="section">
  <div class="panel">
    <div class="ph"><span class="pi">🛡️</span><span class="pt">Windows sluzby</span><span class="pc">$($Services.Count) celkem</span></div>
    <div class="tw">
      <table>
        <thead>$(New-TH @("Nazev","Zobrazovany nazev","Stav","Typ startu","Lze zastavit","Lze pozastavit"))</thead>
        <tbody>
          $(($Services | ForEach-Object {
            $sb = if($_.Status -eq "Running"){"<span class='badge badge-green'>▶ Bezi</span>"}else{"<span class='badge badge-red'>⏹ Stop</span>"}
            "<tr><td>$($_.Name)</td><td>$($_.DisplayName)</td><td>$sb</td><td>$($_.StartType)</td><td>$(if($_.CanStop){'✅'}else{'—'})</td><td>$(if($_.CanPause){'✅'}else{'—'})</td></tr>"
          }) -join "")
        </tbody>
      </table>
    </div>
  </div>
</div>

<!-- ===== SIT ===== -->
<div id="sit" class="section">
  <div class="panel">
    <div class="ph"><span class="pi">🌐</span><span class="pt">Sitove adaptery</span></div>
    <div class="tw">
      <table>
        <thead>$(New-TH @("Nazev","Stav","Rychlost","MAC","Driver verze","Popis"))</thead>
        <tbody>
          $(($NetAdapters | ForEach-Object {
            $sb = if($_.Status -eq "Up"){"<span class='badge badge-green'>▲ UP</span>"}else{"<span class='badge badge-red'>▼ DOWN</span>"}
            "<tr><td>$($_.Name)</td><td>$sb</td><td>$($_.LinkSpeed)</td><td>$($_.MacAddress)</td><td>$($_.DriverVersion)</td><td>$($_.InterfaceDescription)</td></tr>"
          }) -join "")
        </tbody>
      </table>
    </div>
  </div>
  <div class="panel">
    <div class="ph"><span class="pi">📡</span><span class="pt">IP Adresy</span></div>
    <div class="tw">
      <table>
        <thead>$(New-TH @("Adapter","IP Adresa","Prefix","Zdroj"))</thead>
        <tbody>$(($IPConfig | ForEach-Object { "<tr><td>$($_.InterfaceAlias)</td><td><strong>$($_.IPAddress)</strong></td><td>/$($_.PrefixLength)</td><td>$($_.SuffixOrigin)</td></tr>" }) -join "")</tbody>
      </table>
    </div>
  </div>
  <div class="panel">
    <div class="ph"><span class="pi">📊</span><span class="pt">Sitova statistika</span></div>
    <div class="tw">
      <table>
        <thead>$(New-TH @("Adapter","Prijato (MB)","Odeslano (MB)","RX pakety","TX pakety","Zahozeno RX"))</thead>
        <tbody>$netStatsHTML</tbody>
      </table>
    </div>
  </div>
  <div class="panel">
    <div class="ph"><span class="pi">🔗</span><span class="pt">Aktivni TCP spojeni</span><span class="pc">$($NetConnections.Count) spojeni</span></div>
    <div class="tw">
      <table>
        <thead>$(New-TH @("Lokalni IP","Port","Vzdalena IP","Port","Stav","PID"))</thead>
        <tbody>$(($NetConnections | ForEach-Object { "<tr><td>$($_.LocalAddress)</td><td>$($_.LocalPort)</td><td>$($_.RemoteAddress)</td><td>$($_.RemotePort)</td><td><span class='badge badge-green'>$($_.State)</span></td><td>$($_.OwningProcess)</td></tr>" }) -join "")</tbody>
      </table>
    </div>
  </div>
  <div class="panel">
    <div class="ph"><span class="pi">🔥</span><span class="pt">Firewall pravidla (aktivni)</span><span class="pc">$($FirewallRules.Count) pravidel</span></div>
    <div class="tw">
      <table>
        <thead>$(New-TH @("Nazev","Smer","Akce","Profil"))</thead>
        <tbody>
          $(($FirewallRules | ForEach-Object {
            $ab = if($_.Action -eq "Block"){"<span class='badge badge-red'>🚫 Blokovat</span>"}else{"<span class='badge badge-green'>✅ Povolit</span>"}
            $cls = if($_.Action -eq "Block"){"warning"}else{""}
            "<tr class='$cls'><td>$($_.DisplayName)</td><td>$($_.Direction)</td><td>$ab</td><td>$($_.Profile)</td></tr>"
          }) -join "")
        </tbody>
      </table>
    </div>
  </div>
  <div class="panel">
    <div class="ph"><span class="pi">🔍</span><span class="pt">DNS servery</span></div>
    <div class="tw">
      <table>
        <thead>$(New-TH @("Adapter","DNS servery"))</thead>
        <tbody>$(($DNS | ForEach-Object { "<tr><td>$($_.InterfaceAlias)</td><td>$($_.ServerAddresses -join ', ')</td></tr>" }) -join "")</tbody>
      </table>
    </div>
  </div>
</div>

<!-- ===== PORTY ===== -->
<div id="porty" class="section">
  <div class="panel">
    <div class="ph"><span class="pi">🔌</span><span class="pt">Naslouchajici TCP porty</span><span class="pc">$($ListeningPorts.Count) portu</span></div>
    <div class="tw"><table><thead>$(New-TH @("IP","Port","Stav","PID","Proces"))</thead><tbody>$listenHTML</tbody></table></div>
  </div>
  <div class="panel">
    <div class="ph"><span class="pi">📡</span><span class="pt">UDP endpointy</span><span class="pc">$($UDPPorts.Count) zobrazeno</span></div>
    <div class="tw">
      <table>
        <thead>$(New-TH @("Lokalni IP","Port","PID"))</thead>
        <tbody>$(($UDPPorts | ForEach-Object { "<tr><td>$($_.LocalAddress)</td><td>$($_.LocalPort)</td><td>$($_.OwningProcess)</td></tr>" }) -join "")</tbody>
      </table>
    </div>
  </div>
</div>

<!-- ===== SDILENI ===== -->
<div id="sdileni" class="section">
  <div class="panel">
    <div class="ph"><span class="pi">📂</span><span class="pt">Sdilene slozky</span><span class="pc">$($Shares.Count) sdilenych slozek</span></div>
    <div class="tw"><table><thead>$(New-TH @("Nazev","Cesta","Popis","Max pripojeni"))</thead><tbody>$sharesHTML</tbody></table></div>
  </div>
</div>

<!-- ===== AUTOSTART ===== -->
<div id="autostart" class="section">
  <div class="panel">
    <div class="ph"><span class="pi">🚀</span><span class="pt">Autostart – Registry & Tasks</span></div>
    <div class="tw"><table><thead>$(New-TH @("Zdroj","Nazev","Cesta / Hodnota"))</thead><tbody>$autostartHTML</tbody></table></div>
  </div>
</div>

<!-- ===== UPDATES ===== -->
<div id="updates" class="section">
  <div class="panel">
    <div class="ph"><span class="pi">🔄</span><span class="pt">Windows Update historie</span><span class="pc">$($Updates.Count) aktualizaci</span></div>
    <div class="tw">
      <table>
        <thead>$(New-TH @("KB cislo","Popis","Nainstalovan","Instaloval"))</thead>
        <tbody>$(($Updates | ForEach-Object { "<tr><td><span class='badge badge-blue'>$($_.HotFixID)</span></td><td>$($_.Description)</td><td>$($_.InstalledOn)</td><td>$($_.InstalledBy)</td></tr>" }) -join "")</tbody>
      </table>
    </div>
  </div>
</div>

<!-- ===== PROGRAMY ===== -->
<div id="programy" class="section">
  <div class="panel">
    <div class="ph"><span class="pi">📦</span><span class="pt">Nainstalovane programy</span><span class="pc">$($Programs.Count) programu</span></div>
    <div class="tw">
      <table>
        <thead>$(New-TH @("Nazev","Verze","Vydavatel","Datum instalace","Velikost (KB)"))</thead>
        <tbody>$(($Programs | ForEach-Object { "<tr><td>$($_.DisplayName)</td><td>$($_.DisplayVersion)</td><td>$($_.Publisher)</td><td>$($_.InstallDate)</td><td>$(if($_.EstimatedSize){"$($_.EstimatedSize)"}else{"-"})</td></tr>" }) -join "")</tbody>
      </table>
    </div>
  </div>
</div>

<!-- ===== UZIVATELE ===== -->
<div id="uzivatele" class="section">
  <div class="panel">
    <div class="ph"><span class="pi">👤</span><span class="pt">Lokalni uzivatele</span><span class="pc">$($LocalUsers.Count) uzivatelu</span></div>
    <div class="tw"><table><thead>$(New-TH @("Uzivatel","Stav","Posledni prihlaseni","Heslo zmeneno","Popis"))</thead><tbody>$usersHTML</tbody></table></div>
  </div>
  <div class="panel">
    <div class="ph"><span class="pi">👑</span><span class="pt">Clenove skupiny Administrators</span></div>
    <div class="tw"><table><thead>$(New-TH @("Uzivatel","Zdroj","Typ"))</thead><tbody>$adminHTML</tbody></table></div>
  </div>
  <div class="panel">
    <div class="ph"><span class="pi">👥</span><span class="pt">Lokalni skupiny</span><span class="pc">$($LocalGroups.Count) skupin</span></div>
    <div class="tw">
      <table>
        <thead>$(New-TH @("Nazev skupiny","Popis"))</thead>
        <tbody>$(($LocalGroups | ForEach-Object { "<tr><td><strong>$($_.Name)</strong></td><td>$($_.Description)</td></tr>" }) -join "")</tbody>
      </table>
    </div>
  </div>
</div>

</div><!-- /content -->

<!-- FOOTER -->
<div class="footer">
  <span>🖖 HVEZDNA FLOTILA LCARS v3.1 ULTIMATE &nbsp;|&nbsp; VICE ADMIRAL JIRIK</span>
  <span>REPORT: $(Get-Date -Format 'dd.MM.yyyy HH:mm:ss') &nbsp;|&nbsp; SKEN: ${ScanDuration}s &nbsp;|&nbsp; ZDRAVI: $HealthScore/100 ($HealthLabel)</span>
  <span>$env:COMPUTERNAME &nbsp;|&nbsp; $($OS.Caption)</span>
</div>

<script>
function show(id, btn) {
  document.querySelectorAll('.section').forEach(s => s.classList.remove('active'));
  document.querySelectorAll('.tab').forEach(t => t.classList.remove('active'));
  document.getElementById(id).classList.add('active');
  btn.classList.add('active');
  window.scrollTo({top:0, behavior:'smooth'});
}

window.addEventListener('load', () => {
  document.querySelectorAll('.pf').forEach(b => {
    const w = b.style.width; b.style.width='0%';
    setTimeout(() => { b.style.width = w; }, 400);
  });
});
</script>
</body>
</html>
"@

$HTML | Out-File -FilePath $ReportFile -Encoding UTF8

Write-Host ""
Write-Host "🖖 ============================================" -ForegroundColor Cyan
Write-Host "   DIAGNOSTIKA v3.1 ULTIMATE DOKONCENA!" -ForegroundColor Green
Write-Host "   Report: $ReportFile" -ForegroundColor Yellow
Write-Host "   Cas skenu: ${ScanDuration}s | Zdravi: $HealthScore/100" -ForegroundColor White
Write-Host "   Bez Kernel Power padu: ${HoursSinceCrash}h" -ForegroundColor $(if($HoursSinceCrash -ne "N/A" -and $HoursSinceCrash -gt 24){"Green"}else{"Yellow"})
Write-Host "🖖 ============================================" -ForegroundColor Cyan
Write-Host ""

Start-Process $ReportFile
