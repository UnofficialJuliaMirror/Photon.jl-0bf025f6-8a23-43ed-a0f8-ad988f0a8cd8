module MetricsTests

using Photon, Test


function simple_conv_model()
    model = Sequential(
        Conv2D(4, 3, relu),
        Conv2D(8, 3, relu),
        MaxPool2D(),
        Dense(16, relu),
        Dense(10)
    )
    return model
end


function getdata(s=28)
    [(
        KorA(randn(Float32,s,s,1,16)),
        KorA(randn(Float32,10,16))
    ) for i=1:10]
end


function test_callbacks()
    model = simple_conv_model()
    workout = Workout(model, MSELoss())

    data = getdata()

    fit!(workout, data, epochs=2, cb=AutoSave(:loss))

    fit!(workout, data, epochs=2, cb=EpochSave())

    fit!(workout, data, epochs=2, cb=EarlyStop(:loss))
end


function test_core()
    model = simple_conv_model()
    workout = Workout(model, MSELoss())

    data = getdata()
    fit!(workout, data, epochs=2)
    h = history(workout, :loss)

    @test h isa Tuple
    @test length(h[1]) == length(h[2])
end

function test_metrics()
    y_pred = rand(10,16)
    y_true = rand(0:1,10,16)
    b = BinaryAccuracy()
    acc = b(y_pred, y_true)

    o = OneHotBinaryAccuracy()
    cc = o(y_pred, y_true)

end

function test_algo()

    pred   = [[0.3 0.7]; [0. 1.]; [0.4 0.6]]
    labels = [[1 0];[0 1];[0 1]]
    loss = CrossEntropyLoss()
    @assert loss(pred, labels) ≈ 0.5715992760

    pred   = reshape(Array([3, -0.5, 2, 7]), (4,1))
    labels = reshape(Array([2.5, 0.0, 2, 8]), (4,1))
    loss = L1Loss()
    @assert loss(pred,labels) ≈ 0.5

    pred   = reshape(Array([3, -0.5, 2, 7]), (4,1))
    labels = reshape(Array([2.5, 0.0, 2, 8]), (4,1))
    loss = L2Loss()
    @assert loss(pred,labels) ≈ 0.375

    pred   = [[0.3 0.7]; [0. 1.]; [0.4 0.6]]
    labels = [[1 0];[0 1];[0 1]]
    loss = BinaryAccuracy()
    @assert loss(pred, labels) ≈ 0.666666666666

end

@testset "Metrics" begin
    resetContext()
    test_callbacks()
    test_core()
    test_metrics()
    test_algo()
end

end
