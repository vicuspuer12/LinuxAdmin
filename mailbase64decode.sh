#!/bin/bash

# this script takes a mail input, strips out the 3 lines from the header
# then includes the base64 decoded version of the 1st mime attachment

# create a unique directory to store this in
OUTPUT_DIR="/usr/local/username/$1/$(date +'%F')"
if [ ! -d ${OUTPUT_DIR} ]; then
  mkdir -p ${OUTPUT_DIR}
fi

OUTPUT="${OUTPUT_DIR}/output-$(date +'%H%M%S-%N').txt"
ARCHIVE="${OUTPUT_DIR}/input-$(date +'%H%M%S-%N').txt"
ERROR="${OUTPUT_DIR}/errors-$(date +'%H%M%S-%N').txt"

rm ${ARCHIVE} 2> /dev/null

function process_output() {
  pos=$1          # the numberting that we use for this output block when sorting at the end

  # Handle quoted-printable multi-line URLs by concatenating lines ending with '='
  src=$(cat | sed -e':a; /=$/{ s/.$//;N;s/\n//;s/=3D/=/g;ta; }')

  # Extract any REPORT or CSV URLs from <a href>
  urls=$(echo "$src" | grep -Eo '<a [^>]*href="[^"]*"' | grep -Ei '(report|csv)' | grep -Eo 'href="[^"]*"' | cut -d '"' -f 2 )

  if [[ -n "$urls" ]]; then
    for u in $urls; do
      # Fetch the content from the URL
      fetched=$(curl -o - -s "$u")
      if [ "$fetched" != "" ]; then
        attach=$(echo $attach; echo $fetched)
      fi
    done

    # check if we got something
    if [ "$attach" != "" ]; then
      src=$attach   # replace source with the attached files
    fi
#  else
#    # convert the output to text
#    src=$(echo $src | /mnt/data/tms/scripts/convert_to_text.py )
  fi

  # 
  # append our source
  echo "$src" | tr -cd '\10\11\12\40-\176' | awk -v pos=${pos} '{ printf("%d%03d %s\n",pos,++i,$0); }'
}


cat - | { \
  tee ${ARCHIVE} | egrep '(^From)|(^Subject)|(^To)|(^$)' | uniq | process_output 1 >&9; 
  cat ${ARCHIVE} | sed -E -n '/Content-Transfer-Encoding: (quoted-printable|8bit|7bit)/,${/^$/,${p;/^--/q;}}' | egrep -v '(^--)|(^Content)'| process_output 2 >&9; 
  cat ${ARCHIVE} | gawk '\
   /Content-Type:/{ if ((match($0,"text") != 0) || (match($0,"octet-stream") != 0)) show=1; }
   /Content-Transfer-Encoding:/{ if (match($0,"ase64") != 0) show++; }
   /^--/{ show=0; }
   { if (show>=2) print $0 ; }
  ' | egrep -v '(^--)|(Content)|(^$)|(^[[:space:]])|(^X-)|(^[A-Za-z\-]+: )' | base64 --decode --ignore-garbage  | process_output 3 >&9;
} 9>&1 | sort -n -k1 | cut -d ' ' -f 2- | tee -a ${OUTPUT} 2>> $ERROR

# remove the error output if it is blank
if [ ! -s ${ERROR} ]; then
  rm ${ERROR} 2> /dev/null
fi
