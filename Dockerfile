FROM python:3.10-alpine AS build-image

RUN apk add --no-cache gcc musl-dev libffi-dev openssl-dev cargo \
    && if [ $(uname -m) == "arm" ]; then \
         apk add -no-cache py3-asn1; \
       fi

WORKDIR /certbot_dns_porkbun

RUN python -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

ADD requirements.txt requirements.txt
RUN pip3 install -r requirements.txt

COPY . .

RUN pip install .


FROM python:3.10-alpine
COPY --from=build-image /opt/venv /opt/venv

ENV PATH="/opt/venv/bin:$PATH"

ENTRYPOINT ["certbot"]

LABEL org.opencontainers.image.source="https://github.com/infinityofspace/certbot_dns_porkbun"
LABEL org.opencontainers.image.licenses="MIT"
