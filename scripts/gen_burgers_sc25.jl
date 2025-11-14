using Random
using Statistics
using UniqueKronecker
using LinearAlgebra
using RLinearAlgebra
using PolynomialModelReductionDataset
using LiftAndLearn
using JLD2
const poly_dat = PolynomialModelReductionDataset
const LnL = LiftAndLearn

# Define system parameters
num_inputs = 10;
Ω = (0.0, 10.0);
Nx = 2^9; dt = 0.25e-3;

burger = poly_dat.BurgersModel(
    spatial_domain=Ω, time_domain=(0.0, 1.0), Δx=(Ω[2] + 1/Nx)/Nx, Δt=dt,
    diffusion_coeffs=range(0.1, 1.0, length=10), BC=:dirichlet,
);

options = LnL.LSOpInfOption(
    system=LnL.SystemStructure(
        state=[1,2],
        control=1,
        output=1
    ),
    vars=LnL.VariableStructure(
        N=1,
    ),
    data=LnL.DataStructure(
        Δt=dt,
        deriv_type="SI"
    ),
    optim=LnL.OptimizationSetting(
        verbose=true,
    ),
);
Utest = ones(burger.time_dim, 1);  # Reference input/boundary condition for OpInf testing o

μ = burger.diffusion_coeffs[1]

 ## Create testing data
A, F, B = burger.finite_diff_model(burger, μ)
C = ones(1, burger.spatial_dim) / burger.spatial_dim
Xtest = burger.integrate_model(burger.tspan, burger.IC, Utest; linear_matrix=A,
                                control_matrix=B, quadratic_matrix=F, system_input=true)
Ytest = C * Xtest

op_burger = LnL.Operators(A=A, B=B, C=C, A2u=F)

## training data for inferred dynamical models
Urand = rand(burger.time_dim, num_inputs)
Xall = Vector{Matrix{Float64}}(undef, num_inputs)
Xdotall = Vector{Matrix{Float64}}(undef, num_inputs)
for j in 1:num_inputs
    states = burger.integrate_model(burger.tspan, burger.IC, Urand[:, j], linear_matrix=A,
                                        control_matrix=B, quadratic_matrix=F, system_input=true)
    Xall[j] = states[:, 2:end]
    Xdotall[j] = (states[:, 2:end] - states[:, 1:end-1]) / burger.Δt
end
X = reduce(hcat, Xall)
R = reduce(hcat, Xdotall)
U = reshape(Urand[2:end,:], (burger.time_dim - 1) * num_inputs, 1)
Y = C * X

Test = (burger, options, μ, A, F, B, C, Utest, Xtest, Ytest, op_burger, Urand, Xall, Xdotall, X, R, U, Y)
save_object("test_trajectories.jld2", Test)
