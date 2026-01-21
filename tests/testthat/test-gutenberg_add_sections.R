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
    data <- tibble::tibble(
      gutenberg_id = c(1, 1, 1),
      text = c("CHAPTER I", "Text 1", "Text 2"),
      other_col = c("a", "b", "c")
    )

    result <- gutenberg_add_sections(
      data,
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
    data <- tibble::tibble(
      text = c("Chapter 1", "Text", "Chapter 2", "More text")
    )

    to_numeric <- function(x) as.numeric(stringr::str_extract(x, "\\d+"))

    result <- gutenberg_add_sections(
      data,
      pattern = "^Chapter \\d+",
      format_fn = to_numeric
    )

    expect_type(result$section, "double")
    expect_equal(result$section[c(1, 3)], c(1, 2))
  })

  test_that("ignore_case controls matching (table-driven)", {
    cases <- tibble::tibble(
      ignore_case = c(TRUE, FALSE),
      expected = list(
        # ignore_case = TRUE
        c(
          "chapter i",
          "chapter i",
          "CHAPTER II",
          "CHAPTER II",
          "Chapter III",
          "Chapter III"
        ),
        # ignore_case = FALSE
        c(
          NA,
          NA,
          "CHAPTER II",
          "CHAPTER II",
          "CHAPTER II",
          "CHAPTER II"
        )
      )
    )

    for (i in seq_len(nrow(cases))) {
      result <- gutenberg_add_sections(
        mixed_case_chapters,
        pattern = "^CHAPTER [IVXLCDM]+",
        ignore_case = cases$ignore_case[i]
      )

      expect_equal(result$section, cases$expected[[i]])
    }
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
    data <- tibble::tibble(
      gutenberg_id = c(1, 1, 1, 2, 2, 2),
      text = c(
        "CHAPTER I",
        "Text 1",
        "Text 2",
        "CHAPTER II",
        "Text 3",
        "Text 4"
      )
    )

    result <- gutenberg_add_sections(
      data,
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
    empty <- tibble::tibble(text = character())
    headers_only <- tibble::tibble(
      text = c("CHAPTER I", "CHAPTER II", "CHAPTER III")
    )

    result_empty <- gutenberg_add_sections(
      empty,
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
})
