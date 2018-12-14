module Day4
export solvePart1, solvePart2

function getSortedInput()
    inputs = Array{String}(undef, 0)
    open("day4input.txt") do f
        for line in eachline(f)
            push!(inputs, string(line))
        end
    end
    return sort(inputs)
end

function extractMinute(line)
    return parse(Int64, line[16:17])
end

function extractGuardId(lines)
    split(lines[1])[4][2:end]
end

function partitionByGuard(sortedInput)
    guards = []
    guard = []
    for line in sortedInput
        if occursin("Guard", line) && length(guard) > 0
            push!(guards, guard)
            guard = []
        end
        push!(guard, line)
    end

    dict = Dict()
    for guard in guards
        id = extractGuardId(guard)
        dict[id] = append!(get(dict, id, []), guard)
    end
    return collect(values(dict))
end

function lineContainsSleepOrWakeTime(line)
    occursin(r"asleep|wakes", line)
end

function sumTimeAsleepForGuard(lines)
    id = extractGuardId(lines)
    sleepAndWakeMinutes = map(extractMinute, filter(lineContainsSleepOrWakeTime, lines))
    minutesAsleep = Iterators.partition(sleepAndWakeMinutes, 2) |>
        iter -> map(xy -> xy[2] - xy[1], iter) |>
        iter -> reduce(+, iter)
    return (id, minutesAsleep)
end

function findGuardAsleepMost(inputs)
    guards = partitionByGuard(inputs)
    guardIdToTimeAsleep = map(sumTimeAsleepForGuard, guards)
    max = 0
    maxId = "N/A"
    for (id, timeAsleep) in guardIdToTimeAsleep
        if timeAsleep > max
            max = timeAsleep
            maxId = id
        end
    end
    return (maxId, max)
end

function getGuardLinesForId(id, inputs)
    guards = partitionByGuard(inputs)
    for guard in guards
        if occursin("Guard #$id", guard[1])
            return guard
        end
    end
end

function findMinuteGuardIsAsleepMost(lines)
    sleepAndWakeMinutes = map(extractMinute, filter(lineContainsSleepOrWakeTime, lines))
    daysAsleepByMinute = Dict()
    for (asleep, awake) in Iterators.partition(sleepAndWakeMinutes, 2)
        for m in asleep:awake-1
            daysAsleepByMinute[m] = get(daysAsleepByMinute, m, 0) + 1
        end
    end
    max = 0
    maxMinute = -1
    for (minute, timesAsleep) in daysAsleepByMinute
        if timesAsleep > max
            max = timesAsleep
            maxMinute = minute
        end
    end
    return (max, maxMinute)
end

function solvePart1()
    inputs = getSortedInput()
    (id, minutes) = findGuardAsleepMost(inputs)
    guard = getGuardLinesForId(id, inputs)
    (max, minute) = findMinuteGuardIsAsleepMost(guard)
    println("Guard #$id is asleep the most with $minutes minutes asleep.")
    println("Guard #$id is asleep most frequently in minute $minute: $max times")
    return parse(Int, id) * minute
end

function solvePart2()
    inputs = getSortedInput()
    guards = partitionByGuard(inputs)
    max = 0
    maxMinute = -1
    maxId = "n/a"
    for guard in guards
        (timesAsleep, minute) = findMinuteGuardIsAsleepMost(guard)
        if timesAsleep >= max
            max = timesAsleep
            maxMinute = minute
            maxId = extractGuardId(guard)
        end
    end
    println("Guard #$maxId is asleep most in one minute, with $max times in minute $maxMinute")
    return parse(Int, maxId) * maxMinute
end

end
