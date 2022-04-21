;***************************************
;*** Neue Mausroutine fÅr TOS 1.02   ***
;*** Erlaubt Bildschirme, die grîûer ***
;*** als 32kB sind                   ***
;***************************************

v_bas_ad        EQU $044E
vblqueue        EQU $0456
sysbase         EQU $04F2

start:          bra     init

;*** Der GEM-Handler ***
                DC.B "XBRAMAUS"
oldgem:         DS.L 1
new_gem:        cmp.w   #$73,D0         ; VDI-Aufruf?
                bne.s   gooldgem
                move.l  A0,-(SP)
                movea.l D1,A0
                movea.l (A0),A0
                cmpi.w  #1,(A0)         ; Open Workstation?
                bne.s   no_open
                move.l  6(SP),oldret    ; Alte Adresse sichern
                move.l  #newret,6(SP)   ; Neue RÅcksprungsadresse eintragen
no_open:
                movea.l (SP)+,A0
gooldgem:
                move.l  oldgem(PC),-(SP)
                rts                     ; Via rts springen
newret:
                move.l  A0,-(SP)
                movea.l vblqueue.w,A0
                move.l  #new_maus,(A0)  ; Neuen Maustreiber eintragen
                movea.l (SP)+,A0
                move.l  oldret(PC),-(SP)
                rts                     ; Via rts springen

oldret:         DS.L 1

;*** Die Mausroutine: ***
new_maus:       movea.l linea_param(PC),A5
                tst.b   -$0153(A5)
                bne.s   maus_end
                bclr    #0,-$0154(A5)
                beq.s   maus_end
                move.l  -$0158(A5),D1
                move.l  D1,D0
                swap    D0
                movem.w D0-D1,-(SP)
                lea     -$014A(A5),A2
maus_adr1:
                jsr     $FFFD01DE       ; Tos 1.02 spezifisch
                movem.w (SP)+,D0-D1
                movea.l linea_param(PC),A5
                lea     -$0358(A5),A0
                lea     -$014A(A5),A2
                bsr.s   new_maus1
maus_end:
                rts
new_maus1:
                move.w  6(A0),-(SP)
                move.w  8(A0),-(SP)
                clr.w   D2
                tst.w   4(A0)
                bge.s   replace
                moveq   #$10,D2
replace:        move.w  D2,-(SP)
                clr.w   D2
                bclr    #1,6(A2)
                sub.w   (A0),D0
                bcs.s   x_hotspot
                move.w  -$02B4(A5),D3
                subi.w  #15,D3
                cmp.w   D3,D0
                bhi.s   teilweise_x
                bset    #1,6(A2)
                bra.s   maus_y
x_hotspot:
                addi.w  #16,D0
                moveq   #8,D2
                bra.s   maus_y
teilweise_x:
                moveq   #16,D2
maus_y:         sub.w   2(A0),D1
                lea     $0A(A0),A0
                bcs.s   y_hotspot
                move.w  -$02B2(A5),D3
                subi.w  #15,D3
                cmp.w   D3,D1
                bhi.s   teilweise_y
                moveq   #16,D5
                bra.s   maus1
y_hotspot:
                move.w  D1,D5
                addi.w  #16,D5
                asl.w   #2,D1
                suba.w  D1,A0
                clr.w   D1
                bra.s   maus1
teilweise_y:
                move.w  -$02B2(A5),D5
                sub.w   D1,D5
                addq.w  #1,D5
maus1:          jsr     $FFFCA212       ; Tos 1.02 spezifisch
                movea.l v_bas_ad.w,A1
                adda.l  D1,A1
maus_adr3:      jmp     $FFFD008C       ; Tos 1.02 spezifisch

linea_param:    DS.L 1

;*** Initialisation: ***
init:
                clr.l   -(SP)
                move.w  #32,-(SP)
                trap    #1              ; In Supervisor wechseln
                addq.l  #6,SP
                move.l  D0,oldstack

                DC.W $A000
                move.l  A0,linea_param

                movea.l sysbase.w,A5
                move.l  2(A5),D7

                move.l  oldstack,-(SP)
                move.w  #32,-(SP)
                trap    #1              ; In Usermode wechseln
                addq.l  #6,SP

                cmpi.w  #$0102,D7       ; Tos 1.02?
                bne.s   error

                pea     new_gem(PC)     ; Neuer GEM-Handler einklinken
                move.w  #34,-(SP)
                move.w  #5,-(SP)
                trap    #13             ; Setexec
                addq.l  #8,SP
                move.l  D0,oldgem

                pea     meldung(PC)
                move.w  #9,-(SP)
                trap    #1              ; Meldung ausgeben
                addq.l  #6,SP

                clr.w   -(SP)
                move.l  #256+init-start,-(SP)
                move.w  #$31,-(SP)
                trap    #1              ; Ptermres

error:
                pea     errtxt(PC)
                move.w  #9,-(SP)
                trap    #1              ; Meldung ausgeben
                addq.l  #6,SP

                move.w  #7,-(SP)
                trap    #1              ; Auf Taste warten
                addq.l  #2,SP

                move.w  #-1,-(SP)
                move.w  #$4C,-(SP)
                trap    #1              ;Pterm(-1)

                DATA
meldung:        DC.B 13,10,"NEWMOUSE installiert",0
errtxt:         DC.B 13,10,"NEWMOUSE lÑuft nur in Tos 1.02",0
                BSS
oldstack:       DS.L 1
                END
