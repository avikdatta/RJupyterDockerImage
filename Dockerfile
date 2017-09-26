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
    
USER $NB_USER
WORKDIR /home/$NB_USER

ENV PYENV_ROOT="/home/$NB_USER/.pyenv"   
ENV PATH="$PYENV_ROOT/libexec/:$PATH" 
ENV PATH="$PYENV_ROOT/shims/:$PATH" 

RUN eval "$(pyenv init -)"  \
    && pyenv global 3.5.2

ENV R_LIBS_USER /home/$NB_USER/rlib

RUN mkdir -p /home/$NB_USER/rlib

#RUN echo "install.packages(c('RCurl','ggplot2','XML','tm'),repos='http://cran.us.r-project.org/')" > /home/$NB_USER/install.R \
#    && R CMD BATCH --no-save /home/$NB_USER/install.R


RUN echo "install.packages(c('IRdisplay', 'devtools'),repos='http://cran.us.r-project.org/')" > /home/$NB_USER/install.R \
    && echo "devtools::install_github('IRkernel/IRkernel')" >> /home/$NB_USER/install.R  \
    && echo "IRkernel::installspec()" >> /home/$NB_USER/install.R  \
    && R CMD BATCH --no-save /home/$NB_USER/install.R

RUN git clone https://github.com/johnmyleswhite/ML_for_Hackers.git \
    && echo "source('/home/$NB_USER/ML_for_Hackers/package_installer.R')" > /home/$NB_USER/install.R \
    && R CMD BATCH --no-save /home/$NB_USER/install.R
    
RUN rm -f /home/$NB_USER/install.R*
    
CMD ['jupyter-notebook', '--ip=0.0.0.0']
