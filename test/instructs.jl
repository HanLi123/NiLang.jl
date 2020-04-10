using NiLang
using Test

@testset "⊕, ⊖" begin
    x, y = 0.2, 0.5
    @instr x ⊕ y
    @test x == 0.7 && y==0.5
end

@testset "*, /" begin
    x, y, out = 2.0, 2.0, 1.0
    @instr out += x * y
    @test x == 2.0 && y == 2.0 && out == 5.0
    x, y, out = 2.0, 2.0, 1.0
    @instr out += x / y
    @test x == 2.0 && y == 2.0 && out == 2.0

    out = Fixed43(0.0)
    x = 1
    @instr out += x/2
    @test out === Fixed43(0.5)
    @instr out -= x/2
    @test out === Fixed43(0.0)
end

@testset "SWAP" begin
    x, y = 1, 2
    @instr SWAP(x, y)
    @test x == 2 && y == 1
end

@testset "NEG" begin
    x = 0.3
    @instr NEG(x)
    @test x == -0.3
    @test check_inv(NEG, (x,))
end

@testset "FLIP" begin
    x = false
    @instr FLIP(x)
    @test x == true
    @test check_inv(FLIP, (x,))
end

@testset "ROT" begin
    x, y, θ = 0.0, 1.0, π
    @test check_inv(ROT, (x, y, θ); verbose=true)
    @test check_inv(IROT, (x, y, θ); verbose=true)
end

@testset "mulint" begin
    x, y = 3.3, 2
    @test check_inv(mulint, (x, y); verbose=true)
    @test check_inv(divint, (x, y); verbose=true)
end

@testset "stack operations" begin
    x =0.3
    @instr ipush!(x)
    @test x === 0.0
    @instr ipop!(x)
    @test x === 0.3
    @instr ipush!(x)
    x = 0.4
    @test_throws InvertibilityError @instr ipop!(x)

    x =0.3
    st = Float64[]
    @instr ipush!(st, x)
    @test x === 0.0
    @test length(st) == 1
    @instr ipop!(st, x)
    @test length(st) == 0
    @test x === 0.3
    @instr ipush!(st, x)
    @test length(st) == 1
    x = 0.4
    @test_throws InvertibilityError @instr ipop!(x)
    @test length(st) == 1

    @i function test(x)
        x2 ← zero(x)
        x2 += x^2
        ipush!(x)
        SWAP(x, x2)
    end
    @test test(3.0) == 9.0
    l = length(NiLang.GLOBAL_STACK)
    @test check_inv(test, (3.0,))
    @test length(NiLang.GLOBAL_STACK) == l
end
