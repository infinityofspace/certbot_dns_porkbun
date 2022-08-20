FROM python:3.10-alpine3.16

RUN apk add --no-cache py3-cryptography
ENV PYTHONPATH=/usr/lib/python3.10/site-packages

WORKDIR /certbot_dns_porkbun

COPY requirements-docker.txt requirements.txt
RUN pip3 install --no-cache-dir -r requirements.txt

COPY . .

RUN pip3 install --no-cache-dir .

ENTRYPOINT ["certbot"]

LABEL org.opencontainers.image.source="https://github.com/infinityofspace/certbot_dns_porkbun"
LABEL org.opencontainers.image.licenses="MIT"
