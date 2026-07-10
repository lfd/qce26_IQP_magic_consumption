module Permutations
export  permutationCircuit

import Permutations as Perms
import ..Circuits
import ..Gates
import ..Unitaries

function cycleTo2CycleProd(cycle::AbstractVector{Int})
    return reverse([cycle[[i,(i % length(cycle) + 1)]] for i in 2:(length(cycle))])
end

function permutation2CycleProd(permutation::Perms.Permutation)
    cycles = filter((c) -> length(c) > 1, Perms.cycles(permutation))

    twoCycleProd = []
    
    for cyc in cycles
        for c2 in cycleTo2CycleProd(cyc)  
            push!(twoCycleProd, c2)
        end
    end

    return twoCycleProd
end

function permutationCircuit(permutation::Perms.Permutation)
    circ = Circuits.Circuit()
    
    for swap in permutation2CycleProd(permutation)
        Circuits.addGate!(circ, Gates.Gate(Unitaries.Swap, targets=swap))
    end

    return circ
end

end

