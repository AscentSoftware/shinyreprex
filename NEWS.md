# shinyreprex 0.3.0

New features:

* `reprex_lockfile` captures the package versions, sources and R version needed to reproduce 
  one or more reactives as an `renv` lockfile, with `reprex_packages` exposing the detected 
  packages so they can be offered for selection
* `register_reactives` records reactives against the Shiny session, so `reprex_lockfile` 
  and `reprex_packages` can be called without arguments and still cover reactives owned by 
  separate modules

# shinyreprex 0.2.0

New features:

* Handling special cases of additional base functions `switch` and `[[`

Other updates:

* Update to the logo
* Add shinylive example to GitHub Pages

# shinyreprex 0.1.0

* This is the first release of shinyreprex
