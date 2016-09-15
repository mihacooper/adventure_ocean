require 'string'

function Print(...)
    print(table.concat(arg, " "))
end

function Debug(...)
    Print("[ DEBUG ]", arg)
end

function Error(...)
    Print("[ ERROR ]", arg)
end

function Info(...)
    Print("[ INFO ]", arg)
end

function Expect(cond, msg)
    if not cond then
        Error(msg)
    end
end

function table.copy(dst, src)
    for k, v in pairs(src)
    do
        dst[k] = v
    end
end

function table.rcopy(dst, src)
    for k, v in pairs(src) do
        if IsTable(v) then
            dst[k] = {}
            table.rcopy(dst[k], v)
        else
            dst[k] = v
        end
    end
end

function table.exclude(dst, src)
    for k, v in pairs(src)
    do
        dst[k] = nil
    end
end

function table.iforeach(array, func)
    local res = {}
    for _, v in ipairs(array)
    do
        table.insert(res, func(v))
    end
    return res
end

function WriteToFile(filename, data)
    local file = io.open(filename, "w")
    file:write(data)
    file:close()
end

function StrReplace(str, args)
    local result = str
    for name, value in pairs(args) do
        local pattern = '{{' .. name .. '}}'
        result = string.gsub(result, pattern, value)
    end
    return result
end

function ToString(val)
    return val .. ''
end

function IsTable(val)
    return type(val) == type({})
end

function IsString(val)
    return type(val) == type('')
end

function In(val, cont)
    for _, v in pairs(cont) do
        if v == val then
            return true
        end
    end
    return false
end

function Quoted(msg)
  return '"' .. '"'
end

function SafeCall(func, ...)
    local res, args = nil, {...}
    function Runnner()
        res = func(unpack(args))
    end
    return pcall(Runnner), res
end
