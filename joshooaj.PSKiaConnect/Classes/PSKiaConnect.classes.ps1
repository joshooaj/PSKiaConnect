class KiaMessageTimeStamp {
    [datetime] $Utc

    KiaMessageTimeStamp([object]$timestamp) {
        if (-not $timestamp.utc -match '^(\d{4})(\d{2})(\d{2})(\d{2})(\d{2})(\d{2})$') {
            throw "Failed to parse message timestamp '$($timestamp.utc)'"
        }
        $this.Utc = [datetime]::new($Matches[1], $Matches[2], $Matches[3], $Matches[4], $Matches[5], $Matches[6], [datetimekind]::Utc)
    }

    [string] ToString() {
        return $this.Utc.ToLocalTime().ToString()
    }
}
class KiaNotifyMessage {
    [int] $MessageRefId
    [string] $Icon
    [string] $MessageTitle
    [string] $MessageText
    [KiaMessageTimeStamp] $MessageDate
    [string] $MessageTimeStamp

    KiaNotifyMessage() {}
    KiaNotifyMessage ([pscustomobject]$Status) {
        foreach ($name in $Status | Get-Member -MemberType NoteProperty | Select-Object -ExpandProperty Name) {
            $myProperties = $this | Get-Member -MemberType Property | Select-Object -ExpandProperty Name
            if ($name -notin $myProperties) {
                continue
            }
            $this.$name = $Status.$name
        }
    }
}
class KiaImageSize {
    [int] $Length
    [int] $Width
    [int] $Uom

    KiaImageSize() {}
    KiaImageSize ([pscustomobject]$Status) {
        foreach ($name in $Status | Get-Member -MemberType NoteProperty | Select-Object -ExpandProperty Name) {
            $myProperties = $this | Get-Member -MemberType Property | Select-Object -ExpandProperty Name
            if ($name -notin $myProperties) {
                continue
            }
            $this.$name = $Status.$name
        }
    }
}

class KiaImagePath {
    [string] $ImageName
    [string] $ImagePath
    [int] $ImageType
    [KiaImageSize] $ImageSize

    KiaImagePath() {}
    KiaImagePath ([pscustomobject]$Status) {
        foreach ($name in $Status | Get-Member -MemberType NoteProperty | Select-Object -ExpandProperty Name) {
            $myProperties = $this | Get-Member -MemberType Property | Select-Object -ExpandProperty Name
            if ($name -notin $myProperties) {
                continue
            }
            $this.$name = $Status.$name
        }
    }
}

class ResponseStatus {
    [int] $StatusCode
    [int] $ErrorType
    [int] $ErrorCode
    [string] $ErrorMessage

    ResponseStatus() {}
    ResponseStatus ([pscustomobject]$Status) {
        foreach ($name in $Status | Get-Member -MemberType NoteProperty | Select-Object -ExpandProperty Name) {
            $myProperties = $this | Get-Member -MemberType Property | Select-Object -ExpandProperty Name
            if ($name -notin $myProperties) {
                continue
            }
            $this.$name = $Status.$name
        }
    }
}

class VehicleSummary {
    [string]$Vin
    [string]$VehicleIdentifier
    [string]$ModelName
    [string]$ModelYear
    [string]$NickName
    [string]$Generation
    [string]$ExtColorCode
    [string]$Trim
    [object]$ImagePath
    [string]$DealerCode
    [object]$MobileStore
    [object]$SupportedApp
    [int]$SupportAdditionalDriver
    [int]$CustomerType
    [string]$ProjectCode
    [string]$HeadUnitDesc
    [int]$ProvStatus
    [int]$EnrollmentSuppressionType
    [int]$RsaStatus
    [int]$NotificationCount
    [string]$VehicleKey

    VehicleSummary() {}
    VehicleSummary ([pscustomobject]$Status) {
        foreach ($name in $Status | Get-Member -MemberType NoteProperty | Select-Object -ExpandProperty Name) {
            $myProperties = $this | Get-Member -MemberType Property | Select-Object -ExpandProperty Name
            if ($name -notin $myProperties) {
                continue
            }
            $this.$name = $Status.$name
        }
    }
}

class KiaResponse {
    [ResponseStatus] $Status
    [object]         $Payload
    [object]         $Header

    KiaResponse() {}
    KiaResponse ([pscustomobject]$Status) {
        foreach ($name in $Status | Get-Member -MemberType NoteProperty | Select-Object -ExpandProperty Name) {
            $myProperties = $this | Get-Member -MemberType Property | Select-Object -ExpandProperty Name
            if ($name -notin $myProperties) {
                continue
            }
            $this.$name = $Status.$name
        }
    }
}
