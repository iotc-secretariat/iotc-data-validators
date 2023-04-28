source("../app_common.R")

shinyApp(ui     = function()                       { return(common_ui    ("Form 1-RC", "IOTCForm1RC")) }, 
         server = function(input, output, session) { return(common_server("Form 1-RC", "IOTCForm1RC", input, output, session)) })
