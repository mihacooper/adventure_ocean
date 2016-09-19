require 'string'
require 'os'

-- For usage from separate threads
if love == nil and thread == nil then
  love = { thread = require("love.thread") }
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
    if type(val) == type({}) then
      local ret = "{"
      for k, v in pairs(val) do
          ret = ret .. string.format(" %s = %s,", ToString(k), ToString(v))
      end
      ret = string.sub(ret, 1, -2)
      return ret .. " }" 
    elseif val == nil then
        return 'nil'
    else
        return val .. ''
    end
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
  return '"' .. ToString(msg) .. '"'
end

function Print(...)
    local parsed = ""
    for _, val in pairs({...}) do
        parsed = parsed .. " " .. ToString(val) 
    end
    local logChan = love.thread.getChannel("Logging")
    logChan:push(os.date("%x %X ") .. parsed .. "\n")
end

function Debug(...)
    Print("[ DEBUG ]", ...)
end

function Error(...)
    Print("[ ERROR ]", ...)
end

function Info(...)
    Print("[ INFO ]", ...)
end

function Expect(cond, msg)
    if not cond then
        Error(msg)
    end
end
