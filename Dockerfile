FROM alpine:3.6

COPY ./patches .

RUN apk update && apk add --no-cache --virtual .build-deps git curl g++ make openssl-dev zlib musl-dev linux-headers

RUN git clone https://github.com/TelegramMessenger/MTProxy && cd MTProxy && patch -p0 -i /randr_compat.patch

WORKDIR MTProxy

RUN make

WORKDIR objs/bin

RUN curl -s https://core.telegram.org/getProxySecret -o proxy-secret && \
	curl -s https://core.telegram.org/getProxyConfig -o proxy-multi.conf

EXPOSE 443 8888

CMD ["./mtproto-proxy", "-u", "nobody", "-p", "8888", "-H", "443", "-S", `head -c 16 /dev/urandom | xxd -ps`, "--aes-pwd", "proxy-secret", "proxy-multi.conf", "-M", "1"]