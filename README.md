# docker-learning
learning docker technology by myself
* 簡化部署流程
* 跨平台部署
* 建立乾淨測試環境

## [Install Docker Toolbox on macOS](https://docs.docker.com/toolbox/toolbox_install_mac/)
* MacOS 有兩種執行 Docker 的方法
    * Toolbox (課程建議使用)
    * Docker Desktop

### Dockerfile、Docker image、Docker container
* Docker file 可看作一個工廠，產生產品需要原料，包括：
    * Source code
    * base image
    * other input
* Docker file 產出 Docker image (部署包)
* Docker image 放入 Docker container (虛
擬容器)

## 建立與使用 Docker image
* [Docker Hub](https://hub.docker.com)

### 操作指令
* 查詢本機有的 image
```shell=
docker images
```

#### 下載
* docker 下載 image
```shell=
docker pull hello-world
```
* docker 下載指定版本 image
```shell=
docker pull uopsdod/course-image-first:v4
```

#### 執行
* docker container run image
```shell=
docker container run hello-world
```
* docker container run image 指定 TAG
```shell=
docker container run uopsdod/course-image-first:v4
```
* 一樣是執行的意思
```shell=
docker run --name c002 alpine ls /
```
* 持續執行指令，進入 container 內的 shell 指令介面
```shell=
docker run -it --name c003 alpine /bin/sh
```
* 持續執行且 container 執行結束後不會清除
```shell=
docker run -d --name c004 alpine tail -f /dev/null
```
* 進到上面持續執行的 container 進行編輯
```shell=
docker exec -it 7fbc28464b31 /bin/sh
```
* docker run nginx，將 8081 接到 nginx 使用的 80 port
```shell=
docker run -d -p 8081:80 --name c006 nginx
```

#### 建立
* 建立自己的 docker image
```shell=
docker build -t hsiaoyu/course-image-build .
```
* 建立的同時加入參數
```shell=
docker build -t hsiaoyu/course-image-build02 --build-arg my_name_is="JohnTung" .
```

#### 登入
* docker login
```shell=
docker login
```

#### 上傳
* 上傳 Dockerfile to Docker Hub
```shell=
docker push hsiaoyu/course-image-build
```

#### 刪除
* 刪除 image
```shell=
docker rmi uopsdod/course-image-first
```

* 刪除 container
```shell=
docker rm 9704bfb41980
```

* 強制刪除 image
```shell=
docker rmi -f hsiaoyu/course-image-build
```

#### 取得 docker machine ip
* 取得 ip
```shell=
echo $(docker-machine ip)
```

#### 停止 container
* 指令
```shell=
docker container stop 0f89f0f56d4e
```

#### 列出 container
* 列出執行中的 container
```shell=
docker container ls
```
* 不論是否在執行都列出來
```shell=
docker container ls -a
```

## Dockerfile 觀念
### 建立 Dockerfile
#### FROM
* 取得什麼 image
```
FROM alpine:latest
```

#### ENTRYPOINT
* 執行指令
```
ENTRYPOINT ["httpd", "-D", "FOREGROUND"]
```

#### RUN
* image 啟起來後執行
```
RUN apk --update add apache2
RUN rm -rf /var/cache/apk/*
```
* 每個 run 是不同的 container，不相通
* 要寫在同一行才會相互影響，透過 Linux 指令 `&&` 相接

#### ENV
* 設定統一的變數
* 這邊的範例設定 `ENV` 為 `myworkdir`，接下來的 `RUN` 便可帶入 `myworkdir`
```dockerfile=
ENV myworkdir /var/www/localhost/htdocs
RUN cd ${myworkdir} \
    && echo "<h3>I am John. I'm taking this great Docker Course. Round 01<h3>" >> index.html
```

#### WORKDIR
* 搭配 `ENV` 可更簡潔 Dockerfile
```dockerfile=
ENV myworkdir /var/www/localhost/htdocs
WORKDIR ${myworkdir}
RUN echo "<h3>I am John. I'm taking this great Docker Course. Round 01<h3>" >> index.html
```

#### ARG
* 用於設定變數，這邊的範例用於設定名字
```dockerfile=
ENV myworkdir /var/www/localhost/htdocs
WORKDIR ${myworkdir}
ARG whoami=John
RUN echo "<h3>I am ${whoami}. I'm taking this great Docker Course. Round 01<h3>" >> index.html
```
* 依照上列設定可印出：
```
I am John. I'm taking this great Docker Course. Round 01
```
* 在 docker build image 時可使用 `--build-arg` 設定 arg 變數
```shell=
docker build --build-arg whoami=Tony -t hsiaoyu/007 .
docker run -d -p 8007:80 hsiaoyu/007
```

#### COPY
* 將檔案放入 container 空間的根目錄
* `./content.txt`: 當前 Linux VM 的空間
* `./`: Container 空間，這邊會放到 `ENV` 設定的路徑底下
```dockerfile= 
COPY ./content.txt ./
```