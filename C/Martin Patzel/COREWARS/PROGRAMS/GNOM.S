;
;       gnom.s
;
        JMP     start
ptr     DAT     -1
start:
        ADD     #5,ptr
        MOV     #0,@ptr
        JMP     start
