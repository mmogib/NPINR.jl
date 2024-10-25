"""
    solve(p::NLProblem, method::AbstractNewtonRaphson=NPINewtonRaphson(); max_itrs::Integer=10, tol::Float64=1e-6, verpose::Bool=false)

Solves a nonlinear optimization problem specified by an `NLProblem` struct using a selected Newton-Raphson method. This function iteratively approximates the solution to `p.f(x) = 0`, aiming to reach a solution within the given tolerance or maximum number of iterations.

# Arguments
- `p::NLProblem`: A problem instance containing the function `f` to solve and initial guess `x0`.
- `method::AbstractNewtonRaphson`: The variant of Newton-Raphson method to use. Defaults to `NPINewtonRaphson`.
- `max_itrs::Integer`: The maximum number of iterations allowed for convergence (default: 10).
- `tol::Float64`: The convergence tolerance level (default: 1e-6).
- `verpose::Bool`: If `true`, displays iteration details and a table of intermediate results.

# Returns
- `sol::NLSolution`: An `NLSolution` instance with the solution point `xstar`, final function value, number of iterations, convergence status, and additional solver details.

If `verpose` is `true`, displays a detailed iteration table with information on step sizes and gradient norms.

# Example
```julia
# Define the nonlinear problem
p = NLProblem(x -> x[1]^2 + x[2]^2 - 1, [0.5, 0.5])  # Solve min f(x)  with x0 = [0.5, 0.5]

# Solve the problem using default method
solution = solve(p)

# Display solution
println("Optimal solution found: ", solution.xstar)
println("Function value at solution: ", solution.f_value)
```
"""

function solve(
    p::NLProblem,
    method::AbstractNewtonRaphson = NPINewtonRaphson();
    max_itrs::Integer = 10,
    tol::Float64 = 1e-6,
    verpose::Bool = false,
)
    xstar, f_value, num_iterations, iterations, output_flag =
        _solve(p.f, p.x0, method, max_itrs = max_itrs, tol = tol)

    verpose && printstyled("Using $method with \t x0=$(p.x0)\n", color = :green)
    sol =
        NLSolution(p, xstar, f_value, num_iterations, iterations, tol, output_flag, method)

    if !verpose
        return sol
    else
        fvals = map(x -> p.f(vec(Float64.(x))), eachrow(iterations[:, 2:1+length(p.x0)]))
        T = hcat(iterations, fvals)
        T_header = (
            vcat(
                "k",
                ("x_$i" for i = 1:length(p.x0))...,
                "||x_{k}-x_{k-1}||",
                "||x_{k}-x_{0}||",
                "∇f(x)",
                "f(x)",
            ),
            vcat("", ("" for i = 1:length(p.x0))..., "ϵ=$tol", "", "", ""),
        )
        pretty_table(T, header = T_header)
        return sol
    end
end

function _solve(
    f::Function,
    X0::Vector{<:Number},
    method::AbstractNewtonRaphson = NPINewtonRaphson();
    max_itrs::Integer = 10,
    tol::Float64 = 1e-6,
)
    H(x) = hessian(f, x)
    g(x) = gradient(f, x)
    calcuate_Hv_InvH_S(y) = begin
        Gradf, = g(y)
        Hv = H(y)
        InvH = pinv(Hv)
        s = InvH * Gradf
        s, Hv, InvH
    end
    new_x = begin
        if isa(method, NPINewtonRaphson)
            (y) -> begin
                s, Hv, InvH = calcuate_Hv_InvH_S(y)
                InvH * Hv * y - s
            end
        else
            (y) -> begin
                s, = calcuate_Hv_InvH_S(y)
                y - s
            end
        end
    end
    X1 = Xstart = copy(X0)
    k = 1
    T = Matrix{Union{String,Float64}}(undef, max_itrs + 1, length(X0) + 4)

    T[1, :] = vcat(0.0, X0..., "---", "---", "---")
    while true
        if (k > max_itrs)
            return X1, f(X1), k, T[1:max_itrs+1, :], MAX_ITERATIONS
        end
        X1 = new_x(X0)
        norm_gx1 = norm(g(X1))
        norm_x1_x0 = norm(X1 - X0)
        norm_xk_x0 = norm(X1 - Xstart)

        T[k+1, :] = vcat(k, X1..., norm_x1_x0, norm_xk_x0, norm_gx1)

        if norm_gx1 <= tol
            return X1, f(X1), k, T[1:k+1, :], SMALL_GRADIENT
        end

        if norm_x1_x0 <= tol
            return X1, f(X1), k, T[1:k+1, :], SMALL_PROGRESS
        end
        X0 = X1
        k += 1
    end

end



export solve