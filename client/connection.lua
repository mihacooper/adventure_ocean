require "models.kernel.helpers"
require "module.json"
socket = require "socket"

local conn = {}

function conn:Create()
    self.sendChan = love.thread.getChannel("ChannelToSend")
    self.recvChan = love.thread.getChannel("ChannelToRecv")
    self.sendChanErr = love.thread.getChannel("SendChannelErr")
    self.recvChanErr = love.thread.getChannel("RecvChannelErr")

    self.sendThread = love.thread.newThread("conn_thread.lua")
    self.recvThread = love.thread.newThread("conn_thread.lua")
    if self.sendThread == nil or self.recvThread == nil then
        Error("connection", "Unable to create threads")
        return false
    end
    
    self.sendThread:start("Sender")
    self.recvThread:start("Receiver")
    
    -- TODO: make something less stupid than sleep
    love.timer.sleep(2)
    local sendThrRes = self.sendChanErr:pop()
    if sendThrRes ~= "OK" then
        Error(sendThrRes)
        return false
    end
    local recvThrRes = self.recvChanErr:pop()
    if recvThrRes ~= "OK" then
        Error(recvThrRes)
        return false
    end
    return true
end


function conn:Send(data)
    Debug("connection", "Send message", Quoted(data))
    local ret, jdata = pcall(json.encode, data, true)
    if not ret then
        Error("connection", "Unable to parse data to json", data)
        return false
    end
    jdata = jdata .. "\n"
    self.sendChan:push(jdata)
end

function conn:Recv()
    local jdata = self.recvChan:pop()
    if not jdata then
      return nil
    end
    Debug("connection", "Recv message", Quoted(jdata))
    local ret, data = pcall(json.decode, jdata)
    if not ret then
        Error("connection", "Unable to parse data from json, err: ", data)
        return nil
    end
    return data
end

return conn