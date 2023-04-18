# docker101
*learning docker technology*
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

## Docker 網路模式
### None 模式
* 不能向外連
* 外面也連不進去
* 封閉的網路空間

### Bridge 模式
* 把容器放在某個 Bridge Network 中

### Container 模式
* 對應其他容器得到網路標籤

### Host 模式
* 和 Linux VM Network 取得 ip 標籤
* 屬於 Linux VM Network
* 可以和 Linux 上其他的程序互通網路

### 操作指令
#### 列出現有的 network
```shell=
docker network ls
```

#### 以 `none` 網路模式執行 alpine，並持續 `tail -f /dev/null`
```shell=
docker run -d --network none --name none-mode alpine tail -f /dev/null
```

#### 列出 `none` 網路模式下的詳細資訊
```shell=
docker network inspect none
```

#### 建立新的 bridge 網路，命名為 my-bridge
```shell=
docker network create --driver bridge my-bridge
```

* 查詢 my-bridge 網路資訊
```shell=
docker network inspect my-bridge
```

#### 啟一個 Container 執行 alpine `tail -f /dev/null`，命名為 `bridge-mode001`，並使用上面所建立的 `my-bridge` 網路模式
```shell=
docker run -d --network my-bridge --name bridge-mode001 alpine tail -f /dev/null
```

* 此時透過 `docker network inspect my-bridge` 查看，會發現 bridge-mode001 這個 Container 已經加入 my-bridge 網路環境中
* 連入 Container
```shell=
docker exec -it 8b651c72dd63361db7a6f58f6e55546beb3a5c1d2afd9e2aef750e8ab594d858 /bin/sh
```

#### 將 Container 加入現有的 bridge network 中
* bridge-mode001 and bridge-mode002 are in bridge named my-bridge
* bridge-mode003 is in bridge named their-bridge
* add bridge-mode003 to bridge named my-bridge
```shell=
docker network connect my-bridge bridge-mode003
```
* check my-bridge inspect
```shell=
docker network inspect my-bridge
```

#### Container Mode
* 建立一個 container mode 的 container
```shell=
docker run -d --network container:bridge-mode001 --name container-mode001 alpine tail -f /dev/null
```

## Docker Volume
* Container Disk: 啟一台 Container 後會產生 Tmp 存放空間，若 Container 刪除後則會一併刪除
* Linux VM Disk: Container 刪除後仍會存在
* Mac Host Disk: 本機端的儲存空間
* 預設 `docker run` 是使用 Container Disk，刪除後資料就會一併刪除

### 操作指令
* 列出現有的 Volume
```shell=
docker volume ls
```
* 建立 Volume
```shell=
docker volume create mainpage-vol
```
* 查看 Volume 詳細資訊
```shell=
docker volume inspect mainpage-vol
```
輸出：
```
[
    {
        "CreatedAt": "2020-09-09T03:04:18Z",
        "Driver": "local",
        "Labels": {},
        "Mountpoint": "/mnt/sda1/var/lib/docker/volumes/mainpage-vol/_data",
        "Name": "mainpage-vol",
        "Options": {},
        "Scope": "local"
    }
]
```
* 啟一個 Container，使用 mainpage-vol Valume
    * 把 `mainpage-vol:/var/www/localhost/htdocs/` mapping 起來
    * `mainpage-vol` 為 VM Linux Disk
    * `/var/www/localhost/htdocs/` 為 Container Disk 空間
    * 上面兩個空間會相互影響
```scala=
docker run -d -p 8081:80 -v mainpage-vol:/var/www/localhost/htdocs/ john/apache001
```
* 若 `-v` 後面沒加 Volume 名稱，系統會自動建立新的 Volume
```
docker run -d -p 8082:80 -v /var/www/localhost/htdocs/ john/apache001
```
用 `docker volume ls` 驗證會看到自動產生的亂數 Volume Name:
```
DRIVER              VOLUME NAME
local               6ac41ebd8aa5e60e463fbd7020e364a3d779712e3c8d35b46a800c22f629c6ea
local               mainpage-vol
```

