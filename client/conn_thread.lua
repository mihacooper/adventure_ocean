thread = require "love.thread"
require "models.kernel.helpers"
require "module.json"
socket = require "socket"
SERVER_HOST, SERVER_PORT = "127.0.0.1", 1212


Debug("connection", "separate thread started")

local arguments = { ... }
local threadType =  arguments[1]
Debug("connection", "start thread with param =", Quoted(threadType))

local InternalChannel = thread.getChannel("int.ConnectionExchangeThread")

if threadType == "Sender" then
  local ErrorChan = thread.getChannel("SendChannelErr")
  local SendChan  = thread.getChannel("ChannelToSend")
  local ConnectionToSend = socket.tcp()

  Debug("sender", "Try to establish first connection")
  ret, err = ConnectionToSend:connect(SERVER_HOST, SERVER_PORT)
  if not ret then
    Error("sender", "Unable to connect ot server: " .. err)
    return
  end

  Debug("sender", "Send empty ID message")
  ret, err = ConnectionToSend:send('{"id": "None"}\n')
  if not ret then
    Error("sender", "Unable to send 'Hello' message: " .. err)
    return
  end

  Debug("sender", "Read ID from server")
  sid, err = ConnectionToSend:receive('*l')
  if not sid then
    Error("sender", "Unable to receive self ID: " .. err)
    return
  end

  Debug("sender", "Try to decode server message: " .. sid)
  local id = json.decode(sid).id .. ''
  InternalChannel:push(id)

  Debug("sender", "Send success result to main thread")
  ErrorChan:push("OK")

  Debug("sender", "Start infinite loop...")
  while true do
    local data = SendChan:pop()
    if data ~= nil then
      Debug("sender", "Sending data to server:\n" .. Quoted(data))
      ret, err = ConnectionToSend:send(data)
      if ret == nil then
        Error("sender", "Unable to send message", Quoted(data), ", err:", err)
      end
    end
  end

elseif threadType == "Receiver" then
  local ErrorChan = thread.getChannel("RecvChannelErr")
  local RecvChan  = thread.getChannel("ChannelToRecv")
  local ConnectionToRecv = socket.tcp()

  Debug("receiver", "Try to establish second connection")
  ret, err = ConnectionToRecv:connect(SERVER_HOST, SERVER_PORT)
  if not ret then
    Error("receiver", "Unable to connect to server: " .. err)
    return
  end

  Debug("receiver", "Wait for ID from listener")
  local id = InternalChannel:demand()
  
  Debug("receiver", "Send confirm message to server with, ID=" .. id)
  ret, err = ConnectionToRecv:send('{"id": "' .. id .. '"}\n')
  if not ret then
    Error("receiver", "Unable to send 'ID' message: " .. err)
    return
  end

  Debug("receiver", "Send success result to main thread")
  ErrorChan:push("OK")
  
  Debug("receiver", "Start infinite loop...")
  while true do
    data, err = ConnectionToRecv:receive('*l')
    if data then
      Debug("receiver", "Receive data from server: " .. Quoted(data))
      RecvChan:push(data)
    end
  end
end
