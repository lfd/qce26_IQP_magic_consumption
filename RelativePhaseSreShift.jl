module RelativePhaseSreShift

export exp1, exp2

import JLab
using DataFrames
import QuantumToolbox as qt
using LinearAlgebra
#using ProgressBars
using ProgressMeter
using Optim
import Distributions as dis

include("IQP.jl")
include("DKL.jl")

function phaseFreeState(st)
    return qt.normalize(qt.Qobj(abs.(st.data), dims=st.dimensions))
end

function circDklFuncGen(circ, targetPdf, inputState, div)
    return (x) -> begin
        JLab.Circuits.updateParams!(circ, x)
        st = JLab.Circuits.run(circ, inputState)
        return div(st, targetPdf)
    end
end


function exp2(n, gamma, nshots, nCircs)
    data = []

    pbar = Progress(nshots * nCircs * floor(Int, gamma * n * log(n)))

    dataLock = ReentrantLock()

    Threads.@threads for c in 1:nCircs
        circ = IQP.iqpCirc6n(n, gamma)

        binDists = [dis.Binomial(2^n -1, rand()) for _ in 1:4]

        targetPdf = sum([dis.pdf(binDist) for binDist in binDists]) / length(binDists)

        ket0 = JLab.b(join(fill('0', n)))

        f = circDklFuncGen(circ, targetPdf, ket0, DKL.jsd)

        JLab.Circuits.updateParams!(circ, rand(JLab.Circuits.numParams(circ)) .* 2pi)
        res = optimize(f, rand(JLab.Circuits.numParams(circ)))
        JLab.Circuits.updateParams!(circ, res.minimizer)
        finalSt = JLab.Circuits.run(circ, ket0)

        ngates = length(circ.gates)

        st = copy(ket0)
     
        for i in 1:length(circ.gates)
            g = circ.gates[i]
            op = JLab.Gates.resolveGate(g)
            st = JLab.Gates.expandOp(op, dims=Vector(st.dims[1]), targets=vcat(g.controls, g.targets)) * st
            phFrSt = phaseFreeState(st)

            origSre = JLab.sre(st, 2)

            sres = zeros(nshots)
            for shot in 1:nshots 
                phases = exp.(1im .* rand(2^n) .* 2pi)
                phSt = qt.Qobj(phases .* phFrSt.data, dims=st.dimensions)

                sres[shot] = JLab.sre(phSt, 2)
                next!(pbar)
            end

            @lock dataLock data = append!(
                DataFrame(
                    sre = vcat([origSre], sres),
                    type = vcat(["orig"], fill("sampled", nshots)),
                    circDepth = i,
                    circ = c
                ),
                data
            )
                

        end
    end
    return data
end


end
