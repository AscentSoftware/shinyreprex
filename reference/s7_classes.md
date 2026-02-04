# Custom S7 Classes

Additional classes to include in S7 to use in `repro_code` and
`repro_code_chunk` methods:

### Reactives

These variables need to be handled in a specific way to extract
non-static values stored in reactive calls.

- class_reactive:

  The class capturing
  [`shiny::reactive()`](https://rdrr.io/pkg/shiny/man/reactive.html)
  calls

- class_event_cache:

  The class capturing
  [`shiny::bindCache()`](https://rdrr.io/pkg/shiny/man/bindCache.html)
  calls

- class_event_reactive:

  The class capturing
  [`shiny::bindEvent()`](https://rdrr.io/pkg/shiny/man/bindEvent.html)
  calls

- class_bind_reactive:

  The union of `class_event_cache` and `class_event_reactive`

### Special Functions

When determining evaluating a chunk, the function name gets attached to
the class of the chunk, these are special cases that need to be handled
in a non-standard way.

- class_call_function:

  The class capturing anonymous function definitions

- class_call_reactive:

  The class capturing evaluated
  [`shiny::reactive()`](https://rdrr.io/pkg/shiny/man/reactive.html)
  objects

- class_call_reactval:

  The class capturing evaluated
  [`shiny::reactiveValues()`](https://rdrr.io/pkg/shiny/man/reactiveValues.html)
  objects

- class_call_if:

  The class capturing `if` calls

- class_call_null:

  The class capturing undefined calls, such as `pkg::fn`

- class_call_shiny:

  The class capturing ignorable shiny function calls such as
  [`shiny::req()`](https://rdrr.io/pkg/shiny/man/req.html) and
  [`shiny::validate()`](https://rdrr.io/pkg/shiny/man/validate.html)

- class_call_subset:

  The class capturing a subset (`$`) call
