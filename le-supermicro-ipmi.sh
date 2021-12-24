#!/usr/bin/env bash
set -e

if ! [ -z ${DEBUG+x} ]; then
	set -x
fi

if [ -z ${IPMI_USERNAME+x} ]; then
        echo "IPMI_USERNAME not set!"
        exit 1
fi
if [ -z ${IPMI_PASSWORD+x} ]; then
        echo "IPMI_PASSWORD not set!"
        exit 1
fi
if [ -z ${IPMI_DOMAIN+x} ]; then
        echo "IPMI_DOMAIN not set!"
        exit 1
fi
if [ -z ${LE_EMAIL+x} ]; then
        echo "LE_EMAIL not set!"
        exit 1
fi

#Check if the certificate is expiring soon
set +e
echo | openssl s_client -servername $IPMI_DOMAIN -connect $IPMI_DOMAIN:443 2>/dev/null | openssl x509 -noout -checkend 2592000
if [ "$?" == "1" ]; then
set -e
#Expiring in less than one month. We need to renew

# Sign the request and obtain a certificate
if [[ -f ".lego/certificates/$IPMI_DOMAIN.crt" ]]; then
        lego --key-type rsa2048 --server ${LE_SERVER-https://acme-v02.api.letsencrypt.org/directory} --email $LE_EMAIL --dns ${DNS_PROVIDER-cloudflare} --accept-tos --domains $IPMI_DOMAIN renew
else
        lego --key-type rsa2048 --server ${LE_SERVER-https://acme-v02.api.letsencrypt.org/directory} --email $LE_EMAIL --dns ${DNS_PROVIDER-cloudflare} --accept-tos --domains $IPMI_DOMAIN run
fi

python3 supermicro-ipmi-updater.py --ipmi-url http://$IPMI_DOMAIN --cert-file .lego/certificates/$IPMI_DOMAIN.crt --key-file .lego/certificates/$IPMI_DOMAIN.key --username $IPMI_USERNAME --password $IPMI_PASSWORD --model X10

fi
