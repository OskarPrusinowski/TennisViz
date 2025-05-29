library(shiny)

source("data_loader.R")
source("ui.R")
source("server.R")

shinyApp(ui = ui, server = server)
