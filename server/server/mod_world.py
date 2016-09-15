from kernel.helpers import *
from kernel.grid import Grid
from kernel.dispatcher import Dispatcher, EVENT_NEW_CHUNK, EVENT_DATA_REQUEST, EVENT_SEND

class World(object):
    def NewChunkHandler(self, _, chunk):
        for col in Grid().GetChunk(chunk):
            for cell in col:
                cell.append(1)

    def DataRequestHandler(self, _, data):
        Dispatcher().Send(
            (EVENT_SEND, data['id']),
            {"model" : "World", "Data": Grid().GetChunk((0, 0))}
        )

@SafeCall
def Initialize():
    world = World()
    Dispatcher().Subscribe(EVENT_NEW_CHUNK, world.NewChunkHandler)
    Dispatcher().Subscribe(EVENT_DATA_REQUEST, world.DataRequestHandler)
    return world
