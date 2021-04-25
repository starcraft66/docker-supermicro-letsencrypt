FROM alpine:3

RUN apk add --no-cache ca-certificates bash lego openssl python3 py3-pip py3-requests py3-lxml

ADD le-supermicro-ipmi.sh supermicro-ipmi-updater.py /

VOLUME /.lego

ENTRYPOINT ["/le-supermicro-ipmi.sh"]
