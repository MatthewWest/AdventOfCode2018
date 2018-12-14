module Day5

export solvePart1, solvePart2

import DataStructures

function lettersReact(a, b)
    (a != b) && (lowercase(a) == lowercase(b))
end

function reactString(s)
    q = DataStructures.deque(Char)
    for c in s
        if isempty(q)
            push!(q, c)
        else
            last = DataStructures.back(q)
            if lettersReact(c, last)
                pop!(q)
            else
                push!(q, c)
            end
        end
    end

    return join(q, "")
end

function getInput()
    open("day5input.txt") do f
        return read(f, String)
    end
end

function solvePart1()
    length(reactString(getInput()))
end

function getLowercaseLettersSet(s)
    letters = Set{Char}()
    for c in s
        if islowercase(c)
            push!(letters, c)
        end
    end
    return collect(letters)
end

function solvePart2()
    s = getInput()
    minLen = typemax(Int32)
    cs = getLowercaseLettersSet(s)
    for c in cs
        alteredSequence = filter(c1 -> lowercase(c1) != lowercase(c), s)
        n = length(reactString(alteredSequence))
        minLen = min(n, minLen)
    end
    return minLen
end

end
