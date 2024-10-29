#!/usr/bin/env bash
#
# proc.sh: psa, psf, procs
#   select and display particular processes
#
# scott@smemsh.net
# https://github.com/smemsh/utilsh/
# https://spdx.org/licenses/GPL-2.0
#
##############################################################################

if [[ $1 == -p ]]
then
	psflags="-o pid="
	cmdflags="$psflags"
	shift
else
	psfields=(
		pid ppid pgid sid
		pcpu
		rss vsz tty
		s
		cmd
	)
	IFS=,
	psflags="-wwH --no-headers -o ${psfields[*]}"
	unset IFS
	cmdflags="-o comm="
fi

gawk_psfmt="pid=,pgid=,ppid="
gawk_filter='
{
	pid = $1; pgid = $2; ppid = $3
	if (exclpg && pgid == exclpg) next
	if (ppid == 2 && exclk) next
	results[pid]++
}'
gawk_end_print='
END {
	if (recursive) recurse(args)
	$0 = ""; n = 1; OFS=","
	for (pid in results) $(n++) = pid
	print
}'
gawk_filter_print="
$gawk_filter
$gawk_end_print
"

# by pattern match in command line, or give full process table without arg
#
psa ()
{
	local psargs
	local pids

	local uname=`uname -s`
	# TODO: use *TYPE variables provided by bash
	if [[ $uname == 'Linux' ]]
	then
		(($# == 0)) && set -- ^
		(($# > 1)) && bomb "only one pattern for pgrep"
		matches=$(pgrep -d, -f "$1")
		[[ $matches ]] || exit
		pids=$(ps -p $matches -o $gawk_psfmt \
		| gawk -v exclpg=$$ -v exclk=1 "$gawk_filter_print")
		[[ $pids ]] && ps $psflags -p $pids || false

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
	psout="$(ps -$psargs)"
	sedcmds='s,[^^],[&],g; s,\^,\\^,g'
	escprog="$(sed "$sedcmds" <<< "$0")"
	escpat="$(sed "$sedcmds" <<< "$1")"
	grep -E "$1" <<< "$psout" \
	| grep -vE "\\b$$\\b.*[[:space:]]$escprog[[:space:]]+$escpat\$"
}

# processes with a session leader matching specified name
#
psl ()
{
	local pids=$(ps -eo pid=,sid=,comm= \
	| gawk -v leadername="${1:?}" '
	{
		pid = $1; sid = $2; cmd = $3
		pids[i] = pid; sids[i] = sid
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

	[[ $pids ]] && ps $psflags -p $pids
}

# children of given parent(s), recursively
# -p display pids only, which will not include parent
#
psf ()
{
	local pids=$(ps -eo pid=,ppid= \
	| gawk -v ourpid=$$ -v recursive=1 -v pidlist="$*" '
	BEGIN {
		split(pidlist, arglist, "([[:space:]]+|,)")
		for (arg in arglist) args[arglist[arg]]++
	}
	function \
	recurse(pids)
	{
		for (pid in pids) {
			if (pid == ourpid) continue
			results[pid]++
			if (length(children[pid])) recurse(children[pid])
		}
	}
	{
		pid = $1; ppid = $2
		children[ppid][pid]++
	}'"$gawk_end_print")

	[[ $pids ]] && ps $psflags -p $pids
}

pspg ()
{
	local pidlist=$(IFS=,; pgrep --pgroup "${*:?}")
	[[ $pidlist ]] && ps $psflags -p $pidlist
}

# we commonly want to remove processes with our own pgid from the list,
# but otherwise use just one selector option that takes a list
#
ps_noself_select ()
{
	local optname=${1:?}; shift
	local pids=$(ps --$optname "$*" -o $gawk_psfmt \
	| gawk -v exclpg=${exclpg:-$$} -v exclk=$exclk "$gawk_filter_print")
	[[ $pids ]] && ps $psflags -p $pids
}
pst  () { ps_noself_select tty "$@"; }
pss  () { ps_noself_select sid "$@"; }
pspp () { ps_noself_select ppid "$@"; }
psp  () { exclpg=0 \
	  ps_noself_select pid "$@"; }

# tabular lists of unique process names matching eponymous criteria

mktable   () { sort | uniq | column -c 80; }

procs     () { ps -N --ppid=2 ${cmdflags} | mktable; }    # non-kernel procs
daemons   () { ps --ppid=1 ${cmdflags}    | mktable; }    # descendants of init
kthreads  () { ps --ppid=2 ${cmdflags}    | mktable; }    # kernel threads

sessions  () { ps -Nd ${cmdflags}         | mktable; }    # session leaders
leaders   () { leaders "$@"; }                            # sessions alias

headless  () { psflags="$cmdflags" exclk=1 \
               ps_noself_select tty -     | mktable; }    # no ctty, non-kernel

##############################################################################

invname=${0##*/}
if ! [[ `declare -F $invname` ]]
then echo "unimplemented" >&2; false; exit; fi

$invname "$@"
