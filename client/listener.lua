require "helpers"
socket = require "socket"
json = require "json"

SERVER_HOST, SERVER_PORT = "127.0.0.1", 1212

local Listener = 
{
  Create = function ()
    ConnectionToSend = socket.tcp()
    ConnectionToRecv = socket.tcp()

    ret, err = ConnectionToSend:connect(SERVER_HOST, SERVER_PORT)
    if not ret then
      print ("Unable to connect ot server: " .. err)
      return nil
    end

    ret, err = ConnectionToSend:send('{"id": "None"}\n')
    if not ret then
      print ("Unable to send 'Hello' message: " .. err)
      return nil
    end
    
    sid, err = ConnectionToSend:receive('*l')
    if not sid then
      print ("Unable to receive self ID: " .. err)
      return nil
    end
    id = json.decode(sid)
    id = id.id

    ret, err = ConnectionToRecv:connect(SERVER_HOST, SERVER_PORT)
    if not ret then
      print ("Unable to connect to server: " .. err)
      return nil
    end

    ret, err = ConnectionToRecv:send('{"id": ' .. id .. '}')  
    if not ret then
      print ("Unable to send 'ID' message: " .. err)
      return nil
    end

    local t = {}
    t.connectionToSend = ConnectionToSend
    t.connectionToRecv = ConnectionToRecv

    function t:Send(data)
      local ret, jdata = SafeCall(json.encode, data, true)
      if not ret then
        print ("Unable to parse data to json")
        return false
      end
      ret, err = self.connectionToSend:send(jdata)
      if ret == nil then
        print ("Unable to send message '" .. jdata .. "', err: " .. err)
        return false
      end
      return true
    end

    function t:Recv()
      jdata, err = self.connectionToRecv:receive('*l')
      if not jdata then
        print ("Unable to receive self ID: " .. err)
        return nil
      end
      local ret, data = SafeCall(json.decode, jdata)
      if not ret then
        print ("Unable to parse data from json")
        return nil
      end
      return data
    end

    return t
  end,
}

return Listener