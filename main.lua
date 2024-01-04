local screen_width = pesto.window.getWidth()
local screen_height = pesto.window.getHeight()
local tile_size = 20
local window_width = screen_width / tile_size
local window_height = screen_height / tile_size
local border_space = 1
local cells_number = (window_width - 2 * border_space) * (window_height - 2 * border_space)

local tile_x = 3
local tile_y = 3

local visited_cells = {}
local last_cells = {}
local lines = {}
local draw_lines = {}
local borders = {}

local border_thickness = 2
local borders_made = false

math.randomseed(os.time())
local show_lines = true

--draw unfilled rectangles with thickness of 1
local function line_rectangle(x, y, width, height)
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

    if #visited_cells < cells_number then

        local current_cell = {tile_x, tile_y}

        if not tableContains(visited_cells, current_cell) then
            table.insert(visited_cells, current_cell)
        end
        if not tableContains(last_cells, current_cell) then
            table.insert(last_cells, current_cell)
        end

        local directions = {} --directions: 1 up, 2 right, 3 down, 4 left

        --add directions based on the coordinates and near cells
        if current_cell[1] ~= 1 and --add left direction if the cell doesn't touch the left border
                not tableContains(visited_cells, {tile_x - 1, tile_y}) then --and there is no cell on the left
            table.insert(directions, 4)
        end
        if current_cell[1] ~= window_width - 2 * border_space and --add right direction if the cell doesn't touch the right border
                not tableContains(visited_cells, {tile_x + 1, tile_y}) then --and there is no cell on the right
            table.insert(directions, 2)
        end
        if current_cell[2] ~= 1 and --add up direction if the cell doesn't touch the top border
                not tableContains(visited_cells, {tile_x, tile_y - 1}) then --and there is no cell upper
            table.insert(directions, 1)
        end
        if current_cell[2] ~= window_height - 2 * border_space and --add down direction if the cell doesn't touch the bottom border
                not tableContains(visited_cells, {tile_x, tile_y + 1}) then --and there is no cell lower
            table.insert(directions, 3)
        end

        if #directions > 0 then

            local choosen_dir = math.random(#directions)
            local new_dir = directions[choosen_dir]

            local new_tile_x, new_tile_y
            local new_line, new_tile
            local x1, y1, x2, y2

            if new_dir == 1 then
                new_tile_y = tile_y - 1
                new_tile_x = tile_x
            elseif new_dir == 2 then
                new_tile_x = tile_x + 1
                new_tile_y = tile_y
            elseif new_dir == 3 then
                new_tile_y = tile_y + 1
                new_tile_x = tile_x
            elseif new_dir == 4 then
                new_tile_x = tile_x - 1
                new_tile_y = tile_y
            end

            new_line = {tile_x, tile_y, new_tile_x, new_tile_y}
            table.insert(lines, new_line)

            x1 = (tile_x - 1) * tile_size + tile_size * border_space + tile_size / 2
            y1 = (tile_y - 1) * tile_size + tile_size * border_space + tile_size / 2
            x2 = (new_tile_x - 1) * tile_size + tile_size * border_space + tile_size / 2
            y2 = (new_tile_y - 1) * tile_size + tile_size * border_space + tile_size / 2
            table.insert(draw_lines, {x1, y1, x2, y2})

            new_tile = {new_tile_x, new_tile_y}
            table.insert(visited_cells, new_tile)
            table.insert(last_cells, new_tile)
            tile_x = new_tile_x
            tile_y = new_tile_y

        else 
            if #visited_cells < cells_number then --if there are no directions available go back to the previous cell
                tile_x = last_cells[#last_cells - 1][1]
                tile_y = last_cells[#last_cells - 1][2]
                table.remove(last_cells, #last_cells)
            end
        end

    --the program stops only when all the cells have been filled
    --draw borders between unconnected cells to make the maze 
    elseif borders_made == false then

        for x = 1, window_width - 2 * border_space, 1 do
            for y = 1, window_height - 2 * border_space, 1 do

                pesto.graphics.setColor(0, 0, 0)

                local border_x, border_y
                local border_width, border_height
                local new_border
                
                --check if there are lines between the centers of rectangles
                --if there aren't, in both ways, create a border
                if (not tableContains(lines, {x, y, x + 1, y})) and (not tableContains(lines, {x + 1, y, x, y})) then --right - left
                    border_x = tile_size * border_space + x * tile_size - 1
                    border_y = tile_size * border_space + (y - 1) * tile_size
                    border_width = border_thickness
                    border_height = tile_size

                    new_border = {border_x, border_y, border_width, border_height}

                    if not tableContains(borders, new_border) then
                        table.insert(borders, new_border)
                    end
                end

                if (not tableContains(lines, {x, y, x - 1, y})) and (not tableContains(lines, {x - 1, y, x, y})) then --left - right
                    border_x = tile_size * border_space + (x - 1) * tile_size - 1
                    border_y = tile_size * border_space + (y - 1) * tile_size
                    border_width = border_thickness
                    border_height = tile_size

                    new_border = {border_x, border_y, border_width, border_height}

                    if not tableContains(borders, new_border) then
                        table.insert(borders, new_border)
                    end
                end

                if (not tableContains(lines, {x, y, x, y + 1})) and (not tableContains(lines, {x, y + 1, x, y})) then --bottom - up
                    border_x = tile_size * border_space + (x - 1) * tile_size
                    border_y = tile_size * border_space + y * tile_size - 1
                    border_width = tile_size
                    border_height = border_thickness

                    new_border = {border_x, border_y, border_width, border_height}

                    if not tableContains(borders, new_border) then
                        table.insert(borders, new_border)
                    end

                    if (not tableContains(lines, {x, y, x, y - 1})) and (not tableContains(lines, {x, y - 1, x, y})) then --up - bottom
                        border_x = tile_size * border_space + (x - 1) * tile_size
                        border_y = tile_size * border_space + (y - 1) * tile_size - 1
                        border_width = tile_size
                        border_height = border_thickness
    
                        new_border = {border_x, border_y, border_width, border_height}
    
                        if not tableContains(borders, new_border) then
                            table.insert(borders, new_border)
                        end
                    end

                    borders_made = true
                    show_lines = false
                end
            end
        end
    end
end

function pesto.draw()

    --color visited cells
    for i = 1, #visited_cells, 1 do
        pesto.graphics.setColor(255, 255, 255)
        pesto.graphics.rectangle(tile_size * border_space + (visited_cells[i][1] - 1) * tile_size,
                tile_size * border_space + (visited_cells[i][2] - 1) * tile_size, tile_size, tile_size)
    end

    --draw current rectangle till the maze is complete
    if show_lines then
        pesto.graphics.setColor(255, 0, 0)
        pesto.graphics.rectangle((tile_x - 1) * tile_size + tile_size * border_space,
                (tile_y - 1) * tile_size + tile_size * border_space, tile_size, tile_size)
    end

    --lines that connect the center of connected cells, kinda like the roads you can take
    if show_lines then
        if #lines > 0 then
            for _, v in pairs(draw_lines) do
                pesto.graphics.setColor(0, 0, 0)
                pesto.graphics.line(v[1], v[2], v[3], v[4])
            end
        end
    end

    --draw borders
    if #visited_cells == cells_number and borders_made then
        for _, v in pairs(borders) do
            pesto.graphics.setColor(0, 0, 0)
            pesto.graphics.rectangle(v[1], v[2], v[3], v[4])
        end
    end
end
