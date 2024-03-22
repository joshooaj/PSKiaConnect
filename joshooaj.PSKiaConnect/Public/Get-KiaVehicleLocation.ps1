function Get-KiaVehicleLocation {
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipelineByPropertyName, Position = 0)]
        [string]
        $VehicleKey
    )

    process {
        if ([string]::IsNullOrWhiteSpace($VehicleKey)) {
            $VehicleKey = (Get-KiaVehicleSummary -ErrorAction Stop).VehicleKey
            if ($VehicleKey.Count -gt 1) {
                throw "When multiple vehicles are available, you must supply the appropriate VehicleKey."
            }
        }

        $vehicleInfo = Get-KiaVehicleInfo -VehicleKey $VehicleKey
        $vehicleInfo.lastVehicleInfo.location
    }
}
