#!/usr/bin/python

#----
from listener import Server
from server.kernel.dispatcher import Dispatcher, EVENT_INIT
from server.kernel.helpers import *

"""
Server params
"""
HOST, PORT = "127.0.0.1", 1212

if __name__ == "__main__":
    server = Server(HOST, PORT)
    try:
        server.Start()

        Dispatcher().Initialize()
        Dispatcher().Send(EVENT_INIT)
        while 1:
            pass
    except KeyboardInterrupt, e:
       Info("Got stop command")
    except Exception, e:
       Info("Error: something went wrong, server will be stoped\n\t%s" % str(e))
    finally:
        Dispatcher().Uninitialize()
        server.Stop()
