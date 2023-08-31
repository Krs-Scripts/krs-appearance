ESX = exports["es_extended"]:getSharedObject()

local shops, savedOutfits = {}, {}

-- ESX Events
RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
	ESX.PlayerData = xPlayer
	ESX.PlayerLoaded = true
end)

RegisterNetEvent('esx:onPlayerLogout')
AddEventHandler('esx:onPlayerLogout', function()
    ESX.PlayerLoaded = false
    ESX.PlayerData = {}
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
	ESX.PlayerData.job = job
end)

AddEventHandler('esx:onPlayerDeath', function(data)
    closeMenu()
end)




RegisterNetEvent('krs-appearance:skinCommand')
AddEventHandler('krs-appearance:skinCommand', function()
	local config = {
		ped = true,
		headBlend = true,
		faceFeatures = true,
		headOverlays = true,
		components = true,
		props = true
	}
	exports['krs-appearance']:startPlayerCustomization(function (appearance)
		if (appearance) then
			TriggerServerEvent('krs-appearance:save', appearance)
			ESX.SetPlayerData('ped', PlayerPedId())
		else
			ESX.SetPlayerData('ped', PlayerPedId())
		end
	end, config)
end)

RegisterNetEvent('krs-appearance:setOutfit')
AddEventHandler('krs-appearance:setOutfit', function(data)
	local pedModel = data.ped
	local pedComponents = data.components
	local pedProps = data.props
	local playerPed = PlayerPedId()
	local currentPedModel = exports['krs-appearance']:getPedModel(playerPed)
	if currentPedModel ~= pedModel then
    	exports['krs-appearance']:setPlayerModel(pedModel)
		Wait(500)
		playerPed = PlayerPedId()
		exports['krs-appearance']:setPedComponents(playerPed, pedComponents)
		exports['krs-appearance']:setPedProps(playerPed, pedProps)
		local appearance = exports['krs-appearance']:getPedAppearance(playerPed)
		TriggerServerEvent('krs-appearance:save', appearance)
		ESX.SetPlayerData('ped', PlayerPedId())
	else
		exports['krs-appearance']:setPedComponents(playerPed, pedComponents)
		exports['krs-appearance']:setPedProps(playerPed, pedProps)
		local appearance = exports['krs-appearance']:getPedAppearance(playerPed)
		TriggerServerEvent('krs-appearance:save', appearance)
		ESX.SetPlayerData('ped', PlayerPedId())
	end
end)

RegisterNetEvent('krs-appearance:saveOutfit', function()
    local input = lib.inputDialog(Strings.save_outfit_title, {Strings.save_outfit_info})
    if input then
        local name = input[1]
        local playerPed = PlayerPedId()
        local pedModel = exports['krs-appearance']:getPedModel(playerPed)
        local pedComponents = exports['krs-appearance']:getPedComponents(playerPed)
        local pedProps = exports['krs-appearance']:getPedProps(playerPed)
        TriggerServerEvent('krs-appearance:saveOutfit', name, pedModel, pedComponents, pedProps)
    end
end)

AddEventHandler('krs-appearance:clothingMenu', function(price)
    
    openShop('clothing_menu', price)
end)

RegisterNetEvent('krs-appearance:deleteOutfitMenu', function()
    local outfits = lib.callback.await('krs-appearance:getOutfits', 100)
    local Options = {}
    if outfits then
        Options = {
            {
                title = Strings.go_back_title,
                event = 'krs-appearance:clothingShop'
            }
        }
        for i=1, #outfits do
            Options[#Options + 1] = {
                title = outfits[i].name,
                serverEvent = 'krs-appearance:deleteOutfit',
                args = outfits[i].id 
            }
        end
    else
        Options = {
            {
                title = Strings.go_back_title,
                description = Strings.go_back_desc,
                event = 'krs-appearance:clothingShop'
            }
        }
    end
    lib.registerContext({
        id = 'outfit_delete_menu',
        title = Strings.delete_outfits_title,
        options = Options
    })
    lib.showContext('outfit_delete_menu')
end)

