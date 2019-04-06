;========================================================
;
;                   ASMSTART.ASM
;
; Copyright (C) 1988  Metacomco plc. All rights reserved
;
; Startup code for the Atari assembler code
;
;========================================================

; Equates
;
GEM_SHRK  EQU   $4A         ; TOS shrink memory
GEM_TERM  EQU   $4C         ; Terminate process
;
        TEXT  

STARTUP
        MOVE.L  4(A7),A0    ; Get address of base page into A0
        MOVE.L  $18(A0),D2  ; Base of the BSS
        ADD.L   $1C(A0),D2  ; D2 = Size + base of BSS (Base of free memory)
        MOVE.L  A7,D0       ; Top of memory into D0
        SUB.L   _STACK,D0   ; Allow space for the stack.
        SUB.L   D2,D0       ; D0 is now ammount of free memory.
        MOVE.L  D0,D3       ; Now set D3 to how much space I want.
        MOVE.L  _MNEED,D1   ; 0 -> all <0 -> leave for TOS >0 -> what I need.
        BEQ     AllOK       
        BGT.S   whatIneed
        ADD.L   D1,D3       ; _MNEED is negative
        BRA.S   D3set
whatIneed:
        MOVE.L  D1,D3       ; D3 is what I need.
D3set:  CMP.L   D3,D0
        BGE.S   ok
        MOVE.L  D0,D3       ; Too big so use Total space.
ok:     MOVE.L  D2,D1       ; Base of free memory
        SUB.L   A0,D1       ; - base page (gives the program size)
        ADD.L   D3,D1       ; + space needed
        ADD.L   _STACK,D1   ; + stack need = Size of memory needed.
        MOVE.L  D1,-(A7)    ; New size
        MOVE.L  A0,-(A7)    ; Base of memory
        CLR.W   -(A7)       ; filler
        MOVE.W  #GEM_SHRK,-(A7)  ; function code
        TRAP    #1
        TST.L   D0
        BEQ.S   done
        MOVE.W  D0,-(A7)         ; Error, set return code
        MOVE.W  #GEM_TERM,-(A7)  ; and terminate.
        TRAP    #1
;
done:   MOVE.L  D2,A7       ; Set up the stack
        ADD.L   D3,A7       ; add in the heap size
        ADD.L   _STACK,A7   ; and the stack.
AllOK   NOP

; User code gets linked in here

        DATA

_STACK  DC.L    $400        ; A default stack of 1K.
_MNEED  DC.L    $1000       ; A default heap of 4K.

        END

; End of ASMSTART.ASM
