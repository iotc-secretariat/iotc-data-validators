ui = shiny::tagList(
  tags$head(
    tags$link(rel = "stylesheet", type = "text/css", href = "iotc-data-validators.css")
  ),
  fluidPage(
    uiOutput("main_ui")
  ),
  tags$footer(footer(getAppId(), getAppVersion(), getAppDate()), align = "center")
)
