local model = {}

function model:Initialize(context)
  self.x, self.y = 0, 0
end

function model:PlayerUpdate(context, data)
  self.x, self.y = data.x, data.y
  Debug("player", "Data updated:\n", self)
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