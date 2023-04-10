FROM ubuntu:22.04
LABEL maintainer="zhanght9"
LABEL version="1.0"
LABEL description="This is CXX program container."


# install dependencies
RUN apt-get update && apt-get install -y \
    sudo    \
    bash-completion	\
    vim \
    build-essential	\
    ccache  \
    git \
    wget    \
    clangd  \
    cppcheck    \

# CREATE USER
RUN  useradd -m zhanght9 -d /home/user -s /bin/bash -g  -G sudo && cd /home/user && HOME=/home/user
RUN echo 'user:user' | chpasswd  # CREATE PASSWORT FOR USER AFTER BUIDLING CONTAINER	

# configure Git
RUN git config --global user.name zhanght9 && \ 
    git config --global user.email zhanght9@xxx.com && \ 
    git config --global credential.helper store && \
    git config --global core.editor vim
ENV LANG C.UTF-8

ENV LANG C.UTF-8
WORKDIR /home/$USER
EXPOSE 8080
CMD /bin/bash
