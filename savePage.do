#!/bin/bash
set -e
echo

if [ "$QUERY_STRING" == "" ]; then
	QUERY_STRING="home"
fi

PREDIR=`dirname $QUERY_STRING`
if [ "$PREDIR" == "." ]; then
	PREDIR=""
fi
DIR="pages/$PREDIR/"
if [ ! -d "$DIR" ]; then
	mkdir -p $DIR
fi

FILE="$DIR`basename $QUERY_STRING`"
if [ -d "$FILE" ]; then
        FILE="$FILE/home"
fi
if [ ! -f "$FILE" ]; then
	NEW=1
fi

CONTENT=`dd bs=$CONTENT_LENGTH count=1 2>/dev/null`
echo "$CONTENT" > "$FILE" 2>>.log

if [ ! -d ".git" ]; then
	git init . > /dev/null 2>>.log
	git add pages > /dev/null 2>>.log
fi

if [ "$NEW" == "1" ]; then
	git add "$FILE" > /dev/null 2>>.log
	git commit -am "$FILE initial creation." > /dev/null 2>>.log
else
	git commit -am "$FILE updated." > /dev/null 2>>.log
fi

echo "{\"success\": true}"