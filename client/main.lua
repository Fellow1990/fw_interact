-- Handcuff
local isHandcuffed, handcuffTimer = false, {}

AddEventHandler('handcuff', function(data)
	TriggerServerEvent('esx_interact:handcuff', GetPlayerServerId(NetworkGetPlayerIndexFromPed(data.entity)))
end)

RegisterNetEvent('esx_interact:handcuff')
AddEventHandler('esx_interact:handcuff', function()
	isHandcuffed = not isHandcuffed
	local playerPed = PlayerPedId()
	if isHandcuffed then
		RequestAnimDict('mp_arresting')
		while not HasAnimDictLoaded('mp_arresting') do
			Wait(100)
		end
		TaskPlayAnim(playerPed, 'mp_arresting', 'idle', 8.0, -8, -1, 49, 0, 0, 0, 0)
		RemoveAnimDict('mp_arresting')
		SetEnableHandcuffs(playerPed, true)
		DisablePlayerFiring(playerPed, true)
		SetCurrentPedWeapon(playerPed, GetHashKey('WEAPON_UNARMED'), true)
		SetPedCanPlayGestureAnims(playerPed, false)
		DisplayRadar(false)
		if Config.EnableHandcuffTimer then
			if handcuffTimer.active then
				ESX.ClearTimeout(handcuffTimer.task)
			end
			StartHandcuffTimer()
		end
	else
		if Config.EnableHandcuffTimer and handcuffTimer.active then
			ESX.ClearTimeout(handcuffTimer.task)
		end
		ClearPedSecondaryTask(playerPed)
		SetEnableHandcuffs(playerPed, false)
		DisablePlayerFiring(playerPed, false)
		SetPedCanPlayGestureAnims(playerPed, true)
		DisplayRadar(true)
	end
end)

RegisterNetEvent('esx_interact:unrestrain')
AddEventHandler('esx_interact:unrestrain', function()
	if isHandcuffed then
		local playerPed = PlayerPedId()
		isHandcuffed = false

		ClearPedSecondaryTask(playerPed)
		SetEnableHandcuffs(playerPed, false)
		DisablePlayerFiring(playerPed, false)
		SetPedCanPlayGestureAnims(playerPed, true)
		FreezeEntityPosition(playerPed, false)
		DisplayRadar(true)

		-- end timer
		if Config.EnableHandcuffTimer and handcuffTimer.active then
			ESX.ClearTimeout(handcuffTimer.task)
		end
	end
end)

CreateThread(function()
	while true do
		Wait(0)
		local playerPed = PlayerPedId()

		if isHandcuffed then
			DisableControlAction(0, 1, true)
			DisableControlAction(0, 2, true)
			DisableControlAction(0, 24, true)
			DisableControlAction(0, 257, true)
			DisableControlAction(0, 25, true)
			DisableControlAction(0, 263, true)
			DisableControlAction(0, 45, true)
			DisableControlAction(0, 22, true)
			DisableControlAction(0, 44, true)
			DisableControlAction(0, 37, true)
			DisableControlAction(0, 23, true)
			DisableControlAction(0, 288,  true)
			DisableControlAction(0, 289, true)
			DisableControlAction(0, 170, true)
			DisableControlAction(0, 167, true)
			DisableControlAction(0, 0, true)
			DisableControlAction(0, 26, true)
			DisableControlAction(0, 73, true)
			DisableControlAction(2, 199, true)
			DisableControlAction(0, 59, true)
			DisableControlAction(0, 71, true)
			DisableControlAction(0, 72, true)
			DisableControlAction(2, 36, true)
			DisableControlAction(0, 47, true)
			DisableControlAction(0, 264, true)
			DisableControlAction(0, 257, true)
			DisableControlAction(0, 140, true)
			DisableControlAction(0, 141, true)
			DisableControlAction(0, 142, true)
			DisableControlAction(0, 143, true)
			DisableControlAction(0, 75, true)
			DisableControlAction(27, 75, true)

			if IsEntityPlayingAnim(playerPed, 'mp_arresting', 'idle', 3) ~= 1 then
				ESX.Streaming.RequestAnimDict('mp_arresting', function()
					TaskPlayAnim(playerPed, 'mp_arresting', 'idle', 8.0, -8, -1, 49, 0.0, false, false, false)
					RemoveAnimDict('mp_arresting')
				end)
			end
		else
			Wait(500)
		end
	end
end)

function StartHandcuffTimer()
	if Config.EnableHandcuffTimer and handcuffTimer.active then
		ESX.ClearTimeout(handcuffTimer.task)
	end

	handcuffTimer.active = true

	handcuffTimer.task = ESX.SetTimeout(Config.HandcuffTimer, function()
		lib.notify({
			description = Config.Unrestrained_timer,
			style = {
				backgroundColor = '#000000',
				color = '#ffffff'
			},
			icon = 'handcuffs',
			type = 'inform'
		})
		TriggerEvent('esx_interact:unrestrain')
		handcuffTimer.active = false
	end)
