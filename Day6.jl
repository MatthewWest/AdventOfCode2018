module Day6

export solvePart1, solvePart2

import DelimitedFiles
import Distances

"""Get a sorted array of tuples containing xy coordinates."""
function getInput()
    open("day6input.txt") do f
        input = DelimitedFiles.readdlm(f, ',', Int64, '\n')
        sorted = sortslices(input, dims=1)
        mapslices(row -> (row[1], row[2]), sorted, dims=2)[:]
    end
end

""""Create a grid of coordinates to consider, 1 unit larger than the bounding
box of coordinates."""
function createGrid(input)
    xmin = minimum(map(first, input))
    ymin = minimum(map(tuple -> tuple[2], input))
    xmax = maximum(map(first, input))
    ymax = maximum(map(tuple -> tuple[2], input))
    xs = xmin-1:xmax+1
    ys = ymin-1:ymax+1
    return collect(Base.product(xs, ys))
end

"""Create a dictionary mapping from (x, y) to the distances to each point."""
function findDistances(grid, points)
    allDistances = Dict()
    for square in grid
        distances = map(point -> Distances.cityblock([x for x in point],
                                                     [x for x in square]),
                        points)
        allDistances[square] = distances
    end
    return allDistances
end

"""Using the distance map, create a mapping to the closest point."""
function findClosestPoints(distancesMap, points)
    closest = Dict()
    for square in keys(distancesMap)
        distances = distancesMap[square]
        min_index = argmin(distances)
        min_point = points[min_index]
        min_distance = distances[min_index]
        if count(d -> d == min_distance, distances) == 1
            closest[square] = min_point
        else
            closest[square] = "tie"
        end
    end
    return closest
end

"""Find all points that are not closest to an edge square."""
function getEligiblePointsSet(grid, points, closest)
    eligible = Set(points)

    (m, n) = size(grid)
    # Edges along the x direction
    for i in 1:m
        if closest[grid[i, 1]] in eligible
            pop!(eligible, closest[grid[i, 1]])
        end
        if closest[grid[i, n]] in eligible
            pop!(eligible, closest[grid[i, n]])
        end
    end
    # Edges along the y direction
    for i in 1:n
        if closest[grid[1, i]] in eligible
            pop!(eligible, closest[grid[1, i]])
        end
        if closest[grid[m, i]] in eligible
            pop!(eligible, closest[grid[m, i]])
        end
    end
    return eligible
end

"""Find the size of the regions around each point."""
function findRegionSizes(closest, eligible)
    regionSizes = Dict()
    for square in keys(closest)
        p = closest[square]
        if p in eligible
            regionSizes[p] = get(regionSizes, p, 0) + 1
        end
    end
    return regionSizes
end

function solvePart1()
    points = getInput()
    grid = createGrid(points)
    allDistances = findDistances(grid, points)
    closest = findClosestPoints(allDistances, points)
    eligiblePoints = getEligiblePointsSet(grid, points, closest)
    regionSizes = findRegionSizes(closest, eligiblePoints)
    return max(values(regionSizes)...)
end

function solvePart2()
    points = getInput()
    grid = createGrid(points)
    allDistances = findDistances(grid, points)

    totalDistances = Dict()
    for (square, distances) in allDistances
        totalDistances[square] = sum(distances)
    end

    return length(filter(d -> d < 10000, collect(values(totalDistances))))
end
end
