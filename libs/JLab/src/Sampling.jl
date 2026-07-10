module Sampling
export sample, p, State, F, G, approxCTOverlap, blockDiagonalECSop

import QuantumToolbox as qt
import StatsBase as stat
import LinearAlgebra as lin

include("State.jl")

function sample(p, xs::String, n::Int)::String
    if length(xs) == n
        return xs
    end
    
    b = stat.sample(
        ["0", "1"],
        stat.Weights(lin.normalize([p(1:length(xs)+1, xs * c) for c in ["0", "1"]]))
    )
    return sample(p, xs * b, n)
end

function p(st::qt.Qobj, I::AbstractArray{Int}, y::String)
    return real(qt.expect(qt.ptrace(st, I), b(y) * b(y)'))
end

function approxCTOverlap(sampleS1, sampleS2, s1, s2, n, K)
    approxF = 0
    approxG = 0

    for _ in 1:K
        x1 = sampleS1()
        x2 = sampleS2()

        approxF += F(s2, s1, x1) 
        approxG += G(s2, s1, x2) 
    end
    approxF /= K
    approxG /= K
    
    return approxF + approxG
end

struct State
    amp::Function
    prob::Function

    function State(amp::Function)
        return new(amp, x -> abs2(amp(x)))
    end

    function State(s::qt.Qobj)
        return State(x -> b(x)' * s)
    end
end

struct BasisPreservingOp
    amp::Function
    basisMap::Function
    invBasisMap::Function
    dim::Int
end

struct ECSop
    a::Function
    b::Function
    r::Function
    c::Function 
    s::Int
    dim::Int
    target::Set{Int}

    function ECSop(
        a::Function,
        b::Function,
        r::Function,
        c::Function,
        s::Int,
        dim::Int,
        target::Set{Int}
    )
        return new(a, b, r, c, s, copy(dim), target)
    end

    function ECSop(
        a::Function,
        b::Function,
        r::Function,
        c::Function,
        s::Int,
        dim::Int,
        target::AbstractArray{Int}
    )
        return new(a, b, r, c, s, copy(dim), Set(target))
    end
end

function blockDiagonalECSop(nBlocks::Int, blockSize::Int, data)
    r = function(x, i) 
        iblock = x ÷ nBlocks 
        offset = iblock * 2^blockSize
        return offset + i
    end

    c = function(y, i)
        iblock = y ÷ nBlocks 
        offset = iblock * 2^blockSize
        return offset + i
    end

    return ECSop(
        function(x,i)
            return data[r(x,i),x+1]
        end,
        function(y,i)
            return data[y+1,c(y,i)]
        end,
        r,
        c,
        2^blockSize,
        blockSize * nBlocks,
        1:(blockSize * nBlocks)
    )
end

function expectECS(sampleS1, sampleS2, s1, s2, op::ECSop, K)
    val = 0

    for i in 1:op.s
        approxFi = 0
        approxGi = 0
        
        for _ in 1:K
            x1 = sampleS1()
            x2 = sampleS2()
            if abs(op.a(i, x1)) > 0
                y1 = op.r(i, x1)

                approxFi += Fi(s2, s1, x1, y1, op.a(i, x2)) 
            end

            if abs(op.a(i, x2)) > 0
                y2 = op.r(i, x2)
                
                xs = []
                for j in 1:op.s
                    if op.b(j, y2) == 0
                        continue
                    end
                    x = op.c(j, y2)

                    if op.a(i, x) == 0
                        continue
                    end

                    if op.r(j, x) != y2
                        continue
                    end

                    push!(xs, x)
                end
                approxGi += sum([Gi(s2, s1, x, y2, op.a(i, x)) for x in xs])
            end

        end

        approxFi /= K
        approxGi /= K

        val += approxFi + approxGi
    end

    return val
end

function apply(op::BasisPreservingOp, st::State)
    return State(x -> st.amp(op.invBasisMap(x)) * op.amp(op.invBasisMap(x)))
end

function apply(lhs::BasisPreservingOp, rhs::BasisPreservingOp)
    @assert lhs.dim == rhs.dim "dimensions of lhs and rhs dont match"

    return BasisPreservingOp(
    x -> lhs.amp(rhs.basisMap(x[1:lhs.dim])) * rhs.amp(x),
        lhs.basisMap ∘ rhs.basisMap,
        rhs.invBasisMap ∘ lhs.invBasisMap,
        lhs.dim
    )
end

function apply(op::ECSop, st::State)
    return State(
    x -> sum([ op.b(i, x) * st.amp(op.c(i, x))  for i in 1:op.s]) 
    )
end

bs2num(bs::String) = parse(Int, bs, base=2) 
num2bs(num::Int, n::Int) = lpad(string(num, base=2), n, "0") 

function apply(lhs::ECSop, rhs::ECSop)
    I = []

    rilir(il,ir,x) = lhs.r(il, rhs.r(ir, x)) 

    ciril(ir,il,y) = rhs.c(ir, lhs.c(il, y))
    
    riLUT(x) = begin 
        lut = Set{Int}()

        for (il, ir) in Iterators.product(1:lhs.s, 1:rhs.s)
            try
                y = bs2num(rilir(il, ir, x))
                push!(lut, y)
            catch e
                if e != "i2big"
                    throw(e)
                end
            end
        end

        return collect(lut)
    end

    ciLUT(y) = begin
        lut = Set{Int}()

        for (ir, il) in Iterators.product(1:rhs.s, 1:lhs.s)
            try
                x = bs2num(ciril(ir, il, y))
                push!(lut, x)
            catch e
                if e != "i2big"
                    throw(e)
                end
            end
        end
        
        return collect(lut)
    end

    Iyx(y, x) = begin
        I = []

        for il in 1:lhs.s
            for ir in 1:rhs.s
                if lhs.c(il, y) == rhs.r(ir, x)
                    push!(I, (il, ir))
                end
            end
        end
        return I
    end

    r(i, x) = begin
        lut = riLUT(x)
        if i > length(lut)
            #throw("i2big")
            return num2bs(0, lhs.dim)
        end

        return num2bs(lut[i], lhs.dim)
    end

    c(i, y) = begin
        lut = ciLUT(y)
        if i > length(lut)
            #throw("i2big")
            return num2bs(0, lhs.dim)
        end
        num2bs(lut[i], lhs.dim)
    end

    a(i, x) = begin
        rlut = riLUT(x)
        if i > length(rlut)
            return 0
        end

        y = num2bs(rlut[i], length(x))

        iyx = Iyx(y,x)
        if length(iyx) > 0
            return sum([lhs.b(il, y) * rhs.a(ir, x) for (il, ir) in iyx])
        end

        return 0
    end

    b(i, y) = begin
        clut = ciLUT(y)
        if i > length(clut)
            return 0
        end

        x = num2bs(clut[i], length(y))
        iyx = Iyx(y, x)

        if length(iyx) > 0
            return sum([lhs.b(il, y) * rhs.a(ir, x) for (il, ir) in iyx])
        end

        return 0
    end
   
    new_target = union(lhs.target, rhs.target) 

    new_s = 0
    if length(intersect(lhs.target, rhs.target)) == 0
        new_s = lhs.s + rhs.s
    else
        new_s = lhs.s * rhs.s
    end

    new_s = min(new_s, 2^length(new_target))

    return ECSop(
        a,
        b,
        r,
        c,
        new_s,
        max(lhs.dim, rhs.dim),
        new_target
    )
end


function tensor(ops::BasisPreservingOp...)
    if length(ops) == 1
        return ops[1]
    end

    x1(x) = x[1:ops[1].dim]
    x2(x) = x[(ops[1].dim + 1):(ops[1].dim + ops[2].dim)]

    newOp = BasisPreservingOp(
        x -> ops[1].amp(x1(x)) * ops[2].amp(x2(x)),
        x -> ops[1].basisMap(x1(x)) * ops[2].basisMap(x2(x)),
        x -> ops[1].invBasisMap(x1(x)) * ops[2].invBasisMap(x2(x)),
        ops[1].dim + ops[2].dim
    )

    return tensor(newOp, ops[3:end]...)
end


function control(c::Int, op::BasisPreservingOp)
    return BasisPreservingOp(
    x -> parse(Int, x[c]) * op.amp(x[setdiff(1:length(x), c)]),
        x -> parse(Int, x[c]) * op.basisMap(x[setdiff(1:length(x), c)]),
        x -> parse(Int, x[c]) * op.invBasisMap(x[setdiff(1:length(x), c)]),
        op.dim + 1
    )
end

function F(psi, phi, x)
    if psi.prob(x) <  phi.prob(x) 
        return 0
    end

    if psi.prob(x) == 0
        return 0
    end

    return phi.amp(x)' * psi.amp(x) / psi.prob(x)
end

function Fi(psi, phi, x, y, aix)
    if psi.prob(x) <  phi.prob(y) 
        return 0
    end

    if psi.prob(x) == 0
        return 0
    end

    return phi.amp(y)' * psi.amp(x) * aix / psi.prob(x)
end

function G(psi, phi, x)
    if psi.prob(x) >=  phi.prob(x) 
        return 0
    end

    return phi.amp(x)' * psi.amp(x) / phi.prob(x) 
end

function Gi(psi, phi, x, y, aix)
    if psi.prob(x) >=  phi.prob(y) 
        return 0
    end

    return phi.amp(y)' * psi.amp(x) * aix / phi.prob(y) 
end


end

