source("../app_common.R")

shinyApp(ui     = function()                       { return(common_ui    ("Form 1-DI", "IOTCForm1DI")) },
         server = function(input, output, session) { return(common_server("Form 1-DI", "IOTCForm1DI", NA, input, output, session)) })
