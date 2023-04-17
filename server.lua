-- FUNCTIONS
function addVehicle(model, name, orderprice, saleprice, category, shop, index,
                    length)
    ExecuteSQL(string.format([[
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
    ]], model, name, orderprice, saleprice, "", "", category, shop, 0, 0, 0),
               {}, function()
        print("Zerio-Cardealer-Migration | [" .. index .. "/" ..
                  tostring(length) .. "] " .. name ..
                  " was successfully imported")
    end)
end

function SelectSQL(sqlstr, params, cb) -- Selecting SQL strings
    if GetResourceState("oxmysql") == "started" then -- oxmysql
        exports.oxmysql:query(sqlstr, {}, function(retVal) cb(retVal) end)
    end

    if GetResourceState("ghmattimysql") == "started" and
        GetResourceState("oxmysql") ~= "started" then -- ghmattimysql
        exports.ghmattimysql:scalar(sqlstr, params,
                                    function(retVal) cb(retVal) end)
    end

    if GetResourceState("mysql-async") == "started" and
        GetResourceState("oxmysql") ~= "started" then -- mysql-async
        MySQL.Async.fetchAll(sqlstr, params, function(retVal) cb(retVal) end)
    end
end

function ExecuteSQL(sqlstr, params, cb) -- Executing SQL strings
    if GetResourceState("oxmysql") == "started" then -- oxmysql
        exports.oxmysql:query(sqlstr, params,
                              function(result) if cb then cb(result) end end)
    end

    if GetResourceState("ghmattimysql") == "started" and
        GetResourceState("oxmysql") ~= "started" then -- ghmattimysql
        exports.ghmattimysql:execute(sqlstr, params, function(result)
            if cb then cb(result) end
        end)
    end

    if GetResourceState("mysql-async") == "started" and
        GetResourceState("oxmysql") ~= "started" then -- mysql-async
        MySQL.Async.execute(sqlstr, params,
                            function(result) if cb then cb(result) end end)
    end
end

-- MAIN
if GetResourceState("qb-core") == "started" then -- QB-Core
    QBCore = exports['qb-core']:GetCoreObject()

    CreateThread(function()
        local vehicles = QBCore.Shared.Vehicles
        local length = 0
        for i, v in pairs(vehicles) do length = length + 1 end

        local idx = 0
        for i, v in pairs(vehicles) do
            idx = idx + 1
            addVehicle(v.model, v.name, v.price, v.price, v.category, v.shop,
                       idx, length)
            Wait(100)
        end

        print(
            "Zerio-Cardealer-Migration | Has successfully imported all vehicles")
    end)
elseif GetResourceState("es_extended") == "started" then -- ESX
    SelectSQL("SELECT * FROM `vehicles`", {}, function(result)
        if result then
            local length = #result

            local idx = 0
            for i, v in pairs(result) do
                idx = idx + 1
                addVehicle(v.model, v.name, v.price, v.price, v.category,
                           "cardealer", idx, length)
                Wait(100)
            end

            print(
                "Zerio-Cardealer-Migration | Has successfully imported all vehicles")
        end
    end)
end
