#!/usr/bin/env bash

which jq &>/dev/null
if [[ $? -ne 0 ]]; then
    printf "jq required\n"
    exit 1
fi

backup=$(find ~/.mozilla -name storage-sync.sqlite)
if [[ -z "$backup" ]]; then
    print "Failed to find storage-sync database in ~/.mozilla\n"
    exit 1
fi

tempfile="/tmp/tempstorage-sync.sqlite"
cp $backup $tempfile
rules=$(sqlite3 $tempfile "select record from collection_data where collection_name like '%uMatrix@raymondhill.net'" | jq -r .data 2>/dev/null | jq -r .data 2>/dev/null)

if [[ -z "$rules" ]]; then
    printf "Failed to get rules from db\n"
    exit 1
fi

printf "$rules\n"
shred -uzn 10 $tempfile

