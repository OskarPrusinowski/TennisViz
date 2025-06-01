library(shiny)
library(DT)
library(plotly)
library(shinyWidgets)
 

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
      tags$title("TennisViz")
    ),
    
    navbarPage("🎾 TennisViz",
               
               
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
                                       plotlyOutput("conditionsTreemap")
                                       
                                       
                                   )
                            ),
                            
                            column(6,
                                   div(class = "card",
                                       fluidRow(
                                         column(6,
                                                selectInput("statParam", "Select Statistic to Display:",
                                                            choices = c("Match Duration" = "match_duration",
                                                                        "Total Aces" = "total_aces",
                                                                        "Break Points Saved" = "total_break_points_saved",
                                                                        "Total Points Won" = "total_points_won",
                                                                        "Double Faults" = "total_double_faults"),
                                                            selected = "match_duration")
                                         ),
                                         column(6,
                                                selectInput("plotType", "Plot Type:",
                                                            choices = c("Histogram" = "hist", "Density" = "density"),
                                                            selected = "hist")
                                         )
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
               tabPanel("Rankings",
                        fluidPage(
                          titlePanel("🏆 ATP Rankings Visualizations"),
                          
                          sidebarLayout(
                            sidebarPanel(
                              conditionalPanel(
                                condition = "input.tabs == 'top10'",
                                sliderTextInput(
                                  inputId = "year_range", 
                                  label = "Select 5-Year Period:",
                                  choices = as.character(1973:2019), 
                                  selected = "2009",
                                  grid = TRUE
                                )
                              ),
                              conditionalPanel(
                                condition = "input.tabs == 'decade'",
                                selectInput("decade", "Choose a Decade:",
                                            choices = c("1970s", "1980s", "1990s", "2000s", "2010s", "2020s"),
                                            selected = "1980s")
                              )
                            ),
                            
                            mainPanel(
                              tabsetPanel(id = "tabs",
                                          tabPanel("📈 Top 10 Timeline", value = "top10",
                                                   plotlyOutput("top10Plot", height = "600px")
                                          ),
                                          tabPanel("⌛ Weeks in Top 10", value = "decade",
                                                   plotlyOutput("yearsInTop10Plot", height = "600px")
                                          )
                              )
                            )
                          )
                        )
                        
                 
               ),
               tabPanel("About",
                        fluidPage(
                          div(class = "card",
                              tags$img(src = "logo.png", height = "120px", style = "display: block; margin-bottom: 20px;"),
                              
                              h2("About the TennisViz"),
                              p("TennisViz is an interactive web application built using R and Shiny."),
                              p("It allows users to explore tennis tournaments data, view statistics on matches, and analyze player performance across various years and conditions."),
                              p("The project aims to provide tennis enthusiasts and analysts with insightful visualizations and easy access to tournament information."),
                              p("Data visualizations include distributions of match statistics, surface-specific win rates, and financial breakdowns by tournament conditions."),
                              
                              tags$hr(),
                              
                              h3("Features"),
                              tags$ul(
                                tags$li("Browse tournament data by year, surface, and tournament name."),
                                tags$li("Explore detailed match statistics like match duration, aces, break points saved, and more."),
                                tags$li("Visualize distribution of statistics using histograms or density plots."),
                                tags$li("Analyze player performance and rankings over decades and selected time periods."),
                                tags$li("Interactive treemaps to understand financial commitments across surfaces and tournaments."),
                                tags$li("Dynamic filters and selections for customized views.")
                              ),
                              
                              tags$hr(),
                              
                              h3("Technology Stack"),
                              tags$ul(
                                tags$li("Built with ", tags$code("R"), " programming language and ", tags$code("Shiny"), " for the interactive web interface."),
                                tags$li("Uses ", tags$code("plotly"), " for interactive and dynamic visualizations."),
                                tags$li("Data tables are rendered with ", tags$code("DT"), " package for sorting and filtering."),
                                tags$li("Custom CSS styling applied for a clean, user-friendly UI.")
                              ),
                              
                              tags$hr(),
                              
                              h3("Data Sources"),
                              p("The dashboard uses historical ATP World Tour tennis data sourced from:"),
                              tags$a(href = "https://datahub.io/core/atp-world-tour-tennis-data", "https://datahub.io/core/atp-world-tour-tennis-data", target = "_blank"),
                              p("The dataset includes match results, tournament details, player statistics, and rankings spanning several decades."),
                              
                              tags$hr(),
                              
                              h3("Acknowledgments"),
                              p("Special thanks to the open data community and contributors who provide accessible sports data."),
                              p("Developed by:"),
                              tags$ul(
                                tags$li("Jędrzej Pluta"),
                                tags$li("Oskar Prusinowski")
                              ),
                              
                              tags$hr() 
                          )
                        )
               )
               
    )
  )
)
