#!/bin/bash

if [ "$#" -ne 1 ]; then
  echo "Usage: $0 <filename>"
  exit 1
fi

FILE=$1
TEMP_FILE=$(mktemp)

while IFS= read -r line
do
  if [[ $line == *"excludeFolder"* && $line == *"oxid-esales"* ]]; then
    continue
  fi

  echo "$line" >> $TEMP_FILE
done < "$FILE"
mv $TEMP_FILE $FILE
