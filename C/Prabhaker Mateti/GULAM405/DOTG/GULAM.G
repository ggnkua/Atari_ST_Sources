#set show_mem	1
set dir_cache	1
set verbosity 2
set prompt	'$ncmd $cwd 257'
set prompt_tail	' '
#set baud_rate	9600
set sz_rs232_buffer	4096
set sx_remote_cmd	'rz -a'
set rx_remote_cmd	'sz -X'
#set histfile	e:\history.g

set path c:\bin,d:\bin

setenv TEMP f:\

alias tx	'cp $1.tex d:\tex\bin; pushd d:\tex\bin; tex &lplain $1 ; popd'
alias dvi	'pushd d:\tex\bin; gem dvi.prg $1.dvi ; popd d:\tex\bin'
alias txc	'rm *.aux *.log *.dvi'
alias d+	pushd
alias d-	popd
alias h		history
alias p		more
alias rm	'rm -i'
alias Rm	rm
alias ll	'ls -lF'
alias ls	'ls -F'
alias bk	'arc a f:\gulam.arc 'e:\gulam\*.c' 'e:\gulam\*.h' 'e:\gulam\*.s' ; mv f:\gulam.arc a: ; ls -l a:\ '
e:\dotg\mwc.g
alias uc 'ue e:\casedl\$1.n'
cd f:\
