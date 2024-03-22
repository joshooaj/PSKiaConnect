function Get-KiaVehicleInfo {
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipelineByPropertyName, Position = 0)]
        [string]
        $VehicleKey,

        # Specifies that fresh information should be retrieved without regard of the age of the last received information.
        [Parameter()]
        [switch]
        $Force,

        [Parameter()]
        [timespan]
        $MaxAge = [timespan]::FromMinutes(5)
    )

    process {
        if ([string]::IsNullOrWhiteSpace($VehicleKey)) {
            $VehicleKey = (Get-KiaVehicleSummary -ErrorAction Stop).VehicleKey
            if ($VehicleKey.Count -gt 1) {
                throw "When multiple vehicles are available, you must supply the appropriate VehicleKey."
            }
        }

        if (-not $Force -and $script:vehicle_info[$VehicleKey]) {
            $syncDate = [KiaMessageTimeStamp]$script:vehicle_info[$VehicleKey].lastVehicleInfo.location.syncDate
            if (([datetime]::UtcNow - $syncDate.Utc) -lt $MaxAge) {
                $script:vehicle_info[$VehicleKey]
                return
            }
        }

        $irm = @{
            WebSession = $script:kia_session
            Method     = 'Get'
            Uri        = 'https://owners.kia.com/apps/services/owners/getvehicleinfo.html/vehicle/1/maintenance/1/vehicleFeature/1/airTempRange/1/seatHeatCoolOption/1/enrollment/1/dtc/1/vehicleStatus/1/weather/1/location/1/dsAndUbiEligibilityInfo/1'
            Headers    = @{
                'Cache-Control' = 'no-cache'
                'Connection'    = 'keep-alive'
                'Content-Type'  = 'application/json'
                'dateStr'       = Get-Date -Format 'r'
                'offset'        = [datetimeoffset]::Now.Offset.TotalHours
                'Referer'       = 'https://owners.kia.com/content/owners/en/dashboard.html/'
                'sid'           = 'sid'
                'TE'            = 'trailers'
                'vinkey'        = $VehicleKey
            }
        }
        $response = HandleKiaRequest $irm
        $script:vehicle_info[$VehicleKey] = $response.Payload.VehicleInfoList[0]
        $script:vehicle_info[$VehicleKey]
    }
}
