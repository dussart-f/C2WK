#!/bin/bash

LOG_DIR="/var/log/apache2"

ACCESS_LOG="$LOG_DIR/access.log"
ERROR_LOG="$LOG_DIR/error.log"


tail -f "$ACCESS_LOG" "$ERROR_LOG"