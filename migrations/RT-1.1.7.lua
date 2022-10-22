for ThePlayer, TheirProperties in pairs(global.AllPlayers) do
	if (TheirProperties.preferences == nil) then
		TheirProperties.preferences = {}
	end
	if (TheirProperties.state == nil) then
		TheirProperties.state = "default"
	end
	if (TheirProperties.PlayerLauncher == nil) then
		TheirProperties.PlayerLauncher={}
	end
	if (TheirProperties.zipline == nil) then
		TheirProperties.zipline = {}
	end
	if (TheirProperties.RangeAdjusting == nil) then
		TheirProperties.RangeAdjusting = false
	end
	if (TheirProperties.SettingRampRange == nil) then
		TheirProperties.SettingRampRange = {SettingRange=false}
	end
end

--{state="default", PlayerLauncher={}, zipline={}, RangeAdjusting=false, SettingRampRange={SettingRange=false}, GUI={}, preferences={}}
