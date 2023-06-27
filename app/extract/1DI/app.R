source("../app_common.R")

shinyApp(ui     = function()                       { return(common_ui    ("Form 1-DI", "IOTCForm1DI")) },
         server = function(input, output, session) { return(common_server("Form 1-DI", "IOTCForm1DI", function(output, source_code, quality_code) { return(output) }, input, output, session)) })
