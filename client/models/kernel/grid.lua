return function ()
    local grid = {}

    function grid:GetCellCoord(x, y)
        function GlobalToCell(crd, width)
            if crd >= 0 then
                return math.floor(crd / width)
            else
                return math.ceil((crd + 1) / width) - 1
            end
        end
        local cell = { x = 0, y = 0 }
        cell.x  = GlobalToCell( x, self.CellWidth)
        cell.y  = GlobalToCell( y, self.CellHeight)
        return cell.x, cell.y
    end

    function grid:GetChunkCoord(x, y) -- from Cell coords
        function CellToChunk(crd, width)
            if crd >= 0 then
                return math.floor(crd / width), crd % width + 1
            else
                return math.ceil((crd + 1) / width) - 1, math.abs(crd) % width + 1
            end
        end

        local chunk = { x = 0, y = 0}
        local lcell = { x = 0, y = 0} -- local for chunk
        chunk.x, lcell.x = CellToChunk(x, self.ChunkWidth)
        chunk.y, lcell.y = CellToChunk(y, self.ChunkHeight)
        return chunk.x, chunk.y, lcell.x, lcell.y
    end

    function grid:GetCell(x, y)
        local chunk_x, chunk_y, cell_x, cell_y = self:GetChunkCoord(x, y)
        if not self[chunk_x] or not self[chunk_x][chunk_y] or not
                    self[chunk_x][chunk_y][cell_x] or not self[chunk_x][chunk_y][cell_x][cell_y] then
            return nil
        end
        return self[chunk_x][chunk_y][cell_x][cell_y]
    end

    function grid:GetCellFromGlobal(x, y)
        local cell_x, cell_y = self:GetCellCoord(x, y)
        return self:GetCell(cell_x, cell_y)
    end

    return grid
end
