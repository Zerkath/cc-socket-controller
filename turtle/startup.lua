local json = require "json" --external dependancy https://github.com/rxi/json.lua
local label = os.getComputerLabel()
local position = {
    x = 0,
    y = 0,
    z = 0,
    heading = "north"
}
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

local function getPositionFromUser()
    print("x\ty\tz")
    local answer = readLine()
    local coords = getStringArr(answer)
    position["x"] = tonumber(coords[0])
    position["y"] = tonumber(coords[1])
    position["z"] = tonumber(coords[2])
    print("Heading (north, west, east, south)")
    position["heading"] = readLine()
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

-- todo clean this method up
local function Move(direction)
    local heading = position["heading"]
    if direction == "forward" then
        if turtle.forward() then
            if heading == "north" then
                position["z"] = position["z"] - 1
            elseif heading == "east" then
                position["x"] = position["x"] + 1
            elseif heading == "south" then
                position["z"] = position["z"] + 1
            elseif heading == "west" then
                position["x"] = position["x"] - 1
            else
                turtle.back() --invalid direction lets go back
            end
        end
    elseif direction == "back" then
        if turtle.back() then
            if heading == "north" then
                position["z"] = position["z"] + 1
            elseif heading == "east" then
                position["x"] = position["x"] - 1
            elseif heading == "south" then
                position["z"] = position["z"] - 1
            elseif heading == "west" then
                position["x"] = position["x"] + 1
            else
                turtle.forward() --invalid direction lets go back
            end
        end
    elseif direction == "left" then
        if turtle.turnLeft() then
            if heading == "north" then
                position["heading"] = "west"
            elseif heading == "west" then
                position["heading"] = "south"
            elseif heading == "south" then
                position["heading"] = "east"
            elseif heading == "east" then
                position["heading"] = "north"
            end
        end
    elseif direction == "right" then
        if turtle.turnRight() then
            if heading == "north" then
                position["heading"] = "east"
            elseif heading == "east" then
                position["heading"] = "south"
            elseif heading == "south" then
                position["heading"] = "west"
            elseif heading == "west" then
                position["heading"] = "north"
            end
        end
    elseif direction == "up" then
        if turtle.up() then
            position["y"] = position["y"] + 1
        end
    elseif direction == "down" then
        if turtle.down() then
            position["y"] = position["y"] - 1
        end
    end
    ws.send("position " .. json.encode(position))
end

local function Dig(direction) --doesnt move the turtle
    if direction == "forward" then
        turtle.dig()
    elseif direction == "down" then
        turtle.digDown()
    elseif direction == "up" then
        turtle.digUp()
    end
end

local function instructionInterpeter(commands)
    local header = commands[0]
    if(header == "move") then
        if commands[2] then
            for i = 1, tonumber(commands[2]) do
                Move(commands[1])
            end
        else
            Move(commands[1])
        end
    elseif(header == "dig") then
        if commands[2] then
            for i = 1, tonumber(commands[2]) do
                Dig(commands[1])
            end
        else
            Dig(commands[1])
        end
    elseif(header == "tunnel") then
        if commands[2] then
            for i = 1, tonumber(commands[2]) do
                Dig(commands[1])
                Move(commands[1])
            end
        else
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
    getPositionFromUser()
    ws.send("position " .. json.encode(position))
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
