FROM node AS builder
ARG benv
ENV benv ${benv}
WORKDIR /app
COPY ./ /app
RUN npm config set registry https://registry.npm.taobao.org 
RUN npm install
RUN npm run build:${benv}
FROM nginx:latest
MAINTAINER zhangbin
COPY --from=builder /app/dist/ /usr/share/nginx/html/
COPY --from=builder /app/nginx.conf /etc/nginx/
RUN /bin/cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
RUN echo "Asia/Shanghai" > /etc/timezone