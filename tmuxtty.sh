#!/bin/bash
#
# tmuxtty.sh: tmuxtty tmuxpid
#   switches tmux client's focused tty by number
#
# todo:
#   - might not work if $target[] ends up being two lines? is it possible?
#
# scott@smemsh.net
# https://github.com/smemsh/utilsh/
# https://spdx.org/license/GPL-2.0
#
##############################################################################

tmuxtty ()
{
	local target=$(
		tmux list-panes -a -F '#{pane_id}#{pane_tty}' \
		| grep /dev/$1$ \
		| awk -F / '{print $1}'
	)
	tmux switch-client -t ${target:?}
}

tmuxpid ()
{
	local ttybase=$(ps -p ${1:?} -o tty=)
	tmuxtty $ttybase
}

main ()
{
	local invname=${0:##*/}

	if ! [[ `declare -F $invname` ]]
	then echo "unimplemented invocation: '$invname'"; exit 10;
	else $invname "$@"; fi
}

main "$@"
