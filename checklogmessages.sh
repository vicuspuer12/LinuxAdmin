#!/bin/bash

# this scans the messages log looking for a specific messages
grep --color 'specific message' /var/log/messages | cut -d: -f6- | sed -e "s/'.*$//" | sed -e"s/{string to sed}.*)//" | sort | uniq -c | gawk '
BEGIN {
  prev_orgID = 0;
  success = 0;
  failed = 0;
  printf("Message to print out");
}
/orgID=/{ 
 # determine our organisation number
 split($2,a,"="); 

 # check if it has changed
 if (a[2] != prev_orgID) {

    if (prev_orgID != 0) printf("TOTAL: success = %d, failed = %d\n\n",success,failed);
    success = 0;
    failed = 0;
    prev_orgID = a[2];

    # display next organisation
    cmd=sprintf("grep %d /usr/local/templates/url_list.txt | head -1 | cut -d, -f3",a[2]);
    system(cmd);
 }

 # display entry
 printf("  %3d :",$1);
 for (i=3;i<=NF;i++) printf(" %s",$i);
 printf("\n");
}
/flag = 1/{ success += $1; }
/flag=1/{ success += $1; }
/flag = 0/{ failed += $1; }
/flag=0/{failed += $1; }

END {
 if (prev_orgID != 0) printf("TOTAL: success = %d, failed = %d\n\n",success,failed);
 printf(".\n");
}'
