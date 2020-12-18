local ws, err = http.websocket("ws://localhost:5000")

if err then
    print(err)
end

if ws then
    print("> connected")
    while true do
        ws.send("fuel_level " .. turtle.getFuelLevel())
        ws.send("waiting")
        local response = ws.receive()
        if response == "go" then
            local success, data = turtle.inspect()
            if(data.name ~= "minecraft:air") then
                turtle.dig()
            end
            turtle.forward()
        elseif(response == "back") then
            turtle.back()
        elseif(response == "left") then
            turtle.turnLeft()
        elseif(response == "right") then
            turtle.turnRight()
        elseif(response == "up") then
            local success, data = turtle.inspectUp()
            if(data.name ~= "minecraft:air") then
                turtle.digUp()
            end
            turtle.up()
        elseif(response == "down") then
            local success, data = turtle.inspectDown()
            if(data.name ~= "minecraft:air") then
                turtle.digDown()
            end
            turtle.down()
        elseif(response == "dig") then
            turtle.dig()
            turtle.digUp()
            turtle.digDown()
        end
    end
end