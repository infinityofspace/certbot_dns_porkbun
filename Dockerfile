FROM alpine:3.14

RUN apk add --no-cache python3 py3-pip py3-cryptography

WORKDIR /certbot_dns_porkbun

ADD requirements.txt requirements.txt
RUN pip3 install -r requirements.txt

COPY . .

RUN pip install .

ENTRYPOINT ["certbot"]

LABEL org.opencontainers.image.source="https://github.com/infinityofspace/certbot_dns_porkbun"
LABEL org.opencontainers.image.licenses="MIT"
