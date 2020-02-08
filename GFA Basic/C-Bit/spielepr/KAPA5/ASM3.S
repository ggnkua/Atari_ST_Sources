;Programm das Routine im Supervisor Mode aufruft
;Åber XBIOS 38 - Superexec
;
;KapA5.TOS ASM3.S
;
SUPEREXEC EQU 26 ; Funktionsnummer
XBIOS     EQU 14 ; extendet basis input output - Xbios Trap
;
;***** Aufruf von Superexec *****
;
          PEA     ROUTINE          ;Adresse der auszufÅhrenden
                                   ;Routine auf den Stack
          MOVE.W  #SUPEREXEC,-(SP) ;Funktionsnummer a.d. Stack
          TRAP    #XBIOS           ;XBIOS Betriebssystem
                                   ;Routinen aufrufen
          ADDQ.L  #6,SP            ;Stack zurÅck
;
;     ****** QUIT ********* siehe oben !!
;
          CLR.W   -(SP)
          TRAP    #1
;
;
;****** Hier folgt aufzurufende Routine *****
;
ROUTINE: ;Label der anzuspringenden Routine
;
; Programmcode im Superviesor Mode
; Jedoch keine Betriebssystem Aufrufe !!!
;
          RTS ; Wird mit einem RTS d.h.
              ; return from suproutine beendet
              ; "springt" dann hinter den TRAP #XBIOS
END
