import Random

include("BinDistLearning.jl")

function main()
    seed = 1783464238
    Random.seed!(seed)

    n = 7

    data = BinDistLearning.exp3(n, 1:0.4:(n / log(n)), 500)

    return data
end
