screen_width = pesto.window.getWidth()
screen_height = pesto.window.getHeight()
tile_size = 60
window_width = screen_width / tile_size
window_height = screen_height / tile_size
border_space = 1
cells_number = (window_width - 2 * border_space) * (window_height - 2 * border_space)

tile_x = 1
tile_y = 1

visited_cells = {}
last_cells = {}

--directions: 1 up, 2 right, 3 down, 4 left

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

function pesto.update(dt)

    current_cell = {tile_x, tile_y}
    table.insert(visited_cells, current_cell)
    directions = {1, 2, 3, 4}

    if not tableContains(last_cells, current_cell) then
        table.insert(last_cells, current_cell)
    end

    if current_cell[1] == 1 then --when the cell is adjacent to the left border remove left direction
        table.remove(directions, 4)
    elseif current_cell[1] == window_width - 2 * border_space then --when the cell is adjacent to the right border remove right direction
        table.remove(directions, 2)
    end

    if current_cell[2] == 1 then --when the cell is adjacent to the top border remove up direction
        table.remove(directions, 1)
    elseif current_cell[2] == window_height - 2 * border_space then --when the cell is adjacent to the bottom border remove down direction
        if #directions == 4 or current_cell[1] == 1 then --if a direction as already been removed the index at which remove the element may need to be adjusted
            table.remove(directions, 3)
        else
            table.remove(directions, 2) 
        end
    end
    

end

function pesto.draw()
    
    --draw main grid
    for i = border_space, window_width - 1 - border_space, 1 do
        for j = border_space, window_height - 1 - border_space, 1 do

            line_rectangle(i * tile_size, j * tile_size, tile_size, tile_size)
            --drawn ractagles center
            pesto.graphics.rectangle(i * tile_size + (tile_size / 2) - 1, j * tile_size + (tile_size / 2) - 1, 2, 2)
            --draw rectangles coordinates on them
            pesto.graphics.text((i - border_space + 1 .. ", ".. j - border_space + 1), (i * tile_size + (tile_size / 2) - 1), (j * tile_size + (tile_size / 2) - 5))

        end
    end

    pesto.graphics.text((table.concat(directions, " ")), 10, 10)
    

end
