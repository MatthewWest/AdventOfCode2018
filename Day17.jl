function getInputString()
    open("day17input.txt") do f
        return strip(read(f, String))
    end
end

function getMinMaxXY(lines)
    xs = []
    ys = []
    for line in lines
        fixedCoord, coordRange = split(line)

        fixedValue = parse(Int, fixedCoord[3:end-1])
        if fixedCoord[1] == 'x'
            push!(xs, fixedValue)
        elseif fixedCoord[1] == 'y'
            push!(ys, fixedValue)
        end

        rangeStart, rangeEnd = map(s -> parse(Int, s), split(coordRange[3:end], ".."))
        if coordRange[1] == 'x'
            push!(xs, rangeStart:rangeEnd...)
        elseif coordRange[1] == 'y'
            push!(ys, rangeStart:rangeEnd...)
        end
    end
    return (min(xs...), min(ys...), max(xs...), max(ys...))
end

function parseInput(s)
    lines = filter(!isempty, split(s, '\n'))
    xMin, yMin, xMax, yMax = getMinMaxXY(lines)
    grid = Array{Char}(undef, xMax+1, yMax)
    fill!(grid, '.')
    for line in lines
        fixedCoord, coordRange = split(line)

        fixedValue = parse(Int, fixedCoord[3:end-1])

        rangeStart, rangeEnd = map(s -> parse(Int, s), split(coordRange[3:end], ".."))

        if fixedCoord[1] == 'x'
            grid[fixedValue, rangeStart:rangeEnd] .= '#'
        elseif fixedCoord[1] == 'y'
            grid[rangeStart:rangeEnd, fixedValue] .= '#'
        end
     end
     return grid, yMin, yMax
end

function printGrid(grid)
    println("Grid:")
    minX = Inf
    for y in 1:size(grid, 2)
        for x in 1:size(grid, 1)
            if x < minX && grid[x,y] != '.'
                minX = x
            end
        end
    end

    for y in 1:size(grid, 2)
        for x in minX:size(grid, 1)
            print(grid[x,y])
        end
        print("\n")
    end
end

function isPermeable(c::Char)
    c != '#' && c != '~'
end

function floodRow!(loc, grid)
    grid[loc...] = '~'

    left = loc .+ (-1, 0)
    while grid[left...] == '.' || grid[left...] == '|'
        grid[left...] = '~'
        left = left .+ (-1, 0)
    end

    right = loc .+ (1, 0)
    while grid[right...] == '.' || grid[right...] == '|'
        grid[right...] = '~'
        right = right .+ (1, 0)
    end

    return loc .+ (0, -1)
end

function findPourOvers(loc, grid)
    pourOvers = []
    grid[loc...] = '|'

    left = loc .+ (-1, 0)
    while grid[left...] == '.' || grid[left...] == '|'
        grid[left...] = '|'
        if isPermeable(grid[(left .+ (0, 1))...])
            push!(pourOvers, left)
            break
        end
        left = left .+ (-1, 0)
    end

    right = loc .+ (1, 0)
    while grid[right...] == '.' || grid[right...] == '|'
        grid[right...] = '|'
        if isPermeable(grid[(right .+ (0, 1))...])
            push!(pourOvers, right)
            break
        end
        right = right .+ (1, 0)
    end
    return pourOvers
end

function flowToPourOver(loc, grid)
    if grid[loc...] == '~'
        return []
    end

    # Mark this square as hit with water
    grid[loc...] = '|'

    # Flow down as far as possible
    down = loc
    while isPermeable(grid[down...])
        grid[down...] = '|'
        loc = down
        down = down .+ (0, 1)
        if down[2] > size(grid, 2)
            return []
        end
    end

    # we hit something, so find downspouts where we pour over
    pourOvers = findPourOvers(loc, grid)
    if length(pourOvers) > 0
        return pourOvers
    end

    # We didn't find any down spouts, so we're in a well. Flood it until we find downspouts
    while length(pourOvers) == 0
        loc = floodRow!(loc, grid)
        pourOvers = findPourOvers(loc, grid)
    end

    return pourOvers
end


function fillGrid!(grid)
    # Keep track of the places where water is traveling
    q = deque(Tuple{Int,Int})
    processed = Set()

    push!(q, (500, 1))

    while length(q) > 0
        square = popfirst!(q)
        if square in processed
            continue
        end

        toFlow = flowToPourOver(square, grid)
        if length(toFlow) > 0
            push!(q, toFlow...)
        end
        push!(processed, square)
        n = length(q)
        println("$n pourovers to process")
    end
end


function countWetSquares(grid, minY, maxY)
    length(filter(c -> c == '|' || c == '~', grid[:, minY:maxY]))
end

function countFilledSquares(grid, minY, maxY)
    length(filter(c -> c == '~', grid[:, minY:maxY]))
end


function solvePartA()
    grid, yMin, yMax = parseInput(getInputString())
    fillGrid!(grid)
    countWetSquares(grid, yMin, yMax)
end
    
function solvePartB()
    grid, yMin, yMax = parseInput(getInputString())
    fillGrid!(grid)
    countFilledSquares(grid, yMin, yMax)
end