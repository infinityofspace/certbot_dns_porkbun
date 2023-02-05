FROM alpine:3.17

RUN apk add --no-cache python3 py3-pip py3-cryptography

WORKDIR /certbot_dns_porkbun

COPY requirements-docker.txt requirements.txt
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

RUN pip install --no-cache-dir .

ENTRYPOINT ["certbot"]

LABEL org.opencontainers.image.source="https://github.com/infinityofspace/certbot_dns_porkbun"
LABEL org.opencontainers.image.licenses="MIT"
