# Python develop env
# Date : 2021-11-13
# Author : JianlongCao
FROM ubuntu:20.04

MAINTAINER JL Cao <caojianlong@outlook.com>

ENV TZ=Asia/Shanghai
ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
   apt-get install -y \
    bash-completion \
    tmux curl cscope \
    zsh sed sudo git tig qemu-system-arm qemu-efi

# oh-my-zsh
RUN sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
CMD [ "zsh" ]

# Remove default vim
RUN apt-get remove -y vim vim-runtime vim-tiny vim-common
RUN apt-get install -y build-essential autotools-dev automake man flex byacc pkg-config libevent-dev libtool libncurses-dev libssl-dev libcurl4-openssl-dev libexpat1-dev gettext python-dev

RUN git config --global alias.st status 
RUN git config --global alias.co checkout
RUN git config --global alias.br branch

# Install the SSH Server
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y dropbear
RUN echo 'root:root' |chpasswd

RUN mkdir /opt/vim
RUN cd /opt/vim && git clone https://github.com/vim/vim.git
RUN cd /opt/vim/vim/ && ./configure --prefix=/usr/local --with-features=huge --enable-cscope   --enable-pythoninterp --with-python-config-dir=$(python-config --configdir) &&make &&make install

RUN update-alternatives --install /usr/bin/editor editor /usr/local/bin/vim 1
RUN update-alternatives --set editor /usr/local/bin/vim
RUN update-alternatives --install /usr/bin/vi vi /usr/local/bin/vim 1
RUN update-alternatives --set vi /usr/local/bin/vim

#RUN apt-get install vim -y

# vim config
RUN cd ~/; git clone https://github.com/JianlongCao/MYVIM .jayvim; cd .jayvim; ./build.sh;

# tmux config
RUN cd ~/; git clone http://github.com/JianlongCao/TMUX.git .tmux; ln -s .tmux/.tmux.conf .tmux.conf

RUN apt-get update && apt-get install -y locales && rm -rf /var/lib/apt/lists/* \
    && localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8
ENV LANG en_US.utf8

RUN apt update && apt install fontconfig fonts-indic -y \
    && fc-cache -f 

# set as python3 only
RUN apt-get install  python-is-python3 python3-pip -y


RUN pip install pandas
RUN pip install tushare
RUN pip install chinese_calendar
RUN curl -LO http://prdownloads.sourceforge.net/ta-lib/ta-lib-0.4.0-src.tar.gz \
  && sudo tar -xzf ta-lib-0.4.0-src.tar.gz \
  && sudo rm ta-lib-0.4.0-src.tar.gz \
  && cd ta-lib/ \
  && sudo ./configure --prefix=/usr \
  && sudo make \
  && sudo make install \
  && cd ~ \
  && sudo rm -rf ta-lib/ \
  && pip install ta-lib
RUN pip install xlrd
RUN pip install schedule
RUN pip install tables
RUN pip install jupyterlab
