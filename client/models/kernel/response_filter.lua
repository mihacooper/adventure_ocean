require("models.kernel.helpers")

local filter = {
    expectations = {}
}

-- Return true if event was handled. It means that event can be skipped
function filter:HandleEvent(event, data)
    local allExp = self.expectations[event]
    if allExp then
        for i, exp in ipairs(allExp) do
            if ToString(exp) == ToString(data) then
                table.remove(allExp, i)
                return true
            end
        end
    end
    Debug('filter', 'Cann\'t find expectation for', event)
    return false
end

function filter:AddExpectation(event, data)
    if not self.expectations[event] then
        self.expectations[event] = {}
    end
    table.insert(self.expectations[event], data)
end

return filter