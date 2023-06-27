source("../../app_common.R")

shinyApp(ui     = function()                       { return(common_ui    ("Form 3-CE-multiple", "IOTCForm3CEMultiple")) },
         server = function(input, output, session) { return(common_server("Form 3-CE-multiple", "IOTCForm3CEMultiple", do_convert_3CE, input, output, session)) })
