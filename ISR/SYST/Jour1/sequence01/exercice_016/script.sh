#!/bin/bash

if systemctl is-active --quiet apache2; then
    echo "APACHE ACTIF [OK]"
else
    systemctl restart apache2
fi

if systemctl is-active --quiet bind9; then
    echo "BIND9 ACTIF [OK]"
else
    systemctl restart bind9
fi