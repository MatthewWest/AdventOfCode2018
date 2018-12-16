module Day16
export solvePart1, solvePart2

struct Sample
    before::Array{Int}
    command::Array{Int}
    after::Array{Int}
end


function addr(command::Array{Int}, before::Array{Int})
    a, b, c = command[2:4]
    registers = copy(before)
    registers[c+1] = registers[a+1] + registers[b+1]
    return registers
end

function addi(command::Array{Int}, before::Array{Int})
    a, b, c = command[2:4]
    registers = copy(before)
    registers[c+1] = registers[a+1] + b
    return registers
end

function mulr(command::Array{Int}, before::Array{Int})
    a, b, c = command[2:4]
    registers = copy(before)
    registers[c+1] = registers[a+1] * registers[b+1]
    return registers
end

function muli(command::Array{Int}, before::Array{Int})
    a, b, c = command[2:4]
    registers = copy(before)
    registers[c+1] = registers[a+1] * b
    return registers
end

function banr(command::Array{Int}, before::Array{Int})
    a, b, c = command[2:4]
    registers = copy(before)
    registers[c+1] = registers[a+1] & registers[b+1]
    return registers
end

function bani(command::Array{Int}, before::Array{Int})
    a, b, c = command[2:4]
    registers = copy(before)
    registers[c+1] = registers[a+1] & b
    return registers
end

function borr(command::Array{Int}, before::Array{Int})
    a, b, c = command[2:4]
    registers = copy(before)
    registers[c+1] = registers[a+1] | registers[b+1]
    return registers
end

function bori(command::Array{Int}, before::Array{Int})
    a, b, c = command[2:4]
    registers = copy(before)
    registers[c+1] = registers[a+1] | b
    return registers
end

function setr(command::Array{Int}, before::Array{Int})
    a, b, c = command[2:4]
    registers = copy(before)
    registers[c+1] = registers[a+1]
    return registers
end

function seti(command::Array{Int}, before::Array{Int})
    a, b, c = command[2:4]
    registers = copy(before)
    registers[c+1] = a
    return registers
end

function gtir(command::Array{Int}, before::Array{Int})
    a, b, c = command[2:4]
    registers = copy(before)
    if a > registers[b+1]
        registers[c+1] = 1
    else
        registers[c+1] = 0
    end
    return registers
end

function gtri(command::Array{Int}, before::Array{Int})
    a, b, c = command[2:4]
    registers = copy(before)
    if registers[a+1] > b
        registers[c+1] = 1
    else
        registers[c+1] = 0
    end
    return registers
end

function gtrr(command::Array{Int}, before::Array{Int})
    a, b, c = command[2:4]
    registers = copy(before)
    if registers[a+1] > registers[b+1]
        registers[c+1] = 1
    else
        registers[c+1] = 0
    end
    return registers
end

function eqir(command::Array{Int}, before::Array{Int})
    a, b, c = command[2:4]
    registers = copy(before)
    if a == registers[b+1]
        registers[c+1] = 1
    else
        registers[c+1] = 0
    end
    return registers
end

function eqri(command::Array{Int}, before::Array{Int})
    a, b, c = command[2:4]
    registers = copy(before)
    if registers[a+1] == b
        registers[c+1] = 1
    else
        registers[c+1] = 0
    end
    return registers
end

function eqrr(command::Array{Int}, before::Array{Int})
    a, b, c = command[2:4]
    registers = copy(before)
    if registers[a+1] == registers[b+1]
        registers[c+1] = 1
    else
        registers[c+1] = 0
    end
    return registers
end

function getSamplesInput()
    s = ""
    open("day16input.txt") do f
        s = read(f, String)
    end
    sampleSection, program = split(s, "\n\n\n")
    sampleStrings = split(sampleSection, "\n\n")
    samples = []
    for sample in sampleStrings
        lines = split(sample, '\n')
        before = map(s -> parse(Int, s), split(lines[1][10:end-1], ','))
        command = map(s -> parse(Int, s), split(lines[2]))
        after = map(s -> parse(Int, s), split(lines[3][10:end-1], ','))
        push!(samples, Sample(before, command, after))
    end
    return samples
end

function getProgramInput()
    s = ""
    open("day16input.txt") do f
        s = read(f, String)
    end
    sampleSection, program = split(s, "\n\n\n")
    commands = []
    for line in split(program, '\n')
        command = map(s -> parse(Int, s), split(line))
        if length(command) == 4
            push!(commands, command)
        end
    end
    return commands
end

ops = [addr, addi, mulr, muli, banr, bani, borr, bori, setr, seti, gtir, gtri, gtrr, eqir, eqri, eqrr]

function opMatchesSample(op, sample::Sample)
        result = op(sample.command, sample.before)
        return result == sample.after
end

function solvePart1()
    samples = getSamplesInput()
    ns = []
    for sample in samples
        n = 0
        for op in ops
            if opMatchesSample(op, sample)
                n += 1
            end
        end
        push!(ns, n)
    end
    length(filter(n -> n >= 3, ns))
end

function getMapping(samples)
    possibleMappings = Dict()
    for opcode in 0:15
        possibleMappings[opcode] = Set(ops)
    end

    for sample in samples
        opcode = sample.command[1]
        possibleOps = filter(op -> opMatchesSample(op, sample), ops)
        possibleMappings[opcode] = intersect(possibleMappings[opcode], possibleOps)
    end

    mappings = Dict()
    done = false
    while !done
        certain = filter(kv -> length(kv[2]) == 1, possibleMappings)
        if length(certain) == 0
            done = true
        end
        for kv in certain
            opcode, op = kv
            mappings[opcode] = collect(op)[1]
            ocs = keys(possibleMappings)
            for oc in ocs
                possibleMappings[oc] = setdiff(possibleMappings[oc], op)
            end
            delete!(possibleMappings, opcode)
        end
    end
    return mappings
end

function executeProgram(program, mapping)
    registers = [0, 0, 0, 0]
    for command in program
        op = mapping[command[1]]
        a, b, c = command[2:4]
        registers = op(command, registers)
    end
    return registers
end


function solvePart2()
    samples = getSamplesInput()
    mapping = getMapping(samples)
    program = getProgramInput()
    registers = executeProgram(program, mapping)
end
end
