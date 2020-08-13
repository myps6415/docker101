FROM alpine:latest
MAINTAINER JohnTung
ENV myworkdir /var/www/localhost/htdocs
WORKDIR ${myworkdir}
ARG whoami=John
RUN apk --update add apache2
RUN rm -rf /var/cache/apk/*
RUN echo "<h3>I am ${whoami}. I'm taking this great Docker Course. Round 01<h3>" >> index.html
RUN echo "<h3>I am ${whoami}. I'm taking this great Docker Course. Round 02<h3>" >> index.html
RUN echo "<h3>I am ${whoami}. I'm taking this great Docker Course. Round 03<h3>" >> index.html
COPY ./content.txt ./
RUN ls -l ./
RUN cat ./content.txt >> index.html
ENTRYPOINT ["httpd"]
CMD ["-D", "FOREGROUND"]