import SocketServer, json, Queue, socket, threading

from server.kernel.dispatcher import Dispatcher, EVENT_SEND, EVENT_NEW_CLIENT
from server.kernel.helpers import *
from server.kernel.objects_factory import ObjFactory

ServerStop = False
ConnQueue = {}
ConnQueueLock = threading.Lock()

class ConnectionHandler(SocketServer.StreamRequestHandler):
    @SilentSafeCall
    def SenderBody(self):
        data_to_send = None
        with self.queue_lock:
            if not self.queue.empty():
                data_to_send = self.queue.get()
        if data_to_send is not None:
            Debug("Data to send\n\t%s" % str(data_to_send))
            def PreParser(data):
                if isinstance(data, dict):
                    if data.get("transmittable"):
                        return { x: PreParser(data[x]) for x in data["transmittable"] }
                    else:
                        return { x: PreParser(data[x]) for x in data.keys() }
                return data
            data_to_send = PreParser(data_to_send)
            jdata = json.dumps(data_to_send)
            Debug("Send data to (%s:%d)\n\t%s" % (self.client_address[0], self.client_address[1], str(jdata)))
            self.wfile.write(jdata + "\n")

    @SilentSafeCall
    def ReceiverBody(self):
        data = self.rfile.readline().strip()
        if data:
            Debug("Received data (%s:%d)\n\t%s" % (self.client_address[0], self.client_address[1], str(data)))
            jdata = json.loads(data)
            if jdata.get('request')is None or jdata.get('args') is None:
                raise Exception("Invalid request format")
            Dispatcher().Send(jdata.get('request'), self.id, jdata.get('args'))

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
            with ConnQueueLock:
                ConnQueue[self.id] = [threading.Event(), threading.Event()]
            Info("Send response '%s'" % self.id)
            self.wfile.write('{"id": "%s"}\n' % self.id)
            Info("Receiver waits until sender appearance")
            if ConnQueue[self.id][0].wait(10) is not True:
                Throw("Receiver thread timed out, sender had not appeared")
            Info("Receiver waits while sender thread initialization")
            ConnQueue[self.id][1].wait()
            Info("Receiver starts working")
            with ConnQueueLock:
                ConnQueue[self.id] = None
        else:
            # TODO: CHANGE THIS SHIT!!!
            self.id = str(jdata["id"])
            with ConnQueueLock:
                if ConnQueue.get(self.id) is None:
                    Throw("Sender thread has not pair thread!")
                ConnQueue[self.id][0].set()
            self.is_sender = True
            self.queue = Queue.Queue()
            self.queue_lock = threading.Lock()
            Dispatcher().Subscribe((EVENT_SEND, self.id), self.SendHandle)
            ObjFactory().Add(self.id, {"transmittable" : []})
            Dispatcher().Send(EVENT_NEW_CLIENT, self.id)
            with ConnQueueLock:
                if ConnQueue.get(self.id) is None:
                    Throw("Sender thread unable to communicate with pair thread!")
                ConnQueue[self.id][1].set()

        while not ServerStop:
            if self.is_sender:
                self.SenderBody()
            else:
                self.ReceiverBody()

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
        ConnectionHandler.ServerStop = True
        Info("Stop server...")
        self.socketServer.shutdown()
        self.serverThread.join(timeout = 60)
        Info("Server has been stopped")
