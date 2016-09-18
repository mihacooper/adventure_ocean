require "models.kernel.helpers"
socket = require "socket"
json = require "json"

local conn = {}

function conn:Create()
    self.sendChan = love.thread.getChannel("ChannelToSend")
    self.recvChan = love.thread.getChannel("ChannelToRecv")
    self.errChan  = love.thread.getChannel("ChannelConnErr")
    self.thread = love.thread.newThread("conn_thread.lua")
    if self.thread == nil then
        return false
    end
    self.thread:start()
    local result = self.errChan:demand()
    if result == "OK" then
        return true
    end
    Error(result)
    --[[ ]]
    return false
end


function conn:Send(data)
    local ret, jdata = SafeCall(json.encode, data, true)
    if not ret then
        Error("Unable to parse data to json", data)
        return false
    end
    jdata = jdata .. "\n"
    self.sendChan:push(jdata)
end

function conn:Recv()
    local jdata = self.recvChan:pop()
    if jdata then
        ret, data = SafeCall(json.decode, jdata)
        if not ret then
            Error("Unable to parse data from json", jdata)
            return nil
        end
    end
    return data
end

return conn