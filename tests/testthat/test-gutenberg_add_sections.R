# Basic data without IDs
chapter_basic <- tibble::tribble(
  ~text        ,
  "CHAPTER I"  ,
  "Text 1"     ,
  "Text 2"     ,
  "CHAPTER II" ,
  "Text 3"
)

# Data with IDs for grouping tests
chapter_with_ids <- tibble::tribble(
  ~gutenberg_id , ~text       ,
              1 , "CHAPTER I" ,
              1 , "Text 1"    ,
              1 , "Text 2"    ,
              2 , "CHAPTER I" ,
              2 , "Text 3"
)

# Mixed case data for case sensitivity tests
mixed_case_chapters <- tibble::tribble(
  ~text         ,
  "chapter i"   ,
  "Text 1"      ,
  "CHAPTER II"  ,
  "Text 2"      ,
  "Chapter III" ,
  "Text 3"
)

# Data with no chapter markers for no-match tests
only_text <- tibble::tribble(
  ~text              ,
  "Just some text"   ,
  "No chapters here" ,
  "Nothing to see"
)

# Data with multiple grouping columns
multiple_group_cols <- tibble::tribble(
  ~author , ~book , ~text       ,
  "A"     ,     1 , "CHAPTER I" ,
  "A"     ,     1 , "Text"      ,
  "A"     ,     2 , "CHAPTER I" ,
  "B"     ,     1 , "CHAPTER I" ,
  "B"     ,     1 , "Text"      ,
  "B"     ,     2 , "CHAPTER I"
)

# Data with nested sections (books and chapters)
nested_sections_data <- tibble::tribble(
  ~text        ,
  "BOOK ONE"   ,
  "CHAPTER I"  ,
  "Text 1"     ,
  "CHAPTER II" ,
  "Text 2"     ,
  "BOOK TWO"   ,
  "CHAPTER I"  ,
  "Text 3"
)

# Data with extra columns for preserving columns test
data_with_extra_col <- tibble::tribble(
  ~gutenberg_id , ~text       , ~other_col ,
              1 , "CHAPTER I" , "a"        ,
              1 , "Text 1"    , "b"        ,
              1 , "Text 2"    , "c"
)

# Numeric chapter data for format_fn type conversion test
numeric_chapters <- tibble::tribble(
  ~text       ,
  "Chapter 1" ,
  "Text"      ,
  "Chapter 2" ,
  "More text"
)

# Data for group_by = NULL test (crosses books)
cross_book_data <- tibble::tribble(
  ~gutenberg_id , ~text        ,
              1 , "CHAPTER I"  ,
              1 , "Text 1"     ,
              1 , "Text 2"     ,
              2 , "CHAPTER II" ,
              2 , "Text 3"     ,
              2 , "Text 4"
)

# Edge case data
empty_data <- tibble::tribble(
  ~text
)

headers_only <- tibble::tribble(
  ~text         ,
  "CHAPTER I"   ,
  "CHAPTER II"  ,
  "CHAPTER III"
)

