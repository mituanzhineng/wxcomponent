#FROM node:18.17.0 as nodeBuilder
## 指定构建过程中的工作目录
#WORKDIR /wxcloudrun-wxcomponent
#
## 将当前目录（dockerfile所在目录）下所有文件都拷贝到工作目录下
#COPY . /wxcloudrun-wxcomponent/
#
#RUN cd /wxcloudrun-wxcomponent/client && npm install --registry=https://registry.npmjs.org/ && npm run build

FROM golang:1.17.1-alpine3.14 as builder

# 指定构建过程中的工作目录
WORKDIR /wxcloudrun-wxcomponent

# 将当前目录（dockerfile所在目录）下所有文件都拷贝到工作目录下
COPY . /wxcloudrun-wxcomponent/

# 执行代码编译命令。操作系统参数为linux，编译后的二进制产物命名为main，并存放在当前目录下。
RUN GOPROXY="https://goproxy.cn" GO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -o main .

# 选用运行时所用基础镜像（GO语言选择原则：尽量体积小、包含基础linux内容的基础镜像）
FROM alpine:3.13

# 指定运行时的工作目录
WORKDIR /wxcloudrun-wxcomponent

# 将构建产物/wxcloudrun-wxcomponent/main拷贝到运行时的工作目录中
COPY --from=builder /wxcloudrun-wxcomponent/main /wxcloudrun-wxcomponent/
COPY --from=builder /wxcloudrun-wxcomponent/comm/config/server.conf /wxcloudrun-wxcomponent/comm/config/
COPY --from=builder /wxcloudrun-wxcomponent/etc/config.json /wxcloudrun-wxcomponent/etc/
COPY --from=nodeBuilder /wxcloudrun-wxcomponent/client/dist /wxcloudrun-wxcomponent/client/dist

# 设置时区
RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.ustc.edu.cn/g' /etc/apk/repositories && \
    apk update && \
    apk add --no-cache tzdata && \
    ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && \
    echo "Asia/Shanghai" > /etc/timezone && \
    apk del tzdata && \
    rm -rf /var/cache/apk/*

# 基于环境变量写入配置文件
RUN echo "MYSQL_USERNAME=\"$MYSQL_USERNAME\"" >> .env &&\
    echo "MYSQL_ADDRESS=\"$MYSQL_ADDRESS\"" >> .env && \
    echo "MYSQL_PASSWORD=\"$MYSQL_PASSWORD\"" >> .env && \
    echo "WX_APPID=\"WX_APPID\"" >> .env

# 兼容云托管开放接口服务
RUN apk add ca-certificates

# 设置release模式
ENV GIN_MODE release

# 执行启动命令
CMD ["/wxcloudrun-wxcomponent/main"]
