module BinDistLearning

export exp1, circDklFuncGen, minSre, maxSre

import JLab
import QuantumToolbox as qt
import Distributions as dis
using Optim
using DataFrames
using ProgressBars

include("IQP.jl")
include("DKL.jl")

function phaseFreeState(st)
    return qt.normalize(qt.Qobj(abs.(st.data), dims=st.dimensions))
end

function minSre(st)
    pfSt = phaseFreeState(st)
    f(ths) = begin
        return JLab.sre(qt.Qobj(exp.(1im .* ths) .* pfSt.data, dims=st.dimensions), 2)
    end
    res = optimize(f, rand(length(st.data)) .* 2pi)
    return res.minimum
end

function maxSre(st)
    pfSt = phaseFreeState(st)
    f(ths) = begin
        return -1 * JLab.sre(qt.Qobj(exp.(1im .* ths) .* pfSt.data, dims=st.dimensions), 2)
    end
    res = optimize(f, rand(length(st.data)) .* 2pi)
    return -1 * res.minimum
end       
      

function circDklFuncGen(circ, targetPdf, inputState, div)
    return (x) -> begin
        JLab.Circuits.updateParams!(circ, x)
        st = JLab.Circuits.run(circ, inputState)
        return div(st, targetPdf)
    end
end


function exp3(n, gammas, nshots)
    data = []

    pbar = ProgressBar(total = length(gammas) * nshots)
    Threads.@threads for g in gammas
        for shot in 1:nshots
            circ = IQP.iqpCirc6n(n, g)

            binDists = [dis.Binomial(2^n -1, rand()) for _ in 1:4]

            targetPdf = sum([dis.pdf(binDist) for binDist in binDists]) / length(binDists)

            ket0 = JLab.b(join(fill('0', n)))

            f = circDklFuncGen(circ, targetPdf, ket0, DKL.jsd)

            JLab.Circuits.updateParams!(circ, rand(JLab.Circuits.numParams(circ)) .* 2pi)
            res = optimize(f, rand(JLab.Circuits.numParams(circ)))
            JLab.Circuits.updateParams!(circ, res.minimizer)
            finalSt = JLab.Circuits.run(circ, ket0)

            ngates = length(circ.gates)
            sres = zeros(ngates)
            overlaps = zeros(ngates)
            phFrOverlaps = zeros(ngates)
            nGateQubits = zeros(Int, ngates)
            dkls = zeros(ngates)
            jsds = zeros(ngates)

            st = copy(ket0)
            targetSt = qt.normalize(qt.Qobj(sqrt.(targetPdf), dims=st.dims))
            phFrTargetSt = phaseFreeState(st)

            for (i, g) in enumerate(circ.gates)
                op = JLab.Gates.resolveGate(g)
                st = JLab.Gates.expandOp(op, dims=Vector(st.dims[1]), targets=vcat(g.controls, g.targets)) * st

                sres[i] = JLab.sre(st, 2)
                overlaps[i] = abs(targetSt' * st)^2
                phFrOverlaps[i] = abs(phFrTargetSt' * phaseFreeState(st))^2
                dkls[i] = DKL.dkl(st, targetPdf)
                jsds[i] = DKL.jsd(st, targetPdf)
                nGateQubits[i] = length(g.controls) + length(g.targets)

            end
            data = append!(DataFrame(
                sre=sres,
                overlap=overlaps,
                dkl=dkls,
                jsd=jsds,
                phFrOverlap=phFrOverlaps,
                gamma=g,
                shot=shot,
                circDepth = 1:length(circ.gates),
                nGateQubits = nGateQubits),
                data)
            update(pbar)
        end
    end 
    
    return data
end
end
