# Version Control Guide - Farm Management System

## 📋 Current Version Status

### Version 1.0.0 (Production)
- **GitHub Tag**: `v1.0`
- **Commit**: `b246eb4`
- **GitHub Pages**: https://narasakp.github.io/farm-management/
- **Status**: Stable production version with 7-card dashboard

### Version 2.0.0 (Development)
- **Status**: In development with font accessibility improvements
- **Features**: Enhanced font sizes for elderly users, research module, improved feedback system

---

## 🔄 Version Rollback Procedures

### Method 1: Rollback via Git Tags
```bash
# View all available versions
git tag -l

# Checkout to Version 1.0
git checkout v1.0

# Create a new branch from v1.0 (optional)
git checkout -b rollback-to-v1.0

# Return to main branch
git checkout main
```

### Method 2: Rollback via Commit Hash
```bash
# Rollback to specific commit (Version 1.0)
git checkout b246eb4

# Create new branch from this point
git checkout -b version-1.0-restore

# Push the rollback branch
git push origin version-1.0-restore
```

### Method 3: Hard Reset (Destructive)
```bash
# WARNING: This will lose all changes after v1.0
git reset --hard v1.0
git push origin main --force
```

---

## 🌐 GitHub Pages Access

### Production URLs
- **Current Live Version**: https://narasakp.github.io/farm-management/
- **Repository**: https://github.com/narasakp/farm-management

### Version-Specific Access
- **Version 1.0**: Available via GitHub Pages (current deployment)
- **Version 2.0**: Will be deployed after testing completion

---

## 📦 Deployment Commands

### Deploy Version 2.0
```bash
# Add all changes
git add .

# Commit with version message
git commit -m "feat: Version 2.0 - Enhanced accessibility with larger fonts for elderly users"

# Tag the new version
git tag v2.0

# Push changes and tags
git push origin main
git push origin v2.0

# Deploy to GitHub Pages (if needed)
git subtree push --prefix build/web origin gh-pages
```

### Emergency Rollback to Production
```bash
# Quick rollback to v1.0
git checkout v1.0
git checkout -b emergency-rollback
git push origin emergency-rollback

# Update GitHub Pages to v1.0
git checkout v1.0
git subtree push --prefix build/web origin gh-pages --force
```

---

## 🔍 Version Comparison

| Feature | Version 1.0 | Version 2.0 |
|---------|-------------|-------------|
| Dashboard Cards | 7 cards | 15 cards |
| Font Size | Standard (12-16pt) | Enhanced (16-24pt+) |
| Research Module | Basic/Disabled | Fully Functional |
| Feedback System | Basic | Enhanced with floating icon |
| Accessibility | Standard | Elderly-friendly |
| Build Status | Stable | Testing |

---

## 🚀 **Command Execution Guidelines: CMD vs Windsurf**

### **📋 Windows CMD Commands (แสดงปุ่ม 📋 คัดลอก)**

#### **Git Operations (Safe & Fast):**
```cmd
git status
git add .
git commit -m "message"
git push origin main
git pull origin main
git log --oneline
```

#### **Flutter Development:**
```cmd
flutter build web --release --no-source-maps --no-tree-shake-icons --base-href="/farm-management/"
flutter clean
flutter pub get
flutter doctor
```

#### **File Operations:**
```cmd
copy build\web\* .
del filename.txt
mkdir foldername
.\deploy.bat
```

#### **Local Server:**
```cmd
python -m http.server 8080 --directory build/web
```

### **🛡️ Windsurf Run Commands (แสดงปุ่ม ▶️ Run)**

#### **Destructive Operations:**
```bash
# ⚠️ อันตราย - ลบไฟล์
rm -rf folder/
git reset --hard HEAD
git push --force

# System Changes
npm install -g package
pip install package
```

#### **Complex Multi-step:**
```bash
# Multi-command operations
flutter build web && git add . && git commit && git push

# File modifications with logic
find . -name "*.dart" -exec sed -i 's/old/new/g' {} \;
```

#### **Unknown/First Time:**
```bash
# เมื่อไม่แน่ใจผลลัพธ์
git rebase -i HEAD~5
docker run complex-command
```

### **💡 Quick Decision Rules:**
- **รู้จัก + ปลอดภัย + ใช้บ่อย = 📋 CMD**
- **อันตราย + ซับซ้อน + ไม่แน่ใจ = ▶️ Windsurf**

---

## ⚠️ Important Notes

1. **Always test locally** before pushing to production
2. **Use tags** for version management instead of branch names
3. **Keep CHANGELOG.md updated** with each version
4. **GitHub Pages** automatically deploys from `gh-pages` branch
5. **Backup important data** before major version changes
6. **Use CMD for speed**, **Windsurf for safety**
