local QBCore = exports['qb-core']:GetCoreObject()


QBCore.Commands.Add('fixview', 'Activate the camera view at specified coordinates', {}, false, function(source, args)
     local Player = QBCore.Functions.GetPlayer(source)
    TriggerClientEvent('iski-fixview:client:StartCamera', source)
end, 'user ') ---change this with you permssion server 


-- user = all player have acces to use this command 
-- god  = only high rank in your server 
-- admin = only for staff in your server


--$$$ Thx
