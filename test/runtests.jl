using HomogeneousTransformations #must use -project flag when testing!
using Test



@testset "HomogeneousTransformations.jl" begin


  @testset "Rx" begin
    a = 3
    H = Rx(a)
    @test H[2,2] == cos(a)
  end

  @testset "Ry" begin
    a = 3
    H = Ry(a)
    @test H[1,1] == cos(a)
  end

  @testset "Rz" begin
    a = 3
    H = Rz(a)
    @test H[1,1] == cos(a)
  end

  @testset "Rtk" begin
    @test Rx(3) ≈ Rtk(3, [1,0,0])
    @test Ry(3) ≈ Rtk(3, [0,1,0])
    @test Rz(3) ≈ Rtk(3, [0,0,1])
  end

  @testset "Tx" begin
    a = 3
    H = Tx(a)
    @test H[1,4] == a
  end
  @testset "Ty" begin
    a = 3
    H = Ty(a)
    @test H[2,4] == a
  end
  @testset "Tz" begin
    a = 3
    H = Tz(a)
    @test H[3,4] == a
  end

  @testset "Point" begin
    p = Point(1,2,3)
    # display(Rz(1)*p)
    @test Rz(1)*p ≈ [1*cos(1)-2*sin(1), 2*cos(1)+1*sin(1), 3, 1]
    @test Tx(1)*p ≈ [2,2,3,1]
    @test Ty(1)*p ≈ [1,3,3,1]
    @test Tz(1)*p ≈ [1,2,4,1]
  end

end
