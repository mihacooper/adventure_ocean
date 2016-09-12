function SafeCall(func, ...)
    local res, args = nil, {...}
    function Runnner()
        res = func(unpack(args))
    end
    return pcall(Runnner), res
end