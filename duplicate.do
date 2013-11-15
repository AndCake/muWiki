#!/bin/bash
# duplicate a document tree (folder)
set -e
echo

# Decodes an URL-string
# an URL encoding has "+" instead of spaces
# and no special characters but "%HEX"
function urlDec() {
  local value=${*//+/%20}                   # replace +-spaces by %20 (hex)
  for part in ${value//%/ \\x}; do          # split at % prepend \x for printf
    printf "%b%s" "${part:0:4}" "${part:4}" # output decoded char
  done
}

# For all given query strings
# parse them an set shell variables
function setQueryVars() {
  local vars=${*//\*/%2A}                      # escape * as %2A
  for var in ${vars//&/ }; do                  # split at &
    local value=$(urlDec "${var#*=}")          # decode value after =
    value=${value//\\/\\\\}                    # change \ to \\ for later
    eval "CGI_${var%=*}=\"${value//\"/\\\"}\"" # evaluate assignment
  done
}

setQueryVars $QUERY_STRING

BASEPATH="pages"
if [ "$CGI_from" == "" ] || [ "$CGI_to" == "" ]; then
	echo "Nothing copied."
	exit 1
fi

cp -R "$BASEPATH/$CGI_from" "$BASEPATH/$CGI_to"

echo "Complete."