library(dplyr)
library(ggplot2)
library(readr)
library(ggrepel)
library(stringi)
library(jpeg)

source("funs.R")

# Write aggregated category information
fsa <- read_csv("../data/fsa-color.csv")
fsa$id <- stri_sub(fsa$path, 1, -5)

cats <- NULL
for (i in seq_along(fsa$id))
{
  z <- as.matrix(read_csv(
    sprintf("../data/regions/%s.txt", fsa$id[i]),
    col_names = FALSE,
    col_types = cols(.default = col_character()),
    progress = FALSE
  ))
  tab <- table(as.character(z))
  cats <- bind_rows(
    cats,
    tibble(id = fsa$id[i], category = names(tab), n = as.numeric(tab) / sum(tab))
  )
  if (i %% 10 == 0) print(sprintf("Done with %d of %d", i, nrow(fsa)))
}

write_csv(cats, "../data/cats.csv")

# Write aggregated instance information
insts <- NULL
for (i in seq_along(fsa$id))
{
  z <- read_csv(
    sprintf("../data/instances/%s.txt", fsa$id[i]),
    col_names = FALSE,
    col_types = "cdi"
  )
  z$id <- fsa$id[i]
  if (nrow(z))
  {
    insts <- bind_rows(insts, select(z, id, everything()))
  }
}

colnames(insts) <- c("id", "category", "conf", "size")
write_csv(insts, "../data/insts.csv")
