###########################################
# Dockerfile to build an ide image
###########################################
# Base image is Ubuntu
FROM 32bit/ubuntu:14.04
# Author: Dr. Peter
MAINTAINER JL Cao <caojianlong@outlook.com>
# Install git vim cscope package
RUN apt-get update && \
   apt-get install -y \
	git \
	cscope 

# Remove default vim
RUN apt-get remove -y vim vim-runtime vim-tiny vim-common
# Install required packages
# build-essential # general
# autotools-dev # general
# automake # general
# man # general, git, tmux
# pkg-config # tmux
# libevent-dev # tmux
# libncurses-dev # tmux, vim
# libssl-dev # git
# libcurl4-openssl-dev # git
# libexpat1-dev # git
# gettext # git
RUN apt-get update
RUN apt-get install -y build-essential autotools-dev automake man pkg-config libevent-dev libncurses-dev libssl-dev libcurl4-openssl-dev libexpat1-dev gettext python-dev


RUN git config --global alias.st status 
RUN git config --global alias.co checkout
RUN git config --global alias.br branch

# Install the SSH Server
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y dropbear
RUN echo 'root:root' |chpasswd

# Install vim 7.4
RUN mkdir /opt/vim
RUN cd /opt/vim && curl -L -O ftp://ftp.vim.org/pub/vim/unix/vim-7.4.tar.bz2 && tar xjf vim-7.4.tar.bz2
RUN cd /opt/vim/vim74/ && ./configure --prefix=/usr/local --with-features=huge --enable-cscope   --enable-pythoninterp --with-python-config-dir=$(python-config --configdir) &&make &&make install

RUN update-alternatives --install /usr/bin/editor editor /usr/local/bin/vim 1
RUN update-alternatives --set editor /usr/local/bin/vim
RUN update-alternatives --install /usr/bin/vi vi /usr/local/bin/vim 1
RUN update-alternatives --set vi /usr/local/bin/vim
	
RUN cd ~/; git clone https://github.com/JianlongCao/MYVIM .jayvim; cd .jayvim; ./build.sh;

# Install tmux 1.9a
RUN mkdir /opt/tmux
RUN cd /opt/tmux && curl -L -O http://downloads.sourceforge.net/tmux/tmux-1.9a.tar.gz && tar xzf tmux-1.9a.tar.gz
RUN cd /opt/tmux/tmux-1.9a && ./configure && make && make install

RUN cd ~/; git clone http://github.com/JianlongCao/TMUX.git .tmux; ln -s .tmux/.tmux.conf .tmux.conf

# Install Oracle JDK 7

RUN apt-get update && apt-get install -y software-properties-common python-software-properties
RUN add-apt-repository ppa:webupd8team/java -y
RUN apt-get update
RUN echo oracle-java7-installer shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections
RUN apt-get install -y oracle-java7-installer

# Simple Global config
RUN echo 'set completion-ignore-case On' >~/.inputrc

#samba
EXPOSE 137:137
EXPOSE 138:138
EXPOSE 139:139
EXPOSE 445:445
RUN apt-get install -y samba
RUN git clone https://github.com/JianlongCao/SAMBA.git /tmp/SAMBA; cp /tmp/SAMBA/smb.conf /etc/samba/smb.conf
RUN mkdir -p /code; chmod 777 /code
RUN service samba restart

# Clean up APT when done.
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
