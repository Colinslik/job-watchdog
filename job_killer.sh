#!/bin/bash

#Watch_list=(0 1 2 3 4 5 6 7 27)
#Watch_list=(1 2 6 \* 5 )
Watch_list=( 6 7 11 )

#log_path=/share/Public/rtrrdebug/
#brief_log_path=/etc/config/qsync/logs/
#brief_log_name=qsync-Job${Job_id}.log
#detail_log_path=/etc/config/qsync/logs/detail/
#detail_log_name=qsync-Job${Job_id}.log

#mkdir -p $log_path

for i in "${Watch_list[@]}" 
do
	echo "NOW is $i"
	if [ "$i" == "*" ]
        then
		Kill_list=($(ps -ef | grep qsync  | grep [J]ob | awk '{print $1}'))
		for j in "${Kill_list[@]}"
		do
			echo "Kill proc $j"
                        for((;;)); do
                        	if [ $(ps -ef | awk '{print $1}' | grep $j) ]
				then
                        		kill $j
				else
					break
				fi
				sleep 2
			done
		done
		break
	else
		Job_id=$i
                Proc_list=($(ps -ef | grep qsync  | grep [J]ob${Job_id} | awk '{print $1}'))
                for j in "${Proc_list[@]}"
                do
                        echo "Kill proc $j"
                        for((;;)); do
                                if [ $(ps -ef | awk '{print $1}' | grep $j) ]
                                then
                                        kill $j
                                else
                                        break
                                fi
                                sleep 2
                        done
                done

		#echo "ps -ef | grep qsync | grep [J]ob${Job_id} | awk '{print $1}'"
		#qsync_proc=$(ps -ef | grep qsync | grep [J]ob${Job_id} | awk '{print $1}')
		#echo "PROC is  $qsync_proc"
                #for((;;)); do
                #        if [ $(ps -ef | awk '{print $1}' | grep $qsync_proc) ]
                #        then
                #                kill $qsync_proc
		#		:
                #        else
                #                break
                #        fi
                #        sleep 2
                #done
	fi
done
