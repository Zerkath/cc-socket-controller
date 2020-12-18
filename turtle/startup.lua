local ws, err = http.websocket("ws://localhost:5000")

if err then
    print(err)
end

if ws then
    print("> connected")
    while true do
        local response = ws:receive()
        if response then
            print(response)
            if response == "move" then
                turtle.forward()
            else
                ws:send("message", "waiting")
            end
        end
    end
end
