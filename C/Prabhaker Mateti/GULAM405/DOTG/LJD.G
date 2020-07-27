# GULAM shell    adapted to meet the needs of Lee Dickey
# This file is named "gulam.g" and it is executed each time
# Gulam is started.
msoff
# set some variables ----------------------------------------------------
	set	dir_cache 1
	set	verbosity 0

# the prompt
	setenv	STACK "%$STACK"
	set	prompt	'AtariST $cwd $ncmd $STACK'
	set	prompt_tail	' '

# communications
	set	baud_rate	1200
	set	rx_remote_cmd	'public xmodem st'
	set	sx_remote_cmd	'public xmodem rt'
	set	histfile	d:\gu_hist

# set some aliases
alias	hi	history
alias	pu	pushd
alias	po	popd

alias	rm	rm -i
alias	Rm	rm

alias	1st	gem d:\1st_word.prg
alias	uni	uniterm.prg

alias	logout	exit
alias	lo	exit	# ' d:\t_clock.g ; exit '
alias	term	' d:\t_clock.g ; exit '

alias	j	echo "No jobs."
alias	x	ue
alias	lc	ls
alias	ll	'ls -ltF'

alias	aa	'set aa $cwd '
alias	stash	'cp $1 $2 $3 $4 $5 $6 $7 $8 $9 $10  $aa'

alias	free	df a d

# copy some files, (if necessary)
# ------------------------------------------------------
set t1 " arc.ttp "
set t1 " $t1 t_clock.g gu.prg gulam.g gulamend.g "
set t1 " $t1 head.prg more14.ttp "
set t1 " $t1 lv.tos uud.ttp uue.ttp "
foreach fn { $t1 $t2 }
	set src a:\$fn
	set tgt d:\$fn
	if { -e $tgt }
		 # echo File in place: $tgt
	ef { -e $src }
		echo 'cp  '  " $src"   '	D:'
		cp $src $tgt
	ef
		echo '   ----------------       File not found:' $src
	endif
endfor
# two aliases
set	t	d:\more14.ttp
if { -e $t }
	alias	l	$t
	alias	p	$t
ef
	alias	l	more
	alias	p	more
endif

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
# Touch the clock.
# t_clock.g
set	t	"-"

# set for finding commands.-------------------------------------------
# echo rehash
# this line causes an implicit "rehash"
set	path	d:\,a:\
set	PATH	$path
