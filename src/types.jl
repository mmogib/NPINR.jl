abstract type AbstractNewtonRaphson end
struct GINewtonRaphson <: AbstractNewtonRaphson end

struct NPINewtonRaphson <: AbstractNewtonRaphson end

Base.show(io::IO, t::GINewtonRaphson) = print(io, "GINewtonRaphson")
Base.show(io::IO, t::NPINewtonRaphson) = print(io, "NPINewtonRaphson")


struct NLProblem
    f::Function
    x0::Vector{T} where {T<:Number}
    xstars::Union{Vector{Vector{S}},Nothing} where {S<:Number}
    xstars_curves::Union{Vector{Tuple{Function,Function}},Nothing}
end

NLProblem(f::Function, x0::Vector{<:Number}) = NLProblem(f, x0, nothing, nothing)
NLProblem(
    f::Function,
    x0::Vector{T} where {T<:Number},
    xs::Vector{Vector{S}} where {S<:Number},
) = NLProblem(f, x0, xs, nothing)
NLProblem(
    f::Function,
    x0::Vector{T} where {T<:Number},
    xsf::Vector{Tuple{Function,Function}},
) = NLProblem(f, x0, nothing, xsf)

NLProblem(f::Function, x0::Vector{T} where {T<:Number}, xs::Vector{S} where {S<:Number}) =
    NLProblem(f, x0, [xs], nothing)
NLProblem(f::Function, x0::Vector{T} where {T<:Number}, xsf::Tuple{Function,Function}) =
    NLProblem(f, x0, nothing, [xsf])
NLProblem(
    f::Function,
    x0::Vector{T} where {T<:Number},
    xs::Vector{S} where {S<:Number},
    xsf::Tuple{Function,Function},
) = NLProblem(f, x0, [xs], [xsf])

@enum OutputFlag SMALL_PROGRESS = 1 SMALL_GRADIENT = 2 MAX_ITERATIONS = 3
struct NLSolution
    p::NLProblem
    xstar::Vector{T} where {T<:Number}
    f_value::Float64
    num_iterations::Union{Float64,Int64}
    iterations::Matrix{Union{S,String}} where {S<:Number}
    tol::Float64
    output_flag::OutputFlag
    method::AbstractNewtonRaphson
end
Base.show(io::IO, t::NLSolution) = print(io, "Problem: $(Symbol(t.output_flag))")


@recipe function f(s::NLSolution)
    # Apply plot attributes
    xlabel := ""
    ylabel := ""
    title := "Solutions with $(s.method)"
    legend := :topright
    frame_style := :origin
    dim = length(s.p.x0)
    xstars = s.p.xstars
    xstars_x, xstars_y =
        isnothing(xstars) ? ([], []) : (map(x -> x[1], xstars), map(x -> x[2], xstars))

    X = Float64.(s.iterations[:, 2:1+dim])
    max_x, min_x = maximum(vcat(X[:, 1], xstars_x)), minimum(vcat(X[:, 1], xstars_x))
    max_y, min_y = maximum(vcat(X[:, 2], xstars_y)), minimum(vcat(X[:, 2], xstars_y))
    min_xlim, max_xlim = min_x - 5, max_x + 5
    min_ylim, max_ylim = min_y - 5, max_y + 5
    xlims := (min_xlim, max_xlim)
    ylims := (min_ylim, max_ylim)
    # First series (y1)
    @series begin
        seriestype := :scatter
        linecolor := :blue
        label := "Iterations"
        series_annotations := [
            i == 1 ? (L"x_{%$(i-1)}", 20, :left, :bottom, :blue, 12) : "" for
            i = 1:length(X[:, 1])
        ]

        X[:, 1], X[:, 2]
    end

    # Second series: optimal points provided
    if !isnothing(xstars)
        @series begin
            seriestype := :scatter
            markercolor := :red
            label := :none
            ms := 6
            markeralpha := 0.5
            label := "Optimal Solutions"
            series_annotations :=
                [(L"x_{%$(i)}^*", 20, :left, :bottom, :red, 12) for i = 1:length(xstars_x)]

            xstars_x, xstars_y
        end
    end

    # Second series: optimal curves provided
    xstars_fns = s.p.xstars_curves
    if !isnothing(xstars_fns)
        xs = range(min_ylim, stop = max_ylim, length = 100)
        for (xf, yf) in xstars_fns
            @series begin
                seriestype := :path
                color := :red
                label := :none
                xf.(xs), yf.(xs)
            end
        end
    end

end


export NLProblem, NLSolution, AbstractNewtonRaphson, GINewtonRaphson, NPINewtonRaphson