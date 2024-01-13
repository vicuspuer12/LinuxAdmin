#!/bin/sh

# make sure the work directory exists
WORK="/root/ssl-`date +%F`"
mkdir -p ${WORK} 2>/dev/null

# these numbers change each time
CRT="fullchain.pem"
KEY="privkey.pem"
DESC="wildcard Name"

if [ -d ${WORK} ]; then 
 cd ${WORK}

 # fetch updated keys
 curl --silent --user ssl-(name):vE2\&J4w%qs24 -o ${CRT} https://www.(Cert live update domain name)/cert/(Domain name)/${CRT}
 curl --silent --user ssl-(name):vE2\&J4w%qs24 -o ${KEY} https://www.(Cert live update domain name)/cert/(Domain name)/${KEY}

 FIRSTLN=`grep -m1 -n "<cert>" /conf/config.xml | cut -d ":" -f 1`
 PHP=`which php`

 # use php base64_encode function to convert certificate and chain
 ENCRT=`$PHP -r '$cert = file_get_contents( $argv[1] , true);  echo base64_encode("$cert");' $CRT`
 ENKEY=`$PHP -r '$key = file_get_contents( $argv[1] , true);  echo base64_encode("$key");' $KEY`

 # generate a sed pattern substitution rule
 cat << EOF > replace.sed 
/.*$DESC.*/{
  N
  s@crt.*crt@crt>$ENCRT</crt@
  N
  s@prv.*prv@prv>$ENKEY</prv@
}
EOF

 sed -f replace.sed < /conf/config.xml > config.xml
 cp /conf/config.xml config.xml-`date +%F`

 if [ -s config.xml ]; then 
  cp -v config.xml /conf/config.xml
  /usr/local/etc/rc.restart_webgui
  echo "++ New certificate $DESCR installed."
 else
  echo "!! not coping a blank config.xml - something went wrong with sed"
 fi

else
  echo "!! work directory missing"
fi
