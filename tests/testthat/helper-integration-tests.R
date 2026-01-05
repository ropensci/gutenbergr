# Skip integration tests unless explicitly enabled
skip_if_not_integration <- function() {
  if (!identical(Sys.getenv("RUN_INTEGRATION_TESTS"), "true")) {
    skip(
      "Integration tests not enabled. Set RUN_INTEGRATION_TESTS=true to run."
    )
  }
}
