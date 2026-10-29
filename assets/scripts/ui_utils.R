#app_footer
app_footer <- function(id, version, date){
  tags$div(
    class = "container-fluid",
    tags$div(
      class = "row align-items-center",
      tags$div(
        class = "col-md-12",
        tags$footer(
          class = "footer-dashboard mt-auto py-4 border-top",
          tags$div(
            tags$p(sprintf("%s - v%s (%s)", id, version, date), style = "float:left;color:#ccc;")
          ),
          align = "center"
        )
      )
    )
  )
}
