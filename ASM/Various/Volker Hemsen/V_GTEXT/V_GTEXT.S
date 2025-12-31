; V_GTEXT                 Volker Hemsen             Oktober 1991
; GEM-Text fÅr GFA-Basic  (schnelles TEXT X,Y,A$)

; Der VDI-Textaufruf wird in GFA-Basic sehr stark abgebremst.
; (umrechnen von GDOS-Font-Offsets usw.)
; Mit dieser kleinen Routine ist es mîglich durch öbergabe einer
; String-Deskriptor-Adresse einen Text auszugeben.
; Wenn man die X-Koordinate auf ein 8faches legt, erzielt man
; ebenfalls einen enormen Geschwindigkeitszuwachs.

; Aufruf:
;          ~C: adr%( L:*A$ , X& , Y& , L:VDI_BLOCK% )
; siehe V_GTEXT.LST


str_des         EQU 4           ;*A$
x               EQU 8
y               EQU 10
vdi_block       EQU 12

contrl          EQU 0
intin           EQU 4
ptsin           EQU 8
intout          EQU 12
ptsout          EQU 16

                movea.l vdi_block(SP),A0
                move.l  A0,D1           ;fÅr TRAP
                movea.l ptsin(A0),A1    ;ptsin
                move.l  x(SP),(A1)      ;xy setzen
                movea.l intin(A0),A2    ;intin
                movea.l (A0),A0         ;contrl
                move.l  #$080002,(A0)   ;opcode und anz_ptsin setzen

                movea.l str_des(SP),A1  ;str_des
                move.w  4(A1),D0        ;str_len
                tst.w   D0
                beq.s   ende
                move.w  D0,6(A0)        ;anz_intin
                subq.w  #1,D0
                movea.l (A1),A1         ;str_adr

loop:           clr.b   (A2)+           ;Zeichen Åbergeben
                move.b  (A1)+,(A2)+
                dbra    D0,loop

                moveq   #$73,D0
                trap    #2
ende:           rts
                END
