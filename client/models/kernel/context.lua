local Grid = require("models.kernel.grid")

local context =
{
    states = {}, -- Use to decalre some internal state like "initiated"
    resources = {},
    window = {},
    grid = Grid(),
    filter = require("models.kernel.response_filter"),
}

return context
