from dispatcher import Dispatcher, EVENT_NEW_CHUNK, EVENT_INIT

CHUNK_WIDTH = 50
CHUNK_HEIGHT = 50

class Grid(object):
    class __Grid:
        def __init__(self):
            self.grid = {}

        def Initialize(self, _):
            self.CreateChunk((0, 0))

        def CreateChunk(self, pos):
            self.grid[pos] = [
                        [ [] for x in range(CHUNK_HEIGHT)]
                for x in range(CHUNK_WIDTH)
            ]
            Dispatcher().Send(EVENT_NEW_CHUNK, pos)

        def GetChunkCoord(self, point):
            x, y = 0, 0
            if point[0] >= 0:
                x = point[0] / CHUNK_WIDTH
            else:
                x = ((point[0] + 1) / CHUNK_WIDTH) - 1

            if point[1] >= 0:
                y = point[1] / CHUNK_HEIGHT
            else:
                y = ((point[1] + 1) / CHUNK_HEIGHT) - 1
            return (x, y)

        def GetLocalCoord(self, point):
            x, y = 0, 0
            if point[0] >= 0:
                x = point[0] % CHUNK_WIDTH
            else:
                x = (point[0] + 1) % CHUNK_WIDTH

            if point[1] >= 0:
                y = point[1] % CHUNK_HEIGHT
            else:
                y = (point[1] + 1) % CHUNK_HEIGHT
            return (x, y)

        def GetCell(self, pos):
            chunk = self.GetChunkCoord(pos)
            local = self.GetLocalCoord(pos)
            if self.grid.get(chunk) is None:
                self.CreateChunk(chunk)
                Dispatcher().Send(EVENT_NEW_CHUNK, chunk)
            return self.grid[chunk][local[0]][local[1]]

        def GetChunk(self, pos):
            if self.grid[pos] is None:
                self.CreateChunk(pos)
            return self.grid[pos]

    instance = None

    def __new__(cls):
        if not Grid.instance:
            Grid.instance = Grid.__Grid()
            Dispatcher().Subscribe(EVENT_INIT, Grid.instance.Initialize)
        return Grid.instance

    def __getattr__(self, attr):
        return __getattr__(Grid.instance, attr)

    def __setattr__(self, attr):
        return __setattr__(Grid.instance, attr)

Grid()