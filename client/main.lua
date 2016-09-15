math = require "math"
Listener = require "listener"

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

  listener = Listener.Create()
  if listener == nil then
    print("Unable to create Listener, quit")
    love.event.quit(0)
  end
end

function love.update(dt)
end
 
function love.mousepressed( x, y, mb )
end

function love.keypressed(k)
    if k == 'escape' then
      love.event.quit(0)
    elseif k == 'a' then
        listener:Send({request = "MOVEMENT", args = {direction = "left"}})
    elseif k == 'w' then
        listener:Send({request = "MOVEMENT", args = {direction = "up"}})
    elseif k == 'd' then
        listener:Send({request = "MOVEMENT", args = {direction = "right"}})
    elseif k == 's' then
        listener:Send({request = "MOVEMENT", args = {direction = "down"}})
    end
end

function love.draw()
end
