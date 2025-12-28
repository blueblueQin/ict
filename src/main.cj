package ict

import std.sort.*

func solve(input: Array<(Int64, Int64)>): Int64 {
    let n = input.size
    if(n == 0) {return 0 }
    var starts = Array<Int64>(n,repeat:0)
    var ends  = Array<Int64>(n,repeat:0)
    for(i in 0..n){
        starts[i] = input[i][0]
        ends[i] = input[i][1]
    }
    sort(starts)
    sort(ends)
    var count = 0
    var maxRooms = 0
    var sPtr = 0
    var ePtr = 0
    while (sPtr < n){
        if(starts[sPtr]<ends[ePtr]){
            count++
            sPtr++
        } else{
            count--
            ePtr++
        }
        if(count > maxRooms){
            maxRooms = count
        }
    }
    return maxRooms
}

main():Int64{
    let meetings = [(0,600),(500,1000),(700,1200)]
    let result = solve(meetings)
    println(result)
    return 0 
}
