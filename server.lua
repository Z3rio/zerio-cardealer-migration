function addVehicle(model, name, orderprice, saleprice, category, shop, index, length)
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
    ]], model, name, orderprice, saleprice, "", "", category, shop, 0, 0, 0), {}, function() 
        print("Zerio-Cardealer-Migration | [" .. index .. "/" .. tostring(length) .. "] " .. name .. " was successfully imported")
    end)
end

if GetResourceState("qb-core") == "started" then
    QBCore = exports['qb-core']:GetCoreObject()
    
    CreateThread(function()
        local vehicles = QBCore.Shared.Vehicles
        local length = 0
        for i,v in pairs(vehicles) do length = length + 1 end

        local idx = 0
        for i,v in pairs(vehicles) do
            idx = idx + 1
            addVehicle(v.model, v.name, v.price, v.price, v.category, v.shop, idx, length)
            Wait(100)
        end

        print("Zerio-Cardealer-Migration | Has successfully imported all vehicles")
    end)
elseif GetResourceState("es_extended") == "started" then
    exports["oxmysql"]:fetch("SELECT * FROM `vehicles`", function(result)
        if result then
            local length = #result

            local idx = 0
            for i,v in pairs(result) do
                idx = idx + 1
                addVehicle(v.model, v.name, v.price, v.price, v.category, "cardealer", idx, length)
                Wait(100)
            end

            print("Zerio-Cardealer-Migration | Has successfully imported all vehicles")
        end
    end)
end