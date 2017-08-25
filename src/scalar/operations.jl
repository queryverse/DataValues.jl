function Base.DateTime{T<:AbstractString}(dt::DataValue{T}, format::AbstractString; locale::Base.Dates.Locale=Base.Dates.ENGLISH)
    isnull(dt) ? DataValue{DateTime}() : DataValue{DateTime}(DateTime(get(dt), format, locale=locale))
end

function Base.Date{T<:AbstractString}(dt::DataValue{T}, format::AbstractString; locale::Base.Dates.Locale=Base.Dates.ENGLISH)
    isnull(dt) ? DataValue{Date}() : DataValue{Date}(Date(get(dt), format, locale=locale))
end

for f in (:(Base.abs), :(Base.abs2), :(Base.conj),:(Base.sign))
    @eval begin
        function $f{T}(a::DataValue{T})
            if isnull(a)
                DataValue{T}()
            else
                DataValue($f(get(a)))
            end
        end
    end
end


for f in (:(Base.acos), :(Base.acosh), :(Base.asin), :(Base.asinh),
        :(Base.atan), :(Base.atanh), :(Base.sin), :(Base.sinh), :(Base.cos),
        :(Base.cosh), :(Base.tan), :(Base.tanh), :(Base.exp), :(Base.exp2),
        :(Base.expm1), :(Base.log), :(Base.log10), :(Base.log1p),
        :(Base.log2), :(Base.exponent), :(Base.sqrt), :(Base.gamma),
        :(Base.lgamma), :(Base.digamma), :(Base.erf), :(Base.erfc),
        :(Base.Dates.value))
    @eval begin
        function $f{T}(a::DataValue{T})
            if isnull(a)
                DataValue{Float64}()
            else
                DataValue{Float64}($f(get(a)))
            end
        end
    end
end

for op in (:+, :-, :*, :/, :%, :&, :|, :^, :<<, :>>, :div, :mod, :fld,
        :min, :max)
    @eval begin
        import Base.$(op)
        function $op{T1,T2}(a::DataValue{T1},b::DataValue{T2})
            nonnull = Base.hasvalue(a) && Base.hasvalue(b)
            S = Base.Broadcast._nullable_eltype($op,a,b)
            if nonnull
                return DataValue($op(get(a), get(b)))
            else
                return DataValue{Base.nullable_returntype(S)}()
            end            
        end
        
        function $op{T1,T2}(a::DataValue{T1},b::T2)
            nonnull = Base.hasvalue(a)
            S = Base.Broadcast._nullable_eltype($op,a,b)
            if nonnull
                return DataValue($op(get(a), b))
            else
                return DataValue{Base.nullable_returntype(S)}()
            end
        end
        
        function $op{T1,T2}(a::T1,b::DataValue{T2})
            nonnull = Base.hasvalue(b)
            S = Base.Broadcast._nullable_eltype($op,a,b)
            if nonnull
                return DataValue($op(a, get(b)))
            else
                return DataValue{Base.nullable_returntype(S)}()
            end
        end
    end
end
