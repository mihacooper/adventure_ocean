require "models.kernel.helpers"

local model = {}

function model:Initialize(context)

end

function model:Keypressed(context, k)
    local key = k.key
    Debug("Player key pressed handle with key=" .. key)
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