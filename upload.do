#!/bin/bash
echo
DIR="static/`date +%Y%m%d`"
FILE="$DIR/`basename $QUERY_STRING`"
if [ ! -d $DIR ]; then
	mkdir -p $DIR
fi

if [ ! -d ".git" ]; then
	git init . > /dev/null 2>&1
	git add static > /dev/null 2>&1
fi

if [ ! -f "$FILE" ]; then
	NEW=1
fi

cat /dev/stdin > $FILE
base64 -D < $FILE > $FILE.bak
mv $FILE.bak $FILE

if [ "$NEW" == "1" ]; then
	git add "$FILE" > /dev/null 2>&1
	git commit -am "$FILE uploaded." > /dev/null 2>&1
else
	git commit -am "$FILE re-uploaded." > /dev/null 2>&1
fi

echo "$FILE"