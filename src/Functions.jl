######################################################################
# General purpose functionized patterns
# -----
# Licensed under MIT License.
import Base.Threads: @threads

export isinstanceof
isinstanceof(x::T2, ::Type{T1}) where {T1, T2<:T1} = true
isinstanceof(_, _) = false

export hassignature
function hassignature(fn, argtypes::Type...)
    sig = Tuple{typeof(fn), argtypes...}
    for method ∈ methods(fn)
        if sig <: method.sig
            return true
        end
    end
    return false
end

export isiterable
@generated function isiterable(x)
    if hassignature(iterate, x)
        :(true)
    else
        :(false)
    end
end

export curry
curry(fn, curryargs...; kwcurryargs...) = (moreargs...; kwargs...) -> fn(curryargs..., moreargs...; kwcurryargs..., kwargs...)

export indexof
indexof(arr, elem; by = identity, offset::Integer = 1, strict::Bool = false) = findnext(curr->strict ? by(curr) === elem : by(curr) == elem, arr, offset)

export shift!
function shift!(arr)
    item = arr[1]
    deleteat!(arr, 1)
    item
end

export unshift!
function unshift!(arr, value)
    insert!(arr, 1, value)
    arr
end

export hflip!
function hflip!(arr::AbstractArray)
    rows, cols = size(arr)
    if cols < 2 return arr end
    
    @threads for row ∈ 1:rows
        @threads for col ∈ 1:(cols÷2)
            tmp = arr[row, col]
            arr[row, col] = arr[row, cols-(col-1)]
            arr[row, cols-(col-1)] = tmp
        end
    end
    arr
end

export vflip!
function vflip!(arr::AbstractArray)
    rows, cols = size(arr)
    if rows < 2 return arr end
    
    @threads for col ∈ 1:cols
        @threads for row ∈ 1:(rows÷2)
            tmp = arr[row, col]
            arr[row, col] = arr[rows-(row-1), col]
            arr[rows-(row-1), col] = tmp
        end
    end
    arr
end


is_call_expr(_) = false
is_call_expr(expr::Expr) = expr.head === :call
is_call_assignment(expr::Expr) = expr.head === :(=) && is_call_expr(expr.args[2])
