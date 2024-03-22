function Get-KiaVehicleSummary {
    [CmdletBinding()]
    [OutputType([VehicleSummary])]
    param (

    )

    process {
        if ($script:vehicleSummaries.Count -eq 0) {
            Write-Error "No vehicles found. Have you called ``Connect-Kia`` yet?"
            return
        }
        foreach ($vehicle in $script:vehicleSummaries) {
            $vehicle
        }
    }
}
