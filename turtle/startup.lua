local json = require "json" --external dependancy https://github.com/rxi/json.lua
local label = os.getComputerLabel()
local pos = {
    heading = 1 -- place turtle facing north for now
                -- todo define direction without user input
}
pos["x"], pos["y"], pos["z"] = gps.locate() --starting position
local function getStringArr(string)
    local arr = {}
    local i = 0
    for str in string.gmatch(string, "%S+") do
        arr[i] = str
        i = i + 1
    end
    return arr
end

local ws, err = http.websocket("ws://localhost:5000/".. label)
if err then
    print(err)
end

local function readLine()
    local r = io.stdin._handle.readLine()
    return r
end

local function readNumber()
    local r = tonumber(readLine())
    return r
end

local function getAllItemSlots()
    local items = {}
    for slot = 1, 16 do
        local item = turtle.getItemDetail(slot)
        if not item then
            item = {count = 0, name = "minecraft:air"}
        else
            item["damage"] = nil
        end
        items[slot] = item
    end
    ws.send("items " .. json.encode(items))
end

local function Turn(direction)
    local nH = pos["heading"]
    if direction == "left" then
        if turtle.turnLeft() then
            nH = nH - 1
            if nH < 1 then nH = nH + 4 end
        end
    elseif direction == "right" then
        if turtle.turnRight() then
            nH = nH + 1
            if nH > 4 then nH = nH - 4 end
        end
    end
    pos["heading"] = nH
end

local function Move(direction)
    if direction == "forward" then
        turtle.forward()
    elseif direction == "back" then
        turtle.back()
    elseif direction == "left" or direction == "right" then
        Turn(direction)
    elseif direction == "up" then
        turtle.up()
    elseif direction == "down" then
        turtle.down()
    end
    pos["x"], pos["y"], pos["z"] = gps.locate() --update position
    ws.send("position " .. json.encode(pos))
end

local function Dig(direction) --doesnt move the turtle
    if direction == "forward" then
        turtle.dig()
    elseif direction == "down" then
        turtle.digDown()
    elseif direction == "up" then
        turtle.digUp()
    end
    getAllItemSlots()
end

local function instructionInterpeter(commands)
    local header = commands[0]
    local count = 1;
    if commands[2] then -- if exists set number of commands to execute
        count = tonumber(commands[2])
    end
    if(header == "move") then
        for i = 1, count do
            Move(commands[1])
        end
    elseif(header == "dig") then
        for i = 1, count do
            Dig(commands[1])
        end
    elseif(header == "tunnel") then
        for i = 1, count do
            Dig(commands[1])
            Move(commands[1])
        end
    elseif(header == "fuel") then
        ws.send("fuel " .. turtle.getFuelLevel())
    elseif(header == "items") then
        getAllItemSlots()
    end
end

if ws then
    print("> connected")
    ws.send("position " .. json.encode(pos))
    while true do
        ws.send("waiting")
        local response = ws.receive()
        if response then
            local actions = getStringArr(response)
            local header = actions[0]
            if(header == "instructions") then
                local arr = string.sub(response, 13)
                local commands = json.decode(arr)
                for k, v in pairs (commands) do
                    instructionInterpeter(getStringArr(v))
                end
            else
                instructionInterpeter(actions)
            end
        end
    end
end
--
-- local success, data = turtle.inspect()
-- if(data.name ~= "minecraft:air") then
--     turtle.dig()
-- end
