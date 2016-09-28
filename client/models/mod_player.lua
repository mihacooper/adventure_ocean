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
    if     key == 'a' then
        context.connection:Send({request = "MOVEMENT", args = {direction = "left"}})
    elseif key == 'w' then
        context.connection:Send({request = "MOVEMENT", args = {direction = "up"}})
    elseif key == 'd' then
        context.connection:Send({request = "MOVEMENT", args = {direction = "right"}})
    elseif key == 's' then
        context.connection:Send({request = "MOVEMENT", args = {direction = "down"}})
    end
end

return model