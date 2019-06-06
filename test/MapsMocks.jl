module MapsMocks

using CellwiseValues

export MockMap
export TestMap

import CellwiseValues: evaluate!
import CellwiseValues: return_size

struct MockMap{P} <: Map{P,1,P,1}
  val::P
end

function evaluate!(
  this::MockMap{P}, points::AbstractVector{P}, v::AbstractVector{P}) where P
  for (i,qi) in enumerate(points)
    v[i] = qi+this.val
  end
end

return_size(::MockMap, psize::Tuple{Int}) = psize

struct TestMap{P} <: Map{P,1,P,2}
  val::P
  dim::Int
end

function evaluate!(
  this::TestMap{P}, points::AbstractVector{P}, v::AbstractMatrix{P}) where P
  for j in 1:this.dim
    for (i,qi) in enumerate(points)
      v[j,i] = j*qi+this.val
    end
  end
end

return_size(this::TestMap, psize::Tuple{Int}) = (this.dim, psize[1])

end # module MapsMocks
