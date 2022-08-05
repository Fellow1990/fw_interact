RegisterNetEvent('esx_policejob:handcuff')
AddEventHandler('esx_policejob:handcuff', function(target)
	local xPlayer = ESX.GetPlayerFromId(source)
	if xPlayer.job.name == 'police' and xPlayer.getInventoryItem('handcuffs').count >= 1 or xPlayer.getInventoryItem('rope').count >= 1 then
		TriggerClientEvent('esx_policejob:handcuff', target)
	else
		xPlayer.showNotification(Config.RequiredItem)
	end
end)

RegisterNetEvent('esx_policejob:putInVehicle')
AddEventHandler('esx_policejob:putInVehicle', function(target)
	local xPlayer = ESX.GetPlayerFromId(source)
	TriggerClientEvent('esx_policejob:putInVehicle', target)
end)

RegisterNetEvent('esx_policejob:OutVehicle')
AddEventHandler('esx_policejob:OutVehicle', function(target)
	local xPlayer = ESX.GetPlayerFromId(source)
	TriggerClientEvent('esx_policejob:OutVehicle', target)
end)