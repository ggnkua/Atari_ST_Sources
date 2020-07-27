
# GULAM shell - adapted to meet my needs.
# Adapt it to suit yourself.

#-----------------------------------------------------------------------------
msoff	# turn mouse off
# set some variables
	set	dir_cache 1
	set	verbosity 0
	set history 200

#-----------------------------------------------------------------------------
# my prompt
	setenv	STACK "%$STACK"
	setenv	STACK "%"
	set	prompt	'AtariST $cwd $ncmd $STACK'
	set	prompt_tail	' '

#-----------------------------------------------------------------------------
# communications
	set	baud_rate	1200
	set	rx_remote_cmd	'public xmodem st'
	set	sx_remote_cmd	'public xmodem rt'
	set	histfile	d:\gu_hist

#-----------------------------------------------------------------------------
# set some aliases _____-------------------------------------------------------
alias	hi	history
alias	pu	pushd
alias	po	popd

alias	rm	rm -i
alias	Rm	rm

alias	uni	'gem d:\uniterm.prg'
alias	apl	'gem d:\apl.prg'

alias	term	exit
alias	quit	exit
alias	logout	exit
alias	lo	exit	

alias	j	echo "No jobs."
alias	x	ue
alias	lc	'ls -F'
alias	ll	'ls -ltF'

alias	init	'ls a:  > d:\junk ; rm d:\junk '

alias	aa	'set aa $cwd '
alias	stash	'cp +t $* $aa '

alias	free	'df a d'

#-----------------------------------------------------------------------------
# for the printer...
# the following sets tabs on PMs Epson MX-80
#	pr_bof: send before printing each new file.
	set pr_bof '033D010020030040050060070033C102'
	set pr_bof ' '

#	pr_eol: send after each line.
	set pr_eol 'rn'

#	pr_eop: send after each page (214 == ASCII ^L + 0200).
	set pr_eop '214n'
	set pr_eop ' '

#	pr_eof: send after the end of file.
	set pr_eof '214'
	set pr_eof ' '

# two aliases
set	t	d:\more14.ttp
if { -e $t }
	alias	l	$t
	alias	p	$t
ef
	alias	l	more
	alias	p	more
endif

# -----------------------------------------------------------------------------
set	t	d:\head.prg
if { -e $t }
	alias	tail	$t -t
	alias	string	$t -s
ef
	alias	tail	more
	alias	string	more
endif

set	t	d:\lv.tos
if { -e $t }
	alias	vi	$t
endif
unset t

#-----------------------------------------------------------------------------
# set for finding commands.
# this causes an implicit "rehash"
	set	path	d:\,a:\
	set	PATH	$path

#-----------------------------------------------------------------------------
# I like a sub-directory in ram disk.
set 	t 	d:\jj
if { -e $t }
	echo dir $t exists
ef
	mkdir $t
	echo Create directory $t
endif
unset t
#                     --- === EOF === ---

