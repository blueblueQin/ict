import std.collection.*
import std.sort.*

func solve(input: Array<(Rune, Int64)>): Int64 {
    let n = input.size
    if (n < 2) { return 0 }
    
    var groupL = ArrayList<Int64>()
    var groupM = ArrayList<Int64>()
    var groupH = ArrayList<Int64>()
    
    for (i in 0..n) {
        let (tag, val) = input[i]
        // 仓颉支持 Rune 类型的比较操作 [6]
        if (tag == r'L') { groupL.add(val) }
        else if (tag == r'M') { groupM.add(val) }
        else if (tag == r'H') { groupH.add(val) }
    }
    
    sort(groupL)
    sort(groupM)
    sort(groupH)
    
    let nL = groupL.size
    let nM = groupM.size
    let nH = groupH.size
    
    let itemsL = Array<Int64>(nL, { i => groupL[i] })
    let itemsM = Array<Int64>(nM, { i => groupM[i] })
    let itemsH = Array<Int64>(nH, { i => groupH[i] })
    
    let matrix = [[1, 1, 1], [2, 1, 1], [2, 2, 1]]
    let INF: Int64 = Int64.Max / 2 // 防止加法溢出
    
    let totalStates = (nL + 1) * (nM + 1) * (nH + 1) * 3
    var dpCost = Array<Int64>(totalStates, { _ => INF })
    var dpTime = Array<Int64>(totalStates, { _ => INF })
    var dpCostAlt = Array<Int64>(totalStates, { _ => INF })
    var dpTimeAlt = Array<Int64>(totalStates, { _ => INF })
    
    let getIdx = { i: Int64, j: Int64, k: Int64, last: Int64 =>
        ((i * (nM + 1) + j) * (nH + 1) + k) * 3 + last
    }
    
    if (nL > 0) { let id = getIdx(1, 0, 0, 0); dpCost[id] = 0; dpTime[id] = 0; dpCostAlt[id] = 0; dpTimeAlt[id] = 0 }
    if (nM > 0) { let id = getIdx(0, 1, 0, 1); dpCost[id] = 0; dpTime[id] = 0; dpCostAlt[id] = 0; dpTimeAlt[id] = 0 }
    if (nH > 0) { let id = getIdx(0, 0, 1, 2); dpCost[id] = 0; dpTime[id] = 0; dpCostAlt[id] = 0; dpTimeAlt[id] = 0 }
    
    for (i in 0..=nL) {
        for (j in 0..=nM) {
            for (k in 0..=nH) {
                if (i + j + k == 0) { continue }
                for (last in 0..3) {
                    let cur = getIdx(i, j, k, last)
                    if (dpCost[cur] == INF) { continue }
                    
                    let update = { ni: Int64, nj: Int64, nk: Int64, nextT: Int64, baseC: Int64, baseT: Int64, limit: Int64 =>
                        let nextIdx = getIdx(ni, nj, nk, nextT)
                        let timeAt = baseT + matrix[last][nextT]
                        let wait = if (timeAt > limit) { timeAt - limit } else { 0 }
                        let costAt = baseC + wait
                        
                        if (costAt < dpCost[nextIdx] || (costAt == dpCost[nextIdx] && timeAt < dpTime[nextIdx])) {
                            dpCost[nextIdx] = costAt; dpTime[nextIdx] = timeAt
                        }
                        if (timeAt < dpTimeAlt[nextIdx] || (timeAt == dpTimeAlt[nextIdx] && costAt < dpCostAlt[nextIdx])) {
                            dpCostAlt[nextIdx] = costAt; dpTimeAlt[nextIdx] = timeAt
                        }
                    }

                    if (i < nL) { update(i + 1, j, k, 0, dpCost[cur], dpTime[cur], itemsL[i]) }
                    if (j < nM) { update(i, j + 1, k, 1, dpCost[cur], dpTime[cur], itemsM[j]) }
                    if (k < nH) { update(i, j, k + 1, 2, dpCost[cur], dpTime[cur], itemsH[k]) }
                }
            }
        }
    }
    var result = INF
    let finalIdxBase = getIdx(nL, nM, nH, 0)
    for (offset in 0..3) {
        let idx = finalIdxBase + offset
        if (dpCost[idx] < result) { result = dpCost[idx] }
        if (dpCostAlt[idx] < result) { result = dpCostAlt[idx] }
    }
    
    return result
}
