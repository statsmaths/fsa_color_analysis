library(dplyr)
library(ggplot2)
library(readr)
library(ggrepel)
library(stringi)

make_index <- function(path)
{
  imgs <- dir(path, full.names = TRUE, pattern = "jpg$")
  html <- c(
    "<html><body>",
    sprintf("<img src='%s' width='300px'>", imgs),
    "</body>"
  )
  writeLines(html, file.path(path, "index.html"))
}



cats <- read_csv("../data/cats.csv")
insts <- read_csv("../data/insts.csv")

# create output locations
sapply(
  file.path("..", "testing", "stuff", unique(cats$category)),
  dir.create,
  showWarnings = FALSE
)
sapply(
  file.path("..", "testing", "stuff_dec", unique(cats$category)),
  dir.create,
  showWarnings = FALSE
)
sapply(
  file.path("..", "testing", "things", unique(insts$category)),
  dir.create,
  showWarnings = FALSE
)

##############################################################################
# Associate each image with largest strong stuff category
z <- cats %>%
  group_by(id) %>%
  filter(n == max(n)) %>%
  ungroup()

for (j in seq_len(nrow(z)))
{
  file.copy(
    sprintf("../data/images/%s.jpg", z$id[j]),
    sprintf("../testing/stuff/%s/%s.jpg", z$category[j], z$id[j])
  )
}

tab <- table(stri_replace_all(z$category, "_", fixed = "-"))
cat(sprintf("%12s = c(%3d,0),", names(tab), tab), sep = "\n")

# ERRORS

errors <- list(
      banner = c(  1,1),
      bridge = c(  3,0),
    building = c(112,3),
   cardboard = c(  1,1),
     ceiling = c( 11,1),
     curtain = c(  5,1),
        dirt = c( 64,0),
  door_stuff = c(  2,1),
       fence = c(  3,2),
       floor = c(  4,1),
      flower = c(  1,0),
        food = c(  1,0),
       grass = c( 64,1),
      gravel = c(  1,0),
       house = c( 26,0),
mirror_stuff = c(  1,1),
    mountain = c( 53,3),
    pavement = c( 13,3),
      person = c( 79,0),
    platform = c(  2,2),
    railroad = c( 18,0),
       river = c(  2,0),
        road = c(  8,3),
        rock = c(  4,1),
        sand = c(  8,1),
         sea = c(  3,1),
       shelf = c(  1,0),
         sky = c(567,2),
        snow = c( 12,0),
        tent = c(  2,1),
      things = c(115,0),
        tree = c(115,0),
     unknown = c(168,0),
        wall = c(105,11),
  wall_brick = c(  6,1),
   wall_wood = c( 15,0),
       water = c(  2,1),
      window = c(  5,0)
)

##############################################################################
# What about capped at a percentage?

z <- cats %>%
  filter(n > 0.05) %>%
  group_by(id) %>%
  filter(category != "unknown") %>%
  ungroup()

for (j in seq_len(nrow(z)))
{
  file.copy(
    sprintf("../data/images/%s.jpg", z$id[j]),
    sprintf("../testing/stuff_dec/%s/%s.jpg", z$category[j], z$id[j])
  )
}

for (this_cat in unique(z$category))
{
  make_index(sprintf(
    "/Users/taylor/Desktop/fsa_color_analysis/testing/stuff_dec/%s",
    this_cat
  ))
}

# count unique
people <- filter(insts, category == "person") %>%
  group_by(id) %>%
  summarize(category = sprintf("person(%d)", n())) %>%
  select(id, category)
y <- z %>%
  filter(category != "person") %>%
  arrange(desc(n)) %>%
  bind_rows(people) %>%
  group_by(id) %>%
  summarize(desc = paste(category, collapse = ";"))
tab <- table(y$desc)
length(tab)

insts

tab <- table(stri_replace_all(z$category, "_", fixed = "-"))
cat(sprintf("%12s = c(%3d,0),", names(tab), tab), sep = "\n")

