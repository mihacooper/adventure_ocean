from helpers import *
import copy

class ObjFactory(object):
    class __ObjFactory:
        def __init__(self):
            self.objects = {}
            self.lock = threading.Lock()

        @SafeCall
        def Add(self, ind, obj):
            with self.lock:
                if self.objects.get(ind) is None:
                    Debug("Add new object %s, id=%s" % (repr(obj), ind))
                    self.objects[ind] = obj
                    return True
                else:
                    Error("Unable to add object %s with id=%s (already exists %s)"
                          % (repr(obj), ind, repr(self.objects.get(ind)))
                    )
                return False

        @SafeCall
        def Update(self, ind, obj):
            with self.lock:
                if self.objects.get(ind) is None:
                    Warning("Updated object does not exist, id=%s" % ind)
                Debug("Update object %s, id=%s" %(repr(obj), ind))
                self.objects[ind] = obj

        @SafeCall
        def Remove(self, ind):
            with self.lock:
                obj = self.objects.get(ind)
                if obj is not None:
                    Debug("Delete object %s, id=%s" %(repr(obj), ind))
                    self.objects[ind] = None
                    return True
                else:
                    Error("Unable to delete object, id=%s. Object is not found" % ind)
                return False

        @SafeCall
        def Get(self, ind):
            with self.lock:
                obj = copy.deepcopy(self.objects.get(ind))
                if obj is None:
                    Error("Unable to find object with ID=%s" % ind)
                return obj

    instance = None

    def __new__(cls):
        if not ObjFactory.instance:
            ObjFactory.instance = ObjFactory.__ObjFactory()
        return ObjFactory.instance

    def __getattr__(self, attr):
        return __getattr__(ObjFactory.instance, attr)

    def __setattr__(self, attr):
        return __setattr__(ObjFactory.instance, attr)
