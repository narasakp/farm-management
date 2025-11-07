# Pull Request Checklist

## 📋 Before You Submit

### 🔍 Duplicate Check (CRITICAL)
- [ ] Searched `SCREEN_INVENTORY.md` for similar screens
- [ ] Searched codebase: `grep -r "similar_feature" lib/`
- [ ] Checked existing screens can't be extended instead
- [ ] Verified route doesn't already exist in `lib/main.dart`

### 📝 Documentation
- [ ] Updated `SCREEN_INVENTORY.md` if adding/removing screens
- [ ] Updated `AdminNavigationConfig` if admin feature
- [ ] Added comments explaining architectural decisions
- [ ] Updated README if user-facing change

### ✅ Code Quality
- [ ] No duplicate code (checked similar files)
- [ ] Used centralized configs (not hardcoded routes)
- [ ] Followed existing patterns
- [ ] No commented-out code

### 🧪 Testing
- [ ] Tested feature manually
- [ ] Tested on fresh build (`flutter clean` + `flutter run`)
- [ ] Checked for console errors
- [ ] Verified navigation works correctly

### 🏗️ Architecture
- [ ] Feature added to existing screen (if possible)
- [ ] New screen justified (documented reason)
- [ ] Consistent with app architecture
- [ ] No breaking changes (or documented)

---

## 📄 Description

**What does this PR do?**

(Describe the feature/fix)

**Why is this needed?**

(Explain the problem this solves)

---

## 🎯 Type of Change

- [ ] Bug fix
- [ ] New feature
- [ ] Refactoring
- [ ] Documentation
- [ ] Performance improvement

---

## 📸 Screenshots (if UI change)

(Add screenshots here)

---

## 🔗 Related Issues

Fixes #(issue number)

---

## ⚠️ Breaking Changes

- [ ] None
- [ ] Yes (describe below)

(If yes, describe migration path)

---

## 🚨 Admin Screen Changes? (Special Attention Required)

If this PR modifies admin screens:

- [ ] Checked `AdminNavigationConfig` for existing routes
- [ ] Verified no duplicate admin screens being created
- [ ] Added to `/admin-dashboard` tabs (if user management)
- [ ] Updated `SCREEN_INVENTORY.md` admin section

**Reason for new admin screen (if applicable):**

(Justify why this can't be added to existing screen)

---

## 📚 Documentation References

- SCREEN_INVENTORY.md: (link to relevant section)
- Knowledge Base: (link if related to known issue)
- Architecture Doc: (if making architectural change)
