module Day8

export solvePart1, solvePart2

import DelimitedFiles: readdlm
import DataStructures: deque, popfirst!

function getInput()
    open("day8input.txt") do f
        return readdlm(f, Int64)[:]
    end
end

struct Node
    children
    metadata
end

function extractTreeRecursive(q)
    numChildren = popfirst!(q)
    numMetadata = popfirst!(q)
    children = []
    for i in 1:numChildren
        push!(children, extractTreeRecursive(q))
    end
    metadata = []
    for i in 1:numMetadata
        push!(metadata, popfirst!(q))
    end
    return Node(children, metadata)
end

function extractTree(numbers)
    q = deque(Int64)
    push!(q, numbers...)
    tree = extractTreeRecursive(q)
    return tree
end

function sumMetadata(tree::Node)
    summ = 0
    for child in tree.children
        summ += sumMetadata(child)
    end
    summ += sum(tree.metadata)
    return summ
end

function solvePart1()
    numbers = getInput()
    tree = extractTree(numbers)
    return sumMetadata(tree)
end

function getValue(node::Node)
    n = length(node.children)
    if n == 0
        return sum(node.metadata)
    end
    value = 0
    for entry in node.metadata
        if entry <= n
            value += getValue(node.children[entry])
        end
    end
    return value
end


function solvePart2()
    numbers = getInput()
    tree = extractTree(numbers)
    return getValue(tree)
end

end
