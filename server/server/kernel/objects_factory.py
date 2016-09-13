from helpers import *

class ObjFactory(object):
    class __ObjFactory:
        def __init__(self):
            self.objects = {}
            self.lock = threading.Lock()

        @SafeCall
        def Add(self, ind, obj):
			with self.lock:
				if self.objects.get(ind) is None:
					self.objects[ind] = obj
					return True
				return False

        @SafeCall
        def Get(self, ind):
        	with self.lock:
        		return self.objects.get(ind)

    instance = None

    def __new__(cls):
        if not ObjFactory.instance:
            ObjFactory.instance = ObjFactory.__ObjFactory()
        return ObjFactory.instance

    def __getattr__(self, attr):
        return __getattr__(ObjFactory.instance, attr)

    def __setattr__(self, attr):
        return __setattr__(ObjFactory.instance, attr)
