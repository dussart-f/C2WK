#!/bin/bash

mkdir -p "/var/log/named"

cat << 'EOF' >> "/etc/bind/named.conf.options"

logging {
    channel default_file {
        file "/var/log/named/default.log" versions 3 size 5m;
        severity info;
        print-time yes;
        print-category yes;
        print-severity yes;
    };

    channel query_file {
        file "/var/log/named/queries.log" versions 3 size 10m;
        severity info;
        print-time yes;
        print-category yes;
        print-severity yes;
    };

    category default { default_file; };
    category queries { query_file; };
};
EOF

named-checkconf

systemctl restart bind9

rndc reconfig