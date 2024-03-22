function Get-Kia360View {
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipelineByPropertyName, Position = 0)]
        [string]
        $VehicleKey,

        [Parameter()]
        [int]
        $Count = 1
    )

    process {
        if ([string]::IsNullOrWhiteSpace($VehicleKey)) {
            $VehicleKey = (Get-KiaVehicleSummary -ErrorAction Stop).VehicleKey
            if ($VehicleKey.Count -gt 1) {
                throw "When multiple vehicles are available, you must supply the appropriate VehicleKey."
            }
        }

        $irm = @{
            WebSession = $script:kia_session
            Method     = 'Post'
            Uri        = 'https://owners.kia.com/apps/services/owners/apigwServlet.html'
            Headers    = @{
                'Content-Type' = 'application/json'
                'dateStr'      = Get-Date -Format 'r'
                'offset'       = [datetimeoffset]::Now.Offset.TotalHours
                'vinkey'       = $VehicleKey
                'httpMethod'   = 'POST'
                'apiURL'       = '/lbs/svm/inquire'
                'serviceType'  = 'postLoginVehicle'
                'Origin'       = 'https://owners.kia.com'
                'Connection'   = 'keep-alive'
                'Referer'      = 'https://owners.kia.com/content/owners/en/locations.html'
                'TE'           = 'trailers'
            }
            Body       = [pscustomobject]@{} | ConvertTo-Json -Compress
        }
        $response = HandleKiaRequest $irm

        for ($i = 0; $i -lt $Count; $i++) {
            if ($i + 1 -gt $response.Payload.svmInfos.Count) {
                break
            }
            # Add delay so as not to risk triggering rate limiting behavior on API.
            Start-Sleep -Seconds 10
            $snapshotId = $response.Payload.svmInfos[$i].svmId
            $irm = @{
                WebSession = $script:kia_session
                Method     = 'Post'
                Uri        = 'https://owners.kia.com/apps/services/owners/apigwServlet.html'
                Headers    = [ordered]@{
                    'Content-Type'    = 'application/json'
                    'dateStr'         = Get-Date -Format 'r'
                    'offset'          = [datetimeoffset]::Now.Offset.TotalHours
                    'vinkey'          = $VehicleKey
                    'httpMethod'      = 'POST'
                    'apiURL'          = '/lbs/svm/info'
                    'serviceType'     = 'postLoginVehicle'
                    'Origin'          = 'https://owners.kia.com'
                    'Connection'      = 'keep-alive'
                    'Referer'         = 'https://owners.kia.com/content/owners/en/locations.html/?page=360-view'
                }
                Body       = @{
                    svmId = $snapshotId
                } | ConvertTo-Json -Compress
            }
            $snapshotResponse = Invoke-RestMethod @irm
            [pscustomobject]@{
                SvmInfo = $response.Payload.svmInfos[$i]
                Svm     = $snapshotResponse
            }
        }
    }
}
