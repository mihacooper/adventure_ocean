from kernel.grid import Grid
from kernel.dispatcher import Dispatcher, EVENT_NEW_CHUNK

class World(object):
    def NewChunkHandler(self, _, chunk):
        for col in Grid().GetChunk(chunk):
            for cell in col:
                cell.append(1)

def Initialize():
    world = World()
    Dispatcher().Subscribe(EVENT_NEW_CHUNK, world.NewChunkHandler)
