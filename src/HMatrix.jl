# I'd like to define a Homogeneous Matrix type as a specialization of SMatrix with:
# * defined size of 4x4
# * rotation matrix = 3x3
# * position = 1x3
# * unit columns in rotation


export HMatrix

"""
  `HMatrix` wraps a SMatrix{4,4}, enforcing
  * defined size of 4x4
  * unit columns in rotation matrix [1:3,1:3]
  * 0001 last row

  $TYPEDFIELDS
"""
struct HMatrix
  data::MMatrix #need to specify type? ## that you should want to positively and negatively define everything..
end
function HMatrix(a::Matrix)
  @assert length(a) == 12 || length(a) == 16 "HMatrix requires 12 or 16 elements"

  if length(a) == 12
    a = vcat(a, [0 0 0 1])
  end

  mm = MMatrix{4,4,Float64}(a)
  for i=1:3
    mm[1:3,i] /= norm(mm[1:3,i])
  end
  for i=1:3
    mm[4,i] = 0
  end
  mm[4,4] = 1

  return HMatrix(mm)
end
@testitem "HMatrix construction" begin
  @testset "creation from 16 elements" begin
    hm = HMatrix([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16])
    @test hm.data[1,1] ≈ 1/sqrt(1^2+5^2+9^2)
    @test hm.data[4,1] ≈ 0
    
    using LinearAlgebra # @testitems are separted from parent context..
    @test norm(hm.data[1:3,1]) ≈ 1.0

    hm = HMatrix([1 0 0 0; 0 1 0 0; 0 0 1 0; 0 0 0 1])
    @test hm.data[2,2] == 1
  end

  @testset "creation with 12 elements" begin
    hm = HMatrix([1 2 3 4; 5 6 7 8; 9 10 11 12])
    @test hm.data[1,1] ≈ 1/sqrt(1^2+5^2+9^2)

    using LinearAlgebra # @testitems are separted from parent context..
    @test norm(hm.data[1:3,1]) ≈ 1.0
  end

  @testset "matrix size assertion" begin
    @test_throws AssertionError HMatrix([1 2 3; 4 5 6]) 
  end

  @testset "creation from MMatrix" begin
    using StaticArrays
    a = 1
    b = 1.2
    hf = HMatrix( MMatrix{4,4,Float32,16}([1.2 0 0 0; 0 1.0 0 0; 0 0 1.0 0; 0 0 0 1.0]) )
    @test isa(hf, HMatrix)
    @test hf.data[1,1] ≈ 1.2
    @test isa(hf.data[1,1], Float32)

    hi = HMatrix( MMatrix{4,4,Int8,16}([1 0 0 0; 0 1.0 0 0; 0 0 1.0 0; 0 0 0 1.0]) )
    @test isa(hi.data[1,1], Int8)
  end
end

Base.convert(::Type{HMatrix}, sm::MMatrix{4,4}) = HMatrix(sm)
Base.convert(::Type{MMatrix}, hm::HMatrix) = hm.data
Base.convert(::Type{SMatrix}, hm::HMatrix) = hm.data

# Base interface overloads: https://docs.julialang.org/en/v1/manual/interfaces/
Base.getindex(hm::HMatrix, i::Int, j::Int) = hm.data[i,j]
@testitem "getindex" begin
  using StaticArrays
  hf = HMatrix( MMatrix{4,4,Float64}([1.0 0 0 0; 0 1.0 0 0; 0 0 1.0 0; 0 0 0 1.0]) )
  @test hf[1,1] ≈ 1.0
end

Base.setindex!(hm::HMatrix, v, i::Int, j::Int) = (setindex!(hm.data, v, i, j); hm) # from https://github.com/JuliaArrays/StaticArrays.jl/blob/d80455d2e1aba57a6cf65cc8d787dc6474ec3980/src/SizedArray.jl#L93
# Base.setindex!(hm::HMatrix, v, i::Int, j::Int) = (hm.data[i,j]=v) #seems to work
@testitem "setindex" begin
  using StaticArrays
  hf = HMatrix( MMatrix{4,4}([1.0 0 0 0; 0 1.0 0 0; 0 0 1.0 0; 0 0 0 1.0]) )
  hf[1,1] = 1.3
  @test hf[1,1] ≈ 1.3
end

Base.size(hm::HMatrix) = size(hm.data)
Base.length(hm::HMatrix) = length(hm.data)
@testitem "size" begin
  using StaticArrays
  hf = HMatrix( MMatrix{4,4}([1.0 0 0 0; 0 1.0 0 0; 0 0 1.0 0; 0 0 0 1.0]) )
  @test size(hf) == (4,4)
  @test length(hf) == 16
end

