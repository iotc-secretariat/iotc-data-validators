source("../app_common.R")

shinyApp(ui     = function()                       { return(common_ui    ("Form 3CE", "IOTCForm3CE")) },
         server = function(input, output, session) { return(common_server("Form 3CE", "IOTCForm3CE", do_convert_3CE, input, output, session)) })
