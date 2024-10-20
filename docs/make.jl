using NPINR
using Documenter

DocMeta.setdocmeta!(NPINR, :DocTestSetup, :(using NPINR); recursive=true)

makedocs(;
    modules=[NPINR],
    authors="Mohammed Alshahrani <mmogib@gmail.com> and contributors",
    sitename="NPINR.jl",
    format=Documenter.HTML(;
        canonical="https://mmogib.github.io/NPINR.jl",
        edit_link="master",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/mmogib/NPINR.jl",
    devbranch="master",
)
