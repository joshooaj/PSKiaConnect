function Update-KiaVehicleInfo {
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipelineByPropertyName, Position = 0)]
        [string[]]
        $VehicleKey
    )

    process {
        if ($VehicleKey.Count -eq 0) {
            $VehicleKey = (Get-KiaVehicleSummary -ErrorAction Stop).VehicleKey
            if ($VehicleKey.Count -gt 1) {
                throw "When multiple vehicles are available, you must supply the appropriate VehicleKey."
            }
        }

        foreach ($vinKey in $VehicleKey) {
            $irm = @{
                WebSession = $script:kia_session
                Method  = 'Get'
                Uri     = 'https://owners.kia.com/apps/services/owners/overviewvehicledata?requestJson={"action":"ACTION_REMOTE_PAGE_LAST_REFRESHED_STATUS_FULL_LOOP"}'
                Headers = [ordered]@{
                    'User-Agent'      = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:109.0) Gecko/20100101 Firefox/113.0'
                    'Accept'          = 'application/json, text/plain, */*'
                    'Accept-Language' = 'en-US,en;q=0.5'
                    'Accept-Encoding' = 'gzip, deflate, br'
                    'Content-Type'    = 'application/x-www-form-urlencoded'
                    'CSRF-Token'      = 'undefined'
                    'vinkey'          = $VinKey
                    'sid'             = 'sid'
                    'Connection'      = 'keep-alive'
                    'Referer'         = 'https://owners.kia.com/content/owners/en/remote.html?page=security'
                    'Sec-Fetch-Dest'  = 'empty'
                    'Sec-Fetch-Mode'  = 'cors'
                    'Sec-Fetch-Site'  = 'same-origin'
                    'Sec-GPC'         = '1'
                }
            }
            HandleKiaRequest $irm
        }
    }
}
