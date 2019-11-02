

export getContext, setContext, resetContext, ctx, hasgpu, is_on_gpu, KorA, ϵ

const ϵ = 10e-8

abstract type Meter end
abstract type MetricStore end
abstract type Layer end


mutable struct Context
	device::Symbol
	deviceId::Int
	dtype::Type

	function Context()
		device = Knet.gpu() >= 0 ? :gpu : :cpu
		new(device, 0, Float32)
	end
end

global ctx = Context()


function is_on_gpu()
	ctx.device == :gpu
end

hasgpu() = Knet.gpu() >= 0

function getContext()
  ctx
end

function setContext(;device=ctx.device, deviceId=ctx.deviceId, dtype=ctx.dtype)
  ctx.device = device
  ctx.deviceId = deviceId
  ctx.dtype= dtype
  getContext()
end


function resetContext()
	global ctx
	ctx = Context()
end

"""
KorA makes it easy to move an array to the GPU or the other way around
"""
KorA(arr::Array) = (ctx.device == :gpu) ? Knet.KnetArray(arr) : arr
KorA(arr::Knet.KnetArray)= (ctx.device == :cpu) ? Array(arr) : arr
KorA(arr::Tuple)= (KorA(elem) for elem in arr)


# TODO: Make more generic
toFloat32(arr::Array) = convert(Array{Float32}, arr)
toFloat32(arr::Knet.KnetArray) = convert(Knet.KnetArray{Float32}, arr)
toFloat32(arr::Tuple) = (toFloat32(elem) for elem in arr)


addlast(x) = reshape(x, (size(x)...,1))
droplast(x) = reshape(x, (size(x)[1:end-1]...))


"""
autoConvertor converts data to the right format for a model.
It uses the context to determine the device (cpu or gpu) and datatype
that the data needs to be.

It supports Tuples, Arrays and KnetArrays and a combination of those.
"""
function autoConvertor(arr::Array)
	arr = convert(Array{ctx.dtype},arr)
	ctx.device == :gpu ? Knet.KnetArray(arr) : arr
end

function autoConvertor(arr::Knet.KnetArray)
	arr = convert(Knet.KnetArray{ctx.dtype}, arr)
	ctx.device == :gpu ? arr : Array(arr)
end

autoConvertor(arr::Tuple)= (autoConvertor(elem) for elem in arr)
