# Testing

This package includes both unit tests (with mocked data) and integration tests (against the real Project Gutenberg API).

## Running Tests Locally

### Unit Tests Only

```r
devtools::test()
```

### Integration Tests Only

```r
Sys.setenv(RUN_INTEGRATION_TESTS = "true")
testthat::test_local(filter = "integration")
```

### All Tests

```r
Sys.setenv(RUN_INTEGRATION_TESTS = "true")
devtools::test()
```

## Why Separate Integration Tests?

1. **Speed**: Unit tests run quickly with mocked data
1. **Reliability**: Unit tests don't depend on network/API availability
1. **API Health**: Integration tests catch real-world API changes
1. **Rate Limiting**: Integration tests run less frequently to respect Project Gutenberg

## Troubleshooting

If integration tests fail:

1. **Check API Status**: Visit https://www.gutenberg.org/
1. **Network Issues**: Ensure you have internet connectivity
1. **Mirror Changes**: The API structure may have changed
1. **Rate Limiting**: Wait a few minutes and retry

## Adding New Integration Tests

When adding new integration tests:

1. Use `skip_if_not_integration()` at the start
1. Add `skip_on_cran()` to avoid CRAN submission issues
1. Add `skip_if_offline()` for network dependency
1. Use small books (IDs 1, 2, etc.)
1. Disable caching with `use_cache = FALSE` for clean tests
1. Name the test file with `test-integration-*.R` pattern

Example:
```r
test_that("new feature works with real API", {
  skip_if_not_integration()
  skip_on_cran()
  skip_if_offline()

  result <- gutenberg_download(1, use_cache = FALSE)

  # Your assertions here
})
```
