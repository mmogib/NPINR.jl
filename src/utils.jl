function basenameparts(filename::String)
    parts = split(basename(filename), ".")
    if length(parts) == 1
        return parts[1], "UNKOWN"
    else
        return join(parts[1:end-1], "."), parts[end]
    end
end


function outputfilename(file_name::String; dated::Bool = true)
    fname = basename(file_name)
    root = dirname(file_name)
    root_dir = mkpath(root)
    filename = if dated
        fparts = basenameparts(fname)
        zdt = now(tz"Asia/Riyadh")
        dayfolder = Dates.format(zdt, "yyyy_mm_dd")
        hourfolder = Dates.format(zdt, "HH_MM")
        "$root_dir/$(fparts[1])_$(dayfolder)_$(hourfolder).$(fparts[2])"
    else
        "$root_dir/$fname"
    end

    filename
end

function savedf(filename::String, df::DataFrame; dated::Bool = true)
    fname = outputfilename(filename; dated)
    fparts = basenameparts(fname)
    ext = isnothing(fparts[2]) ? "UNKOWN" : lowercase(fparts[2])
    if ext in ["txt", "csv"]
        @info "Saving data in $(fname)."
        CSV.write(fname, df)
    elseif ext == "xlsx"
        @info "Saving data in $(fname)."
        XLSX.writetable(fname, df; overwrite = true)
    else
        @warn "The file $fname is not supported."
    end
end

function save(file_name::String, s::NLSolution; dated::Bool = true)
    # file_name = outputfilename(file_name, dated = dated)
    dim = length(s.p.x0)
    f_values = map(x -> s.p.f(vec(Float64.(x))), eachrow(s.iterations[:, 2:1+dim]))
    df = DataFrame(
        norm_xk_xk_minus_1 = s.iterations[:, 2+dim],
        norm_xk_x0 = s.iterations[:, 3+dim],
        f_values = f_values,
        g_value = s.iterations[:, 4+dim],
    )
    savedf(file_name, df; dated = dated)
end

# """
#     plot_it(f, xs, ys, points; xstars::Union{Nothing,Vector{Vector{T}}} where {T<:Number}=nothing, kwargs...)

# This function generates a plot of the function `f` over the specified ranges `xs` and `ys`, with scatter points
# representing the solutions. The function can also plot the solution points `xstars` if provided.

# # Arguments
# - `f`: The objective function to plot.
# - `xs`: Range of x-values.
# - `ys`: Range of y-values.
# - `points`: Points to be plotted on the graph.
# - `xstars`: (Optional) Solution points to be highlighted.
# - `kwargs`: Additional keyword arguments for customizing the plot (e.g., `xlims`, `ylims`).

# # Returns
# - `p`: The generated plot.
# """

# function plot_it(
#     f,
#     xs,
#     ys,
#     points;
#     xstars::Union{Nothing,Vector{Vector{T}},Vector{NTuple{N,Function}}} where {N,T<:Number} = nothing,
#     kwargs...,
# )

#     length(points) == 0 && return @warn "No points to plot."
#     length(points[1, :]) != 2 && return @warn "2D plots only are currently supported."

#     max_x, min_x = maximum(points[1, :]), minimum(points[1, :])
#     max_y, min_y = maximum(points[2, :]), minimum(points[2, :])
#     max_x, max_y, min_x, min_y = if isa(xstars, Vector{Vector{T}} where {T<:Number})
#         xs_s = map(v -> v[1], xstars)
#         ys_s = map(v -> v[2], xstars)
#         max(max_x, maximum(xs_s)),
#         max(max_y, maximum(ys_s)),
#         min(min_x, minimum(xs_s)),
#         min(min_y, minimum(ys_s))
#     else
#         max_x, max_y, min_x, min_y
#     end
#     kwargs = Dict{Symbol,Any}(kwargs)
#     kargs = Dict([:xlims => (min_x - 5, max_x + 5), :ylims => (min_y - 5, max_y + 5)])
#     kwargs = merge(kargs, kwargs)

