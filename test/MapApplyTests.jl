module MapApplyTests

using Test
using CellwiseValues
using TensorValues

using ..MapsMocks

a = VectorValue(10,10)
b = VectorValue(15,20)
p1 = VectorValue(1,1)
p2 = VectorValue(2,2)
p3 = VectorValue(3,3)
p = [p1,p2,p3]
m = MockMap(a)

m2 = apply(-,m,broadcast=true)

r = evaluate(m,p)
r2 = -r
test_map(m2,p,r2)

m3 = apply(-,m,m2,broadcast=true)
r3 = r .- r2
test_map(m3,p,r3)

m3 = apply(-,m,p,broadcast=true)
r3 = r .- p
test_map(m3,p,r3)

end # module
