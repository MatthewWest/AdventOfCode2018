module Day11
export solvePart1, solvePart2Slow, solvePart2

serialNumber = 6548

function findCellPower(x::Int, y::Int, serialNumber::Int)
    rackId = x + 10
    power = rackId * y
    power += serialNumber
    power *= rackId
    power = div(power, 100) % 10
    power -= 5
    return power
end

function findAllCellPowers(serialNumber::Int)
    map(xy -> findCellPower(xy[1], xy[2], serialNumber), Base.product(1:300, 1:300))
end

function findBlockPower(x::Int, y::Int, squareSize::Int, powers::Array{Int, 2})
    n = 0
    for i in x:x+squareSize-1
        for j in y:y+squareSize-1
            n += powers[i, j]
        end
    end
    return n
end

function findMaxPowerBlock(squareSize::Int, powers::Array{Int, 2})
    blockPowers = Dict()
    for x in 1:size(powers, 1)-squareSize+1
        for y in 1:size(powers, 2)-squareSize+1
            blockPowers[(x, y)] = findBlockPower(x, y, squareSize, powers)
        end
    end
    maxPower = -Inf
    maxPos = nothing
    for (pos, power) in blockPowers
        if power > maxPower
            maxPower = power
            maxPos = pos
        end
    end
    if maxPos == nothing
        return (nothing, nothing, squareSize), maxPower
    else
        return (maxPos[1], maxPos[2], squareSize), maxPower
    end
end

function solvePart1()
    findMaxPowerBlock(3, findAllCellPowers(serialNumber))[1][1:2]
end

"""I got this idea from someone on the AdventOfCode subreddit.
I've also seen it before, so I should have thought of it.

I wanted to see how fast it was. Much much much much much faster, as it turns out."""
function solvePart2()
    # Summed-area Table indexed starting with 0
    t = zeros(Int64, 301, 301)
    for x in 1:300
        for y in 1:300
            power = findCellPower(x, y, serialNumber)
            t[x+1, y+1] = power + t[x, y+1] + t[x+1, y] - t[x, y]
        end
    end
    best = nothing
    max = -Inf
    for s in 1:300
        for x in 1:300-s
            for y in 1:300-s
                total = t[x+s, y+s] - t[x, y+s] - t[x+s, y] + t[x, y]
                if total > max
                    best = (s, x, y)
                    max = total
                end
            end
        end
    end
    return best
end

"""This was my first attempt. It's very slow (~70 seconds)"""
function solvePart2Slow()
    powers = findAllCellPowers(6548)
    maxCoord = nothing
    maxPower = -Inf
    for size in 1:300
        coord, power = findMaxPowerBlock(size, powers)
        if power > maxPower
            maxCoord = coord
            maxPower = power
        end
    end
    x, y, s = maxCoord
    return s, x, y
end
end