errors <- list(
      banner = c(  5,1),
      bridge = c( 14,3),
    building = c(291,7),
     cabinet = c(  1,0),
   cardboard = c(  6,3),
     ceiling = c( 76,1),
     counter = c(  1,0),
     curtain = c(  9,3),
        dirt = c(251,1),
  door_stuff = c( 13,3),
       fence = c( 28,5),
       floor = c( 30,1),
  floor_wood = c( 10,1),
      flower = c(  2,0),
        food = c(  3,0),
       fruit = c(  1,0),
       grass = c(263,0),
      gravel = c(  7,1),
       house = c( 70,2),
mirror_stuff = c(  5,3),
    mountain = c(172,6),
       paper = c(  4,0),
    pavement = c(103,5),
      person = c(422,2),
    platform = c(  7,0),
    railroad = c( 78,0),
       river = c( 13,2),
        road = c(106,4),
        rock = c( 13,1),
        roof = c(  4,0),
         rug = c(  1,1),
        sand = c( 35,0),
         sea = c( 24,4),
       shelf = c(  7,0),
         sky = c(1006,3),
        snow = c( 42,1),
      stairs = c(  4,0),
       table = c( 14,2),
        tent = c(  3,1),
      things = c(298,0),
        tree = c(336,6),
        wall = c(262,17),
  wall_brick = c( 16,3),
  wall_stone = c(  6,1),
   wall_tile = c(  2,1),
   wall_wood = c( 26,2),
       water = c( 14,3),
      window = c( 22,3)
)

sum(sapply(errors, function(v) v[2])) / sum(sapply(errors, function(v) v[1]))

##############################################################################
# Instances

z <- insts %>%
  filter(conf > 0.8) %>%
  filter(category != "person") %>%
  group_by(id, category) %>%
  summarize(n())


for (j in seq_len(nrow(z)))
{
  file.copy(
    sprintf("../data/images/%s.jpg", z$id[j]),
    sprintf("../testing/things/%s/%s.jpg", z$category[j], z$id[j])
  )
}

for (this_cat in unique(z$category))
{
  make_index(sprintf(
    "/Users/taylor/Desktop/fsa_color_analysis/testing/things/%s",
    this_cat
  ))
}

# count unique
y <- insts %>%
  filter(conf > 0.8) %>%
  filter(category != "person") %>%
  group_by(id, category) %>%
  summarize(category = sprintf("%s(%d)", first(category), n())) %>%
  summarize(desc = paste(sort(category), collapse = ";"))
tab <- table(y$desc)
length(tab)

tab <- table(stri_replace_all(z$category, "_", fixed = " "))
cat(sprintf("%13s = c(%3d,0),", names(tab), tab), sep = "\n")

errors <- list(
     airplane = c(110,5),
        apple = c(  1,0),
     backpack = c(  3,2),
 baseball_bat = c(  4,4),
          bed = c(  3,2),
        bench = c( 20,5),
      bicycle = c(  4,2),
         bird = c( 14,9),
         boat = c( 31,14),
         book = c(  4,2),
       bottle = c( 12,6),
         bowl = c( 11,3),
          bus = c(  2,1),
         cake = c(  2,0),
          car = c( 56,6),
          cat = c(  4,4),
   cell_phone = c(  2,2),
        chair = c( 21,9),
        clock = c( 10,6),
          cow = c( 19,6),
          cup = c( 10,6),
 dining_table = c(  3,2),
          dog = c(  8,5),
     elephant = c(  3,3),
 fire_hydrant = c(  3,0),
         fork = c(  2,2),
      frisbee = c(  1,1),
      handbag = c( 14,12),
        horse = c( 54,5),
     keyboard = c(  1,0),
         kite = c(  9,9),
        knife = c(  3,2),
   motorcycle = c( 13,0),
       orange = c(  3,1),
         oven = c(  1,1),
 potted_plant = c( 14,6),
 refrigerator = c(  1,1),
        sheep = c(  7,6),
         sink = c(  2,1),
   skateboard = c(  1,1),
        spoon = c(  4,0),
  sports_ball = c(  1,1),
    stop_sign = c(  3,0),
     suitcase = c( 10,10),
    surfboard = c(  3,3),
   teddy_bear = c(  1,1),
tennis_racket = c(  1,1),
          tie = c( 30,3),
       toilet = c(  2,2),
   toothbrush = c(  1,1),
traffic_light = c(  4,2),
        train = c(109,16),
        truck = c( 43,8),
           tv = c(  3,3),
     umbrella = c(  6,6),
         vase = c(  3,0),
   wine_glass = c(  3,0)
)

sum(sapply(errors, function(v) v[2])) / sum(sapply(errors, function(v) v[1]))
