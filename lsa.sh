#!/bin/bash
#
# lsa.sh: lsa, lsf, lsd, lw, lsc, lstc, lsu, lsh, lsr, llatest, loldest
#   /bin/ls wrapper suite
#
# desc:
#   - this came from our shell init
#   - normally these would be simple functions
#   - needed because functions do not work with sudo
#
# scott@smemsh.net
# https://github.com/smemsh/utilsh/
# https://spdx.org/licenses/GPL-2.0
#
##############################################################################

invocation_name=${0##*/}

# todo: move this to shell init
# instead we have ugly exec and parse of version output here
#
[[ $_BASHRC_HAS_LS_DIRSFIRST ]] || {
	[[ $(ls --version) =~ ([[:digit:]]+) ]] &&
		((${BASH_REMATCH[1]} >= 6))  &&
			export _BASHRC_HAS_LS_DIRSFIRST=1
}

__ls ()
{
	local r p

	ls \
		-hAF \
		--color=always \
		--time-style=+$HISTTIMEFORMAT \
		${_BASHRC_HAS_LS_DIRSFIRST:+'--group-directories-first'} \
		"$@" |&
	sed '/^total/d'

	r=$? p=${PIPESTATUS[0]}
	((r)) && return $r || return $p
}

# not used yet
#_BASHRC_LONG_LIST_FLAGS="-l"
#_BASHRC_LONG_LIST_FLAGS="-n"
#_BASHRC_LONG_LIST_FLAGS="" # need a '-l' variant
#
lsa ()
{
	local r p

	__ls -n "$@" |
	less -ERX -+S

	r=$? p=${PIPESTATUS[0]}
	((r)) && return $r || return $p
}

# lsa just files
#
# lsf/lsd relies on -F being present in __ls() but there's no
# obvious way to do it otherwise, since 'ls' itself doesn't
# implement this, we'd have to reimplement 'ls'
#
lsf ()
{
	local r p

	__ls -n "$@" |
	grep '[^/]$' |
	less -ERX -+S

	r=$? p=${PIPESTATUS[0]}
	((r)) && return $r || return $p
}

# lsa just dirs
#
lsd ()
{
	local r p

	__ls -n "$@" |
	awk '/\/$/ {print; next}; {exit}' |
	less -ERX -+S

	r=$? p=${PIPESTATUS[0]}
	((r)) && return $r || return $p
}

# lsa but wide
#
lw ()
{
	local r p

	__ls "$@" |
	less -ERX -+S

	r=$? p=${PIPESTATUS[0]}
	((r)) && return $r || return $p
}

# lists [files only] by time ...
# ...or as godo-style *: otherwise *
#
lst  () { lstc $FUNCNAME "$@"; }
lsc  () { lstc $FUNCNAME "$@"; }
lstc ()
{
	local r p

	invocation_name=$1; shift

	ls -1Flt --color=never --time-style=+$HISTTIMEFORMAT "$@" |
	sed -e '/\/$/d' | sed -e '0,/^total/d' | # remove dirs and "total"
	awk '{print $6, $7}' | # date and name
	awk '{
		date = $1; print "foo", date;
		rest = $2; print "bar", rest;
			   print "baz";
		idxofdot = index(rest, ".");
		matched = substr(rest, 1, idxofdot);
		printf("%u %s\n", date, matched);
	}'
	sort -sk 2 | # get rid of same filename after strip
	uniq -f 1 | # dot and up to ':' only
	sort -nrk 1,2 # sort results by date

	r=$? p=${PIPESTATUS[0]}
	((r)) && return $r || return $p
}


# all, long, unsorted, page
lsu ()
{
	local r p

	ls -lAF --color=always --time-style=+$HISTTIMEFORMAT "$@" |
	less -ER

	r=$? p=${PIPESTATUS[0]}
	((r)) && return $r || return $p
}

# lsa, wide, no dotfiles, useful in a home dir
lsh ()
{
	local r p

	ls -CFw $COLUMNS --color=always "$@" |
	less -ERX

	r=$? p=${PIPESTATUS[0]}
	((r)) && return $r || return $p
}

# lsa wide nopage; lsr instead of lsw for faster typing
lsr ()
{
	local r p

	ls -CAF --color=always "$@" |
	less -ER

	r=$? p=${PIPESTATUS[0]}
	((r)) && return $r || return $p
}

llatest ()
{
	local r p

	ls -1t ${@} |
	head -1

	r=$? p=${PIPESTATUS[0]}
	((r)) && return $r || return $p
}

loldest ()
{
	local r p

	ls -1t ${@} |
	tail -1

	r=$? p=${PIPESTATUS[0]}
	((r)) && return $r || return $p
}

$invocation_name "$@"
