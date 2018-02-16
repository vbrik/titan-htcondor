#!/bin/bash
# create pool_kill file on certain conditions

pool=$1
#out_of_jobs_shutdown_delay=720
source /tmp/env

while true; do
	sleep 10
	idle_jobs=$(condor_status -sched -af TotalIdleJobs)
	#dyn_slots=$(condor_status -con DynamicSlot | wc -l)
	#part_slots=$(condor_status -con PartitionableSlot|wc -l)
	if ((idle_jobs == 0)); then
		echo idle_jobs=$idle_jobs running_jobs=$running_jobs
		while true; do
			sleep 10
			running_jobs=$(condor_status -sched -af TotalRunningJobs)
			if ((running_jobs == 0)); then
				touch $pool/pool_kill
				exit
			fi
		done
#		if ((running_jobs > 0)); then
#			sleep $out_of_jobs_shutdown_delay
#		fi
#		touch $pool/pool_kill
#		exit
	fi
done
