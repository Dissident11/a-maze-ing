--screen variables
local screenWidth = pesto.window.getWidth()
local screenHeight = pesto.window.getHeight()
local tileSize = 20
--dimensions of window in tiles
local windowWidth = screenWidth / tileSize
local windowHeight = screenHeight / tileSize
local borderSpace = 1 --how many tiles are removed from the border
local cellsNumber = (windowWidth - 2 * borderSpace) * (windowHeight - 2 * borderSpace) --how many tiles/cells are created

--starting settings
--coordinates from which the maze began to be drawn
local tileX = math.random(windowWidth - 2 * borderSpace)
local tileY = math.random(windowHeight - 2 * borderSpace)
local visitedCells = {}
local lastCells = {}
local lines = {}
local toDrawLines = {}
local borders = {}
local borderThickness = 2
local bordersMade = false
local showLines = true

local pause = false

math.randomseed(os.time())

--draw unfilled rectangles with thickness of 1
local function lineRectangle(x, y, width, height)
    pesto.graphics.rectangle(x, y, width, 1)
    pesto.graphics.rectangle(x + width - 1, y, 1, height)
    pesto.graphics.rectangle(x, y, 1, height)
    pesto.graphics.rectangle(x, y + height - 1, width, 1)
end

--check if 2 tables are equal
local function tableEquals(table1, table2)
    if #table1 ~= #table2 then
        return false
    end

    for key, value in pairs(table1) do
        if value ~= table2[key] then
            return false
        end
    end

    return true
end

--check if a table contains another one
local function tableContains(table, targetTable)
    for _, value in pairs(table) do
        if type(value) == "table" and tableEquals(value, targetTable) then
            return true
        end
    end
    return false
end

--return index of element in a table
local function indexOf(array, value)
    for i, v in ipairs(array) do
        if v == value then
            return i
        end
    end
    return nil
end

