FROM alpine:3.4

RUN mkdir -p /usr/src/app 
COPY cpanfile /usr/src/app
WORKDIR /usr/src/app

ENV EV_EXTRA_DEFS -DEV_NO_ATFORK
RUN apk update && \
  apk add perl perl-io-socket-ssl perl-dev g++ make wget curl && \
  curl -L https://cpanmin.us | perl - App::cpanminus && \
  cpanm -n --installdeps . -M https://cpan.metacpan.org && \
  apk del perl-dev g++ make wget curl && \
  rm -rf /root/.cpanm/* /usr/local/share/man/*

COPY . /usr/src/app
RUN chown -R daemon.daemon /usr/src/app
USER daemon
EXPOSE 8080
STOPSIGNAL SIGQUIT
CMD ["hypnotoad", "-f", "app.pl"]
