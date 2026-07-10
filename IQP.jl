module IQP

export Rx, Rxn, GRxn, Rz, Rzn, GRzn, GH, iqpCirc1

import JLab

import QuantumToolbox as qt
import Permutations as Perms

Rz(theta) = JLab.RU(JLab.Z, theta)
Rzn(n) = (theta) -> qt.tensor(fill(Rz(theta), n)...)

GRzn(targets, theta=0., controls=nothing) = JLab.Gate(
    Rzn(length(targets)),
    targets=targets,
    controls=controls,
    params=[theta],
    name="Rxn"
)

Rx(theta) = JLab.RU(JLab.X, theta)
Rxn(n) = (theta) -> qt.tensor(fill(Rx(theta), n)...)

GRxn(targets, theta=0., controls=nothing) = JLab.Gate(
    Rxn(length(targets)),
    targets=targets,
    controls=controls,
    params=[theta],
    name="Rxn"
)

I = qt.eye(2)

RI(theta) = JLab.RU(I, theta)
RIn(n) = (theta) -> qt.tensor(fill(RI(theta), n)...)

GRIn(targets, theta=0., controls=nothing) = JLab.Gate(
    RIn(length(targets)),
    targets=targets,
    controls=controls,
    params=[theta],
    name="Rxn"
)

GRCZHTr(target, control, theta) = JLab.Gate(
    (theta) -> JLab.RU((qt.tensor(I, JLab.X) - qt.tensor(JLab.X, JLab.X)) / 2, theta),
    targets=[control,target],
    params=[theta],
    name="GRCZHTr"
)

GH(target) = JLab.Gates.Gate(JLab.H, targets=[target], name="H")


function iqpCirc6n(n, gamma)::JLab.Circuits.Circuit
    circ = JLab.Circuits.Circuit()

    gates = []
    for i in 1:n
        push!(gates, GRxn([i]))
    end
    
    for j in 1:n
        for i in (j + 1):n
            if rand() <= gamma * log(n) / n
                if i != j
                    if rand() > 0.5
                        push!(gates, GRxn([i, j]))
                    else
                        target, control = rand() > 0.5 ? (i, j) : (j,i)
                        push!(gates, GRCZHTr(control, target, 0.))
                    end
                end
            end
        end
    end

    for i in Perms.RandomPermutation(length(gates))
        JLab.Circuits.addGate!(circ, gates[i])
    end

    return circ
end
end
