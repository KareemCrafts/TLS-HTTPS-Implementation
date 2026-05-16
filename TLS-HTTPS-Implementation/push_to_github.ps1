# PowerShell Script to Push TLS Project to GitHub
# Author: Kareem Alshaer
# Date: May 2026

# Colors for output
$successColor = "Green"
$errorColor = "Red"
$infoColor = "Cyan"

Write-Host "`n========================================" -ForegroundColor $infoColor
Write-Host "  TLS Project GitHub Upload Script" -ForegroundColor $infoColor
Write-Host "========================================`n" -ForegroundColor $infoColor

# Configuration
$projectPath = "C:\Users\$env:USERNAME\Documents\TLS-HTTPS-Implementation"
$githubUsername = "KareemCrafts"
$repoName = "TLS-HTTPS-Implementation"

# Check if Git is installed
Write-Host "[INFO] Checking Git installation..." -ForegroundColor $infoColor
$gitVersion = git --version 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "[ERROR] Git is not installed! Please install Git first." -ForegroundColor $errorColor
    Write-Host "Download from: https://git-scm.com/download/win" -ForegroundColor $infoColor
    exit 1
}
Write-Host "[SUCCESS] Git is installed: $gitVersion" -ForegroundColor $successColor

# Navigate to project directory
Write-Host "`n[INFO] Navigating to project directory..." -ForegroundColor $infoColor
if (-Not (Test-Path $projectPath)) {
    Write-Host "[ERROR] Project directory not found: $projectPath" -ForegroundColor $errorColor
    Write-Host "[INFO] Please update the `$projectPath variable in this script" -ForegroundColor $infoColor
    exit 1
}
Set-Location $projectPath
Write-Host "[SUCCESS] Current directory: $(Get-Location)" -ForegroundColor $successColor

# Initialize Git repository if not already initialized
Write-Host "`n[INFO] Initializing Git repository..." -ForegroundColor $infoColor
if (-Not (Test-Path ".git")) {
    git init
    Write-Host "[SUCCESS] Git repository initialized" -ForegroundColor $successColor
} else {
    Write-Host "[INFO] Git repository already initialized" -ForegroundColor $infoColor
}

# Create .gitignore file
Write-Host "`n[INFO] Creating .gitignore file..." -ForegroundColor $infoColor
@"
# Private keys (NEVER commit these!)
*.key
keylog.txt

# Temporary files
*.tmp
*.log
*.swp
*~

# OS files
.DS_Store
Thumbs.db
desktop.ini

# IDE files
.vscode/
.idea/
*.sublime-*

# Certificate signing requests (temporary)
*.csr

# Backup files
*.bak
*.backup
"@ | Out-File -FilePath ".gitignore" -Encoding UTF8
Write-Host "[SUCCESS] .gitignore created" -ForegroundColor $successColor

# Configure Git user (if not already configured)
Write-Host "`n[INFO] Configuring Git user..." -ForegroundColor $infoColor
$gitUserName = git config user.name 2>&1
$gitUserEmail = git config user.email 2>&1

if ([string]::IsNullOrEmpty($gitUserName)) {
    git config user.name "Kareem Alshaer"
    Write-Host "[SUCCESS] Git user.name set to: Kareem Alshaer" -ForegroundColor $successColor
} else {
    Write-Host "[INFO] Git user.name already set to: $gitUserName" -ForegroundColor $infoColor
}

if ([string]::IsNullOrEmpty($gitUserEmail)) {
    git config user.email "kareemtamer2512@gmail.com"
    Write-Host "[SUCCESS] Git user.email set to: kareemtamer2512@gmail.com" -ForegroundColor $successColor
} else {
    Write-Host "[INFO] Git user.email already set to: $gitUserEmail" -ForegroundColor $infoColor
}

# Add all files
Write-Host "`n[INFO] Adding all files to Git..." -ForegroundColor $infoColor
git add .
Write-Host "[SUCCESS] All files added" -ForegroundColor $successColor

