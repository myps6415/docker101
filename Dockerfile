FROM alpine:latest
MAINTAINER JohnTung
RUN apk --update add apache2
RUN rm -rf /var/cache/apk/*
RUN cd /var/www/localhost/htdocs && pwd
ENTRYPOINT ["httpd"]
CMD ["-D", "FOREGROUND"]