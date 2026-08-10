#!/usr/bin/env pwsh
# termlab git (Windows) - thin wrapper, same safety rules as the zsh
# version: cleanup is always a dry run, nothing destructive runs itself.

param([string]$Sub = "status", [string[]]$Rest)

function Test-Repo {
    git rev-parse --is-inside-work-tree *> $null
    return $LASTEXITCODE -eq 0
}

if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    Write-Error "git not found on PATH."
    exit 1
}

switch ($Sub) {
    "status" {
        if (-not (Test-Repo)) { Write-Error "Not inside a Git repository."; exit 1 }
        git status -sb
    }
    "log" {
        if (-not (Test-Repo)) { Write-Error "Not inside a Git repository."; exit 1 }
        $n = $Rest[0] ?? 10
        git log --oneline --decorate -n $n
    }
    "branches" {
        if (-not (Test-Repo)) { Write-Error "Not inside a Git repository."; exit 1 }
        git branch -vv
    }
    "cleanup" {
        if (-not (Test-Repo)) { Write-Error "Not inside a Git repository."; exit 1 }
        Write-Host "Merged local branches (not deleted automatically):"
        git branch --merged | Where-Object { $_ -notmatch '^\*|main|master' }
        Write-Host ""
        Write-Host "Untracked files 'git clean' would remove (dry run):"
        git clean -ndx
    }
    "info" {
        if (-not (Test-Repo)) { Write-Error "Not inside a Git repository."; exit 1 }
        Write-Host "Repo    : $(Split-Path -Leaf (git rev-parse --show-toplevel))"
        Write-Host "Branch  : $(git rev-parse --abbrev-ref HEAD)"
        $remote = git remote get-url origin 2>$null
        Write-Host "Remote  : $(if ($remote) { $remote } else { 'none' })"
        Write-Host "Commits : $(git rev-list --count HEAD)"
    }
    { $_ -in "-h", "--help", "help" } {
        Write-Host "termlab git [subcommand]"
        Write-Host "  status (default)   short status"
        Write-Host "  log [n]            recent commits"
        Write-Host "  branches           local branches with tracking info"
        Write-Host "  cleanup            dry-run report only"
        Write-Host "  info               repo summary"
    }
    default { Write-Error "Unknown git subcommand: $Sub" }
}
