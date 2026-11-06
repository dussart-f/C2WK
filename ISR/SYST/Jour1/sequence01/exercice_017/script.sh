#!/bin/bash


CRON_SCHEDULE="0 0 * * *"
CRON_COMMAND="systemctl restart apache2 && systemctl restart bind9"
LOG_FILE="/var/log/services_cron_restart.log"
CRON_LINE="$CRON_SCHEDULE $CRON_COMMAND >> $LOG_FILE 2>&1"

(crontab -l 2>/dev/null; echo "0 0 * * * systemctl restart apache2 && systemctl restart bind9") | crontab -