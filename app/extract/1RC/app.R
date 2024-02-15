source("../app_common.R")

shinyApp(ui     = function()                       { return(common_ui    ("Form 1RC", "IOTCForm1RC")) },
         server = function(input, output, session) { return(common_server("Form 1RC", "IOTCForm1RC", do_convert_1RC, input, output, session)) })
