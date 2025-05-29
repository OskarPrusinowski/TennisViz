library(shiny)

ui <- fluidPage(
  titlePanel("Match Statistics"),
  
  sidebarLayout(
    sidebarPanel(
      sliderInput("year_range",
                  "Select year range:",
                  min = 1991,
                  max = 2017, 
                  value = c(1991, 2017),
                  sep = "",
                  step = 1),
      
      selectInput("stat_choice",
                  "Select statistic to plot:",
                  choices = c("Match Duration" = "match_duration",
                              "Total Aces" = "total_aces",
                              "Break Points Saved" = "total_break_points_saved",
                              "Total Points Won" = "total_points_won",
                              "Double Faults" = "total_double_faults"),
                  selected = "match_duration"),
      
      textOutput("statSummary")  
    ),
    
    mainPanel(
      plotOutput("statPlot")
    )
  )
)
