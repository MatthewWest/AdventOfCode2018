module Day9
export solvePart1, solvePart2

numberOfPlayers = 418
lastMarblePoints = 71339

mutable struct Marble
    next
    prev
    number::Int64
end

function indexCounterClockwise(ind, numPlaces, len)
    i = ind - numPlaces
    while i < 0
        i += len
    end
    return i
end

function indexClockwise(ind, numPlaces, len)
    i = ind + numPlaces
    while i > len
        i -= len
    end
    return i
end

function removeMarbleSevenPlacesCounterClockwise(current::Marble)
    toRemove = current
    for i in 1:7
        toRemove = toRemove.prev
    end
    before = toRemove.prev
    after = toRemove.next
    before.next = after
    after.prev = before
    return toRemove
end

function winningElfScore(numberOfPlayers, lastNumberScore)
    # Start with a marble whose previous and next is itself
    firstMarble = Marble(nothing, nothing, 0)
    firstMarble.next = firstMarble
    firstMarble.prev = firstMarble

    whoseTurn = 1
    points = Dict()
    current = firstMarble
    for nextMarbleNumber in 1:lastNumberScore
        if nextMarbleNumber % 23 == 0
            removed = removeMarbleSevenPlacesCounterClockwise(current)
            toGain = nextMarbleNumber + removed.number
            points[whoseTurn] = get(points, whoseTurn, 0) + toGain
            current = removed.next
        else
            before = current.next
            after = before.next
            toInsert = Marble(before, after, nextMarbleNumber)
            before.next = toInsert
            after.prev = toInsert
            toInsert.prev = before
            toInsert.next = after
            current = toInsert
        end

        whoseTurn += 1
        if whoseTurn > numberOfPlayers
            whoseTurn = 1
        end
    end
    return max(values(points)...)
end

function solvePart1()
    winningElfScore(numberOfPlayers, lastMarblePoints)
end

function solvePart2()
    winningElfScore(numberOfPlayers, lastMarblePoints*100)
end
end
