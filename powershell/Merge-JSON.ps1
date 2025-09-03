# Load the JSON files
$artDatesJSON = Join-Path $PSScriptRoot "../json/artDates.json"
$artMetaDataJSON = Join-Path $PSScriptRoot "../json/artMetadata.json"
$artInfoJSON = Join-Path $PSScriptRoot "../json/artInfo.json"

$artDates = Get-Content $artDatesJSON -Raw | ConvertFrom-Json
$artMetadata = Get-Content $artMetaDataJSON -Raw | ConvertFrom-Json

# Create $artInfo with art_pieces as an empty hashtable or PSCustomObject
$artInfo = [PSCustomObject]@{
    art_pieces = @{}
}

$keys = $artDates.art_pieces.PSObject.Properties.Name

foreach ($key in $keys) {

    # Start with the artDates entry
    $artInfo.art_pieces[$key] = $artDates.art_pieces.PSObject.Properties[$key].Value

    # If artMetadata has the same key, merge properties
    if ($null -ne $artMetadata.art_pieces.PSObject.Properties[$key]) {
        
        # Merge by adding properties individually
        foreach ($prop in $artMetadata.art_pieces.PSObject.Properties[$key].Value.PSObject.Properties) {
            $artInfo.art_pieces[$key] | Add-Member -NotePropertyName $prop.Name -NotePropertyValue $prop.Value -Force
        }
    }
}

# Convert back to JSON
$artInfo | ConvertTo-Json -Depth 10 | Set-Content $artInfoJSON