using NPINR
using Test

@testset "NPINR.jl" begin
    # Write your tests here.
    @test addit(1, 2) == 3
    @test addit(0, 0) == 0
    @test addit(-1, 1) == 0
    @test addit(10.5, 2.5) == 13.0

    @test divit(4, 2) == 2
    @test divit(9, 3) == 3
    @test divit(10.0, 5.0) == 2.0
    @test divit(-6, 2) == -3

    # Edge cases
    @test divit(0, 1) == 0  # 0 divided by any number is 0

    # Test division by zero (this should throw an error)
    @test_throws DivideError divit(1, 0)
end
