module Ansatz

import QuantumToolbox as qt

import ..Circuits
import ..Gates
import ..Unitaries

function qft(n)
    circ = Circuits.Circuit()

    for i in 1:n
        Circuits.addGate!(circ, Gates.Gate(Unitaries.H, targets=[i], name="H_$i"))

        if i < n
            for k in 2:(n + 1 - i)
                Circuits.addGate!(
                    circ,
                    Gates.Gate(
                        Unitaries.Phase(2 * pi / 2^k),
                        targets=[i],
                        controls=[i + k - 1],
                        name="CPhase_$i(k=$(k))"
                    )
                )
            end
        end
    end

    for i in 1:Int(floor(n / 2))
        Circuits.addGate!(circ, Gates.Gate(Unitaries.Swap, targets=[i, n - i + 1], name="SWAP"))
    end

    return circ
end

end
