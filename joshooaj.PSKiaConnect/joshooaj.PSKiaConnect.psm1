# Dot source public/private functions when importing from source
if (Test-Path -Path $PSScriptRoot/Public) {
    $classes = @(Get-ChildItem -Path (Join-Path -Path $PSScriptRoot -ChildPath 'Classes/*.ps1') -Recurse -ErrorAction Stop)
    $public  = @(Get-ChildItem -Path (Join-Path -Path $PSScriptRoot -ChildPath 'Public/*.ps1')  -Recurse -ErrorAction Stop)
    $private = @(Get-ChildItem -Path (Join-Path -Path $PSScriptRoot -ChildPath 'Private/*.ps1') -Recurse -ErrorAction Stop)
    foreach ($import in @(($classes + $public + $private))) {
        try {
            . $import.FullName
        } catch {
            throw "Unable to dot source [$($import.FullName)]"
        }
    }

    Export-ModuleMember -Function $public.Basename
}


$script:web_request_history_length = 50
$script:web_request_history = [system.collections.generic.list[pscustomobject]]::new()
$script:kia_session = [Microsoft.PowerShell.Commands.WebRequestSession]::new()
$script:vehicleSummaries = [System.Collections.Generic.List[VehicleSummary]]::new()
$script:vehicle_info = @{}
$script:default_http_headers = @{
    'User-Agent'      = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:109.0) Gecko/20100101 Firefox/113.0'
    'Accept'          = 'application/json, text/plain, */*'
    'Accept-Language' = 'en-US,en;q=0.5'
    'Accept-Encoding' = 'gzip, deflate, br'
    'CSRF-Token'      = 'undefined'
    'Connection'      = 'keep-alive'
    'Sec-Fetch-Dest'  = 'empty'
    'Sec-Fetch-Mode'  = 'cors'
    'Sec-Fetch-Site'  = 'same-origin'
    'Sec-GPC'         = '1'
}
