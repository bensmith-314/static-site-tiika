
function Get-HeadHTML {
    return Get-Content $(Join-Path $PSScriptRoot "../html_snippets/head.txt")
}

function Get-NavHTML {
    return Get-Content $(Join-Path $PSScriptRoot "../html_snippets/nav.txt")
}

function Get-FootHTML {
    return Get-Content $(Join-Path $PSScriptRoot "../html_snippets/foot.txt")
}

function Convert-MarkdownToHtml {
    param (
        [Parameter(Mandatory)]
        [string]$MarkdownPath,

        [string]$PythonScript = (Join-Path $PSScriptRoot "../python/Generate-Markdown.py")
    )

    $resolvedMarkdownPath = $MarkdownPath

    Write-Host $PythonScript

    if (-not (Test-Path $resolvedMarkdownPath)) {
        throw "Markdown file '$resolvedMarkdownPath' does not exist."
    }
    if (-not (Test-Path $PythonScript)) {
        throw "Python script '$PythonScript' not found."
    }

    # Run the Python script, capture the output
    $html = & python3 $PythonScript $resolvedMarkdownPath

    return $html
}