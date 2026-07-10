module Gates
export Gate, resolveGate, expandOp

import QuantumToolbox as qt

mutable struct Gate 
    targets::Vector{Int}
    controls::Vector{Int}
    params::Vector{Float64}
    unitary::Function
    name::String

    function Gate(
        unitary::Union{qt.Qobj, Function};
        targets::Union{Vector{Int}, Nothing}=nothing,
        controls::Union{Vector{Int}, Nothing}=nothing,
        params::Union{Vector{Float64}, Nothing}=nothing,
        name::String=""
        )
        
        trgs = targets == nothing ? (1:(unitary(params...).dims |> length)) : targets
        ctrls = controls == nothing ? [] : controls
        ps = params == nothing ? [] : params

        @assert (vcat(trgs, ctrls) |> length) == (vcat(trgs, ctrls) |> unique |> length) "targets and controls cannot share qubits"
        
        if unitary isa Function
            return new(trgs, ctrls, ps, unitary, name)
        end
        return new(trgs, ctrls, ps, () -> unitary, name)
    end
end

function resolveGate(gate::Gate) 
    if gate.controls == []
        return gate.unitary(gate.params...)
    end

    zblock = zeros(2 * (gate.controls |> length), 2 * (gate.targets |> length))
    
    return qt.Qobj([
    qt.eye(2 * (gate.controls |> length)).data zblock 
    zblock                                     gate.unitary(gate.params...).data
    ],
    dims=qt.ProductDimensions(fill(2, (gate.controls |> length) + (gate.targets |> length))))
end

function expandOp(op::qt.Qobj; dims::Vector{Int}, targets::Vector{Int})
    N = length(dims)
    new_order = zeros(Int, N)

    for (i, t) in enumerate(targets)
        new_order[t] = i
    end

    rest_pos = [q for q in 1:N if new_order[q] == 0]
    rest_qubits = length(targets)+1:N

    for (i, ind) in enumerate(rest_pos)
        new_order[ind] = rest_qubits[i]
    end

    id_list = [qt.eye(dims[i]) for i in rest_pos]

    return qt.permute(qt.tensor(op, id_list...), new_order)
end

end
