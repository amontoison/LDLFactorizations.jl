using LDLFactorizations, Test, LinearAlgebra, SparseArrays

# this matrix possesses an LDLᵀ factorization without pivoting
A = [ 1.7     0     0     0     0     0     0     0   .13     0
        0    1.     0     0   .02     0     0     0     0   .01
        0     0   1.5     0     0     0     0     0     0     0
        0     0     0   1.1     0     0     0     0     0     0
        0   .02     0     0   2.6     0   .16   .09   .52   .53
        0     0     0     0     0   1.2     0     0     0     0
        0     0     0     0   .16     0   1.3     0     0   .56
        0     0     0     0   .09     0     0   1.6   .11     0
      .13     0     0     0   .52     0     0   .11   1.4     0
        0   .01     0     0   .53     0   .56     0     0   3.1 ]
b = [.287, .22, .45, .44, 2.486, .72, 1.55, 1.424, 1.621, 3.759]
ϵ = sqrt(eps(eltype(A)))

LDLT = ldl(A)
x = LDLT \ b

r = A * x - b
@test norm(r) ≤ ϵ * norm(b)

y = collect(0.1:0.1:1)
@test norm(x - y) ≤ ϵ * norm(y)

x2 = copy(b)
ldiv!(LDLT, x2)

r2 = A * x2 - b
@test norm(r2) ≤ ϵ * norm(b)

@test norm(x2 - y) ≤ ϵ * norm(y)

# test properties
@test eltype(LDLT) == eltype(A)
@test nnz(LDLT) == nnz(LDLT.L) + length(LDLT.d)
@test size(LDLT) == size(A)
@test typeof(LDLT.D) <: Diagonal
@test propertynames(LDLT) == (:L, :D, :P)

# this matrix does not possess an LDLᵀ factorization without pivoting
A = [ 0 1
      1 1 ]
@test_throws LDLFactorizations.SQDException ldl(A, [1, 2])

# Sparse tests
for Ti in (Int32, Int), Tf in (Float32, Float64, BigFloat)
  A = sparse(Ti[1, 2, 1, 2], Ti[1, 1, 2, 2], Tf[10, 2, 2, 5])
  b = A * ones(Tf, 2)
  LDLT = ldl(A)
  x = LDLT \ b
  r = A * x - b
  @test norm(r) ≤ sqrt(eps(Tf)) * norm(b)

  x2 = copy(b)
  ldiv!(LDLT, x2)
  r2 = A * x2 - b
  @test norm(r2) ≤ sqrt(eps(Tf)) * norm(b)

  y = similar(b)
  ldiv!(y, LDLT, b)
  r2 = A * y - b
  @test norm(r2) ≤ sqrt(eps(Tf)) * norm(b)

  @test nnz(LDLT) == nnz(LDLT.L) + length(LDLT.d)
end

# Using only the upper triangle tests

A = [ 1.7     0     0     0     0     0     0     0   .13     0
        0    1.     0     0   .02     0     0     0     0   .01
        0     0   1.5     0     0     0     0     0     0     0
        0     0     0   1.1     0     0     0     0     0     0
        0   .02     0     0   2.6     0   .16   .09   .52   .53
        0     0     0     0     0   1.2     0     0     0     0
        0     0     0     0   .16     0   1.3     0     0   .56
        0     0     0     0   .09     0     0   1.6   .11     0
      .13     0     0     0   .52     0     0   .11   1.4     0
        0   .01     0     0   .53     0   .56     0     0   3.1 ]
b = [.287, .22, .45, .44, 2.486, .72, 1.55, 1.424, 1.621, 3.759]
ϵ = sqrt(eps(eltype(A)))

A_upper = triu(A)
LDLT_upper = ldl(A_upper, upper = true)
x = LDLT_upper \ b

r = A * x - b
@test norm(r) ≤ ϵ * norm(b)

y = collect(0.1:0.1:1)
@test norm(x - y) ≤ ϵ * norm(y)

x2 = copy(b)
ldiv!(LDLT, x2)

r2 = A * x2 - b
@test norm(r2) ≤ ϵ * norm(b)

@test norm(x2 - y) ≤ ϵ * norm(y)

@test nnz(LDLT_upper) == nnz(LDLT_upper.L) + length(LDLT_upper.d)

# test with a permutation of a different int type
p = Int32.(collect(size(A,1):-1:1))
LDLT_upper = ldl(A_upper, p, upper = true)
x = LDLT_upper \ b

r = A * x - b
@test norm(r) ≤ ϵ * norm(b)

y = collect(0.1:0.1:1)
@test norm(x - y) ≤ ϵ * norm(y)

x2 = copy(b)
ldiv!(LDLT, x2)

r2 = A * x2 - b
@test norm(r2) ≤ ϵ * norm(b)

@test norm(x2 - y) ≤ ϵ * norm(y)

# Tests with multiple right-hand sides
B = 1.0 * [ i + j for j = 1 : 10, i = 0 : 3]
X = A \ B
Y = similar(B)
ldiv!(Y, LDLT, B)
@test norm(Y - X) ≤ ϵ * norm(X)

# this matrix does not possess an LDLᵀ factorization without pivoting
A = triu([ 0 1
           1 1 ])
@test_throws LDLFactorizations.SQDException ldl(A, [1, 2], upper = true)

# Sparse tests
for Ti in (Int32, Int), Tf in (Float32, Float64, BigFloat)
  A = sparse(Ti[1, 2, 1, 2], Ti[1, 1, 2, 2], Tf[10, 2, 2, 5])
  A_upper = triu(A)
  b = A * ones(Tf, 2)
  LDLT = ldl(A_upper, upper = true)
  x = LDLT \ b
  r = A * x - b
  @test norm(r) ≤ sqrt(eps(Tf)) * norm(b)

  x2 = copy(b)
  ldiv!(LDLT, x2)
  r2 = A * x2 - b
  @test norm(r2) ≤ sqrt(eps(Tf)) * norm(b)

  @test nnz(LDLT) == nnz(LDLT.L) + length(LDLT.d)
end

