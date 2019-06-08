module CellMapOperations

using CellwiseValues

import CellwiseValues: evaluate
import MapOperations: _stype: _m
import CellwiseValues.ArrayOperations: _nd, _eltype
import CellwiseValues: apply
import Base: iterate
import Base: length

struct CellMapFromKernel{S,M,T,N,R,K,V} <: IterCellMap{S,M,T,N,R}
  kernel::K
  cellvalues::V
end

function CellMapFromKernel(k::ArrayKernel,v::Vararg{<:CellValues})
  S = _compute_S(v)
  M = _compute_M(v)
  T = _compute_T(k,v)
  N = _compute_N(k,v)
  R = _compute_R(k,v)
  K = typeof(k)
  V = typeof(v)
  CellMapFromKernel{S,M,T,N,R,K,V}(k,v)
end

function length(self::CellMapFromKernel)
  vi, = self.cellvalues
  length(vi)
end

@inline function iterate(self::CellMapFromKernel{T,N}) where {T,N}
  zipped = zip(self.cellvalues...)
  znext = iterate(zipped)
  if znext === nothing; return nothing end
  a, zstate = znext
  v = MapFromKernel(self.kernel,a...)
  _iterate(self,znext,zipped,v)
end

@inline function iterate(self::CellMapFromKernel,state)
  zipped, zstate, v = state
  znext = iterate(zipped,zstate)
  _iterate(self,znext,zipped,v)
end

@inline function _iterate(self::CellMapFromKernel,znext,zipped,v)
  if znext === nothing; return nothing end
  a, zstate = znext
  setinputs!(v,a...)
  state = (zipped,zstate,v)
  (v, state)
end

function evaluate(
  m::CellMapFromKernel{S,M,T,N},a::CellArray{S,M}) where {S,M,T,N}
  v = [ _eval(mi,a) for mi in m.cellvalues ]
  apply(m.kernel,v...)
end

_eval(m::CellMap,a) = evaluate(m,a)

_eval(m::CellArray,a) = m

function _compute_R(k,v)
  m = tuple([eltype(vi) for vi in v]...)
  S = _compute_S(m)
  M = _compute_M(m)
  T = _compute_T(k,m)
  N = _compute_N(k,m)
  K = typeof(k)
  V = m
  C = tuple([ _cache_type(mi) for mi in m]...)
  MapFromKernel{S,M,T,N,K,V,C}
end

_cache_type(::Type{<:Map{S,M,T,N}}) where {S,M,T,N} = CachedArray{T,N,Array{T,N}}

_cache_type(::Type{<:AbstractArray{T,N}}) where {T,N} = CachedArray{T,N,Array{T,N}}

_stype(v::CellMap{S}) where S = S

_stype(v::CellArray) = nothing

_m(v::CellMap{S,M}) where {S,M} = M

_m(v::CellArray) = nothing

_eltype(v::CellMap{S,M,T}) where {S,M,T} = T

_eltype(v::CellArray{T}) where T = T

_nd(v::CellMap{S,M,T,N}) where {S,M,T,N} = N

_nd(v::CellArray{T,N}) where {T,N} = N

_stype(v::Type{<:Map{S}}) where S = S

_stype(v::Type{<:AbstractArray}) = nothing

_m(v::Type{<:Map{S,M}}) where {S,M} = M

_m(v::Type{<:AbstractArray}) = nothing

_eltype(v::Type{<:Map{S,M,T}}) where {S,M,T} = T

_eltype(v::Type{<:AbstractArray{T}}) where T = T

_nd(v::Type{<:Map{S,M,T,N}}) where {S,M,T,N} = N

_nd(v::Type{<:AbstractArray{T,N}}) where {T,N} = N

end # module CellMapOperations
