; V_GTEXT                 Volker Hemsen             Oktober 1991
; GEM-Text fÅr GFA-Basic  (schnelles TEXT X,Y,A$)

; Der VDI-Textaufruf wird in GFA-Basic sehr stark abgebremst.
; Mit dieser kleinen Routine ist es mîglich durch öbergabe einer
; String-Deskriptor-Adresse einen Text auszugeben.
; Wenn man die X-Koordinate auf ein 8faches legt, erzielt man
; ebenfalls einen enormen Geschwindigkeitszuwachs.
; Noch schneller gehts mit diversen VDI-Patches, z.B. Quick ST
; Turbo ST, NVDI usw.

; Aufruf:
;          ~C: adr%( L:*A$ , X& , Y& , L:VDI_BLOCK% )
; (siehe V_GTEXT.LST)


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

                move.l  str_des(SP),D0  ;str_des
                tst.l   D0
                ble.s   ende
                movea.l D0,A1
                move.w  4(A1),D0        ;str_len
                tst.w   D0
                ble.s   ende
                move.w  D0,6(A0)        ;anz_intin
                movea.l (A1),A1         ;str_adr

loop:           clr.b   (A2)+           ;Zeichen Åbergeben
                move.b  (A1)+,(A2)+
                subq.w  #1,D0
                bgt.s   loop

                moveq   #$73,D0
                trap    #2
ende:           rts
                END
