FROM debian:jessie
MAINTAINER Eugene Obrezkov "ghaiklor@gmail.com"

ENV PATH "/root/.cargo/bin:$PATH"

ADD ./ /src
WORKDIR /src

RUN apt-get update && apt-get -y install \
  build-essential \
  apt-get -y clean

RUN curl https://sh.rustup.rs > rustup.sh
RUN sh -s rustup.sh -- -y
