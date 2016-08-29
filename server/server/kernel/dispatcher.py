import Queue

from helpers import *

EVENT_INIT = 0
EVENT_NEW_CHUNK = 1
EVENT_SEND = 2

class Dispatcher(object):
    class __Dispatcher:
        def __init__(self):
            self.subscribes = {}
            self.queue = Queue.Queue()
            self.lock = threading.Lock()
            self.sender_thread = threading.Thread(target = self.__Sender, name = "DispatcherThread")
            self.sender_stop = False

        def Initialize(self):
            self.sender_thread.start()

        def Uninitialize(self):
            self.sender_stop = True
            self.sender_thread.join(5)

        def __Sender(self):
            while not self.sender_stop:
                if not self.queue.empty():
                    event = self.queue.get()
                    self.__SendImpl(event[0], event[1], event[2])

        @SafeCall
        def Send(self, event, *args, **kwargs):
            Info("Add event to queue %s(%s, %s)" % (str(event), str(*args), str(**kwargs)))
            self.queue.put_nowait((event, args, kwargs))

        @SafeCall
        def __SendImpl(self, event, args, kwargs):
            Info("Send event %s(%s, %s)" % (str(event), str(args), str(kwargs)))
            with self.lock:
                recvs = self.subscribes.get(event)
                if recvs is not None:
                    for recv in recvs:
                        Info("Pass event %s to handler %s" % (str(event), str(recv)))
                        recv(event, *args, **kwargs)
                else:
                    Info("No one handler was found for event %s" % str(event))

        @SafeCall
        def Subscribe(self, event, handler):
            Info("Subscribe %s on event %s" % (str(handler), str(event)))
            with self.lock:
                self.subscribes[event] = (self.subscribes.get(event) or []) + [handler]

    instance = None

    def __new__(cls):
        if not Dispatcher.instance:
            Dispatcher.instance = Dispatcher.__Dispatcher()
        return Dispatcher.instance

    def __getattr__(self, attr):
        return __getattr__(Dispatcher.instance, attr)

    def __setattr__(self, attr):
        return __setattr__(Dispatcher.instance, attr)