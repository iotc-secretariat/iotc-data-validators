#getAppPackage
getAppPackage <- function(){
  package <- jsonlite::read_json('./package.json')
  return(package)
}

#getAppId
getAppId <- function(){
  package <- getAppPackage()
  return(package$id)
}

#getAppVersion
getAppVersion <- function(){
  package <- getAppPackage()
  return(package$version)
}

#getAppDate
getAppDate <- function(){
  package <- getAppPackage()
  return(package$date)
}
