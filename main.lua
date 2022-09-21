CubixLife = nil
local vehicleCruiser = 'off'
local vehicleSpeedSource = nil
local vehicles = {};

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)
		while CubixLife == nil do
			Citizen.Wait(10)
			TriggerEvent("CubixLife:getCubixSharedLifeObject", function(response)
				CubixLife = response
			end)
		end
				
		local vehicle = GetVehiclePedIsIn(GetPlayerPed(-1), false)
		if vehicle ~= nil and vehicle ~= 0 and GetPedInVehicleSeat(vehicle, -1) == GetPlayerPed(-1) then
			if vehicleCruiser == 'off' then
				SetEntityMaxSpeed(vehicle, GetVehicleHandlingFloat(vehicle,"CHandlingData","fInitialDriveMaxFlatVel"))
			elseif vehicleCruiser == 'on' then
				SetEntityMaxSpeed(vehicle, vehicleSpeedSource/3.6)
			end
		end
	end
end)

function OpenvehicleActionsMenu()
	CubixLife.UI.Menu.CloseAll()
		
	CubixLife.UI.Menu.Open('default', GetCurrentResourceName(), 'tempolimit_actions', {
	title    = 'Tempolimit',
	align    = 'top-left',
	elements = {
		{label = "60 km/h", value = 'tempolimit60'},
		{label = "80 km/h", value = 'tempolimit80'},
		{label = "120 km/h", value = 'tempolimit120'},
		{label = "Eigene Geschwindigkeit", value = 'tempolimiton'},
		{label = "Ausschalten", value = 'tempolimitoff'},
	}}, function(data, menu)
					 
		if data.current.value == 'tempolimit60' then
			vehicleSpeedSource = 60
			if vehicleCruiser == 'off' then
				vehicleCruiser = 'on'
				SetEntityMaxSpeed(vehicle, 60/3.6)
				CubixLife.ShowNotification("Tempolimit auf 60 km/h gesetzt.")
			elseif vehicleCruiser == 'on' then
				SetEntityMaxSpeed(vehicle, 60/3.6)
				CubixLife.ShowNotification("Tempolimit auf 60 km/h geändert.")	
						
			end
		elseif data.current.value == 'tempolimit80' then
			vehicleSpeedSource = 80
			if vehicleCruiser == 'off' then
				vehicleCruiser = 'on'
				SetEntityMaxSpeed(vehicle, 80/3.6)
				CubixLife.ShowNotification("Tempolimit auf 80 km/h gesetzt.")
			elseif vehicleCruiser == 'on' then
				SetEntityMaxSpeed(vehicle, 80/3.6)
				CubixLife.ShowNotification("Tempolimit auf 80 km/h geändert.")				
			end
		elseif data.current.value == 'tempolimit120' then
			vehicleSpeedSource = 120
			if vehicleCruiser == 'off' then
				vehicleCruiser = 'on'
				SetEntityMaxSpeed(vehicle, 130/3.6)
				CubixLife.ShowNotification("Tempolimit auf 120 km/h gesetzt.")
			elseif vehicleCruiser == 'on' then
				SetEntityMaxSpeed(vehicle, 130/3.6)
				CubixLife.ShowNotification("Tempolimit auf 120 km/h geändert.")	
			end
		elseif data.current.value == 'tempolimiton' then
	
			local player = GetPlayerPed(-1)
			local vehicle = GetVehiclePedIsIn(player, false)
			local maxSpeed = GetVehicleHandlingFloat(vehicle,"CHandlingData","fInitialDriveMaxFlatVel")
			
			CubixLife.UI.Menu.Open('dialog', GetCurrentResourceName(), 'menu1',
			{
				title = ('Geschwindigkeit')
			},
			function(data, menu)
			local amount = tonumber(data.value)
			if amount == nil then
				CubixLife.ShowNotification('Ungültiger Wert')
			else
				if amount <= maxSpeed then
					vehicleSpeedSource = amount
					if vehicleCruiser == 'off' then
						vehicleCruiser = 'on'
						SetEntityMaxSpeed(vehicle, vehicleSpeedSource/3.6)
						CubixLife.ShowNotification("Tempolimit auf " ..vehicleSpeedSource.. " km/h gesetzt.")
					elseif vehicleCruiser == 'on' then
						SetEntityMaxSpeed(vehicle, vehicleSpeedSource/3.6)
						CubixLife.ShowNotification("Tempolimit auf " ..vehicleSpeedSource.. " km/h geändert.")	
					else
						CubixLife.ShowNotification("Irgendwas ist schiefgelaufen")	
						vehicleCruiser = 'off'
						vehicleSpeedSource = nil
					end
				else
					CubixLife.ShowNotification("Dein Limit darf maximal bei " ..math.floor(maxSpeed).. " km/h liegen.")	
				end				
				menu.close()
			end					
			end,
			function(data, menu)
				menu.close()
			end)
		elseif data.current.value == 'tempolimitoff' then
			if vehicleCruiser == 'on' then
				vehicleCruiser = 'off'
				SetEntityMaxSpeed(vehicle, maxSpeed)
				CubixLife.ShowNotification("Du hast dein Tempolimit ausgeschaltet")
			else
				CubixLife.ShowNotification("Dein Tempolimit ist aus.")
			end
		end	
	end,function(data, menu) 
		menu.close() 
	end)
end

RegisterCommand("tempolimit", function()
	local veh = GetVehiclePedIsIn(GetPlayerPed(-1))
	if veh ~= 0  then
		if  GetPedInVehicleSeat(veh, -1) == GetPlayerPed(-1) then
			OpenvehicleActionsMenu()
		else
			CubixLife.ShowNotification("Du bist nicht der Fahrer.")
		end
	end
end)
