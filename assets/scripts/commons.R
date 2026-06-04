#General helpers
logger <- function(type, symbol, txt, ...){
  log_txt <- sprintf(txt, ...)
  cat(sprintf("[iotc-data-browser][%s] %s %s \n", type, symbol, log_txt), file = stderr())
}
INFO <- function(txt, ...){logger("INFO", "\u2139", txt, ...)}
WARN <- function(txt, ...){logger("WARN", "\u26A0", txt, ...)}
ERROR <- function(txt, ...){logger("ERROR", "\u274C", txt, ...)}
DEBUG <- function(txt, ...){logger("DEBUG", "\u203C", txt, ...)}

DEBUG_MODULE_PROCESSING_TIME <- function(module, start, end){
  module_time = end - start
  DEBUG("\u23F3 %s module loaded in %s %s", module, as(module_time, "numeric"), attr(module_time, "units"))
}

#updateURL
updateURL <- function(session, path = ""){
  updateQueryString(
    queryString = path,
    mode = "push", session
  )
}

filter_messages = function(response, level) {
  return(
    response$validation_messages[LEVEL == level][, .(Sheet = SOURCE, Column = COLUMN, Row = ROW, Message = TEXT)]
  )
}

info_messages = function(response) {
  return(filter_messages(response, "INFO"))
}

warn_messages = function(response) {
  return(filter_messages(response, "WARN"))
}

error_messages = function(response) {
  return(filter_messages(response, "ERROR"))
}

fatal_messages = function(response) {
  return(filter_messages(response, "FATAL"))
}

render_message = function(message, level) {
  return(
    div(
      class = "message",
      span(class = "level badge info",
           level
      ),
      span(class = "source badge secondary",
           message$Sheet
      ),
      span(class = "text",
           message$Message
      )
    )
  )
}
