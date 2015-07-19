\tools\cp68 command.c cmd10.i
\tools\c068 cmd10.i cmd10.1 cmd10.2 cmd10.3 -f -t
\tools\c168 cmd10.1 cmd10.2 cmd10.s -t
era  cmd10.1
era cmd10.2
\tools\as68 -t -l -s \tools\ -u cmd10.s 
era  cmd10.s

