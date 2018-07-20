#!/bin/bash
#by Zbigniew Karolczuk, 24 March 2017

log_orig="Server.log"
log_copy="Server.temp"

threshold=1000 #Set time writing threshold in milliseconds when script returns message from the log
sleepMIN=5 #Set sleep time in minutes

sleepSEC=$((sleepMIN * 60))
while [[ 0==1 ]]; do #Endless loop as declared a false statement

  cat $log_orig | sort -r > $log_copy #Copying log file with reverse order on each iteration of the loop

  time_ago=`date -d "-1 hour" +%s`
  time_now=`date -d "now" +%X`

  echo ""
  echo "##### Reading file: ${log_orig} at ${time_now} #####"
  echo ""

  (while read -r line
  do
    
      time_write=`echo ${line} | awk '{print $16}'`
      time_concat=`echo ${line} | cut -d "," -f 1`
      time_line=`date -d "${time_concat}" +%s`

      if [[ ${time_line} -ge ${time_ago} ]] && [[ ${time_write} -ge ${threshold} ]]; then
          echo $line
    
      elif [[ ${time_line} -ge ${time_ago} ]] && [[ ${time_write} -lt ${threshold} ]]; then
          (exit) #Exit in brackets to avoid killing the script

      else
        exit
      fi

  done < "$log_copy")

  echo "" 
  echo "Sleep for ${sleepMIN} minute(s)"
  echo ""

  sleep $sleepSEC #Sleep for some period of time and start the loop again

done
