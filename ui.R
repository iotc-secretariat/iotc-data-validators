ui = shiny::tagList(
  tags$head(
    tags$link(rel = "stylesheet", type = "text/css", href = "fao-home.min.css"),
    tags$link(rel = "stylesheet", type = "text/css", href = "fao-theme.min.css"),
    tags$link(rel = "stylesheet", type = "text/css", href = "fao-adds.css")
  ),
  fluidPage(
    uiOutput("main_ui")
  ),
  app_footer(getAppId(), getAppVersion(), getAppDate()),
  fao_footer()
)
