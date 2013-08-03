
cp68 command.c command.i
c068 command.i command.1 command.2 command.3 -f 
c168 command.1 command.2 command.s 
era  command.1
era command.2
as68 -l -t -s \alyc\ -u command.s 
era  command.s
#link68 [s] command.rel = coma,command[l],lmul,lrem,ldiv
link68 command.prg = coma,command,lmul,lrem,ldiv

