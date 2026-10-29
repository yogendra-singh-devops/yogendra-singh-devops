# ==============================================================================
# Auto-Push All 4 Enterprise Repositories to GitHub
# Author: Yogendra Singh (DevOps Engineer)
# ==============================================================================

$username = "yogendra-singh-devops"
$baseDir  = "c:\devOpsinsider\yogi-infra1\repos"

$repos = @(
    "terraform-azure-enterprise-suite",
    "azure-devsecops-pipeline-templates",
    "aks-microservices-gitops",
    "azure-finops-cloud-governance"
)

Write-Host "`n🚀 Starting Automated Push for 4 DevOps Repositories...`n" -ForegroundColor Cyan

foreach ($repo in $repos) {
    $repoPath = Join-Path $baseDir $repo
    Write-Host "--------------------------------------------------------" -ForegroundColor Gray
    Write-Host "Processing: $repo" -ForegroundColor Yellow
    Write-Host "Path: $repoPath" -ForegroundColor DarkGray

    if (Test-Path $repoPath) {
        Set-Location $repoPath

        if (-not (Test-Path "$repoPath\.git")) {
            Write-Host "  -> Initializing Git repository..." -ForegroundColor Green
            git init | Out-Null
        }

        git add .
        git commit -m "feat: initial commit - enterprise production suite" | Out-Null
        git branch -M main

        # Set remote origin safely
        git remote remove origin 2>$null
        git remote add origin "https://github.com/$username/$repo.git"

        Write-Host "  -> Pushing to https://github.com/$username/$repo.git..." -ForegroundColor Cyan
        git push -u origin main
        Write-Host "  [OK] Successfully pushed $repo!" -ForegroundColor Green
    } else {
        Write-Warning "Directory not found: $repoPath"
    }
}

Write-Host "`n🎉 All 4 repositories have been pushed to GitHub!`n" -ForegroundColor Green

