test_that("keep_while works", {
  x <- c("a", "b", "c", "d")
  expect_equal(keep_while(x, rep(TRUE, 4)), x)
  expect_equal(keep_while(x, c(TRUE, TRUE, FALSE, FALSE)), x[1:2])
  expect_equal(keep_while(x, c(FALSE, FALSE, FALSE, FALSE)), x)
})

test_that("discard_start_while works", {
  x <- c("a", "b", "c", "d")
  expect_equal(discard_start_while(x, rep(TRUE, 4)), x)
  expect_equal(discard_start_while(x, c(TRUE, TRUE, FALSE, FALSE)), x[3:4])
  expect_equal(discard_start_while(x, c(FALSE, FALSE, FALSE, FALSE)), x)
})

test_that("discard_end_while works", {
  x <- c("a", "b", "c", "d")
  expect_equal(discard_end_while(x, rep(TRUE, 4)), x)
  expect_equal(discard_end_while(x, c(TRUE, TRUE, FALSE, FALSE)), x)
  expect_equal(discard_end_while(x, c(FALSE, FALSE, TRUE, TRUE)), x[1:2])
  expect_equal(discard_end_while(x, c(FALSE, FALSE, FALSE, FALSE)), x)
})

test_that("maybe_message might message", {
  expect_message(
    maybe_message(TRUE, "xyz"),
    "xyz"
  )
  expect_no_message(
    maybe_message(FALSE, "xyz")
  )
})

test_that("read_url can download and read a zip file", {
  local_dl_and_read()
  # read Bill of Rights (small file)
  z <- read_url("http://gutenberg.pglaf.org/0/2/2.zip")
  expect_true(any(z == "Ratified December 15, 1791"))
})

test_that("read_url silently returns NULL on non-existent zip file", {
  local_dl_and_read()
  z <- read_url("http://gutenberg.pglaf.org/0/2/THISISNOTAFILE.zip")
  expect_no_warning(expect_null(z))
})

test_that("read_url can download and read a txt file", {
  local_dl_and_read()
  z <- read_url("https://www.gutenberg.org/cache/epub/68283/pg68283.txt")
  expect_true(any(z == "The CALL of CTHULHU"))
})

test_that("read_url returns NULL on non-existent txt file", {
  local_dl_and_read()
  z <- read_url("http://gutenberg.pglaf.org/0/2/THISISNOTAFILE.txt")
  expect_no_warning(expect_null(z))
})
