package ict
import std.collection.*

// 1. 使用 struct 封装汉字处理，利用 toRuneArray 确保索引准确 [3][5]
struct VerseText {
    let characters: Array<Rune>
    let length: Int64

    public init(raw: String) {
        this.characters = raw.toRuneArray()
        this.length = characters.size
    }

    // 利用重载运算符简化子串提取逻辑 [5]
    operator func [](range: Range<Int64>): String {
        return String(characters[range])
    }
}

// 2. 单词信息结构体，脱敏字段名称
class WordEntry {
    let key: Int64
    let content: String
    let charCount: Int64
    
    init(key: Int64, content: String, charCount: Int64) {
        this.key = key
        this.content = content
        this.charCount = charCount
    }
}

func solve(verse: String, words: Array<String>): Int64 {
    let target = VerseText(verse)
    let totalLen = target.length
    if (totalLen == 0) { return 0 }

    // 3. 词典预处理：去重并过滤无效长度单词 [3]
    let dictMap = HashMap<String, Int64>()
    let pool = ArrayList<WordEntry>()
    var idGenerator: Int64 = 0

    for (w in words) {
        if (w.isEmpty()) { continue }
        if (!dictMap.contains(w)) {
            dictMap[w] = idGenerator
            let r = w.toRuneArray()
            if (r.size <= totalLen) {
                pool.add(WordEntry(idGenerator, w, r.size))
            }
            idGenerator += 1
        }
    }
    
    let uniqueSize = idGenerator
    // 状态记录：[最小单词种类, 达成该种类的路径数]
    var finalResult = [Int64.Max, 0]

    // 4. 定义递归搜索函数，显式标注返回类型 : Unit [6]
    func search(pos: Int64, currentPath: ArrayList<Int64>): Unit {
        if (pos == totalLen) {
            // 统计路径中不重复单词的数量
            let visited = Array<Bool>(uniqueSize, { _ => false }) 
            var distCount: Int64 = 0
            for (id in currentPath) {
                if (!visited[id]) {
                    visited[id] = true
                    distCount += 1
                }
            }

            // 更新全局最优解
            if (distCount < finalResult[0]) {
                finalResult[0] = distCount
                finalResult[1] = 1
            } else if (distCount == finalResult[0]) {
                finalResult[1] += 1
            }
            return
        }

        for (entry in pool) {
            let nextPos = pos + entry.charCount
            if (nextPos <= totalLen && target[pos..nextPos] == entry.content) {
                currentPath.add(entry.key)
                search(nextPos, currentPath)
                // 回溯：移除最后加入的元素 [4]
                currentPath.remove(currentPath.size - 1..currentPath.size) 
            }
        }
    }

    search(0, ArrayList<Int64>())

    return if (finalResult[0] == Int64.Max) { 0 } else { finalResult[1] }
}
