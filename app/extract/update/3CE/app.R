source("../../app_common.R")

shinyApp(ui     = function()                       { return(common_ui    ("Form 3CE (update)", "IOTCForm3CEUpdate")) },
         server = function(input, output, session) { return(common_server("Form 3CE (update)", "IOTCForm3CEUpdate", do_convert_3CE, input, output, session)) })
