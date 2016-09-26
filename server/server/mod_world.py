from kernel.helpers import *
from kernel.grid import Grid
from kernel.dispatcher import Dispatcher, EVENT_NEW_CHUNK, EVENT_SEND

class World(object):
    def NewChunkHandler(self, _, chunk):
        for col in Grid().GetChunk(chunk):
            for cell in col:
                cell.append(1)

    @SafeCall
    def DataRequestHandler(self, _, id, data):
        x, y = data['location']['x'], data['location']['y']
        Dispatcher().Send(
            (EVENT_SEND, id),
            {
                "event" : "ChunkUpdate",
                "data":
                    {
                        "location": {'x': x, 'y': y},
                        "data" : Grid().GetChunk((x, y))
                    }
            }
        )

    @SafeCall
    def SettingsRequestHandler(self, _, id, args):
        Dispatcher().Send(
            (EVENT_SEND, id),
            {"event" : "WorldSettings", "data": Grid().GetSettings()}
        )

@SafeCall
def Initialize():
    world = World()
    Dispatcher().Subscribe(EVENT_NEW_CHUNK, world.NewChunkHandler)
    Dispatcher().Subscribe("ChunkRequest", world.DataRequestHandler)
    Dispatcher().Subscribe("WorldSettings", world.SettingsRequestHandler)
    return world
