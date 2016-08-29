import time, datetime, threading

def LogMessage(msg):
    ts = time.time()
    dt = datetime.datetime.fromtimestamp(ts).strftime('%Y-%m-%d %H:%M:%S')
    thread = threading.current_thread().name
    print "%s <%s> %s" % (dt, thread, msg)

def Error(msg):
    LogMessage("[ERR] " + str(msg))

def Warning(msg):
    LogMessage("[WRN] " + str(msg))

def Info(msg):
    LogMessage("[INF] " + str(msg))

def Debug(msg):
    LogMessage("[DBG] " + str(msg))

# Decorator
def SafeCall(func):
    def Caller(self, *args, **kwargs):
        Debug("Call %s(%s, %s)" % (func.__name__, args, kwargs))
        try:
            return func(self, *args, **kwargs)
        except Exception as e:
            Error("Exception during %s execution:\n\t%s" % (func.__name__, str(e)))
            raise
    return Caller
