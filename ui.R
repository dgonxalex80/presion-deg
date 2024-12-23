## ui.R
library(shiny)
library(ggplot2)
library(shinydashboard)
library(formattable)

ui <- fluidPage(
  tags$head(
    tags$style(HTML(
      "body { background-color: #F0F4F8; } \
       .titlePanel { background-color: #0D47A1; padding: 10px; text-align: center; } \
       .titlePanel h1 { color: #FFFFFF; font-weight: bold; margin: 0; } \
       .sidebarPanel { background-color: #1E88E5; color: #FFFFFF; padding: 15px; border-radius: 5px; } \
       .sidebarPanel input, .sidebarPanel button { margin-bottom: 10px; width: 100%; background-color: #C8E6C9; color: black; border: none; border-radius: 5px; padding: 10px; font-size: 1em; } \
       .custom-box { padding: 20px; border-radius: 5px; text-align: center; font-weight: bold; font-size: 1.2em; } \
       .custom-systolic { background-color: #FF8A65; color: white; } \
       .custom-diastolic { background-color: #4DB6AC; color: white; }"
    ))
  ),
  titlePanel(h1("Seguimiento de Presión Arterial", style = "font-weight: bold; color: black;")),
  sidebarLayout(
    sidebarPanel(
      dateInput("date", "Fecha de Registro", value = Sys.Date()),
      numericInput("systolic", "Presión Sistólica", value = 120, min = 80, max = 200),
      numericInput("diastolic", "Presión Diastólica", value = 80, min = 50, max = 120),
      actionButton("add", "Agregar Registro"),
      br(),br(),
      downloadButton("download", "Descargar Datos")
    ),
    mainPanel(
      plotOutput("pressurePlot"),
      uiOutput("formattedTable"),
      fluidRow(
        column(6, uiOutput("customSystolicBox")),
        column(6, uiOutput("customDiastolicBox"))
      )
    )
  )
)
