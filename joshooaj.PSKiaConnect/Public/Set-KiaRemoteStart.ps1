function Set-KiaRemoteStart {
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipelineByPropertyName, Position = 0)]
        [string]
        $VehicleKey,

        [Parameter(Mandatory)]
        [bool]
        $AutoLock
    )

    process {
        if ([string]::IsNullOrWhiteSpace($VehicleKey)) {
            $VehicleKey = (Get-KiaVehicleSummary -ErrorAction Stop).VehicleKey
            if ($VehicleKey.Count -gt 1) {
                throw "When multiple vehicles are available, you must supply the appropriate VehicleKey."
            }
        }

        # The current value of comboCommand seems to maybe be in the /rems/getsch response instead of the vehicle info.
        # $vehicleInfo = Get-KiaVehicleInfo -VehicleKey $VehicleKey
        # $comboCommand = $vehicleInfo.vehicleConfig.vehicleFeature.remoteFeature.comboCommand
        # if (($comboCommand -as [bool]) -eq $AutoLock) {
        #     Write-Verbose "Vehicle comboCommand value already $comboCommand."
        #     return
        # }

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
                'Referer'      = 'https://owners.kia.com/content/owners/en/remote.html?page=climate'
                'TE'           = 'trailers'
            }
            Body = [pscustomobject]@{
                actionType    = 2
                remoteClimate = [pscustomobject]@{
                    comboCommand = [int]$AutoLock
                }
            } | ConvertTo-Json -Compress
        }
        $null = HandleKiaRequest $irm
    }
}
