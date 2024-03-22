function Start-Kia {
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipelineByPropertyName, Position = 0)]
        [string[]]
        $VehicleKey,

        # Specifies the time, in minutes, before the vehicle turns off automatically.
        [Parameter()]
        [ValidateRange(1, 30)]
        [int]
        $Duration = 10,

        # Specifies the desired temperature in fahrenheit.
        [Parameter()]
        [int]
        $Temperature = 70,

        # Turn on the front and rear window, and side mirror defrost.
        [Parameter()]
        [switch]
        $Defrost,

        # Turn on the heated steering wheel.
        [Parameter()]
        [switch]
        $SteeringWheel,

        [Parameter()]
        [switch]
        $NoWait,

        [Parameter()]
        [switch]
        $PassThru
    )

    process {
        if ($VehicleKey.Count -eq 0) {
            $VehicleKey = (Get-KiaVehicleSummary -ErrorAction Stop).VehicleKey
            if ($VehicleKey.Count -gt 1) {
                throw "When multiple vehicles are available, you must supply the appropriate VehicleKey."
            }
        }

        $requestJson = [pscustomobject]@{
            action        = "ACTION_EXEC_REMOTE_CLIMATE_ON"
            remoteClimate = [pscustomobject]@{
                airTemp            = [pscustomobject]@{
                    value = "70"
                    unit  = 1
                }
                airCtrl            = $true
                defrost            = $Defrost.ToBool()
                ventilationWarning = $false
                ignitionOnDuration = [pscustomobject]@{
                    value = $Duration
                    unit  = 4
                }
                heatingAccessory   = [pscustomobject]@{
                    steeringWheel = [int]$SteeringWheel.ToBool()
                    sideMirror    = [int]$Defrost.ToBool()
                    rearWindow    = [int]$Defrost.ToBool()
                }
                heatVentSeat       = [pscustomobject]@{
                    driverSeat    = [pscustomobject]@{
                        heatVentType  = 0
                        heatVentLevel = 1
                        heatVentStep  = 0
                    }
                    passengerSeat = [pscustomobject]@{
                        heatVentType  = 0
                        heatVentLevel = 1
                        heatVentStep  = 0
                    }
                    rearLeftSeat  = [pscustomobject]@{
                        heatVentType  = 0
                        heatVentLevel = 1
                        heatVentStep  = 0
                    }
                    rearRightSeat = [pscustomobject]@{
                        heatVentType  = 0
                        heatVentLevel = 1
                        heatVentStep  = 0
                    }
                }
            }
        } | ConvertTo-Json -Depth 10 -Compress

        foreach ($vinKey in $VehicleKey) {
            if ($vinKey -notin (Get-KiaVehicleSummary).VehicleKey) {
                Write-Error "Vehicle key '$vinKey' not recognized."
                continue
            }
            $irm = @{
                WebSession = $script:kia_session
                Method     = 'Get'
                Uri        = 'https://owners.kia.com/apps/services/owners/remotevehicledata?requestJson={0}' -f $requestJson
                Headers    = @{
                    'Content-Type' = 'application/x-www-form-urlencoded'
                    'vinkey'       = $VinKey
                    'sid'          = 'sid'
                    'Connection'   = 'keep-alive'
                    'Referer'      = 'https://owners.kia.com/content/owners/en/remote.html?page=climate'
                    'Pragma'       = 'no-cache'
                    'TE'           = 'trailers'
                }
            }
            Invoke-RestMethod @irm
            $response = HandleKiaRequest $irm
            if ($PassThru) {
                $response
            }

            $transactionId = $response.header.xid -as [guid]
            if ($NoWait) {
                return
            } elseif ($null -eq $transactionId) {
                Write-Error "Either no transaction id (xid) was provided with the response, or it could not be cast to [guid] type."
                return
            }

            $requestJson = [pscustomobject]@{
                xid    = $transactionId.ToString()
                action = 'ACTION_GET_TRANSACTION_STATUS'
            } | ConvertTo-Json -Compress
            $irm = @{
                WebSession = $script:kia_session
                Method     = 'Get'
                Uri        = 'https://owners.kia.com/apps/services/owners/remotevehicledata?requestJson={0}' -f $requestJson
                Headers    = @{
                    'Content-Type' = 'application/x-www-form-urlencoded'
                    'vinkey'       = $VinKey
                    'sid'          = 'sid'
                    'Connection'   = 'keep-alive'
                    'Referer'      = 'https://owners.kia.com/content/owners/en/remote.html?page=climate'
                    'Pragma'       = 'no-cache'
                    'TE'           = 'trailers'
                }
            }

            $delay = 20
            $timeout = (Get-Date).AddMinutes(5)
            while ((Get-Date) -lt $timeout) {
                # Kia website has an initial ~20 second delay followed by 10 second delays between polling requests.
                Write-Verbose "Sleeping for $delay seconds before polling for command status."
                Start-Sleep -Seconds $delay
                $delay = 10

                Invoke-RestMethod @irm
                $response = HandleKiaRequest $irm -ErrorAction Stop
                Write-Verbose ($response | ConvertTo-Json)

                if ($response.payload.errorDesc) {
                    Write-Warning $response.payload.errorDesc
                }

                if ($PassThru) {
                    $response
                }

                if ($response.payload.remoteStatus -eq 0) {
                    break
                }
            }
            if ($response.payload.remoteStatus -ne 0) {
                Write-Error "Timeout occurred before observing a successful start."
            }
        }
    }
}
