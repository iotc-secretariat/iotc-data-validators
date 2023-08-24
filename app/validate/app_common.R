library(shiny)
library(shinyjs)
library(shinyWidgets)
library(shinycssloaders)
library(DT)

library(iotc.data.common.workflow.legacy)

#shiny::devmode(TRUE)

filter_messages = function(response, level) {
  return(
    response$validation_messages[LEVEL == level][, .(Sheet = SOURCE, Column = COLUMN, Row = ROW, Message = TEXT)]
  )
}

info_messages = function(response) {
  return(filter_messages(response, "INFO"))
}

warn_messages = function(response) {
  return(filter_messages(response, "WARN"))
}

error_messages = function(response) {
  return(filter_messages(response, "ERROR"))
}

fatal_messages = function(response) {
  return(filter_messages(response, "FATAL"))
}

render_message = function(message, level) {
  return(
    div(
      class = "message",
      span(class = "level badge info",
           level
      ),
      span(class = "source badge secondary",
           message$Sheet
      ),
      span(class = "text",
           message$Message
      )
    )
  )
}

common_ui = function(form_name, form_class) {
  return(
    fluidPage(
      #theme = bslib::bs_theme(version = 5),
      title = paste(form_name, " validator"),
      tags$style(HTML("
        .file_input .form-group {
          margin-top: 15px;
          margin-bottom: 0 !important;
        }
        .file_input .progress {
          margin-bottom: 5px !important;
        }
        .message_panel {
          padding: 1em
        }
        .dt-right {
          text-align: right;
        }
        tr td.dt-right {
          padding-right: 1em !important;
        }
        pre {
          word-break: normal;
          white-space: normal;
        }
      ")),
      fluidRow(
        column(
          width = 12,
          h2(
            img(src = "iotc-logo.png", height = "96px"), 
            span(paste("IOTC", form_name, "data validation and analysis"))
          )
        )
      ),
      fluidRow(
        column(
          width = 4,
          fluidRow(
            column(
              width = 12,
              h3(paste("Select the IOTC", form_name, "to upload:")),
              hr(),
              div(
                class = "file_input",
                fileInput(
                  inputId = "IOTC_form", label = NULL,
                  width = "100%",
                  placeholder = paste("Choose a", form_name, "file"),
                  buttonLabel = icon(lib = "glyphicon", name = "folder-open"),
                  multiple = FALSE,
                  accept = c("application/msexcel", ".xlsx", ".xlsm")
                )
              )
            )
          ),
          fluidRow(
            column(
              width = 12,
              conditionalPanel(
                condition = "output.fileUploaded",
                fluidRow(
                  column(
                    width = 12,
                    h3(
                      span("Original file:"),
                      downloadButton("download_original_file", "Download"),
                      hr()
                    )
                  )
                ),
                fluidRow(
                  column(
                    width = 12,
                    h3("Validation summary:"),
                    uiOutput("summary")
                  )
                )
              )
            )
          )
        ),
        column(
          width = 8,
          conditionalPanel(
            condition = "output.fileUploaded",
            fluidRow(
              column(
                width = 12,
                h3(
                  span("Validation messages:"),
                ),
                hr(),
                h3(
                  downloadButton("download_messages", "Download"),
                  span("all messages"),
                ),
                hr(),
                tabsetPanel(
                  id = "messages",
                  type = "tabs",
                  tabPanel(
                    icon = icon(lib = "glyphicon", name = "remove-sign"),
                    title = "Fatal errors", # uiOutput("tab_label_fatal"),
                    div(class="message_panel",
                        dataTableOutput("fatal")
                    )
                  ),
                  tabPanel(
                    icon = icon(lib = "glyphicon", name = "exclamation-sign"),
                    title = "Errors", # uiOutput("tab_label_error"),
                    div(class="message_panel",
                        dataTableOutput("error")
                    )
                  ),
                  tabPanel(
                    icon = icon(lib = "glyphicon", name = "warning-sign"),
                    title = "Warnings", # uiOutput("tab_label_warn"),
                    div(class="message_panel",
                        dataTableOutput("warn")
                    )
                  ),
                  tabPanel(
                    icon = icon(lib = "glyphicon", name = "info-sign"),
                    title = "Info messages", #uiOutput("tab_label_info"),
                    #uiOutput("info", inline = TRUE)
                    div(class="message_panel",
                        dataTableOutput("info")
                    )
                  )
                )
              )
            )
          )
        )
      )
    )
  )
}

common_server = function(form_name, form_class, input, output, session) {
  # Updates the maximum uploadable file size to 64MB (instead of the 5MB default value)
  options(shiny.maxRequestSize = 64 * 1024^2)
  
  parse_file = reactive({
    if(length(input$IOTC_form) != 0) {
      #print((input$IOTC_form)$datapath)

      form =
        new(form_class, 
            path_to_file  = input$IOTC_form$datapath,
            original_name = input$IOTC_form$name
        )

      shinycssloaders::showPageSpinner(caption = "Processing file content...")
      
      result = validation_summary(form)
      
      return(result)
    }
  })

  # See: https://stackoverflow.com/questions/19686581/make-conditionalpanel-depend-on-files-uploaded-with-fileinput

  output$fileUploaded = reactive({
    return(!is.null(input$IOTC_form))
  })

  outputOptions(output, 'fileUploaded', suspendWhenHidden = FALSE)

  output$uploaded_file_status = renderText({
    response = req(parse_file(), cancelOutput = TRUE)

    if(!response$can_be_processed)
      return("danger")

    if(response$warning_messages > 0)
      return("warning")

    return("success")
  })

  output$summary = renderUI({
    response = req(parse_file(), cancelOutput = TRUE)

    shinycssloaders::hidePageSpinner()
    
    return(
      shinyWidgets::alert(
        status = ifelse(!response$can_be_processed, "danger",
                         ifelse(response$warning_messages > 0,
                                "warning",
                                "success")
        ),
        pre(
          response$summary
        ),
        em(
          paste0("Current form ", ifelse(response$can_be_processed, "CAN", "CANNOT"), " be successfully processed")
        )
      )
    )
  })
  
  output$download_original_file = downloadHandler(
    filename = function() {
      return(input$IOTC_form$name)
    },
    content  = function(file_name) {
      file.copy(file.path(input$IOTC_form$datapath), file_name)
    },
    contentType = "application/vnd.ms-excel"
  )

  output$download_messages = downloadHandler(
    filename = function() {
      return(
        str_replace_all(input$IOTC_form,
                        "\\.xlsx$",
                        replacement = "_validation_messages.csv")
      )
    },
    content  = function(file_name) {
      messages = req(parse_file(), cancelOutput = TRUE)$validation_messages
     
      messages$LEVEL = factor(
        messages$LEVEL,
        levels = c("FATAL", "ERROR", "WARN", "INFO"),
        labels = c("FATAL", "ERROR", "WARN", "INFO"),
        ordered = TRUE
      )

      messages$SOURCE = factor(
        messages$SOURCE,
        levels = c("Metadata", "Data"),
        labels = c("Metadata", "Data"),
        ordered = TRUE
      )

      messages = messages[order(SOURCE, LEVEL, ROW, COLUMN, TEXT)]

      write.csv(
        messages,
        row.names = FALSE,
        file_name
      )
    }
  )
  
  default_column_defs = list(list(visible = FALSE, targets = c(0)),
                             list(width = "92px", targets = c(1)),
                             list(width = "64px", targets = 2:3),
                             list(className = "dt-right" , targets = 2:3))
  
  default_dt_options = list(
    columnDefs = default_column_defs,
    selection = "none"
  )

  output$info = DT::renderDataTable({
      return(info_messages(req(parse_file(), cancelOutput = TRUE)))
    }, 
    options = default_dt_options
  )

  output$has_info_messages = reactive({
    return(nrow(info_messages(req(parse_file(), cancelOutput = TRUE)) > 0))
  })

  output$warn = DT::renderDataTable({
      return(warn_messages(req(parse_file(), cancelOutput = TRUE)))
    }, 
    options = default_dt_options
  )
  
  output$has_warn_messages = reactive({
    return(nrow(warn_messages(req(parse_file(), cancelOutput = TRUE)) > 0))
  })

  output$error = DT::renderDataTable({
      return(error_messages(req(parse_file(), cancelOutput = TRUE)))
    }, 
    options = default_dt_options
  )

  output$has_error_messages = reactive({
    return(nrow(error_messages(req(parse_file(), cancelOutput = TRUE)) > 0))
  })

  output$has_fatal_messages = reactive({
    return(nrow(fatal_messages(req(parse_file(), cancelOutput = TRUE)) > 0))
  })

  output$fatal = DT::renderDataTable({
      return(fatal_messages(req(parse_file(), cancelOutput = TRUE)))
    }, 
    options = default_dt_options
  )

  observe({
    req(parse_file(), cancelOutput = FALSE)

    num_info  = nrow(info_messages(req(parse_file(),  cancelOutput = TRUE)))
    num_warn  = nrow(warn_messages(req(parse_file(),  cancelOutput = TRUE)))
    num_error = nrow(error_messages(req(parse_file(), cancelOutput = TRUE)))
    num_fatal = nrow(fatal_messages(req(parse_file(), cancelOutput = TRUE)))

    if(num_info == 0) hideTab("messages", "Info messages")
    else {
      showTab("messages", "Info messages")
      updateTabsetPanel(inputId = "messages", selected = "Info messages")
    }

    if(num_warn == 0) hideTab("messages", "Warnings")
    else {
      showTab("messages", "Warnings")
      updateTabsetPanel(inputId = "messages", selected = "Warnings")
    }

    if(num_error == 0) hideTab("messages", "Errors")
    else {
      showTab("messages", "Errors")
      updateTabsetPanel(inputId = "messages", selected = "Errors")
    }

    if(num_fatal == 0) hideTab("messages", "Fatal errors")
    else {
      showTab("messages", "Fatal errors")
      updateTabsetPanel(inputId = "messages", selected = "Fatal errors")
    }
  })
}