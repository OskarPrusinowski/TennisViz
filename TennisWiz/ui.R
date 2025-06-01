library(shiny)
library(DT)

custom_css <- "
  @import url('https://fonts.googleapis.com/css2?family=Roboto&display=swap');
  
  body {
    font-family: 'Roboto', sans-serif;
    background-color: #f9f9f9;
    color: #333;
  }

  h2, h3, h4 {
    font-weight: 500;
    margin-top: 1em;
  }

  .section-divider {
    border-top: 1px solid #ddd;
    margin-top: 30px;
    margin-bottom: 20px;
  }

  .card {
    background-color: #fff;
    padding: 20px;
    margin-bottom: 20px;
    border-radius: 10px;
    box-shadow: 0 2px 6px rgba(0,0,0,0.05);
  }

  .plot-title {
    margin-top: 20px;
    margin-bottom: 10px;
  }

  .datatables {
    margin-top: 10px;
  }
 
  .irs--shiny .irs-bar,
  .irs--shiny .irs-bar-edge {
    background: #007bff;
    border-top: 1px solid #0069d9;
    border-bottom: 1px solid #0069d9;
  }

  .irs--shiny .irs-handle > i:first-child {
    background: #007bff;
    border-radius: 50%;
    box-shadow: 0 0 8px rgba(0, 123, 255, 0.6);
  }

  .irs--shiny .irs-line {
    border: 1px solid #007bff;
    background: #cce5ff;
  }

  .irs--shiny .irs-single {
    background: #007bff;
    color: white;
    font-weight: 600;
  }
"

shinyUI(
  tagList(
    tags$head(
      tags$style(HTML(custom_css)),
      tags$title("Tennis Dashboard")
    ),
    
    navbarPage("🎾 Tennis Dashboard",
               
               tabPanel("Home",
                        fluidPage(
                          div(class = "card",
                              h2("Welcome to the Tennis Dashboard"),
                              p("Use the tabs above to explore tournaments, statistics, and player information.")
                          )
                        )
               ),
               
               tabPanel("Tournaments",
                        fluidPage(
                          tags$div(class = "card",
                                   titlePanel("🏆 Tennis Tournaments Dashboard"),
                                   
                                   sliderInput(
                                     inputId = "year",
                                     label = "Select Year:",
                                     min = 1991,
                                     max = 2017,
                                     value = 1991,
                                     step = 1,
                                     sep = "",
                                     width = "100%"
                                   )
                          ),
                          
                          tags$div(class = "section-divider"),
                          
                          fluidRow(
                            column(6,
                                   div(class = "card",
                                       h3("📋 Tournaments Table"),
                                       DTOutput("tournamentTable"),
                                       tags$div(class = "section-divider"),
                                       h3("💰 Amount Distribution by Conditions"),
                                       plotlyOutput("conditionsPie")
                                   )
                            ),
                            
                            column(6,
                                   div(class = "card",
                                       selectInput("statParam", "Select Statistic to Display:",
                                                   choices = c("Match Duration" = "match_duration",
                                                               "Total Aces" = "total_aces",
                                                               "Break Points Saved" = "total_break_points_saved",
                                                               "Total Points Won" = "total_points_won",
                                                               "Double Faults" = "total_double_faults"),
                                                   selected = "match_duration"
                                       ),
                                       
                                       tags$div(class = "section-divider"),
                                       h3("📊 Distribution"),
                                       plotOutput("statDistributionPlot"),
                                       
                                       tags$div(class = "section-divider"),
                                       h4("🏅 Winner Information"),
                                       uiOutput("winnerInfo"),
                                       
                                       tags$div(class = "section-divider"),
                                       h3("🌍 Wins by Surface"),
                                       plotOutput("winsBySurfacePlot", height = "300px")
                                   )
                            )
                          )
                        )
               ),
               
               # New About tab
               tabPanel("About",
                        fluidPage(
                          div(class = "card",
                              h2("About the Tennis Dashboard Project"),
                              p("This Tennis Dashboard is an interactive web application built using R and Shiny."),
                              p("It allows users to explore tennis tournaments data, view statistics on matches, and analyze player performance across various years and conditions."),
                              p("The project aims to provide tennis enthusiasts and analysts with insightful visualizations and easy access to tournament information."),
                              p("Data visualizations include distributions of match statistics, surface-specific win rates, and financial breakdowns by tournament conditions."),
                             tags$hr(),
                              h4("Developed by:"),
                              tags$ul(
                                tags$li("Jędrzej Pluta"),
                                tags$li("Oskar prusinowski")
                              ),
                              tags$hr(),
                              h4("Data Sources:"),
                              p("https://datahub.io/core/atp-world-tour-tennis-data")
                          )
                        )
               )
    )
  )
)
