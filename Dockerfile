FROM alpine:latest
ENV myworkdir /var/www/localhost/htdocs/
ARG whoami=John
RUN apk --update add apache2
RUN rm -rf /var/cache/apk/*
ENTRYPOINT ["httpd", "-D", "FOREGROUND"]