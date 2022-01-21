import getfem as gf
import numpy as np
import numpy.testing as npt
import os

cases = [
    "case11",
    "case12",
    "case13",
    "case14",
    "case21",
    "case22",
    "case23",
    "case24",
    "case31",
    "case32",
    "case33",
    "case34",
    "case41",
    "case42",
    "case43",
    "case44",
]

xs = [
    4,
    4,
    4,
    16,
    4,
    4,
    4,
    16,
    4,
    4,
    4,
    16,
    4,
    4,
    4,
    16,
]
ys = [
    1,
    2,
    4,
    8,
    1,
    2,
    4,
    8,
    1,
    2,
    4,
    8,
    1,
    2,
    4,
    8,
]

fem_names = [
    "FEM_PK(1, 2)",
    "FEM_PK(1, 2)",
    "FEM_PK(1, 2)",
    "FEM_PK(1, 2)",
    "FEM_PK(1, 1)",
    "FEM_PK(1, 1)",
    "FEM_PK(1, 1)",
    "FEM_PK(1, 1)",
    "FEM_PK(1, 1)",
    "FEM_PK(1, 1)",
    "FEM_PK(1, 1)",
    "FEM_PK(1, 1)",
    "FEM_PK_WITH_CUBIC_BUBBLE(1, 1)",
    "FEM_PK_WITH_CUBIC_BUBBLE(1, 1)",
    "FEM_PK_WITH_CUBIC_BUBBLE(1, 1)",
    "FEM_PK_WITH_CUBIC_BUBBLE(1, 1)",
]

methods = [
    "IM_GAUSS1D(4)",
    "IM_GAUSS1D(4)",
    "IM_GAUSS1D(4)",
    "IM_GAUSS1D(4)",
    "IM_GAUSS1D(2)",
    "IM_GAUSS1D(2)",
    "IM_GAUSS1D(2)",
    "IM_GAUSS1D(2)",
    "IM_GAUSS1D(0)",
    "IM_GAUSS1D(0)",
    "IM_GAUSS1D(0)",
    "IM_GAUSS1D(0)",
    "IM_GAUSS1D(4)",
    "IM_GAUSS1D(4)",
    "IM_GAUSS1D(4)",
    "IM_GAUSS1D(4)",
]

L = 10.0
b = 1.0
h = 1.0
meshs = []
for case, x, y in zip(cases, xs, ys):
    X = np.arange(x + 1) * L / x
    Y = np.arange(y + 1) * h / y
    mesh = gf.Mesh("cartesian", X, Y)
    meshs.append(mesh)
    
TOP_BOUND = 1
RIGHT_BOUND = 2
LEFT_BOUND = 3
BOTTOM_BOUND = 4

for mesh in meshs:
    fb1 = mesh.outer_faces_with_direction([0.0, 1.0], 0.01)
    fb2 = mesh.outer_faces_with_direction([1.0, 0.0], 0.01)
    fb3 = mesh.outer_faces_with_direction([-1.0, 0.0], 0.01)
    fb4 = mesh.outer_faces_with_direction([0.0, -1.0], 0.01)
    mesh.set_region(TOP_BOUND, fb1)
    mesh.set_region(RIGHT_BOUND, fb2)
    mesh.set_region(LEFT_BOUND, fb3)
    mesh.set_region(BOTTOM_BOUND, fb4)

fems = []
for fem_name in fem_names:
    fems.append(gf.Fem("FEM_PRODUCT(" + fem_name + "," + fem_name + ")"))
    
mfus = []
for mesh, fem in zip(meshs, fems):
    mfu = gf.MeshFem(mesh, 2)
    mfu.set_fem(fem)
    mfus.append(mfu)
    
ims = []
for method in methods:
    ims.append(gf.Integ("IM_PRODUCT(" + method + ", " + method + ")"))

mims = []
for mesh, im in zip(meshs, ims):
    mim = gf.MeshIm(mesh, im)
    mims.append(mim)

mds = []
for mfu in mfus:
    md = gf.Model("real")
    md.add_fem_variable("u", mfu)
    mds.append(md)

E = 10000  # N/mm2
Nu = 0.0

for md in mds:
    md.add_initialized_data("E", E)
    md.add_initialized_data("Nu", Nu)
    
for md, mim in zip(mds, mims):
    md.add_isotropic_linearized_elasticity_brick_pstrain(mim, "u", "E", "Nu")

for (md, mim, mfu, fem) in zip(mds, mims, mfus, fems):
    if fem.is_lagrange():
        md.add_Dirichlet_condition_with_simplification("u", LEFT_BOUND)
    else:
        md.add_Dirichlet_condition_with_multipliers(mim, "u", mfu, LEFT_BOUND)

F = 1.0  # N/mm2
for (md, mfu, mim) in zip(mds, mfus, mims):
    md.add_initialized_data("F", [0, F / (b * h)])
    md.add_source_term_brick(mim, "u", "F", RIGHT_BOUND)

for md in mds:
    md.solve()

for md, mfu, case in zip(mds, mfus, cases):
    u = md.variable("u")
    dof = mfu.basic_dof_on_region(LEFT_BOUND)
    print(u[dof])
    npt.assert_almost_equal(abs(np.max(u[dof])), 0.0)
