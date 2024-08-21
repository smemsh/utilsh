#!/usr/bin/env bash
#
# datewrap.sh
#   now, today, yesterday, tomorrow, thisweek, lastweek, thismonth, lastmonth
#
# desc:
#   convenience date wrappers
#
# scott@smemsh.net
# https://github.com/smemsh/utilsh/
# https://spdx.org/licenses/GPL-2.0
#
##############################################################################

invname=${0##*/}

mflags=%Y%m
dflags=%Y%m%d
wflags=%G%V
nflags=%Y%m%d%H%M%S

_thisweek  () { date +$wflags; }
_thismonth () { date +$mflags; }
_today     () { date +$dflags; }
_now       () { date +$nflags; }

_nextweek  () { date -d next-week +$wflags; }
_lastweek  () { date -d last-week +$wflags; }
_lastmonth () { date -d last-month +$mflags; }
_yesterday () { date -d yesterday +$dflags; }
_tomorrow  () { date -d tomorrow +$dflags; }

main ()
{
	if [[ $(declare -F _$invname) ]]; then
		_$invname "$@"
	else
		echo usage:
		for f in $(compgen -A function _); do
			echo -e \\t${f#_}; done
		exit 1
	fi
}

main "$@"
