utilsh
==============================================================================

Collection of shell utilities, written in bash.

(once they become large or more useful, they will probably get moved to
their own repositories)

| Scott Mcdermott <scott@smemsh.net>
| https://github.com/smemsh/utilsh/
| https://spdx.org/licenses/GPL-2.0

____

.. contents::

____


exes
------------------------------------------------------------------------------

| **exes**, **files**, **bins**, **scripts**, **pyscripts**, **shscripts**
| output list of all executables, or any particular language scripts

exes is for doing things like::

 $ cd ~/bin
 $ for script in `pyscripts`; do head -1 $script; done | sort | uniq -c
      1 #!/usr/bin/env python
      1 #!/usr/bin/env python2
     13 #!/usr/bin/env python3

- if args given, uses those directories instead of current directory
- if args given are files, will end up "filtering"


invocations
..............................................................................

============= ================================================================
exes          outputs list of executables in the current directory
bins          only non-text executables
files         only files
scripts       only scripts, as determined by file magic
pyscripts     only python scripts
shscripts     only shell or bash scripts
============= ================================================================


bugs
..............................................................................

- accommodates filenames with newlines, but delimits output with them
- probably directories with newlines given as arguments would break
- inefficient if file list given, calls 'find' on each one of them
- bash behavior for readarray with null delimiter might change

  - '-t' not needed for nulls, needed for newlines; inconsistent


proc
------------------------------------------------------------------------------

select and display particular processes.

``proc`` is a suite of convenience wrapper functions for ``ps``
utilities, selecting processes with the requested attributes.  It will
output using a standard format, without a header line, so the fields
must be memorized.

``-p`` can be given to some commands to display only the pids rather
than the ``ps`` output fields.

invocations:

=========== ==================================================================
daemons     direct descendants of init
headless    no ctty, non-kernel
kthreads    kernel threads
leaders     session leaders
sessions    session leaders
procs       userspace processes
psa         by given regex, full table if no arg
psf         children of given parents, recursive
psl         session leader with specified name
psp         select the given pids
pspg        select from the given process groups
pspp        select by parent pid
pss         select by session id
pst         select by tty
=========== ==================================================================


datewrap
------------------------------------------------------------------------------

convenience date wrappers, implemented in ``datewrap.sh``::

  now
  today
  tomorrow
  yesterday
  thisweek
  lastweek
  nextweek
  thismonth
  lastmonth
  thisyear


tmuxtty
------------------------------------------------------------------------------

| tmuxtty.sh: tmuxtty, tmuxpid

Switches tmux client's focused tty to the one with ``number`` or ``pid``.

1. switch the focused window to the right tty with ``xttypid`` or
   ``xttytty`` from https://github.com/smemsh/utilx/

2. if you end up in a tmux window, but it's not the right one, use
   ``tmuxtty`` with the tty of some process you're trying to find that
   has the given controlling tty, or ``tmuxpid`` if you know the pid.

Either of these will require appropriate privileges to do everything.
In most cases that's just your user but sometimes switching to
privileged windows doesn't work without sudo.


srcdirs
------------------------------------------------------------------------------

:srcdirs:
  all git repos in $1 with config attribute $2 == 'true' printed
:dirties:
  outputs all srcdirs that have any 'modified' statuses

- default srcdir ``~/src``
- default attribute ``srcdirs.ispublic``
- does not handle spaces in repo paths (and newline is OFS)
- works only with non-bare repositories


lsa
------------------------------------------------------------------------------

Shell wrappers for listing files and directories (in ``lsa.sh``).  For
details of the flags used, it's better to look inside the script.

=========== ==================================================================
lsa         list all
lsf         only files
lsd         only directories
lst         by modtime
lsc         by ctime
lstc        by ctime
lsh         no dotfiles
lsu         unsorted
lw          wide
lsr         wide nopage (?)
llatest     show the latest file
loldest     show the oldest file
=========== ==================================================================


pause
------------------------------------------------------------------------------

send signals to groups of processes.  implemented in ``pause.sh``

======= =====================================================================
ppause  send SIGSTOP to PGID of oldest proc matching given ``pgrep`` pattern
presume send SIGCONT instead
pterm   send SIGTERM instead
======= =====================================================================



vimcmd
------------------------------------------------------------------------------

**vimcmd**: execute given vim commands with its ``--cmd`` after
redirecting output to stdout, and after which vim will ``quit``.

**vimver**: use ``vimcmd`` to print vim's ``v:versionlong`` as a line to
stdout.

==============================================================================


birth
------------------------------------------------------------------------------

display file creation dates


blkfree
------------------------------------------------------------------------------

show mountpoint and free megabytes of files/dirs from $@


cmpfuncs
------------------------------------------------------------------------------

- compares all functions that exist in both source files $1 and $2
- any remaining args restrict comparison to only those function names
- system must support "ctags -x" (ie exuberant, universal)
- outputs universal diff hunks for each differing function, or nothing
- function signature line (the ctags referent line) is not compared
- functions must end on a line with trailing brace in column 0
- only tested with C files

columnate
------------------------------------------------------------------------------

break input into columns by width of its longest word, fill to $COLUMNS


