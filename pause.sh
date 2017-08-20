#!/bin/bash
#
# pause.sh: ppause, presume
#   stops or starts entire process group of oldest proc named as given in arg1
#
# scott@smemsh.net
# http://smemsh.net/src/utilsh/
# http://spdx.org/licenses/GPL-2.0
#
##############################################################################

set -e

main ()
{

	case $(basename $0) in
	(*pause) signal="STOP";;
	(*resume) signal="CONT";;
	(*) echo "unimplemented"; false; exit;;
	esac

	pid=`pgrep -o ${1:?}`
	[[ $pid ]] || { echo failed; false; exit; }

	# we can't just use pgid= because ps seems to space-pad for
	# column width even though we just want the number, and we
	# cannot seem to combine :1 with pgid= in any way could find
	#
	pgid="$(ps --no-headers -o pgid:1 -p $pid)"

	# or we could do this after -o pgid=, but we prefer explicit
	# TODO: make bug, this is clearly a problem for script actions
	#
	#pgid=${pgid//\ /}

	# or we could do this, but it's just ugly
	#
	#kill -$signal -`printf $pgid`

	kill -$signal -$pgid
}

main "$@"
