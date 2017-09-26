FROM avikdatta/basejupyterdockerimage

MAINTAINER reach4avik@yahoo.com

ENTRYPOINT []

ENV NB_USER vmuser

USER root
WORKDIR /root/

RUN apt-get -y update &&   \
    apt-get install -y     \
    r-base                 \
    r-base-dev             \
    r-recommended          \
    libssl-dev             \
    libcurl4-openssl-dev   
    
#RUN echo 'options(repos = c(CRAN = "https://cran.rstudio.com/"), download.file.method = "libcurl")' >> /etc/R/Rprofile.site \
#    && echo 'source("/etc/R/Rprofile.site")' >> /etc/littler.r \
#    && ln -s /usr/share/doc/littler/examples/install.r /usr/local/bin/install.r \
#    && ln -s /usr/share/doc/littler/examples/install2.r /usr/local/bin/install2.r \
#    && ln -s /usr/share/doc/littler/examples/installGithub.r /usr/local/bin/installGithub.r \
#    && ln -s /usr/share/doc/littler/examples/testInstalled.r /usr/local/bin/testInstalled.r \
#    #&& install.r docopt \
#    && rm -rf /tmp/downloaded_packages/ /tmp/*.rds \
#    && rm -rf /var/lib/apt/lists/*
    
USER $NB_USER
WORKDIR /home/$NB_USER

ENV PYENV_ROOT="//home/$NB_USER/.pyenv"   
ENV PATH="$PYENV_ROOT/libexec/:$PATH" 
ENV PATH="$PYENV_ROOT/shims/:$PATH" 

RUN eval "$(pyenv init -)" 
RUN pyenv global 3.5.2

ENV R_LIBS_USER /home/$NB_USER/rlib

RUN mkdir -p /home/$NB_USER/rlib

RUN echo "install.packages(c('RCurl','ggplot2'),repos='http://cran.us.r-project.org/')" > /home/$NB_USER/install.R 
RUN R CMD BATCH --no-save /home/$NB_USER/install.R

RUN echo "install.packages(c('igraph','lme4'),repos='http://cran.us.r-project.org/')" > /home/$NB_USER/install.R 
RUN R CMD BATCH --no-save /home/$NB_USER/install.R

RUN echo "install.packages(c('lubridate','rshape'),repos='http://cran.us.r-project.org/')" > /home/$NB_USER/install.R 
RUN R CMD BATCH --no-save /home/$NB_USER/install.R

RUN echo "install.packages(c('RJSONIO','XML'),repos='http://cran.us.r-project.org/')" > /home/$NB_USER/install.R 
RUN R CMD BATCH --no-save /home/$NB_USER/install.R

RUN echo "install.packages(c('tm','repr'),repos='http://cran.us.r-project.org/')" > /home/$NB_USER/install.R 
RUN R CMD BATCH --no-save /home/$NB_USER/install.R

RUN echo "install.packages(c(),repos='http://cran.us.r-project.org/')" > /home/$NB_USER/install.R 
RUN R CMD BATCH --no-save /home/$NB_USER/install.R

RUN echo "install.packages(c(),repos='http://cran.us.r-project.org/')" > /home/$NB_USER/install.R 
RUN R CMD BATCH --no-save /home/$NB_USER/install.R

RUN echo "install.packages(c('IRdisplay', 'devtools'),repos='http://cran.us.r-project.org/')" > /home/$NB_USER/install.R \
    && echo "devtools::install_github('IRkernel/IRkernel')" >> /home/$NB_USER/install.R  \
    && echo "IRkernel::installspec()" >> /home/$NB_USER/install.R  

RUN R CMD BATCH --no-save /home/$NB_USER/install.R

RUN rm -f /home/$NB_USER/install.R*

CMD ['jupyter-notebook', '--ip=0.0.0.0']
