#!/usr/bin/env bash
#
# urlcode
#   command line encode/decode of urls to clean http refs
#
# args:
#   - invoke as urlencode or urldecode
#   - send as lines on stdin, or pass as command line args, or both
#
# deps:
#   - uses php's rawurlencode() and rawurldecode(), respectively
#
# todo:
#   - url arg (ie after `+') maybe urlencode() not raw variant
#   - just write this in php itself using its `-R'
#   - we tack on a newline at end; perhaps only if stdout isatty?
#
# scott@smemsh.net
# https://github.com/smemsh/utilsh/
# https://spdx.org/licenses/GPL-2.0
#
##############################################################################

name=$(basename $0); usage="
 $name: write ${name}d lines to stdout
   - invoke as either \`urlencode', or \`urldecode'
   - send either stdin, or pass in arguments, or both
   - each line is then raw${name}d to stdout
"
usage_exit  () { cat <<< "$usage"; exit; }
xxcode      () { php -r "printf(\"%s\\n\", raw$name(\"$1\"));"; }
main        ()
{
	readarray -t stdin
	set -- "$@" "${stdin[@]}"
	for each; do xxcode "$each"; done
}

main "$@"
