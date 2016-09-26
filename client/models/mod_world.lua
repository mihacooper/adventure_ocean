local model = { grid = {} }

--[[ 
  Make this functions global
]]
function GetAllCoords(context, x, y)
  function GlobalToChunk(crd, width)
    if crd >= 0 then
        return crd / width
    else
        return ((crd + 1) / width) - 1
    end
  end
  
  function GlobalToCell(crd, width)
    if crd >= 0 then
        return crd % width
    else
        return ((crd + 1) % width)
    end
  end
  
  local chunk = { x = 0, y = 0}
  local cell = { x = 0, y = 0 }
  chunk.x = GlobalToChunk(x, context.grid.ChunkWidth)
  chunk.y = GlobalToChunk(y, context.grid.ChunkHeight)
  cell.x  = GlobalToCell( x, context.grid.CellWidth)
  cell.y  = GlobalToCell( y, context.grid.CellHeight)
  return chunk.x, chunk.y, cell.x, cell.y
end

function model:Initialize(context)
  context.grid = {}
  context.connection:Send({request = "WorldSettings", args = {}})
  context.resources['background.grass'] = love.graphics.newImage("resources/grass.png")
end

function model:Draw(context, data)
  if not context.states["World.Initialized"] then
    return
  end
  
  if data.level == 1 then
    local lux, luy = context.player.x - love.graphics.getWidth() / 2, context.player.y - love.graphics.getHeight() / 2
    local rdx, rdy = context.player.x + love.graphics.getWidth() / 2, context.player.y + love.graphics.getHeight() / 2
    
    local chx, chy, cex, cey = GetAllCoords(context, lux, luy)
    love.graphics.draw(context.resources['background.grass'], 
        0, 0)--, math.pi * 2, 1, 1, 50, 50)
  end
end

function model:Update(context, dt)
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
    local x,y = GetAllCoords(context, context.player.x, context.player.y)
    SendChunkRequest(x,     y)
    SendChunkRequest(x - 1, y)
    SendChunkRequest(x + 1, y)
    SendChunkRequest(x    , y - 1)
    SendChunkRequest(x    , y + 1)
    SendChunkRequest(x - 1, y - 1)
    SendChunkRequest(x + 1, y + 1)
    SendChunkRequest(x - 1, y + 1)
    SendChunkRequest(x + 1, y - 1)
  end  
end

function model:WorldSettings(context, settings)
  context.grid.CellWidth   = settings.CellWidth
  context.grid.CellHeight  = settings.CellHeight
  context.grid.ChunkWidth  = settings.ChunkWidth
  context.grid.ChunkHeight = settings.ChunkHeight
  Debug("world", "Data updated:", self)
  context.states["World.Initialized"] = true
end

function model:ChunkUpdate(context, data)
  local x, y = data.location.x, data.location.y
  if context.grid[x] == nil then
    context.grid[x] = {}
  end
  context.grid[x][y] = data.data
  Debug("world", "Data updated:", self)
end

return model