Base.isapprox(a::HMatrix, b::HMatrix; atol::Real=0, rtol::Real=atol) = isapprox(a.data, b.data, atol=atol, rtol=rtol)
Base.isapprox(a::HMatrix, b::MMatrix; atol::Real=0, rtol::Real=atol) = isapprox(a.data, b, atol=atol, rtol=rtol)
Base.isapprox(a::MMatrix, b::HMatrix; atol::Real=0, rtol::Real=atol) = isapprox(a, b.data, atol=atol, rtol=rtol)
@testitem "isapprox" begin
  using StaticArrays
  a = HMatrix( MMatrix{4,4}([1.1 0 0 0; 0 1.0 0 0; 0 0 1.0 0; 0 0 0 1.0]) )
  b = HMatrix( MMatrix{4,4}([1.1 0 0 0; 0 1.0 0 0; 0 0 1.0 0; 0 0 0 1.0]) )
  c = HMatrix( MMatrix{4,4}([1.0 0 0 0; 0 1.0 0 0; 0 0 1.0 0; 0 0 0 1.0]) )
  @test isapprox(a, b)
  @test a ≈ b
  @test ~isapprox(a, c)

  d = MMatrix{4,4}([1.1 0 0 0; 0 1.0 0 0; 0 0 1.0 0; 0 0 0 1.0]) 
  @test isapprox(a,d)
  @test a ≈ d
  @test isapprox(d,a)
  @test d ≈ a
end

Base.iterate(hm::HMatrix, state=1) = state > length(hm) ? nothing : (hm.data[state],state+1)
@testitem "broadcasting" begin 
  using StaticArrays
  hf = HMatrix( MMatrix{4,4}([1.0 0 0 0; 0 1.0 0 0; 0 0 1.0 0; 0 0 0 1.0]) )
  @test_throws MethodError hf + 1 
  a = hf .+ 1
  @test a[1,1] ≈ 2

  b = hf .* 2
  @test b[1,1] ≈ 2

  c = hf ./ 2
  @test c[1,1] ≈ 1/2
end

Base.:*(a::HMatrix, b::HMatrix) = HMatrix( a.data * b.data )
@testitem "multiplication" begin
  a = 0.1
  b = 0.2
  H = Rx(a) * Ry(b)
  @test H[1,1] ≈ cos(b)
  @test H[2,2] ≈ cos(a)
  @test H[3,3] ≈ cos(a)*cos(b)
end
Base.:*(a::HMatrix, b::MMatrix) = HMatrix( a.data * b )
Base.:*(a::MMatrix, b::HMatrix) = HMatrix( a * b.data )

Base.:/(a::HMatrix, b::HMatrix) = HMatrix( a.data / b.data)
@testitem "division" begin
  a = 0.1
  b = 0.2
  H = Rx(a) / Ry(b)
  @test H[2,2] ≈ cos(a)
  @test H[3,3] ≈ cos(a)*cos(b)
end
Base.:/(a::HMatrix, b::MMatrix) = HMatrix( a.data / b)
Base.:/(a::MMatrix, b::HMatrix) = HMatrix( a / b.data)

# Base.:+(a::HMatrix, b::HMatrix) = HMatrix( a.data + b.data) #homogeneous transformation matrices are not additive...
# @testitem "addition" begin
#   a = 0.1
#   b = 0.2
#   H = Rx(a) + Ry(b)
#   @test H[3,3] ≈ cos(a)+cos(b)
# end

function Base.show(io::IO, h::HMatrix)
  # print(io, h.data)
  # for i in 1:4
  #   for j in 1:4
  #     if i < 4 && j < 4
  #       printstyled(io, @sprintf("%0.3f ", h.data[i,j]), color=:cyan) # rotation
  #     elseif i < 4 && j == 4
  #       printstyled(io, @sprintf("%3.3f;\n", h.data[i,j]), color=:blue) # position
  #     else 
  #       printstyled(io, @sprintf("%3.3f ", h.data[i,j]), color=:normal) #0001
  #     end
  #   end
  # end
  # println(io)

  #too cute?
  for irow = 1:4
    for icol = 1:4
      if irow < 4 && icol == 1
        printstyled(io, @sprintf("%0.3f ", h.data[irow,icol]), color=:light_red) # rx
      end
      if irow < 4 && icol == 2
        printstyled(io, @sprintf("%0.3f ", h.data[irow,icol]), color=:light_green) # ry
      end
      if irow < 4 && icol == 3
        printstyled(io, @sprintf("%0.3f ", h.data[irow,icol]), color=:light_blue) # ry
      end
      if irow < 4 && icol == 4
        printstyled(io, @sprintf("%0.3f;\n", h.data[irow,icol]), color=:yellow) # position
      end
      if irow == 4 
        printstyled(io, @sprintf("%0.3f ", h.data[irow,icol]), color=:normal) # 0001
      end
    end
  end
  println(io)
end
@testitem "printing" begin
  a = 0.1
  b = 0.2
  H = Rx(a) / Ry(b)
  # @show H
  # display(H)
  @test true # too hard to test whether the display is correct, verify manually
end





