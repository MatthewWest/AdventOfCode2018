module Day10
export solvePart1, solvePart2

struct Point
    position::Vector{Int64}
    velocity::Vector{Int64}
end

function getInput()
    open("day10input.txt") do f
        posvel = []
        for line in eachline(f)
            xLoc = findnext(r"[-0-9]+", line, 1)
            x = parse(Int64, line[xLoc])
            yLoc = findnext(r"[-0-9]+", line, xLoc[end]+1)
            y = parse(Int64, line[yLoc])
            xVelLoc = findnext(r"[-0-9]+", line, yLoc[end]+1)
            xVel = parse(Int64, line[xVelLoc])
            yVelLoc = findnext(r"[-0-9]+", line, xVelLoc[end]+1)
            yVel = parse(Int64, line[yVelLoc])
            push!(posvel, Point([x, y], [xVel, yVel]))
        end
        return posvel
    end
end

function getBoundingBox(points)
    xs = map(point -> point.position[1], points)
    ys = map(point -> point.position[2], points)
    return min(xs...), max(xs...), min(ys...), max(ys...)
end

function getBoundingBoxMagnitude(points)
    xMin, xMax, yMin, yMax = getBoundingBox(points)
    (xMax - xMin) + (yMax - yMin)
end

function getSuccessorPoints(points)
    next = []
    for point in points
        newPosition = point.position + point.velocity
        push!(next, Point(newPosition, point.velocity))
    end
    return next
end

function sPrintPoints(points)
    xMin, xMax, yMin, yMax = getBoundingBox(points)

    locContainsPoint = Dict()
    for point in points
        locContainsPoint[point.position] = true
    end

    s = []

    for y in yMin:yMax
        for x in xMin:xMax
            if get(locContainsPoint, [x, y], false)
                push!(s, "#")
            else
                push!(s, " ")
            end
        end
        push!(s, "\n")
    end
    return join(s, "")
end

function solve()
    points = getInput()
    size = getBoundingBoxMagnitude(points)
    next = getSuccessorPoints(points)
    nextSize = getBoundingBoxMagnitude(next)
    seconds = 0
    while nextSize < size
        points = next
        size = nextSize
        next = getSuccessorPoints(points)
        nextSize = getBoundingBoxMagnitude(next)
        seconds += 1
    end
    return (sPrintPoints(points), seconds)
end

function solvePart1()
    return solve()[1]
end

function solvePart2()
    return solve()[2]
end
end
