thread = require "love.thread"
require "models.kernel.helpers"
socket = require "socket"
json = require "json"
SERVER_HOST, SERVER_PORT = "127.0.0.1", 1212

local ErrorChan = thread.getChannel("ChannelConnErr")
local SendChan  = thread.getChannel("ChannelToSend")
local RecvChan  = thread.getChannel("ChannelToRecv")

local ConnectionToSend = socket.tcp()
local ConnectionToRecv = socket.tcp()

Debug("Try to establish first connection")
ret, err = ConnectionToSend:connect(SERVER_HOST, SERVER_PORT)
if not ret then
  ErrorChan:push("Unable to connect ot server: " .. err)
  return
end

Debug("Try to establish second connection")
ret, err = ConnectionToRecv:connect(SERVER_HOST, SERVER_PORT)
if not ret then
  ErrorChan:push("Unable to connect to server: " .. err)
  return
end

Debug("Send empty ID message")
ret, err = ConnectionToSend:send('{"id": "None"}\n')
if not ret then
  ErrorChan:push("Unable to send 'Hello' message: " .. err)
  return
end

Debug("Read ID from server")
sid, err = ConnectionToSend:receive('*l')
if not sid then
  ErrorChan:push("Unable to receive self ID: " .. err)
  return
end

Debug("Try to decode server message: " .. sid)
local id = json.decode(sid)
id = '' .. id.id -- to string

Debug("Send confirm message to server with, ID=" .. id)
ret, err = ConnectionToRecv:send('{"id": "' .. id .. '"}\n')
if not ret then
  ErrorChan:push("Unable to send 'ID' message: " .. err)
  return
end

function Send(data)
  Debug("Sending data to server:" .. Quoted(sdata))
  ret, err = ConnectionToSend:send(data)
  if ret == nil then
    --Error("Unable to send message", Quoted(data), ", err:", err)
    return false
  end
end
  
function Recv()
  jdata, err = ConnectionToRecv:receive('*l')
  if not jdata then
    --Error("Unable to receive self ID: " .. err)
    return nil
  end
  Debug("Receive data from server: " .. Quoted(jdata))
  return jdata
end

Debug("Send success result to main thread")
ErrorChan:push("OK")

Debug("Start infinite loop...")
while true do
  local sd = SendChan:pop()
  if sd ~= nil then
    Send(sd)
  end
  local rd = Recv()
  if rd ~= nil then
    RecvChan:push(rd)
  end
end

