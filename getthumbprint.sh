#!/bin/bash
PRINT=$(echo | openssl s_client -connect $1 2>&- | openssl x509 -fingerprint -noout | sed 's/://g' | awk -F= '{print tolower($2)}')
echo "{\"data\":\"$PRINT\"}"