;Fooberol source code by Stefan Posthuma (1992)
;String number in D0
;Return address in A0

     MOVE.W    #-1,D1              ; Compare value in D1
.0   CMP.W     (A0),D0             ; String number reached yet?
     BNE       .1                  ; No
     ADDQ.W    #2,A0               ; Skip number 
     RTS                           ; Leave

.1   CMP.W     (A0),D1             ; End of strings reached?
     BNE       .2                  ; No
     LEA       $FFFF,A0            ; -1, Not found
     RTS                           ; Leave

.2   TST.B     $1(A0)              ; Next byte a zero?
     BEQ       .3                  ; Yes
     ADDQ.L    #2,A0               ; Skip this word
     BRA       .2                  ; And again
.3   ADDQ.L    #2,A0               ; Skip this one
     BRA       .0                  ; Check again

