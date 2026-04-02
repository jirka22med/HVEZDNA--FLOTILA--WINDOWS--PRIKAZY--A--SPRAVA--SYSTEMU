# 🖖 HVĚZDNÁ FLOTILA — Windows Příkazy & Správa Systému

<div align="center">

![LCARS](https://img.shields.io/badge/LCARS-v1.0-f0c040?style=for-the-badge&logo=data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHZpZXdCb3g9IjAgMCAyNCAyNCI+PHBhdGggZmlsbD0iI2YwYzA0MCIgZD0iTTEyIDJMMiA3bDEwIDUgMTAtNS0xMC01ek0yIDE3bDEwIDUgMTAtNS0xMC01LTEwIDV6TTIgMTJsMTAgNSAxMC01LTEwLTUtMTAgNXoiLz48L3N2Zz4=)
![Windows](https://img.shields.io/badge/Windows-11-0078D4?style=for-the-badge&logo=windows)
![PowerShell](https://img.shields.io/badge/PowerShell-5.1+-5391FE?style=for-the-badge&logo=powershell)
![HTML](https://img.shields.io/badge/HTML-100%25-E34F26?style=for-the-badge&logo=html5)
![License](https://img.shields.io/badge/Licence-AGPL--3.0-green?style=for-the-badge)
![GitHub Pages](https://img.shields.io/badge/GitHub%20Pages-Live-00e676?style=for-the-badge)

**Interaktivní webová databáze PowerShell příkazů pro správu Windows systému v tématu Star Trek LCARS**

[🚀 **Live Demo**](https://jirka22med.github.io/HVEZDNA--FLOTILA--WINDOWS--PRIKAZY--A--SPRAVA--SYSTEMU/) • [📦 **GitHub Repo**](https://github.com/jirka22med/HVEZDNA--FLOTILA--WINDOWS--PRIKAZY--A--SPRAVA--SYSTEMU) • [🐛 **Nahlásit chybu**](https://github.com/jirka22med/HVEZDNA--FLOTILA--WINDOWS--PRIKAZY--A--SPRAVA--SYSTEMU/issues)

</div>

---

## 📖 O projektu

Tento projekt vznikl jako **praktická pomůcka pro správu Windows systému**, inspirovaná rozhraním LCARS ze seriálu Star Trek. Namísto suchého textového dokumentu nebo nudného README souboru s příkazy dostaneš **krásně navržený interaktivní web** kde najdeš všechny důležité PowerShell příkazy přehledně rozdělené do kategorií — každý s tlačítkem pro okamžité zkopírování a jasným vysvětlením co přesně dělá.

Projekt vznikl na základě **reálné diagnostiky a opravy systému** — konkrétně dvouletého problému s kernel crashemi (Event ID:41) na Lenovo notebooku s AMD Ryzen 5 4600H a GTX 1650 po hardwarovém upgradu. Příkazy v této databázi jsou prověřené praxí, ne jen zkopírované z internetu.

---

## 🎯 Proč tento projekt existuje?

### Problém který řešil

Většina uživatelů Windows se dostane do situace kdy:
- Systém padá s **kernel crashem** a neví proč
- **Windows Update přepsal ovladač** novější (ale vadnou) verzí
- **Event Log je plný chyb** ale není jasné které jsou kritické a které jsou jen informační
- **Disk je plný** ale není jasné čím
- Potřebují rychle **zkopírovat správný příkaz** bez hledání na internetu

### Řešení

Jednoduchý, přehledný web s **okamžitě použitelnými příkazy**, organizovaný podle témat, s vysvětlením každého příkazu laickým jazykem.

---

## ✨ Funkce projektu

### 🎨 Design — Star Trek LCARS rozhraní
- Vizuální styl inspirovaný **LCARS počítačovým rozhraním** ze Star Trek sérií
- Tmavé pozadí s zlatými, modrými a červenými akcenty
- Animované prvky — pulzující indikátory, plovoucí emblem, shimmer efekty
- Plně responzivní — funguje na desktopu i na mobilu
- CRT scanline efekt pro autentický retro-futuristický pocit
- Fonty Orbitron, Share Tech Mono a Exo 2 z Google Fonts

### 📋 Obsah — 8 kategorií příkazů
Každá kategorie obsahuje úvodní vysvětlení a sadu příkazů s popisem:

| Kategorie | Počet příkazů | Popis |
|---|---|---|
| 🔧 Drivery | 6 | Blokace WU, diagnostika BT, chybná zařízení |
| ⚙️ Systém | 6 | SFC, DISM, temp čištění, služby, uptime |
| 💾 Disk & Úložiště | 6 | CHKDSK, TRIM, WU cache, největší soubory |
| 🌐 Síť | 4 | DNS flush, Winsock reset, adaptéry |
| 🛡️ VBS & Security | 4 | VBS cleanup, Secure Boot, Defender |
| 📋 Logy | 5 | Měsíční reset, ID:41, ID:153, ID:5 |
| 🧠 RAM & CPU | 4 | RAM test, moduly, TOP procesy |
| ⚡ Napájení | 4 | C-States, Špičkový výkon, energy report |

### 🖱️ Interaktivita
- **Okamžité kopírování** — každý příkaz má tlačítko KOPÍROVAT
- Vizuální potvrzení kopírování (tlačítko se změní na ✅ ZKOPÍROVÁNO)
- Navigace přes záložky bez načítání stránky
- Smooth scroll na začátek sekce při přepínání

### 🏷️ Barevné označení příkazů
Každý příkaz má barevný štítek podle bezpečnosti/typu:

| Štítek | Barva | Význam |
|---|---|---|
| BEZPEČNÝ | 🟢 Zelená | Lze spustit kdykoliv bez rizika |
| DOPORUČENO | 🟢 Zelená | Doporučená konfigurace |
| ADMIN | 🟡 Zlatá | Vyžaduje práva administrátora |
| POKROČILÝ | 🟡 Zlatá | Pro pokročilé uživatele |
| RESTART NUTNÝ | 🟡 Zlatá | Po příkazu je nutný restart |
| DIAGNOSTIKA | 🟡 Zlatá | Příkaz pro diagnostiku problémů |
| NOUZE | 🔵 Modrá | Použít pouze při problému |
| ADMIN NUTNÝ | 🔴 Červená | Kritický příkaz, vždy jako admin |

---

## 🛠️ Technologie

Projekt je záměrně navržen jako **čistý HTML/CSS/JS bez závislostí** — žádné frameworky, žádné npm balíčky, žádné buildovací nástroje.

```
index.html          ← Celý projekt v jednom souboru
├── CSS             ← Vložený v <style> tagu
│   ├── LCARS design systém (CSS proměnné)
│   ├── Animace (keyframes)
│   └── Responzivní layout (grid, flexbox)
├── HTML            ← Struktura stránek
│   ├── Header s animacemi
│   ├── Navigační záložky
│   ├── 8 sekcí s příkazy
│   └── Footer
└── JavaScript      ← Minimální, vložený v <script> tagu
    ├── show() — přepínání sekcí
    └── copyCmd() — kopírování příkazů
```

### Použité technologie
- **HTML5** — sémantická struktura
- **CSS3** — proměnné, animace, grid, flexbox
- **Vanilla JavaScript** — přepínání záložek, Clipboard API
- **Google Fonts** — Orbitron, Share Tech Mono, Exo 2
- **GitHub Pages** — hosting zdarma

---

## 🚀 Jak použít projekt

### Možnost 1 — Online (nejjednodušší)
Otevři [Live Demo](https://jirka22med.github.io/HVEZDNA--FLOTILA--WINDOWS--PRIKAZY--A--SPRAVA--SYSTEMU/) v prohlížeči. Žádná instalace, funguje okamžitě.

### Možnost 2 — Stáhnout a spustit lokálně
```bash
# Klonovat repozitář
git clone https://github.com/jirka22med/HVEZDNA--FLOTILA--WINDOWS--PRIKAZY--A--SPRAVA--SYSTEMU.git

# Přejít do složky
cd HVEZDNA--FLOTILA--WINDOWS--PRIKAZY--A--SPRAVA--SYSTEMU

# Otevřít v prohlížeči
start index.html        # Windows
open index.html         # macOS
xdg-open index.html     # Linux
```

### Možnost 3 — Stáhnout jen HTML soubor
Stáhni `index.html` přímo z repozitáře a otevři v jakémkoliv moderním prohlížeči. **Žádná instalace ani internet nejsou potřeba** (jen Google Fonts se načítají online — bez internetu se použijí záložní fonty).

---

## 📚 Podrobné vysvětlení kategorií

### 🔧 Drivery — Proč je tato sekce kritická?

Windows Update má zásadní problém: **certifikuje ovladače se zpožděním 6–12 měsíců za výrobcem**. To znamená že pokud necháš Windows stahovat drivery automaticky, může:

1. Přepsat tvůj čerstvě nainstalovaný NVIDIA driver starší verzí
2. Nainstalovat Bluetooth driver s known bugy které způsobují Event ID:5 spam
3. Po reinstalaci AMD driveru vrátit starou verzi s chybami

**Řešení:** Příkaz `ExcludeWUDriversInQualityUpdate = 1` zablokuje Windows Update aby přepisoval drivery. Ty pak řídíš co a kdy se nainstaluje ručně přímo od výrobce.

```
Výrobce vydá driver 1.5.0  →  Windows certifikuje po 8 měsících
                                        ↓
                              Windows Update nainstaluje 1.5.0
                              ale výrobce mezitím vydal 1.8.0 !
```

---

### ⚙️ Systém — SFC a DISM: dvojice zachránců

**SFC (System File Checker)** a **DISM** jsou dva nástroje které by měl znát každý uživatel Windows:

- **SFC** prohledá ~200 000 chráněných systémových souborů a porovná je s čistou kopií. Pokud najde poškozený soubor, automaticky ho opraví. Spusť při:
  - Záhadných pádech aplikací
  - Chybách Windows Update
  - Podezřelém chování systému

- **DISM** pracuje na nižší úrovni — opravuje samotný Windows obraz ze kterého SFC čerpá. Pokud SFC hlásí že "nemůže opravit poškozené soubory", spusť nejdřív DISM a pak znovu SFC.

```
Doporučené pořadí:
1. DISM /Online /Cleanup-Image /RestoreHealth
2. Restart
3. sfc /scannow
```

---

### 💾 Disk — M.2 NVMe bez DDR cache a HMB

Tento projekt vznikl částečně kvůli specifickému problému s **M.2 NVMe disky bez vlastní DDR cache paměti**.

Levnější M.2 NVMe disky (DRAM-less) šetří na vestavěné DDR cache paměti. Místo ní používají technologii **HMB (Host Memory Buffer)** — "ukradnou" si část systémové RAM (typicky 64–128 MB) pro dočasné ukládání dat.

**Důsledky pro systém:**
- Výkon je závislý na rychlosti systémové RAM
- Při vysokém využití RAM (>85%) má HMB málo prostoru → IO chyby → Event ID:153
- Pokud je disk z 99% plný, HMB nemá kam odkládat data → kernel crash ID:41
- CPU musí být stále dostupný (C-States vypnuté!) pro okamžitou obsluhu HMB požadavků

**Proto jsou C-States VYPNUTÉ** v doporučené konfiguraci — CPU nesmí přecházet do úsporných stavů protože by způsobovalo prodlevy při HMB operacích.

---

### 📋 Logy — Jak číst Event Viewer jako profesionál

Windows Event Viewer loguje tisíce událostí denně. Většina z nich jsou jen informační hlášky. Jak rozlišit co je důležité?

**Klíčové Event ID pro sledování:**

| Event ID | Zdroj | Závažnost | Popis |
|---|---|---|---|
| **41** | Kernel-Power | 🔴 KRITICKÝ | Systém se nečekaně restartoval — kernel crash nebo výpadek proudu |
| **153** | storport | 🟠 DŮLEŽITÝ | Disk IO chyba nebo retry operace. Pozor: někdy jen VBS boot hláška! |
| **124** | Microsoft-Windows-DeviceGuard | 🟡 INFORMAČNÍ | VBS fáze selhala — normální pokud je SVM v BIOS vypnuté |
| **42** | Microsoft-Windows-DeviceGuard | 🟡 INFORMAČNÍ | Hypervisor se nespustil — normální bez SVM |
| **5** | BTHUSB | 🟡 VAROVÁNÍ | Bluetooth HCI timeout — při >5x za den řeš reinstalaci driveru |
| **7031** | Service Control Manager | 🟡 VAROVÁNÍ | Služba se nečekaně ukončila — sleduj co je za služba |
| **7023** | Service Control Manager | 🟡 VAROVÁNÍ | Služba selhala při startu |

**Proč je měsíční reset logů důležitý?**

Windows nečistí logy automaticky podle data nebo měsíce. Logy se přepisují **pouze podle velikosti souboru** (výchozí limit System logu je 20 MB). Pokud máš staré chyby z minulých měsíců v logu, diagnostické skripty je započítají do skóre zdraví a výsledek bude zkreslený.

```
Příklad: 15 kernel padů z března + 0 padů v dubnu
         ↓
Diagnostický skript vidí: 15 kernel padů!
         ↓
Skóre zdraví: KRITICKÉ (místo DOBRÉ)

Po měsíčním resetu logů:
         ↓
Diagnostický skript vidí: 0 kernel padů
         ↓
Skóre zdraví: DOBRÉ ✅
```

---

### 🛡️ VBS — Příběh dvouletého kernel crashe

**VBS (Virtualization Based Security)** je bezpečnostní funkce Windows která používá Hyper-V hypervisor k izolaci kritických systémových procesů. Zní to dobře, ale má jeden zásadní háček:

**VBS vyžaduje SVM (AMD) nebo Intel VT-x zapnuté v BIOSu.**

Co se stane když:
- Registry říkají: `EnableVirtualizationBasedSecurity = 1` (VBS zapnuto)
- BIOS říká: SVM = VYPNUTO

```
Boot → Windows čte registry → "VBS musí být zapnuté!"
                ↓
       Pokus o spuštění Hypervisoru
                ↓
       BIOS: SVM = VYPNUTO ← KONFLIKT!
                ↓
       ID:42 – Hypervisor se nespustil
       ID:124 – VBS fáze 6 selhala
                ↓
       KERNEL PANIKA → ID:41 💥
```

**Toto způsobilo 15 kernel crashů za 25 dní** na konkrétním systému. Řešením bylo **vyčistit VBS registry klíče** příkazem v sekci VBS & Security.

---

### 🧠 RAM — Mismatched RAM a dual channel

Pokud máš v systému dva RAM moduly s **různými frekvencemi nebo různými part numbery**, systém funguje v dual channel ale na nižší z obou frekvencí. To samo o sobě není kritické, ale může způsobovat:

- Nestabilitu při vysoké zátěži
- Nižší výkon paměti (limitovaný pomalejším modulem)
- Problémy s HMB u DRAM-less M.2 disků

**Doporučení:** Pro maximální stabilitu používej dva identické moduly RAM (stejný výrobce, stejný part number, stejná frekvence). Pokud to není možné, aspoň stejná frekvence.

---

### ⚡ C-States — Co to je a kdy je vypnout?

**C-States (CPU Power States)** jsou úsporné stavy procesoru:

| C-State | Název | Popis | Latence probuzení |
|---|---|---|---|
| C0 | Active | CPU plně aktivní | 0 ns |
| C1 | Halt | CPU čeká ale je připraven | ~1 μs |
| C2 | Stop-Clock | Hlubší úspora | ~10 μs |
| C6 | Deep Power Down | Maximální úspora | ~100-200 μs |

**Kdy C-States VYPNOUT:**
- Máš M.2 NVMe bez DDR cache (HMB závisí na okamžité reakci CPU)
- Zažíváš náhodné "stutter" ve hrách nebo při práci
- Máš problémy s nestabilitou systému

**Kdy C-States ZAPNOUT (nechat zapnuté):**
- Chceš co nejdelší výdrž na baterii u notebooku
- Systém je stabilní a nemáš problémy
- Nemáš DRAM-less M.2 disk

---

## 🔒 Důležité upozornění

> ⚠️ **VŽDY spouštěj PowerShell příkazy jako Administrator** — bez admin práv většina příkazů nebude fungovat nebo se provede pouze částečně.

> ⚠️ **Před jakoukoliv změnou systému si zálohuj data** — zejména před DISM, CHKDSK nebo VBS cleanup operacemi.

> ⚠️ **Příkazy s označením RESTART NUTNÝ** — po jejich provedení je nutný restart aby se změny projevily.

> ⚠️ **Příkaz výjimky pro Windows Update drivery** (`ExcludeWUDriversInQualityUpdate = 0`) — po vyřešení problému s driverem ho ihned znovu nastav na 1!

---

## 🤝 Jak přispět

Příspěvky jsou vítány! Pokud znáš užitečný PowerShell příkaz který zde chybí:

1. **Fork** repozitáře
2. Vytvoř novou větev: `git checkout -b novy-prikaz`
3. Přidej příkaz do příslušné sekce v `index.html`
4. Použij existující strukturu `.cmd-card` pro konzistentní vzhled
5. Přidej badge s bezpečnostním označením
6. **Pull Request** s popisem co příkaz dělá a proč je užitečný

### Struktura nového příkazu

```html
<div class="cmd-card">
  <div class="cmd-header">
    <span class="cmd-icon">🔍</span>
    <span class="cmd-title">Název příkazu</span>
    <span class="cmd-badge badge-safe">BEZPEČNÝ</span>
  </div>
  <div class="cmd-desc">
    Popis co příkaz dělá. <strong>Klíčová informace tučně.</strong>
  </div>
  <div class="cmd-code-wrap">
    <pre class="cmd-code"><span class="comment"># Komentář</span>
Příkaz zde</pre>
    <button class="copy-btn" onclick="copyCmd(this)">KOPÍROVAT</button>
  </div>
</div>
```

### Dostupné badge třídy

```css
badge-safe    /* Zelená — bezpečný příkaz */
badge-warn    /* Zlatá — varování, admin potřeba */
badge-danger  /* Červená — kritický, nutný admin */
badge-info    /* Modrá — informační, nouze */
```

---

## 📁 Struktura repozitáře

```
HVEZDNA--FLOTILA--WINDOWS--PRIKAZY--A--SPRAVA--SYSTEMU/
├── index.html      ← Celý projekt (HTML + CSS + JS)
├── README.md       ← Tato dokumentace
└── LICENSE         ← AGPL-3.0 licence
```

---

## 🌟 Star Trek LCARS Design Systém

Projekt používá vlastní LCARS design systém inspirovaný rozhraním z Star Trek: The Next Generation a pozdějších sérií.

### Barevná paleta

```css
--gold:   #f0c040  /* Primární — nadpisy, aktivní prvky */
--blue:   #4fc3f7  /* Sekundární — informační prvky */
--red:    #ef5350  /* Varování, chyby */
--green:  #00e676  /* Úspěch, OK stav */
--orange: #ff9800  /* Upozornění */
--purple: #ce93d8  /* Zvláštní prvky */
--bg:     #010d1a  /* Pozadí */
--panel:  #031524  /* Panely */
--border: #0d3a6e  /* Ohraničení */
--text:   #b3e5fc  /* Základní text */
```

### Typografie

- **Orbitron** — nadpisy, navigace, LCARS panely (futuristický display font)
- **Share Tech Mono** — monospace text, kódy, technické údaje
- **Exo 2** — základní text, popisy (čitelný bez ztráty sci-fi atmosféry)

---

## 📊 Kompatibilita

| Prohlížeč | Podpora |
|---|---|
| Chrome 90+ | ✅ Plná podpora |
| Firefox 88+ | ✅ Plná podpora |
| Edge 90+ | ✅ Plná podpora |
| Safari 14+ | ✅ Plná podpora |
| Opera 76+ | ✅ Plná podpora |

| OS | Podpora příkazů |
|---|---|
| Windows 11 | ✅ Plná podpora |
| Windows 10 | ✅ Většina příkazů funguje |
| Windows Server 2019+ | ✅ Serverové příkazy fungují |

**Clipboard API** (kopírování příkazů) vyžaduje HTTPS nebo localhost — na GitHub Pages funguje automaticky.

---

## 📜 Licence

Tento projekt je licencován pod **GNU Affero General Public License v3.0 (AGPL-3.0)**.

To znamená:
- ✅ Můžeš projekt volně používat, studovat a modifikovat
- ✅ Můžeš ho distribuovat dál
- ✅ Můžeš ho použít jako základ pro vlastní projekt
- ⚠️ Pokud ho použiješ na serveru (web app), musíš zveřejnit zdrojový kód
- ⚠️ Odvozené projekty musí používat stejnou licenci

Viz [LICENSE](LICENSE) pro plné znění.

---

## 👤 Autor

**Vice Admiral Jiřík** — jirka22med

- GitHub: [@jirka22med](https://github.com/jirka22med)
- Projekt: [LCARS Windows Databáze](https://jirka22med.github.io/HVEZDNA--FLOTILA--WINDOWS--PRIKAZY--A--SPRAVA--SYSTEMU/)

---

## 🙏 Poděkování

Tento projekt vznikl ve spolupráci s:

- **Claude AI (Anthropic)** — hlavní AI asistent, diagnostika systému, tvorba kódu
- **Gemini AI (Google)** — spolupráce na diagnostice kernel crashů
- **Hvězdná flotila** — za inspiraci rozhraním LCARS 🖖

---

<div align="center">

**🖖 Živě dlouho a prosperujte — LCARS v1.0**

*"Space: the final frontier. These are the voyages of the Starship DESKTOP-GLDFRSU."*

![WARP](https://img.shields.io/badge/WARP-ONLINE-00e676?style=flat-square)
![KERNEL_PADY](https://img.shields.io/badge/KERNEL%20PADY-0x-00e676?style=flat-square)
![VBS](https://img.shields.io/badge/VBS-VYPNUTO-00e676?style=flat-square)
![C_STATES](https://img.shields.io/badge/C--STATES-VYPNUTO-00e676?style=flat-square)

</div>



# 🖖 Hvězdná Flotila — LCARS Diagnostický Skript v3.1 ULTIMATE

> **Kompletní systémový skener Windows 11 s exportem do HTML reportu ve stylu Star Trek LCARS**  
> Vytvořeno více admirálem Jiříkem | Hvězdná flotila — osobní projekt

---

## 📋 Obsah

- [Popis projektu](#-popis-projektu)
- [Ukázka výstupu](#-ukázka-výstupu)
- [Požadavky](#-požadavky)
- [Instalace a spuštění](#-instalace-a-spuštění)
- [Scanning moduly — 16 sekcí](#-scanning-moduly--16-sekcí)
- [LCARS Dashboard — přehled panelů](#-lcars-dashboard--přehled-panelů)
- [Skóre zdraví systému](#-skóre-zdraví-systému)
- [Nastavení limitů záznamů](#-nastavení-limitů-záznamů)
- [Changelog](#-changelog)
- [Struktura exportu](#-struktura-exportu)
- [Technické poznámky](#-technické-poznámky)
- [Autoři](#-autoři)

---

## 🚀 Popis projektu

**StarTrek-Diagnostika** je PowerShell skript, který provede hloubkový sken Windows 11 a vygeneruje interaktivní HTML report ve vizuálním stylu Star Trek LCARS (Library Computer Access and Retrieval System).

Script prochází **16 diagnostických modulů** — od hardwaru, přes systémové logy, síť, procesy, až po bezpečnostní audit. Výsledek je plnohodnotný HTML dashboard s přepínacími záložkami, progress bary, barevnými odznaky a animacemi.

### ✨ Klíčové vlastnosti

| Funkce | Popis |
|--------|-------|
| 🏠 **Dashboard** | Přehled všech kritických hodnot na jedné obrazovce |
| ⏱️ **Crash Timer** | Počítadlo hodin bez Kernel Power pádu (Event ID 41) |
| 💯 **Health Score** | Automatické skóre zdraví systému 0–100 |
| 🎨 **LCARS UI** | Star Trek vizuální styl s animacemi a barvami |
| 📊 **Status Bar** | Real-time statusový pruh se stavem všech subsystémů |
| 🔌 **18 záložek** | Plně přepínatelné sekce bez reloadu stránky |
| ⚡ **C-States** | Detekce stavu CPU power management |
| 🔩 **AMD PSP** | Zobrazení stavu AMD Platform Security Processor |
| 💾 **Disk IO** | Správné zachycení ID 153 jako Disk IO chyby (ne VBS!) |

---

## 🖥️ Ukázka výstupu

```
🖖 HVEZDNA FLOTILA LCARS v3.1 ULTIMATE
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 WARP: ONLINE | KERNEL PADY: 0 | DRIVERY: OK
 RAM: 45% | DISKY: 0 KRITICKÉ | ZDRAVÍ: 87/100
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 Záložky: Dashboard | Hardware | RAM | BIOS |
          Baterie | Teploty | Logy | Security |
          Drivery | Procesy | Služby | Síť |
          Porty | Sdílení | Autostart | Updates |
          Programy | Uživatelé
```

HTML report se automaticky otevře v prohlížeči po dokončení skenování.

---

## 📦 Požadavky

| Požadavek | Minimum |
|-----------|---------|
| **OS** | Windows 10 / Windows 11 |
| **PowerShell** | 5.1 nebo novější (doporučeno PS 7+) |
| **Práva** | Spustit jako **Správce (Administrator)** |
| **Místo na disku** | ~500 KB pro HTML report |
| **Připojení k internetu** | Pouze pro Google Fonts v HTML výstupu |

> ⚠️ Bez práv správce některé moduly (TPM, Security Log, Defender) nemusí vrátit kompletní data.

---

## 🛠️ Instalace a spuštění

### 1. Stažení skriptu

```powershell
# Přímé stažení přes PowerShell
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/jirka22med/<repo>/main/StarTrek-Diagnostika-v6-1-ULTIMATE.ps1" -OutFile "StarTrek-Diagnostika.ps1"
```

nebo ručně stáhni soubor `StarTrek-Diagnostika-v6-1-ULTIMATE.ps1` z tohoto repozitáře.

### 2. Nastavení cesty pro export

Ve skriptu uprav proměnnou `$ExportPath` podle svého systému:

```powershell
$ExportPath = "C:\Users\TVOJE_JMENO\Desktop\export-slozka-pro-pokrocily-script-poweshale"
```

### 3. Povolení spuštění skriptů (pokud potřeba)

```powershell
# Spustit v PowerShell jako Správce
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### 4. Spuštění

```powershell
# Klikni pravým tlačítkem → "Spustit jako správce"
# nebo v PowerShell konzoli jako Správce:
.\StarTrek-Diagnostika-v6-1-ULTIMATE.ps1
```

Po dokončení skenování se report automaticky otevře v prohlížeči.

---

## 📡 Scanning moduly — 16 sekcí

Script sbírá data v 16 sekvenčních krocích:

| # | Modul | Sbíraná data |
|---|-------|-------------|
| 01 | **Hardware** | CPU, RAM, GPU, disky, OS, základní deska |
| 02 | **RAM moduly** | Fyzické sloty, frekvence, výrobce, kapacita |
| 03 | **BIOS & Firmware** | Verze, datum, SMBIOS, S/N |
| 04 | **TPM / VBS / Security** | TPM, VBS, Secure Boot, Defender, **C-States**, **AMD PSP** |
| 05 | **Baterie & Napájení** | Stav baterie, kapacita, napájecí plán |
| 06 | **Teploty & Ventilátory** | ACPI teplotní zóny (WMI), ventilátory |
| 07 | **Systémové logy** | Kernel Power ID 41, Disk IO ID 153, VBS ID 124, chyby |
| 08 | **Security log** | Přihlášení, selhání, změny účtů (ID 4624–4732) |
| 09 | **Drivery** | Podepsané i problematické ovladače |
| 10 | **Procesy & Služby** | Top 40 procesů dle CPU, všechny Windows služby |
| 11 | **Síť** | Adaptéry, TCP spojení, porty, firewall, DNS, statistiky |
| 12 | **Sdílené složky** | SMB sdílení a oprávnění |
| 13 | **Autostart** | Registry (HKLM/HKCU/RunOnce) + Scheduled Tasks |
| 14 | **Windows Update** | Historie posledních 30 aktualizací |
| 15 | **Programy** | Všechny nainstalované aplikace (x64 + x86) |
| 16 | **Uživatelé & Skupiny** | Lokální účty, skupiny, členové Administrators |

---

## 🎛️ LCARS Dashboard — přehled panelů

### ⏱️ Crash Timer panel (nový v v3.1)
- Zobrazuje počet hodin od posledního Kernel Power pádu (Event ID 41)
- Barevná indikace: 🟢 zelená (>72h), 🟡 žlutá (24–72h), 🔴 červená (<24h)
- Datum posledního pádu + celkový počet zaznamenaných pádů

### 💯 Health Score
Automaticky vypočítané skóre 0–100 se odečítá za:
- Přeplněné disky (>80% = -8, >90% = -15)
- Kernel Power pady (>0 = -6, >5 = -12, >10 = -20)
- Disk IO chyby ID 153 (>0 = -5, >10 = -10)
- Problematické drivery (-10)
- VBS zapnuto (-5)
- RAM obsazenost >85% (-10)
- Příliš mnoho systémových chyb (-8)

### 📊 Status Bar
Permanentní pruh pod hlavičkou zobrazuje live stav:
```
WARP: ONLINE | KERNEL PADY: X | DRIVERY: OK/PROBLÉM |
CPU: model | RAM: X% | DISKY: X KRITICKÉ | VBS: stav |
C-STATES: stav | BEZ PÁDŮ: Xh
```

---

## 🎚️ Nastavení limitů záznamů

Skript má na dvou místech nastavitelné limity — kolik záznamů se **načte z logu** a kolik se **zobrazí v HTML reportu**. Obojí lze upravit ručně přímo ve skriptu.

### Kde hledat

Vše je v sekci označené komentářem `[7] SYSTEM LOGY` a `[8] SECURITY LOG`.

### Jak limity fungují

| Parametr | Funkce |
|----------|--------|
| `-MaxEvents X` | Kolik záznamů PowerShell **načte z Windows Event Logu** do paměti — větší hodnota = zachytí starší záznamy, ale sken trvá déle |
| `Select-Object -First X` | Kolik z načtených záznamů se **zobrazí v HTML reportu** |

> 💡 Logika: nejdříve se načte velký buffer (`-MaxEvents`), z něho se vyfiltrují relevantní záznamy, a pak se zobrazí jen první X výsledků (`-First`).

### Přehled všech nastavitelných limitů

```powershell
# ── [7] SYSTÉMOVÉ LOGY ─────────────────────────────────────────────

# Systémové chyby a varování (úroveň ≤ 2)
$EventErrors = Get-WinEvent -LogName System -MaxEvents 1000   # ← buffer: kolik načíst
    | Select-Object -First 50                                  # ← zobrazit: max v reportu

# Kernel Power pady (Event ID 41) — neočekávaný restart
$KernelPower = Get-WinEvent -LogName System ...
    | Select-Object -First 15                                  # ← zobrazit v reportu

# Aplikační chyby
$AppErrors = Get-WinEvent -LogName Application -MaxEvents 500 # ← buffer
    | Select-Object -First 30                                  # ← zobrazit v reportu

# Disk IO chyby (Event ID 153 — retry operace)
$DiskIOEvents = Get-WinEvent -LogName System ...
    | Select-Object -First 15                                  # ← zobrazit v reportu

# VBS události (Event ID 124 — skutečné VBS eventy)
$VBSEvents = Get-WinEvent -LogName System ...
    | Select-Object -First 10                                  # ← zobrazit v reportu

# ── [8] SECURITY LOG ───────────────────────────────────────────────

# Bezpečnostní záznamy (přihlášení, selhání, změny účtů)
$SecEvents = Get-WinEvent -LogName Security -MaxEvents 200    # ← buffer
    | Select-Object -First 30                                  # ← zobrazit v reportu
```

### Doporučené hodnoty

| Typ záznamu | Výchozí `-First` | Doporučené maximum | Poznámka |
|-------------|------------------|--------------------|----------|
| Systémové chyby | 50 | 100 | Více záznamů = větší HTML soubor |
| Kernel Power pady | 15 | 50 | Pro dlouhodobé sledování stability |
| Aplikační chyby | 30 | 60 | — |
| Disk IO chyby | 15 | 30 | — |
| VBS události | 10 | 20 | Obvykle jich bývá málo |
| Security záznamy | 30 | 100 | Pozor na velikost souboru |

> ⚠️ Příliš vysoké hodnoty (`-MaxEvents` přes 5000, `-First` přes 200) mohou prodloužit dobu skenování a výrazně zvětšit výsledný HTML soubor.

---

## 🔧 Changelog

### v3.1 ULTIMATE (aktuální)
- ✅ **Oprava:** `Get-WmiObject` → `Get-CimInstance` kompletně nahrazeno v celém skriptu
- ✅ **Oprava:** Event ID 153 správně označen jako **Disk IO retry chyby** (dříve chybně jako VBS)
- ✅ **Oprava:** Kernel Power alert odstraňuje falešné "VBS podezření"
- ✅ **Oprava:** Problematické drivery — detekce přes `ConfigManagerErrorCode -ne 0` (přesnější)
- 🆕 **Nové:** Panel **C-States stav** v sekci BIOS & Security
- 🆕 **Nové:** Panel **AMD PSP stav** v sekci BIOS & Security  
- 🆕 **Nové:** **Crash Timer** — výpočet a zobrazení hodin bez Kernel Power pádu
- 🆕 **Nové:** VBS panel zobrazuje skutečné VBS eventy **ID 124** (ne ID 153)
- 🆕 **Nové:** Crash Timer karta v hlavním Dashboardu
- 🆕 **Nové:** C-States a "BEZ PÁDŮ" indikátor přidán do Status Baru

### v3.0
- Základní 16-modulový sken
- LCARS HTML výstup se záložkami
- Health Score systém
- Kernel Power monitoring

---

## 📁 Struktura exportu

Po spuštění skript vytvoří:

```
C:\Users\<uživatel>\Desktop\export-slozka-pro-pokrocily-script-poweshale\
└── StarTrek-Diagnostika-v3-YYYY-MM-DD_HH-mm.html   ← HTML report s datem
```

Každé spuštění vytvoří **nový soubor** s časovým razítkem — starší reporty zůstávají zachovány.

---

## 💡 Technické poznámky

### Proč `Get-CimInstance` místo `Get-WmiObject`?
`Get-WmiObject` je deprecated od PowerShell 3.0 a v PS 7+ zcela chybí. `Get-CimInstance` používá WS-Management protokol a je modernějším ekvivalentem s lepší podporou.

### Teploty přes WMI
WMI teplotní hodnoty (`MSAcpi_ThermalZoneTemperature`) jsou závislé na BIOS a nemusí být dostupné na všech zařízeních. Pro přesné hodnoty doporučuji **HWiNFO64** nebo **HWMonitor**.

### C-States detekce
Skript čte stav `IDLEDISABLE` z aktivního napájecího plánu přes `powercfg -query`. Hodnota `0x00000001` = C-States vypnuty (doporučeno pro stabilitu NVMe disků a prevenci Kernel Power pádů).

### AMD PSP / TPM
AMD Platform Security Processor se projevuje jako TPM 2.0 v systému. Pokud je PSP v BIOS vypnuto, `Get-Tpm` vrátí `TpmPresent: False` — skript tuto situaci správně detekuje a zobrazí "VYPNUTO (BIOS)".

### Event ID 41 — Kernel Power
Jde o neočekávaný restart systému (výpadek napájení, BSOD, přehřátí, chyba hardware). Skript zobrazí posledních 15 zaznamenaných událostí a počítá čas od posledního pádu.

### Bezpečnostní logy
Sledované Event ID:
| ID | Popis |
|----|-------|
| 4624 | Úspěšné přihlášení |
| 4625 | Selhání přihlášení |
| 4634 | Odhlášení |
| 4648 | Přihlášení s jinými pověřeními |
| 4720 | Vytvoření účtu |
| 4726 | Smazání účtu |
| 4732 | Přidání do skupiny |

---

## 👥 Autoři

| Role | Jméno | Popis |
|------|-------|-------|
| 🤖 **Hlavní programování** | **Admirál Claude.AI** | Návrh architektury, psaní kódu, HTML/CSS LCARS šablona, diagnostické moduly, Health Score systém |
| 🖖 **Správce kódu** | **Více admirál Jiřík** | Vedení projektu, testování na živém systému, zadávání požadavků, opravy, verzování a správa repozitáře |

GitHub správce: [@jirka22med](https://github.com/jirka22med)

> *"Warpový pohon online. Diagnostika zahájena."* 🖖

---

## 📄 Licence

Osobní projekt. Volně ke studiu a použití — pokud někde použiješ, uveď autora. Hvězdná flotila to ocení.

---

*Report generován skriptem StarTrek-Diagnostika-v6-1-ULTIMATE.ps1 | Hvězdná flotila LCARS v3.1*
