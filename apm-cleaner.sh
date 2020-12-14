#!/bin/bash
indiceTypeArray=("span" "transaction" "error" "metric" "onboarding")
activeDate=$(date '+%Y.%m.%d' -d "11 day ago")
echo $activeDate

for indiceType in "${indiceTypeArray[@]}"
do
   if curl -XDELETE qa.kibana.internal:9200/apm-7.5.0-$indiceType-$activeDate | grep "\""acknowledged"\"":true
		then
    		echo "Indice type" $indiceType "is deleted for" $activeDate
		else
    		echo "Indice type" $indiceType "can not be deleted for" $activeDate
	fi
done
