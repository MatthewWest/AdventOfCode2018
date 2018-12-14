module Day14

export solvePart1, solvePart2

#= input = 633601 =#
input = 633601


function solvePart1()
    scores = [3, 7]
    elf1, elf2 = 1, 2

    while length(scores) < input + 10
        toAdd = scores[elf1] + scores[elf2]
        if toAdd <= 9
            push!(scores, toAdd)
        else
            push!(scores, div(toAdd, 10))
            push!(scores, toAdd % 10)
        end
        n = length(scores)
        elf1 += 1 + scores[elf1]
        while elf1 > n
            elf1 -= n
        end
        elf2 += 1 + scores[elf2]
        while elf2 > n
            elf2 -= n
        end
    end
    strings = map(score -> string(score), scores[input+1:input+10])
    return join(strings, "")
end

# A local variable / parameter is much cheaper to access than a module-global.
function part2Inner(target)
    scores = [3, 7]
    elf1, elf2 = 1, 2

    digits = Int(floor(log10(target))) + 1

    found = false
    while !found
        toAdd = scores[elf1] + scores[elf2]
        if toAdd <= 9
            push!(scores, toAdd)
        else
            push!(scores, div(toAdd, 10))
            push!(scores, toAdd % 10)
        end
        n = length(scores)
        elf1 += 1 + scores[elf1]
        while elf1 > n
            elf1 -= n
        end
        elf2 += 1 + scores[elf2]
        while elf2 > n
            elf2 -= n
        end

        if n >= digits
            final = 0
            semiFinal = 0
            for i in -digits+1:0
                final = final * 10 + scores[n+i]
            end
            if n >= digits + 1
                for i in -digits:-1
                    semiFinal = semiFinal * 10 + scores[n+i]
                end
            end

            if final == target
                return n - digits
            elseif semiFinal == target
                return n - (digits+1)
            end

        end
    end
end


function solvePart2()
    return part2Inner(input)
end
end
