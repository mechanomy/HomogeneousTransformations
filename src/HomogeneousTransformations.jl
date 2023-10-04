

"""
HomogeneousTransformations provides basic functions for creating and using [homogeneous transformation matrices]() to perform 3D translations and rotations.


## Exports:
($EXPORTS)

## References:
* 2006_Spong_RobotModelingAndControl

"""
module HomogeneousTransformations
  using DocStringExtensions

  using LinearAlgebra
  using StaticArrays


  export Point
  export Rx, Ry, Rz, Rtk
  export Tx,Ty,Tz

  function Point(x,y,z)
    return SVector{4}(x,y,z,1)
  end


  """
  Create a rotation matrix of angle `a` about the X axis.
  """
  function Rx(a) #a => radian / degree?
    return SMatrix{4,4}([1 0 0 0; 0 cos(a) -sin(a) 0; 0 sin(a) cos(a) 0; 0 0 0 1]) 
  end

  """
  Create a rotation matrix of angle `b` about the Y axis.
  """
  function Ry(b)
    return SMatrix{4,4}([cos(b) 0 sin(b) 0; 0 1 0 0; -sin(b) 0 cos(b) 0; 0 0 0 1])
  end

  """
  Create a rotation matrix of angle `c` about the Z axis.
  """
  function Rz(c)
    return SMatrix{4,4}([cos(c) -sin(c) 0 0; sin(c) cos(c) 0 0; 0 0 1 0; 0 0 0 1])
  end

  """
  Create a rotation of angle `th` about and aribrary axis `k`.
  """
  function Rtk(th, k)
    return SMatrix{4,4}([ k[1]^2*(1-cos(th)) + cos(th)       k[1]*k[2]*(1-cos(th))-k[3]*sin(th) k[1]*k[3]*(1-cos(th))+k[2]*sin(th) 0;
                          k[1]*k[2]*(1-cos(th))+k[3]*sin(th) k[2]^2*(1-cos(th))+cos(th)         k[2]*k[3]*(1-cos(th))-k[1]*sin(th) 0; 
                          k[1]*k[3]*(1-cos(th))-k[2]*sin(th) k[2]*k[3]*(1-cos(th))+k[1]*sin(th) k[3]^2*(1-cos(th))+cos(th)         0; 0 0 0 1 ]) # Spong_eq2.43 as a 4x4
  end

  """
  Create a transformation matrix of distance `a` along the X axis.
  """
  function Tx(a)
      return SMatrix{4,4}([1 0 0 a; 0 1 0 0; 0 0 1 0; 0 0 0 1])
  end

  """
  Create a transformation matrix of distance `b` along the Y axis.
  """
  function Ty(b)
      return SMatrix{4,4}([1 0 0 0; 0 1 0 b; 0 0 1 0; 0 0 0 1])
  end

  """
  Create a transformation matrix of distance `c` along the Z axis.
  """
  function Tz(c)
      return SMatrix{4,4}([1 0 0 0; 0 1 0 0; 0 0 1 c; 0 0 0 1])
  end
end
