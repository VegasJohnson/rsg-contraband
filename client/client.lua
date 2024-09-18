local RSGCore = exports['rsg-core']:GetCoreObject()
-- 
local contrabandselling = false
local hasTarget = false
local startLocation = nil
local lastPed = {}
local stealingPed = nil
local stealData = {}
local availableContraband = {}
local currentOfferContraband = nil
local reward = 0
--ZONE CHECKS
local ZoneHot = false
local ZoneForeign = false
local ZoneHigh = false
local ZoneMed = false
local ZonePoor = false
local ZoneBlack = false

RegisterCommand('selldrugs', function(source)
    TriggerEvent('rsg-contraband:client:contrabandselling')
end)

RegisterNetEvent('rsg-contraband:client:sellzonecheck')
AddEventHandler('rsg-contraband:client:sellzonecheck', function()
    RSGCore.Functions.TriggerCallback('police:GetCops', function(result)
        CurrentLawmen = result
        if Config.Debug then print(result .. "lAW") end
        local player = (GetEntityCoords(PlayerPedId()))
        local current_district = Citizen.InvokeNative(0x43AD8FC02B429D33, player, 1)
        local HotZone = {
            [1] = { townname = 'Strawberry', zone = 427683330 },
        }
        local foreign = {
            [1] = { townname = 'AguasdulcesFarm', zone = 1654810713 },
            [2] = { townname = 'AguasdulcesRuins', zone = 201158410 },
            [3] = { townname = 'AguasdulcesVilla', zone = -1207133769 },
            [4] = { townname = 'Manicato', zone = 1299204683 },
        }
        local HighZone = {
            [1] = { townname = 'StDenis', zone = -765540529 },
            [2] = { townname = 'Blackwater', zone = 1053078005 },
        }
        local MedZone = {
            [1] = { townname = 'Manzanita', zone = 1463094051 },
            [2] = { townname = 'Rhodes', zone = 2046780049 },
            --[3] = { townname = 'Strawberry', zone = 427683330 },
            [4] = { townname = 'valentine', zone = 459833523 },
            [5] = { townname = 'Annesburg', zone = 7359335 },
        }
        local PoorZone = {
            [1] = { townname = 'Armadillo', zone = -744494798 },
            [2] = { townname = 'Butcher', zone = -1947415645 },
            [3] = { townname = 'cornwall', zone = -1851305682 },
            [4] = { townname = 'lagras', zone = 406627834 },
            [5] = { townname = 'Tumbleweed', zone = -1524959147 },
            [6] = { townname = 'VANHORN', zone = 2126321341 },
            [7] = { townname = 'Wallace', zone = -872622034 },
            [8] = { townname = 'wapiti', zone = 1663398575 },
        }
        local Blacklisted = {
            [1] = { townname = 'Braithwaite', zone = 1778899666 },
            [2] = { townname = 'Caliga', zone = 1862420670 },
            [3] = { townname = 'Emerald', zone = -473051294 },
            [4] = { townname = 'Siska', zone = 2147354003 },

        }
        for k, i in pairs(HotZone) do
            if CurrentLawmen >= 0 then --3
                if current_district == i.zone then
                    ZoneHot = true
                    if Config.Debug then print("Hot Zone") end
                end
            end
        end
        for k, i in pairs(foreign) do
            if current_district == i.zone then
                ZoneForeign = true
                if Config.Debug then print("Foreign Zone") end
            end
        end
        for k, i in pairs(HighZone) do
            if CurrentLawmen >= 0 then ---2
                if current_district == i.zone then
                    ZoneHigh = true
                    if Config.Debug then print("High Zone") end
                end
            end
        end
        for k, i in pairs(MedZone) do
            if CurrentLawmen >= 0 then  ---1
                if current_district == i.zone then
                    ZoneMed = true
                    if Config.Debug then print("Med Zone") end
                end
            end
        end
        for k, i in pairs(PoorZone) do
            if current_district == i.zone then
                ZonePoor = true
                if Config.Debug then print("Poor Zone") end
            end
        end
        for k, i in pairs(Blacklisted) do
            if current_district == i.zone then
                if Config.Debug then print("Black Zone") end
                ZoneBlack = true
            end
        end
    end)
end)

