;COMMAND1  eine modifizierte, aber nicht optimierte Version von 
;          COMMANDO
      MOV  0    -1
      JMP  -1
START SPL  -2
      MOV  IMP  223
      SPL  222
COPY  MOV  <LOC <NEW
      CMP  LOC  #-13
      JMP  COPY
      jmp  206           ; Sprung zur Kopie
IMP   MOV  0    1
NEW   DAT  214
LOC   DAT  1


