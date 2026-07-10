export b, rand_b, performMeasurement

import QuantumToolbox as qt

function b(bs) 
    return qt.tensor([c == '0' ? qt.basis(2,0) : qt.basis(2,1) for c in bs]...) 
end

function rand_b(n)
    bs = rand(['0', '1'], n)

    return (b(bs), bs)
end

K1 = b("1") * b("1")'
K0 = b("0") * b("0")'

function expandKrausOp(K, i, n)
    return qt.tensor(fill(qt.eye(2), i - 1)..., K, fill(qt.eye(2), n - i)...)
end

function applyMeasurementOp(st, K)
    return K * st / qt.tr(K * st * st' * K')
end

function performMeasurement(st, i, n)
    p1 = real(qt.tr(expandKrausOp(K1, i, n) * st * st' * expandKrausOp(K1, i, n)'))

    if rand() > p1 
        return (0, applyMeasurementOp(st, expandKrausOp(K0, i, n))) 
    else
        return (1, applyMeasurementOp(st, expandKrausOp(K1, i, n)))
    end
end
