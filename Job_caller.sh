#!/bin/bash

Watch_list=(28 29 30)

log_path=/share/Public/log/

brief_log_path=/etc/config/qsync/logs/

detail_log_path=/etc/config/qsync/logs/detail/

mkdir -p $log_path
for((;;)); do
  for i in "${Watch_list[@]}"
    do
 
      Job_id=$i
      qsync_proc=`ps -ef | grep -c [J]ob${Job_id}`
 
      if [ $qsync_proc != 0  ]; then
         echo "found $Job_id" 1>/dev/null 2>/dev/null
      else
          echo "Backup qsync log."

          brief_log_name=qsync-Job${Job_id}.log
          detail_log_name=qsync-Job${Job_id}.log
          NOW=$(date +%Y%m%d%H%M)
          new_brief_name=Brief_qsync-Job${Job_id}_$NOW.log
          new_detail_name=Detail_qsync-Job${Job_id}_$NOW.log

          cp -p -a $brief_log_path$brief_log_name $log_path$new_brief_name
          cp -p -a $detail_log_path$detail_log_name $log_path$new_detail_name
          qsync -J:Job${Job_id} &
   
          echo "Qsync Job${Job_id} NOT Found!"
       fi
    done
  sleep 5

done
