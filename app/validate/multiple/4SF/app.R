source("../../app_common.R")

shinyApp(ui     = function()                       { return(common_ui    ("Form 4-SF-multiple", "IOTCForm4SFMultiple")) }, 
         server = function(input, output, session) { return(common_server("Form 4-SF-multiple", "IOTCForm4SFMultiple", input, output, session)) })
