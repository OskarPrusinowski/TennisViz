library(shiny)
library(DT)

shinyUI(
  navbarPage("Tennis Dashboard",
             
             tabPanel("Home",
                      fluidPage(
                        h2("Welcome to the Tennis Dashboard"),
                        p("Use the tabs above to explore tournaments, statistics, and player info.")
                      )
             ),
             
             tabPanel("Tournaments",
                      fluidPage(
                        titlePanel("Tennis Tournaments Dashboard"),
                        
                        sliderInput("year", "Select Year:",
                                    min = 1991, max = 2017, value = 1991,
                                    sep = "", step = 1, width = "100%"),
                        
                        fluidRow( 
                          column(6,
                                 h3("Tournaments Table"),
                                 DTOutput("tournamentTable"),
                                 
                                 br(),
                                 h3("Amount Distribution by Conditions"),
                                 plotOutput("conditionsPie")
                          ),
                          
                          column(6,
                                 selectInput("statParam", "Select Statistic to Display:",
                                             choices = c("Match Duration" = "match_duration",
                                                         "Total Aces" = "total_aces",
                                                         "Break Points Saved" = "total_break_points_saved",
                                                         "Total Points Won" = "total_points_won",
                                                         "Double Faults" = "total_double_faults"),
                                             selected = "match_duration"
                                 ),
                                 
                                 br(),
                                 h3("Distribution"),
                                 plotOutput("statDistributionPlot"),
                                 
                                 br(),
                                 h4("Winner Information"),
                                 uiOutput("winnerInfo"),
                                 
                                 br(),
                                 h3("Wins by Surface"),
                                 plotOutput("winsBySurfacePlot", height = "300px")
                          )
                        )
                      )
             )
  )
)
