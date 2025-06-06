library(remotes)

options(download.file.method = "libcurl")

#Installs the iotc libs from their new BB location...

#install_bitbucket("iotc-ws/< repo name >", ref = "< branch >", subdir = "< if needed >", dependencies = TRUE)

# install_bitbucket("iotc-ws/core-utils-misc",          dependencies = TRUE)
remotes::install_github("iotc-secretariat/iotc-lib-core-utils-misc", dependencies = TRUE)
# install_bitbucket("iotc-ws/core-db-connections",      dependencies = TRUE)
# install_bitbucket("iotc-ws/iotc-reference-codelists", dependencies = TRUE)
remotes::install_github("iotc-secretariat/iotc-data-reference-codelists", dependencies = TRUE)
# install_bitbucket("iotc-ws/base-form-management",     dependencies = FALSE)
remotes::install_github("iotc-secretariat/iotc-lib-base-form-management", dependencies = FALSE)

remotes::install_github("daattali/shinycssloaders") # Necessary to download the latest (development) version of this lib

q(save = "no") #####