RegisterNetEvent('krs-appearance:browseOutfits', function()
    local outfits = lib.callback.await('krs-appearance:getOutfits', 100)
    local Options = {}
    if outfits then 
        Options = {
            {
                title = Strings.go_back_title,
                event = 'krs-appearance:clothingShop'
            }
        }
        for i=1, #outfits do 
            Options[#Options + 1] = {
                title = outfits[i].name,
                event = 'krs-appearance:setOutfit',
                args = {
                    ped = outfits[i].ped,
                    components = outfits[i].components,
                    props = outfits[i].props
                }
            }
        end
    else
        Options = {
            {
                title = Strings.go_back_title,
                description = Strings.go_back_desc,
                event = 'krs-appearance:clothingShop'
            }
        }
    end
    lib.registerContext({
        id = 'outfit_menu',
        title = Strings.browse_outfits_title,
        options = Options
    })
    lib.showContext('outfit_menu')
end)


RegisterNetEvent('krs-appearance:clothingShop', function(price)
	lib.registerContext({
		id = 'clothing_menu',
		title = Strings.clothing_shop_title,
		options = {
			{
				title = Strings.change_clothing_title,
				description = Strings.change_clothing_desc,
				arrow = false,
				event = 'krs-appearance:clothingMenu',
                args = price
			},
			{
				title = Strings.browse_outfits_title,
				description = Strings.browse_outfits_desc,
				arrow = false,
				event = 'krs-appearance:browseOutfits'
			},
			{
				title = Strings.save_outfit_title,
				description = Strings.save_outfit_desc,
				arrow = false,
				event = 'krs-appearance:saveOutfit'
			},
			{
				title = Strings.delete_outfit_title,
				description = Strings.delete_outfit_desc,
				arrow = false,
				event = 'krs-appearance:deleteOutfitMenu'
			},
		}
	})
	lib.showContext('clothing_menu')
end)



CreateThread(function()
    for i=1, #Config.ClothingShops do
        if Config.ClothingShops[i].blip.enabled then
            createBlip(Config.ClothingShops[i].coords, Config.ClothingShops[i].blip.sprite, Config.ClothingShops[i].blip.color, Config.ClothingShops[i].blip.string, Config.ClothingShops[i].blip.scale)
        end
    end
    for i=1, #Config.BarberShops do
        if Config.BarberShops[i].blip.enabled then
            createBlip(Config.BarberShops[i].coords, Config.BarberShops[i].blip.sprite, Config.BarberShops[i].blip.color, Config.BarberShops[i].blip.string, Config.BarberShops[i].blip.scale)
        end
    end
    for i=1, #Config.TattooShops do
        if Config.TattooShops[i].blip.enabled then
            createBlip(Config.TattooShops[i].coords, Config.TattooShops[i].blip.sprite, Config.TattooShops[i].blip.color, Config.TattooShops[i].blip.string, Config.TattooShops[i].blip.scale)
        end
    end
end)


Citizen.CreateThread(function()
    for i = 1, #Config.ClothingShops, 1 do
        local v = Config.ClothingShops[i] 
        
        local markerId = 'camerino_' .. i 
        
        TriggerEvent('gridsystem:registerMarker', {
            name = markerId,
            pos = v.coords,
            type = -1,
            texture = 'krs',
            color = { r = 255, g = 255, b = 255 },
            scale = vector3(0.50, 0.50, 0.50),
            size = vector3(1.5, 1.5, 1.5),
            control = 'E',
            msg = '[E] - Negozio vestiti',
            action = function()
                openShop('clothing', v.price)
            end
        })
    end
end)


