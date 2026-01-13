local QBCore = nil
local ESX = nil

if Config.Framework == 'qbcore' then
    QBCore = exports['qb-core']:GetCoreObject()
elseif Config.Framework == 'esx' then
    ESX = exports["es_extended"]:getSharedObject()
end

local function GetIdentifier(source)
    if Config.Framework == 'qbcore' then
        local Player = QBCore.Functions.GetPlayer(source)
        return Player and Player.PlayerData.citizenid or nil
    elseif Config.Framework == 'esx' then
        local xPlayer = ESX.GetPlayerFromId(source)
        return xPlayer and xPlayer.identifier or nil
    elseif Config.Framework == 'qbox' then
        local Player = exports.qbx_core:GetPlayer(source)
        return Player and Player.PlayerData.citizenid or nil
    end
end

RegisterNetEvent('pd-outfits:server:getOutfits', function()
    local src = source
    local identifier = GetIdentifier(src)
    if not identifier then return end

    MySQL.query('SELECT * FROM pd_outfits WHERE identifier = ?', {identifier}, function(result)
        TriggerClientEvent('pd-outfits:client:updateOutfits', src, result)
    end)
end)

RegisterNetEvent('pd-outfits:server:saveOutfit', function(name, skin, model)
    local src = source
    local identifier = GetIdentifier(src)
    if not identifier then return end

    MySQL.insert('INSERT INTO pd_outfits (identifier, name, skin, model) VALUES (?, ?, ?, ?)', {
        identifier, name, json.encode(skin), model
    }, function(id)
        if id then
            TriggerClientEvent('pd-outfits:client:notify', src, 'outfit_saved', 'success')
            MySQL.query('SELECT * FROM pd_outfits WHERE identifier = ?', {identifier}, function(result)
                TriggerClientEvent('pd-outfits:client:updateOutfits', src, result)
            end)
        else
            TriggerClientEvent('pd-outfits:client:notify', src, 'error_saving', 'error')
        end
    end)
end)

RegisterNetEvent('pd-outfits:server:deleteOutfit', function(id)
    local src = source
    local identifier = GetIdentifier(src)
    
    MySQL.update('DELETE FROM pd_outfits WHERE id = ? AND identifier = ?', {id, identifier}, function(affectedRows)
        if affectedRows > 0 then
            TriggerClientEvent('pd-outfits:client:notify', src, 'outfit_deleted', 'success')
            MySQL.query('SELECT * FROM pd_outfits WHERE identifier = ?', {identifier}, function(result)
                TriggerClientEvent('pd-outfits:client:updateOutfits', src, result)
            end)
        end
    end)
end)

RegisterNetEvent('pd-outfits:server:editOutfit', function(id, newName)
    local src = source
    local identifier = GetIdentifier(src)

    MySQL.update('UPDATE pd_outfits SET name = ? WHERE id = ? AND identifier = ?', {newName, id, identifier}, function(affectedRows)
        if affectedRows > 0 then
            TriggerClientEvent('pd-outfits:client:notify', src, 'outfit_updated', 'success')
             MySQL.query('SELECT * FROM pd_outfits WHERE identifier = ?', {identifier}, function(result)
                TriggerClientEvent('pd-outfits:client:updateOutfits', src, result)
            end)
        end
    end)
end)

-- Version Checker
local currentVersion = GetResourceMetadata(GetCurrentResourceName(), 'version', 0)

Citizen.CreateThread(function()
    local githubRepo = 'JoshOscar5654/pd-outfits' 
    
    PerformHttpRequest('https://api.github.com/repos/'..githubRepo..'/releases/latest', function(err, text, headers)
        if err == 200 then
            local data = json.decode(text)
            local latestVersion = data.tag_name:gsub('v', '')

            if latestVersion ~= currentVersion then
                print('^4[PrimeDev] ------------------------------------------------^0')
                print('^4[PrimeDev] ^3Update Available for '..GetCurrentResourceName()..'!^0')
                print('^4[PrimeDev] ^7Current: ^1'..currentVersion..'^7 | Latest: ^2'..latestVersion..'^0')
                print('^4[PrimeDev] ^7Download: ^4'..data.html_url..'^0')
                print('^4[PrimeDev] ------------------------------------------------^0')
            else
                print('^4[PrimeDev] ^2'..GetCurrentResourceName()..' is up to date! ('..currentVersion..')^0')
            end
        else
            if Config.Debug then
                print('^4[PrimeDev] ^1Debug: GitHub API Error Code: '..tostring(err)..'^0')
            end
        end
    end, 'GET', '', { ['User-Agent'] = 'PrimeDev-Script' })
end)