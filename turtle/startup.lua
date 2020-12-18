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
        if response == "forward" then
            turtle.forward()
        elseif(response == "back") then
            turtle.back()
        elseif(response == "left") then
            turtle.turnLeft()
        elseif(response == "right") then
            turtle.turnRight()
        elseif(response == "up") then
            turtle.up()
        elseif(response == "down") then
            turtle.down()
        end
    end
end
