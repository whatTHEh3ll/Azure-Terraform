#!/bin/bash

source .env

echo "$(bw get password ${BW_VAULT_ENTRY_ID} --session ${BW_SESSION} --raw)"

unset BW_SESSION

unset BW_VAULT_ENTRY_ID
