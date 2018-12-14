module Day3
export solvePart1, solvePart2

function parseClaim(s)
    split(s, r"[^0-9]") |>
    parts -> filter(!isempty, parts) |>
    nums -> map(n -> parse(Int64, n), nums)
end

function getAreaIterator(x, y, w, h)
    Iterators.product(x:x+w-1, y:y+h-1)
end

function getInput()
    open("day3input.txt") do f
        readlines(f) |>
        collect |>
        lines -> map(line -> parseClaim(line), lines)
    end
end

function addPointToDict!(dict, xy)
    dict[(xy[1], xy[2])] = get(dict, (xy[1], xy[2]), 0) + 1
end

function addClaimToDict!(dict, claim)
    getAreaIterator(claim[2:end]...) |>
    iter -> foreach(xy -> addPointToDict!(dict, xy), iter)
end

function solvePart1()
    claims = getInput()
    coverage = Dict{Tuple{Int, Int}, Int}()
    for claim in claims
        addClaimToDict!(coverage, claim)
    end
    overlaps = 0
    for (k, v) in coverage
        if v > 1
            overlaps += 1
        end
    end
    println("There are " * string(overlaps) * " square inches of overlap.")
    return overlaps
end

function noOverlappingSquares(dict, claim)
    squaresInClaim = getAreaIterator(claim[2:end]...)
    for square in squaresInClaim
        if dict[square] > 1
            return false
        end
    end
    return true
end

function solvePart2()
    claims = getInput()
    overlappingSquareDict = Dict()
    for claim in claims
        addClaimToDict!(overlappingSquareDict, claim)
    end

    claim = filter(claim -> noOverlappingSquares(overlappingSquareDict, claim), claims)[1][1]
    print("Claim #" * string(claim) * " has no overlapping squares.")
end

end
