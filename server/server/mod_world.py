from kernel.helpers import *
from kernel.grid import Grid
from kernel.dispatcher import Dispatcher, EVENT_NEW_CHUNK, EVENT_WORLD_REQUEST, EVENT_SEND

class World(object):
    def NewChunkHandler(self, _, chunk):
        for col in Grid().GetChunk(chunk):
            for cell in col:
                cell.append(1)

    def DataRequestHandler(self, _, id, data):
        location = (data['location']['x'], data['location']['y'])
        Dispatcher().Send(
            (EVENT_SEND, id),
            {"event" : "WorldUpdate", "data": Grid().GetChunk(location)}
        )

@SafeCall
def Initialize():
    world = World()
    Dispatcher().Subscribe(EVENT_NEW_CHUNK, world.NewChunkHandler)
    Dispatcher().Subscribe(EVENT_WORLD_REQUEST, world.DataRequestHandler)
    return world
