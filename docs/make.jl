using RLAOpInf
using Documenter

DocMeta.setdocmeta!(RLAOpInf, :DocTestSetup, :(using RLAOpInf); recursive=true)

makedocs(;
    modules=[RLAOpInf],
    authors="Vivak Patel <vp314@users.noreply.github.com>",
    sitename="RLAOpInf.jl",
    format=Documenter.HTML(;
        canonical="https://numlinalg.github.io/RLAOpInf.jl",
        edit_link="main",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/numlinalg/RLAOpInf.jl",
    devbranch="main",
)
