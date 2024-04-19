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
	if [[ $uname == 'Linux' ]]
	then
		if pids=`pgrep -f "$*" -d,`; then
			# remove our own process
			pids=$pids,; pids=${pids/$$,/}; pids=${pids%,}
			if [[ $pids ]]
			then ps -wwH \
				-o pid,ppid,pgid,sid,pcpu,rss,vsz,tty,s,cmd \
				-p $pids
			else false
			fi
		fi

		return # end Linux

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
	local pids=$(ps -eo pid=,sid=,comm= \
	| gawk -v leadername=${1:?} '
	{
		pid = $1
		sid = $2
		cmd = $3

		pids[i] = pid
		sids[i] = sid
		cmds[i] = cmd

		if (pid == sid) leaders[i] = 1
		if (sid != 0 && leaders[i] && cmd == leadername)
			target_sessions[sid] = 1
		i++
	}
	END {
		pidlen = length(pids)
		for (i = 0; i < pidlen; i++) {
			sid = sids[i]
			if (target_sessions[sid] && !leaders[i])
				matches[j++] = pids[i]
		}
		sidlist = matches[0]
		matchlen = length(matches)
		for (i = 1; i < matchlen; i++)
			sidlist = sidlist "," matches[i]
		printf("%s", sidlist)
	}')

	[[ $pids ]] && ps -jHF -p $pids
}

# tabular lists of unique process names matching eponymous criteria
#
mktable   () { sort | uniq | column -c 80;           }
procs     () { ps -N --ppid=2 -o comm=    | mktable; }    # non-kernel procs
daemons   () { ps --ppid=1 -o comm=       | mktable; }    # descendants of init
sessions  () { ps -Nd -o comm=            | mktable; }    # session leaders

##############################################################################

invname=${0##*/}
if ! [[ `declare -F $invname` ]]; then
	echo "unimplemented"; false; exit; fi

$invname "$@"
