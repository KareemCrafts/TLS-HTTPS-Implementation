# Manual GitHub Push Commands

If you prefer to run commands manually instead of using the PowerShell script, follow these steps:

## Prerequisites

1. **Install Git for Windows:**
   - Download from: https://git-scm.com/download/win
   - Run installer and follow default options

2. **Create GitHub Repository:**
   - Go to: https://github.com/new
   - Repository name: `TLS-HTTPS-Implementation`
   - Description: `TLS/HTTPS Implementation - Networks Security CCY3201 Project`
   - **Keep it PUBLIC** (for portfolio visibility)
   - Don't initialize with README (we have our own)
   - Click "Create repository"

---

## Step-by-Step Commands

### 1. Navigate to Project Directory
```powershell
cd "C:\Users\$env:USERNAME\Documents\TLS-HTTPS-Implementation"
```

Or wherever you extracted the project files.

### 2. Initialize Git Repository
```powershell
git init
```

### 3. Configure Git User (First Time Only)
```powershell
git config user.name "Kareem Alshaer"
git config user.email "kareemtamer2512@gmail.com"
```

### 4. Create .gitignore File
```powershell
@"
# Private keys (NEVER commit these!)
*.key
keylog.txt

# Temporary files
*.tmp
*.log
*.csr
*.bak

# OS files
.DS_Store
Thumbs.db
"@ | Out-File -FilePath ".gitignore" -Encoding UTF8
```

### 5. Add All Files
```powershell
git add .
```

### 6. Check Status (Optional)
```powershell
git status
```

You should see:
- README.md
- images/ folder
- commands/ folder
- certificates/ folder (if any)

### 7. Commit Changes
```powershell
git commit -m "Add TLS/HTTPS Implementation Project - Networks Security CCY3201"
```

### 8. Rename Branch to 'main'
```powershell
git branch -M main
```

### 9. Add GitHub Remote
```powershell
git remote add origin https://github.com/KareemCrafts/TLS-HTTPS-Implementation.git
```

### 10. Push to GitHub
```powershell
git push -u origin main
```

**You'll be prompted for credentials:**
- Username: `KareemCrafts`
- Password: Use your **Personal Access Token** (not your GitHub password!)

---

## Creating a Personal Access Token (PAT)

Since GitHub no longer accepts passwords for Git operations, you need a PAT:

1. **Go to GitHub Settings:**
   - https://github.com/settings/tokens

2. **Generate New Token:**
   - Click "Generate new token (classic)"
   - Note: "Git operations for TLS project"
   - Expiration: 90 days (or custom)
   - Scopes: Check **repo** (all sub-options)
   - Click "Generate token"

3. **Copy the Token:**
   - **Save it somewhere safe!**
   - You won't be able to see it again
   - Use this as your password when pushing

---

## Verify Upload

After pushing successfully, visit:

**https://github.com/KareemCrafts/TLS-HTTPS-Implementation**

You should see:
- ✅ README.md with all documentation
- ✅ images/ folder with 9 screenshots
- ✅ commands/ folder with 3 reference files
- ✅ Nicely formatted project page

---

## Update Existing Repository

If you need to make changes and push again:

```powershell
# Navigate to project directory
cd "C:\Users\$env:USERNAME\Documents\TLS-HTTPS-Implementation"

# Add changed files
git add .

# Commit with message
git commit -m "Update documentation and screenshots"

# Push to GitHub
git push
```

---

## Troubleshooting

### Error: "repository not found"
**Solution:** Make sure you created the repository on GitHub first:
- Go to: https://github.com/new
- Create `TLS-HTTPS-Implementation` repository

### Error: "Authentication failed"
**Solution:** Use Personal Access Token instead of password
- Create token at: https://github.com/settings/tokens
- Use token as password when prompted

### Error: "Updates were rejected"
**Solution:** Pull changes first, then push:
```powershell
git pull origin main --rebase
git push origin main
```

### Error: "src refspec main does not match any"
**Solution:** Make sure you committed changes first:
```powershell
git add .
git commit -m "Initial commit"
git push -u origin main
```

---

## Alternative: GitHub Desktop

If you prefer a GUI instead of command line:

1. **Download GitHub Desktop:**
   - https://desktop.github.com/

2. **Install and sign in** with your GitHub account

3. **Add local repository:**
   - File → Add Local Repository
   - Choose `TLS-HTTPS-Implementation` folder

4. **Commit changes:**
   - Enter commit message
   - Click "Commit to main"

5. **Publish repository:**
   - Click "Publish repository"
   - Make it public
   - Click "Publish"

Done! Much easier than command line.

---

## Next Steps After Upload

1. **Update LinkedIn:**
   - Add project link to LinkedIn profile
   - Projects section: "TLS/HTTPS Implementation"
   - URL: https://github.com/KareemCrafts/TLS-HTTPS-Implementation

2. **Add to Resume:**
   - Projects section
   - Brief description: "Implemented mutual TLS authentication with PKI infrastructure, traffic capture, and Wireshark analysis"

3. **Pin Repository:**
   - Go to: https://github.com/KareemCrafts
   - Click "Customize your pins"
   - Select TLS-HTTPS-Implementation
   - Show to visitors

---

## Quick Reference

```powershell
# Clone from GitHub (if needed later)
git clone https://github.com/KareemCrafts/TLS-HTTPS-Implementation.git

# Pull latest changes
git pull

# Push updates
git add .
git commit -m "Update message"
git push

# Check status
git status

# View commit history
git log --oneline --graph
```
