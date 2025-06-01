library(shiny)
library(ggplot2)
library(dplyr)

# Load rankings data
ranking_data <- read.csv("data/atp_rankings_combined.csv", na.strings = c("", "NA"))
ranking_data$player <- as.character(ranking_data$player)  # Force to character
ranking_data$rank <- as.numeric(ranking_data$rank)
ranking_data$rank_date <- as.Date(as.character(ranking_data$rank_date), format = "%Y%m%d")
ranking_data$year <- as.numeric(format(ranking_data$rank_date, "%Y"))

# Load player data
players_data <- read.csv("data/atp_players.csv", stringsAsFactors = FALSE)
colnames(players_data) <- c("player_id","name_first","name_last","hand","dob","ioc","height","wikidata_id")
players_data$player_id <- as.character(players_data$player_id)  # Also as character

# Join player names into ranking data
ranking_data <- ranking_data %>%
  left_join(players_data, by = c("player" = "player_id"))
