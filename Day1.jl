module Day1
export solvePart1, solvePart2

import Base.Iterators
import DelimitedFiles

function getInput()
    open("day1input.txt") do f
        return DelimitedFiles.readdlm(f, Int64)
    end
end

function solvePart1()
    pos = sum(getInput())
    println("Final resulting frequency: $pos")
    return pos
end

function solvePart2()
    visited = Set{Int64}()
    pos = 0
    push!(visited, pos)

    for input in Base.Iterators.cycle(getInput())
        pos += input
        if in(pos, visited)
            break
        end
        push!(visited, pos)
    end

    println("First frequency reached twice is: $pos")
    return pos
end

end
