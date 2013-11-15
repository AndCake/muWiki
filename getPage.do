#!/bin/bash
BASEPATH="pages"
echo

if [ "$QUERY_STRING" == "" ]; then
	QUERY_STRING="home"
elif [ -d "$BASEPATH/$QUERY_STRING" ]; then
	QUERY_STRING="$QUERY_STRING/home"
fi

if [ ! -f "$BASEPATH/$QUERY_STRING" ]; then
	echo "New WIKI page"
	echo "============="
	echo
	echo "<button onclick='editPage()'>Create this page.</button>"
else
	cat $BASEPATH/$QUERY_STRING
fi