import std.collection.*
import std.sort.*


public func solve(input: Array<(Rune, Int64)>): Int64 {
    let n = input.size
    if (n < 2) { return 0 }

    // 1. 数据分类归档：利用 ArrayList 动态划分数据 [1]
    var bucketL = ArrayList<Int64>()
    var bucketM = ArrayList<Int64>()
    var bucketH = ArrayList<Int64>()

    for (i in 0..n) {
        let (category, timeVal) = input[i]
        match (category) {
            case r'L' => bucketL.add(timeVal)
            case r'M' => bucketM.add(timeVal)
            case _    => bucketH.add(timeVal)
        }
    }

    // 排序各类别权重 [6]
    sort(bucketL)
    sort(bucketM)
    sort(bucketH)

    let countL = bucketL.size
    let countM = bucketM.size
    let countH = bucketH.size

    // 【语法脱敏/修复】重新绑定引用，避免 Lambda 捕获可变变量错误 [3]
    let refL = bucketL
    let refM = bucketM
    let refH = bucketH

    let dataL = Array<Int64>(countL, { i => refL[i] })
    let dataM = Array<Int64>(countM, { i => refM[i] })
    let dataH = Array<Int64>(countH, { i => refH[i] })

    // 2. 调度间隔矩阵定义 (0=L, 1=M, 2=H)
    let weightMatrix = [[1, 1, 1], [2, 1, 1], [2, 2, 1]]
    let INF: Int64 = Int64.Max / 2 // 使用 64 位整数处理 [6]

    // 3. DP 状态表空间初始化
    let stateSpace = (countL + 1) * (countM + 1) * (countH + 1) * 3
    let dp_Cost = Array<Int64>(stateSpace, { _ => INF })
    let dp_Time = Array<Int64>(stateSpace, { _ => INF })
    let dp_Cost_Alt = Array<Int64>(stateSpace, { _ => INF })
    let dp_Time_Alt = Array<Int64>(stateSpace, { _ => INF })

    // 索引映射函数（保持为闭包，但捕获量已通过 let 锁定）
    let calcIdx = { i: Int64, j: Int64, k: Int64, typeIdx: Int64 =>
        ((i * (countM + 1) + j) * (countH + 1) + k) * 3 + typeIdx
    }

    // 初始状态设定
    if (countL > 0) { let id = calcIdx(1, 0, 0, 0); dp_Cost[id] = 0; dp_Time[id] = 0; dp_Cost_Alt[id] = 0; dp_Time_Alt[id] = 0 }
    if (countM > 0) { let id = calcIdx(0, 1, 0, 1); dp_Cost[id] = 0; dp_Time[id] = 0; dp_Cost_Alt[id] = 0; dp_Time_Alt[id] = 0 }
    if (countH > 0) { let id = calcIdx(0, 0, 1, 2); dp_Cost[id] = 0; dp_Time[id] = 0; dp_Cost_Alt[id] = 0; dp_Time_Alt[id] = 0 }

    // 4. DP 状态转移核心
    for (i in 0..=countL) {
        for (j in 0..=countM) {
            for (k in 0..=countH) {
                if (i + j + k == 0) { continue }
                for (lastType in 0..3) {
                    let currentId = calcIdx(i, j, k, lastType)
                    if (dp_Cost[currentId] == INF) { continue }

                    // 定义原子更新闭包，通过引用操作数组 [3]
                    let step = { ni: Int64, nj: Int64, nk: Int64, nextT: Int64, prevC: Int64, prevT: Int64, limit: Int64 =>
                        let nextId = calcIdx(ni, nj, nk, nextT)
                        let arrival = prevT + weightMatrix[lastType][nextT]
                        let delay = if (arrival > limit) { arrival - limit } else { 0 }
                        let totalC = prevC + delay

                        // 更新最优成本路径
                        if (totalC < dp_Cost[nextId] || (totalC == dp_Cost[nextId] && arrival < dp_Time[nextId])) {
                            dp_Cost[nextId] = totalC; dp_Time[nextId] = arrival
                        }
                        // 更新最优时间路径
                        if (arrival < dp_Time_Alt[nextId] || (arrival == dp_Time_Alt[nextId] && totalC < dp_Cost_Alt[nextId])) {
                            dp_Cost_Alt[nextId] = totalC; dp_Time_Alt[nextId] = arrival
                        }
                    }

                    // 转移至三种机型
                    if (i < countL) { 
                        step(i + 1, j, k, 0, dp_Cost[currentId], dp_Time[currentId], dataL[i])
                        if (dp_Time_Alt[currentId] != dp_Time[currentId]) {
                            step(i + 1, j, k, 0, dp_Cost_Alt[currentId], dp_Time_Alt[currentId], dataL[i])
                        }
                    }
                    if (j < countM) { 
                        step(i, j + 1, k, 1, dp_Cost[currentId], dp_Time[currentId], dataM[j])
                        if (dp_Time_Alt[currentId] != dp_Time[currentId]) {
                            step(i, j + 1, k, 1, dp_Cost_Alt[currentId], dp_Time_Alt[currentId], dataM[j])
                        }
                    }
                    if (k < countH) { 
                        step(i, j, k + 1, 2, dp_Cost[currentId], dp_Time[currentId], dataH[k])
                        if (dp_Time_Alt[currentId] != dp_Time[currentId]) {
                            step(i, j, k + 1, 2, dp_Cost_Alt[currentId], dp_Time_Alt[currentId], dataH[k])
                        }
                    }
                }
            }
        }
    }

    // 5. 最终解提取
    var minFinalCost = INF
    let finalBase = calcIdx(countL, countM, countH, 0)
    for (offset in 0..3) {
        let idx = finalBase + offset
        if (dp_Cost[idx] < minFinalCost) { minFinalCost = dp_Cost[idx] }
        if (dp_Cost_Alt[idx] < minFinalCost) { minFinalCost = dp_Cost_Alt[idx] }
    }

    return minFinalCost
}
