module DKL

export dkl, jsd

import JLab
import QuantumToolbox as qt


function st2dist(st::qt.Qobj)::AbstractVector{Float64}
    return abs.(st.data).^2
end

function dkl(p::AbstractVector{Float64}, q::AbstractVector{Float64})::Float64
    term(pp, qp) = pp == 0 ? 0 : pp * log(pp / qp)
    return sum(term.(p, q))
end

dkl(st1::qt.Qobj, st2::qt.Qobj) = dkl(st2dist(st1), st2dist(st2))
dkl(st1::AbstractVector{Float64}, st2::qt.Qobj) = dkl(st1, st2dist(st2))
dkl(st1::qt.Qobj, st2::AbstractVector{Float64}) = dkl(st2dist(st1), st2)


function jsd(p::AbstractVector{Float64}, q::AbstractVector{Float64})::Float64
    return (dkl(p, (p + q) / 2) + dkl(q, (p + q) / 2)) / 2
end

jsd(st1::qt.Qobj, st2::qt.Qobj) = jsd(st2dist(st1), st2dist(st2))
jsd(st1::AbstractVector{Float64}, st2::qt.Qobj) = jsd(st1, st2dist(st2))
jsd(st1::qt.Qobj, st2::AbstractVector{Float64}) = jsd(st2dist(st1), st2)

end