RegisterNetEvent('rsg-contraband:client:contrabandselling', function()
    RSGCore.Functions.TriggerCallback('rsg-contraband:server:contrabandselling:getAvailableContraband',
        function(result)
            if result ~= nil then
                availableContraband = result
                if not contrabandselling then
                    contrabandselling = true
                    LocalPlayer.state:set("inv_busy", true, true)
                    --TriggerEvent('bm-weapons:client:Notifications', Lang:t('title.drugs'), Lang:t('success.selling'), 5000)
					RSGCore.Functions.Notify('Contraband Selling', 'success', 5000)
                    startLocation = GetEntityCoords(PlayerPedId())
                else
                    contrabandselling = false
                    LocalPlayer.state:set("inv_busy", false, true)
                    --TriggerEvent('bm-weapons:client:Notifications', Lang:t('title.drugs'), Lang:t('error.stopped'), 5000)
					RSGCore.Functions.Notify('Stoped Selling', 'error', 5000)
					
                end
            else
                --TriggerEvent('bm-weapons:client:Notifications', Lang:t('title.drugs'), Lang:t('error.empty'), 5000)
				RSGCore.Functions.Notify('No more contraband to sell!', 'error', 5000)
                LocalPlayer.state:set("inv_busy", false, true)
            end
        end)
end)

RegisterNetEvent('rsg-contraband:client:refreshAvailableContraband', function(items)
    availableContraband = items
    if #availableContraband <= 0 then
        --TriggerEvent('bm-weapons:client:Notifications', Lang:t('title.drugs'), Lang:t('error.empty'), 5000)
		RSGCore.Functions.Notify('No more contraband to sell!', 'error', 5000)
        contrabandselling = false
        LocalPlayer.state:set("inv_busy", false, true)
    end
end)

RegisterNetEvent('rsg-contraband:client:refreshzones', function()
    ZoneHot = false
    ZoneForeign = false
    ZoneHigh = false
    ZoneMed = false
    ZonePoor = false
    ZoneBlack = false
end)

function DrawTxt(str, x, y, w, h, enableShadow, col1, col2, col3, a, centre)
    local str = CreateVarString(10, "LITERAL_STRING", str)
    SetTextScale(w, h)
    SetTextColor(math.floor(col1), math.floor(col2), math.floor(col3), math.floor(a))
    SetTextCentre(centre)
    if enableShadow then SetTextDropshadow(1, 0, 0, 0, 255) end
    DisplayText(str, x, y)
end

Citizen.CreateThread(function()
    while true do
        Wait(0)
        if contrabandselling then
        DrawTxt('SELLING CONTRABAND', 0.20, 0.96, 0.4, 0.4, true, 232, 190, 0, 255, false)
        end
    end
end)

