FROM continuumio/anaconda3

MAINTAINER Alessandro Adamo <alessandro.adamo@gmail.com>

USER root

RUN apt-get -qq update && apt-get -y dist-upgrade

RUN apt-get install -y \
	curl \
	gcc \
	g++ \
	gfortran \
	build-essential \
	locales \
	unixodbc \
	fonts-dejavu

ENV LC_ALL en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US.UTF-8

RUN echo "en_US.UTF-8 UTF-8" > /etc/locale.gen
RUN locale-gen

# Hacky access control for the image
RUN adduser --disabled-password --gecos '' innovation
RUN echo "innovation ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

RUN apt-get clean -y && apt-get clean -y && apt-get -y autoremove

# Install Oracle client
RUN conda install -c anaconda -y oracle-instantclient=11.2.0.4

# install jupyter 
RUN conda install -y jupyter ipykernel

WORKDIR /tmp
RUN wget --no-check-certificate --no-cookies --header "Cookie: oraclelicense=accept-securebackup-cookie" http://download.oracle.com/otn-pub/java/jdk/8u131-b11/d54c1d3a095b4ff2b6607d096fa80163/jdk-8u131-linux-x64.tar.gz
RUN mkdir -p /opt/jdk
RUN tar xvfz /tmp/jdk-8u131-linux-x64.tar.gz -C /opt/jdk
ENV JAVA_HOME /opt/jdk/jdk1.8.0_131
ENV PATH ${JAVA_HOME}/bin:$PATH
RUN update-alternatives --install /usr/bin/java java /opt/jdk/jdk1.8.0_131/bin/java 100
RUN update-alternatives --install /usr/bin/javac javac /opt/jdk/jdk1.8.0_131/bin/javac 100
RUN rm /tmp/jdk-8u131-linux-x64.tar.gz

# install Spark
# ADD https://d3kbcqa49mib13.cloudfront.net/spark-2.1.1-bin-hadoop2.7.tgz /opt/ 
# RUN ln -s /opt/spark-2.1.1-bin-hadoop2.7 /opt/spark
ADD https://d3kbcqa49mib13.cloudfront.net/spark-2.1.0-bin-hadoop2.7.tgz /opt/ 
RUN ln -s /opt/spark-2.1.0-bin-hadoop2.7 /opt/spark
ENV SPARK_HOME /opt/spark
ENV PATH ${SPARK_HOME}/sbin:${SPARK_HOME}/bin:${PATH}
ENV PYTHONPATH ${SPARK_HOME}/python/:${PYTHONPATH}
ENV PYTHONPATH ${SPARK_HOME}/python/lib/py4j-0.10.4-src.zip:${PYTHONPATH}

ENV PYSPARK_DRIVER_PYTHON="jupyter"
ENV PYSPARK_DRIVER_PYTHON_OPTS="notebook"

# install packages anaconda
RUN /opt/conda/bin/conda install -c anaconda -y \
	numpy=1.11.3 \
	scipy=0.19.0 \
	pandas=0.20.1 \
	pandas-datareader=0.2.1 \
	pytables=3.3.0 \
	matplotlib=2.0.2 \
	bokeh=0.12.5 \
	plotly=1.12.9 \
	curl=7.52.1 \
	blaze=0.10.1 \
	numba=0.33.0 \
	proj4=4.9.2 \
	iso8601=0.1.11 \
	memory_profiler=0.43 \
	line_profiler=2.0 \
	psutil=5.2.2 \
	nltk=3.2.3 \
	pcre=8.39 \
	scikit-learn=0.18.1 \
	seaborn=0.7.1 \
	sympy=1.0 \
	tensorflow=1.1.0 \
	pyodbc=4.0.17 \
	# tensorflow-gpu=1.1.0 \
	keras=2.0.2 \
	pyodbc=4.0.17 \
	# cx_oracle \
	&& conda clean -yat

RUN conda install -c mgckind cx_oracle=5.3
# Install Python 3
#RUN conda create -n python3 python=3.6 \
#	ipykernel \
#	ipywidgets \
#	pandas \
#	numpy \
#	scipy \
#	pillow \
#	matplotlib \
#	tensorflow \
#	keras \
#	gensim \
#	nltk \
#	seaborn \ 
#	scikit-learn \
#	plotly \
#	cython \ 
#	statsmodels \ 
#	numba \ 
#	bokeh \ 
#	pyodbc \
#	&& conda clean -yat

RUN conda install -c conda-forge -y \
	polyline=1.3.2 \
	geopy=1.11.0 \
	geopandas=0.2.1
# RUN conda install -n python3 -c conda-forge geopy 
# RUN conda install -n python3 -c mlgill gmplot

# R packages including IRKernel which gets installed globally.
RUN conda config --add channels r 
RUN conda install \
	rpy2=2.8.5 \
	r-base=3.3.2 \
	r-essentials=1.5.2 \
	r-spatial=7.3.8 \
	r-irkernel=0.7.1 \
	r-plyr=1.8.4 \
	r-devtools=1.12.0 \
	r-tidyverse=1.0.0 \
	r-shiny=0.14.2 \
	r-rmarkdown=1.3 \
	r-forecast=7.3 \
	r-reshape2=1.4.2 \
	r-caret=6.0_73 \
	r-curl=2.3 \
	r-ggplot2=2.2.0 \
	r-crayon=1.3.2 \
	r-randomforest=4.6_12 \
	r-rodbc=1.3_14 \
	r-sparklyr=0.5.1 \
	&& conda clean -tipsy

RUN conda install -c conda-forge \
	r-rgooglemaps=1.4.1

RUN /bin/bash -c ""

USER innovation
RUN mkdir /home/innovation/notebooks
WORKDIR /home/innovation

EXPOSE 8888

ENTRYPOINT ["/opt/conda/bin/jupyter", "notebook", "--port=8888", "--no-browser", "--ip=0.0.0.0", "--NotebookApp.token=''", "--NotebookApp.base_url='/'", "--NotebookApp.notebook_dir='/home/innovation/notebooks'"]
