source("../app_common.R")

shinyApp(ui     = function()                       { return(common_ui    ("Form 3-CE-update", "IOTCForm3CEUpdate")) },
         server = function(input, output, session) { return(common_server("Form 3-CE-update", "IOTCForm3CEUpdate", input, output, session)) })
