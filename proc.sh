#!/usr/bin/env bash
#
# proc.sh: psa, psf, procs
#   select and display particular processes
#
# scott@smemsh.net
# http://smemsh.net/src/utilsh/
# http://spdx.org/licenses/GPL-2.0
#
##############################################################################

# by name, or give full process table without arg
#
psa ()
{
	local psargs grepargs
	local pids

	local uname=`uname -s`
	# TODO: use *TYPE variables provided by bash
	if [[ $uname == 'Linux' ]]; then
		if pids=`pgrep -f "$*" -d,`; then
			# remove our own process
			pids=$pids,; pids=${pids/$$,/}; pids=${pids%,}
			if [[ $pids ]]
			then ps -wwH \
				-o pid,ppid,pgid,sid,pcpu,rss,vsz,tty,s,cmd \
				-p $pids
			fi
		fi
		return
	elif [[ $uname == 'SunOS' ]]; then psargs=ef
	elif [[ $uname == 'Darwin' ]]; then psargs=efwwwwww
	else echo "no code for you!"
	fi

	# avoid our own process appearing: capture ps output first so the greps
	# aren't therein, and try to remove our own process from the list, by
	# escaping the expected ps line for ourself, which could have arbitrary
	# patterns given as $1, so we escape all the chars and require it has
	# our pid in a field of its own
	#
	# todo: tests well on linux, but need to try solaris and bsd, which is
	# the only place it will ever actually run.  tried to avoid gnuisms...
	#
	grepout="$(ps -$psargs)"
	sedcmds='s,[^^],[&],g; s,\^,\\^,g'
	escprog="$(sed "$sedcmds" <<< "$0")"
	escpat="$(sed "$sedcmds" <<< "$1")"
	grep -E "$1" <<< "$grepout" \
	| grep -vE "\\b$$\\b.*[[:space:]]$escprog[[:space:]]+$escpat\$"
}

# processes with a session leader matching specified name
#
psf ()
{
	ps -H --sid $(pgrep -d, $@) -F
}

# tabular list of unique process names except kernel threads
#
procs ()
{
	ps -N --ppid=2 -o comm= \
	| sort -u \
	| column -c 80
}

##############################################################################

invname=${0##*/}
if ! [[ `declare -F $invname` ]]; then
	echo "unimplemented"; false; exit; fi

$invname "$@"
