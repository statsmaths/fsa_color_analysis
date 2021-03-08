library(tidyverse)
library(stringi)
library(smodels)
library(ggrepel)

theme_set(theme_minimal())
options(dplyr.summarise.inform = FALSE)
options(width = 77L)

source("funs.R")

fsa <- read_csv("../data/fsa-color.csv")
cats <- read_csv("../data/cats.csv")
insts <- read_csv("../data/insts.csv")
meta <- read_csv("../data/category_meta.csv")
fsa$id <- stri_sub(fsa$path, 1, -5)
fsa$photographer <- as.character(fct_lump(fsa$photographer_name, n = 8))
fsa$photographer[is.na(fsa$photographer)] <- "Other"

z <- cats %>%
  left_join(meta, by = "category") %>%
  mutate(group = if_else(is.na(group), "unknown", group)) %>%
  mutate(super = if_else(is.na(super), "unknown", super)) %>%
  group_by(id, super) %>%
  summarize(n = sum(n)) %>%
  ungroup() %>%
  left_join(fsa, by = "id") %>%
  select(id, photographer, super, n) %>%
  pivot_wider(
    names_from = "super",
    values_from = "n",
    values_fill = 0
  )

z %>%
  group_by(photographer) %>%
  summarize(sm_mean_ci_normal(outdoor * 100, name = "perc")) %>%
  arrange(desc(perc_mean)) %>%
  mutate(photographer = fct_inorder(photographer)) %>%
  ggplot() +
    geom_pointrange(aes(
      x = photographer,
      y = perc_mean,
      ymin = perc_ci_min,
      ymax = perc_ci_max
    )) +
    labs(x = "Photographer", y = "Percent Image Outdoor") +
    coord_flip()
ggsave("photo_outside.jpg", height = 6, width = 8)


z <- cats %>%
  left_join(meta, by = "category") %>%
  mutate(group = if_else(is.na(group), "unknown", group)) %>%
  mutate(super = if_else(is.na(super), "unknown", super)) %>%
  group_by(id, category) %>%
  summarize(n = sum(n)) %>%
  ungroup() %>%
  left_join(fsa, by = "id") %>%
  select(id, photographer, category, n)


z %>%
  mutate(category = fct_lump(category, 10)) %>%
  group_by(photographer) %>%
  mutate(denom = length(unique(id))) %>%
  group_by(photographer, category) %>%
  summarize(mu = sum(n) / first(denom) * 100) %>%
  mutate(category = stri_trans_totitle(category)) %>%
  ggplot() +
    geom_col(aes(x = category, y = mu), color = "black", fill = "white") +
    facet_wrap(~photographer) +
    labs(x = "Category", y = "Average Percentage") +
    coord_flip() +
    theme_sm()

ggsave("photo_category.jpg", height = 6, width = 8)


z %>%
  mutate(category = fct_lump(category, 10)) %>%
  group_by(photographer) %>%
  mutate(denom = length(unique(id))) %>%
  group_by(photographer, category) %>%
  summarize(mu = sum(n) / first(denom) * 100) %>%
  pivot_wider(
    names_from = "category",
    values_from = "mu",
    values_fill = 0
  ) %>%
  ggplot(aes(sky, building)) +
    geom_point() +
    geom_text_repel(aes(label = photographer)) +
    labs(x = "Sky, Average Percentage", y = "Building, Average Percentage")

ggsave("photo_sky_building.jpg", height = 6, width = 8)


z %>%
  filter(n > 0.1) %>%
  group_by(category, photographer) %>%
  summarize(n = n()) %>%
  arrange(desc(n)) %>%
  slice_head(n = 1) %>%
  arrange(desc(n)) %>%
  print(n = Inf)
