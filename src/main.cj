import std.collection.*
import std.sort.*

struct StateResult {
    init(
        public var cost: Int64,
        public var time: Int64
    ) {}
}


public func solve(input: Array<(Rune, Int64)>): Int64 {
    let totalItems = input.size
    if (totalItems < 2) { return 0 }
    
    var groupA = ArrayList<Int64>()
    var groupB = ArrayList<Int64>()
    var groupC = ArrayList<Int64>()
    
    for (i in 0..totalItems) {
        let (category, val) = input[i]
        match (category) {
            case r'L' => groupA.add(val)
            case r'M' => groupB.add(val)
            case r'H' => groupC.add(val)
            case _ => ()
        }
    }
    
    sort(groupA)
    sort(groupB)
    sort(groupC)
    
    let sizeA = groupA.size
    let sizeB = groupB.size
    let sizeC = groupC.size
    
    // 转换至静态数组提升访问效率
    let dataA = Array<Int64>(sizeA, { i => groupA[i] })
    let dataB = Array<Int64>(sizeB, { i => groupB[i] })
    let dataC = Array<Int64>(sizeC, { i => groupC[i] })
    
    let gapMatrix = [[1, 1, 1], [2, 1, 1], [2, 2, 1]]
    let INF: Int64 = Int64.Max / 2
    
    let totalStates = (sizeA + 1) * (sizeB + 1) * (sizeC + 1) * 3
    var dpCost = Array<Int64>(totalStates, { _ => INF })
    var dpTime = Array<Int64>(totalStates, { _ => INF })
    var dpCostAlt = Array<Int64>(totalStates, { _ => INF })
    var dpTimeAlt = Array<Int64>(totalStates, { _ => INF })
    
    let getIdx = { a: Int64, b: Int64, c: Int64, last: Int64 =>
        ((a * (sizeB + 1) + b) * (sizeC + 1) + c) * 3 + last
    }
    
    if (sizeA > 0) { let i = getIdx(1, 0, 0, 0); dpCost[i] = 0; dpTime[i] = 0; dpCostAlt[i] = 0; dpTimeAlt[i] = 0 }
    if (sizeB > 0) { let i = getIdx(0, 1, 0, 1); dpCost[i] = 0; dpTime[i] = 0; dpCostAlt[i] = 0; dpTimeAlt[i] = 0 }
    if (sizeC > 0) { let i = getIdx(0, 0, 1, 2); dpCost[i] = 0; dpTime[i] = 0; dpCostAlt[i] = 0; dpTimeAlt[i] = 0 }
    
    for (a in 0..=sizeA) {
        for (b in 0..=sizeB) {
            for (c in 0..=sizeC) {
                if (a + b + c == 0) { continue }
                for (lastType in 0..3) {
                    let currIdx = getIdx(a, b, c, lastType)
                    if (dpCost[currIdx] == INF) { continue }
                    
                    let update = { targetA: Int64, targetB: Int64, targetC: Int64, nextType: Int64, baseC: Int64, baseT: Int64, limit: Int64 =>
                        let nextIdx = getIdx(targetA, targetB, targetC, nextType)
                        let nextT = baseT + gapMatrix[lastType][nextType]
                        let wait = if (nextT > limit) { nextT - limit } else { 0 }
                        let nextC = baseC + wait
                        
                        if (nextC < dpCost[nextIdx] || (nextC == dpCost[nextIdx] && nextT < dpTime[nextIdx])) {
                            dpCost[nextIdx] = nextC
                            dpTime[nextIdx] = nextT
                        }
                        if (nextT < dpTimeAlt[nextIdx] || (nextT == dpTimeAlt[nextIdx] && nextC < dpCostAlt[nextIdx])) {
                            dpCostAlt[nextIdx] = nextC
                            dpTimeAlt[nextIdx] = nextT
                        }
                    }

                    if (a < sizeA) { 
                        update(a + 1, b, c, 0, dpCost[currIdx], dpTime[currIdx], dataA[a])
                        if (dpTimeAlt[currIdx] != dpTime[currIdx]) {
                            update(a + 1, b, c, 0, dpCostAlt[currIdx], dpTimeAlt[currIdx], dataA[a])
                        }
                    }
                    if (b < sizeB) { 
                        update(a, b + 1, c, 1, dpCost[currIdx], dpTime[currIdx], dataB[b])
                        if (dpTimeAlt[currIdx] != dpTime[currIdx]) {
                            update(a, b + 1, c, 1, dpCostAlt[currIdx], dpTimeAlt[currIdx], dataB[b])
                        }
                    }
                    if (c < sizeC) { 
                        update(a, b, c + 1, 2, dpCost[currIdx], dpTime[currIdx], dataC[c])
                        if (dpTimeAlt[currIdx] != dpTime[currIdx]) {
                            update(a, b, c + 1, 2, dpCostAlt[currIdx], dpTimeAlt[currIdx], dataC[c])
                        }
                    }
                }
            }
        }
    }
    
    var finalMin = INF
    for (t in 0..3) {
        let lastIdx = getIdx(sizeA, sizeB, sizeC, t)
        finalMin = min(finalMin, min(dpCost[lastIdx], dpCostAlt[lastIdx], [])) // 使用标准库 min 函数 [6]
    }
    
    return finalMin
}
