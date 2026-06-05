
server = function(input, output, session) {

  react_module <- reactiveVal("home")
  react_resolver <- reactiveVal(TRUE)
  react_extraction_activated <- reactiveVal(FALSE)
  react_validation_activated <- reactiveVal(FALSE)

  homeUI <- function(){
    tagList(
      titlePanel(
        windowTitle = "IOTC data validators - extract and validate data",
        title = ""
      ),
      fluidRow(
        column = 12,
        tags$div(class="container",
                 actionLink(inputId = "module_validation", class="btn btn-primary text-monospace button-link", title="Click to open validation module",
                            icon = icon("check"),
                            label = "VALIDATE"
                 ),
                 actionLink(inputId = "module_extraction", class="btn btn-primary text-monospace button-link", title="Click to open extraction module",
                            icon = icon("table"),
                            label = "EXTRACT"
                 )
        )
      )
    )
  }

  output$main_ui <- renderUI({
    DEBUG("Render MAIN UI")
    switch(react_module(),
           "home" = {
             homeUI()
           },
           "extraction" = {
             INFO("Load extraction module")
             extraction_ui("extraction")
           },
           "validation" = {
             INFO("Load validation module")
             validation_ui("validation")
           }
    )
  })

  #events to update the model/page
  observeEvent(input$home,{
    react_module("home"); react_resolver(FALSE);
    updateURL(session, "")
  }, ignoreInit = T)
  observeEvent(input$module_extraction,{
    react_module("extraction"); react_resolver(FALSE);
    react_extraction_activated(TRUE)
    updateURL(session, "?module=extraction")
  }, ignoreInit = T)
  observeEvent(input$module_validation,{
    react_module("validation"); react_resolver(FALSE);
    react_validation_activated(TRUE)
    updateURL(session, "?module=validation")
  }, ignoreInit = T)

  #mechanism to load a module page from the URL
  observe({
    req(react_resolver())
    query <- parseQueryString(session$clientData$url_search)
    module = NULL
    if(is.null(query$module) || query$module == ""){
      module = "home"
    }else{
      module = query$module
    }
    if(module != "home"){
      eval(parse(text = paste0("react_", module, "_activated(TRUE)")))
    }
    react_module(module)
  })

  #configure module servers
  extraction_server("extraction", react_extraction_activated)
  validation_server("validation", react_validation_activated)
}
