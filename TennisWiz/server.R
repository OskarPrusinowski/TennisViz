library(shiny)
library(DT)
library(dplyr)
library(plotly)
library(grid)
library(gridGraphics)
library(countrycode)

match_stats <- read.csv("data/match_stats.csv", stringsAsFactors = FALSE)

tournaments <- read.csv("data/tournaments.csv", stringsAsFactors = FALSE)

players <- read.csv("data/players.csv", stringsAsFactors = FALSE)

shinyServer(function(input, output) {
  
  filtered_data <- reactive({
    subset(tournaments, year == input$year)
  })
  
  output$tournamentTable <- renderDT({
    datatable(
      filtered_data()[, c("name", "conditions", "surface", "fin_commit", "winner")],
      options = list(pageLength = 10, scrollX = TRUE),
      selection = "single"
    )
  })
  
  output$conditionsPie <- renderPlotly({
    data <- filtered_data() %>%
      group_by(surface) %>%
      summarise(total_amount = sum(amount, na.rm = TRUE)) %>%
      arrange(desc(total_amount))
    
    surface_colors <- c(
      "Clay" = "#D95F02", 
      "Grass" = "#1B9E77",    
      "Hard" = "#7570B3",   
      "Carpet" = "#E7298A"  
    )
    
    matched_colors <- surface_colors[data$surface]
    
    plot_ly(
      data,
      labels = ~surface,
      values = ~total_amount,
      type = "pie",
      textinfo = "label+percent",
      hoverinfo = "label+value+percent",
      marker = list(
        colors = matched_colors,
        line = list(color = '#FFFFFF', width = 2)
      )
    ) %>%
      layout(
        title = paste("Total Financial Commitment by Surface -", input$year),
        showlegend = TRUE
      )
  })
  
  
  
  selected_match_stats <- reactive({
    sel <- input$tournamentTable_rows_selected
    if (is.null(sel) || length(sel) == 0) return(NULL)
     
    selected_tourney <- filtered_data()[sel, ]
     
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
     
    sel <- input$tournamentTable_rows_selected
    selected_tourney <- filtered_data()[sel, ]
    selected_year <- selected_tourney$year 
    broader_stats <- match_stats %>%
      filter(year == selected_year)
    
    broader_vec <- broader_stats[[param]]
    broader_vec <- broader_vec[!is.na(broader_vec)]
     
    hist(data_vec,
         main = paste("Distribution of", gsub("_", " ", param)),
         xlab = gsub("_", " ", param),
         col = "#A6CEE3",  # soft blue
         border = "white",
         freq = FALSE)
    
    # Overlay density for same year (if enough data)
    if (length(broader_vec) > 2) {
      dens <- density(broader_vec)
      lines(dens, col = "#33A02C", lwd = 2)  # medium green
      
      legend("topright",
             legend = c("Selected Tournament", paste("All Tournaments in", selected_year)),
             fill = c("#A6CEE3", NA),
             border = c("white", NA),
             lty = c(NA, 1),
             col = c(NA, "#33A02C"),
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
    
    birthdate <- ifelse(is.na(player$birthdate) | player$birthdate == "", "Unknown", player$birthdate)
    residence <- ifelse(player$residence == "", "Unknown", player$residence)
    handedness <- ifelse(player$handedness == "", "Unknown", player$handedness)
    
     
    country_code_2 <- countrycode(player$flag_code, origin = "iso3c", destination = "iso2c")
    
    flag_url <- paste0("https://flagcdn.com/w40/", tolower(country_code_2), ".png")
    flag_img <- if (!is.na(country_code_2)) {
      paste0("<img src='", flag_url, "' style='height:20px; vertical-align:middle; margin-right:5px;'>")
    } else {
      ""
    }
    
    total_wins <- sum(tournaments$winner_slug == winner_slug, na.rm = TRUE)
    
    HTML(paste0(
      "<b>Name:</b> ", player$first_name, " ", player$last_name, "<br>",
      "<b>Birthdate:</b> ", birthdate, "<br>",
      "<b>Residence:</b> ", flag_img, " ", residence, "<br>",
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
    
    barplot(wins_by_surface[order(wins_by_surface)],
            horiz = TRUE,
            col = "#4DB6AC",
            main = "Tournament Wins by Surface",
            xlab = "Number of Wins",
            las = 1,
            border = NA,
            cex.names = 0.9)
  })
  
  
  
  
})
