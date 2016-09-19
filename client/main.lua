math = require "math"
connection = require "connection"
queue = require "models.kernel.queue"

--io.stdout:setvbuf('no')

Models = {}
Context = {}

function love.load()
  --[[
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
  ]]

  
  -- Log thread
  logger = love.thread.newThread("log_thread.lua")
  if logger == nil then
    Error("system", "Unable to create Logger, quit")
    love.event.quit(0)
  end
  logger:start()
  Context.logger = logger

  if not connection:Create() then
    Error("system", "Unable to create Listener, quit")
    love.event.quit(0)
  end
  Context.connection = connection

  Context.events = queue.Create()
  Context.events:Put({ event = "Initialize", data = {} })
  local files = love.filesystem.getDirectoryItems("models")
  for _, file in pairs(files) do
    if love.filesystem.isFile("models/" .. file) and string.gmatch(file, "mod_.*.lua")() ~= "" then
      local model = require("models." .. string.sub(file, 1, -5))
      if model == nil then
        Error("system", "Unable to load model from file " .. file)
        love.event.quit(0)
      end
      Debug("system", "Model from " .. file .. " was loaded")
      table.insert(Models, model)
    end
  end
end

function love.update(dt)
  local sendToAll = function(msg)
    local ev, data = msg.event, msg.data
    for _, mod in pairs(Models) do
      local func = mod[ev]
      if func then
        func(mod, Context, data) -- 'self' is first param
      end
    end
  end

  for msg in function() return Context.connection:Recv() end do
    Debug("system", "Going to handle server msg " .. Quoted(msg.event))
    sendToAll(msg)
  end
  for msg in function() return Context.events:Pop() end do
    Debug("system", "Going to handle internal event " .. Quoted(msg.event))
    sendToAll(msg)
  end
end

function love.mousepressed( x, y, mb )
end

function love.keypressed(k)
    if k == 'escape' then
      love.event.quit(0)
    end
    Debug("system", "Put event keypressed " .. Quoted(k))
    Context.events:Put({ event = "Keypressed", data = { key = k } })
end

function love.draw()
end
