module Circuits
export Circuit,
       addGate!,
       updateParams!

import QuantumToolbox as qt

import ..Gates

mutable struct Circuit
    gates::Vector{Gates.Gate}

    Circuit() = new([])
end

function addGate!(circuit::Circuit, gate::Gates.Gate)
    push!(circuit.gates, gate)
end

function run(circuit::Circuit, state::qt.Qobj)::qt.Qobj
    st = copy(state)
    
    for g in circuit.gates
        op = Gates.resolveGate(g)
        st = Gates.expandOp(op, dims=Vector(st.dims[1]), targets=vcat(g.controls, g.targets)) * st
    end
    
    return st
end

function updateParams!(circuit::Circuit, params::Vector{Float64})
    consumed = 0
    for g in circuit.gates
        if length(g.params) > 0
            g.params = params[(consumed + 1):(consumed + length(g.params))]
            consumed += length(g.params)
        end
    end
end

function numParams(circuit::Circuit)
    num = 0
    for g in circuit.gates
        num += length(g.params)
    end

    return num
end

end
