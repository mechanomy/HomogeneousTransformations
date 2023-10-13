#TestItemRunner fails to find tests if the module is documented, https://github.com/julia-vscode/TestItemRunner.jl/issues/33 , moving this to index.md
module HomogeneousTransformations
  using DocStringExtensions
  using LinearAlgebra
  using StaticArrays
  using TestItems # https://github.com/julia-vscode/TestItemRunner.jl 

  export Point
  export Rx, Ry, Rz, Rtk
  export Tx,Ty,Tz
  export HMatrix


  """
  Create a rotation matrix of angle `a` about the X axis.
  """
  function Rx(a) #a => radian / degree?
    return SMatrix{4,4}([1 0 0 0; 0 cos(a) -sin(a) 0; 0 sin(a) cos(a) 0; 0 0 0 1]) 
  end
  @testitem "Rx" begin
    a = 3
    H = Rx(a)
    @test H[2,2] == cos(a)
  end

  """
  Create a rotation matrix of angle `b` about the Y axis.
  """
  function Ry(b)
    return SMatrix{4,4}([cos(b) 0 sin(b) 0; 0 1 0 0; -sin(b) 0 cos(b) 0; 0 0 0 1])
  end
  @testitem "Ry" begin
    a = 3
    H = Ry(a)
    @test H[1,1] == cos(a)
  end

  """
  Create a rotation matrix of angle `c` about the Z axis.
  """
  function Rz(c)
    return SMatrix{4,4}([cos(c) -sin(c) 0 0; sin(c) cos(c) 0 0; 0 0 1 0; 0 0 0 1])
  end
  @testitem "Rz" begin
    a = 3
    H = Rz(a)
    @test H[1,1] == cos(a)
  end


  """
  Create a rotation of angle `th` about and aribrary axis `k`.
  """
  function Rtk(th, k)
    return SMatrix{4,4}([ k[1]^2*(1-cos(th)) + cos(th)       k[1]*k[2]*(1-cos(th))-k[3]*sin(th) k[1]*k[3]*(1-cos(th))+k[2]*sin(th) 0;
                          k[1]*k[2]*(1-cos(th))+k[3]*sin(th) k[2]^2*(1-cos(th))+cos(th)         k[2]*k[3]*(1-cos(th))-k[1]*sin(th) 0; 
                          k[1]*k[3]*(1-cos(th))-k[2]*sin(th) k[2]*k[3]*(1-cos(th))+k[1]*sin(th) k[3]^2*(1-cos(th))+cos(th)         0; 0 0 0 1 ]) # Spong_eq2.43 as a 4x4
  end
  @testitem "Rtk" begin
    @test Rx(3) ≈ Rtk(3, [1,0,0])
    @test Ry(3) ≈ Rtk(3, [0,1,0])
    @test Rz(3) ≈ Rtk(3, [0,0,1])
  end

  """
  Create a transformation matrix of distance `a` along the X axis.
  """
  function Tx(a)
    return SMatrix{4,4}([1 0 0 a; 0 1 0 0; 0 0 1 0; 0 0 0 1])
  end
  @testitem "Tx" begin
    a = 3
    H = Tx(a)
    @test H[1,4] == a
  end

  """
  Create a transformation matrix of distance `b` along the Y axis.
  """
  function Ty(b)
    return SMatrix{4,4}([1 0 0 0; 0 1 0 b; 0 0 1 0; 0 0 0 1])
  end
  @testitem "Ty" begin
    a = 3
    H = Ty(a)
    @test H[2,4] == a
  end

  """
  Create a transformation matrix of distance `c` along the Z axis.
  """
  function Tz(c)
    return SMatrix{4,4}([1 0 0 0; 0 1 0 0; 0 0 1 c; 0 0 0 1])
  end
  @testitem "Tz" begin
    a = 3
    H = Tz(a)
    @test H[3,4] == a
  end

  """
    $TYPEDSIGNATURES
    Constructs a `Point` at x,y,z coordinates.
  """
  function Point(x,y,z)
    return SVector{4}(x,y,z,1)
  end
  @testitem "Point" begin
    p = Point(1,2,3)
    # display(Rz(1)*p)
    @test Rz(1)*p ≈ [1*cos(1)-2*sin(1), 2*cos(1)+1*sin(1), 3, 1]
    @test Tx(1)*p ≈ [2,2,3,1]
    @test Ty(1)*p ≈ [1,3,3,1]
    @test Tz(1)*p ≈ [1,2,4,1]
  end

  """
    $TYPEDSIGNATURES
    Returns a `Point` at [0,0,0]
  """
  function P0()
    return Point(0.0,0.0,0.0)
  end

  """
    $TYPEDSIGNATURES
    Returns an Identity matrix.
  """
  function Eye()
    return SMatrix{4,4}([1.0 0 0 0; 0 1.0 0 0; 0 0 1.0 0; 0 0 0 1.0])
  end

  # I'd like to define a Homogeneous Matrix type as a specialization of SMatrix with:
  # * defined size of 4x4
  # * rotation matrix = 3x3
  # * position = 1x3
  # * unit columns in rotation
  """
    `HMatrix` wraps a SMatrix{4,4} to allow typed arguments
    $TYPEDFIELDS
  """
  struct HMatrix
    data::SMatrix{4,4}
  end
  Base.convert(::Type{HMatrix}, sm::SMatrix{4,4}) = HMatrix(sm)
  Base.convert(::Type{SMatrix}, hm::HMatrix) = hm.data
  Base.getindex(hm::HMatrix, i::Int) = hm.data[i]
  Base.setindex!(hm::HMatrix, v, i::Int) = hm.data[i] = v
  Base.getindex(hm::HMatrix, i::Int, j::Int) = hm.data[i,j]
  Base.setindex!(hm::HMatrix, v, i::Int, j::Int) = hm.data[i,j] = v
  # Base.:+(hm::HMatrix, v::Int) = hm.data[1,1] + v

  # Base.:+(hm::HMatrix, v::Int) = hm.data .+ v

  @testitem "scalar addition" begin 
    a = HomogeneousTransformations.Eye()
    @test_throws MethodError a + 1 #need the .+
    b = a .+ 1
    @test b[1,1] ≈ 2
  end


end
