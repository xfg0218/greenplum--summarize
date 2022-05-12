#!/usr/bin/env bash

# set up configurations

# IMPALA FRAMART
source ./benchmark_impala.conf;

if [ -e "$LOG_FILE" ]; then
	timestamp=`date "+%F-%R" --reference=$LOG_FILE`
	backupFile="$LOG_FILE.$timestamp""_impala"
	mv $LOG_FILE $LOG_DIR/$backupFile
fi

echo ""
echo "***********************************************"
echo "*          PC-H benchmark on Impala-shell     *"
echo "***********************************************"
echo "                                               " 
echo "Running Impala-shell .... " | tee -a $LOG_FILE
echo "See $LOG_FILE for more details of query errors."
echo ""

trial=0
while [ $trial -lt $NUM_OF_TRIALS ]; do
	trial=`expr $trial + 1`
	echo "Executing Trial #$trial of $NUM_OF_TRIALS trial(s)..."

	for query in ${IMPALA_TPCH_QUERIES_ALL[@]}; do
		echo "Running Impala-shell query: $query" | tee -a $LOG_FILE
		$TIME_CMD $IMPALA_CMD -f $BASE_DIR/$query 2>&1 | tee -a $LOG_FILE | grep '^Time:'
                returncode=${PIPESTATUS[0]}
		if [ $returncode -ne 0 ]; then
			echo "ABOVE QUERY FAILED:$returncode"
		fi
	done

done # TRIAL
echo "***********************************************"
echo ""
