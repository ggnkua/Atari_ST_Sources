;********************************************************
;***                    SCREENPLUS II                 ***
;*** Based on Screenplus, written by Steffen Scharfe, ***
;***  ST-Computer 4/92                                ***
;*** Extensions written by T. Huth, 1997              ***
*********************************************************

nvbls       EQU $0454
vblqueue    EQU $0456
sysbase     EQU $04F2
mfp         EQU $FFFFFA01
aer         EQU $FFFFFA03
iera        EQU $FFFFFA07
isra        EQU $FFFFFA0F
imra        EQU $FFFFFA13
tbcr        EQU $FFFFFA1B
tbdr        EQU $FFFFFA21
sync_mod    EQU $FFFF820A
new_y_res   EQU 240

start:
            bra     init

;*** VBL-Routine: ***
new_vbl:    move.b  #190,tbdr.w
            move.b  #8,tbcr.w
            rts

;*** Timer-B-Routine: ***
            DC.B "XBRASCR+"
old_tb:     DS.L 1
new_tb:     move    #$2700,SR
            move.l  D0,-(SP)
w200:       cmpi.b  #180,tbdr.w
            bne.s   w200
            move.b  #0,sync_mod.w
            move.w  #2,D0
tb_wait:    nop
            dbra    D0,tb_wait
            move.b  #2,sync_mod.w
            move    #$2300,SR
            move.b  #0,tbcr.w
            move.l  (SP)+,D0
            bclr    #0,isra.w
            rte

;*** GEM-Handler: ***
            DC.B "XBRASCR+"
oldgem:     DS.L 1
new_trap_2: cmp.w   #$73,D0     ; VDI-Aufruf?
            bne.s   tst_vq_drvr
            move.l  D1,vdipb
            move.w  (SP),oldsr
            move.l  2(SP),gemret
            move.w  #$2500,(SP)
            move.l  #new_gemret,2(SP)
gooldgem:
            move.l  oldgem(PC),-(SP)
            rts                 ; Via rts springen
tst_vq_drvr:
            cmp.w   #-1,D0      ; vq_driver Aufruf?
            bne.s   gooldgem
            move.l  #new_vq_driver,D0
            rte
new_gemret:
            movem.l D0-D2/A0-A2,-(SP)
            movea.l vdipb(PC),A0
            movea.l (A0),A1
            cmpi.w  #1,(A1)     ; v_opnwk-Aufruf?
            bne     gemret_end
            cmpi.w  #4,12(A1)   ; Ist es auch Bildschirm?
            bhi     gemret_end
            movea.l 12(A0),A1
            move.w  #new_y_res,2(A1) ; Neue Werte eintragen
            DC.W $A000          ; Line-A Parameter
            move.w  #new_y_res,-$02B2(A0)
            move.w  #(new_y_res/8)-1,-$2A(A0) ; Textzeilen
            move.w  #new_y_res,-4(A0)

            move.w  #-1,-(SP)
            move.l  newscreen(PC),-(SP)
            move.l  newscreen(PC),-(SP)
            move.w  #5,-(SP)
            trap    #14         ; Neuen Screen setzen
            lea     12(SP),SP
            movea.l vblqueue.w,A0 ; Zeiger auf VBL-Liste holen
            addq.l  #4,A0
            move.w  nvbls.w,D0
            subq.w  #2,D0
vblsuch:    tst.l   (A0)+
            beq.s   vbleintrag
            cmpi.l  #new_vbl,-4(A0)
            beq.s   gemret_end
            dbra    D0,vblsuch
            move.w  #$0700,$FFFF8240.w
            bra.s   gemret_end
vbleintrag: move.l  #new_vbl,-(A0) ; VBL-Routine eintragen
            cmpi.l  #new_tb,$0120.w
            beq.s   gemret_end
            move.l  $0120.w,old_tb
            move.l  #new_tb,$0120.w ; Timer-B Routine eintragen
            move.b  #0,tbcr.w
            andi.b  #$F7,aer.w
            move.b  #190,tbdr.w
            ori.b   #1,imra.w
            ori.b   #1,iera.w
            move.w  #37,-(SP)
            trap    #14         ; Vsync
            addq.l  #2,SP
            move.b  #8,tbcr.w   ; Timer in Event-Count-Mode an

gemret_end:
            movem.l (SP)+,D0-D2/A0-A2
            move.l  gemret(PC),-(SP)
            move    oldsr(PC),SR
            rts

;*** Neuer vq_driver: ***
new_vq_driver:
            move.l  D1,vdipb
            move.l  (SP),oldsr
            move.l  2(SP),gemret
            move.w  #$2500,(SP)
            move.l  #new_gemret,2(SP)
            move.l  oldvqdrvr(PC),-(SP)
            rts

gemret:     DS.L 1
vdipb:      DS.L 1
oldvqdrvr:  DS.L 1
newscreen:  DS.L 1
oldsr:      DS.W 1

