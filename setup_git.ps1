# Set your GitHub username & email
$gitUserName = "Ron Wright"
$gitEmail = "ron.wright@clgi.org"
$repoURL = "https://github.com/your-username/your-repo.git"
$repoPath = "C:\Users\melba\OneDrive\Documents\terraform_build"

# Navigate to the repo directory
Set-Location -Path $repoPath

# Configure Git
git config --global user.name "$gitUserName"
git config --global user.email "$gitEmail"

# Check if Git repo exists, else initialize
if (!(Test-Path "$repoPath\.git")) {
    git init
    git remote add origin $repoURL
}

# Add and commit all files
git add .
git commit -m "Initial commit of Terraform and GitHub Actions workflow"

# Push to GitHub
git push -u origin main

Write-Host "Repository has been pushed to GitHub!"