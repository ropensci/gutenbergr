describe("gutenberg_add_sections", {
  describe("basic functionality", {
    test_that("adds section column to data", {
      mock_data <- tibble(
        text = c(
          "CHAPTER I",
          "Some text",
          "More text",
          "CHAPTER II",
          "Other text"
        )
      )

      result <- gutenberg_add_sections(
        mock_data,
        pattern = "^CHAPTER [IVXLCDM]+"
      )

      expect_true("section" %in% colnames(result))
      expect_false("is_header" %in% colnames(result))
      expect_equal(nrow(result), nrow(mock_data))
    })

    test_that("fills section downward", {
      mock_data <- tibble(
        text = c("CHAPTER I", "Text 1", "Text 2", "CHAPTER II", "Text 3")
      )

      result <- gutenberg_add_sections(
        mock_data,
        pattern = "^CHAPTER [IVXLCDM]+"
      )

      expect_equal(
        result$section[1:3],
        c("CHAPTER I", "CHAPTER I", "CHAPTER I")
      )
      expect_equal(result$section[4:5], c("CHAPTER II", "CHAPTER II"))
    })

    test_that("handles no matches", {
      mock_data <- tibble(
        text = c("Just some text", "No chapters here", "Nothing to see")
      )

      result <- gutenberg_add_sections(
        mock_data,
        pattern = "^CHAPTER [IVXLCDM]+"
      )

      expect_true(all(is.na(result$section)))
    })

    test_that("preserves other columns", {
      mock_data <- tibble(
        gutenberg_id = c(1, 1, 1),
        text = c("CHAPTER I", "Text 1", "Text 2"),
        other_col = c("a", "b", "c")
      )

      result <- gutenberg_add_sections(
        mock_data,
        pattern = "^CHAPTER [IVXLCDM]+"
      )

      expect_true("gutenberg_id" %in% colnames(result))
      expect_true("other_col" %in% colnames(result))
      expect_equal(result$other_col, c("a", "b", "c"))
    })
  })

  describe("format_fn parameter", {
    test_that("applies format_fn when provided", {
      mock_data <- tibble(
        text = c("CHAPTER one", "Text 1", "chapter TWO", "Text 2")
      )

      result <- gutenberg_add_sections(
        mock_data,
        pattern = "^CHAPTER (one|two)",
        format_fn = stringr::str_to_title
      )

      expect_equal(result$section[1], "Chapter One")
      expect_equal(result$section[3], "Chapter Two")
    })

    test_that("works with custom format_fn", {
      mock_data <- tibble(
        text = c("CHAPTER I", "Text", "CHAPTER II", "More text")
      )

      # Custom function to extract just the chapter number
      extract_num <- function(x) stringr::str_extract(x, "[IVXLCDM]+$")

      result <- gutenberg_add_sections(
        mock_data,
        pattern = "^CHAPTER [IVXLCDM]+",
        format_fn = extract_num
      )

      expect_equal(result$section[1], "I")
      expect_equal(result$section[3], "II")
    })

    test_that("works with format_fn to convert to numeric", {
      mock_data <- tibble(
        text = c("Chapter 1", "Text", "Chapter 2", "More text")
      )

      to_numeric <- function(x) as.numeric(stringr::str_extract(x, "\\d+"))

      result <- gutenberg_add_sections(
        mock_data,
        pattern = "^Chapter \\d+",
        format_fn = to_numeric
      )

      expect_equal(result$section[1], 1)
      expect_equal(result$section[3], 2)
      expect_type(result$section, "double")
    })
  })

  describe("ignore_case parameter", {
    test_that("is case insensitive by default", {
      mock_data <- tibble(
        text = c(
          "chapter i",
          "Text 1",
          "CHAPTER II",
          "Text 2",
          "Chapter III",
          "Text 3"
        )
      )

      result <- gutenberg_add_sections(
        mock_data,
        pattern = "^CHAPTER [IVXLCDM]+"
      )

      expect_equal(result$section[1], "chapter i")
      expect_equal(result$section[3], "CHAPTER II")
      expect_equal(result$section[5], "Chapter III")
    })

    test_that("respects ignore_case = TRUE explicitly", {
      mock_data <- tibble(
        text = c(
          "Chapter I",
          "Text 1",
          "CHAPTER II",
          "Text 2",
          "chapter III",
          "Text 3"
        )
      )

      result <- gutenberg_add_sections(
        mock_data,
        pattern = "^CHAPTER [IVXLCDM]+",
        ignore_case = TRUE
      )

      # Should match all variations
      expect_equal(result$section[1], "Chapter I")
      expect_equal(result$section[3], "CHAPTER II")
      expect_equal(result$section[5], "chapter III")
    })

    test_that("respects ignore_case = FALSE", {
      mock_data <- tibble(
        text = c(
          "CHAPTER I",
          "Text 1",
          "chapter ii",
          "Text 2",
          "CHAPTER III",
          "Text 3"
        )
      )

      result <- gutenberg_add_sections(
        mock_data,
        pattern = "^CHAPTER [IVXLCDM]+",
        ignore_case = FALSE
      )

      # Should only match uppercase CHAPTER
      # "chapter ii" is NOT recognized as a header, so it's just regular text
      # that belongs to the previous section (CHAPTER I)
      expect_equal(result$section[1], "CHAPTER I")
      expect_equal(result$section[2], "CHAPTER I")
      expect_equal(result$section[3], "CHAPTER I") # "chapter ii" not a header
      expect_equal(result$section[4], "CHAPTER I") # Still in CHAPTER I
      expect_equal(result$section[5], "CHAPTER III")
      expect_equal(result$section[6], "CHAPTER III")
    })

    test_that("demonstrates ignore_case controls pattern matching", {
      mock_data <- tibble(
        text = c("CHAPTER I", "Text 1", "Chapter II", "Text 2")
      )

      # Case sensitive - only matches "CHAPTER"
      result_sensitive <- gutenberg_add_sections(
        mock_data,
        pattern = "^CHAPTER [IVXLCDM]+",
        ignore_case = FALSE
      )

      # "Chapter II" not matched, so everything stays in CHAPTER I
      expect_equal(
        result_sensitive$section,
        c("CHAPTER I", "CHAPTER I", "CHAPTER I", "CHAPTER I")
      )

      # Case insensitive - matches both
      result_insensitive <- gutenberg_add_sections(
        mock_data,
        pattern = "^CHAPTER [IVXLCDM]+",
        ignore_case = TRUE
      )

      expect_equal(
        result_insensitive$section,
        c("CHAPTER I", "CHAPTER I", "Chapter II", "Chapter II")
      )
    })
  })

  describe("group_by parameter", {
    test_that("defaults to gutenberg_id when present", {
      mock_data <- tibble(
        gutenberg_id = c(1, 1, 2, 2),
        text = c("CHAPTER I", "Text 1", "CHAPTER I", "Text 2")
      )

      # Should automatically group by gutenberg_id without specifying
      result <- gutenberg_add_sections(
        mock_data,
        pattern = "^CHAPTER [IVXLCDM]+"
      )

      expect_equal(result$section[1:2], c("CHAPTER I", "CHAPTER I"))
      expect_equal(result$section[3:4], c("CHAPTER I", "CHAPTER I"))
    })

    test_that("works without gutenberg_id column", {
      mock_data <- tibble(
        text = c("CHAPTER I", "Text 1", "CHAPTER II", "Text 2")
      )

      result <- gutenberg_add_sections(
        mock_data,
        pattern = "^CHAPTER [IVXLCDM]+"
      )

      # Should work fine without gutenberg_id, no grouping
      expect_equal(result$section[1:2], c("CHAPTER I", "CHAPTER I"))
      expect_equal(result$section[3:4], c("CHAPTER II", "CHAPTER II"))
    })

    test_that("handles multiple gutenberg_ids", {
      mock_data <- tibble(
        gutenberg_id = c(1, 1, 1, 2, 2, 2),
        text = c(
          "CHAPTER I",
          "Text 1",
          "Text 2",
          "CHAPTER I",
          "Text 3",
          "Text 4"
        )
      )

      result <- gutenberg_add_sections(
        mock_data,
        pattern = "^CHAPTER [IVXLCDM]+"
      )

      # Should group by gutenberg_id and fill within each group
      expect_equal(
        result$section[1:3],
        c("CHAPTER I", "CHAPTER I", "CHAPTER I")
      )
      expect_equal(
        result$section[4:6],
        c("CHAPTER I", "CHAPTER I", "CHAPTER I")
      )
    })

    test_that("accepts custom group_by column", {
      mock_data <- tibble(
        book_id = c(1, 1, 1, 2, 2, 2),
        text = c(
          "CHAPTER I",
          "Text 1",
          "Text 2",
          "CHAPTER I",
          "Text 3",
          "Text 4"
        )
      )

      result <- gutenberg_add_sections(
        mock_data,
        pattern = "^CHAPTER [IVXLCDM]+",
        group_by = "book_id"
      )

      # Should group by book_id instead of gutenberg_id
      expect_equal(
        result$section[1:3],
        c("CHAPTER I", "CHAPTER I", "CHAPTER I")
      )
      expect_equal(
        result$section[4:6],
        c("CHAPTER I", "CHAPTER I", "CHAPTER I")
      )
    })

    test_that("treats as single document when group_by = NULL", {
      mock_data <- tibble(
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
        mock_data,
        pattern = "^CHAPTER [IVXLCDM]+",
        group_by = NULL
      )

      # Should NOT group by gutenberg_id, treat as one document
      # So CHAPTER I should fill through to row 3, then CHAPTER II fills rows 4-6
      expect_equal(
        result$section[1:3],
        c("CHAPTER I", "CHAPTER I", "CHAPTER I")
      )
      expect_equal(
        result$section[4:6],
        c("CHAPTER II", "CHAPTER II", "CHAPTER II")
      )
    })

    test_that("accepts multiple group_by columns", {
      mock_data <- tibble(
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

      result <- gutenberg_add_sections(
        mock_data,
        pattern = "^CHAPTER [IVXLCDM]+",
        group_by = c("author", "book")
      )

      # Should group by both author AND book
      expect_equal(result$section[1:2], c("CHAPTER I", "CHAPTER I"))
      expect_equal(result$section[3], "CHAPTER I")
      expect_equal(result$section[4:5], c("CHAPTER I", "CHAPTER I"))
      expect_equal(result$section[6], "CHAPTER I")
    })

    test_that("ungroups after processing", {
      mock_data <- tibble(
        gutenberg_id = c(1, 1, 2, 2),
        text = c("CHAPTER I", "Text 1", "CHAPTER I", "Text 2")
      )

      result <- gutenberg_add_sections(
        mock_data,
        pattern = "^CHAPTER [IVXLCDM]+"
      )

      # Result should not be grouped
      expect_false(dplyr::is_grouped_df(result))
    })
  })

  describe("pattern matching", {
    test_that("matches different section formats", {
      mock_data <- tibble(
        text = c("CANTO I", "Text 1", "CANTO II", "Text 2")
      )

      result <- gutenberg_add_sections(mock_data, pattern = "^CANTO [IVXLCDM]+")

      expect_equal(result$section[1], "CANTO I")
      expect_equal(result$section[3], "CANTO II")
    })

    test_that("handles numeric chapters", {
      mock_data <- tibble(
        text = c("Letter 1", "Text 1", "Letter 2", "Text 2")
      )

      result <- gutenberg_add_sections(mock_data, pattern = "^Letter \\d+")

      expect_equal(result$section[1], "Letter 1")
      expect_equal(result$section[3], "Letter 2")
    })

    test_that("handles complex patterns", {
      mock_data <- tibble(
        text = c("ACT I, SCENE I", "Text 1", "ACT I, SCENE II", "Text 2")
      )

      result <- gutenberg_add_sections(
        mock_data,
        pattern = "^ACT [IVXLCDM]+, SCENE [IVXLCDM]+"
      )

      expect_equal(result$section[1], "ACT I, SCENE I")
      expect_equal(result$section[3], "ACT I, SCENE II")
    })
  })

  describe("edge cases", {
    test_that("handles empty data", {
      mock_data <- tibble(text = character(0))

      result <- gutenberg_add_sections(
        mock_data,
        pattern = "^CHAPTER [IVXLCDM]+"
      )

      expect_equal(nrow(result), 0)
      expect_true("section" %in% colnames(result))
    })

    test_that("handles data with only headers", {
      mock_data <- tibble(
        text = c("CHAPTER I", "CHAPTER II", "CHAPTER III")
      )

      result <- gutenberg_add_sections(
        mock_data,
        pattern = "^CHAPTER [IVXLCDM]+"
      )

      expect_equal(result$section, c("CHAPTER I", "CHAPTER II", "CHAPTER III"))
    })

    test_that("handles whitespace variations in headers", {
      mock_data <- tibble(
        text = c("  CHAPTER I  ", "Text 1", "CHAPTER   II", "Text 2")
      )

      result <- gutenberg_add_sections(
        mock_data,
        pattern = "^\\s*CHAPTER\\s+[IVXLCDM]+"
      )

      expect_equal(result$section[1], "CHAPTER I")
      expect_equal(result$section[3], "CHAPTER II")
    })

    test_that("handles NA values in text column", {
      mock_data <- tibble(
        text = c("CHAPTER I", NA_character_, "Text 1", "CHAPTER II", "Text 2")
      )

      result <- gutenberg_add_sections(
        mock_data,
        pattern = "^CHAPTER [IVXLCDM]+"
      )

      expect_equal(result$section[1], "CHAPTER I")
      expect_equal(result$section[2], "CHAPTER I") # NA fills with previous
      expect_equal(result$section[4], "CHAPTER II")
    })
  })
})
