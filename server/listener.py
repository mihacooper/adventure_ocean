import SocketServer, json, Queue, socket, threading

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
            self.queue_lock = threading.Lock()
            # TODO: CHANGE THIS SHIT!!!
            self.id = jdata["id"]
            Dispatcher().Subscribe((EVENT_SEND, self.id), self.SendHandle)

        while True:
            if self.is_sender:
                data_to_send = []
                with self.queue_lock:
                    while not self.queue.empty():
                        data_to_send.append(self.queue.get())
                if len(data_to_send) > 0:
                    jdata = json.dump(data_to_send)
                    Info("Send data to (%s:%d)\n\t%s" % (self.client_address[0], self.client_address[1], str(jdata)))
                    self.wfile.write(jdata)
            else:
                data = self.rfile.readline().strip()
                if data:
                    Info("Received data (%s:%d)\n\t%s" % (self.client_address[0], self.client_address[1], str(data)))
                    jdata = json.loads(data)
                    if jdata.get('request')is None or jdata.get('args') is None:
                        raise Exception("Invalid request format")
                    Dispatcher().Send(jdata.get('request'), jdata.get('args'))

    @SafeCall
    def SendHandle(self, _, params):
        if self.is_sender:
            with self.queue_lock:
                self.queue.put_nowait(params)

class WorkingTcpServer(SocketServer.ThreadingMixIn,SocketServer.TCPServer):
    pass

class Server(object):
    def __listener(self, socketServer):
        socketServer.serve_forever()

    def __init__(self, host, port):
        self.socketServer = WorkingTcpServer((host, port), ConnectionHandler)
        self.socketServer.socket.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
        self.serverThread = threading.Thread(target = self.__listener, args = (self.socketServer, ), name = "Listener thread")

    def Start(self):
        Info("Start server on %s..." % str(self.socketServer.server_address))
        self.serverThread.start()
        Info("Server has been started")

    def Stop(self):
        Info("Stop server...")
        self.socketServer.shutdown()
        self.serverThread.join(timeout = 60)
        Info("Server has been stoped")
