#extraction_server
extraction_server <- function(id, activated){

  moduleServer(id, function(input, output, session) {

    ns <- session$ns

    #reactive
    form_class = reactiveVal(NULL)
    form_name = reactiveVal(NULL)
    form_processor = reactiveVal(NULL)
    fileUploaded = reactiveVal(FALSE)
    file_input_key = reactiveVal(0)

    #functions
    parse_file = reactive({
      if(length(input[[paste0("IOTC_form_", file_input_key())]]) != 0) {
        INFO("Init form class")
        form =
          new(form_class(),
              path_to_file  = input[[paste0("IOTC_form_", file_input_key())]]$datapath,
              original_name = input[[paste0("IOTC_form_", file_input_key())]]$name
          )

        shinycssloaders::showPageSpinner(caption = "Processing file content...")

        INFO("Create validation summary")
        validation  = iotc.base.form.management::validation_summary(form)

        data = data.table()
        data_wide = data.table()
        data_IOTDB = data.table()

        INFO("Extract form data")
        tryCatch({
          data = iotc.base.form.management::extract_output(form, wide = FALSE)
        }, error = function(cond) {
          ERROR("Error while extracting form data")
          print(cond)
        })

        INFO("Extract form data (wide)")
        tryCatch({
          data_wide = iotc.base.form.management::extract_output(form, wide = TRUE)
        }, error = function(cond) {
          ERROR("Error while extracting form data (wide)")
          print(cond)
        })

        INFO("Process form data")
        if(!is.null(form_processor())) {
          tryCatch({
            readr::write_csv(data, "data_3ce.csv")
            readr::write_csv(data_wide, "data_3ce_wide.csv")
            data_IOTDB  = form_processor()(data, input$source, input$quality)
          }, error = function(cond) {
            ERROR("Error while processing form data")
            print(cond)
          })
        }

        fileUploaded(!is.null(input[[paste0("IOTC_form_", file_input_key())]]))

        return(
          list(
            validation = validation,
            data       = data,
            data_wide  = data_wide,
            data_IOTDB = data_IOTDB
          )
        )
      }else{
        fileUploaded(FALSE)
        return(NULL)
      }
    })


    #UI
    output$extraction_ui_page <- renderUI({
      fluidPage(
        #theme = bslib::bs_theme(version = 5),
        title = "Extraction module",
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
              span(paste("IOTC data extraction"))
            )
          )
        ),
        fluidRow(
          column(
            width = 6,
            fluidRow(
              column(
                width = 12,
                h3(paste("Select the IOTC form type")),
                hr(),
                selectizeInput(
                  inputId = ns("form_type"),
                  label = "IOTC Form type",
                  choices = c("", IOTC_FORM_TYPES),
                  selected = if(!is.null(form_class())) form_class() else "",
                  options = list(
                    placeholder = 'Select an item'
                  )
                )
              )
            ),
            if(!is.null(form_name())) fluidRow(
              column(
                width = 12,
                h3(paste("Select the IOTC", form_name(), "to upload:")),
                hr(),
                uiOutput(ns("file_input_ui"))
              )
            ),
            fluidRow(
              column(
                width = 6,
                selectizeInput(ns("source"), "Data source:",
                               choices = SOURCE_CODES, selected = "LO", multiple = FALSE
                )
              ),
              column(
                width = 6,
                selectizeInput(ns("quality"), "Data quality:",
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
              uiOutput(ns("summary")),
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
    })

    output$file_input_ui <- renderUI({

      key = file_input_key()

      dynamic_id <- paste0("IOTC_form_", key)

      div(
        class = "file_input",
        fileInput(
          inputId = ns(dynamic_id), label = NULL,
          width = "100%",
          placeholder = paste("Choose a", form_name(), "file"),
          buttonLabel = icon(lib = "glyphicon", name = "folder-open"),
          multiple = FALSE,
          accept = c("application/msexcel", ".xlsx", ".xlsm")
        )
      )

    })


    #form type observer
    observeEvent(input$form_type,{
        req(input$form_type != "")
        form_class(input$form_type)
        form_name(names(IOTC_FORM_TYPES)[IOTC_FORM_TYPES == input$form_type])
        form_processor(switch(input$form_type,
          "IOTCForm1DI" = NULL,
          "IOTCForm1RC" = iotc.base.form.management::do_convert_1RC,
          "IOTCForm3BU" = NULL,
          "IOTCForm3CE" = iotc.base.form.management::do_convert_3CE,
          "IOTCForm3CEUpdate" = iotc.base.form.management::do_convert_3CE,
          "IOTCForm4SF" = iotc.base.form.management::do_convert_4SF,
          "IOTCForm4SFUpdate" = iotc.base.form.management::do_convert_4SF
        ))
        updateURL(session, sprintf("?module=extraction&form=%s", input$form_type))

        # Increment key to force re-render and reset
        file_input_key(file_input_key() + 1)
    })

    #form type resolver
    observe({
      query <- parseQueryString(session$clientData$url_search)
      if(!is.null(query$form)){
        form_class(query$form)
      }
    })

    # See: https://stackoverflow.com/questions/19686581/make-conditionalpanel-depend-on-files-uploaded-with-fileinput
#
#     output$fileUploaded = reactive({
#       return(!is.null(input$IOTC_form))
#     })

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
        return(input[[paste0("IOTC_form_", file_input_key())]]$name)
      },
      content  = function(file_name) {
        file.copy(file.path(input[[paste0("IOTC_form_", file_input_key())]]$datapath), file_name)
      },
      contentType = "application/vnd.ms-excel"
    )

    output$download_messages = downloadHandler(
      filename = function() {
        return(
          str_replace_all(input[[paste0("IOTC_form_", file_input_key())]],
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
          str_replace_all(input[[paste0("IOTC_form_", file_input_key())]],
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
          str_replace_all(input[[paste0("IOTC_form_", file_input_key())]],
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
          str_replace_all(input[[paste0("IOTC_form_", file_input_key())]],
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





  })

}
