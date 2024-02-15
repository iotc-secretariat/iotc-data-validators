source("../../app_common.R")

shinyApp(ui     = function()                       { return(common_ui    ("Form 4-SF-update", "IOTCForm4SFUpdate")) },
         server = function(input, output, session) { return(common_server("Form 4-SF-update", "IOTCForm4SFUpdate", do_convert_4SF, input, output, session)) })
