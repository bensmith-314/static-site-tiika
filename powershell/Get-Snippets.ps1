
function Get-HeadHTML {
    param(
        [Parameter(Mandatory)]
        [string]$Title,
        [string]$Description = "",
        [string[]]$Keywords = @(),
        [string]$ImageUrl = "https://tiika.co/icons/site-logos/site-logo-share.png",
        [string]$PageUrl = "",
        [string]$ImageDescription = "Tiika by Ben Smith"
    )

    $snippetPath = Join-Path $PSScriptRoot "../html_snippets/head.txt"
    $snippet = Get-Content $snippetPath -Raw

    $keywordString = ($Keywords -join ", ")

    if (-not $PageUrl){
        $PageUrl = "https://tiika.co"
    } 

    $snippet = $snippet.Replace("{{PAGE_TITLE}}", $Title)
    $snippet = $snippet.Replace("{{PAGE_DESCRIPTION}}", $Description)
    $snippet = $snippet.Replace("{{PAGE_KEYWORDS}}", $keywordString)
    $snippet = $snippet.Replace("{{PAGE_IMAGE}}", $ImageUrl)
    $snippet = $snippet.Replace("{{PAGE_URL}}", $PageUrl)
    $snippet = $snippet.Replace("{{IMAGE_DESCRIPTION}}", $ImageDescription)

    return $snippet
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