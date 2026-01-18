# Skip integration tests unless explicitly enabled
skip_if_not_integration <- function() {
  if (!identical(Sys.getenv("RUN_INTEGRATION_TESTS"), "true")) {
    skip(
      "Integration tests not enabled. Run `Sys.setenv(RUN_INTEGRATION_TESTS = 'true')` to enable."
    )
  }
}
