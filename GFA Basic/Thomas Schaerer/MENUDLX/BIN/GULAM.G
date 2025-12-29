set GG      g
set tcdir   $GG:\tc
set texdir  e:\tex
set ctexdir g:\ctex
set drawdir h:\easydraw
set gnucdir f:\gnuc
set psdir   i:\ps
set prtfoliodir e:\prtfolio

#set show_mem	1
set dir_cache	1
set verbosity 2
set prompt	'$ncmd $cwd 257'
set prompt_tail	' '
set baud_rate	19200
set sz_rs232_buffer	4096
set sx_remote_cmd	'rz -a'
set rx_remote_cmd	'sz -X'
set gulam_help_file c:\bin\gulam.hlp
#set histfile	e:\history.g
set history 20

# the following sets tabs on Epson MX-80
#set pr_bof '033D010020030040050060070033C102'
#set pr_eof '214'
#set pr_eop '214n'
#set pr_eol 'rn'

# the following sets Atari SLM 804
#set pr_bof '033D010020030040050060070033C102'
set pr_eof '014'
#set pr_eop '014'
#set pr_eol 'rn'


setenv PATH c:,c:\bin,d:\lattic,e:\sound,h:\wordplus

setenv TRB c:\bin
setenv TEMP e:
setenv SUFF .prg,.tos,.ttp
#setenv LIBPATH g:,d:\mwc\lib,d:\mwc\bin
setenv TMPDIR g:
#setenv INCDIR d:\mwc\include
#setenv TIMEZONE CST:0:CDT
setenv HELPDIR d:\rbhelp
setenv HELPFILE 'gnutex;msdos'
setenv MYINPUTS g:\metafont

#alias cc 'f:\cc.ttp -V -DMWC -c -Ic:\gulam -Ic:\bin\emacs'
#alias li 'f:\cc.ttp -V *.o -lgu -lue -o a.prg'
#alias ldlib 'cp d:\mwc\lib\*.* d:\mwc\bin\cc.ttp g:\ '

alias ngu	'ue c:\gulam.g'

alias clear	'echo %033E%c'
alias c		clear

alias m         'pushd $texdir; gem menu+; popd'
alias dfall     'df c d e f g h i'
alias since     'time myfind -a$1 -r c:\ d:\ e:\ f:\ g:\ h:\ i:\'

alias prtfoljb  '$texdir\prtfoljb'
alias frmtex    '$texdir\frmtex -n'
alias frmtexp   '$texdir\frmtex -n -r37 -i0'
alias touml     '$texdir\touml -r78'
alias backpr    '$texdir\backpr -i5'
alias dvitty    'echo "dvi2tty";$texdir\dvi2tty -o t $texdir\dvi\$1; echo "touml";touml -c t;echo "Ready for printing"'
alias dvi2tty   '$texdir\dvi2tty'
alias sda       'myfind -t -i -r $1 $cwd'
alias myhelp    'd:\rbhelp\help'
alias gnutex    'h:\gnutex\gnutex -l'
alias todiss    'pushd $texdir\input\diss'
alias todraw    'pushd $drawdir$1'
alias draw      'pushd $drawdir; gem easydraw; popd'
alias gemtex    '$drawdir\gemtex'
alias tops      'pushd $psdir; gem uscript; popd'
alias topsp     'a2ps $1 >$psdir\t.ps;pushd $psdir;gem uscript t.ps;Rm t.ps;popd'
alias tosound	'pushd e:\sound$1'
alias tosoundm	'pushd $GG:\soundm$1'
alias toprocess 'pushd $GG:\process$1'
alias toanalyze 'pushd $GG:\analyze$1'
alias tobin	'pushd c:\bin$1'
alias tolattic	'pushd d:\lattic\w$1'
#alias tomwc     'pushd d:\mwc$1'
#alias tosrc     'pushd e:\src$1'
alias tovideo	'pushd e:\video$1'
alias totex	'pushd $texdir$1'
alias toctex	'pushd $ctexdir$1'
alias totmp	'pushd e:\tmp$1'
alias totc      'pushd $tcdir$1'
alias tcc       'pushd $tcdir; gem tc; popd'
alias tohelios  'pushd i:\helios'
alias tofolio   'pushd $prtfoliodir$1;d'
alias tofolio1  'pushd $prtfoliodir$1;d1'
alias sig       'pushd i:\helios\home\duenki\signal'
alias bye	exit

alias f01	'gem e:\filt\filt01'
alias f02	'gem e:\filt\filt02'
alias f03	'gem e:\filt\filt03'
alias fcnv	'gem e:\filt\soundflt'
alias m30	'gem e:\filt\max300'
alias uni	'pushd c:\bin; gem c:\bin\uniterm;popd'
alias uw	'pushd $GG:\uw; gem uw.prg;popd'
alias soundm    'pushd e:\sound; gem soundm.prg; popd'

#alias txc	'rm *.aux *.log *.dvi'

alias emacs	'c:\bin\emacs.ttp @c:\emacs.rc $1'
alias emacst	'c:\bin\emacs.ttp @c:\emacst.rc $1'
alias wp	'gem c:\wordplus\wordplus $1'
alias hdscan	'gem hdscan13'
alias dir	'ls'
alias t		'cat'
alias d+	pushd
alias d-	popd
alias h		history
alias p		more
alias rm	'rm -i'
alias Rm	rm
alias ll	'ls -lF'
alias ls	'ls -F'
alias dir	'ls -F'
alias cp	'cp +t'
alias menu	'pushd e:\tex; gem menu+; popd'
alias make	'd:\lattic\make -f $1.mak'
alias assems    'd:\lattic\assem from $1.s to $1.o opt j'
alias arxx      'd:\clink\arxx'

#kb -r 081 44
#kb -r 083 42
#kb -r 084 2c
#kb -r 089 3e
#kb -r 08a 0d
#kb -r 08c 55
#kb -r 08e 54
#kb -r 143 0e
#kb -r 15a 62
#kb -r 220 30
#kb -r 252 2f

#kb -g 081 44
#kb -g 083 42
#kb -g 084 2c
#kb -g 089 3e
#kb -g 08a 0d
#kb -g 08c 55
#kb -g 08e 54
#kb -g 143 0e
#kb -g 15a 62
#kb -g 220 30
#kb -g 252 2f

#kb -m 081 44
#kb -m 083 42
#kb -m 084 2c
#kb -m 089 3e
#kb -m 08a 0d
#kb -m 143 0e
#kb -m 15a 62
#kb -m 220 30
#kb -m 252 2f

rehash

