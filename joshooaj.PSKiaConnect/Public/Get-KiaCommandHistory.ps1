function Get-KiaCommandHistory {
    [CmdletBinding()]
    param (
        [Parameter()]
        [int]
        $Count = $script:web_request_history_length
    )

    process {
        $Count = [math]::Min($Count, $script:web_request_history.Count)
        for ($i = 0; $i -lt $Count; $i++) {
            $script:web_request_history[$i]
        }
    }
}
