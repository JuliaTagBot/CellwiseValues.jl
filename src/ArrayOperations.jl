module ArrayOperations

using CellwiseValues
using CellwiseValues.NumberOperations: _checks
using CellwiseValues.Kernels: _size_for_broadcast

import CellwiseValues: apply
import Base: iterate
import Base: length
import Base: size
import Base: getindex
import Base: IndexStyle
import CellwiseValues.NumberOperations: _apply

function apply(k::ArrayKernel,v::Vararg{<:CellValue})
  CellArrayFromKernel(k,v...)
end

function _apply(f,v,::Val{true})
  k = ArrayKernelFromBroadcastedFunction(f)
  apply(k,v...)
end

struct CellArrayFromKernel{T,N,K,V} <: IterCellArray{T,N,CachedArray{T,N,Array{T,N}}}
  kernel::K
  cellvalues::V
end

function CellArrayFromKernel(k::ArrayKernel,v::Vararg{<:CellValue})
  _checks(v)
  T = _compute_type(k,v)
  N = _compute_N(v)
  K = typeof(k)
  V = typeof(v)
  CellArrayFromKernel{T,N,K,V}(k,v)
end

function _compute_type(k,v)
  t = tuple([ _eltype(vi) for vi in v ]...)
  T = compute_type(k,t...)
  @assert T <: NumberLike
  T
end

function _compute_N(v)
  n = 0
  for vi in v
    n = max(n,_ndims(vi))
  end
  n
end

_ndims(v::CellNumber) = 0

_ndims(v::CellArray{T,N}) where {T,N} = N

_eltype(v::CellNumber{T}) where T = T

_eltype(v::CellArray{T}) where T = T

function length(self::CellArrayFromKernel)
  vi, = self.cellvalues
  length(vi)
end

@inline function iterate(self::CellArrayFromKernel{T,N}) where {T,N}
  zipped = zip(self.cellvalues...)
  znext = iterate(zipped)
  v = CachedArray(T,N)
  _iterate(self,znext,zipped,v)
end

@inline function iterate(self::CellArrayFromKernel,state)
  zipped, zstate, v = state
  znext = iterate(zipped,zstate)
  _iterate(self,znext,zipped,v)
end

@inline function _iterate(self::CellArrayFromKernel,znext,zipped,v)
  if znext === nothing; return nothing end
  a, zstate = znext
  s = _compute_sizes(a...)
  z = compute_size(self.kernel,s...)
  setsize!(v,z)
  compute_value!(v,self.kernel,a...)
  state = (zipped,zstate,v)
  (v, state)
end

const _bs = _size_for_broadcast

# TODO use a generated function?
_compute_sizes(a...) = @notimplemented
_compute_sizes(a1) = (_bs(a1),)
_compute_sizes(a1,a2) = (_bs(a1),_bs(a2))
_compute_sizes(a1,a2,a3) = (_bs(a1),_bs(a2),_bs(a3))
_compute_sizes(a1,a2,a3,a4) = (_bs(a1),_bs(a2),_bs(a3),_bs(a4))
_compute_sizes(a1,a2,a3,a4,a5) = (_bs(a1),_bs(a2),_bs(a3),_bs(a4),_bs(a5))
_compute_sizes(a1,a2,a3,a4,a5,a6) = (_bs(a1),_bs(a2),_bs(a3),_bs(a4),_bs(a5),_bs(a6))
  
end # module ArrayOperations