## Docker Compose
* 幫忙管理 Docker 的各項功能
    * Service
    * Network
    * Volume
* 可以透過 Docker Compose 一次啟起多個 Container
### 建立 Docker-Compose file
#### Docker-Compose Services
* yaml 格式
```yaml=
version: "3.7"
services:
  myweb:
    build:
      context: .
      args:
        whoami: "Tony"
    image: john/myweb:latest
    ports:
      - "8080:80"
```
* 使用的 Dockerfile
```dockerfile=
FROM alpine:latest
ENV myworkdir /var/www/localhost/htdocs/
ARG whoami=John
WORKDIR ${myworkdir}
RUN apk --update add apache2
RUN rm -rf /var/cache/apk/*
RUN echo "<h3>I am ${whoami}. I am taking this great Docker Course. Round 01<h3>" >> index.html
RUN echo "<h3>I am ${whoami}. I am taking this great Docker Course. Round 02<h3>" >> index.html
RUN echo "<h3>I am ${whoami}. I am taking this great Docker Course. Round 03<h3>" >> index.html
ENTRYPOINT ["httpd", "-D", "FOREGROUND"]
```
* 透過 Docker-Compose 建立 image
    * `--no-cache` 會讓它每次 build 重新跑一次，避免有些東西沒有更新到
```shell=
docker-compose build --no-cache
```
* 透過 Docker-Compose 把所有東西啟起來
```shell=
docker-compose up -d
```
* 透過 Docker-Compose 把所有的 Container 下架
```shell=
docker-compose down
```
* Docker-Compose 可以同時啟多個 Container，docker-compose.yml 範例：
```yaml=
version: "3.7"
services:
  myweb:
    build:
      context: .
      args:
        whoami: "Tony"
    image: john/myweb:latest
    ports:
      - "8080:80"
  myweb2:
    build:
      context: .
      args:
        whoami: "Chris"
    image: john/myweb1:latest
    ports:
      - "8081:80"
  myweb3:
    build:
      context: .
      args:
        whoami: "Jane"
    image: john/myweb2:latest
    ports:
      - "8082:80"
```
* 若要設定 Container 不要從頭建立，而是直接取用現有的 image，設定如 `myweb4`
```yaml=
version: "3.7"
services:
  myweb:
    build:
      context: .
      args:
        whoami: "Tony"
    image: john/myweb:latest
    ports:
      - "8080:80"
  myweb2:
    build:
      context: .
      args:
        whoami: "Chris"
    image: john/myweb1:latest
    ports:
      - "8081:80"
  myweb3:
    build:
      context: .
      args:
        whoami: "Jane"
    image: john/myweb2:latest
    ports:
      - "8082:80"
  myweb4:
    image: john/myweb:latest
    ports:
      - "8083:80"
```
#### Docker-Compose Networks
* Docker-Compose 啟起 Container 時會使用路徑位置名稱啟一個 bridge network
    * 路徑位置：`~/Docker-Compose/Networks`
    * network name：`networks_default`
* 可以在 yaml 中設定自建 networks，並指定 Container 使用指定的 network：
```yaml=
version: "3.7"
services:
  myweb:
    build:
      context: .
      args:
        whoami: "Tony"
    image: john/myweb:latest
    ports:
      - "8080:80"
    networks:
      - mybridge001
  myweb2:
    build:
      context: .
      args:
        whoami: "Chris"
    image: john/myweb1:latest
    ports:
      - "8081:80"
    networks:
      - mybridge001
  myweb3:
    build:
      context: .
      args:
        whoami: "Jane"
    image: john/myweb2:latest
    ports:
      - "8082:80"
    networks:
      - mybridge001
  myweb4:
    image: john/myweb:latest
    ports:
      - "8083:80"
    networks:
      - mybridge002

networks:
  mybridge001:
  mybridge002:
```

```
其他網路模式的設定方式，可以參考下列官網：

https://docs.docker.com/compose/compose-file/#network_mode

這邊提供一個 host 模式的設定示範 (教材-docker-compose-host-mode.yml)
另外可以結合我們在網路章節學到的概念，搭配這個文件自己試試看其他模式
```
