\tools\cp68 command.c command.i
\tools\c068 command.i command.1 command.2 command.3 -f 
\tools\c168 command.1 command.2 command.s 
era  command.1
era command.2
\tools\as68 -l -s \tools\ -u command.s 
era  command.s
#\tools\link68 [s] command.rel = coma,command[l],lmul,lrem,ldiv
\tools\link68 command.rel = coma,command,lmul,lrem,ldiv
\tools\relmod command.rel command.prg

