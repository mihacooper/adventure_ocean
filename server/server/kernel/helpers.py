import time, datetime, threading

print_lock = threading.Lock()

def LogMessage(msg):
    with print_lock:
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
def SilentSafeCall(func):
    def Caller(self, *args, **kwargs):
        try:
            return func(self, *args, **kwargs)
        except Exception as e:
            Error("Exception during %s execution:\n\t%s" % (func.__name__, str(e)))
            #raise
    return Caller

# Decorator
def SafeCall(func):
    def Caller(self, *args, **kwargs):
        try:
            Debug("Call %s(%s, %s)" % (func.__name__, args, kwargs))
            return func(self, *args, **kwargs)
        except Exception as e:
            Error("Exception during %s execution:\n\t%s" % (func.__name__, str(e)))
            #raise
    return Caller
