# 📤 File Upload System - Testing Guide

## 🚀 Setup Instructions

### 1. Install Multer
```bash
cd D:\Code\farm\backend
npm install multer --save
```

Or run:
```bash
.\install_multer.bat
```

### 2. Update Database Schema
```bash
node update_feedback_attachments.js
```

This will:
- Check if `attachments` column exists
- Add it if missing (TEXT type for JSON storage)

### 3. Restart Backend Server
```bash
node server.js
```

Look for:
```
✅ Static uploads folder served at /uploads
✅ Upload routes registered
```

---

## 📂 File Size Limits

| Category | Max Size | Extensions |
|----------|----------|------------|
| **Images** | **5 MB** | JPG, JPEG, JFIF, PNG, WEBP, GIF, SVG |
| **PDF** | **10 MB** | PDF |
| **Documents** | **5 MB** | DOC, DOCX, XLS, XLSX, PPT, PPTX |
| **Videos** | **50 MB** | MP4, AVI, MOV |
| **Audio** | **10 MB** | MP3, WAV |
| **Archives** | **20 MB** | ZIP, RAR, 7Z |
| **Text** | **5 MB** | TXT, CSV, JSON, XML |

**Max Files**: 10 files per feedback

---

## 🧪 Testing Steps

### Step 1: Test Upload Endpoint

```bash
curl -X GET http://localhost:3000/api/upload/limits
```

Expected response:
```json
{
  "success": true,
  "limits": {
    "image": "5.0 MB",
    "pdf": "10.0 MB",
    "document": "5.0 MB",
    "video": "50.0 MB",
    "audio": "10.0 MB",
    "archive": "20.0 MB",
    "default": "5.0 MB"
  },
  "allowedExtensions": {...},
  "maxFiles": 10
}
```

### Step 2: Test in Flutter App

1. **Hot Restart** Flutter app (`R` in terminal)
2. Navigate to: http://localhost:8096/#/feedback
3. Tab: "ส่งข้อเสนอแนะ"
4. Fill form fields
5. Click **"เลือกไฟล์"**
6. Select 1-10 files (images, PDFs, docs, etc.)
7. Verify files appear in list with:
   - ✅ Icon based on type
   - ✅ File name
   - ✅ File size
   - ✅ Delete button (X)
8. Click **"ส่งข้อเสนอแนะ"**
9. Check console for:
   ```
   📤 Uploading 3 files...
   📡 [FeedbackProvider] Sending upload request...
   📥 [FeedbackProvider] Upload response: 200
   ✅ [FeedbackProvider] Uploaded 3 files
   ```

### Step 3: Verify in Database

```bash
node backend/show_all_feedback.js
```

Check `attachments` field contains JSON array of URLs:
```json
["/ uploads/feedback/1730214400-abc123-file1.jpg", "/uploads/feedback/1730214401-def456-file2.pdf"]
```

### Step 4: Access Uploaded Files

Open browser:
```
http://localhost:3000/uploads/feedback/[filename]
```

Example:
```
http://localhost:3000/uploads/feedback/1730214400-abc123-document.pdf
```

---

## 🐛 Troubleshooting

### Issue 1: "Cannot find module 'multer'"

**Solution**:
```bash
cd D:\Code\farm\backend
npm install multer --save
```

### Issue 2: "413 File too large"

**Cause**: File exceeds category limit

**Check**: Review file size limits table above

**Solution**: 
- Compress image files
- Split large videos
- Use archives for multiple files

### Issue 3: "No such file or directory: uploads/feedback"

**Cause**: Upload directory not created

**Solution**: Restart server (it auto-creates on startup)

### Issue 4: Files uploaded but not visible

**Cause**: Static files not served

**Check server.js**:
```javascript
app.use('/uploads', express.static(path.join(__dirname, 'uploads')));
```

**Solution**: Restart server

---

## 📝 API Reference

### POST /api/upload/feedback

Upload files for feedback

**Request**: `multipart/form-data`
- Field name: `files` (array)
- Max files: 10

**Response**:
```json
{
  "success": true,
  "message": "อัปโหลด 3 ไฟล์สำเร็จ",
  "files": [
    {
      "originalName": "document.pdf",
      "filename": "1730214400-abc123-document.pdf",
      "url": "/uploads/feedback/1730214400-abc123-document.pdf",
      "size": 1048576,
      "mimetype": "application/pdf",
      "category": "pdf",
      "uploadedAt": "2025-10-29T13:00:00.000Z"
    }
  ]
}
```

### DELETE /api/upload/feedback/:filename

Delete uploaded file

**Response**:
```json
{
  "success": true,
  "message": "ลบไฟล์สำเร็จ"
}
```

### GET /api/upload/limits

Get file size limits and allowed extensions

---

## ✅ Success Checklist

- [ ] Multer installed
- [ ] Database schema updated
- [ ] Backend server restarted
- [ ] Upload endpoint accessible
- [ ] Can select files in Flutter UI
- [ ] Files appear in list with details
- [ ] Upload progress visible
- [ ] Files saved to `backend/uploads/feedback/`
- [ ] URLs stored in database
- [ ] Can access files via browser
- [ ] File size limits enforced
- [ ] Max 10 files enforced
- [ ] Can delete files from list
- [ ] Unsupported file types rejected

---

## 📊 Database Schema

```sql
CREATE TABLE feedback (
  id TEXT PRIMARY KEY,
  user_id TEXT NOT NULL,
  user_name TEXT NOT NULL,
  email TEXT,
  phone TEXT,
  type TEXT NOT NULL,
  category TEXT NOT NULL,
  subject TEXT NOT NULL,
  message TEXT NOT NULL,
  rating INTEGER DEFAULT 5,
  attachments TEXT,  -- JSON array: ["url1", "url2"]
  priority TEXT DEFAULT 'medium',
  status TEXT DEFAULT 'pending',
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME,
  admin_response TEXT,
  responded_at DATETIME
);
```

---

**Last Updated**: 2025-10-29
**Version**: 1.0.0
