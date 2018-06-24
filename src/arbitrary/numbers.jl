using Random

function shrink(s::Integer)
    # Always shrink towards zero
    function cls(size, rng)
        if s == 0
            return s
        end
        
        magnitude = abs(s) 
        upper = s
        origin = 0

        if s > origin
            upper = upper-1
        else
            upper = upper+1
        end
       
        return rand(rng, upper:origin)
    end
    cls
end


function constrain(s::Integer) 
    function cls(size,rng)
        bound = s 
        if abs(s) > size
            if s > 0
                bound = size
            else
                bound = -size
            end
        end

        return shrink(bound)(size,rng)
    end
    cls
end

function constrain end

function constrain(s::UnitRange{<:Integer})
    function cls(size, rng)
        if length(s) <= size
            return s
        end
        
        current = UnitRange(constrain(s.start)(size,rng), constrain(s.stop)(size,rng))

        while length(current) > size
            current = UnitRange(constrain(current.start)(size, rng), constrain(current.stop)(size,rng))
        end

        return current
    end
    cls
end

function choose(::Type{X}, range) where X
    return (size_limit,rng)->rand(rng,range)
end

arbitrary(::Type{Integer}) = (size, rng) -> Integer(choose(Integer, -1337:1337)(size,rng))

arbitrary(::Type{Bool}) = (size, rng) -> arbitrary(Integer)(size,rng)%2 == 0 
shrink(b::Bool) = (size,rng)-> false

function arbitrary(::Type{Float64})
    function arb(size,rng)
        Float64(-1337+1337*2*rand(rng))
    end
    arb
end

struct IntegerIn{R}
    value::Integer
end

export IntegerIn

function arbitrary(::Type{IntegerIn{R}}) where R 
    function arb(size, rng)
        return IntegerIn{R}(choose(Integer, R)(size,rng))
    end
    arb
end