#     p = plot(; plot_titlefontsize = 8, frame_style = :origin, margins = (2, :mm), kwargs...)
#     # p= contour(p, xs, ys, f)
#     p =
#         isnothing(xstars) ? p :
#         begin
#             if isa(xstars, Vector{Vector{T}} where {T<:Number})
#                 scatter(
#                     p,
#                     map(s -> s[1], xstars),
#                     map(s -> s[2], xstars),
#                     label = :none,
#                     c = :red,
#                     ms = 6,
#                     markeralpha = 0.5,
#                 )
#                 annotate!(
#                     map(
#                         x -> (x[2][1] + 0.4, x[2][2] + 0.4, L"x_{%$(x[1])}^*", :red),
#                         enumerate(xstars),
#                     ),
#                 )

#             else
#                 for pf in xstars
#                     x_t = range(kwargs[:xlims][1], stop = kwargs[:xlims][2], length = 200)
#                     y_t = range(kwargs[:ylims][1], stop = kwargs[:ylims][2], length = 200)
#                     f_t, g_t = pf
#                     p = plot(p, f_t.(x_t), g_t.(y_t), c = :red, label = nothing)
#                 end
#                 p = plot(p, c = :red, label = "Optimal Set")
#             end
#         end
#     p = scatter(p, points[:, 1], points[:, 2], label = :none, c = :blue)
#     p
# end

# """
#     run_all(problems::Union{Vector{Integer},AbstractRange}; kwargs...)

# Runs the Newton-Raphson solver on a set of nonlinear optimization problems, iterating through each problem,
# applying different methods (e.g., `GINR`, `NPINewtonRaphson`), and saving the results and plots to files.

# # Arguments
# - `problems`: A vector or range of problem indices to solve.
# - `kwargs`: Additional keyword arguments for customizing the plot or solver settings (e.g., `xlims`, `ylims`).

# # Returns
# - None (the function saves results and plots for each problem to the specified folder).
# """

# function run_all(
#     problems::Union{Vector{Integer},AbstractRange};
#     max_itrs::Integer = 10,
#     tol::Float64 = 1e-6,
#     kwargs...,
# )
#     # kwargs = Dict{Symbol,Any}(kwargs)
#     # kargs = Dict([:xlims => (-5, 5), :ylims => (-5, 5)])
#     # kwargs = merge(kargs, kwargs)

#     fns = getAllFunctions(problems)
#     if isnothing(fns)
#         return @error "Probelms requested not defined.. "
#     end

#     xs = ys = range(-5, stop = 5, length = 200)
#     @variables x y
#     folder = "./results/nonlinear_solve"
#     mkpath(folder)  # Create the results folder if it doesn't exist
#     println("Folder created at: $folder")

#     # Iterate over all function problems
#     pss = map(fns) do (f, x0, xstars)
#         println("Starting problem: f(x,y) = ", f(x, y))

#         # Define file name based on the function
#         file_name = "$folder/$(String(Symbol(f)))"
#         println("Saving results to: $file_name.txt and $file_name.png")

#         # Map over methods like GINR and NPINewtonRaphson
#         ps = map([GINR, NPINewtonRaphson]) do m
#             println("Running method: $(m()) for f(x, y) = ", f(x, y))
#             title_str = L"%$(m()) : f(x, y) =  %$(f(x, y))"

#             # Solve using Newton's method or any other solver
#             println("Solving the problem using method $(m())...")
#             X1, fX1, iters, Ps, flag, T, T_header =
#                 solve(f, x0, m(), max_itrs = max_itrs, tol = tol)

#             # Generate plots and return table data
#             println("Generating plots for method $(m())")
#             p = plot_it(
#                 f,
#                 xs,
#                 ys,
#                 Float64.(Ps);
#                 xstars = xstars,
#                 kwargs...,
#                 title = title_str,
#             )
#             p, T, T_header
#         end

#         # Write table data to a text file
#         println("Saving tables to: $file_name.txt")
#         open("$(file_name).txt", "w+") do fl
#             for i = 1:2
#                 pretty_table(fl, ps[i][2], header = ps[i][3])  # Save the table for each method
#             end
#         end

#         # Save plot images
#         println("Saving plots to: $file_name.png")
#         pls = map(first, ps)  # Extract the plots
#         l = @layout [
#             a{0.95w}
#             b{0.95w}
#         ]
#         savefig(plot(pls...; layout = l), "$(file_name).png")

#         println("Completed problem: f(x, y) = ", f(x, y))

#         ps  # Return the results for this function
#     end

#     println("All problems completed and results saved.")
# end

export save