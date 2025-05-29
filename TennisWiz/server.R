library(shiny)
source("load_data.R") 

server <- function(input, output) {
  output$distPlot <- renderPlot({
    x <- load_geyser_data()
    bins <- seq(min(x), max(x), length.out = input$bins + 1)
    hist(x, breaks = bins, col = 'darkgray', border = 'white',
         xlab = 'Waiting time to next eruption (in mins)',
         main = 'Histogram of waiting times')
  })
}
