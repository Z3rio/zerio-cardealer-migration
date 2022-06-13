QBCore = exports['qb-core']:GetCoreObject()
CreateThread(function()
    local vehicles = QBCore.Shared.Vehicles
    local length = 0
    for i,v in pairs(vehicles) do length = length + 1 end

    local idx = 0
    for i,v in pairs(vehicles) do
        idx = idx + 1
        exports["oxmysql"]:query(string.format([[
            INSERT INTO `zerio_cardealer-vehicles`(`model`, `label`, `orderprice`, `saleprice`, `description`, `image`, `category`, `cardealer`, `topspeed`, `acceleration`, `horsepower`) VALUES (
                '%s',
                '%s',
                %s,
                %s,
                '%s',
                '%s',
                '%s',
                '%s',
                %s,
                %s,
                %s
            )
        ]], v.model, v.name, v.price, v.price, "", "", v.category, v.shop, 0, 0, 0), {}, function() 
            print("Zerio-Cardealer-Migration | [" .. idx .. "/" .. tostring(length) .. "] " .. v.name .. " was successfully imported")
        end)
        Wait(100)
    end

    print("Zerio-Cardealer-Migration | Has successfully imported all vehicles")
end)