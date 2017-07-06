FROM continuumio/anaconda3

MAINTAINER Alessandro Adamo <alessandro.adamo@vodafone.com>

USER root

RUN apt-get -qq update && apt-get -y dist-upgrade

# Hacky access control for the image
RUN adduser --disabled-password --gecos '' innovation
RUN echo "innovation ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

RUN apt-get clean -y && apt-get clean -y && apt-get -y autoremove

# Install Oracle client
RUN conda install -c anaconda -y oracle-instantclient=11.2.0.4

# install jupyter 
RUN conda install -y jupyter ipykernel

# Install Python 3
RUN conda create -n python3 python=3.6 \
	ipykernel \
	ipywidgets \
	pandas \
	numpy \
	scipy \
	pillow \
	matplotlib \
	tensorflow \
	keras \
	gensim \
	nltk \
	seaborn \ 
	scikit-learn \
	plotly \
	cython \ 
	statsmodels \ 
	numba \ 
	bokeh \ 
	pyodbc \
	&& conda clean -yat

RUN conda install -n python3 -c conda-forge polyline 
RUN conda install -n python3 -c conda-forge geopy 
# RUN conda install -n python3 -c mlgill gmplot

# R packages including IRKernel which gets installed globally.
RUN conda config --add channels r
RUN conda install \
	rpy2 \
	r-base \
	r-essentials \
	r-spatial \
	r-irkernel \
	r-plyr \
	r-devtools \
	r-tidyverse \
	r-shiny \
	r-rmarkdown \
	r-forecast \
	r-rsqlite \
	r-reshape2 \
	r-caret \
	r-rcurl \
	r-ggplot2 \
	r-crayon \
	r-randomforest \
	r-rodbc \
	&& conda clean -tipsy

RUN conda install -n python3 -c conda-forge r-rgooglemaps

RUN /bin/bash -c ""

USER innovation
RUN mkdir /home/innovation/notebooks
WORKDIR /home/innovation

EXPOSE 8888
CMD ["jupyter", "notebook", "--port=8888", "--no-browser", "--ip=0.0.0.0", "--NotebookApp.token=''", "--NotebookApp.base_url='/'", "--NotebookApp.notebook_dir='/home/innovation/notebooks'"]
