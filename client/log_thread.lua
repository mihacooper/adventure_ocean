thread = require "love.thread"

local logChan = thread.getChannel("Logging")
local logFile = io.open("client.log", "w")

while true do
  local msg = logChan:pop()
  if msg then
    logFile:write(msg)
    logFile:flush()
  end
end
