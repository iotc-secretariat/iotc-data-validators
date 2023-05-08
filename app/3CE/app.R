source("../app_common.R")

shinyApp(ui     = function()                       { return(common_ui    ("Form 3-CE", "IOTCForm3CE")) }, 
         server = function(input, output, session) { return(common_server("Form 3-CE", "IOTCForm3CE", input, output, session)) })
