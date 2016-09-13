from helpers import *

class TransmittableObject(object):
    def __init__(self):
        self.fields = []

    def TrasmittableField(self, field):
        self.fields.append(field)

    def GetFields(self, field):
        ret = {}
        for f in self.fields:
            ret[f] = self.__dict__[f]
        return ret
