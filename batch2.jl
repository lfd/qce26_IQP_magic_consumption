import Random

include("RelativePhaseSreShift.jl")

function main()
    seed = 1783464238
    Random.seed!(seed)

    n = 7

    data = RelativePhaseSreShift.exp2(n, 1.5, 100, 50)

    return data
end
