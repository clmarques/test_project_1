#!/bin/bash

# Cloudflare zone is the zone which holds the record
zone=`grep 'Zone-Name=' cloudflare_config | awk -F"=" '{print $2}'`
# dnsrecord is the A record which will be updated
dnsrecord=`grep 'Dns-Record=' cloudflare_config | awk -F"=" '{print $2}'`

## Cloudflare authentication details
## keep these private
cloudflare_auth_email=`grep 'Auth-Email=' cloudflare_config | awk -F"=" '{print $2}'`
cloudflare_auth_key=`grep 'Auth-Key=' cloudflare_config | awk -F"=" '{print $2}'`

# Get the current external IP address
EXTERNAL_IP=$(curl -s -X GET https://checkip.amazonaws.com)

# Read the ip address saved on previous interactions.
PREVIOUS_IP=$(cat myip.txt)

# Check if there are changes
if [ "$PREVIOUS_IP" != "$EXTERNAL_IP" ]; then

  printf "%s\n" "IP changed. Updating cloudflare...."
  # if here, the dns record needs updating
  echo $EXTERNAL_IP > myip.txt

  # get the zone id for the requested zone
  zoneid=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones?name=$zone&status=active" \
    -H "X-Auth-Email: $cloudflare_auth_email" \
    -H "X-Auth-Key: $cloudflare_auth_key" \
    -H "Content-Type: application/json" | jq -r '{"result"}[] | .[0] | .id')

  # get the dns record id
  dnsrecordid=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones/$zoneid/dns_records?type=A&name=$dnsrecord.$zone" \
    -H "X-Auth-Email: $cloudflare_auth_email" \
    -H "X-Auth-Key: $cloudflare_auth_key" \
    -H "Content-Type: application/json" | jq -r '{"result"}[] | .[0] | .id')

  # update the record
  curl -s -X PUT "https://api.cloudflare.com/client/v4/zones/$zoneid/dns_records/$dnsrecordid" \
    -H "X-Auth-Email: $cloudflare_auth_email" \
    -H "X-Auth-Key: $cloudflare_auth_key" \
    -H "Content-Type: application/json" \
    --data "{\"type\":\"A\",\"name\":\"$dnsrecord.$zone\",\"content\":\"$EXTERNAL_IP\",\"ttl\":1,\"proxied\":true}" | jq
fi
