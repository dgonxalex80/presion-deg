library(shiny)
library(ggplot2)
library(dplyr)
library(shinydashboard)
library(formattable)

# Define the UI
ui <- fluidPage(
  titlePanel("Seguimiento de Presión Arterial"),
  sidebarLayout(
    sidebarPanel(
      dateInput("date", "Fecha de Registro", value = Sys.Date()),
      numericInput("systolic", "Presión Sistólica", value = 120, min = 80, max = 200),
      numericInput("diastolic", "Presión Diastólica", value = 80, min = 50, max = 120),
      actionButton("add", "Agregar Registro"),
      br(),
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

# Define the server
server <- function(input, output, session) {
  # File path for saving data
  file_path <- "presion-daniel.csv"
  
  # Reactive data storage
  data <- reactiveVal({
    if (file.exists(file_path)) {
      loaded_data <- read.csv(file_path, stringsAsFactors = FALSE)
      loaded_data$Fecha <- as.Date(loaded_data$Fecha)
      loaded_data
    } else {
      data.frame(
        Fecha = as.Date(character()),
        Sistólica = numeric(),
        Diastólica = numeric(),
        stringsAsFactors = FALSE
      )
    }
  })
  
  # Add new data
  observeEvent(input$add, {
    new_data <- data.frame(
      Fecha = input$date,
      Sistólica = input$systolic,
      Diastólica = input$diastolic
    )
    updated_data <- rbind(data(), new_data)
    data(updated_data)
    write.csv(updated_data, file_path, row.names = FALSE)
  })
  
  # Render the plot
  output$pressurePlot <- renderPlot({
    plot_data <- data()
    if (nrow(plot_data) == 0) return(NULL)
    
    ggplot(plot_data, aes(x = Fecha)) +
      geom_line(aes(y = Sistólica, color = "Sistólica"), size = 1) +
      geom_line(aes(y = Diastólica, color = "Diastólica"), size = 1) +
      geom_ribbon(aes(ymin = 120, ymax = 140), fill = "#F7AD19", alpha = 0.2) +
      geom_ribbon(aes(ymin = 80, ymax = 90), fill = "#429EBD", alpha = 0.2) +
      labs(title = "Seguimiento de Presión Arterial",
           x = "Fecha",
           y = "Presión (mmHg)") +
      scale_color_manual(values = c("Sistólica" = "#4682B4", "Diastólica" = "#228B22")) +
      theme_minimal()
  })
  
  # Render the formatted data table
  output$formattedTable <- renderUI({
    plot_data <- data()
    if (nrow(plot_data) == 0) return(NULL)
    
    formatted_table <- formattable(
      plot_data,
      list(
        Sistólica = color_tile("white", "#F7AD19"),
        Diastólica = color_tile("white", "#429EBD"),
        Fecha = formatter("span", style = ~ style(color = "black"))
      )
    )
    
    HTML(as.character(formatted_table))
  })
  
  # Custom average systolic box
  output$customSystolicBox <- renderUI({
    plot_data <- data()
    if (nrow(plot_data) == 0) return(NULL)
    
    avg_systolic <- mean(plot_data$Sistólica)
    
    div(
      style = paste0("background-color: ", ifelse(avg_systolic > 140, "#F7AD19", "#429EBD"), "; ",
                     "color: white; padding: 20px; border-radius: 5px; text-align: center;"),
      h4("Promedio Sistólica"),
      h3(round(avg_systolic, 2))
    )
  })
  
  # Custom average diastolic box
  output$customDiastolicBox <- renderUI({
    plot_data <- data()
    if (nrow(plot_data) == 0) return(NULL)
    
    avg_diastolic <- mean(plot_data$Diastólica)
    
    div(
      style = paste0("background-color: ", ifelse(avg_diastolic > 90, "#F7AD19", "#429EBD"), "; ",
                     "color: white; padding: 20px; border-radius: 5px; text-align: center;"),
      h4("Promedio Diastólica"),
      h3(round(avg_diastolic, 2))
    )
  })
  
  # Download handler
  output$download <- downloadHandler(
    filename = function() {
      paste("registro_presion_arterial", Sys.Date(), ".csv", sep = "")
    },
    content = function(file) {
      write.csv(data(), file, row.names = FALSE)
    }
  )
}

# Run the application
shinyApp(ui = ui, server = server)

