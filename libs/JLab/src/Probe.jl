module RandProbe
export probeRandArea

import QuantumToolbox as qt

using ..Unitaries

function probeRandArea(s::qt.Qobj ; radius = 0.1, nSamples = 1000)
    function rand_R()
        (theta_x, theta_y, theta_z) = radius .* (-0.5 .+ rand(3))
        
        return RU(qt.tensor(fill(X, length(s.dims[1]))...), theta_x) *
               RU(qt.tensor(fill(Y, length(s.dims[1]))...), theta_y) *
               RU(qt.tensor(fill(Z, length(s.dims[1]))...), theta_z)
    end
 
    return [rand_R() * s for _ in 1:nSamples] 
end

end
