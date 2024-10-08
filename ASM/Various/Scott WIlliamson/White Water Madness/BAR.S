  TEXT

DRAWBAR:                ; DRAWS 128b LIFE/ENERGY BAR FROM D0 AT (A0)
  MOVE.L A0,A1          ; COPY INIT ADRESS
  ADD.L #64,A1          ; A1 INDICATES END
  AND #$7F,D0           ; MASK OFF UNWANTED BITS (0-127 ALLOWED)

  MOVE D0,D1            ; COPY D0
  AND #$F,D1            ; D1 IS SPLIT REMAINDER
  LSR #4,D0             ; D0 IS # OF TOTALY LIT SECTIONS OF THE BAR
  BEQ DRAWSPLITBAR      ; IF THERE ARE NO SECTIONS SKIP FOLLOWING LOOP
  SUBQ #1,D0            ; FIX FOR DBRA
DRAWSOLID:              ; DRAW SOLID PORTION OF BAR
  MOVE #$FFFF,(A0)      ; LINE 0   DRAW IN COLOR 1
  MOVE #$FFFF,160(A0)   ; LINE 1
  MOVE #$FFFF,320(A0)   ; LINE 2
;  MOVE #$FFFF,480(A0)   ; LINE 3
;  MOVE #$FFFF,640(A0)   ; LINE 4
;  MOVE #$FFFF,800(A0)   ; LINE 5
;  MOVE #$FFFF,960(A0)   ; LINE 6
;  MOVE #$FFFF,1120(A0)  ; LINE 7
  ADD.L #8,A0
  DBRA D0,DRAWSOLID     ; ENDLOOP

DRAWSPLITBAR:
  SUB #16,D1
  NEG D1
  CLR D0
MAKEBAR:
        CMP     #16,D1
        BEQ     DRAWSEC
  ADDQ #1,D1            ; INC BIT COUNT
  BSET D1,D0            ; SET BITS FROM RIGHT TO LEFT
  BRA   MAKEBAR           ; ENDLOOP

DRAWSEC:
  MOVE D0,(A0)          ; LINE 0   DRAW IN COLOR 1
  MOVE D0,160(A0)       ; LINE 1
  MOVE D0,320(A0)       ; LINE 2
;  MOVE D0,480(A0)       ; LINE 3
;  MOVE D0,640(A0)       ; LINE 4
;  MOVE D0,800(A0)       ; LINE 5
;  MOVE D0,960(A0)       ; LINE 6
;  MOVE D0,1120(A0)      ; LINE 7
  ADD.L #8,A0

CLEARBAR:               ; CLEAR REST OF BAR
  CMP.L A1,A0           ; ARE WE AT THE END OF THE BAR YET?
  BGE EXITBAR           ; YES-GOODBYE
  MOVE #0,(A0)          ; LINE 0   CLEAR COLOR 1
  MOVE #0,160(A0)       ; LINE 1
  MOVE #0,320(A0)       ; LINE 2
;  MOVE #0,480(A0)       ; LINE 3
;  MOVE #0,640(A0)       ; LINE 4
;  MOVE #0,800(A0)       ; LINE 5
;  MOVE #0,960(A0)       ; LINE 6
;  MOVE #0,1120(A0)      ; LINE 7
  ADD.L #8,A0
  BRA CLEARBAR
EXITBAR:
  RTS

  END
 