# Show status
Write-Host "`n[INFO] Git status:" -ForegroundColor $infoColor
git status --short

# Commit changes
Write-Host "`n[INFO] Committing changes..." -ForegroundColor $infoColor
$commitMessage = "Add TLS/HTTPS Implementation Project - Networks Security CCY3201

- Complete PKI infrastructure with Root CA and signed certificates
- Mutual TLS authentication implementation
- OpenSSL s_server and s_client applications
- Wireshark traffic capture and analysis (encrypted and decrypted)
- Comprehensive documentation with screenshots
- Certificate generation commands
- Server/client configuration guide
- Wireshark decryption setup

Project completed for Networks Security (CCY3201) at AASTMT
Grade: 15/15 marks
Instructor: Prof. Dr. Ayman Adel Abdel-Hamid
Student ID: 231012043"

git commit -m $commitMessage
if ($LASTEXITCODE -eq 0) {
    Write-Host "[SUCCESS] Changes committed successfully" -ForegroundColor $successColor
} else {
    Write-Host "[ERROR] Commit failed! Check error messages above." -ForegroundColor $errorColor
    exit 1
}

# Add remote repository
Write-Host "`n[INFO] Adding GitHub remote repository..." -ForegroundColor $infoColor
$remoteUrl = "https://github.com/$githubUsername/$repoName.git"

# Check if remote already exists
$remoteExists = git remote get-url origin 2>&1
if ($LASTEXITCODE -eq 0) {
    Write-Host "[INFO] Remote 'origin' already exists: $remoteExists" -ForegroundColor $infoColor
    Write-Host "[INFO] Updating remote URL..." -ForegroundColor $infoColor
    git remote set-url origin $remoteUrl
} else {
    git remote add origin $remoteUrl
    Write-Host "[SUCCESS] Remote added: $remoteUrl" -ForegroundColor $successColor
}

# Get current branch name
$currentBranch = git branch --show-current
if ([string]::IsNullOrEmpty($currentBranch)) {
    $currentBranch = "main"
    git branch -M $currentBranch
    Write-Host "[INFO] Renamed branch to: $currentBranch" -ForegroundColor $infoColor
}

# Push to GitHub
Write-Host "`n[INFO] Pushing to GitHub..." -ForegroundColor $infoColor
Write-Host "[INFO] Repository: $remoteUrl" -ForegroundColor $infoColor
Write-Host "[INFO] Branch: $currentBranch" -ForegroundColor $infoColor
Write-Host "`n[IMPORTANT] You may be prompted for GitHub credentials!" -ForegroundColor "Yellow"
Write-Host "If using Personal Access Token, use it as the password." -ForegroundColor "Yellow"

git push -u origin $currentBranch

if ($LASTEXITCODE -eq 0) {
    Write-Host "`n========================================" -ForegroundColor $successColor
    Write-Host "  SUCCESS! Project pushed to GitHub!" -ForegroundColor $successColor
    Write-Host "========================================" -ForegroundColor $successColor
    Write-Host "`nView your project at:" -ForegroundColor $infoColor
    Write-Host "https://github.com/$githubUsername/$repoName`n" -ForegroundColor "Cyan"
} else {
    Write-Host "`n========================================" -ForegroundColor $errorColor
    Write-Host "  ERROR! Push failed!" -ForegroundColor $errorColor
    Write-Host "========================================" -ForegroundColor $errorColor
    Write-Host "`nPossible issues:" -ForegroundColor $infoColor
    Write-Host "1. Repository doesn't exist on GitHub - create it first at:" -ForegroundColor $infoColor
    Write-Host "   https://github.com/new" -ForegroundColor "Cyan"
    Write-Host "2. Authentication failed - check your credentials" -ForegroundColor $infoColor
    Write-Host "3. No internet connection`n" -ForegroundColor $infoColor
    exit 1
}

Write-Host "`n[INFO] Script completed!" -ForegroundColor $infoColor
Write-Host "================================================`n" -ForegroundColor $infoColor
