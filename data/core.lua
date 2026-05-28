-- iMorphTools Core - 命名空间和辅助函数

IMT = {}

-- 从定义列表自动生成映射表和排序列表
function BuildIDTable(defs)
    local tbl = {}
    local order = {}
    for _, def in ipairs(defs) do
        tbl[def[1]] = def[2]
        table.insert(order, def[1])
    end
    return tbl, order
end
