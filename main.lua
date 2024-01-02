screen_width = pesto.window.getWidth()
screen_height = pesto.window.getHeight()
tile_size = 60
window_width = screen_width / tile_size
window_height = screen_height / tile_size
border_space = 1
cells_number = (window_width - 2 * border_space) * (window_height - 2 * border_space)

tile_x = 3
tile_y = 3

visited_cells = {}
last_cells = {}
lines = {}

math.randomseed(os.time())
show_lines = true

--draw unfilled rectangles with thickness of 1
function line_rectangle(x, y, width, height)
    pesto.graphics.rectangle(x, y, width, 1)
    pesto.graphics.rectangle(x + width - 1, y, 1, height)
    pesto.graphics.rectangle(x, y, 1, height)
    pesto.graphics.rectangle(x, y + height - 1, width, 1)
end

--check if 2 tables are equal
function tableEquals(table1, table2)
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
function tableContains(table, targetTable)
    for _, value in pairs(table) do
        if type(value) == "table" and tableEquals(value, targetTable) then
            return true
        end
    end
    return false
end

--return index of element in a table
function indexOf(array, value)
    for i, v in ipairs(array) do
        if v == value then
            return i
        end
    end
    return nil
end

function pesto.update(dt)

    current_cell = {tile_x, tile_y}

    if not tableContains(visited_cells, current_cell) then
        table.insert(visited_cells, current_cell)
    end

    if not tableContains(last_cells, current_cell) then
        table.insert(last_cells, current_cell)
    end

    directions = {} --directions: 1 up, 2 right, 3 down, 4 left

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

    if pesto.mouse.isPressed(1) or false then

        if #directions > 0 then

            choosen_dir = math.random(#directions)
            new_dir = directions[choosen_dir]

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

            new_tile = {new_tile_x, new_tile_y}
            table.insert(visited_cells, new_tile)
            table.insert(last_cells, new_tile)
            tile_x = new_tile_x
            tile_y = new_tile_y

        else
            
            if #visited_cells < cells_number then
                tile_x = last_cells[#last_cells - 1][1]
                tile_y = last_cells[#last_cells - 1][2]
                table.remove(last_cells, #last_cells)
            else
                
            end
            

        end
    end
end

function pesto.draw()

    --color visited cells
    for i = 1, #visited_cells, 1 do
        pesto.graphics.setColor(255, 255, 255)
        pesto.graphics.rectangle(tile_size * border_space + (visited_cells[i][1] - 1) * tile_size, tile_size * border_space + (visited_cells[i][2] - 1) * tile_size, tile_size, tile_size)
    end
    
    --draw main grid
    for i = border_space, window_width - 1 - border_space, 1 do
        for j = border_space, window_height - 1 - border_space, 1 do

            pesto.graphics.setColor(255, 255, 255)
            --draw grid
            line_rectangle(i * tile_size, j * tile_size, tile_size, tile_size)
            --drawn ractagles' centers
            pesto.graphics.rectangle(i * tile_size + (tile_size / 2) - 1, j * tile_size + (tile_size / 2) - 1, 2, 2)
            --draw rectangles' coordinates on them
            pesto.graphics.setColor(0, 0, 0)
            --pesto.graphics.text((i - border_space + 1 .. ", ".. j - border_space + 1), (i * tile_size + (tile_size / 2) - 1), (j * tile_size + (tile_size / 2) - 5))

        end
    end

    --draw current rectangle
    pesto.graphics.setColor(255, 0, 0)
    pesto.graphics.rectangle((tile_x - 1) * tile_size + tile_size * border_space, (tile_y - 1) * tile_size + tile_size * border_space, tile_size, tile_size)

    if show_lines then
        if #lines > 0 then
            for _, v in pairs(lines) do
                pesto.graphics.setColor(0, 0, 0)
                pesto.graphics.line((v[1] - 1) * tile_size + tile_size * border_space + tile_size / 2,
                        (v[2] - 1) * tile_size + tile_size * border_space + tile_size / 2,
                        (v[3] - 1) * tile_size + tile_size * border_space + tile_size / 2,
                        (v[4] - 1) * tile_size + tile_size * border_space + tile_size / 2)
            end
        end
    end
end
