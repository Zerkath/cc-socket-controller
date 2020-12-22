local json = require "json" --external dependancy https://github.com/rxi/json.lua
local label = os.getComputerLabel()
local coords = {
    x = 0,
    y = 0,
    z = 0,
    heading = "north"
}
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

local function getCoordsFromUser()
    print("x")
    coords["x"] = readNumber()
    print("y")
    coords["y"] = readNumber()
    print("z")
    coords["z"] = readNumber()
    print("Heading (north, west, east, south)")
    coords["heading"] = readLine()
end

local function getStringArr(string)
    local arr = {}
    local i = 0
    for str in string.gmatch(string, "%S+") do
        arr[i] = str
        i = i + 1
    end
    return arr
end

local function getAllItemSlots()
    local items = {}
    for slot = 1, 16 do
        local item = turtle.getItemDetail(slot)
        if not item then
            item = {}
        end
        item["index"] = slot-1
        items[slot] = item
    end
    ws.send("items " .. json.encode(items))
end

-- todo clean this method up
local function Move(direction)
    local heading = coords["heading"]
    if direction == "forward" then
        if turtle.forward() then
            if heading == "north" then
                coords["z"] = coords["z"] - 1
            elseif heading == "east" then
                coords["x"] = coords["x"] + 1
            elseif heading == "south" then
                coords["z"] = coords["z"] + 1
            elseif heading == "west" then
                coords["x"] = coords["x"] - 1
            else
                turtle.back() --invalid direction lets go back
            end
        end
    elseif direction == "back" then
        if turtle.back() then
            if heading == "north" then
                coords["z"] = coords["z"] + 1
            elseif heading == "east" then
                coords["x"] = coords["x"] - 1
            elseif heading == "south" then
                coords["z"] = coords["z"] - 1
            elseif heading == "west" then
                coords["x"] = coords["x"] + 1
            else
                turtle.forward() --invalid direction lets go back
            end
        end
    elseif direction == "left" then
        if turtle.turnLeft() then
            if heading == "north" then
                coords["heading"] = "west"
            elseif heading == "west" then
                coords["heading"] = "south"
            elseif heading == "south" then
                coords["heading"] = "east"
            elseif heading == "east" then
                coords["heading"] = "north"
            end
        end
    elseif direction == "right" then
        if turtle.turnRight() then
            if heading == "north" then
                coords["heading"] = "west"
            elseif heading == "west" then
                coords["heading"] = "south"
            elseif heading == "south" then
                coords["heading"] = "east"
            elseif heading == "east" then
                coords["heading"] = "north"
            end
        end
    elseif direction == "up" then
        if turtle.up() then
            coords["y"] = coords["y"] + 1
        end
    elseif direction == "down" then
        if turtle.down() then
            coords["y"] = coords["y"] - 1
        end
    end
    ws.send("position " .. json.encode(coords))
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

if ws then
    print("> connected")
    getCoordsFromUser()
    while true do
        ws.send("waiting")
        local response = ws.receive()
        if response then
            local actions = getStringArr(response)
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
            elseif(header == "items") then
                getAllItemSlots()
            end
        end
    end
end
--
-- local success, data = turtle.inspect()
-- if(data.name ~= "minecraft:air") then
--     turtle.dig()
-- end
