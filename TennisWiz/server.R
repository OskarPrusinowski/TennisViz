library(shiny)
source("load_data.R") 

server <- function(input, output, session) {
  
  match_data <- load_match_data()
  
  # Data filtered only by year range (no quantile filtering)
  year_filtered_data <- reactive({
    subset(match_data, year >= input$year_range[1] & year <= input$year_range[2])
  })
  
  # Quantiles calculated on year-filtered data, used for filtering
  quantiles <- reactive({
    df <- year_filtered_data()
    stat_col <- input$stat_choice
    q25 <- quantile(df[[stat_col]], 0.01, na.rm = TRUE)
    q75 <- quantile(df[[stat_col]], 0.99, na.rm = TRUE)
    list(q25 = q25, q75 = q75)
  })
  
  # Data filtered by year and quantiles
  filtered_data <- reactive({
    df <- year_filtered_data()
    stat_col <- input$stat_choice
    q <- quantiles()
    df[df[[stat_col]] >= q$q25 & df[[stat_col]] <= q$q75, ]
  })
  
  output$statPlot <- renderPlot({
    stat_col <- input$stat_choice
    hist(filtered_data()[[stat_col]],
         col = "steelblue",
         border = "white",
         main = paste("Distribution of", gsub("_", " ", stat_col)),
         xlab = gsub("_", " ", stat_col),
         breaks = 20)
  })
  
  output$statSummary <- renderText({
    df <- year_filtered_data()
    stat_col <- input$stat_choice
    
    if (nrow(df) == 0) {
      return("No data available for selected filters.")
    }
    
    min_val <- min(df[[stat_col]], na.rm = TRUE)
    max_val <- max(df[[stat_col]], na.rm = TRUE)
    
    paste0("Range of ", gsub("_", " ", stat_col), " (all data in selected years): ",
           round(min_val, 2), " to ", round(max_val, 2))
  })
}