local function SellToPed(ped)
    hasTarget = true
    for i = 1, #lastPed, 1 do
        if lastPed[i] == ped then
            hasTarget = false
            if Config.Debug then print("Already Sold to Ped") end
            --TriggerEvent('bm-weapons:client:Notifications', Lang:t('title.drugs'), Lang:t('error.notwant'), 5000)
			RSGCore.Functions.Notify('Person not interested!', 'error', 5000)
            return
        end
    end

    local succesChance = math.random(1, 20)

    local getRobbed = math.random(1, 20)

    if succesChance <= 7 then
        hasTarget = false
        return
    elseif succesChance >= 19 then
        local sellcoords = GetEntityCoords(PlayerPedId())
        hasTarget = false
        return
    end

    local contrabandType = math.random(1, #availableContraband)
    local contrabandAmount = math.random(1, availableContraband[contrabandType].amount)

    ----------POSSIBLY AMT OF DRUGS AT A TIME IT SELLS
    if contrabandAmount > 3 then
        contrabandAmount = math.random(1, 3)
    end
    
    currentOfferContraband = availableContraband[contrabandType]

    ---------------PRICING
    local ddata = Config.ContrabandPrice[currentOfferContraband.item]
    local randomPrice = math.random(ddata.price, ddata.priceh) * contrabandAmount
    -------------------

    SetEntityAsNoLongerNeeded(ped)
    ClearPedTasks(ped)

    local coords = GetEntityCoords(PlayerPedId(), true)
    local pedCoords = GetEntityCoords(ped)
    local pedDist = #(coords - pedCoords)

    if getRobbed == 18 or getRobbed == 9 then
        TaskGoStraightToCoord(ped, coords, 15.0, -1, 0.0, 0.0)
        if Config.Debug then print("1A ROB") end
    else
        TaskGoStraightToCoord(ped, coords, 1.2, -1, 0.0, 0.0)
        if Config.Debug then print("2A ROB") end
    end

    while pedDist > 1.5 do
        coords = GetEntityCoords(PlayerPedId(), true)
        pedCoords = GetEntityCoords(ped)
        if getRobbed == 18 or getRobbed == 9 then
            TaskGoStraightToCoord(ped, coords, 15.0, -1, 0.0, 0.0)
            if Config.Debug then print("1B ROB") end
        else
            TaskGoStraightToCoord(ped, coords, 1.2, -1, 0.0, 0.0)
            if Config.Debug then print("2B ROB") end
        end
        TaskGoStraightToCoord(ped, coords, 1.2, -1, 0.0, 0.0)
        pedDist = #(coords - pedCoords)
        Wait(100)
        if Config.Debug then print("Someone is coming") end
    end

    TaskLookAtEntity(ped, PlayerPedId(), 5500.0, 2048, 3)
    TaskTurnPedToFaceEntity(ped, PlayerPedId(), 5500)
    TaskStartScenarioInPlace(ped, "WORLD_HUMAN_WAITING_IMPATIENT", 0, false)
    
    if hasTarget then
        while pedDist < 1.5 and not IsPedDeadOrDying(ped) do
            local player = PlayerPedId()
            coords = GetEntityCoords(PlayerPedId(), true)
            pedCoords = GetEntityCoords(ped)
            pedDist = #(coords - pedCoords)
            if getRobbed == 18 or getRobbed == 9 then
                TriggerServerEvent('rsg-contraband:server:robContraband', availableContraband[contrabandType].item, contrabandAmount)
                --TriggerEvent('bm-weapons:client:Notifications', Lang:t('title.drugs'), Lang:t('error.rob'), 3000)
				RSGCore.Functions.Notify('You have been robbed!', 'error', 5000)
                stealingPed = ped
                stealData = {
                    item = availableContraband[contrabandType].item,
                    amount = contrabandAmount,
                    print('ped stole' ..contrabandAmount)
                }
                hasTarget = false
                local moveto = GetEntityCoords(PlayerPedId())
                local movetoCoords = {x = moveto.x + math.random(100, 500), y = moveto.y + math.random(100, 500), z = moveto.z, }
                ClearPedTasks(ped)
                --TaskCombatPed(ped, player)
                TaskGoStraightToCoord(ped, movetoCoords.x, movetoCoords.y, movetoCoords.z, 15.0, -1, 0.0, 0.0)
                startLocation = GetEntityCoords(PlayerPedId())
                lastPed[#lastPed+1] = ped
                break
            else
                if pedDist < 1.5 and contrabandselling then
                    local item = availableContraband[contrabandType].item
                    if ZoneHot then
                        if Config.Debug then print("reward hot") end
                        reward = randomPrice * 4
                        --TriggerEvent('bm-weapons:client:Notifications', Lang:t('title.drugs'),
                            --"Sell " ..contrabandAmount.." ".. item .. " for $" .. reward .. " [G] Confirm [R] Decline", 1000)
							--RSGCore.Functions.Notify("Sell " ..contrabandAmount.." ".. item .. " for $" .. reward .. " [G] Confirm [R] Decline", 'success', 5000)
							DrawTxt("Sell " ..contrabandAmount.." ".. item .. " for $" .. reward .. " [G] Confirm [R] Decline", 0.14, 0.90, 0.27, 0.27, true, 255, 128, 0, 255, false)
                    end
                    if ZoneForeign then
                            if Config.Debug then print("reward foreign") end
                            reward = randomPrice / 3
                            --TriggerEvent('bm-weapons:client:Notifications', Lang:t('title.drugs'),
                            --"Sell " ..contrabandAmount.." ".. item .. " for $" .. reward .. " [G] Confirm [R] Decline", 1000)
							--RSGCore.Functions.Notify("Sell " ..contrabandAmount.." ".. item .. " for $" .. reward .. " [G] Confirm [R] Decline", 'success', 5000)
							DrawTxt("Sell " ..contrabandAmount.." ".. item .. " for $" .. reward .. " [G] Confirm [R] Decline", 0.14, 0.90, 0.27, 0.27, true, 255, 128, 0, 255, false)
                    end
                    if ZoneHigh then
                            if Config.Debug then print("reward high") end
                            reward = randomPrice * 3
                            --TriggerEvent('bm-weapons:client:Notifications', Lang:t('title.drugs'),
                                --"Sell " ..contrabandAmount.." ".. item .. " for $" .. reward .. " [G] Confirm [R] Decline", 1000)
								--RSGCore.Functions.Notify("Sell " ..contrabandAmount.." ".. item .. " for $" .. reward .. " [G] Confirm [R] Decline", 'success', 5000)
								DrawTxt("Sell " ..contrabandAmount.." ".. item .. " for $" .. reward .. " [G] Confirm [R] Decline", 0.14, 0.90, 0.27, 0.27, true, 255, 128, 0, 255, false)
                    end
                    if ZoneMed then
                            if Config.Debug then print("reward med") end
                            reward = randomPrice * 1.5
                            --TriggerEvent('bm-weapons:client:Notifications', Lang:t('title.drugs'),
                                --"Sell " ..contrabandAmount.." ".. item .. " for $" .. reward .. " [G] Confirm [R] Decline", 1000)
								--RSGCore.Functions.Notify("Sell " ..contrabandAmount.." ".. item .. " for $" .. reward .. " [G] Confirm [R] Decline", 'success', 5000)
								DrawTxt("Sell " ..contrabandAmount.." ".. item .. " for $" .. reward .. " [G] Confirm [R] Decline", 0.14, 0.90, 0.27, 0.27, true, 255, 128, 0, 255, false)
                    end
                    if ZonePoor then
                            if Config.Debug then print("reward poor") end
                            reward = randomPrice / 2
                            --TriggerEvent('bm-weapons:client:Notifications', Lang:t('title.drugs'),
                                --"Sell " ..contrabandAmount.." ".. item .. " for $" .. reward .. " [G] Confirm [R] Decline", 1000)
								--RSGCore.Functions.Notify("Sell " ..contrabandAmount.." ".. item .. " for $" .. reward .. " [G] Confirm [R] Decline", 'success', 5000)
								DrawTxt("Sell " ..contrabandAmount.." ".. item .. " for $" .. reward .. " [G] Confirm [R] Decline", 0.14, 0.90, 0.27, 0.27, true, 255, 128, 0, 255, false)
                    end
                    if IsControlJustPressed(0, 0x5415BE48) then --G
                        FreezeEntityPosition(ped, true)
                        local randomNumber = math.random(1,100)
                        if randomNumber > 60 then -- 40% chance of calling the law
                            TriggerServerEvent('police:server:policeAlert', 'contraband being sold')
                        end

                        TriggerServerEvent('rsg-contraband:server:sellContraband', availableContraband[contrabandType].item, contrabandAmount, reward)

                        hasTarget = false
                        -- animation here
                        RequestAnimDict("script_re@treasure_hunter@treasure_hunter_offer")
                        while not HasAnimDictLoaded("script_re@treasure_hunter@treasure_hunter_offer") do
                            Wait(0)
                        end
                        TaskPlayAnim(player, "script_re@treasure_hunter@treasure_hunter_offer" ,"exchange_ft_hunter" ,8.0, -8.0, -1, 1, 0, false, false, false )
                        TaskPlayAnim(ped, "script_re@treasure_hunter@treasure_hunter_offer" ,"exchange_ft_hunter" ,8.0, -8.0, -1, 1, 0, false, false, false )
                        Wait(7000)
                        FreezeEntityPosition(ped, false)
                        ClearPedTasks(player)
                        SetPedKeepTask(ped, false)
                        SetEntityAsNoLongerNeeded(ped)
                        ClearPedTasks(ped)
                        startLocation = GetEntityCoords(PlayerPedId())
                        lastPed[#lastPed+1] = ped
                        TriggerEvent('rsg-contraband:client:refreshzones')
                        break
                    end

                    if IsControlJustPressed(0, 0xE30CD707) then --R
                        FreezeEntityPosition(ped, true)
                        --PLAYER ANIM
                        RequestAnimDict("ai_gestures@gen_female@standing@speaker@lt_hand")
                        while not HasAnimDictLoaded("ai_gestures@gen_female@standing@speaker@lt_hand") do
                            Wait(0)
                        end
                        --PED ANIM
                        RequestAnimDict("ai_gestures@gen_male@standing@silent@rt_hand@prop_rt")
                        while not HasAnimDictLoaded("ai_gestures@gen_male@standing@silent@rt_hand@prop_rt") do
                            Wait(0)
                        end
                        TaskPlayAnim(player, "ai_gestures@gen_female@standing@speaker@lt_hand" ,"negative_punctuate_r_003" ,8.0, -8.0, -1, 2, 0, false, false, false )    
                        TaskPlayAnim(ped, "ai_gestures@gen_male@standing@silent@rt_hand@prop_rt" ,"silent_frustrated_punctuate_f_005" ,8.0, -8.0, -1, 1, 0, false, false, false )    
                        Wait(1000)
                        FreezeEntityPosition(ped, false)
                        hasTarget = false
                        SetPedKeepTask(ped, false)
                        SetEntityAsNoLongerNeeded(ped)
                        ClearPedTasks(ped)
                        ClearPedTasks(player)
                        startLocation = GetEntityCoords(PlayerPedId())
                        lastPed[#lastPed+1] = ped
                        Wait(2000)
                        ClearPedTasks(ped)
                        TaskGoStraightToCoord(ped, startLocation.x, startLocation.y, startLocation.z, 0.5, -1, 0.0, 0.0)
                        TriggerEvent('rsg-contraband:client:refreshzones')
                        break
                    end
                else
                    if Config.Debug then print("else") end
                    hasTarget = false
                    lastPed[#lastPed+1] = ped
                    TriggerEvent('rsg-contraband:client:refreshzones')
                    --TriggerEvent('bm-weapons:client:Notifications', Lang:t('title.drugs'), Lang:t('error.nolaw'), 5000)
					RSGCore.Functions.Notify('Not Enough Law', 'error', 5000)
                end
            end
            Wait(3)
        end
        Wait(math.random(4000, 7000))
    end
end

function DrawTxt(str, x, y, w, h, enableShadow, col1, col2, col3, a, centre)
    local str = CreateVarString(10, "LITERAL_STRING", str)
    SetTextScale(w, h)
    SetTextColor(math.floor(col1), math.floor(col2), math.floor(col3), math.floor(a))
    SetTextCentre(centre)
    if enableShadow then SetTextDropshadow(1, 0, 0, 0, 255) end
    DisplayText(str, x, y)
end

CreateThread(function()
    while true do
        local sleep = 1000
        if Config.Debug then print('Steal Sleep 1') end
        if stealingPed ~= nil and stealData ~= nil then
            sleep = 0
            if IsEntityDead(stealingPed) then
                local ped = PlayerPedId()
                local pos = GetEntityCoords(ped)
                local pedpos = GetEntityCoords(stealingPed)
                if Config.Debug then print('PED IS DEAD AND HAS DRUGS') end
                if #(pos - pedpos) < 1.5 then
                    --TriggerEvent('bm-weapons:client:Notifications', Lang:t('title.drugs'), "Press [G] to get drugs back!", 1000)
					--RSGCore.Functions.Notify("Press [G] to get drugs back!", 'error', 5000)
					DrawTxt("Press [G] to get drugs back!", 0.14, 0.90, 0.27, 0.27, true, 255, 128, 0, 255, false)
                    if Config.Debug then print('SIGN ON BODY') end
                    if IsControlJustPressed(0, 0x760A9C6F) then --G 0x760A9C6F
                        TaskStartScenarioInPlace(ped, GetHashKey('WORLD_HUMAN_CROUCH_INSPECT'), -1, true, false, false, false)
                        Wait(2000)
                        ClearPedTasks(ped)
                        TriggerServerEvent('rsg-contraband:server:getbackcontraband', stealData.item, stealData.amount)
                        if Config.Debug then print('got drugs back') end
                        stealingPed = nil
                        stealData = {}
                    end
                end
            end
        end
        Wait(sleep)
    end
end)

CreateThread(function()
    while true do
        local sleep = 1000
        if contrabandselling then
            local target = IsControlJustPressed(0, 0xF84FA74F)
            sleep = 10
            local player = PlayerPedId()
            local coords = GetEntityCoords(player)
            if not hasTarget then
                if target then
                    local PlayerPeds = {}
                    if next(PlayerPeds) == nil then
                        for _, activePlayer in ipairs(GetActivePlayers()) do
                            local ped = GetPlayerPed(activePlayer)
                            PlayerPeds[#PlayerPeds + 1] = ped
                        end
                    end
                    local closestPed, closestDistance = RSGCore.Functions.GetClosestPed(coords, PlayerPeds)
                    if closestDistance < 2.0 and closestPed ~= 0 and not IsPedInAnyVehicle(closestPed) and GetPedType(closestPed) ~= 28 then
                        TriggerEvent('rsg-contraband:client:sellzonecheck')
                        SellToPed(closestPed)
                    end
                end
            end
            local startDist = #(startLocation - coords)
            if startDist > 10 then
                --toFarAway()
            end
        end
        Wait(sleep)
    end
end)
