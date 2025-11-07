# Flutter Screen Generator with Smart Back Navigation
# Usage: .\generate_screen.ps1 -ScreenName "MyNewScreen" -HasTabs

param(
    [Parameter(Mandatory=$true)]
    [string]$ScreenName,
    
    [Parameter(Mandatory=$false)]
    [switch]$HasTabs,
    
    [Parameter(Mandatory=$false)]
    [int]$TabCount = 2,
    
    [Parameter(Mandatory=$false)]
    [string]$Category = "screens"
)

$ErrorActionPreference = "Stop"

Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "Flutter Screen Generator with Smart Back Navigation" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host ""

# Validate screen name
if ($ScreenName -notmatch '^[A-Z][a-zA-Z0-9]*$') {
    Write-Host "[ERROR] Screen name must start with uppercase letter (PascalCase)" -ForegroundColor Red
    exit 1
}

# Convert to snake_case for filename
$fileName = ($ScreenName -creplace '([A-Z])', '_$1').ToLower().TrimStart('_') + "_screen.dart"
$screenPath = "lib\$Category\$fileName"

Write-Host "[INFO] Screen Name: $ScreenName" -ForegroundColor Yellow
Write-Host "[INFO] File Path: $screenPath" -ForegroundColor Yellow
Write-Host "[INFO] Has Tabs: $HasTabs" -ForegroundColor Yellow
if ($HasTabs) {
    Write-Host "[INFO] Tab Count: $TabCount" -ForegroundColor Yellow
}
Write-Host ""

# Check if file exists
if (Test-Path $screenPath) {
    Write-Host "[ERROR] File already exists: $screenPath" -ForegroundColor Red
    exit 1
}

# Create directory if not exists
$directory = Split-Path $screenPath -Parent
if (-not (Test-Path $directory)) {
    New-Item -ItemType Directory -Path $directory -Force | Out-Null
    Write-Host "[CREATED] Directory: $directory" -ForegroundColor Green
}

# Generate content based on type
if ($HasTabs) {
    # Generate tabs array
    $tabs = @()
    for ($i = 1; $i -le $TabCount; $i++) {
        $tabs += "            Tab(text: 'Tab $i', icon: Icon(Icons.view_list)),"
    }
    $tabsCode = $tabs -join "`n"
    
    # Generate tab builders
    $builders = @()
    for ($i = 1; $i -le $TabCount; $i++) {
        $builders += "          _buildTab$i(),"
    }
    $buildersCode = $builders -join "`n"
    
    # Generate tab methods
    $methods = @()
    for ($i = 1; $i -le $TabCount; $i++) {
        $methods += @"

  Widget _buildTab$i() {
    return Center(
      child: Text('Tab $i Content', style: TextStyle(fontSize: 24)),
    );
  }
"@
    }
    $methodsCode = $methods -join ""

    $content = @"
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/app_bars/standard_app_bar.dart';
import '../../utils/tab_navigation_mixin.dart';

/// $ScreenName - TODO: Add description
/// 
/// ⭐ มี Smart Back Navigation อัตโนมัติแล้ว
/// กด Back จะกลับ Tab ก่อนหน้า → กลับหน้าจริง
class $ScreenName extends StatefulWidget {
  const $ScreenName({super.key});

  @override
  State<$ScreenName> createState() => _${ScreenName}State();
}

class _${ScreenName}State extends State<$ScreenName>
    with TickerProviderStateMixin, TabNavigationMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: $TabCount, vsync: this);
    
    // ⭐ REQUIRED: Initialize Smart Back Navigation
    initTabNavigation(_tabController, initialTab: 0, fallbackRoute: '/dashboard');
  }

  @override
  void dispose() {
    // ⭐ REQUIRED: Dispose Smart Back Navigation
    disposeTabNavigation();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: StandardAppBar(
        type: AppBarType.main,
        title: '$ScreenName',
        // ⭐ REQUIRED: Enable Smart Back Navigation
        onBackPressed: handleSmartBackPress,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
$tabsCode
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
$buildersCode
        ],
      ),
    );
  }
$methodsCode
}
"@
} else {
    # Simple screen without tabs
    $content = @"
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/app_bars/standard_app_bar.dart';

/// $ScreenName - TODO: Add description
/// 
/// ⭐ StandardAppBar มี Back Navigation อัตโนมัติแล้ว
class $ScreenName extends StatefulWidget {
  const $ScreenName({super.key});

  @override
  State<$ScreenName> createState() => _${ScreenName}State();
}

class _${ScreenName}State extends State<$ScreenName> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: StandardAppBar(
        type: AppBarType.main,
        title: '$ScreenName',
        // StandardAppBar มี back navigation built-in แล้ว
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.construction, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              '$ScreenName',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'TODO: Implement screen content',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
"@
}

# Write file
$content | Out-File -FilePath $screenPath -Encoding UTF8

Write-Host "[SUCCESS] Created: $screenPath" -ForegroundColor Green
Write-Host ""
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "Next Steps:" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "1. Add route to router configuration" -ForegroundColor White
Write-Host "2. Add navigation from dashboard or menu" -ForegroundColor White
Write-Host "3. Implement screen content" -ForegroundColor White
Write-Host ""
Write-Host "✅ Smart Back Navigation is ALREADY INCLUDED!" -ForegroundColor Green
if ($HasTabs) {
    Write-Host "   - Tab History: Automatic" -ForegroundColor Green
    Write-Host "   - Back Button: handleSmartBackPress()" -ForegroundColor Green
}
Write-Host ""
