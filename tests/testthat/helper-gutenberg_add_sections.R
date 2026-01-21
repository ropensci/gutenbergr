expect_section_fill <- function(result, rows, value) {
  expect_equal(
    result$section[rows],
    rep(value, length(rows))
  )
}

chapter_basic <- tibble::tibble(
  text = c(
    "CHAPTER I",
    "Text 1",
    "Text 2",
    "CHAPTER II",
    "Text 3"
  )
)

chapter_with_ids <- tibble::tibble(
  gutenberg_id = c(1, 1, 1, 2, 2),
  text = c(
    "CHAPTER I",
    "Text 1",
    "Text 2",
    "CHAPTER I",
    "Text 3"
  )
)

mixed_case_chapters <- tibble::tibble(
  text = c(
    "chapter i",
    "Text 1",
    "CHAPTER II",
    "Text 2",
    "Chapter III",
    "Text 3"
  )
)

only_text <- tibble::tibble(
  text = c(
    "Just some text",
    "No chapters here",
    "Nothing to see"
  )
)

multiple_group_cols <- tibble::tibble(
  author = c("A", "A", "A", "B", "B", "B"),
  book = c(1, 1, 2, 1, 1, 2),
  text = c(
    "CHAPTER I",
    "Text",
    "CHAPTER I",
    "CHAPTER I",
    "Text",
    "CHAPTER I"
  )
)
