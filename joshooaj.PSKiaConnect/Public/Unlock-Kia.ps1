function Unlock-Kia {
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipelineByPropertyName, Position = 0)]
        [string]
        $VehicleKey,

        [Parameter()]
        [switch]
        $NoWait,

        [Parameter()]
        [switch]
        $PassThru
    )

    process {
        if ([string]::IsNullOrWhiteSpace($VehicleKey)) {
            $VehicleKey = (Get-KiaVehicleSummary -ErrorAction Stop).VehicleKey
            if ($VehicleKey.Count -gt 1) {
                throw "When multiple vehicles are available, you must supply the appropriate VehicleKey."
            }
        }

        $requestJson = [pscustomobject]@{
            action = 'ACTION_EXEC_REMOTE_UNLOCK_DOORS'
        } | ConvertTo-Json -Compress

        $irm = @{
            WebSession  = $script:kia_session
            Method      = 'Get'
            Uri         = 'https://owners.kia.com/apps/services/owners/remotevehicledata?requestJson={0}' -f $requestJson
            Headers     = @{
                'Cache-Control' = 'no-cache'
                'Connection'    = 'keep-alive'
                'Content-Type'  = 'application/x-www-form-urlencoded'
                'Pragma'        = 'no-cache'
                'Referer'       = 'https://owners.kia.com/content/owners/en/dashboard.html/'
                'sid'           = 'sid'
                'TE'            = 'trailers'
                'vinkey'        = $VehicleKey
            }
            ErrorAction = 'Stop'
        }
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
            WebSession  = $script:kia_session
            Method      = 'Get'
            Uri         = 'https://owners.kia.com/apps/services/owners/remotevehicledata?requestJson={0}' -f $requestJson
            Headers     = @{
                'Content-Type' = 'application/x-www-form-urlencoded'
                'vinkey'       = $VehicleKey
                'sid'          = 'sid'
                'Connection'   = 'keep-alive'
                'Referer'      = 'https://owners.kia.com/content/owners/en/dashboard.html/'
                'Pragma'       = 'no-cache'
                'TE'           = 'trailers'
            }
            ErrorAction = 'Stop'
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
