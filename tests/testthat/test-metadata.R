context("Gutenberg metadata")

test_that("gutenberg_works does appropriate filtering by default", {
  w <- gutenberg_works()

  expect_true(all(w$language == "en"))
  expect_false(any(grepl("Copyright", w$rights)))
  expect_gt(nrow(w), 40000)
})


test_that("gutenberg_works takes filtering conditions", {
  w2 <- gutenberg_works(author == "Shakespeare, William")
  expect_gt(nrow(w2), 30)
  expect_true(all(w2$author == "Shakespeare, William"))
})


test_that("gutenberg_works does appropriate filtering by language", {
  w_de <- gutenberg_works(languages = "de")
  expect_true(all(w_de$language == "de"))

  w_lang <- gutenberg_works(languages = NULL)
  expect_gt(length(unique(w_lang$language)), 50)
})
