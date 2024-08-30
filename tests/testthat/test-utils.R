test_that("read_url can download and read a zip file", {
  skip_on_cran()

  # read Bill of Rights (small file)
  z <- read_url("http://gutenberg.pglaf.org/0/2/2.zip", ".zip")

  expect_true(
    any(
      z == "Congress shall make no law respecting an establishment of religion,"
    )
  )
})


test_that("read_url returns NULL on non-existent zip file", {
  skip_on_cran()
  z2 <- read_url("http://gutenberg.pglaf.org/0/2/THISISNOTAFILE.zip", ".zip")

  expect_null(z2)
})


test_that("read_url can download and read a txt file", {
  skip_on_cran()

  z3 <- read_url("https://www.gutenberg.org/cache/epub/68283/pg68283.txt", ".txt")

  expect_true(
    any(
      z3 == "The CALL of CTHULHU"
    )
  )
})


test_that("read_url returns NULL on non-existent txt file", {
  skip_on_cran()
  z4 <- read_url("http://gutenberg.pglaf.org/0/2/23.txt", ".txt")

  expect_null(z4)
})


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
