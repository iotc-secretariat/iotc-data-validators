source("../app_common.R")

shinyApp(ui     = function()                       { return(common_ui    ("Form 3BU", "IOTCForm3BU")) },
         server = function(input, output, session) { return(common_server("Form 3BU", "IOTCForm3BU", NA, input, output, session)) })
