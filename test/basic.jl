module BasicTests

using Photon, Test

function KorATest()
    a = randn(10,10)
    b = KorA(a)
    @test size(a) == size(b)
    @test isapprox(sum(a), sum(b))
end


function contextTest()
    setContext(device=:cpu)
    @test getContext().device == :cpu

    setContext( dtype=Float32)
    @test getContext().dtype == Float32

    setContext(deviceId = 2)
    @test getContext().deviceId == 2

    resetContext()
end

function cpuTest()
    setContext(device=:cpu)

    a = KorA(randn(10,10))
    @test a isa Array
end

@testset "Basic" begin
    KorATest()
    contextTest()
    cpuTest()
end

end
