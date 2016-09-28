local context = require("models.kernel.context")
local Grid = require("models.kernel.grid")

local model = { }

function model:Initialize()
    context.grid = Grid()
    context.connection:Send({request = "WorldSettings", args = {}})
    context.resources['background.grass'] = love.graphics.newImage("resources/grass.png")
    context.resources['background.earth'] = love.graphics.newImage("resources/earth.png")
end

function model:Draw(data)
    if not context.states["World.Initialized"] then
        return
    end
  
    if not data.level == 1 then
        return
    end
    
    local lux, luy = context.grid:GetCellCoord(context.player.x - context.window.Width / 2,
                        context.player.y - love.graphics.getHeight() / 2)
    local rdx, rdy = context.grid:GetCellCoord(context.player.x + context.window.Height / 2,
                        context.player.y + love.graphics.getHeight() / 2)
    for x = lux, rdx + 1, 1 do
        for y = luy, rdy + 1, 1 do
            local cell = context.grid:GetCell(x, y)
            if cell and cell ~= nil then
                local draw_x, draw_y = x * context.grid.CellWidth - context.player.x + context.window.Width / 2,
                             y * context.grid.CellHeight - context.player.y + context.window.Height / 2
                local img = nil
                if cell[1] == 1 then
                    img = context.resources['background.grass']
                elseif cell[1] == 2 then
                    img = context.resources['background.earth']
                end
                love.graphics.draw(img, draw_x, draw_y)--, math.pi * 2, 1, 1, 50, 50)
            end
        end
    end
end

function model:Update(dt)
  if not context.states["World.Initialized"] then
    return
  end

  function SendChunkRequest(x, y)
    if context.grid[x] == nil or context.grid[x][y] == nil then
      context.connection:Send({request = "ChunkRequest", args = {location = { x = x, y = y}}})
      context.grid[x] = context.grid[x] or {}
      context.grid[x][y] = {}
    end
  end
  
  if context.player and context.player.x and context.player.y then
    local cx,cy = context.grid:GetChunkCoord(context.player.x, context.player.y)
    for x = cx - 1, cx + 1, 1 do
      for y = cy - 1, cy + 1, 1 do
        SendChunkRequest(x, y)
      end
    end
  end  
end

function model:WorldSettings(settings)
  context.grid.CellWidth   = settings.CellWidth
  context.grid.CellHeight  = settings.CellHeight
  context.grid.ChunkWidth  = settings.ChunkWidth
  context.grid.ChunkHeight = settings.ChunkHeight
  Debug("world", "Data updated:", self)
  context.states["World.Initialized"] = true
end

function model:ChunkUpdate(data)
  local x, y = data.location.x, data.location.y
  if context.grid[x] == nil then
    context.grid[x] = {}
  end
  context.grid[x][y] = data.data
  Debug("world", "Data updated:", self)
end

return model