local model = {}

function model.Create()
    local queue =
    {
        elements = {},
    }

    function queue:Put(data)
        table.insert(self.elements, data)
    end

    function queue:Pop()
        local ret = self.elements[#self.elements]
        table.remove(self.elements, #self.elements)
        return ret
    end
    return queue
end

return model
