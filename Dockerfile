FROM python:3.13-alpine3.21 AS build-image

RUN apk add --no-cache gcc musl-dev libffi-dev openssl-dev cargo

WORKDIR /certbot_dns_porkbun

RUN python -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

COPY requirements.txt .
RUN pip install -r requirements.txt

COPY . .
RUN pip install .

FROM python:3.13-alpine3.21

COPY --from=build-image /opt/venv /opt/venv

ENV PATH="/opt/venv/bin:$PATH"

ENTRYPOINT ["certbot"]

LABEL org.opencontainers.image.source="https://github.com/infinityofspace/certbot_dns_porkbun"
LABEL org.opencontainers.image.licenses="MIT"
