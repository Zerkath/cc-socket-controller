local label = os.getComputerLabel()
local ws, err = http.websocket("ws://localhost:5000/".. label)
if err then
    print(err)
    exit()
end

function GetStringArr(string)
    local arr = {}
    local i = 0
    for str in string.gmatch(string, "%S+") do
        arr[i] = str
        i = i + 1
    end
    return arr
end

function Move(direction)
    if direction == "forward" then
        turtle.forward()
    elseif direction == "back" then
        turtle.back()
    elseif direction == "left" then
        turtle.turnLeft()
    elseif direction == "right" then
        turtle.turnRight()
    elseif direction == "up" then
        turtle.up()
    elseif direction == "down" then
        turtle.down()
    end
end

function Dig(direction)
    if direction == "forward" then
        turtle.dig()
    elseif direction == "down" then
        turtle.digDown()
    elseif direction == "up" then
        turtle.digUp()
    end
end

if ws then
    print("> connected")
    while true do
        ws.send("waiting")
        local response = ws.receive()
        if response then
            local actions = GetStringArr(response)
            local header = actions[0]
            if(header == "move") then
                for i = 1, tonumber(actions[2]) do
                    Move(actions[1])
                end
            elseif(header == "dig") then
                for i = 1, tonumber(actions[2]) do
                    Dig(actions[1])
                end
            elseif(header == "fuel") then
                ws.send("fuel " .. turtle.getFuelLevel())
            elseif(header == "tunnel") then
                for i = 1, tonumber(actions[2]) do
                    Dig(actions[1])
                    Move(actions[1])
                end
            end
        end
    end
end
--
-- local success, data = turtle.inspect()
-- if(data.name ~= "minecraft:air") then
--     turtle.dig()
-- end
