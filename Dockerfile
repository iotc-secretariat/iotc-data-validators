FROM rocker/shiny:4.1.2

# Environment variables

ENV _R_SHLIB_STRIP_=true

ARG BB_user
ARG BB_password

# Downloads version 1.1.1h of OpenSSL to resolve the issue
# with MS SQL ODBC connector not authenticating properly

# See: https://code.luasoftware.com/tutorials/linux/upgrade-openssl-on-ubuntu-20/

RUN wget https://www.openssl.org/source/openssl-1.1.1h.tar.gz && \
    tar -zxf openssl-1.1.1h.tar.gz

WORKDIR openssl-1.1.1h

RUN bash ./config && \
    make && \
    make install && \
    mv /usr/bin/openssl /usr/bin/openssl-1.1.1f && \
    ln -s /usr/local/bin/openssl /usr/bin/openssl && \
    ldconfig

WORKDIR /

# Installs R packages

RUN install2.r --error --skipinstalled \
    bslib \
    cachem \
    commonmark \
    crayon \
    data.table \
    devtools \
    digest \
    fastmap \
    fontawesome \
    fs \
    glue \
    httpuv \
    jsonlite \
    later \
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
    stringr

# Copies the app sources

RUN rm -rf /srv/shiny-server/*

COPY ./app /srv/shiny-server/validator

# Runs the "update_IOTC_deps.R" script, to install / update the IOTC dependencies

ENV BITBUCKET_USER=$BB_user
ENV BITBUCKET_PASSWORD=$BB_password

RUN Rscript /srv/shiny-server/validator/update_IOTC_deps.R

RUN echo DEFAULT_IOTC_DB_SERVER=$DB_server    >  /home/shiny/.Renviron && \
    echo IOTDB_USER=$DB_user                  >> /home/shiny/.Renviron && \
    echo IOTDB_PASSWORD=$DB_password          >> /home/shiny/.Renviron && \
    echo IOTCSTATISTICS_USER=$DB_user         >> /home/shiny/.Renviron && \
    echo IOTCSTATISTICS_PASSWORD=$DB_password >> /home/shiny/.Renviron && \
    echo WP_CE_RAISED_USER=$DB_user           >> /home/shiny/.Renviron && \
    echo WP_CE_RAISED_PASSWORD=$DB_password   >> /home/shiny/.Renviron && \
    echo SHINY_LOG_LEVEL=TRACE                >> /home/shiny/.Renviron && \
    chown shiny.shiny /home/shiny/.Renviron

#COPY ./app/shiny-server.conf /etc/shiny-server

# User running the Shiny server
USER shiny

# TCP/IP Port
EXPOSE 3838

# Starts Shiny
CMD ["/usr/bin/shiny-server"]
