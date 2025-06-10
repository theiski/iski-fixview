local QBCore = exports['qb-core']:GetCoreObject()


QBCore.Commands.Add('fixview', 'Activate the camera view at specified coordinates', {}, false, function(source, args)
    local Player = QBCore.Functions.GetPlayer(source)
    
    -- Optional: Check for permissions if needed
    -- if not QBCore.Functions.HasPermission(source, 'admin') then 
    --     TriggerClientEvent('QBCore:Notify', source, "You do not have permission to use this command.", "error")
    --     return 
    -- end

    -- Trigger the client event to start the camera
    TriggerClientEvent('iski-fixview:client:StartCamera', source)
end)
