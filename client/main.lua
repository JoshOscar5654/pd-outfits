local QBCore = nil
local ESX = nil

-- Debug Helper
local function DebugLog(msg)
    if Config.Debug then
        print('^3[PD-Debug] ' .. msg .. '^0')
    end
end

if Config.Framework == 'qbcore' then
    if GetResourceState('qb-core') == 'started' then
        QBCore = exports['qb-core']:GetCoreObject()
    end
elseif Config.Framework == 'esx' then
    if GetResourceState('es_extended') == 'started' then
        ESX = exports["es_extended"]:getSharedObject()
    end
end

local function Notify(msg, type)
    if Config.Framework == 'qbcore' and QBCore then
        QBCore.Functions.Notify(msg, type)
    elseif Config.Framework == 'esx' and ESX then
        ESX.ShowNotification(msg)
    else
        SetNotificationTextEntry('STRING')
        AddTextComponentString(msg)
        DrawNotification(false, true)
    end
end

Citizen.CreateThread(function()
    if Config.CommandName then
        TriggerEvent('chat:addSuggestion', '/' .. Config.CommandName, 'Open Outfits Menu', {})
    end
end)

local function IsNearClothingShop()
    if not Config.RestrictToShops then return true end
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    for _, shopCoords in pairs(Config.ShopLocations) do
        local dist = #(playerCoords - shopCoords)
        if dist < Config.ShopRadius then return true end
    end
    return false
end

local function ScrapeSkinData()
    local ped = PlayerPedId()
    local skin = {}

    -- Helper to format like qb-clothing
    local function getComp(id)
        return { item = GetPedDrawableVariation(ped, id), texture = GetPedTextureVariation(ped, id) }
    end
    local function getProp(id)
        return { item = GetPedPropIndex(ped, id), texture = GetPedPropTextureIndex(ped, id) }
    end

    -- Mapping GTA Components to qb-clothing names
    skin['mask'] = getComp(1)
    skin['arms'] = getComp(3)
    skin['pants'] = getComp(4)
    skin['bag'] = getComp(5)
    skin['shoes'] = getComp(6)
    skin['accessory'] = getComp(7)
    skin['t-shirt'] = getComp(8)
    skin['vest'] = getComp(9)
    skin['decals'] = getComp(10)
    skin['torso2'] = getComp(11) -- Jackets

    -- Mapping Props
    skin['hat'] = getProp(0)
    skin['glass'] = getProp(1)
    skin['ear'] = getProp(2)
    skin['watch'] = getProp(6)
    skin['bracelet'] = getProp(7)
    return skin
end

-- === UNIVERSAL SKIN GETTER ===
local function GetPlayerSkin(cb)
    local playerPed = PlayerPedId()
    DebugLog('Fetching skin data...')

    if Config.ClothingScript == 'qb-clothing' then
        local success, skinData = pcall(function() 
            return exports['qb-clothing']:GetCurrentPed() 
        end)
        
        if success and skinData then
            DebugLog('Skin found via qb-clothing Export.')
            cb(skinData, GetEntityModel(playerPed))
            return
        end

        if QBCore then
            local PlayerData = QBCore.Functions.GetPlayerData()
            if PlayerData and PlayerData.skin and next(PlayerData.skin) ~= nil then
                DebugLog('Skin found via QBCore PlayerData.')
                cb(PlayerData.skin, GetEntityModel(playerPed))
                return
            end
        end

        DebugLog('Using Native Scraper fallback (Guaranteed to work).')
        local scrapedSkin = ScrapeSkinData()
        cb(scrapedSkin, GetEntityModel(playerPed))

    elseif Config.ClothingScript == 'fivem-appearance' or Config.ClothingScript == 'illenium-appearance' then
        local appearance = exports[Config.ClothingScript]:getPedAppearance(playerPed)
        cb(appearance, GetEntityModel(playerPed))
    elseif Config.ClothingScript == 'esx_skin' then
        TriggerEvent('skinchanger:getSkin', function(skin)
            cb(skin, GetEntityModel(PlayerPedId()))
        end)
    else
        local scrapedSkin = ScrapeSkinData()
        cb(scrapedSkin, GetEntityModel(playerPed))
    end
