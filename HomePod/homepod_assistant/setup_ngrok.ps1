# Setup script for ngrok authentication
Write-Host "🔧 ngrok Setup for Real Voice Input" -ForegroundColor Green
Write-Host "=====================================" -ForegroundColor Green

Write-Host "📋 To get real voice working, you need to:" -ForegroundColor Yellow
Write-Host "1. Sign up at: https://dashboard.ngrok.com/signup" -ForegroundColor Cyan
Write-Host "2. Get your authtoken at: https://dashboard.ngrok.com/get-started/your-authtoken" -ForegroundColor Cyan
Write-Host "3. Run this command with your token:" -ForegroundColor Cyan
Write-Host ""
Write-Host "   ngrok config add-authtoken YOUR_TOKEN_HERE" -ForegroundColor White
Write-Host ""
Write-Host "4. Then run: .\run_with_https.ps1" -ForegroundColor Cyan

Write-Host ""
Write-Host "💡 Alternative: Test on a real device with HTTPS" -ForegroundColor Yellow
Write-Host "   - Deploy to a web server with HTTPS" -ForegroundColor Yellow
Write-Host "   - Use a service like Vercel, Netlify, or GitHub Pages" -ForegroundColor Yellow

Write-Host ""
Write-Host "🎯 Current Status:" -ForegroundColor Green
Write-Host "   ✅ Volume detection working (3-5%)" -ForegroundColor Green
Write-Host "   ❌ HTTPS required for microphone access" -ForegroundColor Red
Write-Host "   🧪 Currently in test mode" -ForegroundColor Yellow 