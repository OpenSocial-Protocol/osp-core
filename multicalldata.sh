#!/bin/bash
ENVIRONMENT=$1
if [[ "$ENVIRONMENT" == "" ]]
    then
        echo "No ENVIRONMENT specified."
        exit 1
fi
json_data=$(cat ./addresses-"${ENVIRONMENT}".json)
result=""
keys=$(echo "$json_data" | jq -r 'keys[] | select(endswith("Logic"))')
for key in $keys
do
      address=$(echo "$json_data" | jq -r ".$key")
      new_str=$(echo "$key" | awk '{print toupper(substr($0,1,1))substr($0,2)}')
      json=$(cat target/fun-sig/core/logics/interfaces/*"${new_str}".json)
      # shellcheck disable=SC2207
      keys=($(echo "$json" | jq -r 'keys_unsorted[]'))
      # shellcheck disable=SC2207
      values=($(echo "$json" | jq -r 'to_entries | .[] | .value'))
      for ((j=0; j<${#keys[@]}; j++)); do
        #echo "(${values[j]},$address,${keys[j]})"
        tt=$(cast calldata "addRouter((bytes4,address,string))"  "(${values[j]},$address,'${keys[j]}')")
        result="$result,$tt"
      done
done
substring=${result:1}
data=$(cast calldata  "multicall(bytes[])" ["$substring"])
echo "$data"



