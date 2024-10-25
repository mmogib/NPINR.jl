using NPINR
using Plots
using Test

@testset "NPINR.jl" begin
    # Write your tests here.
    f1(x::Vector{<:Number}) = (x[1] - 1)^4 + (x[2] - 2)^3
    x0 = [1.0; 0.0]
    xstars = [[1.0; 2.0]]
    P1 = NLProblem(f1, x0, xstars, [(t -> t, t -> t^2)])
    @test P1.f([1, 1]) == -1.0
    sol1 = solve(P1; verpose = true)
    @test isa(sol1, NLSolution)
    # Plot using the recipe
    p1 = plot(sol1, title = "Plotting the solution - 1")
    savefig(p1, "./results/p1.png")
    @test length(p1.series_list) == 3
    # save("./results/f1.xlsx", sol)
    # save("./results/f1.csv", sol)
    # save("./results/f1.txt", sol)
    # Test division by zero (this should throw an error)

    # @test_throws DivideError divit(1, 0)
    # Define the custom data

    P2 = NLProblem(f1, x0, xstars, nothing)
    sol2 = solve(P2; verpose = true)
    p2 = plot(sol2, title = "Plotting the solution - 2")
    savefig(p2, "./results/p2.pdf")
    @test length(p2.series_list) == 2


    P3 = NLProblem(f1, x0, nothing, [(t -> t, t -> t^2)])
    sol3 = solve(P3; verpose = true)
    p3 = plot(sol3, title = "Plotting the solution - 3")
    savefig(p3, "./results/p3.pdf")
    @test length(p3.series_list) == 2

    P4 = NLProblem(f1, x0)
    sol4 = solve(P4; verpose = true)
    p4 = plot(sol4, title = "Plotting the solution - 4")
    savefig(p4, "./results/p4.png")
    @test length(p4.series_list) == 1

    sol5 = solve(P4, GINewtonRaphson(); verpose = true)
    @test isa(sol5.method, GINewtonRaphson)

    f2(x::Vector{<:Number}) = 2(x[1])^2 + 0.5(x[2])^2 + 2x[1] * x[2]
    P6 = NLProblem(f2, [1.0; 0.0], nothing, [(t -> t, t -> -2t), (t -> t, t -> -2t)])
    sol6 = solve(P6; verpose = true)
    p6 = plot(sol6, title = "Plotting the solution - 6")
    @test length(p6.series_list) == 3


end
