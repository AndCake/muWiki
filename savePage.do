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
DIR="pages/$PREDIR"
if [ ! -d "$DIR" ]; then
	mkdir -p $DIR
fi

CONTENT=`cat /dev/stdin`
FILE="$DIR/`basename $QUERY_STRING`"
if [ ! -f "$FILE" ]; then
	NEW=1
fi

echo "$CONTENT" > "$FILE"

if [ ! -d ".git" ]; then
	git init . > /dev/null 2>&1
	git add pages > /dev/null 2>&1
fi

if [ "$NEW" == "1" ]; then
	git add "$FILE" > /dev/null 2>&1
	git commit -am "$FILE initial creation." > /dev/null 2>&1
else
	git commit -am "$FILE updated." > /dev/null 2>&1
fi

echo "{\"success\": true}"