# NPINR

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://mmogib.github.io/NPINR.jl/stable/)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://mmogib.github.io/NPINR.jl/dev/)
[![Build Status](https://github.com/mmogib/NPINR.jl/actions/workflows/CI.yml/badge.svg?branch=master)](https://github.com/mmogib/NPINR.jl/actions/workflows/CI.yml?query=branch%3Amaster)
[![Build Status](https://ci.appveyor.com/api/projects/status/github/mmogib/NPINR.jl?svg=true)](https://ci.appveyor.com/project/mmogib/NPINR-jl)



# NPINR.jl

`NPINR.jl` is a Julia package for solving nonlinear optimization problems using various Newton-Raphson based methods, including custom approaches for improving performance in iterative solutions. This package provides tools to define optimization problems, solve them with a variety of methods, and visualize the results.

## Features
- Define and solve nonlinear optimization problems with flexible initialization.
- Support for multiple Newton-Raphson methods (such as `NPINewtonRaphson` and `GINewtonRaphson`).
- Detailed reporting on iterations, gradients, and convergence steps.
- Plotting recipes to visualize solutions and track optimization progress.
- Save solution data in multiple formats, including `.png`, `.pdf`, `.xlsx`, `.csv`, and `.txt`.

## Installation

To install `NPINR.jl`, use the Julia package manager:

```julia
using Pkg
Pkg.add("NPINR")
```

## Usage

Here is an example of defining an optimization problem, solving it, and plotting the results.

### Example Workflow

1. **Define a Nonlinear Problem**

   Define a function and an initial point for the problem.

   ```julia
   using NPINR

   # Define the objective function
   f1(x::Vector{<:Number}) = (x[1] - 1)^4 + (x[2] - 2)^3
   x0 = [1.0; 0.0]
   xstars = [[1.0; 2.0]]  # Expected solution

   # Create a nonlinear problem instance
   P1 = NLProblem(f1, x0, xstars, [(t -> t, t -> t^2)])
   ```

2. **Solve the Problem**

   Use the `solve` function with the default Newton-Raphson method.

   ```julia
   # Solve the problem with verbose output
   sol1 = solve(P1; verpose = true)
   ```

3. **Plot the Solution**

   Plot the solution with titles and save to a specified format.

   ```julia
   # Plot the solution
   using Plots
   p1 = plot(sol1, title = "Plotting the solution - 1")
   savefig(p1, "./results/p1.png")
   ```

4. **Additional Examples and Methods**

   You can create and solve additional problems, using various Newton-Raphson methods and output formats.

   ```julia
   f2(x::Vector{<:Number}) = 2(x[1])^2 + 0.5(x[2])^2 + 2x[1] * x[2]
   P2 = NLProblem(f2, [1.0; 0.0], nothing, [(t -> t, t -> -2t), (t -> t, t -> -2t)])
   sol2 = solve(P2; verpose = true)
   p2 = plot(sol2, title = "Plotting the solution - 2")
   savefig(p2, "./results/p2.pdf")

   ```

## Documentation

For more information on available functions, types, and methods, consult the [documentation](https://mmogib.github.io/NPINR.jl/dev/).

### Contributing
Contributions are welcome! Feel free to open issues or submit pull requests with improvements or new features.

### License
This project is licensed under the MIT License. See the `LICENSE` file for details.