;*** Initialisation: ***
init:
            movea.l 4(SP),A6    ; Basepage -> A6
            move.l  #$0500,D7   ; Grîûe Basepage + Stack
            add.l   12(A6),D7   ; + TEXT
            add.l   20(A6),D7   ; + DATA
            add.l   28(A6),D7   ; + BSS
            move.l  D7,D0
            add.l   A6,D0
            movea.l D0,SP       ; Stack setzen
            move.l  D7,-(SP)
            move.l  A6,-(SP)
            clr.w   -(SP)
            move.w  #$4A,-(SP)
            trap    #1          ; Mshrink
            lea     12(SP),SP

            move.w  #-1,-(SP)
            move.w  #11,-(SP)
            trap    #13         ; Kbshift
            addq.l  #4,SP
            and.b   #1,D0
            beq.s   no_abort
            pea     notinsttxt(PC)
            move.w  #9,-(SP)
            trap    #1
            clr.w   (SP)        ; Bei gedrÅckter rechter Shift-Taste
            trap    #1          ; beenden
no_abort:

            move.w  #4,-(SP)
            trap    #14         ; Getrez
            addq.l  #2,SP
            cmp.w   #2,D0
            bhs     error1      ; Kein monochrom

            move.w  #2,-(SP)
            trap    #14         ; Physbase
            addq.l  #2,SP
            movea.l D0,A5       ; Alte Screenaddi in A5
; Versuchen, 8000 Bytes vor dem alten Screenram zu bekommen:
            move.l  #-1,-(SP)
            move.w  #$48,-(SP)
            trap    #1          ; Malloc(-1)
            move.l  D0,D4
            move.l  D0,-(SP)
            move.w  #$48,-(SP)
            trap    #1          ; Grîûten Block allozieren
            lea     12(SP),SP
            tst.l   D0
            bmi.s   nrmlram
            movea.l D0,A4
            adda.l  D4,A4
            cmpa.l  A4,A5
            bne.s   freeit
            move.l  D0,D5
            sub.l   #8000,D4
            move.l  D4,-(SP)
            move.l  D0,-(SP)
            clr.w   -(SP)
            move.w  #$4A,-(SP)
            trap    #1          ; Mshrink
            lea     12(SP),SP
            tst.w   D0
            bne     error0
            move.l  #8000,-(SP)
            move.w  #$48,-(SP)
            trap    #1          ; Malloc
            move.l  D0,D6
            move.l  D5,-(SP)
            move.w  #$49,-(SP)
            trap    #1          ; Mfree
            lea     12(SP),SP
            tst.l   D6
            bmi     error2
            move.l  D6,D0
            clr.b   D7          ; D7 als Flag verwenden
            add.l   #8000,D6
            cmpa.l  D6,A5
            bne.s   freeit
            move.b  #-1,D7
            bra.s   setnewscreen
freeit:
            move.l  D0,-(SP)
            move.w  #$49,-(SP)
            trap    #1          ; Mfree
            addq.l  #6,SP
nrmlram:
            move.l  #40000,-(SP)
            move.w  #$48,-(SP)  ; Malloc
            trap    #1          ; Screenram reservieren
            addq.l  #6,SP
            tst.l   D0
            bmi     error2
setnewscreen:
            add.l   #255,D0
            clr.b   D0          ; neue Screenaddi ermitteln
            move.l  D0,newscreen

            pea     meldung(PC)
            move.w  #9,-(SP)
            trap    #1          ; Meldung ausgeben
            addq.l  #6,SP
            tst.b   D7
            beq.s   nohurra
            pea     hurratxt(PC)
            move.w  #9,-(SP)
            trap    #1
            addq.l  #6,SP
nohurra:
            moveq   #-1,D0
            trap    #2          ; vq_driver
            move.l  D0,oldvqdrvr ; Alte Routine merken

            pea     new_trap_2(PC)
            move.w  #34,-(SP)
            move.w  #5,-(SP)
            trap    #13
            addq.l  #8,SP
            move.l  D0,oldgem

            clr.w   -(SP)
            move.l  #256+init-start,-(SP) ; Residenter Teil
            move.w  #$31,-(SP)  ; Ptermres
            trap    #1

; Fehlermeldung ausgeben:
error0:     pea     err0_txt(PC)
            bra.s   error
error1:     pea     err1_txt(PC)
            bra.s   error
error2:     pea     err2_txt(PC)
error:      move.w  #9,-(SP)
            trap    #1
            addq.l  #6,SP
            pea     notinsttxt(PC)
            move.w  #9,-(SP)
            trap    #1
            addq.l  #6,SP
            move.w  #8,-(SP)
            trap    #1
            clr.w   (SP)
            trap    #1

            DATA
meldung:    DC.B 13,10,27,'p',"SCREENPLUS II",27,'q'
            DC.B 13,10,"Original written by Steffen Scharfe,"
            DC.B 13,10,189," by Maxon Computer"
            DC.B 13,10,"Extensions written by Thomas Huth, 1997",0
hurratxt:   DC.B 13,10,27,'p',"Using old video ram!",27,'q',13,10,0
err0_txt:   DC.B 13,10,"Unknown error",0
err1_txt:   DC.B 13,10,"Only low or medium resolution",0
err2_txt:   DC.B 13,10,"Not enough memory",0
notinsttxt: DC.B 13,10,"SCREENPLUS *not* installed",0

            BSS
            EVEN
old_stack:  DS.L 1

            END
