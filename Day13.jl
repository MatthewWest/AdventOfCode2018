module Day13
export solvePart1, solvePart2

function getRawInput()
    open("day13input.txt") do f
        return read(f, String)
    end
end

function parseInput(s)
    lines = split(s, '\n')
    height = length(lines)
    width = max(map(length, lines)...)
    grid = Array{Any}(undef, height, width)
    for (row, line) in enumerate(lines)
        for (col, c) in enumerate(line)
            if c == '^'
                grid[row, col] = ('N', 'l', '|')
            elseif c == 'v'
                grid[row, col] = ('S', 'l', '|')
            elseif c == '<'
                grid[row, col] = ('W', 'l', '-')
            elseif c == '>'
                grid[row, col] = ('E', 'l', '-')
            else
                grid[row, col] = c
            end
        end
    end
    return grid
end

function getCartPositions(grid)
    carts = []
    for r in 1:size(grid, 1)
        for c in 1:size(grid, 2)
            ch = grid[r, c]
            if typeof(ch) == Tuple{Char, Char, Char}
                push!(carts, (r, c))
            end
        end
    end
    return carts
end

function getVectorForDirection(dir)
    if dir == 'N'
        return [-1, 0]
    elseif dir == 'W'
        return [0, -1]
    elseif dir == 'S'
        return [1, 0]
    elseif dir == 'E'
        return [0, 1]
    end
end

function getNextDirection(cur, turn)
    directions = ['N', 'E', 'S', 'W']
    ind = findfirst(dir -> dir == cur, directions)
    if turn == 'l'
        ind = ind - 1
        if ind < 1
            ind += 4
        end
        return directions[ind]
    elseif turn == 's'
        return cur
    elseif turn == 'r'
        ind = ind + 1
        if ind > 4
            ind -= 4
        end
        return directions[ind]
    end
    return ' '
end

function getNextTurn(cur)
    if cur == 'l'
        return 's'
    elseif cur == 's'
        return 'r'
    elseif cur == 'r'
        return 'l'
    end
    return ' '
end

function getNewCornerDirection(d, corner)
    if corner == '\\'
        if d == 'N'
            return 'W'
        elseif d == 'W'
            return 'N'
        elseif d == 'S'
            return 'E'
        elseif d == 'E'
            return 'S'
        end
    elseif corner == '/'
        if d == 'N'
            return 'E'
        elseif d == 'E'
            return 'N'
        elseif d == 'S'
            return 'W'
        elseif d == 'W'
            return 'S'
        end
    end
end

function moveCart(row, col, grid)
    if typeof(grid[row, col]) != Tuple{Char, Char, Char}
        # there's no cart here
        return false, nothing
    end
    dir, turn, under = grid[row, col]
    loc = [row, col]
    vec = getVectorForDirection(dir)
    oldLoc = loc
    loc = loc + vec

    # Restore the square we moved from
    grid[row, col] = under

    row, col = loc

    newSquare = grid[row, col]
    if newSquare == '|' || newSquare == '-'
        grid[row, col] = (dir, turn, newSquare)
    elseif newSquare == '+'
        dir = getNextDirection(dir, turn)
        turn = getNextTurn(turn)
        grid[row, col] = (dir, turn, newSquare)
    elseif newSquare == '/' || newSquare == '\\'
        dir = getNewCornerDirection(dir, newSquare)
        grid[row, col] = (dir, turn, newSquare)
    elseif typeof(newSquare) == Tuple{Char, Char, Char}
        grid[row, col] = grid[row, col][3]
        # We collided!
        x = col - 1
        y = row - 1
        println("collided at $x,$y")
        flush(stdout)
        return true, (x, y)
    end
    return false, nothing
end

function solvePart1()
    s = getRawInput()
    grid = parseInput(s)
    collided = false
    row, col = 1, 1
    xy = (-1, -1)
    while !collided
        cartPositions = getCartPositions(grid)
        for (row, col) in cartPositions
            collided, xy = moveCart(row, col, grid)
            if collided
                break
            end
        end
    end
    return xy
end

function solvePart2()
    s = getRawInput()
    grid = parseInput(s)
    row, col = 1, 1
    cartPositions = getCartPositions(grid)
    while length(cartPositions) > 1
        for (row, col) in cartPositions
            for (row, col) in cartPositions
                moveCart(row, col, grid)
            end
        end
        cartPositions = getCartPositions(grid)
    end
    row, col = cartPositions[1]
    x = col - 1
    y = row - 1
    println("Cart ends at $x,$y")
    return (x, y)
end

end
