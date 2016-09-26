local model = {}

function model:Initialize(context)
  if context.player == nil then
    context.player = {}
  end
  context.player.x, context.player.y = 0, 0
end

function model:PlayerUpdate(context, data)
  context.player.x, context.player.y = data.x, data.y
  Debug("player", "Data updated:\n", context.player)
end

function model:Keypressed(context, k)
    local key = k.key
    Debug("player", "handle keypressed with key=" .. key)
    if     key == 'a' then
        Context.connection:Send({request = "MOVEMENT", args = {direction = "left"}})
    elseif key == 'w' then
        Context.connection:Send({request = "MOVEMENT", args = {direction = "up"}})
    elseif key == 'd' then
        Context.connection:Send({request = "MOVEMENT", args = {direction = "right"}})
    elseif key == 's' then
        Context.connection:Send({request = "MOVEMENT", args = {direction = "down"}})
    end
end

return model