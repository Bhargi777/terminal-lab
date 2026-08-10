#!/usr/bin/env pwsh
<#
.SYNOPSIS
    DEPRECATED. Use termlab.ps1 instead.

.DESCRIPTION
    'bhargi' was this project's old personal branding; the CLI is now
    'termlab'. This shim exists only so old installs/aliases/muscle
    memory don't break outright — it will be removed in a future
    release. See docs/migration.md.
#>

param(
    [Parameter(ValueFromRemainingArguments = $true)]
    [string[]]$Args
)

Write-Warning "'bhargi.ps1' is deprecated, use 'termlab.ps1' instead (see docs/migration.md)"

& "$PSScriptRoot/termlab.ps1" @Args
