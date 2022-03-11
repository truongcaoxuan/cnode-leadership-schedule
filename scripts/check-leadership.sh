#!/bin/bash

#######################################################
# Get poolTicker list                                 #
#######################################################
echo "-------------------------------------------------"
poolTicker=$(cat /opt/cardano/cnode/files/pool-list.json | jq -r 'keys[]')
echo "Ticker list:"
echo "${poolTicker}"

#######################################################
# Get number poolTicker                               #
#######################################################
echo "-------------------------------------------------"
totalPool=$(echo -n "$(cat /opt/cardano/cnode/files/pool-list.json | jq -r 'keys[]')" | grep -c '^')
echo "Total Pool Ticker: ${totalPool}"

#######################################################
# Get current Date                                    #
#######################################################
echo "-------------------------------------------------"
currentDate=$(TZ="Asia/Ho_Chi_Minh" date +"%A, %d/%m/%Y %H:%M")
echo "Current Date and Time is: " 
echo "${currentDate}"
echo "${currentDate}" > /tmp/data-leadership.txt

#######################################################
# Chose the epoch parameters                          #
#######################################################
echo "-------------------------------------------------"
epoch="--current"
read -p "Enter Epoch 1=current, 2=next: " EPOCH
if [[ "$EPOCH" == "2" ]]; then
    epoch="--next"
    echo "Check leadership-schedule for ${epoch}"
else
    echo "Check leadership-schedule for ${epoch}"
fi

#######################################################
# Chose mainnet/testnet parameters                    #
#######################################################
echo "-------------------------------------------------"
net="--mainnet"
read -p "Enter network 1=mainnet, 2=testnet: " NET
if [[ "$NET" == "2" ]]; then
    net="--testnet-magic 42"
    echo "Check leadership-schedule for ${net}"
else
    echo "Check leadership-schedule for ${net}"
fi

#######################################################
# Processing check leadership-schedule                #
#######################################################
echo "-------------------------------------------------"
i=0
for poolName in ${poolTicker}
do
  let "i++"
  echo "[${i}/${totalPool}] Start check leadership-schedule for ${poolName} pool" 
  
  poolID=$(cat pool-list.json | jq -r .${poolName})
  echo "${poolID}"
  
  if [[ -z ${poolID} ]]; then
    echo "poolID not found for ${poolName} !!!"
    let "i--"
  else
    echo "${poolName} leadership-schedule processing" 
    echo "${poolName} leadership-schedule" >> /tmp/data-leadership.txt
    cardano-cli query leadership-schedule \
     ${net} \
     --genesis /opt/cardano/cnode/files/shelley-genesis.json \
     --stake-pool-id  "${poolID}" \
     --vrf-signing-key-file "/opt/cardano/cnode/priv/pool/${poolName}/vrf.skey" \
     ${epoch} >> /tmp/data-leadership.txt
    echo "._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._." 
    echo "Check leadership-schedule for ${poolName} finished "
    echo "**************************************************"
    
  fi
done

echo "-------------------------------------------------"
#######################################################
# Notify the result                                   #
#######################################################
echo " Result: [${i}/${totalPool}] DONE! "
