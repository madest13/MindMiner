<#
MindMiner  Copyright (C) 2017-2018  Oleg Samsonov aka Quake4
https://github.com/Quake4/MindMiner
License GPL-3.0
#>

function Out-DeviceInfo ([bool] $OnlyTotal) {
	$valuesweb = [Collections.ArrayList]::new()
	$valuesapi = [Collections.ArrayList]::new()

	[bool] $has = $false
	[Config]::ActiveTypes | ForEach-Object {
		$type = [eMinerType]::nVidia # $_
		if ($Devices.$type -and $Devices.$type.Length -gt 0) {
			if ($OnlyTotal) {
				$measure = $Devices.$type | Measure-Object "Clock", "ClockMem", "Load", "LoadMem", "Temperature", "Power", "PowerLimit" -Min -Max
				$str = "$type`: "
				if ($measure[0].Minimum -eq $measure[0].Maximum) { $str += "$($measure[0].Minimum)/" } else { $str += "$($measure[0].Minimum)-$($measure[0].Maximum)/" }
				if ($measure[1].Minimum -eq $measure[1].Maximum) { $str += "$($measure[1].Minimum) Mhz, " } else { $str += "$($measure[1].Minimum)-$($measure[1].Maximum) Mhz, " }
				if ($measure[2].Minimum -eq $measure[2].Maximum) { $str += "$($measure[2].Minimum)/" } else { $str += "$($measure[2].Minimum)-$($measure[2].Maximum)/" }
				if ($measure[3].Minimum -eq $measure[3].Maximum) { $str += "$($measure[3].Minimum) %, " } else { $str += "$($measure[3].Minimum)-$($measure[3].Maximum) %, " }
				if ($measure[4].Minimum -eq $measure[4].Maximum) { $str += "$($measure[4].Minimum) C, " } else { $str += "$($measure[4].Minimum)-$($measure[4].Maximum) C, " }
				if ($measure[5].Minimum -eq $measure[5].Maximum) { $str += "$($measure[5].Minimum) W, " } else { $str += "$($measure[5].Minimum)-$($measure[5].Maximum) W, " }
				if ($measure[6].Minimum -eq $measure[6].Maximum) { $str += "$($measure[6].Minimum) %" } else { $str += "$($measure[6].Minimum)-$($measure[6].Maximum) %" }
				Write-Host $str
				Remove-Variable measure
				$has = $true
			}
			else {
				Write-Host "   Type: $type"
				Write-Host
				$columns = [Collections.ArrayList]::new()
				$columns.AddRange(@(
					@{ Label="GPU"; Expression = { $_.Name } }
					@{ Label="Clock, MHz"; Expression = { "$($_.Clock)/$($_.ClockMem)" }; Alignment = "Center" }
					@{ Label="Load, %"; Expression = { "$($_.Load)/$($_.LoadMem)" }; Alignment = "Center" }
					@{ Label="Temp, C"; Expression = { $_.Temperature }; Alignment = "Right" }
					@{ Label="Power, W"; Expression = { $_.Power }; Alignment = "Right" }
					@{ Label="PL, %"; Expression = { $_.PowerLimit }; Alignment = "Right" }
				))
				Out-Table ($Devices.$type | Format-Table $columns)
				Remove-Variable columns
			}
			if ($global:API.Running) {
				$columnsweb = [Collections.ArrayList]::new()
				$columnsweb.AddRange(@(
					@{ Label="GPU"; Expression = { $_.Name } }
					@{ Label="Clock, MHz"; Expression = { "$($_.Clock)/$($_.ClockMem)" }; }
					@{ Label="Load, %"; Expression = { "$($_.Load)/$($_.LoadMem)" }; }
					@{ Label="Temp, C"; Expression = { $_.Temperature }; }
					@{ Label="Power, W"; Expression = { $_.Power }; }
					@{ Label="PL, %"; Expression = { $_.PowerLimit }; }
				))
				$valuesweb.AddRange(@(($Devices.$type | Select-Object $columnsweb | ConvertTo-Html -Fragment)))
				Remove-Variable columnsweb
				# api
				$columnsapi = [Collections.ArrayList]::new()
				$columnsapi.AddRange(@(
					@{ Label="type"; Expression = { "$type" } }
					@{ Label="name"; Expression = { $_.Name } }
					@{ Label="clock"; Expression = { $_.Clock } }
					@{ Label="clockmem"; Expression = { $_.ClockMem } }
					@{ Label="load"; Expression = { $_.Load } }
					@{ Label="loadmem"; Expression = { $_.LoadMem } }
					@{ Label="temperature"; Expression = { $_.Temperature } }
					@{ Label="power"; Expression = { $_.Power } }
					@{ Label="powelimit"; Expression = { $_.PowerLimit } }
				))
				$valuesapi.AddRange(@(($Devices.$type | Select-Object $columnsapi)))
				Remove-Variable columnsapi
			}
		}
	}
	if ($has) { Write-Host }

	if ($global:API.Running) {
		$global:API.Device = $valuesweb
		$global:API.Devices = $valuesapi
	}
	Remove-Variable valuesapi, valuesweb
}