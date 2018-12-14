module Day7
export solvePart1, solvePart2

import DataStructures: PriorityQueue, enqueue!, dequeue!

function getRawInput()
    lines = []
    open("day7input.txt") do f
        for line in eachline(f)
            push!(lines, line)
        end
    end
    return lines
end

function parseInput(lines)
    parents = Dict()
    children = Dict()
    for s in lines
        step, required = s[37], s[6]
        parents[step] = union(get(parents, step, Set()), Set([required]))
        children[required] = union(get(children, required, Set()), Set([step]))
    end

    return (parents, children)
end


function getInput()
    parseInput(getRawInput())
end

function solvePart1()
    parents, children = getInput()

    queue = PriorityQueue{Char, Char}()
    roots = setdiff(Set(keys(children)), Set(keys(parents)))
    for root in roots
        enqueue!(queue, root, root)
    end

    order = []
    processed = Set()
    while length(queue) > 0
        c = dequeue!(queue)
        push!(processed, c)
        push!(order, c)

        childs = get(children, c, Set())
        for child in childs
            deps = get(parents, child, Set())
            if length(setdiff(parents[child], processed)) == 0
                enqueue!(queue, child, child)
            end
        end
    end
    join(order, "")
end

function timeToDo(task::Char)
    60 + task - 'A' + 1
end

function addToDictionary!(d, time, task)
    d[time] = [get(d, time, []); task]
end

function enqueueUnblockedChildren!(q, c, children, parents, processed)
    childs = get(children, c, Set())
    for child in childs
        deps = get(parents, child, Set())
        if length(setdiff(parents[child], processed)) == 0
            enqueue!(q, child, child)
        end
    end
end

function solvePart2()
    parents, children = getInput()
    freeWorkers = 5
    queue = PriorityQueue{Char, Char}()
    roots = setdiff(Set(keys(children)), Set(keys(parents)))
    for root in roots
        enqueue!(queue, root, root)
    end

    processed = Set()
    seconds = 0
    # a map with 15 -> ['A', 'B'], where 'A' and 'B' are tasks, and 15 is the
    # seconds count when they will finish.
    inProgress = Dict()
    while (length(queue) + length(keys(inProgress)) > 0)
        # Remove completed tasks
        if seconds in keys(inProgress)
            for completed in inProgress[seconds]
                push!(processed, completed)
                enqueueUnblockedChildren!(queue, completed, children, parents, processed)
                freeWorkers += 1
            end
            delete!(inProgress, seconds)
        end
        # To avoid an off-by-one error, break immediately when we finish
        if length(queue) + length(keys(inProgress)) == 0
            break
        end

        # Start as many workers as we have and have tasks for
        while freeWorkers > 0 && length(queue) > 0
            task = dequeue!(queue)
            addToDictionary!(inProgress, seconds + timeToDo(task), task)
            freeWorkers -= 1
        end
        seconds += 1
    end
    return seconds
end

end
