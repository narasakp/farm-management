# Auto-generate SCREEN_INVENTORY.md from actual screen files
# Scans lib/screens directory and creates complete inventory

Write-Host "[*] Scanning screens..." -ForegroundColor Cyan
Write-Host ""

# Get all screen files
$screens = Get-ChildItem -Path "lib/screens" -Recurse -Filter "*_screen.dart" | Sort-Object FullName

if ($screens.Count -eq 0) {
    Write-Host "[ERROR] No screen files found!" -ForegroundColor Red
    exit 1
}

Write-Host "[OK] Found $($screens.Count) screen files" -ForegroundColor Green
Write-Host ""

# Function to extract route from main.dart
function Get-RouteForScreen {
    param($screenFileName)
    
    $baseName = $screenFileName -replace "_screen\.dart$", ""
    $route = ""
    
    if (Test-Path "lib/main.dart") {
        $mainContent = Get-Content "lib/main.dart" -Raw
        
        # Try to find route pattern
        if ($mainContent -match "GoRoute\([^)]*path:\s*'([^']*)'[^)]*name:\s*'[^']*$baseName") {
            $route = $matches[1]
        }
        elseif ($mainContent -match "path:\s*'(/[^']*$baseName[^']*)'") {
            $route = $matches[1]
        }
    }
    
    return $route
}

# Function to guess purpose from screen name
function Get-ScreenPurpose {
    param($screenName, $directory)
    
    $name = $screenName -replace "_screen\.dart$", "" -replace "_", " "
    $name = (Get-Culture).TextInfo.ToTitleCase($name)
    
    # Add context from directory
    if ($directory -match "admin") { return "Admin: $name" }
    if ($directory -match "auth") { return "Authentication: $name" }
    if ($directory -match "guest") { return "Guest Access: $name" }
    if ($directory -match "dashboard") { return "Dashboard: $name" }
    
    return $name
}

# Categorize screens
$adminScreens = @()
$authScreens = @()
$guestScreens = @()
$coreScreens = @()
$otherScreens = @()

