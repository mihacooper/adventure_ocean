import time, datetime, threading, sys, traceback

print_lock = threading.Lock()

def LogMessage(msg):
    with print_lock:
        ts = time.time()
        dt = datetime.datetime.fromtimestamp(ts).strftime('%Y-%m-%d %H:%M:%S')
        thrName = threading.current_thread().name
        sys.stdout.write("%s <%s> %s\n" % (dt, thrName, msg))

def Error(msg):
    LogMessage("[ERR] " + str(msg))

def Warning(msg):
    LogMessage("[WRN] " + str(msg))

def Info(msg):
    LogMessage("[INF] " + str(msg))

def Debug(msg):
    LogMessage("[DBG] " + str(msg))


class SafeException(Exception): # Use only with SafeCall!!!
    def __init__(self, m):
        self.message = m
    def __str__(self):
        return self.message
    def SilentMsg(self):
        return self.message

def Throw(msg):
    raise SafeException(msg)

def GetCurrentStackTrace():
    return '\n'.join([ line for line in traceback.format_stack()])

# Decorator
def SilentSafeCall(func):
    def Caller(self, *args, **kwargs):
        try:
            return func(self, *args, **kwargs)
        except SafeException as e:
            Error(e.SilentMsg())
        except Exception as e:
            Error("Exception during %s execution:\n\tWhat: %s\nStack trace:\n%s"
                  % (func.__name__, str(e), GetCurrentStackTrace()))
    return Caller

# Decorator
def SafeCall(func):
    def Caller(*args, **kwargs):
        try:
            Debug("Call %s(%s, %s)" % (func.__name__, args, kwargs))
            return func(*args, **kwargs)
        except Exception as e:
            Error("Exception during %s execution:\n\tWhat: %s\nStack trace:\n%s"
                  % (func.__name__, str(e), GetCurrentStackTrace()))
    return Caller

def MakeTransmittable(obj, field, value = None):
    if obj.get("transmittable") is None or not isinstance(obj["transmittable"], list):
        obj["transmittable"] = []
    obj["transmittable"].append(str(field))
    if value is not None:
        obj[field] = value