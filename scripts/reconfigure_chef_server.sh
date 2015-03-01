#/bin/bash -x

LOG_FILE="/var/log/chef_reconfigure.log"
URL="http://127.0.0.1:8000/_status"
CODE=1
SECONDS=0
TIMEOUT=60

touch $LOG_FILE
chef-server-ctl reconfigure | tee $LOG_FILE
return=`curl -sf ${URL}`

echo "${URL} returns: ${return}" >> $LOG_FILE
if [[ -z "$return" ]]; then
    echo "Error while running chef-server-ctl reconfigure" >> $LOG_FILE
    echo "Blocking until <${URL}> responds..." >> $LOG_FILE
    while [ $CODE -ne 0 ]; do
	curl -sf \
	    --connect-timeout 3 \
	    --max-time 5 \
	    --fail \
	    --silent \
	    ${URL}
	CODE=$?
	sleep 2
	echo -n "." >> $LOG_FILE
	if [ $SECONDS -ge $TIMEOUT ]; then
	    echo "$URL is not available after $SECONDS seconds...stopping the script!" >> $LOG_FILE
	    exit 1
	fi
    done;
    echo -e "\n$URL is available!\n" >> $LOG_FILE
    chef-server-ctl reconfigure | tee $LOG_FILE
fi