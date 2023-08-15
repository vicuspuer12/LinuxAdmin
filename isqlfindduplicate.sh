#!/bin/bash
for filename in org_*; do echo 'SELECT
  d1.depotid,d1.name,p1.name AS parent,
  d2.depotid,d2.name,p2.name AS parent
FROM DEPOT d1
INNER JOIN depot d2 ON (d1.depotid<d2.depotid AND upper(d1.name)=upper(d2.name) AND d1.LINKID=d2.linkid)
INNER JOIN depot p1 ON (p1.depotid=bin_and(d1.linkid,65535))
INNER JOIN depot p2 ON (p2.depotid=bin_and(d2.linkid,65535))
; ' | isql-fb  $filename -o depotnow/$filename.txt; done