foreach ($screen in $screens) {
    $relativePath = $screen.FullName -replace [regex]::Escape((Get-Location).Path + "\"), "" -replace "\\", "/"
    $directory = $screen.Directory.Name
    $fileName = $screen.Name
    
    $route = Get-RouteForScreen $fileName
    if (-not $route) {
        # Try to guess route from file structure
        $route = "/" + ($fileName -replace "_screen\.dart$", "" -replace "_", "-")
    }
    
    $purpose = Get-ScreenPurpose $fileName $screen.Directory.FullName
    
    $screenInfo = @{
        Name = $fileName -replace "_screen\.dart$", "" -replace "_", " " | ForEach-Object { (Get-Culture).TextInfo.ToTitleCase($_) }
        Route = $route
        File = $relativePath
        Purpose = $purpose
        Category = $directory
    }
    
    if ($relativePath -match "admin/") { $adminScreens += $screenInfo }
    elseif ($relativePath -match "auth/") { $authScreens += $screenInfo }
    elseif ($relativePath -match "guest/") { $guestScreens += $screenInfo }
    elseif ($relativePath -match "dashboard|farms|livestock|production|market|trading|quick_buy") { $coreScreens += $screenInfo }
    else { $otherScreens += $screenInfo }
}

# Generate markdown
$markdown = @"
# 📱 Screen Inventory - Farm Management App

**Last Updated:** $(Get-Date -Format "yyyy-MM-dd HH:mm")  
**Total Screens:** $($screens.Count)  
**Auto-generated:** Yes (by generate-screen-inventory.ps1)  
**Purpose:** Complete list of all screens to prevent duplicate creation

---

## 🔐 Admin Screens ($($adminScreens.Count))

| Screen | Route | File | Purpose | Status |
|--------|-------|------|---------|--------|
"@

foreach ($screen in $adminScreens | Sort-Object Name) {
    $status = if ($screen.File -match "admin_dashboard") { "✅ **MAIN**" } 
              elseif ($screen.Name -match "User" -and $screen.File -notmatch "dashboard") { "🚫 **DEPRECATED**" }
              else { "✅ Active" }
    
    $markdown += "`n| **$($screen.Name)** | ``$($screen.Route)`` | ``$($screen.File)`` | $($screen.Purpose) | $status |"
}

$markdown += @"


**⚠️ IMPORTANT:** 
- Only ONE screen for user management: **AdminDashboardScreen** (``/admin-dashboard``)
- Never create separate "admin users" screen again
- Add features to AdminDashboardScreen tabs instead

---

## 🏠 Core Features ($($coreScreens.Count))

| Screen | Route | File | Purpose |
|--------|-------|------|---------|
"@

foreach ($screen in $coreScreens | Sort-Object Name) {
    $markdown += "`n| **$($screen.Name)** | ``$($screen.Route)`` | ``$($screen.File)`` | $($screen.Purpose) |"
}

$markdown += @"


---

## 🔓 Authentication ($($authScreens.Count))

| Screen | Route | File | Purpose |
|--------|-------|------|---------|
"@

foreach ($screen in $authScreens | Sort-Object Name) {
    $markdown += "`n| **$($screen.Name)** | ``$($screen.Route)`` | ``$($screen.File)`` | $($screen.Purpose) |"
}

$markdown += @"


---

## 👤 Guest Access ($($guestScreens.Count))

| Screen | Route | File | Purpose |
|--------|-------|------|---------|
"@

foreach ($screen in $guestScreens | Sort-Object Name) {
    $markdown += "`n| **$($screen.Name)** | ``$($screen.Route)`` | ``$($screen.File)`` | $($screen.Purpose) |"
}

if ($otherScreens.Count -gt 0) {
    $markdown += @"


---

## 📋 Other Screens ($($otherScreens.Count))

| Screen | Route | File | Purpose |
|--------|-------|------|---------|
"@

    foreach ($screen in $otherScreens | Sort-Object Name) {
        $markdown += "`n| **$($screen.Name)** | ``$($screen.Route)`` | ``$($screen.File)`` | $($screen.Purpose) |"
    }
}

$markdown += @"


---

## 🚨 Before Creating New Screen

### Checklist:
``````
□ 1. Search this file for similar functionality
□ 2. Check if existing screen can be extended instead
□ 3. Check routes in lib/main.dart
□ 4. Check AdminNavigationConfig (for admin screens)
□ 5. Document architectural decision
□ 6. Update this file immediately after creation
``````

### Questions to Ask:
1. **Does similar screen already exist?**
   - Search: ``grep -r "ScreenName" lib/``
   - Check: This inventory file

2. **Can I add feature to existing screen?**
   - Add tab to TabBar
   - Add section to existing page
   - Extend with modal/dialog

3. **Is this truly unique functionality?**
   - Different data source?
   - Different user role?
   - Different workflow?

---

## 📝 How to Maintain

### When Adding Screen:
1. Create screen file
2. Add route to ``lib/main.dart``
3. **Run this script to update inventory:**
   ``````powershell
   .\generate-screen-inventory.ps1
   ``````

### When Removing Screen:
1. Remove route from ``lib/main.dart``
2. Delete screen file
3. **Run this script to update inventory:**
   ``````powershell
   .\generate-screen-inventory.ps1
   ``````

### When Refactoring:
1. Update file paths
2. Update routes if changed
3. **Run this script to update inventory:**
   ``````powershell
   .\generate-screen-inventory.ps1
   ``````

---

## 🔧 Auto-Update

This file was auto-generated. To regenerate:

``````powershell
.\generate-screen-inventory.ps1
``````

---

## 📚 Related Documentation

- **Navigation Config:** ``lib/config/admin_navigation_config.dart``
- **Routes:** ``lib/main.dart`` (GoRouter configuration)
- **Architecture Decisions:** ``D:\Code\_KNOWLEDGE_BASE\TROUBLESHOOTING\ADMIN_SCREEN_DUPLICATION_REFACTOR_2025-10-21.md``
- **Prevention System:** ``DUPLICATE_PREVENTION_SYSTEM.md``

---

**Remember:** This file is your first stop before creating any new screen!

**Last scan:** $(Get-Date -Format "yyyy-MM-dd HH:mm")
"@

# Write to file
$markdown | Out-File -FilePath "SCREEN_INVENTORY.md" -Encoding UTF8 -Force

Write-Host "[OK] Generated SCREEN_INVENTORY.md" -ForegroundColor Green
Write-Host ""
Write-Host "Summary:" -ForegroundColor Cyan
Write-Host "  Admin Screens: $($adminScreens.Count)" -ForegroundColor White
Write-Host "  Core Features: $($coreScreens.Count)" -ForegroundColor White
Write-Host "  Authentication: $($authScreens.Count)" -ForegroundColor White
Write-Host "  Guest Access: $($guestScreens.Count)" -ForegroundColor White
Write-Host "  Other: $($otherScreens.Count)" -ForegroundColor White
Write-Host "  Total: $($screens.Count)" -ForegroundColor Yellow
Write-Host ""
Write-Host "[OK] Done! Check SCREEN_INVENTORY.md" -ForegroundColor Green
