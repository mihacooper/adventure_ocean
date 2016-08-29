import SocketServer, json, Queue

from server.kernel.dispatcher import Dispatcher, EVENT_SEND
from server.kernel.helpers import *


class ConnectionHandler(SocketServer.StreamRequestHandler):
    @SafeCall
    def handle(self):
        Info("Accept connection from %s:%d" % (self.client_address[0], self.client_address[1]))
        data = self.rfile.readline().strip()

        Info("New client sends %s" % data)
        jdata = json.loads(data)
        if jdata.get('id') is None:
            raise Exception("Message does not include ID")
        if jdata["id"] == "None":
            self.is_sender = False
            self.id = str(hash(self.client_address[0] + str(self.client_address[1])))
            self.wfile.write('{"id": "%s"}\n' % self.id)
        else:
            self.is_sender = True
            self.queue = Queue.Queue()
            # TODO: CHANGE THIS SHIT!!!
            self.id = jdata["id"]
            Dispatcher().Subscribe((EVENT_SEND, self.id), )

        while True:
            data = self.rfile.readline().strip()
            if self.is_sender:
                Info("Received data (%s:%d)\n\t%s" % (self.client_address[0], self.client_address[1], str(data)))
                if not self.queue.empty():
                    json.dump()
                    self.wfile.write(self.queue.get())
            else:
                Info("Received data (%s:%d)\n\t%s" % (self.client_address[0], self.client_address[1], str(data)))
                jdata = json.loads(data)
                if jdata.get('request')is None or jdata.get('args') is None:
                    raise Exception("Invalid request format")
                Dispatcher().Send(jdata.get('request'), jdata.get('args'))

    @SafeCall
    def SendHandle(self, _, params):
        self.queue.put_nowait(params)


class Server(object):
    def __listener(self, socketServer):
        socketServer.serve_forever()

    def __init__(self, host, port):
        self.socketServer = SocketServer.TCPServer((host, port), ConnectionHandler)
        self.listener = threading.Thread(target = self.__listener, args = (self.socketServer, ), name = "Listener thread")

    def Start(self):
        Info("Start server on %s..." % str(self.socketServer.server_address))
        self.listener.start()
        Info("Server has been started")

    def Stop(self):
        Info("Stop server...")
        self.socketServer.shutdown()
        self.listener.join(timeout = 5)
        Info("Server has been stoped")
