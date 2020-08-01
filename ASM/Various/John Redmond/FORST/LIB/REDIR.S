( redirect.s: console i/o redirection)

decimal

file f1
file f2

: namearg  32 word  0 over count + c! 1+ ;

: file>  f1 0 namearg fopen  f1 src ! ;
: console>  src @ fclose  0 src ! ;

: >console  dest @ abs fclose  1 dest ! ;
: >file  f2 1 namearg fopen  f2 dest ! ;
: >tee  f2 1 namearg fopen  f2 negate dest ! ;
: >printer  f2 1 " prn:" drop fopen  f2 dest ! ;

hide f1  hide f2  hide namearg
