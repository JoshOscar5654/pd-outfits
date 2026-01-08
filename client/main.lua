local QBCore = nil
local ESX = nil

-- Debug Helper
local function DebugLog(msg)
    if Config.Debug then
        print('^3[PD-Debug] ' .. msg .. '^0')
    end
end

if Config.Framework == 'qbcore' then
    QBCore = exports['qb-core']:GetCoreObject()
elseif Config.Framework == 'esx' then
    ESX = exports["es_extended"]:getSharedObject()
end

-- Compatibility Auto-Check (Runs on start if Debug is true)
CreateThread(function()
    if not Config.Debug then return end
    
    Wait(1000) -- Wait for other resources to load
    DebugLog('Starting Compatibility Auto-Check...')
    
    if Config.ClothingScript == 'qb-clothing' then
        local PlayerData = QBCore.Functions.GetPlayerData()
        if PlayerData and PlayerData.skin and next(PlayerData.skin) ~= nil then
            DebugLog('^2[PASS] Method 1: QBCore PlayerData found.^0')
        else
            DebugLog('^1[FAIL] Method 1: QBCore PlayerData is empty.^0')
        end

        local success, skinData = pcall(function() return exports['qb-clothing']:GetCurrentPed() end)
        if success and skinData then
            DebugLog('^2[PASS] Method 2: qb-clothing Export found.^0')
        else
            DebugLog('^1[FAIL] Method 2: qb-clothing Export not found.^0')
        end
    else
        DebugLog('Using '..Config.ClothingScript..', skipping qb-clothing checks.')
    end
    DebugLog('Auto-Check complete.')
end)

local function Notify(msg, type)
    if Config.Framework == 'qbcore' then
        QBCore.Functions.Notify(msg, type)
    elseif Config.Framework == 'esx' then
        ESX.ShowNotification(msg)
    else
        print(msg) 
    end
end

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

-- UNIVERSAL SKIN GETTER
local function GetPlayerSkin(cb)
    local playerPed = PlayerPedId()
    DebugLog('Fetching skin data...')

    if Config.ClothingScript == 'qb-clothing' then
        -- 1. Try QBCore PlayerData
        local PlayerData = QBCore.Functions.GetPlayerData()
        if PlayerData and PlayerData.skin and next(PlayerData.skin) ~= nil then
            DebugLog('Skin found via QBCore PlayerData.')
            cb(PlayerData.skin, GetEntityModel(playerPed))
            return
        end

        -- 2. Try Export
        local success, skinData = pcall(function() 
            return exports['qb-clothing']:GetCurrentPed() 
        end)
        if success and skinData then
            DebugLog('Skin found via qb-clothing Export.')
            cb(skinData, GetEntityModel(playerPed))
            return
        end

        -- 3. Fallback: Event
        DebugLog('Trying Event fallback...')
        TriggerEvent('qb-clothing:client:getSkin', function(skin)
            if skin then
                cb(skin, GetEntityModel(playerPed))
            else
                print('^1[PD-Outfits] CRITICAL: Could not retrieve skin (Tried: Core, Export, Event).^0')
                cb(nil, nil)
            end
        end)

    elseif Config.ClothingScript == 'fivem-appearance' or Config.ClothingScript == 'illenium-appearance' then
        local appearance = exports[Config.ClothingScript]:getPedAppearance(playerPed)
        cb(appearance, GetEntityModel(playerPed))
    elseif Config.ClothingScript == 'esx_skin' then
        TriggerEvent('skinchanger:getSkin', function(skin)
            cb(skin, GetEntityModel(PlayerPedId()))
        end)
    else
        cb(nil, nil)
    end
end

-- UNIVERSAL SKIN SETTER & SAVER
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
        
        -- AUTO-SAVE Logic
        Wait(100)
        DebugLog('Triggering Auto-Save for qb-clothing...')
        
        local saveSuccess, currentData = pcall(function()
            return exports['qb-clothing']:GetCurrentPed()
        end)

        if saveSuccess and currentData then
            TriggerServerEvent("qb-clothing:insert_character_current", currentData)
            DebugLog('Saved to DB via insert_character_current.')
        else
            TriggerServerEvent("qb-clothes:saveSkin", skin)
        end

    elseif Config.ClothingScript == 'fivem-appearance' or Config.ClothingScript == 'illenium-appearance' then
        exports[Config.ClothingScript]:setPedAppearance(playerPed, skin)
        Wait(100)
        DebugLog('Saving via appearance export...')
        exports[Config.ClothingScript]:saveAppearance()

    elseif Config.ClothingScript == 'esx_skin' then
        TriggerEvent('skinchanger:loadSkin', skin)
        Wait(100)
        DebugLog('Saving via esx_skin...')
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
        SetPlayerSkin(json.decode(outfit.skin), tonumber(outfit.model))
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