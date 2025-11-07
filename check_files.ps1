# Quick File Checker - ตรวจสอบไฟล์ที่จำเป็นทั้งหมด

Write-Host "📁 Checking Social Commerce Files..." -ForegroundColor Cyan
Write-Host ""

$filesOK = 0
$filesMissing = 0
$filesTotal = 0

function Check-File {
    param([string]$Path, [string]$Description)
    
    $script:filesTotal++
    
    if (Test-Path $Path) {
        Write-Host "✅ $Description" -ForegroundColor Green
        Write-Host "   $Path" -ForegroundColor Gray
        $script:filesOK++
    } else {
        Write-Host "❌ $Description" -ForegroundColor Red
        Write-Host "   $Path" -ForegroundColor Gray
        $script:filesMissing++
    }
}

Write-Host "═══ Models ═══" -ForegroundColor Yellow
Check-File "lib\models\social_share.dart" "SocialShare Model"
Check-File "lib\models\deep_link_click.dart" "DeepLinkClick Model"
Check-File "lib\models\trading.dart" "Trading Model (updated)"

Write-Host ""
Write-Host "═══ Services ═══" -ForegroundColor Yellow
Check-File "lib\services\social_commerce\share_service.dart" "Share Service"
Check-File "lib\services\social_commerce\deep_link_service.dart" "Deep Link Service"
Check-File "lib\services\social_commerce\template_generator.dart" "Template Generator"
Check-File "lib\services\social_commerce\image_upload_service.dart" "Image Upload Service"
Check-File "lib\services\social_commerce\order_service.dart" "Order Service"
Check-File "lib\services\social_commerce\analytics_service.dart" "Analytics Service"
Check-File "lib\services\social_commerce\router_integration.dart" "Router Integration"

Write-Host ""
Write-Host "═══ Platform Services ═══" -ForegroundColor Yellow
Check-File "lib\services\social_commerce\platforms\facebook_service.dart" "Facebook Service"
Check-File "lib\services\social_commerce\platforms\tiktok_service.dart" "TikTok Service"
Check-File "lib\services\social_commerce\platforms\twitter_service.dart" "Twitter Service"
Check-File "lib\services\social_commerce\platforms\line_service.dart" "LINE Service"

Write-Host ""
Write-Host "═══ Screens ═══" -ForegroundColor Yellow
Check-File "lib\screens\social_commerce\share_dialog.dart" "Share Dialog"
Check-File "lib\screens\social_commerce\quick_buy_screen.dart" "Quick Buy Screen"
Check-File "lib\screens\social_commerce\analytics_dashboard_screen.dart" "Analytics Dashboard"

Write-Host ""
Write-Host "═══ Widgets ═══" -ForegroundColor Yellow
Check-File "lib\widgets\social_commerce\share_preview_card.dart" "Share Preview Card"

Write-Host ""
Write-Host "═══ Config ═══" -ForegroundColor Yellow
Check-File "lib\config\deep_link_config.dart" "Deep Link Config"

Write-Host ""
Write-Host "═══ Tests ═══" -ForegroundColor Yellow
Check-File "test\models\social_share_test.dart" "SocialShare Tests"
Check-File "test\services\share_service_test.dart" "ShareService Tests"
Check-File "test\widgets\share_dialog_test.dart" "ShareDialog Tests"
Check-File "integration_test\share_and_purchase_flow_test.dart" "E2E Tests"

Write-Host ""
Write-Host "═══════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "  Summary" -ForegroundColor Cyan
Write-Host "═══════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "Total Files: $filesTotal" -ForegroundColor White
Write-Host "✅ OK: $filesOK" -ForegroundColor Green
Write-Host "❌ Missing: $filesMissing" -ForegroundColor Red
Write-Host ""

if ($filesMissing -gt 0) {
    Write-Host "WARNING: Some files are missing!" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "TIP: Send this message to Cascade:" -ForegroundColor Cyan
    Write-Host "Missing $filesMissing files. Please create them." -ForegroundColor Gray
    Write-Host ""
} else {
    Write-Host "SUCCESS: All files present! Ready to test!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Next step: Run .\fix_errors.ps1" -ForegroundColor Cyan
}

Write-Host "═══════════════════════════════════════════" -ForegroundColor Cyan
