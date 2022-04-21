;* SCREEN Plus - ST Computer 4/92 *
v_bas_ad        EQU $044E
nvbls           EQU $0454
vblqueue        EQU $0456
sysbase         EQU $04F2
mfp             EQU $FFFA01
aer             EQU $FFFA03
iera            EQU $FFFA07
isra            EQU $FFFA0F
imra            EQU $FFFA13
tbcr            EQU $FFFA1B
tbdr            EQU $FFFA21
sync_mod        EQU $FF820A
zeile           EQU 190
                bra     init
trap_2:         move.l  D1,vdipd
                move.w  D0,vdi_aes
                move.l  2(SP),return
                move.l  #new_return,2(SP)
                movea.l vblqueue,A1
                move.l  #new_maus,(A1)
                movea.l old_vektor,A1
                jmp     (A1)
new_return:
                cmpi.w  #$73,vdi_aes
                beq.s   vdi
zurueck:        movea.l return,A1
                jmp     (A1)
vdi:            movem.l D0-D2/A0-A2,-(SP)
                movea.l vdipd,A0
                movea.l (A0),A1
                cmpi.w  #1,(A1)
                bne.s   no_open
                movea.l 12(A0),A1
                move.w  #244,2(A1)
                movea.l linea_param,A0
                move.w  #244,-$02B2(A0)
                addi.w  #5,-$2A(A0)
                addi.w  #45,-4(A0)
                move.l  old_vektor,-(SP)
                move.w  #34,-(SP)
                move.w  #5,-(SP)
                trap    #13
                addq.l  #8,SP
no_open:        movem.l (SP)+,D0-D2/A0-A2
                bra.s   zurueck
new_maus:       movea.l linea_param,A5
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
                jsr     0
                movem.w (SP)+,D0-D1
                movea.l linea_param,A5
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
maus1:          jsr     0
                movea.l v_bas_ad,A1
                adda.l  D1,A1
maus_adr3:      jmp     0
new_vbl:        move.b  #zeile,tbdr
                move.b  #8,tbcr
                rts
timer_b:        move.l  D0,-(SP)
                move    #$2700,SR
w200:           cmpi.b  #180,tbdr
                bne.s   w200
                move.b  #0,sync_mod
                move.w  #2,D0
w:              nop
                dbra    D0,w
                move.b  #2,sync_mod
                move    #$2300,SR
                move.b  #0,tbcr
                move.l  (SP)+,D0
                bclr    #0,isra
                rte
                EVEN
old_vektor:     DS.L 1
return:         DS.L 1
vdipd:          DS.L 1
vdi_aes:        DS.W 1
linea_param:    DS.L 1
old_stack:      DS.L 1
init:           movea.l 4(SP),A6
                move.w  #$0100,D7
                add.l   12(A6),D7
                add.l   20(A6),D7
                add.l   28(A6),D7
                move.w  #4,-(SP)
                trap    #14
                addq.l  #2,SP
                cmp.w   #2,D0
                beq     error1
                DC.W $A000
                move.l  A0,linea_param
                clr.l   -(SP)
                move.w  #32,-(SP)
                trap    #1
                addq.l  #6,SP
                move.l  D0,old_stack
                movea.l sysbase,A0
                move.w  2(A0),D0
                lea     tos_1_2,A1
                cmp.w   #$0102,D0
                beq.s   tos1
                lea     tos_1_4,A1
                cmp.w   #$0104,D0
                bne     error3
tos1:           move.l  (A1)+,maus_adr1+2
                move.l  (A1)+,maus1+2
                move.l  (A1)+,maus_adr3+2
                sub.l   #init_end-init,D7
                move.l  A6,D6
                add.l   D7,D6
                add.l   #255,D6
                clr.b   D6
                move.w  #-1,-(SP)
                move.l  D6,-(SP)
                move.l  D6,-(SP)
                move.w  #5,-(SP)
                trap    #14
                lea     12(SP),SP
                movea.l vblqueue,A0
                addq.l  #4,A0
                move.w  nvbls,D0
                subq.w  #2,D0
such:           move.l  (A0)+,D1
                beq.s   eintrag
                dbra    D0,such
                bra     error2
eintrag:        move.l  #new_vbl,-(A0)
                move.l  #timer_b,$0120
                move.b  #0,tbcr
                andi.b  #$F7,aer
                move.b  #zeile,tbdr
                ori.b   #1,imra
                ori.b   #1,iera
                move.w  #37,-(SP)
                trap    #14
                addq.l  #2,SP
                move.b  #8,tbcr
                pea     trap_2
                move.w  #34,-(SP)
                move.w  #5,-(SP)
                trap    #13
                addq.l  #8,SP
                move.l  D0,old_vektor
                move.l  old_stack,-(SP)
                move.w  #32,-(SP)
                trap    #1
                addq.l  #6,SP
                add.l   #32000+7200,D6
                sub.l   A6,D6
                clr.w   -(SP)
                move.l  D6,-(SP)
                move.w  #$31,-(SP)
                trap    #1
error1:         pea     err_txt1
                bra.s   error
error2:         pea     err_txt2
                bra.s   error
error3:         pea     err_txt3
error:          move.w  #9,-(SP)
                trap    #1
                addq.l  #6,SP
                move.w  #-1,D0
warte:          dbra    D0,warte
                clr.w   -(SP)
                trap    #1
                EVEN
tos_1_2:        DC.L $FD01DE,$FCA212,$FD008C
tos_1_4:        DC.L 0,0,0
err_txt1:       DC.B "Nur niedrige oder mittlere"
                DC.B " Aufl”sung !",0
err_txt2:       DC.B "Alle VBL-Slots belegt !",0
err_txt3:       DC.B "Unbekannte TOS-Version !",0
                EVEN
init_end:
                END
