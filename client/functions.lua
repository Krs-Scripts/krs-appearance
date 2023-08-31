

closeMenu = function()
    RenderScriptCams(false, false, 0, true, true)
    DestroyAllCams(true)
    DisplayRadar(true)
    SetNuiFocus(false, false)
    SetEntityInvincible(PlayerPedId(), false)

    SetNuiFocus(false, false)
    SendNUIMessage{
        type = 'appearance_hide',
        payload = {}
    }
end

addCommas = function(n)
	return tostring(math.floor(n)):reverse():gsub("(%d%d%d)","%1,")
								  :gsub(",(%-?)$","%1"):reverse()
end

createBlip = function(coords, sprite, color, text, scale)
	local blip = AddBlipForCoord(coords.x, coords.y, coords.z)
	SetBlipSprite(blip, sprite)
	SetBlipDisplay(blip, 4)
	SetBlipScale(blip, scale)
	SetBlipColour(blip, color)
	SetBlipAsShortRange(blip, true)
	BeginTextCommandSetBlipName(text)
	EndTextCommandSetBlipName(blip)
end



consolidateShops = function()
    local shops = {}
    for _,v in ipairs(Config.ClothingShops) do
        shops[#shops + 1] = {coords = v.coords, distance = v.distance, price = v.price, store = 'clothing'}
    end
    for _,v in ipairs(Config.BarberShops) do
        shops[#shops + 1] = {coords = v.coords, distance = v.distance, price = v.price, store = 'barber'}
    end
    for _,v in ipairs(Config.TattooShops) do
        shops[#shops + 1] = {coords = v.coords, distance = v.distance, price = v.price, store = 'tattoo'}
    end
    return shops
end

showTextUI = function(store)
    if store == 'clothing' then
        store = Strings.clothing_menu
    elseif store == 'barber' then
        store = Strings.barber_menu
    else
        store = Strings.tattoo_menu
    end
    return store
end


openShop = function(store, price)
    local ped = cache.ped
    local currentAppearance = exports['krs-appearance']:getPedAppearance(ped)
    local tetovaze = exports['krs-appearance']:getPedTattoos(ped)
    currentAppearance.tattoos = tetovaze
    local config = {}
    InMenu = true
    if store == 'clothing' then
        TriggerEvent('krs-appearance:clothingShop', price)
    else
        if store == 'clothing_menu' then 
            config = {
                ped = false,
                headBlend = false,
                faceFeatures = false,
                headOverlays = false,
                components = true,
                props = true
            }
        elseif store == 'barber' then
            config = {
                ped = false,
                headBlend = true,
                faceFeatures = true,
                headOverlays = true,
                components = false,
                props = false,
                tattoos = false
            }
        elseif store == 'tattoo' then 
            config = {
                ped = false,
                headBlend = false,
                faceFeatures = false,
                headOverlays = false,
                components = false,
                props = false,
                tattoos = true
            }
        end
        exports['krs-appearance']:startPlayerCustomization(function(appearance)
            if appearance then
                if json.encode(appearance.tattoos) == '[]' then
                    appearance.tattoos = tetovaze
                end
                if price then
                    local paid = lib.callback.await('krs-appearance:payFunds', 100, price)                    
                    if paid then
                        TriggerEvent('esx:showNotification', (Strings.success_desc):format(addCommas(price)))
                        TriggerServerEvent('krs-appearance:save', appearance)
                        InMenu = false
                        ESX.SetPlayerData('ped', PlayerPedId())
                    else
                        TriggerEvent('esx:showNotification', Strings.no_funds_desc)
                        exports['krs-appearance']:setPlayerAppearance(currentAppearance)
                        InMenu = false
                        TriggerServerEvent('krs-appearance:save', currentAppearance)
                        ESX.SetPlayerData('ped', PlayerPedId())
                    end
                else
                    TriggerServerEvent('krs-appearance:save', appearance)
                    InMenu = false
                    ESX.SetPlayerData('ped', PlayerPedId())
                end
            else
                ESX.SetPlayerData('ped', PlayerPedId())
                InMenu = false
            end
        end, config)
    end
end


openWardrobe = function()
    local outfits = lib.callback.await('krs-appearance:getOutfits', 100)
    local Options = {}
    if outfits then
        Options = {}
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
                title = Strings.go_back_desc,
                event = ''
            }
        }
    end
    lib.registerContext({
        id = 'wardrobe_menu',
        title = Strings.wardrobe_title,
        options = Options
    })
    lib.showContext('wardrobe_menu')
end

exports('openWardrobe', openWardrobe)

-- ESX Skin/Skin Changer compatibility
convertClothes = function(outfit)
    local data = {}
    data.Components = exports['krs-appearance']:getPedComponents(cache.ped)
    data.Props = exports['krs-appearance']:getPedProps(cache.ped)
    for i=1, #data.Components do
        if data.Components[i].component_id == 1 and outfit.mask_1 then
            data.Components[i].drawable = outfit.mask_1
            data.Components[i].texture = (outfit.mask_2 or 0)
        end
        if data.Components[i].component_id == 3 and outfit.arms then
            data.Components[i].drawable = outfit.arms
            data.Components[i].texture = (outfit.arms_2 or 0)
        end
        if data.Components[i].component_id == 4 and outfit.pants_1 then
            data.Components[i].drawable = outfit.pants_1
            data.Components[i].texture = (outfit.pants_2 or 0)
        end
        if data.Components[i].component_id == 6 and outfit.shoes_1 then
            data.Components[i].drawable = outfit.shoes_1
            data.Components[i].texture = (outfit.shoes_2 or 0)
        end
        if data.Components[i].component_id == 7 and outfit.chain_1 then
            data.Components[i].drawable = outfit.chain_1
            data.Components[i].texture = (outfit.chain_2 or 0)
        end
        if data.Components[i].component_id == 8 and outfit.tshirt_1 then
            data.Components[i].drawable = outfit.tshirt_1
            data.Components[i].texture = (outfit.tshirt_2 or 0)
        end
        if data.Components[i].component_id == 9 and outfit.bproof_1 then
            data.Components[i].drawable = outfit.bproof_1
            data.Components[i].texture = (outfit.bproof_2 or 0)
        end
        if data.Components[i].component_id == 10 and outfit.decals_1 then
            data.Components[i].drawable = outfit.decals_1
            data.Components[i].texture = (outfit.decals_2 or 0)
        end
        if data.Components[i].component_id == 11 and outfit.torso_1 then
            data.Components[i].drawable = outfit.torso_1
            data.Components[i].texture = (outfit.torso_2 or 0)
        end
    end
    for i=1, #data.Props do
        if data.prop_id == 0 and outfit.helmet_1 then
            data.Props[i].drawable = outfit.helmet_1
            data.Props[i].texture = (outfit.helmet_2 or 0)
        end
        if data.prop_id == 1 and outfit.glasses_1 then
            data.Props[i].drawable = outfit.glasses_1
            data.Props[i].texture = (outfit.glasses_2 or 0)
        end
        if data.prop_id == 2 and outfit.ears_1 then
            data.Props[i].drawable = outfit.ears_1
            data.Props[i].texture = (outfit.ears_2 or 0)
        end
        if data.prop_id == 6 and outfit.watches_1 then
            data.Props[i].drawable = outfit.watches_1
            data.Props[i].texture = (outfit.watches_2 or 0)
        end
        if data.prop_id == 7 and outfit.bracelets_1 then
            data.Props[i].drawable = outfit.bracelets_1
            data.Props[i].texture = (outfit.bracelets_2 or 0)
        end
    end
    return data
end
