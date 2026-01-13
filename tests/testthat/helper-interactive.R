local_interactive <- function(value, env = parent.frame()) {
  testthat::local_mocked_bindings(
    interactive = function() value,
    .package = "base",
    .env = env
  )
}
