                clr.l   D0
                move.b  D1,D0
                move.l  A2,mus
                move.l  A2,init+2
init:           jsr     $00
                adda.l  #104,A1
                move.l  A1,grafix
                adda.l  #32008,A1
                move.l  A1,pal
                move.w  #2,-(SP)        ;Hole Adresse des Physicalischen Screens
                trap    #14
                adda.l  #2,SP
                movea.l D0,A0           ;Adresse in a0
                movea.l grafix(PC),A1
                move.w  #0,D0           ;Kopieren der Grafik
setpic:         move.w  (A1),(A0)       ;bitplane #1
                move.w  2(A1),8(A0)
                move.w  4(A1),16(A0)
                move.w  6(A1),24(A0)
                move.w  8(A1),32(A0)
                move.w  10(A1),40(A0)
                move.w  12(A1),48(A0)
                move.w  14(A1),56(A0)
                move.w  16(A1),64(A0)
                move.w  18(A1),72(A0)
                move.w  20(A1),80(A0)
                move.w  22(A1),88(A0)
                move.w  24(A1),96(A0)
                move.w  26(A1),104(A0)
                move.w  28(A1),112(A0)
                move.w  30(A1),120(A0)
                move.w  32(A1),128(A0)
                move.w  34(A1),136(A0)
                move.w  36(A1),144(A0)
                move.w  38(A1),152(A0)
                move.w  40(A1),2(A0)    ;bitplane #2
                move.w  42(A1),10(A0)
                move.w  44(A1),18(A0)
                move.w  46(A1),26(A0)
                move.w  48(A1),34(A0)
                move.w  50(A1),42(A0)
                move.w  52(A1),50(A0)
                move.w  54(A1),58(A0)
                move.w  56(A1),66(A0)
                move.w  58(A1),74(A0)
                move.w  60(A1),82(A0)
                move.w  62(A1),90(A0)
                move.w  64(A1),98(A0)
                move.w  66(A1),106(A0)
                move.w  68(A1),114(A0)
                move.w  70(A1),122(A0)
                move.w  72(A1),130(A0)
                move.w  74(A1),138(A0)
                move.w  76(A1),146(A0)
                move.w  78(A1),154(A0)
                move.w  80(A1),4(A0)    ;bitplane #3
                move.w  82(A1),12(A0)
                move.w  84(A1),20(A0)
                move.w  86(A1),28(A0)
                move.w  88(A1),36(A0)
                move.w  90(A1),44(A0)
                move.w  92(A1),52(A0)
                move.w  94(A1),60(A0)
                move.w  96(A1),68(A0)
                move.w  98(A1),76(A0)
                move.w  100(A1),84(A0)
                move.w  102(A1),92(A0)
                move.w  104(A1),100(A0)
                move.w  106(A1),108(A0)
                move.w  108(A1),116(A0)
                move.w  110(A1),124(A0)
                move.w  112(A1),132(A0)
                move.w  114(A1),140(A0)
                move.w  116(A1),148(A0)
                move.w  118(A1),156(A0)
                move.w  120(A1),6(A0)   ;bitplane #4
                move.w  122(A1),14(A0)
                move.w  124(A1),22(A0)
                move.w  126(A1),30(A0)
                move.w  128(A1),38(A0)
                move.w  130(A1),46(A0)
                move.w  132(A1),54(A0)
                move.w  134(A1),62(A0)
                move.w  136(A1),70(A0)
                move.w  138(A1),78(A0)
                move.w  140(A1),86(A0)
                move.w  142(A1),94(A0)
                move.w  144(A1),102(A0)
                move.w  146(A1),110(A0)
                move.w  148(A1),118(A0)
                move.w  150(A1),126(A0)
                move.w  152(A1),134(A0)
                move.w  154(A1),142(A0)
                move.w  156(A1),150(A0)
                move.w  158(A1),158(A0)
                adda.l  #160,A1
                adda.l  #160,A0
                add.w   #1,D0
                cmp.w   #200,D0
                bne     setpic
                move.l  $70,oldvbl
                move    #$2700,SR       ;Interrupts aus
                move.l  #vbl,$70        ;neue Interrupts initialisieren
                move.l  #timer_b,$0120
                clr.b   $FFFFFA07.w
                clr.b   $FFFFFA09.w
                ori.b   #1,$FFFFFA07.w
                ori.b   #1,$FFFFFA13.w
                clr.b   $FFFFFA1B.w
                move    #$2300,SR       ;Interrupts an
                rts                     ;Und tschÅû !

vbl:
                clr.b   $FFFFFA1B.w
                movem.l D0-A6,retteall
                movea.l pal(PC),A0
                movem.l 2(A0),D0-D7
                movem.l D0-D7,$FFFF8240.w
                clr.l   D0
                move.b  35(A0),D0
                divu    #2,D0
                move.b  D0,$FFFFFA21.w
                move.b  35(A0),retted0
                adda.l  #34,A0
                move.l  A0,rettea0
                move.b  #8,$FFFFFA1B.w
                movem.l retteall3(PC),D0-A6
                movea.l mus(PC),A0
                jsr     play(A0)
                movem.l D0-A6,retteall3
                move.l  oldvbl(PC),end_vbl+2
                movem.l retteall(PC),D0-A6
end_vbl:        jmp     $00

timer_b:
                movem.l D0-A0,retteall2
                movem.l rettea0(PC),A0
                movem.l -32(A0),D0-D7
                movem.l D0-D7,$FFFF8240.w
                clr.l   D0
                move.b  35(A0),D0
                sub.b   retted0(PC),D0
                move.b  D0,$FFFFFA21.w
                move.b  35(A0),retted0
                adda.l  #34,A0
                move.l  A0,rettea0
                movem.l retteall2(PC),D0-A0
                bclr    #0,$FFFFFA0F.w
                rte

                DATA
                EVEN
                DS.L 63
retteall:       DS.L 15
rettea0:        DS.L 1
retteall2:      DS.L 9
retteall3:      DS.L 15
res:            DS.W 1
retted0:        DS.B 1
                EVEN
oldvbl:         DS.L 1
grafix:         DS.L 1
pal:            DS.L 1
mus:            DS.L 1

play            EQU $08
                END
