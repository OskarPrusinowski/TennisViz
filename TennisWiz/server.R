library(shiny)
library(DT)
library(dplyr)

match_stats <- read.csv("data/match_stats.csv", stringsAsFactors = FALSE)

tournaments <- read.csv("data/tournaments.csv", stringsAsFactors = FALSE)

players <- read.csv("data/players.csv", stringsAsFactors = FALSE)

shinyServer(function(input, output) {
  
  filtered_data <- reactive({
    subset(tournaments, year == input$year)
  })
  
  # Render datatable with selection = "single"
  output$tournamentTable <- renderDT({
    datatable(
      filtered_data()[, c("name", "conditions", "surface", "amount", "currency")],
      options = list(pageLength = 10, scrollX = TRUE),
      selection = "single"
    )
  })
  
  # Render pie chart grouped by surface
  output$conditionsPie <- renderPlot({
    data <- filtered_data() %>%
      group_by(surface) %>%
      summarise(total_amount = sum(amount, na.rm = TRUE)) %>%
      arrange(desc(total_amount))
    
    pie(data$total_amount, labels = data$surface,
        main = paste("Total Financial Commitment by Surface -", input$year),
        col = rainbow(nrow(data)))
  })
  
  
  selected_match_stats <- reactive({
    sel <- input$tournamentTable_rows_selected
    if (is.null(sel) || length(sel) == 0) return(NULL)
    
    # get the selected tournament data (year and order)
    selected_tourney <- filtered_data()[sel, ]
    
    # filter match_stats by year and order
    subset(match_stats, year == selected_tourney$year & order == selected_tourney$order)
  })
  output$statDistributionPlot <- renderPlot({
    stats <- selected_match_stats()
    param <- input$statParam
    
    if (is.null(stats) || nrow(stats) == 0) {
      plot.new()
      text(0.5, 0.5, "No match stats available for selected tournament", cex = 1.2)
      return()
    }
    
    if (!(param %in% names(stats))) {
      plot.new()
      text(0.5, 0.5, paste("Statistic", param, "not found"), cex = 1.2)
      return()
    }
    
    data_vec <- stats[[param]]
    data_vec <- data_vec[!is.na(data_vec)]
    
    if (length(data_vec) == 0) {
      plot.new()
      text(0.5, 0.5, paste("No data for", param), cex = 1.2)
      return()
    }
    
    # Get year of selected tournament
    sel <- input$tournamentTable_rows_selected
    selected_tourney <- filtered_data()[sel, ]
    selected_year <- selected_tourney$year
    
    # Filter match_stats to same year
    broader_stats <- match_stats %>%
      filter(year == selected_year)
    
    broader_vec <- broader_stats[[param]]
    broader_vec <- broader_vec[!is.na(broader_vec)]
    
    # Plot histogram for selected tournament
    hist(data_vec,
         main = paste("Distribution of", gsub("_", " ", param)),
         xlab = gsub("_", " ", param),
         col = "lightgreen",
         border = "white",
         freq = FALSE)
    
    # Overlay density for same year (if enough data)
    if (length(broader_vec) > 2) {
      dens <- density(broader_vec)
      lines(dens, col = "blue", lwd = 2)
      legend("topright",
             legend = c("Selected Tournament", paste("All Tournaments in", selected_year)),
             fill = c("lightgreen", NA),
             border = c("white", NA),
             lty = c(NA, 1),
             col = c(NA, "blue"),
             lwd = c(NA, 2))
    }
  })
  
  
  output$winnerInfo <- renderUI({
    sel <- input$tournamentTable_rows_selected
    if (is.null(sel) || length(sel) == 0) {
      return(HTML("<i>Select a tournament to see winner info</i>"))
    }
    
    selected_tourney <- filtered_data()[sel, ]
    winner_slug <- selected_tourney$winner_slug
    
    player <- players[players$player_slug == winner_slug, ]
    
    if (nrow(player) == 0) {
      return(HTML(paste0("<b>Winner slug: </b>", winner_slug, "<br><i>No additional player info found.</i>")))
    }
    
    birthdate <- player$birthdate
    birthdate <- ifelse(is.na(birthdate) | birthdate == "", "Unknown", birthdate)
    
    residence <- ifelse(player$residence == "", "Unknown", player$residence)
    handedness <- ifelse(player$handedness == "", "Unknown", player$handedness)
    
    total_wins <- sum(tournaments$winner_slug == winner_slug, na.rm = TRUE)
    
    HTML(paste0(
      "<b>Name:</b> ", player$first_name, " ", player$last_name, "<br>",
      "<b>Birthdate:</b> ", birthdate, "<br>",
      "<b>Residence:</b> ", residence, "<br>",
      "<b>Handedness:</b> ", handedness, "<br>",
      "<b>Total Tournaments Won:</b> ", total_wins, "<br>",
      "<a href='", player$player_url, "' target='_blank'>Player Profile</a>"
    ))
  })
  
  
  output$winsBySurfacePlot <- renderPlot({
    sel <- input$tournamentTable_rows_selected
    if (is.null(sel) || length(sel) == 0) return(NULL)
    
    winner_slug <- filtered_data()[sel, ]$winner_slug
    
    player_wins <- tournaments[tournaments$winner_slug == winner_slug, ]
    if (nrow(player_wins) == 0) return(NULL)
    
    wins_by_surface <- table(player_wins$surface)
    
    barplot(wins_by_surface,
            col = "steelblue",
            main = "Tournament Wins by Surface",
            ylab = "Number of Wins",
            xlab = "Surface",
            las = 1)
  })
  
  
  
})
