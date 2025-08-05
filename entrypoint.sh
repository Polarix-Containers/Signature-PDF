#! /bin/bash

envsubst < /usr/local/signaturepdf/config/php.ini > /usr/local/etc/php/conf.d/uploads.ini
envsubst < /usr/local/signaturepdf/config/config.ini.tpl > /usr/local/signaturepdf/config/config.ini

sed -i "/$DEFAULT_LANGUAGE/s/^# //g" /etc/locale.gen && locale-gen
export LANG=$DEFAULT_LANGUAGE
export LANGUAGE=$DEFAULT_LANGUAGE
export LC_ALL=$DEFAULT_LANGUAGE

if [[ -n $PDF_STORAGE_PATH ]] ; then
    mkdir -p "$PDF_STORAGE_PATH"
    chown 101:101 "$PDF_STORAGE_PATH"
fi