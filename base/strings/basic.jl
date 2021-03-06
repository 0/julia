# This file is a part of Julia. License is MIT: http://julialang.org/license

## core string functions ##

endof(s::AbstractString) = error("you must implement endof(", typeof(s), ")")
next(s::AbstractString, i::Int) = error("you must implement next(", typeof(s), ",Int)")
next(s::DirectIndexString, i::Int) = (s[i],i+1)
next(s::AbstractString, i::Integer) = next(s,Int(i))

string() = ""
string(s::AbstractString) = s

"""
    String(s::AbstractString)

Convert a string to a contiguous byte array representation encoded as UTF-8 bytes.
This representation is often appropriate for passing strings to C.
"""
String(s::AbstractString) = print_to_string(s)
String(s::String) = s

# String constructor docstring from boot.jl, workaround for #16730
# and the unavailability of @doc in boot.jl context.
"""
    String(v::Vector{UInt8})

Create a new `String` from a vector `v` of bytes containing
UTF-8 encoded characters.   This function takes "ownership" of
the array, which means that you should not subsequently modify
`v` (since strings are supposed to be immutable in Julia) for
as long as the string exists.

If you need to subsequently modify `v`, use `String(copy(v))` instead.
"""
String(v::Array{UInt8,1})


"""
    unsafe_string(p::Ptr{UInt8}, [length::Integer])

Copy a string from the address of a C-style (NUL-terminated) string encoded as UTF-8.
(The pointer can be safely freed afterwards.) If `length` is specified
(the length of the data in bytes), the string does not have to be NUL-terminated.

This function is labelled "unsafe" because it will crash if `p` is not
a valid memory address to data of the requested length.

See also [`unsafe_wrap(String, p, [length])`](:func:`unsafe_wrap`), which takes a pointer
and wraps a string object around it without making a copy.
"""
function unsafe_string(p::Union{Ptr{UInt8},Ptr{Int8}}, len::Integer)
    p == C_NULL && throw(ArgumentError("cannot convert NULL to string"))
    ccall(:jl_pchar_to_string, Ref{String}, (Ptr{UInt8},Int), p, len)
end
function unsafe_string(p::Union{Ptr{UInt8},Ptr{Int8}})
    p == C_NULL && throw(ArgumentError("cannot convert NULL to string"))
    ccall(:jl_cstr_to_string, Ref{String}, (Ptr{UInt8},), p)
end

convert(::Type{Vector{UInt8}}, s::AbstractString) = String(s).data
convert(::Type{Array{UInt8}}, s::AbstractString) = String(s).data
convert(::Type{String}, s::AbstractString) = String(s)
convert(::Type{Vector{Char}}, s::AbstractString) = collect(s)
convert(::Type{Symbol}, s::AbstractString) = Symbol(s)

## generic supplied functions ##

start(s::AbstractString) = 1
done(s::AbstractString,i) = (i > endof(s))
getindex(s::AbstractString, i::Int) = next(s,i)[1]
getindex(s::AbstractString, i::Integer) = s[Int(i)]
getindex{T<:Integer}(s::AbstractString, r::UnitRange{T}) = s[Int(first(r)):Int(last(r))]
# TODO: handle other ranges with stride ±1 specially?
getindex(s::AbstractString, v::AbstractVector) =
    sprint(length(v), io->(for i in v; write(io,s[i]) end))

Symbol(s::AbstractString) = Symbol(String(s))

sizeof(s::AbstractString) = error("type $(typeof(s)) has no canonical binary representation")

eltype{T<:AbstractString}(::Type{T}) = Char

(*)(s1::AbstractString, ss::AbstractString...) = string(s1, ss...)
(.*){T<:AbstractString}(v::Vector{T},s::AbstractString) = [i*s for i in v]
(.*){T<:AbstractString}(s::AbstractString,v::Vector{T}) = [s*i for i in v]

length(s::DirectIndexString) = endof(s)
function length(s::AbstractString)
    i = start(s)
    if done(s,i)
        return 0
    end
    n = 1
    while true
        c, j = next(s,i)
        if done(s,j)
            return n
        end
        n += 1
        i = j
    end
end

## string comparison functions ##

function cmp(a::AbstractString, b::AbstractString)
    if a === b
        return 0
    end
    i = start(a)
    j = start(b)
    while !done(a,i) && !done(b,i)
        c, i = next(a,i)
        d, j = next(b,j)
        if c != d
            return c < d ? -1 : +1
        end
    end
    done(a,i) && !done(b,j) ? -1 :
    !done(a,i) && done(b,j) ? +1 : 0
end

==(a::AbstractString, b::AbstractString) = cmp(a,b) == 0
isless(a::AbstractString, b::AbstractString) = cmp(a,b) < 0

# faster comparisons for byte strings and symbols

cmp(a::String, b::String) = lexcmp(a.data, b.data)
cmp(a::Symbol, b::Symbol) = Int(sign(ccall(:strcmp, Int32, (Cstring, Cstring), a, b)))

==(a::String, b::String) =
    (len = length(a.data)) == length(b.data) &&
    ccall(:memcmp, Int32, (Ptr{UInt8}, Ptr{UInt8}, UInt), a.data, b.data, len) == 0
isless(a::Symbol, b::Symbol) = cmp(a,b) < 0

## Generic validation functions ##

isvalid(s::DirectIndexString, i::Integer) = (start(s) <= i <= endof(s))
function isvalid(s::AbstractString, i::Integer)
    i < 1 && return false
    done(s,i) && return false
    try
        next(s,i)
        true
    catch
        false
    end
