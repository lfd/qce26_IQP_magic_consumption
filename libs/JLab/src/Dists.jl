module Dists
export wootters,
       fubiniStudy

import QuantumToolbox as qt

function wootters(lambda::Real, psi_a::qt.Qobj, psi_b::qt.Qobj)::Real
    @assert qt.isket(psi_a) "psi_a has to be a ket"
    @assert qt.isket(psi_b) "psi_b has to be a ket"

    return lambda * acos(min(1, abs(psi_a' * psi_b)))
end

function fubiniStudy(lambda::Real, psi_a::qt.Qobj, psi_b::qt.Qobj)::Real
    @assert qt.isket(psi_a) "psi_a has to be a ket"
    @assert qt.isket(psi_b) "psi_b has to be a ket"

    return lambda * sqrt(1 - abs2(psi_a' * psi_b))
end

end
