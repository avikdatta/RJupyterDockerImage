FROM avikdatta/basejupyterdockerimage

MAINTAINER reach4avik@yahoo.com

ENTRYPOINT []

ENV NB_USER vmuser

USER $NB_USER
RUN mkdir -p /home/$NB_USER/tmp \
    && chmod a+w /home/$NB_USER/tmp
    
USER root
WORKDIR /root/

RUN apt-get -y update &&   \
    apt-get install --no-install-recommends -y     \
    r-base                 \
    r-base-dev             \
    r-recommended          \
    r-cran-slam            \
    libnlopt-dev           \
    r-cran-nloptr          \
    libcurl4-openssl-dev   \
    libxml2-dev            \
    r-cran-xml             \
   &&  apt-get purge -y --auto-remove \
   &&  apt-get clean \
   &&  rm -rf /var/lib/apt/lists/*
    
USER $NB_USER
WORKDIR /home/$NB_USER

ENV PYENV_ROOT="/home/$NB_USER/.pyenv"   
ENV PATH="$PYENV_ROOT/libexec/:$PATH" 
ENV PATH="$PYENV_ROOT/shims/:$PATH" 

RUN eval "$(pyenv init -)"  \
    && pyenv global 3.5.2

ENV R_LIBS_USER /home/$NB_USER/rlib

RUN mkdir -p /home/$NB_USER/rlib

RUN echo 'install.packages(c("IRdisplay", \
                             "devtools"), \
                             repos="https://cloud.r-project.org/", \
                             dependencies = TRUE, type = "source")' > /home/$NB_USER/install.R \
    && echo "devtools::install_github('IRkernel/IRkernel')" >> /home/$NB_USER/install.R  \
    && echo "IRkernel::installspec()" >> /home/$NB_USER/install.R  \
    && R CMD BATCH --no-save /home/$NB_USER/install.R
    
RUN echo "library(devtools)" > /home/$NB_USER/install.R \
    && echo "slam_url <- 'https://cloud.r-project.org/src/contrib/Archive/slam/slam_0.1-37.tar.gz'"  >> /home/$NB_USER/install.R \
    && echo "install_url(slam_url)" >> /home/$NB_USER/install.R \
    && echo 'install_github("igraph/rigraph")' >> /home/$NB_USER/install.R \
    && R CMD BATCH --no-save /home/$NB_USER/install.R
    
RUN git clone https://github.com/johnmyleswhite/ML_for_Hackers.git \
    && sed -i 's|http://cran.stat.auckland.ac.nz/|https://cloud.r-project.org/|g' /home/$NB_USER/ML_for_Hackers/package_installer.R \
    && R CMD BATCH --no-save /home/$NB_USER/ML_for_Hackers/package_installer.R

RUN rm -rf /home/$NB_USER/install.R* \
           /home/$NB_USER/ML_for_Hackers/package_installer.R* 

RUN rm -rf /home/$NB_USER/.cache \
    && rm -rf /home/$NB_USER/tmp
    
EXPOSE 8889    
CMD ["jupyter","notebook","--ip=0.0.0.0","--port=8889","--no-browser"]
