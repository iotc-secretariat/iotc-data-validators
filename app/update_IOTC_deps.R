library(devtools)

options(download.file.method = "libcurl")

#Installs the iotc libs from their new BB location...

#install_bitbucket("iotc-ws/< repo name >", ref = "< branch >", subdir = "< if needed >", dependencies = TRUE)

install_bitbucket("iotc-ws/core-utils-misc",          dependencies = TRUE)
install_bitbucket("iotc-ws/iotc-reference-codelists", dependencies = TRUE) 
install_bitbucket("iotc-ws/workflow",                 dependencies = TRUE, ref = "legacy-forms")  

install_github("daattali/shinycssloaders") 

q(save = "no")
