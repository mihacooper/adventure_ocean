local context = require("models.kernel.context")
local model = {}

function model:Initialize()
  if context.player == nil then
    context.player = {}
  end
  context.player.x, context.player.y = 0, 0
end

function model:PlayerUpdate(data)
  context.player.x, context.player.y = data.x, data.y
  Debug("player", "Data updated:\n", context.player)
end

function model:Keypressed(k)
    local key = k.key
    Debug("player", "handle keypressed with key=" .. key)
    local map = {
        a = { 'left',  { -20,   0 } },
        w = { 'up',    {   0, -20 } },
        d = { 'right', {  20,   0 } },
        s = { 'down',  {   0,  20 } },
    }
    if map[key] then
        local strDir = map[key][1]
        context.connection:Send({request = "MOVEMENT", args = {direction = strDir}})
        context.player.x = context.player.x + map[key][2][1]
        context.player.y = context.player.y + map[key][2][2]
        local newPlayerCoord = { x = context.player.x, y = context.player.y}
        context.filter:AddExpectation('PlayerUpdate', newPlayerCoord)
    end
end

return model