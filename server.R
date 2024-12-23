## server.R
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
      geom_line(aes(y = Sistólica), size = 2, color = '#FF8A65') +
      geom_line(aes(y = Diastólica), size = 2, color = '#4DB6AC') +
      geom_ribbon(aes(ymin = 120, ymax = 140), fill = "#FF8A65", alpha = 0.2) +
      geom_ribbon(aes(ymin = 80, ymax = 90), fill = "#4DB6AC", alpha = 0.2) +
      geom_hline(yintercept = 120, color = "#D32F2F", linetype = "dashed", size = 1) +
      geom_hline(yintercept = 80, color = "#0D47A1", linetype = "dashed", size = 1) +
      theme_minimal()
  })
  
  # Render the formatted data table
  output$formattedTable <- renderUI({
    plot_data <- data()
    if (nrow(plot_data) == 0) return(NULL)
    
    formatted_table <- formattable(
      plot_data,
      list(
        Sistólica = color_tile("white", "#FF8A65"),
        Diastólica = color_tile("white", "#4DB6AC"),
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
      style = "background-color: #FF8A65; color: white; padding: 20px; border-radius: 5px; text-align: center;",
      h4("Promedio Sistólica"),
      h1(round(avg_systolic, 2))
    )
  })
  
  # Custom average diastolic box
  output$customDiastolicBox <- renderUI({
    plot_data <- data()
    if (nrow(plot_data) == 0) return(NULL)
    
    avg_diastolic <- mean(plot_data$Diastólica)
    
    div(
      style = "background-color: #4DB6AC; color: white; padding: 20px; border-radius: 5px; text-align: center;",
      h4("Promedio Diastólica"),
      h1(round(avg_diastolic, 2))
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


