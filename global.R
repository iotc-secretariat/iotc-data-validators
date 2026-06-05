#packages
library(shiny)
library(shinyjs)
library(shinyWidgets)
library(shinycssloaders)
library(DT)
library(openxlsx)
library(iotc.base.form.management)

#options
# Updates the maximum uploadable file size to 64MB (instead of the 5MB default value)
options(shiny.maxRequestSize = 64 * 1024^2)

#data
SOURCE_CODES = as.data.table(read.xlsx("./assets/data/IOTDB_codes.xlsx", sheet = "SOURCES"))
SOURCE_CODES = as.list(setNames(SOURCE_CODES$CODE, paste0(SOURCE_CODES$CODE, " - ", SOURCE_CODES$NAME_EN)))
QUALITY_CODES = as.data.table(read.xlsx("./assets/data/IOTDB_codes.xlsx", sheet = "QUALITY"))
QUALITY_CODES = as.list(setNames(QUALITY_CODES$CODE, paste0(QUALITY_CODES$CODE, " - ", QUALITY_CODES$NAME_EN)))

IOTC_FORM_TYPES = setNames(
  object = c(
    "IOTCForm1DI",
    "IOTCForm1RC",
    "IOTCForm3BU",
    "IOTCForm3CE", "IOTCForm3CEUpdate",
    "IOTCForm4SF", "IOTCForm4SFUpdate"
  ),
  nm = c(
    "Form 1-DI",
    "Form 1-RC",
    "Form 3-BU",
    "Form 3-CE", "Form 3-CE-update",
    "Form 4-SF", "Form 4-SF-update"
  )
)

#scripts
source("./assets/scripts/commons.R")

#modules
source("./modules/validation_ui.R")
source("./modules/validation_server.R")
source("./modules/extraction_ui.R")
source("./modules/extraction_server.R")