end

-- Open inventory
AddEventHandler('search', function(data)
	if IsEntityPlayingAnim(data.entity, "missminuteman_1ig_2", "handsup_base", 3) or IsEntityPlayingAnim(data.entity, "mp_arresting", "idle", 3) or IsPedDeadOrDying(data.entity) then
		exports.ox_inventory:openInventory('player', GetPlayerServerId(NetworkGetPlayerIndexFromPed(data.entity)))
	else
		lib.notify({
			description = Config.ShowNotificationText,
			style = {
				backgroundColor = '#000000',
				color = '#ffffff'
			},
			icon = 'people-robbery',
			type = 'error'
		})
	end
end)

-- Put in vehicle
AddEventHandler('putveh', function(data)
	TriggerServerEvent('esx_interact:putInVehicle', GetPlayerServerId(NetworkGetPlayerIndexFromPed(data.entity)))
end)

RegisterNetEvent('esx_interact:putInVehicle')
AddEventHandler('esx_interact:putInVehicle', function()
	if isHandcuffed then
		local playerPed = PlayerPedId()
		local vehicle, distance = ESX.Game.GetClosestVehicle()

		if vehicle and distance < 5 then
			local maxSeats, freeSeat = GetVehicleMaxNumberOfPassengers(vehicle)

			for i=maxSeats - 1, 0, -1 do
				if IsVehicleSeatFree(vehicle, i) then
					freeSeat = i
					break
				end
			end

			if freeSeat then
				TaskWarpPedIntoVehicle(playerPed, vehicle, freeSeat)
			end
		end
	end
end)

-- Out the vehicle
AddEventHandler('outveh', function(data)
	local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
	if closestPlayer ~= -1 and closestDistance <= 3.0 then
		TriggerServerEvent('esx_interact:OutVehicle', GetPlayerServerId(closestPlayer))
	end
end)

RegisterNetEvent('esx_interact:OutVehicle')
AddEventHandler('esx_interact:OutVehicle', function()
	local playerPed = PlayerPedId()
	if IsPedSittingInAnyVehicle(playerPed) then
		local vehicle = GetVehiclePedIsIn(playerPed, false)
		TaskLeaveVehicle(playerPed, vehicle, 64)
	end
end)

-- ID
AddEventHandler('id', function(data)
	TriggerServerEvent('jsfour-idcard:open', GetPlayerServerId(NetworkGetPlayerIndexFromPed(data.entity)), GetPlayerServerId(PlayerId()))
end)

-- ID Driver
AddEventHandler('id-driver', function(data)
	TriggerServerEvent('jsfour-idcard:open', GetPlayerServerId(NetworkGetPlayerIndexFromPed(data.entity)), GetPlayerServerId(PlayerId()), 'driver')
end)

-- Billing
RegisterNetEvent('billing', function(data)
	local player = ESX.Game.GetClosestPlayer()
	if ESX.PlayerData.job and ESX.PlayerData.job.name == 'unemployed' then
		lib.notify({
			description = Config.Unemployed,
			style = {
				backgroundColor = '#000000',
				color = '#ffffff'
			},
			icon = 'fa-x',
			type = 'error'
		})
	else
		local input = lib.inputDialog(Config.billing_title, {Config.input})
		if input then
			local lockerNumber = tonumber(input[1])
			TriggerServerEvent('esx_billing:sendBill', GetPlayerServerId(player), 'society_'..ESX.PlayerData.job.name, (ESX.PlayerData.job.label), lockerNumber)
		end
	end
end)

exports.ox_target:addGlobalPlayer({
	{
		event = "search",
		icon = Config.search_img,
		label = Config.search,
		num = 1
	},
	{
		event = "handcuff",
		icon = Config.handcuff_img,
		label = Config.handcuff,
		num = 2
	},
	{
		event = "putveh",
		icon = Config.putveh_img,
		label = Config.putveh,
		num = 3
	},
	{
		event = "id",
		icon = Config.ID_img,
		label = Config.ID,
		num = 4
	},
	{
		event = "id-driver",
		icon = Config.ID_driver_img,
		label = Config.ID_driver,
		num = 5
	},
	{
		event = "billing",
		icon = Config.billing_img,
		label = Config.billing,
		num = 6
	},
})

exports.ox_target:addGlobalVehicle({
	{
		event = "outveh",
		icon = Config.outveh_img,
		label = Config.outveh,
		num = 1
	},
})
