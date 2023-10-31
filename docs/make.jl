# 231012: running via: /w/sync/mechgits/julia/HomogeneousTransformations.jl_public/docs (testItemRunner)$ julia --project make.jl 
using Documenter
using DocumenterTools
using DocStringExtensions
push!(LOAD_PATH, "../src/")
# display(LOAD_PATH)
using HomogeneousTransformations

makedocs(
  sitename="HomogeneousTransformations.jl",
  modules=[HomogeneousTransformations],
  root = joinpath(dirname(pathof(HomogeneousTransformations)), "..", "docs"),
  source = "src",
  build = "build",
  clean=true,
  doctest=true,
  draft=false,
  checkdocs=:all,
  # linkcheck=true, fails to find internal links to bookmarks..
  )

# compile custom theme scss in to css, copying over the default themes
DocumenterTools.Themes.compile("docs/src/assets/themes/documenter-mechanomy.scss", "docs/build/assets/themes/documenter-dark.css")
DocumenterTools.Themes.compile("docs/src/assets/themes/documenter-mechanomy.scss", "docs/build/assets/themes/documenter-light.css")

deploydocs(
  root = joinpath(dirname(pathof(HomogeneousTransformations)), "..", "docs"),
  target = "build",
  dirname = "",
  repo = "github.com/mechanomy/HomogeneousTransformations.jl.git",
  branch = "gh-pages",
  deps = nothing, 
  make = nothing,
  devbranch = "main",
  devurl = "dev",
  versions = ["stable" => "v^", "v#.#", "dev" => "dev"],
  forcepush = false,
  deploy_config = Documenter.auto_detect_deploy_system(),
  push_preview = false,
)

