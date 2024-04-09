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

	(($#)) && grepargs="[${1:0:1}]${1:1}" # TODO works? such old code!

	local uname=`uname -s`
	# TODO: use *TYPE variables provided by bash
	if [[ $uname == 'Linux' ]]; then
		if pids=`pgrep -f "$*" -d,`; then
			ps -wwH \
			-o pid,ppid,pgid,sid,pcpu,rss,vsz,tty,s,cmd \
			-p $pids
		fi
		return
	elif [[ $uname == 'SunOS' ]]; then psargs=ef
	elif [[ $uname == 'Darwin' ]]; then psargs=efwwwwww
	else echo "no code for you!"
	fi

	ps -$psargs | egrep "$grepargs"
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
