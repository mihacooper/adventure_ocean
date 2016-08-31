math = require "math"
socket = require "socket"
json = require "json"

connectionToSend = nil
connectionToRecv = nil

--[[
function love.load()
  local window_width = love.graphics.getWidth()
  local window_height = love.graphics.getHeight()
  local minor = 8
  if love.getVersion ~= nil then
    _, minor, _, _ = love.getVersion()
  end
  LOVE_VERSION_IS_OLD = not (minor > 8)
  
  if LOVE_VERSION_IS_OLD then
    love.graphics.setMode(window_width, window_height, true, true, 2)
  else
    love.window.setMode(window_width, window_height, {fullscreen = true})
  end
  return
]]
  connectionToSend = socket.tcp()
  connectionToRecv = socket.tcp()
  
  print("Try to connect listen channel")
  ret, err = connectionToSend:connect("127.0.0.1", 1212)
  print("1")
  if not ret then
    print ("Unable to connect ot server: " .. err)
    --love.event.quit(0)
  end
  
  print("Send request for ID")
  ret, err = connectionToSend:send('{"id": "None"}\n')
  print("1")
  if not ret then
    print ("Unable to send 'Hello' message: " .. err)
    --love.event.quit(0)
  end
  
  print("Read working ID")
  sid, err = connectionToSend:receive('*l')
  print(sid)
  if not sid then
    print ("Unable to receive self ID: " .. err)
    --love.event.quit(0)
  end
  id = json.decode(sid)
  id = id.id

  print("Try to connect receive channel")
  ret, err = connectionToRecv:connect("127.0.0.1", 1212)
  if not ret then
    print ("Unable to connect to server: " .. err)
    --love.event.quit(0)
  end
  print("Send second ID")
  ret, err = connectionToRecv:send('{"id": ' .. id .. '}')  
  if not ret then
    print ("Unable to send 'ID' message: " .. err)
    --love.event.quit(0)
  end
  print("Send request")
  connectionToSend:send('{"request": "command", "args": "arguments"}\n')
--end

--[[
function love.update(dt)
end
 
function love.mousepressed( x, y, mb )
end

function love.keypressed(k)
    if k == 'escape' then
      love.event.quit(0)
      --  love.event.push('q')
    end
end
function love.draw()
end
]]
