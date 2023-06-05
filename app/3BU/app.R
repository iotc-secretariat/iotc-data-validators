source("../app_common.R")

shinyApp(ui     = function()                       { return(common_ui    ("Form 3-BU", "IOTCForm3BU")) }, 
         server = function(input, output, session) { return(common_server("Form 3-BU", "IOTCForm3BU", input, output, session)) })
