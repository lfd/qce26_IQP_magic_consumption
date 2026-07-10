export quantum_line, quantum_path, norm_factor

import QuantumToolbox as qt

function quantum_line(start_state, end_state)
    braket_end_start = end_state' * start_state
    phase = braket_end_start == 0 ? 1 : braket_end_start / abs(braket_end_start)
    norm_factor(t) = 1 / sqrt(1 - 2 * t * (1 - t) * (1 - abs(braket_end_start)))

    return t -> norm_factor(t) * ((1 - t) * start_state + phase * t * end_state)
end

function norm_factor(start_state, end_state, t)
    braket_end_start = end_state' * start_state

    return 1 / sqrt(1 - 2 * t * (1 - t) * (1 - abs(braket_end_start)))
end


function quantum_path(qls) 
    
    return t -> begin
        T = t * length(qls)
    
        if t == 1
            return qls[end](1)
        else
            return qls[convert(UInt, div(T, 1) + 1)](T % 1)
        end
    end
      
end


