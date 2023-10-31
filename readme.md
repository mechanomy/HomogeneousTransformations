# HomogeneousTransformations.jl
HomogeneousTransformations provides basic functions for creating and using homogeneous transformation matrices to perform 3D translations and rotations.
These are 4x4 matrices that allow rotation and translations of points to be performed straightforwardly, without the limitations of Euler angles or Quaternions.
Type `HMatrix` is a 4x4 wrapper on StaticArrays.MMatrix{4,4}, with some guardrails for unit vectors in the rotation matrix.
The submatrix [1:3,1:3] is the entity's rotation matrix, with columns that orient the entity's local xyz frame, and [1:3,4] is the entity's position.

## Use
```julia
using HomogeneousTransformations
H01 = Tx(-11.35)*Ty(500.00) * Rz(π/2)
H12 = Rz( -(180-76.17)/57.296) * Tx(500.44)
H23 = Rz( -(180-71.08)/57.296) * Tx(328.81) * Ty(-11.35)
H03 = H01 * H12 * H23
```
See the in-source tests in [src/HMatrix.jl](src/HMatrix.jl) and [src/HomogeneousTransformations.jl](src/HomogeneousTransformations.jl).

## Design
This package is intentionally simple, focused only on providing functions for calculating transformations and not attempting to include many functions like [Rigid Body Dynamics](https://github.com/JuliaRobotics/RigidBodyDynamics.jl).


## Status
[![Build Status](https://github.com/mechanomy/HomogeneousTransformations/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/mechanomy/HomogeneousTransformations/actions/workflows/CI.yml?query=branch%3Amain)

## References:
* [2006_Spong_RobotModelingAndControl](https://www.google.com/books/edition/Robot_Modeling_and_Control/DdjNDwAAQBAJ?hl=en&gbpv=1&dq=robot%20modeling%20and%20control%20homogeneous&pg=PA62&printsec=frontcover)

## Copyright
Copyright (c) 2023 Mechanomy LLC
