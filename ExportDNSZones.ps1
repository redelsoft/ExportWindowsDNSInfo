$Report = [System.Collections.Generic.List[Object]]::new()
$zones = Get-DnsServerZone
foreach ($zone in $zones) {
    $zoneInfo = Get-DnsServerResourceRecord -ZoneName $zone.ZoneName
    foreach ($info in $zoneInfo) {
        $timestamp = if ($info.Timestamp) { $info.Timestamp } else { "static" }
        $timetolive = $info.TimeToLive.TotalSeconds
        $recordData = switch ($info.RecordType) {
            'A' { $info.RecordData.IPv4Address }
            'CNAME' { $info.RecordData.HostnameAlias }
            'NS' { $info.RecordData.NameServer }
            'SOA' { "[$($info.RecordData.SerialNumber)] $($info.RecordData.PrimaryServer), $($info.RecordData.ResponsiblePerson)" }
            'SRV' { $info.RecordData.DomainName }
            'PTR' { $info.RecordData.PtrDomainName }
            'MX' { $info.RecordData.MailExchange }
            'AAAA' { $info.RecordData.IPv6Address }
            'TXT' { $info.RecordData.DescriptiveText }
            default { $null }
        }
        $ReportLine = [PSCustomObject]@{
            Name       = $zone.ZoneName
            Hostname   = $info.Hostname
            Type       = $info.RecordType
            Data       = $recordData
			Priority   = $info.RecordData.Preference
            Timestamp  = $timestamp
            TimeToLive = $timetolive
        }
        $Report.Add($ReportLine)
    }
}
$Report | Export-Csv "AllDNSZonesRecords.csv" -NoTypeInformation -Encoding utf8
