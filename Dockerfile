FROM rocker/shiny:4.1.2

# Environment variables

ENV _R_SHLIB_STRIP_=true

WORKDIR /

# Installs R packages

RUN install2.r --error --skipinstalled \
    bslib \
    cachem \
    commonmark \
    crayon \
    data.table \
    remotes \
    digest \
    DT \
    fastmap \
    fontawesome \
    fs \
    generics \
    glue \
    htmltools \
    httpuv \
    jsonlite \
    later \
    lubridate \
    magrittr \
    openxlsx \
    Rcpp \
    remotes \
    sass \
    shiny \
    shinyjs \
    shinyWidgets \
    sourcetools \
    stringi \
    stringr \
    timechange \
    vctrs \
    withr

RUN install2.r --error --skipinstalled \
    cli \
    cpp11 \
    lifecycle \
    promises \
    rlang \
    zip

# Copies the app sources

RUN rm -rf /srv/shiny-server/*

COPY ./app /srv/shiny-server/validator

# Runs the "update_IOTC_deps.R" script, to install / update the IOTC dependencies

RUN Rscript /srv/shiny-server/validator/update_IOTC_deps.R

RUN echo SHINY_LOG_LEVEL=TRACE                >> /home/shiny/.Renviron && \
    chown shiny.shiny /home/shiny/.Renviron

COPY ./app/shiny-server.conf /etc/shiny-server

RUN echo "shiny:pass" | chpasswd
RUN adduser shiny sudo

# User running the Shiny server
USER shiny

# TCP/IP Port
EXPOSE 3838

# Starts Shiny
CMD ["/usr/bin/shiny-server"]
