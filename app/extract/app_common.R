library(shiny)
library(shinyjs)
library(shinyWidgets)
library(shinycssloaders)
library(DT)

library(iotc.base.form.management.interim)
library(openxlsx)

SOURCE_CODES = as.data.table(read.xlsx("../IOTDB_codes.xlsx", sheet = "SOURCES"))
SOURCE_CODES = as.list(setNames(SOURCE_CODES$CODE, paste0(SOURCE_CODES$CODE, " - ", SOURCE_CODES$NAME_EN)))

QUALITY_CODES = as.data.table(read.xlsx("../IOTDB_codes.xlsx", sheet = "QUALITY"))
QUALITY_CODES = as.list(setNames(QUALITY_CODES$CODE, paste0(QUALITY_CODES$CODE, " - ", QUALITY_CODES$NAME_EN)))

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

common_ui = function(form_name, form_class) {
  return(
    fluidPage(
      #theme = bslib::bs_theme(version = 5),
      title = paste(form_name, " extractor"),
      tags$style(HTML("
        .file_input .form-group {
          margin-top: 15px;
          margin-bottom: 0 !important;
        }
        .file_input .progress {
          margin-bottom: 5px !important;
        }
        .tab-content {
          padding: 1em;
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
            span(paste("IOTC", form_name, "data extraction"))
          )
        )
      ),
      fluidRow(
        column(
          width = 6,
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
              width = 6,
              selectizeInput("source", "Data source:",
                             choices = SOURCE_CODES, selected = "LO", multiple = FALSE
              )
            ),
            column(
              width = 6,
              selectizeInput("quality", "Data quality:",
                             choices = QUALITY_CODES, selected = "FAIR", multiple = FALSE
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
                      downloadButton("download_original_file", "Download")
                    )
                  )
                )
              )
            )
          )
        ),
        column(
          width = 6,
          conditionalPanel(
            condition = "output.fileUploaded",
            h3("Validation summary:"),
            hr(),
            uiOutput("summary"),
            h3(
              downloadButton("download_messages", "Download"),
              span("all validation messages")
            )
          )
        )
      ),
      fluidRow(
        column(
          width = 12,
          hr()
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
                tabsetPanel(
                  id = "processed_data",
                  type = "tabs",
                  tabPanel(
                    #icon = icon(lib = "glyphicon", name = "remove-sign"),
                    title = "Extracted data",
                    div(
                      h3(
                        downloadButton("download_extracted_data", "Download")
                      ),
                      dataTableOutput("data")
                    )
                  ),
                  tabPanel(
                    #icon = icon(lib = "glyphicon", name = "exclamation-sign"),
                    title = "Extracted data (wide)", # uiOutput("tab_label_error"),
                    div(
                      h3(
                        downloadButton("download_extracted_data_wide", "Download")
                      ),
                      dataTableOutput("data_wide")
                    )
                  ),
                  tabPanel(
                    #icon = icon(lib = "glyphicon", name = "exclamation-sign"),
                    title = "Data (for IOTDB)", # uiOutput("tab_label_error"),
                    div(
                      h3(
                        downloadButton("download_extracted_data_IOTDB", "Download")
                      ),
                      dataTableOutput("data_IOTDB")
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

common_server = function(form_name, form_class, processing_function, input, output, session) {
  # Updates the maximum uploadable file size to 64MB (instead of the 5MB default value)
  options(shiny.maxRequestSize = 64 * 1024^2)

  parse_file = reactive({
    if(length(input$IOTC_form) != 0) {
      form =
        new(form_class,
            path_to_file  = input$IOTC_form$datapath,
            original_name = input$IOTC_form$name
        )

      shinycssloaders::showPageSpinner(caption = "Processing file content...")

      validation  = validation_summary(form)

      data = data.table()
      data_wide = data.table()
      data_IOTDB = data.table()

      tryCatch({
        data = extract_output(form, wide = FALSE)
      }, error = function(cond) {
        print(cond)
      })

      tryCatch({
        data_wide = extract_output(form, wide = TRUE)
      }, error = function(cond) {
        print(cond)
      })

      if(!is.null(processing_function)) {
        tryCatch({
          data_IOTDB  = processing_function(data, input$source, input$quality)
        }, error = function(cond) {
           print(cond)
        })
      }

      return(
        list(
          validation = validation,
          data       = data,
          data_wide  = data_wide,
          data_IOTDB = data_IOTDB
        )
      )
    }
  })

  # See: https://stackoverflow.com/questions/19686581/make-conditionalpanel-depend-on-files-uploaded-with-fileinput

  output$fileUploaded = reactive({
    return(!is.null(input$IOTC_form))
  })

  outputOptions(output, 'fileUploaded', suspendWhenHidden = FALSE)

  output$uploaded_file_status = renderText({
    response = req(parse_file(), cancelOutput = TRUE)$validation

    if(!response$can_be_processed)
      return("danger")

    if(response$warning_messages > 0)
      return("warning")

    return("success")
  })

  output$summary = renderUI({
    response = req(parse_file(), cancelOutput = TRUE)$validation

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
      messages = req(parse_file(), cancelOutput = TRUE)$validation$validation_messages

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
        na = "",
        file_name
      )
    }
  )

  output$download_extracted_data = downloadHandler(
    filename = function() {
      return(
        str_replace_all(input$IOTC_form,
                        "\\.xlsx$",
                        replacement = "_extracted_data.csv")
      )
    },
    content  = function(file_name) {
      extracted_data = req(parse_file(), cancelOutput = TRUE)$data

      write.csv(
        extracted_data,
        row.names = FALSE,
        na = "",
        file_name
      )
    }
  )

  output$download_extracted_data_wide = downloadHandler(
    filename = function() {
      return(
        str_replace_all(input$IOTC_form,
                        "\\.xlsx$",
                        replacement = "_extracted_data_wide.csv")
      )
    },
    content  = function(file_name) {
      extracted_data = req(parse_file(), cancelOutput = TRUE)$data_wide

      write.csv(
        extracted_data,
        row.names = FALSE,
        na = "",
        file_name
      )
    }
  )

  output$download_extracted_data_IOTDB = downloadHandler(
    filename = function() {
      return(
        str_replace_all(input$IOTC_form,
                        "\\.xlsx$",
                        replacement = "_extracted_data_IOTDB.csv")
      )
    },
    content  = function(file_name) {
      extracted_data = req(parse_file(), cancelOutput = TRUE)$data_IOTDB

      write.csv(
        extracted_data,
        row.names = FALSE,
        na = "",
        file_name
      )
    }
  )

  output$data = DT::renderDataTable({
    return(req(parse_file(), cancelOutput = TRUE)$data)
  })

  output$data_wide = DT::renderDataTable({
    return(req(parse_file(), cancelOutput = TRUE)$data_wide)
  })

  output$data_IOTDB = DT::renderDataTable({
    return(req(parse_file(), cancelOutput = TRUE)$data_IOTDB)
  })

  observe({
    req(parse_file(), cancelOutput = FALSE)

    num_info  = nrow(info_messages(req(parse_file()$response,  cancelOutput = TRUE)))
    num_warn  = nrow(warn_messages(req(parse_file()$response,  cancelOutput = TRUE)))
    num_error = nrow(error_messages(req(parse_file()$response, cancelOutput = TRUE)))
    num_fatal = nrow(fatal_messages(req(parse_file()$response, cancelOutput = TRUE)))

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
