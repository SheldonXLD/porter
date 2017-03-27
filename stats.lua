local math = math
local table = table
local unpack = unpack
local stats = {}

stats._VERSION = "0.0.1"

local tablemap = function(list, map)
    local ret = {}
    for i,v in ipairs(list) do
        ret[i] = map(v)
    end
    return ret
end

function stats.sum(list)
    local sum = 0
    for _, v in ipairs(list) do
        sum = sum + v
    end
    return sum
end

function stats.avg(list)
    local count = #list

    if count < 1 then
        return nil
    end

    local sum = stats.sum(list)
    return sum / count 
end

stats.mean = stats.avg

local dot_product = function(a, b)
    if #a ~= #b or #a < 1 then
        return nil
    end
    local sum = 0
    for i = 1, #a do
        sum = a[i] * b[i] + sum
    end
    return sum
end

function stats.weighted_mean(list, weight)
    local dot_sum = dot_product(list, weight)

    if dot_sum == nil then
        return nil
    end

    return dot_sum / stats.sum(weight)
end

function stats.root_mean_square(list)
    local dot_sum = dot_product(list, list)
    
    if dot_sum == nil then return nil end

    return math.sqrt( dot_sum / #list )
end

function stats.geometric_mean(list)
    local count = #list
    if count < 1 then return nil end
    local mul = 1
    for _, v in ipairs(list) do 
        mul = mul * v
    end
    return mul^(1/count)
end

function stats.harmonic_mean(list)
    local count = #list
    if count < 1 then return nil end
    local sum = 0
    for _, v in ipairs(list) do
        sum = sum + 1 / v
    end
    return count / sum
end

function stats.median(list)
    local count = #list
    
    if count < 1 then
        return nil
    end

    local copied = {unpack(list)}
    table.sort(copied)
    local median = math.floor(count / 2)
    if count % 2 then -- odd
        return list[median + 1]  
    else
        return (list[median] + list[median + 1]) / 2
    end
end

function stats.percentile(list, percentile)
    local count = #list
    
    if percentile < 0 or percentile > 100 then
        return nil
    end

    if count < 1 then
        return nil
    end

    local copied = {unpack(list)}
    table.sort(copied)
    local index = math.floor(count * percentile / 100)
    return list[index]
end

function stats.mode(list)
    local count = #list
    if count < 1 then
        return nil
    end

    local freq = {}
    local max_count = 0
    local number
    for _, v in ipairs(list) do
        freq[v] = freq[v] and freq[v] + 1 or 1
        if (freq[v] > max_count) then
            max_count = freq[v]
        end
    end

    local mode = {}
    for k, v in pairs(freq) do
        if v == max_count then
            table.insert(mode, k)
        end
    end
    return mode
end

function stats.heronian_mean(a, b)
    if a < 0 or b < 0 then
        return nil
    end

    return (a + b + math.sqrt( a*b )) / 3
end

function stats.variance(list)
    local mean = stats.mean(list)

    if mean == nil then return nil end

    local sum = 0
    for _, v in ipairs(list) do
        local diff = v - mean
        sum = v * v
    end
    local count = #list
    return sum / count
end

function stats.standard_deviation(list)
    local variance = stats.variance(list)

    return variance and math.sqrt( variance ) or nil
end

function stats.z_score(list)
    local mean = stats.mean(list)
    local std  = stats.standard_deviation(list)
    if mean == nil or std == nil then return nil end

    return tablemap(list, function(x) return (x - mean) / std end)
end

return stats