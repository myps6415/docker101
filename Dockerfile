FROM alpine:latest
MAINTAINER JohnTung
RUN apk --update add apache2
RUN rm -rf /var/cache/apk/*
ENTRYPOINT ["httpd"]
CMD ["-D", "FOREGROUND"]