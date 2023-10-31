#TestItemRunner fails to find tests if the module is documented, https://github.com/julia-vscode/TestItemRunner.jl/issues/33 , moving this to index.md
module HomogeneousTransformations
  using DocStringExtensions
  using LinearAlgebra
  using StaticArrays
  using Printf
  using TestItems # https://github.com/julia-vscode/TestItemRunner.jl 

  include("HMatrix.jl") # the core struct

  export Point
  export Rx, Ry, Rz, Rtk
  export Tx,Ty,Tz
  export Eye

  """
    $TYPEDSIGNATURES
    Create a rotation matrix of angle `a` about the X axis, in radians.
  """
  function Rx(a) #a => radian / degree?
    # return MMatrix{4,4}([1 0 0 0; 0 cos(a) -sin(a) 0; 0 sin(a) cos(a) 0; 0 0 0 1]) 
    return HMatrix([1 0 0 0; 0 cos(a) -sin(a) 0; 0 sin(a) cos(a) 0; 0 0 0 1]) 
  end
  @testitem "Rx" begin
    a = 3
    H = Rx(a)
    @test H[2,2] ≈ cos(a)
  end

  """
    $TYPEDSIGNATURES
    Create a rotation matrix of angle `b` about the Y axis, in radians.
  """
  function Ry(b)
    return HMatrix([cos(b) 0 sin(b) 0; 0 1 0 0; -sin(b) 0 cos(b) 0; 0 0 0 1])
  end
  @testitem "Ry" begin
    a = 3
    H = Ry(a)
    @test H[1,1] ≈ cos(a)
  end

  """
    $TYPEDSIGNATURES
    Create a rotation matrix of angle `c` about the Z axis, in radians.
  """
  function Rz(c)
    return HMatrix([cos(c) -sin(c) 0 0; sin(c) cos(c) 0 0; 0 0 1 0; 0 0 0 1])
  end
  @testitem "Rz" begin
    a = 3
    H = Rz(a)
    @test H[1,1] ≈ cos(a)
  end


  """
    $TYPEDSIGNATURES
    Create a rotation of angle `th`, in radians, about and aribrary axis `k`.
  """
  function Rtk(th, k)
    k /= norm(k)
    return HMatrix([k[1]^2*(1-cos(th)) + cos(th)       k[1]*k[2]*(1-cos(th))-k[3]*sin(th) k[1]*k[3]*(1-cos(th))+k[2]*sin(th) 0;
                    k[1]*k[2]*(1-cos(th))+k[3]*sin(th) k[2]^2*(1-cos(th))+cos(th)         k[2]*k[3]*(1-cos(th))-k[1]*sin(th) 0; 
                    k[1]*k[3]*(1-cos(th))-k[2]*sin(th) k[2]*k[3]*(1-cos(th))+k[1]*sin(th) k[3]^2*(1-cos(th))+cos(th)         0; 0 0 0 1 ]) # Spong_eq2.43 as a 4x4
  end
  @testitem "Rtk" begin
    @test Rx(3) ≈ Rtk(3, [1,0,0])
    @test Ry(3) ≈ Rtk(3, [0,1,0])
    @test Rz(3) ≈ Rtk(3, [0,0,1])
    @test Rx(3) ≈ Rtk(3, [10,0,0]) #test vector normalization
  end

  """
    $TYPEDSIGNATURES
    Create a transformation matrix of distance `a` along the X axis.
  """
  function Tx(a)
    return HMatrix([1 0 0 a; 0 1 0 0; 0 0 1 0; 0 0 0 1])
  end
  @testitem "Tx" begin
    a = 3
    H = Tx(a)
    @test H[1,4] == a
  end

  """
    $TYPEDSIGNATURES
    Create a transformation matrix of distance `b` along the Y axis.
  """
  function Ty(b)
    return HMatrix([1 0 0 0; 0 1 0 b; 0 0 1 0; 0 0 0 1])
  end
  @testitem "Ty" begin
    a = 3
    H = Ty(a)
    @test H[2,4] == a
  end

  """
    $TYPEDSIGNATURES
    Create a transformation matrix of distance `c` along the Z axis.
  """
  function Tz(c)
    return HMatrix([1 0 0 0; 0 1 0 0; 0 0 1 c; 0 0 0 1])
  end
  @testitem "Tz" begin
    a = 3
    H = Tz(a)
    @test H[3,4] == a
  end

  """
    $TYPEDSIGNATURES
    Returns an Identity matrix.
  """
  function Eye()
    return HMatrix([1.0 0 0 0; 0 1.0 0 0; 0 0 1.0 0; 0 0 0 1.0])
  end

end
