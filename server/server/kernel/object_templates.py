from helpers import *

class TransmittableObject(object):
	def __init__(self):
		self.fields = {}

	def TrasmittableField(self, field):
		self.fields[field] = __getattr__(self, field)

	def GetFields(self, field):
		return self.fields
