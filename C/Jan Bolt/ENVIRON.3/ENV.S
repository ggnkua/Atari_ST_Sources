*===============================================================*
*                                                               *
* ENV.S               ==> ENV.TOS                               *
*                                                               *
* Anzeige der Environment-Strings                               *
*                                                               *
*                                                               *
* 17.02.90 Jan Bolt                                             *
*                                                               *
* MAS                                                           *
*===============================================================*

          include "gemdos.mac"

CR        equ       $0d
LF        equ       $0a

*======================= Hauptprogramm =========================*

BASEPAGE  set       4
P_ENV     set       $2c

main:     move.l    BASEPAGE(sp),a0          ; Adresse Basepage
          move.l    P_ENV(a0),a6             ; Adresse Env-Strings
env1:     tst.b     (a6)                     ; Ende der Strings ?
          beq       envend                   ; ja
env2:     clr.w     d0                       ; einen String
          move.b    (a6)+,d0                 ; ausgeben
          beq       esend
          Cconout   d0
          bra       env2
esend:    Cconws    crlf                     ; String mit CR, LF
          bra       env1                     ; abschliežen
envend:   Cnecin                             ; auf Taste warten
          Pterm0                             ; Ende

          data
crlf:     dc.b      CR,LF,0          

