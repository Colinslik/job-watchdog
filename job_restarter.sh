#!/bin/bash

#Watch_list=(0 1 2 3 4 5 6 7 27)
#Watch_list=(1 2 6 \* 5 )
Watch_list=( \* )

log_path=/share/Public/rtrrdebug/
brief_log_path=/etc/config/qsync/logs/
detail_log_path=/etc/config/qsync/logs/detail/

log_time_diff=3600

mkdir -p $log_path


function job_watchdaog()
{
	Job_id=$1
	qsync_proc=`ps -ef | grep -c [J]ob${Job_id}`
	#echo "ps -ef | grep -c [J]ob${Job_id}"
	if [ $qsync_proc != 0  ] 
	then
		:	
	else
		brief_log_name=qsync-Job${Job_id}.log
		detail_log_name=qsync-Job${Job_id}.log
		NOW=$(date +%Y%m%d%H%M)
		new_brief_name=Brief_qsync-Job${Job_id}_$NOW.log
		new_detail_name=Detail_qsync-Job${Job_id}_$NOW.log
		cp -p -a $brief_log_path$brief_log_name $log_path$new_brief_name
		cp -p -a $detail_log_path$detail_log_name $log_path$new_detail_name
		qsync -J:Job${Job_id} &
                sleep 30
	fi
	sleep 5
}

function job_killer()
{
	Job_id=$1
	Proc_list=($(ps -ef | grep qsync  | grep [J]ob${Job_id} | awk '{print $1}'))
	for k in "${Proc_list[@]}"
	do
		echo "Kill proc $k"
		for((;;)); do
			if [ $(ps -ef | awk '{print $1}' | grep $k) ]
			then
				kill $k
			else
				break
			fi
			sleep 2
		done
	done
}

function job_restartor()
{
	Job_id=$1
	job_watchdaog $Job_id

	brief_log_name=qsync-Job${Job_id}.log
	detail_log_name=qsync-Job${Job_id}.log

        echo $detail_log_name

	log_time=`date -d "$(ls -l $detail_log_path$detail_log_name | awk '{print $6,$7,$8}')" +%s`
	echo "log time $log_time"
	current_time=`date -d "$(date +"%Y-%m-%d %H:%M:%S")" +%s`
	echo "current time $current_time"
	if [ $(expr $current_time - $log_time) -ge $log_time_diff ]
	then
		#echo $(expr $current_time - $log_time)
		job_killer $Job_id
		job_watchdaog $Job_id
	else
		#echo "small $(expr $current_time - $log_time)"
		:
	fi
	sleep 2
}


for i in "${Watch_list[@]}" 
do
	echo "NOW is $i"
	if [ "$i" == "*" ]
        then
		Proc_list=($(ps -ef | grep qsync  | grep [J]ob | awk '{print $7}' | sed 's/.*b//g'))
		for j in "${Proc_list[@]}"
		do
			Job_id=$j
			job_restartor $Job_id
		done
		break
	else
		Job_id=$i
		job_restartor $Job_id
	fi
done
