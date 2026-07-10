export pauli_string, 
       Xi,
       sre,
       match_op

import QuantumToolbox as qt

function match_op(c)
    if c == 'I'
        return qt.eye(2)
    elseif c == 'X'
        return qt.sigmax()
    elseif c == 'Y'
        return qt.sigmay()
    elseif c == 'Z'
        return qt.sigmaz()
    end
end

function pauli_string(s)
    function match_op(c)
        if c == 'I'
            return qt.eye(2)
        elseif c == 'X'
            return qt.sigmax()
        elseif c == 'Y'
            return qt.sigmay()
        elseif c == 'Z'
            return qt.sigmaz()
        end
    end

    return qt.tensor([match_op(c) for c in s]...)
end

function Xi(state, P)
    n = length(state.dims[1])
    d = 2^n

    return qt.expect(P, state)^2 / d
end


function sre(state, alpha)
    n = length(state.dims[1])

    Xi_sum = 0

    for ps in Iterators.product(Iterators.repeated(['I', 'X', 'Y', 'Z'], n)...)
        Xi_sum += Xi(state, pauli_string(ps))^alpha
    end

    return abs(log(Xi_sum) / (1 - alpha) - log(2^n))
end

