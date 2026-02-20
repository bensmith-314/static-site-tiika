# 1. Load metadata (manual overrides)
$metadataPath = Join-Path $PSScriptRoot "../json/artMetadata.json"
if (Test-Path $metadataPath) {
    $metadata = Get-Content $metadataPath -Raw | ConvertFrom-Json
} else {
    Write-Error "artMetadata.json doesn't exist at expected location in /json"
    exit
}

# 2. Count total pieces
$everydaysPath = Join-Path $PSScriptRoot "../everydays/"
$totalPieces = (Get-ChildItem $everydaysPath -Filter "*.jpg").Count

# 3. Generate full artInfo with defaults + overrides
$artInfo = [PSCustomObject]@{ art_pieces = @{} }
$startDay = Get-Date "March 22, 2021"

for ($i = 1; $i -le $totalPieces; $i++) {
    # Default values
    $date = $startDay.AddDays($i - 1).ToString("MMMM, d, yyyy")
    $piece = [PSCustomObject]@{
        date = $date
        application = "Adobe Illustrator"
    }
    
    # Apply manual overrides if they exist
    if ($metadata.art_pieces.PSObject.Properties[$i.ToString()]) {
        $override = $metadata.art_pieces.PSObject.Properties[$i.ToString()].Value
        foreach ($prop in $override.PSObject.Properties) {
            $piece | Add-Member -NotePropertyName $prop.Name -NotePropertyValue $prop.Value -Force
        }
    }
    
    $artInfo.art_pieces[$i.ToString()] = $piece
}

# 4. Write artInfo.json
$artInfoPath = Join-Path $PSScriptRoot "../json/artInfo.json"
$artInfo | ConvertTo-Json -Depth 10 | Set-Content $artInfoPath

Write-Host "Generated artInfo.json with $totalPieces pieces"