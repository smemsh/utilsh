#!/usr/bin/env bash
#
# installx
#   copies all exe files and in-dir symlinks from $1:-./ to $2:-~/bin/
#
# scott@smemsh.net
# http://smemsh.net/src/utilsh/
# http://spdx.org/licenses/GPL-2.0
#
##############################################################################

src_default="${PWD:?}"
dst_default="${HOME:?}/bin"

usagex ()
{
	echo "$invname: args: <srcdir> <dstdir>"
	echo "$invname: default: src='$src_default' dst='$dst_default'"
	false; exit
}

process_args ()
{
	local yn
	local ask=1
	declare -g src dst

	if [[ $1 =~ (-f|--noask|--force) ]]
	then ask=0; shift; fi # default without asking

	case $# in
	(0) src="$src_default" dst="$dst_default";;
	(2) src="$1" dst="$2";;
	(*) usagex;;
	esac

	dst="${dst%/}"

	if ((ask)); then
		read -n 1 -p "overwrite in $dst/ with $src/* (y/n)? " yn; echo
		if [[ $yn != 'y' ]]; then
			echo "aborting"; false; exit; fi
	fi
}

check_sanity ()
{
	if ! test -d "$dst"; then
		if ! mkdir -p "$dst"; then
			echo "dest '$dst/' dne and mkdir failed"; exit; fi; fi

	if ! cd "$src"; then
		echo "source dir invalid"; false; exit; fi

	if ! test -w "$dst"; then
		echo "cannot write to dstdir '$dst/'"; false; exit; fi
}


print_execution_stats ()
{
	pluralize ()
	{
		printf $1
		if (($2 == 0 || $2 > 1)); then
			printf 's'; fi
	}

	local nscripts=${#scripts[@]}
	local nsymlinks=${#symlinks[@]}

	local src="$src/"
	local dst="$dst/"

	if [[ $src$dst =~ [^[:alnum:]_-/] ]]
	then src="\"$src\"" dst="\"$dst\""; fi

	echo "$src -> $dst"
	printf "installed "
	printf "$nscripts `pluralize script $nscripts`, "
	printf "$nsymlinks `pluralize symlink $nsymlinks`"
	echo
}

main ()
{
	process_args "$@" || exit
	check_sanity "$src" "$dst" || exit

	find_base="find -mindepth 1 -maxdepth 1"
	find_scripts="-type f -perm -01"
	find_symlinks="-type l -not -lname */*"
	find_print="-printf %P\\0"

	#
	# mapfile delim is a bash 4.4 feature, so we cannot use it yet
	#readarray -d $'\0' scripts < <($find_base $find_scripts $find_print)
	#readarray -d $'\0' symlinks < <($find_base $find_symlinks $find_print)
	#

	while read -d $'\0'
	do scripts+=("$REPLY")
	done < <($find_base $find_scripts $find_print)

	while read -d $'\0'
	do symlinks+=("$REPLY")
	done < <($find_base $find_symlinks $find_print)

	if ! cp \
		--archive \
		--remove-destination \
		"${scripts[@]}" \
		"${symlinks[@]}" \
		"$dst/"
	then
		echo "copy failed"
		false
		exit
	fi
	
	print_execution_stats
}

main "$@"