function pesto.update(dt)

    if not pause then

        if #visitedCells < cellsNumber then --the maze is created till all the tiles have been used

            local currentCell = {tileX, tileY}

            if not tableContains(visitedCells, currentCell) then
                table.insert(visitedCells, currentCell)
            end
            if not tableContains(lastCells, currentCell) then
                table.insert(lastCells, currentCell)
            end

            local directions = {} --directions: 1 up, 2 right, 3 down, 4 left

            --add directions based on the coordinates and near cells
            if currentCell[1] ~= 1 and --add left direction if the cell doesn't touch the left border
                    not tableContains(visitedCells, {tileX - 1, tileY}) then --and there is no cell on the left
                table.insert(directions, 4)
            end
            if currentCell[1] ~= windowWidth - 2 * borderSpace and --add right direction if the cell doesn't touch the right border
                    not tableContains(visitedCells, {tileX + 1, tileY}) then --and there is no cell on the right
                table.insert(directions, 2)
            end
            if currentCell[2] ~= 1 and --add up direction if the cell doesn't touch the top border
                    not tableContains(visitedCells, {tileX, tileY - 1}) then --and there is no cell upper
                table.insert(directions, 1)
            end
            if currentCell[2] ~= windowHeight - 2 * borderSpace and --add down direction if the cell doesn't touch the bottom border
                    not tableContains(visitedCells, {tileX, tileY + 1}) then --and there is no cell lower
                table.insert(directions, 3)
            end

            if #directions > 0 then --if there is at least one direction, randomly take one of them

                local choosenDir = math.random(#directions)
                local newDir = directions[choosenDir]

                local newTileX, newTileY
                local newLine, newTile
                local x1, y1, x2, y2

                if newDir == 1 then
                    newTileY = tileY - 1
                    newTileX = tileX
                elseif newDir == 2 then
                    newTileX = tileX + 1
                    newTileY = tileY
                elseif newDir == 3 then
                    newTileY = tileY + 1
                    newTileX = tileX
                elseif newDir == 4 then
                    newTileX = tileX - 1
                    newTileY = tileY
                end

                newLine = {tileX, tileY, newTileX, newTileY}
                table.insert(lines, newLine) --the lines used to make calculations

                x1 = (tileX - 1) * tileSize + tileSize * borderSpace + tileSize / 2
                y1 = (tileY - 1) * tileSize + tileSize * borderSpace + tileSize / 2
                x2 = (newTileX - 1) * tileSize + tileSize * borderSpace + tileSize / 2
                y2 = (newTileY - 1) * tileSize + tileSize * borderSpace + tileSize / 2
                table.insert(toDrawLines, {x1, y1, x2, y2}) --the lines that are drawn

                newTile = {newTileX, newTileY}
                table.insert(visitedCells, newTile)
                table.insert(lastCells, newTile)
                tileX = newTileX
                tileY = newTileY

            else 
                if #visitedCells < cellsNumber then --if there are no directions available go back to the previous cell in lastCells
                    tileX = lastCells[#lastCells - 1][1]
                    tileY = lastCells[#lastCells - 1][2]
                    table.remove(lastCells, #lastCells)
                end
            end

        --the program stops only when all the cells have been filled
        --draw borders between unconnected cells to make the maze 
        elseif bordersMade == false then

            for x = 1, windowWidth - 2 * borderSpace, 1 do
                for y = 0, windowHeight - 2 * borderSpace, 1 do

                    pesto.graphics.setColor(0, 0, 0)

                    local borderX, borderY
                    local borderWidth, borderHeight
                    local newBorder
                    
                    --check if there are lines between the centers of rectangles
                    --if there aren't, in both ways, create a border
                    if (not tableContains(lines, {x, y, x + 1, y})) and (not tableContains(lines, {x + 1, y, x, y})) then --right - left
                        borderX = tileSize * borderSpace + x * tileSize - 1
                        borderY = tileSize * borderSpace + (y - 1) * tileSize
                        borderWidth = borderThickness
                        borderHeight = tileSize

                        newBorder = {borderX, borderY, borderWidth, borderHeight}

                        if not tableContains(borders, newBorder) then
                            table.insert(borders, newBorder)
                        end
                    end

                    if (not tableContains(lines, {x, y, x - 1, y})) and (not tableContains(lines, {x - 1, y, x, y})) then --left - right
                        borderX = tileSize * borderSpace + (x - 1) * tileSize - 1
                        borderY = tileSize * borderSpace + (y - 1) * tileSize
                        borderWidth = borderThickness
                        borderHeight = tileSize

                        newBorder = {borderX, borderY, borderWidth, borderHeight}

                        if not tableContains(borders, newBorder) then
                            table.insert(borders, newBorder)
                        end
                    end

                    if (not tableContains(lines, {x, y, x, y + 1})) and (not tableContains(lines, {x, y + 1, x, y})) then --bottom - up
                        borderX = tileSize * borderSpace + (x - 1) * tileSize
                        borderY = tileSize * borderSpace + y * tileSize - 1
                        borderWidth = tileSize
                        borderHeight = borderThickness

                        newBorder = {borderX, borderY, borderWidth, borderHeight}

                        if not tableContains(borders, newBorder) then
                            table.insert(borders, newBorder)
                        end

                        if (not tableContains(lines, {x, y, x, y - 1})) and (not tableContains(lines, {x, y - 1, x, y})) then --up - bottom
                            borderX = tileSize * borderSpace + (x - 1) * tileSize
                            borderY = tileSize * borderSpace + (y - 1) * tileSize - 1
                            borderWidth = tileSize
                            borderHeight = borderThickness
        
                            newBorder = {borderX, borderY, borderWidth, borderHeight}
        
                            if not tableContains(borders, newBorder) then
                                table.insert(borders, newBorder)
                            end
                        end

                        bordersMade = true
                        showLines = false --once the borders are made, the lines aren't drawn anymore
                    end
                end
            end
        end
    end

    --resetting the maze
    if pesto.mouse.isPressed(0) then
        tileX = math.random(windowWidth - 2 * borderSpace)
        tileY = math.random(windowHeight - 2 * borderSpace)

        visitedCells = {}
        lastCells = {}
        lines = {}
        toDrawLines = {}
        borders = {}

        borderThickness = 2
        bordersMade = false
        showLines = true
    end

    --pausing the maze
    if pesto.mouse.isPressed(1) then
        pause = not pause
    end

end

--grid canvas
local grid = pesto.graphics.loadCanvas(screenWidth, screenHeight)

grid:beginDrawing()

pesto.graphics.setColor(255, 255, 255)

for i = borderSpace, windowWidth - 1 - borderSpace, 1 do
    for j = borderSpace, windowHeight - 1 - borderSpace, 1 do

        lineRectangle(i * tileSize, j * tileSize, tileSize, tileSize)

    end
end

grid:endDrawing()

function pesto.draw()

    pesto.graphics.setColor(255, 255, 255)
    grid:draw(0, 0)

    --color visited cells
    for i = 1, #visitedCells, 1 do
        pesto.graphics.setColor(255, 255, 255)
        pesto.graphics.rectangle(tileSize * borderSpace + (visitedCells[i][1] - 1) * tileSize,
                tileSize * borderSpace + (visitedCells[i][2] - 1) * tileSize, tileSize, tileSize)
    end

    --draw current rectangle till the maze is complete
    if showLines then
        pesto.graphics.setColor(255, 0, 0)
        pesto.graphics.rectangle((tileX - 1) * tileSize + tileSize * borderSpace,
                (tileY - 1) * tileSize + tileSize * borderSpace, tileSize, tileSize)
    end

    --lines that connect the center of connected cells, kinda like the roads you can take
    if showLines then
        if #lines > 0 then
            for _, v in pairs(toDrawLines) do
                pesto.graphics.setColor(0, 0, 0)
                pesto.graphics.line(v[1], v[2], v[3], v[4])
            end
        end
    end

    --draw borders
    if #visitedCells == cellsNumber and bordersMade then
        for _, v in pairs(borders) do
            pesto.graphics.setColor(0, 0, 0)
            pesto.graphics.rectangle(v[1], v[2], v[3], v[4])
        end
    end
end
