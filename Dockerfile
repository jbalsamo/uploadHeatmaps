FROM ubuntu
LABEL maintainer="joseph.balsamo@stonybrook.edu"
#
# QuIP - Heatmap Loader Docker Container
#
### update OS
RUN echo "Start update"
RUN \
  sed -i 's/# \(.*multiverse$\)/\1/g' /etc/apt/sources.list && \
  apt-get update && \
  apt-get -y upgrade
RUN \
  apt-get install -y libcurl4 openssl && \
  apt-get install -y build-essential && \
  apt-get install -y software-properties-common && \
  apt-get install -y byobu curl git htop man unzip vim wget gnupg

RUN echo "Install Mongo and Node"

RUN echo "deb [ arch=amd64 ] http://repo.mongodb.org/apt/ubuntu bionic/mongodb-org/4.0 multiverse" | tee /etc/apt/sources.list.d/mongodb-org-4.0.list
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 68818C72E52529D4

RUN apt-get update
RUN apt-get -y upgrade

RUN apt-get install -y mongodb nodejs

RUN \
  rm -rf /var/lib/apt/lists/* && \
  apt-get clean

# Add files.
ADD root/.bashrc /root/.bashrc
ADD root/.gitconfig /root/.gitconfig
ADD root/.scripts /root/.scripts

COPY convert_heatmaps.js /usr/local/bin/
COPY uploadHeatmaps.sh /usr/local/bin/
RUN chmod 0775 /usr/local/bin/uploadHeatmaps.sh
RUN mkdir /mnt/data

# Set environment variables.
ENV HOME /root

# Define working directory.
WORKDIR /root

ENTRYPOINT tail -f /dev/null

# Define default command.
CMD ["tail -f /dev/null"]