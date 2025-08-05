ARG VERSION=1.9.0

FROM php:8.2-fpm-alpine

ARG VERSION

ENV SERVERNAME=localhost
ENV UPLOAD_MAX_FILESIZE=24M
ENV POST_MAX_SIZE=24M
ENV MAX_FILE_UPLOADS=201
ENV PDF_STORAGE_PATH=/data
ENV DISABLE_ORGANIZATION=false
ENV DEFAULT_LANGUAGE=fr_FR.UTF-8
ENV PDF_STORAGE_ENCRYPTION=false

RUN apk -U upgrade \
    && apk add musl-locales gettext librsvg imagemagick potrace ghostscript gpg openjdk8 \
    && docker-php-ext-install gettext \
    && rm -rf /var/cache/apk/*

RUN cd /tmp \
    && wget https://gitlab.com/pdftk-java/pdftk/-/jobs/924565145/artifacts/raw/build/libs/pdftk-all.jar \
    && mv pdftk-all.jar pdftk.jar

ADD https://github.com/24eme/signaturepdf.git#v${VERSION} /usr/local/signaturepdf
COPY entrypoint.sh /usr/local/signaturepdf
COPY --chmod=755 pdftk /usr/bin

RUN envsubst < /usr/local/signaturepdf/config/php.ini > /usr/local/etc/php/conf.d/uploads.ini && \
    envsubst < /usr/local/signaturepdf/config/config.ini.tpl > /usr/local/signaturepdf/config/config.ini

WORKDIR /usr/local/signaturepdf

COPY --from=ghcr.io/polarix-containers/hardened_malloc:latest /install /usr/local/lib/
ENV LD_PRELOAD="/usr/local/lib/libhardened_malloc.so"

CMD /usr/local/signaturepdf/entrypoint.sh