describe("gutenberg_add_sections()", {
  test_that("adds section column and preserves data", {
    result <- gutenberg_add_sections(
      chapter_basic,
      pattern = "^CHAPTER [IVXLCDM]+"
    )

    expect_true("section" %in% names(result))
    expect_false("is_header" %in% names(result))
    expect_equal(nrow(result), nrow(chapter_basic))
  })

  test_that("fills sections downward", {
    result <- gutenberg_add_sections(
      chapter_basic,
      pattern = "^CHAPTER [IVXLCDM]+"
    )

    expect_section_fill(result, 1:3, "CHAPTER I")
    expect_section_fill(result, 4:5, "CHAPTER II")
  })

  test_that("handles no matches", {
    result <- gutenberg_add_sections(
      only_text,
      pattern = "^CHAPTER [IVXLCDM]+"
    )

    expect_true(all(is.na(result$section)))
  })

  test_that("preserves non-text columns", {
    result <- gutenberg_add_sections(
      data_with_extra_col,
      pattern = "^CHAPTER [IVXLCDM]+"
    )

    expect_equal(result$other_col, c("a", "b", "c"))
  })

  test_that("format_fn transforms section values", {
    extract_num <- function(x) stringr::str_extract(x, "[IVXLCDM]+$")

    result <- gutenberg_add_sections(
      chapter_basic,
      pattern = "^CHAPTER [IVXLCDM]+",
      format_fn = extract_num
    )

    expect_section_fill(result, 1:3, "I")
    expect_section_fill(result, 4:5, "II")
  })

  test_that("format_fn can change type", {
    to_numeric <- function(x) as.numeric(stringr::str_extract(x, "\\d+"))

    result <- gutenberg_add_sections(
      numeric_chapters,
      pattern = "^Chapter \\d+",
      format_fn = to_numeric
    )

    expect_type(result$section, "double")
    expect_equal(result$section[c(1, 3)], c(1, 2))
  })

  test_that("ignore_case = TRUE matches case-insensitively", {
    result <- gutenberg_add_sections(
      mixed_case_chapters,
      pattern = "^CHAPTER [IVXLCDM]+",
      ignore_case = TRUE
    )

    expect_equal(
      result$section,
      c(
        "chapter i",
        "chapter i",
        "CHAPTER II",
        "CHAPTER II",
        "Chapter III",
        "Chapter III"
      )
    )
  })

  test_that("ignore_case = FALSE matches case-sensitively", {
    result <- gutenberg_add_sections(
      mixed_case_chapters,
      pattern = "^CHAPTER [IVXLCDM]+",
      ignore_case = FALSE
    )

    expect_equal(
      result$section,
      c(
        NA,
        NA,
        "CHAPTER II",
        "CHAPTER II",
        "CHAPTER II",
        "CHAPTER II"
      )
    )
  })

  test_that("groups by gutenberg_id by default", {
    result <- gutenberg_add_sections(
      chapter_with_ids,
      pattern = "^CHAPTER [IVXLCDM]+"
    )

    expect_section_fill(result, 1:3, "CHAPTER I")
    expect_section_fill(result, 4:5, "CHAPTER I")
  })

  test_that("accepts custom group_by columns", {
    result <- gutenberg_add_sections(
      multiple_group_cols,
      pattern = "^CHAPTER [IVXLCDM]+",
      group_by = c("author", "book")
    )

    expect_equal(result$section[c(1, 2)], c("CHAPTER I", "CHAPTER I"))
    expect_equal(result$section[3], "CHAPTER I")
    expect_equal(result$section[c(4, 5)], c("CHAPTER I", "CHAPTER I"))
    expect_equal(result$section[6], "CHAPTER I")
  })

  test_that("group_by = NULL treats input as a single document", {
    result <- gutenberg_add_sections(
      cross_book_data,
      pattern = "^CHAPTER [IVXLCDM]+",
      group_by = NULL
    )

    expect_section_fill(result, 1:3, "CHAPTER I")
    expect_section_fill(result, 4:6, "CHAPTER II")
  })

  test_that("returns ungrouped data", {
    result <- gutenberg_add_sections(
      chapter_with_ids,
      pattern = "^CHAPTER [IVXLCDM]+"
    )

    expect_false(dplyr::is_grouped_df(result))
  })

  test_that("handles edge cases", {
    result_empty <- gutenberg_add_sections(
      empty_data,
      pattern = "^CHAPTER [IVXLCDM]+"
    )

    result_headers <- gutenberg_add_sections(
      headers_only,
      pattern = "^CHAPTER [IVXLCDM]+"
    )

    expect_equal(nrow(result_empty), 0)
    expect_true("section" %in% names(result_empty))
    expect_equal(
      result_headers$section,
      c("CHAPTER I", "CHAPTER II", "CHAPTER III")
    )
  })

  test_that("handles custom and nested section columns", {
    res <- nested_sections_data |>
      gutenberg_add_sections(
        pattern = "^BOOK [A-Z]+",
        section_col = "book_name"
      ) |>
      gutenberg_add_sections(
        pattern = "^CHAPTER [IVXLCDM]+",
        section_col = "chapter_name"
      )

    expect_true(all(c("book_name", "chapter_name") %in% colnames(res)))
    expect_equal(res$book_name[1:5], rep("BOOK ONE", 5))
    expect_equal(res$book_name[6:8], rep("BOOK TWO", 3))
    expect_true(is.na(res$chapter_name[1]))
    expect_equal(res$chapter_name[2:3], rep("CHAPTER I", 2))
    expect_equal(res$chapter_name[4:5], rep("CHAPTER II", 2))
  })
})