cwdof
------------------------------------------------------------------------------

get the cwd of the given pids


daemonize
------------------------------------------------------------------------------

initialize environment, fork/exec, setsid/disown, stdout/err to syslog

- performs all the steps daemons do in C programs, but for shell scripts
- use logger to redirect stdout and stderr to syslog using given prefix
- starts daemon with clean environment (only "standard" base env retained)

args:

- *arg1*: quoted string, will be unquoted to make argv for invoked program
- *arg2*: prefix to use (less colons) in syslog messages
- (if one arg supplied, log prefix will be invocation name)


fflatest
------------------------------------------------------------------------------

find latest regular file in dirtree by mtime, print parsable mtime stdout

todo:

- allow other kinds of times to be tested
- make sure this will handle filenames with newlines
- flags to print the name, the date, or both
- handle other kinds of inodes besides regular files


ffproximate
------------------------------------------------------------------------------

find files in temporal proximity.

outputs matching files that:

1. are located somewhere within user-specified tree, and
2. have mtimes within specified range of reference file

args:

- *arg1*: allowed +/- mtime variance
- *arg2*: mtime reference file
- *arg3*: match files only in tree rooted here
- *argN*: [treeN] ...
- if only one arg, use $default_variance and file's parent

todo:

- allow ctime in addition to mtime
- handle case of filenames starting with '-'


findsymbol
------------------------------------------------------------------------------

| finds libraries that define a symbol.
| looks in the standard system library search paths.

todo: look in other places, allow user to specify, getopt


getyn
------------------------------------------------------------------------------

gets a yes or no from the user:

| $1 -> 1 or 0 for default yes/no
| $2 -> prompt string

exits success for yes, failure for no


gidxck
------------------------------------------------------------------------------

checks if google has indexed the given page


greenv
------------------------------------------------------------------------------

start program as user with green environment (clean but sane)

usage:

- must be invoked as root (use sudo)
- arg1: user to run as
- argN: argument vector for program

desc:

- wraps program invocation as different user via sudo -u
- only basic/minimal sanitized version of environment passed in
- does not involve session layer, pam, etc
- impetus for this program was originally a "gem install" user+wrapper
- beyond that, useful to replace: su -lc "env - ENV=ENV1 ... args" user

note:

- redhat 'runuser' would work, but see debian bug 8700
- waiting for upstream util-linux release
- update: may be deprecated; runuser now is in jessie
- update: debian runuser starts login shell, uses pam?!?! (todo: verify)
- update: sudo uses pam anyways!

todo:

- integrate with ~/.bash/{init,env}
- does not handle spaces in any of the exports
- embeds call to sudo -- NOT GOOD, was whole point of runuser


man
------------------------------------------------------------------------------

sets up some LESS term overrides so display is better, and then executes
``/usr/bin/man``


markless
------------------------------------------------------------------------------

converts markdown file to roff macros, typesets for term and pages

- input file can be optionally compressed (.gz)
- input file can be optionally without .md or .md.gz extension

deps: pandoc

creds: snarfed pandoc invocation: Keith Thompson
http://stackoverflow.com/questions/7599447/

todo:

- refactor this, at least 2 factors to reduce on
- does not handle spaces
- barfs if one of the filename variants does not exist


memstrings
------------------------------------------------------------------------------

dump contents of heap memory and filter through ``strings``.  reads
``/proc/pid/maps`` to determine heap mapping, and reads only that.

| usage: ``memstrings <pid>``


mk4group
------------------------------------------------------------------------------

recursively makes dirs group-owned, setgid, and copies user mode to group

args:

- system group to chgrp given as $1
- all remaining args: trees to be recursively converted

nocomments
------------------------------------------------------------------------------

by either stdin or the given files, remove their comments and emit on
stdout.  knows only very simple comments like hashmarks.


rename
------------------------------------------------------------------------------

``rename.ul`` replacement with different/better options::

  rename [options | <from-string> <to-string>] <file> ...

  -p/--prepend <string to add to beginning>
  -a/--append <string to add to end>
  -P/--unprepend <string to remove from beginning>
  -A/--unappend <string to remove from end>

Debian removed rename.ul from its util-linux installation, so we have to
write our own.  While we're at it, we add a couple options to make it
easier to to prepend or append something without needing empty string
argument (which only works to append), although we still take one to
allow the interface to be used the same way

see also https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=982944


thes
------------------------------------------------------------------------------

display thesaurus entries using ``dict -d moby-thesaurus``

| *first arg*: word
| *second arg*: number of cols in output, default four


wrapt
------------------------------------------------------------------------------

apt, dpkg convenience wrapper

=========== ==================================================================
pkgsearch   searches packages, only names
short       searches packages, only first line of description
search      searches packages, full description and fields
desc        displays description metadata from the named package
url         displays the home page url
ls          displays file contents in package (list, files, contents)
install     passes args to ``apt-get install``
=========== ==================================================================

todo:

- verify names in "also"
- does not handle spaces in package names or other input, as usual


trunc
------------------------------------------------------------------------------

wraps coreutils 'truncate', making all args zero bytes

args: any options and files to give to 'truncate'
