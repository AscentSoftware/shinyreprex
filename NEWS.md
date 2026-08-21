# shinyreprex 0.2.0

New features:

* Handling special cases of additional base functions `switch` and `[[`

Bug fixes:

* Correctly reproduce unbraced `if`/`else` branches. Previously a branch that was a
  single expression rather than a `{` block had its function call stripped, producing
  a script containing only the call's arguments, and any package used solely in that
  branch went undetected

Other updates:

* Update to the logo
* Add shinylive example to GitHub Pages

# shinyreprex 0.1.0

* This is the first release of shinyreprex
