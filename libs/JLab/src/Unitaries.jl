module Unitaries
export H,
       X,
       Y,
       Z,
       RU,
       R,
       randBlockDiagonal

import QuantumToolbox as qt
import BlockDiagonals as bd

H = qt.Qobj([1 1; 1 -1] / sqrt(2))
X = qt.sigmax()
Y = qt.sigmay()
Z = qt.sigmaz()

Phase(theta) = qt.Qobj([
    1 0
    0 exp(1im * theta)
])

Swap = qt.Qobj([
    1 0 0 0
    0 0 1 0
    0 1 0 0
    0 0 0 1
], dims=[2, 2])

RU(U, theta) = exp(-1im * theta * U)

function R(theta_x::Real, theta_y::Real, theta_z::Real)::qt.Qobj
    return RU(X, theta_x) * RU(Y, theta_y) * RU(Z, theta_z)
end

function randBlockDiagonal(nBlocks, blockSize)
    return qt.Qobj(
        bd.BlockDiagonal([qt.rand_unitary(repeat([2], blockSize)).data for _ in 1:nBlocks]),
        dims=repeat([2], nBlocks * blockSize)
    ) 
end

end
