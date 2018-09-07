FROM alpine:3.4

COPY ./patches .

ENV SECRET ""

ENV WORKERS 1

RUN apk update && apk add .build-deps git curl g++ make openssl-dev zlib musl-dev

RUN patch -p0 -i randr_compat.patch

RUN git clone https://github.com/TelegramMessenger/MTProxy

WORKDIR MTProxy

RUN make

WORKDIR objs/bin

RUN curl -s https://core.telegram.org/getProxySecret -o proxy-secret && \
	curl -s https://core.telegram.org/getProxyConfig -o proxy-multi.conf

EXPOSE 443

CMD ["mtproto-proxy", "-u", "nobody", "-p", "8888", "-H", "443", "-S", "$SECRET", "--aes-pwd", "proxy-secret", "proxy-multi.conf", "-M", "$WORKERS"]