module Day12
export solvePart1, solvePart2

function getInput()
    s = ""
    open("day12input.txt") do f
        s = read(f, String)
    end
    lines = split(s, "\n")

    state = repeat(".", 100) * lines[1][16:end]
    rules = Dict()
    for line in lines[3:end-1]
        rules[line[1:5]] = line[10]
    end
    return state, rules, -100
end

function getSuccessor(state, leftIndex, rules)
    successor = []
    if '#' in state[1:3]
        leftIndex -= 100
        state = repeat(".", 100) * state
    end

    if '#' in state[end-2:end]
        state = state * repeat(".", 100)
    end

    for i in 1:length(state)
        if i < 3 || i > length(state) - 2
            push!(successor, ".")
        else
            push!(successor, get(rules, state[i-2:i+2], "."))
        end
    end
    return join(successor, ""), leftIndex
end

function sumPotsWithPlants(state, leftIndex)
    sum = 0
    for i in leftIndex:length(state)+leftIndex-1
        if state[i - leftIndex + 1] == '#'
            sum += i
        end
    end
    return sum
end

function solve(state, leftIndex, rules)
    for i in 1:20
        state, leftIndex = getSuccessor(state, leftIndex, rules)
    end
    part1 = sumPotsWithPlants(state, leftIndex)

    # Keep going to get to a stable pattern
    for i in 21:1000
        state, leftIndex = getSuccessor(state, leftIndex, rules)
    end
    # Find the current rate of growth each generation
    num = sumPotsWithPlants(state, leftIndex)
    state, leftIndex = getSuccessor(state, leftIndex, rules)
    diff = sumPotsWithPlants(state, leftIndex) - num
    # Multiply by the number of generations
    part2 = num + diff * (50000000000 - 1000)
    return (part1, part2)
end

function solvePart1()
    state, rules, leftIndex = getInput()
    part1 = solve(state, leftIndex, rules)[1]
    println("Answer for part 1 is $part1")
    return part1
end

function solvePart2()
    state, rules, leftIndex = getInput()
    part2 = solve(state, leftIndex, rules)[2]
    println("Answer for part 2 is $part2")
    return part2
end
end