end

## Generic indexing functions ##

prevind(s::DirectIndexString, i::Integer) = Int(i)-1
prevind(s::AbstractArray    , i::Integer) = Int(i)-1
nextind(s::DirectIndexString, i::Integer) = Int(i)+1
nextind(s::AbstractArray    , i::Integer) = Int(i)+1

function prevind(s::String, i::Integer)
    j = Int(i)
    e = endof(s.data)
    if j > e
        return endof(s)
    end
    j -= 1
    while j > 0 && is_valid_continuation(s.data[j])
        j -= 1
    end
    j
end

function nextind(s::String, i::Integer)
    j = Int(i)
    if j < 1
        return 1
    end
    e = endof(s.data)
    j += 1
    while j <= e && is_valid_continuation(s.data[j])
        j += 1
    end
    j
end

function prevind(s::AbstractString, i::Integer)
    e = endof(s)
    if i > e
        return e
    end
    j = Int(i)-1
    while j >= 1
        if isvalid(s,j)
            return j
        end
        j -= 1
    end
    return 0 # out of range
end

function nextind(s::AbstractString, i::Integer)
    e = endof(s)
    if i < 1
        return 1
    end
    if i > e
        return Int(i)+1
    end
    for j = Int(i)+1:e
        if isvalid(s,j)
            return j
        end
    end
    next(s,e)[2] # out of range
end

checkbounds(s::AbstractString, i::Integer) = start(s) <= i <= endof(s) || throw(BoundsError(s, i))
checkbounds{T<:Integer}(s::AbstractString, r::Range{T}) = isempty(r) || (minimum(r) >= start(s) && maximum(r) <= endof(s)) || throw(BoundsError(s, r))
# The following will end up using a deprecated checkbounds, when T is not Integer
checkbounds{T<:Real}(s::AbstractString, I::AbstractArray{T}) = all(i -> checkbounds(s, i), I)
checkbounds{T<:Integer}(s::AbstractString, I::AbstractArray{T}) = all(i -> checkbounds(s, i), I)

ind2chr(s::DirectIndexString, i::Integer) = begin checkbounds(s,i); i end
chr2ind(s::DirectIndexString, i::Integer) = begin checkbounds(s,i); i end

function ind2chr(s::AbstractString, i::Integer)
    s[i] # throws error if invalid
    j = 1
    k = start(s)
    while true
        c, l = next(s,k)
        if i <= k
            return j
        end
        j += 1
        k = l
    end
end

function chr2ind(s::AbstractString, i::Integer)
    i < start(s) && throw(BoundsError(s, i))
    j = 1
    k = start(s)
    while true
        c, l = next(s,k)
        if i == j
            return k
        end
        j += 1
        k = l
    end
end

immutable EachStringIndex{T<:AbstractString}
    s::T
end
eachindex(s::AbstractString) = EachStringIndex(s)

length(e::EachStringIndex) = length(e.s)
start(e::EachStringIndex) = start(e.s)
next(e::EachStringIndex, state) = (state, nextind(e.s, state))
done(e::EachStringIndex, state) = done(e.s, state)
eltype(::Type{EachStringIndex}) = Int

typealias Chars Union{Char,Tuple{Vararg{Char}},AbstractVector{Char},Set{Char}}

typealias ByteArray Union{Vector{UInt8},Vector{Int8}}

## character column width function ##

strwidth(s::AbstractString) = (w=0; for c in s; w += charwidth(c); end; w)

isascii(c::Char) = c < Char(0x80)
isascii(s::AbstractString) = all(isascii, s)

## string promotion rules ##

promote_rule{S<:AbstractString,T<:AbstractString}(::Type{S}, ::Type{T}) = String

isxdigit(c::Char) = '0'<=c<='9' || 'a'<=c<='f' || 'A'<=c<='F'
isxdigit(s::AbstractString) = all(isxdigit, s)

## checking UTF-8 & ACSII validity ##

byte_string_classify(data::Vector{UInt8}) =
    ccall(:u8_isvalid, Int32, (Ptr{UInt8}, Int), data, length(data))
byte_string_classify(s::String) = byte_string_classify(s.data)
    # 0: neither valid ASCII nor UTF-8
    # 1: valid ASCII
    # 2: valid UTF-8

isvalid(::Type{String}, s::Union{Vector{UInt8},String}) = byte_string_classify(s) != 0

## uppercase and lowercase transformations ##
uppercase(s::AbstractString) = map(uppercase, s)
lowercase(s::AbstractString) = map(lowercase, s)

function ucfirst(s::AbstractString)
    isempty(s) || isupper(s[1]) ? s : string(uppercase(s[1]),s[nextind(s,1):end])
end
function lcfirst(s::AbstractString)
    isempty(s) || islower(s[1]) ? s : string(lowercase(s[1]),s[nextind(s,1):end])
end

## string map, filter, has ##

function map(f, s::AbstractString)
    out = IOBuffer(Array{UInt8}(endof(s)),true,true)
    truncate(out,0)
    for c in s
        c2 = f(c)
        if !isa(c2,Char)
            throw(ArgumentError("map(f,s::AbstractString) requires f to return Char; try map(f,collect(s)) or a comprehension instead"))
        end
        write(out, c2::Char)
    end
    String(takebuf_array(out))
end

function filter(f, s::AbstractString)
    out = IOBuffer(Array{UInt8}(endof(s)),true,true)
    truncate(out,0)
    for c in s
        if f(c)
            write(out, c)
        end
    end
    takebuf_string(out)
end