Citizen.CreateThread(function()
    for i = 1, #Config.BarberShops, 1 do
        local v = Config.BarberShops[i] 
        
        local markerId = 'barbershops_' .. i 
        
        TriggerEvent('gridsystem:registerMarker', {
            name = markerId,
            pos = v.coords,
            type = -1,
            texture = 'krs',
            color = { r = 255, g = 255, b = 255 },
            scale = vector3(0.50, 0.50, 0.50),
            size = vector3(1.5, 1.5, 1.5),
            control = 'E',
            msg = '[E] - Per rasarti',
            action = function()
                openShop('barber', v.price)
            end
        })
    end
end)


Citizen.CreateThread(function()
    for i = 1, #Config.TattooShops, 1 do
        local v = Config.TattooShops[i] 
        local markerId = 'tattooshops_' .. i 
        
        TriggerEvent('gridsystem:registerMarker', {
            name = markerId,
            pos = v.coords,
            type = -1,
            texture = 'krs',
            color = { r = 255, g = 255, b = 255 },
            scale = vector3(0.50, 0.50, 0.50),
            size = vector3(1.5, 1.5, 1.5),
            control = 'E',
            msg = '[E] - Per tatuarti',
            action = function()
                openShop('tattoo', v.price)
            end
        })
    end
end)


RegisterCommand('propfix', function()
    for k, v in pairs(GetGamePool('CObject')) do
        if IsEntityAttachedToEntity(PlayerPedId(), v) then
            SetEntityAsMissionEntity(v, true, true)
            DeleteObject(v)
            DeleteEntity(v)
        end
    end
end)

RegisterCommand('reloadchar', function()
    ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(appearance)
        exports['krs-appearance']:setPlayerAppearance(appearance)
    end)
end)

--cd_multicharacter compatibility
RegisterNetEvent('skinchanger:loadSkin2')
AddEventHandler('skinchanger:loadSkin2', function(ped, skin)
    if not skin.model then skin.model = 'mp_m_freemode_01' end
    	exports['krs-appearance']:setPedAppearance(ped, skin)
    if cb ~= nil then
        cb()
    end
end)

-- esx_skin/skinchanger compatibility(The best I/we can)
AddEventHandler('skinchanger:getSkin', function(cb)
    while not ESX.PlayerLoaded do
        Wait(1000)
    end
    ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(appearance)
        cb(appearance)
    end)
end)

RegisterNetEvent('skinchanger:loadSkin')
AddEventHandler('skinchanger:loadSkin', function(skin, cb)
	if not skin.model then skin.model = 'mp_m_freemode_01' end
	exports['krs-appearance']:setPlayerAppearance(skin)
	if cb ~= nil then
		cb()
	end
end)

AddEventHandler('skinchanger:loadDefaultModel', function(loadMale, cb)
    if loadMale then
        TriggerEvent('skinchanger:loadSkin',Config.DefaultSkin)
    else
        local skin = Config.DefaultSkin
        skin.model = 'mp_f_freemode_01'
        TriggerEvent('skinchanger:loadSkin',skin)
    end
end)

RegisterNetEvent('skinchanger:loadClothes')
AddEventHandler('skinchanger:loadClothes', function(skin, clothes)
    local playerPed = PlayerPedId()
    local outfit = convertClothes(clothes)
    exports['krs-appearance']:setPedComponents(playerPed, outfit.Components)
    exports['krs-appearance']:setPedProps(playerPed, outfit.Props)
end)

RegisterNetEvent('esx_skin:openSaveableMenu')
AddEventHandler('esx_skin:openSaveableMenu', function(submitCb, cancelCb)
	local config = {
		ped = true,
		headBlend = true,
		faceFeatures = true,
		headOverlays = true,
		components = true,
		props = true
	}
	exports['krs-appearance']:startPlayerCustomization(function (appearance)
		if (appearance) then
			TriggerServerEvent('krs-appearance:save', appearance)
			ESX.SetPlayerData('ped', PlayerPedId())
			if submitCb then submitCb() end
		else
			if cancelCb then cancelCb() end
			ESX.SetPlayerData('ped', PlayerPedId())
		end
	end, config)
end)