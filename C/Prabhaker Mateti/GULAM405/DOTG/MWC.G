set env_style mw
set path c:\mwc\bin,c:\bin,f:
setenv SUFF .prg,.tos,.ttp
setenv LIBPATH f:,c:\mwc\lib,c:\mwc\bin
setenv TMPDIR f:\
setenv INCDIR c:\mwc\include\
setenv TIMEZONE CST:0:CDT

alias cc 'f:\cc.ttp -V -DMWC -c -Ie:\gulam -Ie:\ue'
alias cg 'f:\cc.ttp -V -DMWC -c -Ie:\gulam e:\gulam\$1.c'
alias cu 'f:\cc.ttp -V -DMWC -c -Ie:\ue e:\ue\$1.c'
alias li 'f:\cc.ttp -V *.o -lgu -lue -o a.prg'
alias ldlib 'cp c:\mwc\lib\libc.a e:\ue\libue.a e:\gulam\libgu.a f:\ '
alias ug 'ue e:\gulam\$1.c'
alias uu 'ue e:\ue\$1.c'
