#set show_mem		1
set dir_cache		0
set mscursor		0000
set verbosity		2
set prompt		'$ncmd $cwd 257'
set prompt_tail		' '
set baud_rate		9600
set sz_rs232_buffer	4096
set sx_remote_cmd	'rz -a'
set rx_remote_cmd	'sz -X'
set env_style		mw
set gulam_help_file	c:\gulam.hlp
set histfile		c:\history.g
set path		c:\bin,c:\tools,c:\alcyon,c:\debuger

setenv PATH		,,c:\bin,c:\tools,c:\alcyon,c:\debuger
setenv TEMP		m:\
setenv TMPDIR		m:\
setenv HOME		c:\bin
setenv TIMEZONE		CST:0:CDT
setenv SUFF		.prg,.ttp,.tos,.app
setenv LIBPATH		c:\lib,c:\bin
setenv INCDIR		c:\include
setenv ESC		""
setenv SHELL_P		yes
setenv GPshell		running
setenv SHELL		c:\bin\msh.prg

alias "++"		pushd
alias "--"		popd
alias h			history
alias t			more
alias Rm		rm
alias rm		"rm -i"
alias l			"ls -lF"
alias ls		"ls -F"
alias ex 		'm:\small;echo -n ${ESC}E;$-;m:\big'
alias 411		'egrep $- c:\phone_bo'
alias hs		history
alias lo 		exit
alias Rm		rm
alias cp		'cp +t'
alias mv		'mv +t'
alias white		'set rgb 777-555-333-000'
alias black		'set rgb 000-333-555-777'
alias mem		'echo "+++ NOT IMPLEMENTED +++"'
alias Mac		'mac -ic:\include'
alias e			'msoff;c:\gemacs\gemacs @c:\gemacs\emacs.rc $-;mson'

rehash
pokew	37d0	4
mson

cp c:\alcyon\as68symb.dat m:
e:\matrix\matrix\cxx_info
e:\matrix\matrix\cxx_driv e:\matrix\matrix\cxx\truecol.cxs
