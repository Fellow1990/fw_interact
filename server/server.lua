RegisterNetEvent('esx_interact:handcuff')
AddEventHandler('esx_interact:handcuff', function(target)
	local xPlayer = ESX.GetPlayerFromId(source)
	if xPlayer.job.name == 'police' and xPlayer.getInventoryItem('handcuffs').count >= 1 or xPlayer.getInventoryItem('rope').count >= 1 then
		TriggerClientEvent('esx_interact:handcuff', target)
	else
		xPlayer.showNotification(Config.RequiredItem)
	end
end)

RegisterNetEvent('esx_interact:putInVehicle')
AddEventHandler('esx_interact:putInVehicle', function(target)
	local xPlayer = ESX.GetPlayerFromId(source)
	TriggerClientEvent('esx_interact:putInVehicle', target)
end)

RegisterNetEvent('esx_interact:OutVehicle')
AddEventHandler('esx_interact:OutVehicle', function(target)
	local xPlayer = ESX.GetPlayerFromId(source)
	TriggerClientEvent('esx_interact:OutVehicle', target)
end)