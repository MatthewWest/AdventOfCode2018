module Day2
export solvePart1, solvePart2

import DelimitedFiles
import Combinatorics

function getInput()
    open("day2input.txt") do f
        return DelimitedFiles.readdlm(f, String)
    end
end

function getLetterCounts(s)
    counts = Dict()
    for c in s
        counts[c] = get(counts, c, 0) + 1
    end
    return counts
end

function numCodesWithNRepeats(n, inputs)
    letters = Char[]
    num = 0
    for code in inputs
        counts = getLetterCounts(code)
        if n in values(counts)
            num +=1
        end
    end
    return num
end

function solvePart1()
    inputs = getInput()
    repeat2 = numCodesWithNRepeats(2, inputs)
    repeat3 = numCodesWithNRepeats(3, inputs)
    return repeat2 * repeat3
end

function numChanges(a, b)
    n = 0
    for (c1, c2) in zip(a, b)
        if c1 != c2
            n +=1
        end
    end
    return n
end

function pairsWithOneChange(inputs)
    pairs = []
    for (s1, s2) in Combinatorics.combinations(inputs, 2)
        if numChanges(s1, s2) == 1
            push!(pairs, (s1, s2))
        end
    end
    return pairs
end

function commonLetters(s1, s2)
    output = []
    for (c1, c2) in zip(s1, s2)
        if c1 == c2
            push!(output, c1)
        end
    end
    return join(output)
end

function solvePart2()
    inputs = getInput()
    oneChange = pairsWithOneChange(inputs)
    commonLetters(oneChange[1]...)
end
end