end

-- === UNIVERSAL SKIN SETTER ===
local function SetPlayerSkin(skin, model)
    local playerPed = PlayerPedId()
    
    if model and model ~= 0 and GetEntityModel(playerPed) ~= tonumber(model) then
        RequestModel(model)
        while not HasModelLoaded(model) do Wait(0) end
        SetPlayerModel(PlayerId(), model)
        SetModelAsNoLongerNeeded(model)
        playerPed = PlayerPedId()
    end

    if Config.ClothingScript == 'qb-clothing' then
        local success = pcall(function()
            exports['qb-clothing']:LoadPed(skin)
        end)

        if not success then
            TriggerEvent('qb-clothing:client:loadPlayerClothing', skin, playerPed)
        end
        
        Wait(100)
        local saveSuccess, currentData = pcall(function() return exports['qb-clothing']:GetCurrentPed() end)
        if saveSuccess and currentData then
            TriggerServerEvent("qb-clothing:insert_character_current", currentData)
        else
            TriggerServerEvent("qb-clothes:saveSkin", GetEntityModel(playerPed), json.encode(skin))
        end

    elseif Config.ClothingScript == 'fivem-appearance' or Config.ClothingScript == 'illenium-appearance' then
        exports[Config.ClothingScript]:setPedAppearance(playerPed, skin)
        Wait(100)
        exports[Config.ClothingScript]:saveAppearance()

    elseif Config.ClothingScript == 'esx_skin' then
        TriggerEvent('skinchanger:loadSkin', skin)
        Wait(100)
        TriggerServerEvent('esx_skin:save', skin)
    end
end

-- Main Command
RegisterCommand(Config.CommandName, function()
    if not IsNearClothingShop() then
        Notify(Locales[Config.Language]['not_near_shop'], 'error')
        return
    end

    SetNuiFocus(true, true)
    SendNUIMessage({
        action = 'open',
        language = Config.Language,
        locales = Locales[Config.Language]
    })
    
    TriggerServerEvent('pd-outfits:server:getOutfits')
end)

if Config.Keybind then
    RegisterKeyMapping(Config.CommandName, 'Open Outfits Menu', 'keyboard', Config.Keybind)
end

-- NUI Callbacks
RegisterNUICallback('close', function(data, cb)
    SetNuiFocus(false, false)
    cb('ok')
end)

RegisterNUICallback('saveOutfit', function(data, cb)
    local name = data.name
    if not name then return cb('error') end

    GetPlayerSkin(function(skin, model)
        if skin then
            TriggerServerEvent('pd-outfits:server:saveOutfit', name, skin, model)
            cb('ok')
        else
            Notify('Error: Could not retrieve skin data.', 'error')
            cb('error')
        end
    end)
end)

RegisterNUICallback('deleteOutfit', function(data, cb)
    TriggerServerEvent('pd-outfits:server:deleteOutfit', data.id)
    cb('ok')
end)

RegisterNUICallback('useOutfit', function(data, cb)
    local outfit = data.outfit
    if outfit and outfit.skin then
        local skinData = json.decode(outfit.skin)
        SetPlayerSkin(skinData, tonumber(outfit.model))
        Notify(Locales[Config.Language]['outfit_loaded'], 'success')
    end
    cb('ok')
end)

RegisterNUICallback('editOutfit', function(data, cb)
    TriggerServerEvent('pd-outfits:server:editOutfit', data.id, data.newName)
    cb('ok')
end)

RegisterNetEvent('pd-outfits:client:updateOutfits', function(outfits)
    SendNUIMessage({
        action = 'updateList',
        outfits = outfits
    })
end)

RegisterNetEvent('pd-outfits:client:notify', function(msgKey, type)
    local msg = Locales[Config.Language][msgKey] or msgKey
    Notify(msg, type)
end)