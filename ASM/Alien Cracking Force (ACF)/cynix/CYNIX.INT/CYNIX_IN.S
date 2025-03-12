**********************************************
*   Intro done from 10th to 15th, nov '92!   *
* by: JACKY of ACF alias THE ATTACKING SHARK *
* and music by: MAD MAX (Amberstar Endtheme) *
******CYNIX-Version on 13th of July '93!******
**********************************************
* Originally coded with Turbo ASS!
                TEXT
start:
                pea     0.w
                move.w  #$20,-(sp)
                trap    #1
                addq.l  #6,sp
                move.l  d0,-(sp)

                move.l  sp,oldstack
                lea     stack,sp
                move    sr,oldsr

                lea     $fffffc02.w,a0
                move.b  #$12,(a0)
                move.b  #$1a,(a0)

                bsr     key_check

                movem.l $ffff8240.w,d0-d7
                movem.l d0-d7,old_pal

                movem.l dummies(pc),d0-d7
                movem.l d0-d7,$ffff8240.w

                move.b  $ffff820a.w,old_sync
                move.b  $ffff8260.w,old_res

                move.l  #screens,d0
                clr.b   d0
                movea.l d0,a0
                movea.l d0,a1
                adda.l  #33536,a1
                move.l  a0,screen1
                move.l  a1,screen2

                bsr     skip_it
                bsr     clear_soundreg

                move.b  #2,$ffff820a.w
                move.b  #0,$ffff8260.w

                lea     $ffff8201.w,a0
                movep.w 0(a0),d0
                move.l  d0,old_scr

                move.l  screen1(pc),d0
                lsr.l   #8,d0
                lea     $ffff8201.w,a0
                movep.w d0,0(a0)

                bsr     clear_bss

                bsr     init_music

                bsr     hbl_on
                bsr     key_check

                bsr     fade_cols
                bsr     plot
                bsr     plotlet
                bsr     init_scroll

wait:           bsr     loch
                bsr     loesch
                bsr     loesch2
                bsr     loesch3
                move.b  $fffffc02.w,d0
                cmp.b   #$39+128,d0
                bne.s   wait

                cmpi.w  #$4e75,mover
                beq.s   out2
                move.w  #$4e71,fod3
out:            bra.s   out
out2:
                move    #$2700,sr

                movem.l dummies(pc),d0-d7
                movem.l d0-d7,$ffff8240.w

                bsr     hbl_off

                move.w  ST_STE(pc),d0
                moveq   #0,d1
                bsr     music+32

                move.b  #2,$ffff820a.w
                bsr     skip_it
                move.b  #0,$ffff820a.w
                bsr     skip_it
                move.b  #2,$ffff820a.w
                bsr     skip_it

                move.b  old_sync(pc),$ffff820a.w
                move.b  old_res(pc),$ffff8260.w

                move.l  old_scr(pc),d0
                lea     $ffff8201.w,a0
                movep.w d0,0(a0)

                movem.l old_pal(pc),d0-d7
                movem.l d0-d7,$ffff8240.w

                lea     $fffffc02.w,a0
                move.b  #$14,(a0)
                move.b  #8,(a0)

                movea.l oldstack(pc),sp
                move    oldsr(pc),sr

                move.w  #$20,-(sp)
                trap    #1
                addq.l  #6,sp

                clr.w   -(sp)
                trap    #1

vbl:
                clr.b   $ffff8260.w
                movem.l d0-d6/a0-a4,-(sp)

                movea.l colo2(pc),a0
                movem.l (a0)+,d0-d6/a1
                movem.l d0-d6/a1,$ffff8240.w

                bsr     mover
                bsr     do_shark
                bsr     plotin
                bsr     fader

                st      flag

                movem.l (sp)+,d0-d6/a0-a4
                rte

ikbd:
                move    #$2500,sr
                rte

hbl_on:
                lea     $fffffa00.w,a0
                lea     save_reg(pc),a1
                move.l  $70.w,(a1)+
                move.l  $0118.w,(a1)+
                move.l  $0120.w,(a1)+
                move.b  $07(a0),(a1)+
                move.b  $09(a0),(a1)+
                move.b  $0f(a0),(a1)+
                move.b  $11(a0),(a1)+
                move.b  $13(a0),(a1)+
                move.b  $15(a0),(a1)+
                move.b  $17(a0),(a1)+
                move.b  $1b(a0),(a1)+
                move.b  $1d(a0),(a1)+
                move.b  $21(a0),(a1)+
                andi.b  #$fe,$07(a0)
                move.l  #vbl,$70.w
                ori.b   #1,$07(a0)
                ori.b   #1,$13(a0)
                bclr    #6,$09(a0)
                move.l  #ikbd,$0118.w
                bset    #6,$09(a0)
                bset    #6,$15(a0)
                bclr    #3,$17(a0)
                move    #$2300,sr
                rts

hbl_off:
                lea     save_reg(pc),a0
                lea     $fffffa00.w,a1
                move.l  (a0)+,$70.w
                move.l  (a0)+,$0118.w
                move.l  (a0)+,$0120.w
                move.b  (a0)+,$07(a1)
                move.b  (a0)+,$09(a1)
                move.b  (a0)+,$0f(a1)
                move.b  (a0)+,$11(a1)
                move.b  (a0)+,$13(a1)
                move.b  (a0)+,$15(a1)
                move.b  (a0)+,$17(a1)
                move.b  (a0)+,$1b(a1)
                move.b  (a0)+,$1d(a1)
                move.b  (a0)+,$21(a1)
                rts

two_screens:
                move.l  screen2(pc),d0
                move.l  screen1(pc),screen2
                move.l  d0,screen1
                move.l  screen1(pc),d0
                lsr.w   #8,d0
                move.b  d0,$ffff8203.w
                swap    d0
                move.b  d0,$ffff8201.w
                rts

clear_soundreg:
                moveq   #10,d0
                lea     $ffff8800.w,a0
clr_sndall:
                move.b  d0,(a0)
                move.b  #0,2(a0)
                dbra    d0,clr_sndall
                move.b  #7,(a0)
                move.b  #$7f,2(a0)
                move.b  #14,(a0)
                move.b  #$26,2(a0)
                rts

key_check:
                btst    #0,$fffffc00.w
                beq.s   key_ok
                move.b  $fffffc02.w,d0
                bra.s   key_check
key_ok:
                rts

skip_it:
                movem.l d0-d1/a0,-(sp)
                lea     $ffff8209.w,a0
                movep.w -8(a0),d0
skip1:
                tst.b   (a0)
                beq.s   skip1
skip2:
                tst.b   (a0)
                bne.s   skip2
                movep.w -4(a0),d1
                cmp.w   d0,d1
                bne.s   skip2
                movem.l (sp)+,d0-d1/a0
                rts

clear_bss:
                lea     bss_anfang,a5
                lea     bss_ende,a6
                movem.l dummies(pc),d0-a4
clear_all_bss:
                movem.l d0-a4,(a5)
                movem.l d0-a4,52(a5)
                movem.l d0-a4,104(a5)
                lea     156(a5),a5
                cmpa.l  a5,a6
                bpl.s   clear_all_bss
                rts

dummies:        DS.W 26
save_reg:       REPT 4
                DC.B "CYNIX"
                ENDR
                DS.W 1
old_pal:        DC.B $41,$43,$46,$21,$20
                DC.B "What a fuckin' intro, eey ?"
oldstack:       DC.L 0
oldsr:          DC.L 0
old_ikbd:       DC.L 0
old_scr:        DC.L 0
old_res:        DC.B 0
old_sync:       DC.B 0
flag:           DC.B 0
                EVEN

screen1:        DC.L 0
screen2:        DC.L 0

fader:          nop
                tst.w   pi
                beq.s   dort
                subq.w  #1,pi
                rts
dort:           subi.l  #32,colo2
bla:            move.w  #2,pi
rt:             cmpi.l  #cols2,colo2
                bne.s   er
                cmpi.l  #cols2+7*32,rt+2
                bne.s   qw
                move.w  #$4e71,loch
                move.w  #$4e75,fader
                rts
qw:             move.w  #1045,pi
                move.l  #cols2+7*32,rt+2
                neg.l   dort+2
                move.w  #4,bla+2
er:             rts
pi:             DC.W 575

loch:           rts
                bsr     wer
                move.w  #$4e75,loch
dad:            lea     with(pc),a0
                movea.l screen1(pc),a1
                movea.l screen2(pc),a2
                lea     75*160+6*8+2(a1),a1
                lea     75*160+6*8+2(a2),a2

                moveq   #47,d0
dop:
dis             SET 0
                REPT 112/16
                move.w  (a0),dis(a1)
                move.w  (a0)+,dis(a2)
dis             SET dis+8
                ENDR
                lea     160(a1),a1
                lea     160(a2),a2
                dbra    d0,dop
                move.w  #$4e71,plotin
                move.l  #cols+7*32,colo2
                rts

fate:           tst.w   poso
                beq.s   wr
                subq.w  #1,poso
                rts
wr:             subi.l  #32,colo2
                move.w  #6,poso
df:             cmpi.l  #cols,colo2
                bne.s   sd
zz:             move.w  #1350,poso
                neg.l   wr+2
                cmpi.l  #cols+7*32,df+2
                bne.s   qws
                move.w  #$4e75,plotin
                move.w  #$4e71,loesch
                move.l  #cols,df+2
                rts
qws:            move.l  #cols+7*32,df+2
sd:             rts
poso:           DC.W 50

anz             EQU 37
plotin:         rts
lo:             bsr.s   fate
                bsr     fod2
                bsr     two_screens
                movea.l screen1(pc),a0
                lea     -27*160(a0),a0
                moveq   #anz-1,d1
                lea     clear_1(pc),a2
                tst.l   var5
                bpl.s   noti
                lea     clear_2(pc),a2
noti:
                moveq   #0,d0
lupin:
                movea.l (a2)+,a1
dis             SET 0
                REPT 16
                move.w  d0,dis(a1)
                move.w  d0,dis+8(a1)
dis             SET dis+160
                ENDR
                dbra    d1,lupin

                moveq   #anz-1,d2
                lea     clear_1(pc),a3
                tst.l   var5
                bpl.s   noti2
                lea     clear_2(pc),a3
noti2:
                lea     movinx(pc),a4
                move.l  var3(pc),d0
                lsl.l   #1,d0
                adda.l  d0,a4
                move.l  a4,var1
                lea     moviny(pc),a4
                move.l  var4(pc),d0
                lsl.l   #1,d0
                adda.l  d0,a4
                move.l  a4,var2
lupin2:
                movea.l var1(pc),a4
                move.w  (a4),d0
                ext.l   d0
                addq.l  #8,var1
                movea.l var2(pc),a4
                move.w  (a4),d1
                ext.l   d1
                addq.l  #4,var2
                movea.l a0,a2
                lsl.l   #5,d1
                adda.l  d1,a2
                lsl.l   #2,d1
                adda.l  d1,a2
                move.l  d0,d1
                andi.l  #-16,d1
                lsr.l   #1,d1
                adda.l  d1,a2
                andi.l  #15,d0
swapp:          lea     cynix_1pl,a1
                lsl.l   #6,d0
                adda.l  d0,a1
dis             SET 0
                REPT 16
                move.l  (a1)+,d0
                or.w    d0,8+dis(a2)
                swap    d0
                or.w    d0,dis(a2)
dis             SET dis+160
                ENDR

                move.l  a2,(a3)+
                dbra    d2,lupin2
                addq.l  #1,var3
                andi.l  #255,var3
                not.l   var5
                rts

var1:           DC.L 0
var2:           DC.L 0
var3:           DC.L 0
var4:           DC.L 92
var5:           DC.L 0
clear_1:        REPT anz
                DC.L screens
                ENDR
clear_2:        REPT anz
                DC.L screens
                ENDR
movinx:
                INCBIN 'MOVINX.B'
moviny:
                INCBIN 'MOVINY.B'

cynix_1pl:      INCBIN 'CYNIX1PL.B'
cynix_2pl:      INCBIN 'CYNIX2PL.B'
pre:            INCBIN 'PRE.B'
with:           INCBIN 'WITH.B'

clear_screens:
                movea.l screen1(pc),a0
                movea.l screen2(pc),a1
                move.w  #8000-1,d0
                moveq   #0,d1
clr:
                move.l  d1,(a0)+
                move.l  d1,(a1)+
                dbra    d0,clr
                rts

loesch:         rts
                move.w  #$4e75,loesch
                move.w  #$4e71,do_shark
                move.l  #cols3+7*32,colo2
wer:
                bra.s   clear_screens
loesch2:        rts
                bsr.s   clear_screens

                lea     pre(pc),a0
                movea.l screen1(pc),a1
                movea.l screen2(pc),a2
                lea     87*160+6*8+2(a1),a1
                lea     87*160+6*8+2(a2),a2
                moveq   #25,d0
dop3:
dis             SET 0
                REPT 128/16
                move.w  (a0),dis(a1)
                move.w  (a0)+,dis(a2)
dis             SET dis+8
                ENDR
                lea     160(a1),a1
                lea     160(a2),a2
                dbra    d0,dop3

                move.w  #$4e71,d0
                move.w  #$4e75,loesch2
                move.w  d0,lo
                move.w  d0,plotin
                move.l  #cols+7*32,colo2
                move.w  d0,fod2
                rts

loesch3:        rts
                move.w  #$4e75,loesch3
                bsr     clear_screens
                bsr     plot
                movea.l screen2(pc),a1
                bsr     plot2
                move.w  #$4e71,mover
                rts

fod:            tst.w   pol
                beq.s   era
                subq.w  #1,pol
                rts
era:            subi.l  #32,colo2
                move.w  #6,pol
sdu:            cmpi.l  #cols3,colo2
                bne.s   ol
uu:             move.w  #900,pol
                neg.l   era+2
                cmpi.l  #cols3+7*32,sdu+2
                bne.s   qwa
                move.w  #$4e75,do_shark
                move.w  #$4e71,loesch2
                rts
qwa:            move.l  #cols3+7*32,sdu+2
ol:             rts
pol:            DC.W 55

do_shark:       rts
                bsr.s   fod
do_s:           tst.w   pol
                beq.s   yx
do_p:           rts
yx:             move.w  #$4e71,do_p
                bsr     two_screens
                lea     shark(pc),a3
                movea.l screen1(pc),a4
                lea     199*160+5*8(a4),a4
                suba.w  wert(pc),a4

                addi.w  #160,wert

                cmpi.w  #160*133,wert
                bne.s   asd2
                move.w  #$4e75,do_s
asd2:
                cmpi.w  #160*61,wert
                bne.s   asd
                clr.w   asd+2
                move.l  #cynix_2pl,swapp+2
asd:
                addq.w  #1,dd+2
dd:             move.w  #0,d0
dopi:
                movem.l (a3)+,d1-d6/a0-a2
                movem.l d1-d6/a0-a2,(a4)
                movem.l (a3)+,d1-d6/a0-a2
                movem.l d1-d6/a0-a2,36(a4)
                movem.l (a3)+,d1-d2
                movem.l d1-d2,36*2(a4)
                lea     160(a4),a4
                dbra    d0,dopi
                rts
wert:           DC.W 0
shark:          INCBIN 'SHARK.B'
                DS.W 120

fod2:           rts
                tst.w   pop
                beq.s   as
                subq.w  #1,pop
                rts
as:             subi.l  #32,colo2
                move.w  #6,pop
tz:             cmpi.l  #cols,colo2
                bne.s   we
                cmpi.l  #cols+7*32,tz+2
                bne.s   we0
                move.w  #$4e75,plotin
                move.w  #$4e71,loesch3
                move.l  #cols4+7*32,colo2
we0:            move.w  #800,pop
                neg.l   as+2
                move.l  #cols+7*32,tz+2
we:             rts
pop:            DC.W 50

fod3:           nop
                tst.w   log
                beq.s   yxx
                subq.w  #1,log
                rts
yxx:            subi.l  #32,colo2
xy:             move.w  #5,log
asde:           cmpi.l  #cols4,colo2
                bne.s   sdz
                move.w  #2,xy+2
                cmpi.l  #cols4+7*32,asde+2
                bne.s   asz0
                move.w  #$4e71,out
asz0:           move.l  #cols4+7*32,asde+2
                move.w  #$4e75,fod3
                neg.l   yxx+2
sdz:            rts
log:            DC.W 110

zeil            EQU 17
mover:          rts
                bsr.s   fod3
                bsr     two_screens
                movea.l screen1(pc),a1
                lea     2+8+160*2(a1),a1
                movea.l move_tab(pc),a0
                move.b  (a0),d0
                mulu    #160,d0
                adda.w  d0,a1
                addq.w  #1,a0
                cmpa.l  #plotlet,a0
                bcs.s   nich
                lea     move_data(pc),a0
nich:           move.l  a0,move_tab

                moveq   #0,d0
                moveq   #1,d1
dou:            move.w  d0,(a1)
                move.w  d0,8(a1)
                move.w  d0,16(a1)
                move.w  d0,24(a1)
                move.w  d0,32(a1)
                move.w  d0,40(a1)
                move.w  d0,48(a1)
                move.w  d0,56(a1)
                move.w  d0,64(a1)
                move.w  d0,72(a1)
                move.w  d0,80(a1)
                move.w  d0,88(a1)
                move.w  d0,96(a1)
                move.w  d0,104(a1)
                move.w  d0,112(a1)
                move.w  d0,120(a1)
                move.w  d0,128(a1)
                move.w  d0,136(a1)
                lea     160(a1),a1
                dbra    d1,dou

                lea     la,a0
                move.w  #(9*zeil)-2,d1
dou2:           move.w  (a0)+,(a1)
                move.w  (a0)+,8(a1)
                move.w  (a0)+,16(a1)
                move.w  (a0)+,24(a1)
                move.w  (a0)+,32(a1)
                move.w  (a0)+,40(a1)
                move.w  (a0)+,48(a1)
                move.w  (a0)+,56(a1)
                move.w  (a0)+,64(a1)
                move.w  (a0)+,72(a1)
                move.w  (a0)+,80(a1)
                move.w  (a0)+,88(a1)
                move.w  (a0)+,96(a1)
                move.w  (a0)+,104(a1)
                move.w  (a0)+,112(a1)
                move.w  (a0)+,120(a1)
                move.w  (a0)+,128(a1)
                move.w  (a0)+,136(a1)
                lea     160(a1),a1
                dbra    d1,dou2

                moveq   #1,d1
dou3:           move.w  d0,(a1)
                move.w  d0,8(a1)
                move.w  d0,16(a1)
                move.w  d0,24(a1)
                move.w  d0,32(a1)
                move.w  d0,40(a1)
                move.w  d0,48(a1)
                move.w  d0,56(a1)
                move.w  d0,64(a1)
                move.w  d0,72(a1)
                move.w  d0,80(a1)
                move.w  d0,88(a1)
                move.w  d0,96(a1)
                move.w  d0,104(a1)
                move.w  d0,112(a1)
                move.w  d0,120(a1)
                move.w  d0,128(a1)
                move.w  d0,136(a1)
                lea     160(a1),a1
                dbra    d1,dou3
                bra     plscroll
move_tab:
                DC.L move_data
move_data:
                INCBIN 'MOVEDATA.B'

flott           EQU 288/8
plotlet:
                lea     la,a0
                moveq   #-1,d0
                move.w  #zeil*(flott*10),d1
poin:           move.b  d0,(a0)+
                dbra    d1,poin
plotlet2:
                movea.l sprung(pc),a2
                moveq   #0,d0
                move.b  (a2)+,d0
                beq.s   nzeil
                bmi.s   nichts
dow:
                sub.b   #32,d0
                lsl.w   #3,d0
                lea     fontt(pc),a1
                adda.w  d0,a1
                lea     la,a0
                move.w  pos(pc),d0
                adda.w  d0,a0
                move.l  a2,sprung
                btst    #0,d0
                beq.s   leer2
                addq.w  #1,d0
                bra.s   flot
leer2:          addq.w  #1,d0
flot:           move.w  d0,pos
dis             SET 0
                REPT 8
                move.b  (a1)+,dis(a0)
dis             SET dis+flott
                ENDR
                bra.s   plotlet2
nzeil:          move.l  a2,sprung
                addi.w  #flott*8,pos
                bra.s   plotlet2
nichts:         rts

pos:            DC.W 0
sprung:         DC.L text
text:
                DC.B '<                                  =',0
                DC.B "  Another game released by Cynix!!  ",0
                DC.B '                                    ',0
                DC.B '               called:              ',0
                DC.B '                                    ',0
                DC.B ' ********************************** ',0
                DC.B ' *                                * ',0
                DC.B ' *          N O   N A M E         * ',0
                DC.B ' *                                * ',0
                DC.B ' ********************************** ',0
                DC.B '                                    ',0
                DC.B '   Cracked by XXXXXXXXXXXXXXXXXXX   ',0
                DC.B '                                    ',0
                DC.B '    Original supply by XXXXXXXXX    ',0
                DC.B '                                    ',0
                DC.B ' Watch out for other Cynix-cracks ! ',0
                DC.B '_                                  >',0
                DC.B -1
                EVEN
fontt:
                INCBIN 'FONTT.B'

high            EQU 8
init_scroll:    lea     scr_text(pc),a0
                move.l  a0,varie2
                move.l  a0,varie3
wieder:         moveq   #0,d0
                move.b  (a0),d0
                bmi.s   end_ini
                lea     fonttab(pc),a1
zur:            move.b  (a1)+,d1
                bmi.s   weier
                cmp.b   d1,d0
                bne.s   zur
                move.l  a1,d0
                subi.l  #fonttab+1,d0
                move.b  d0,(a0)+
                bra.s   wieder
weier:          clr.b   (a0)+
                bra.s   wieder
end_ini:        clr.l   scrshift
                rts
fonttab:
                DC.B ' !"#$%&'
                DC.B "'()*+,-./0123456789:;<=>?"
                DC.B "@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\]"
                DC.B "^_`abcdefghijklmnopqrstuvwxyz"
                DC.B -1
                EVEN
plscroll:
                move.w  scrshift(pc),d1
                lea     scrbuffer,a0
                move.w  d1,d0
                mulu    #320,d0
                adda.w  d0,a0
                adda.w  varie(pc),a0
                movea.l screen1(pc),a1
                lea     4+192*160(a1),a1
                moveq   #high-1,d0
looping:
                REPT 20
                move.b  (a0)+,(a1)+
                move.b  (a0)+,(a1)+
                addq.w  #6,a1
                ENDR
                lea     40(a0),a0
                dbra    d0,looping
                movea.l varie2(pc),a2
                clr.w   d0
                move.b  (a2)+,d0
                asl.w   #3,d0
                lea     font+256(pc),a4
                adda.w  d0,a4
                clr.w   d0
                move.b  (a2),d0
                bpl.s   weier2
                movea.l varie3(pc),a2
                move.b  (a2),d0
weier2:
                asl.w   #3,d0
                lea     font+256(pc),a1
                adda.w  d0,a1
                move.w  scrshift(pc),d1
                lea     scrbuffer,a0
                move.w  d1,d0
                mulu    #320,d0
                adda.w  d0,a0
                adda.w  varie(pc),a0
dis             SET 0
dis2            SET 0
                REPT 8
                movep.w dis(a1),d0
                move.b  (a4)+,d0
                rol.w   d1,d0
                move.b  d0,dis2(a0)
                move.b  d0,40+dis2(a0)
dis             SET dis+1
dis2            SET dis2+80
                ENDR
                addq.w  #2,scrshift
                andi.w  #7,scrshift
                bne.s   end_scroll
                move.l  a2,varie2
                addq.w  #1,varie
                cmpi.w  #40,varie
                bcs.s   end_scroll
                clr.w   varie
end_scroll:     rts

scr_text:       DC.B '                Intro by The Attacking Shark/Cynix aka Jacky of The ACF Design Team - Nov. 92'
                DC.B '                                 '
                DC.B -1
                EVEN

scrshift:       DC.W 0
varie:          DC.W 0
varie2:         DC.L 0
varie3:         DC.L 0
font:
                INCBIN 'VIP.FNT'

fade_cols:      lea     cols(pc),a0
                bsr.s   sde
                lea     cols2(pc),a0
                bsr.s   sde
                lea     cols3(pc),a0
                bsr.s   sde
                lea     cols4(pc),a0
sde:            lea     32(a0),a1
                moveq   #6,d5
loop_cols1:
                moveq   #15,d6
loop_cols2:
                move.w  (a0)+,d0
                move.w  d0,d1
                and.w   #$0700,d1
                beq.s   loop_cols3
                sub.w   #$0100,d0
loop_cols3:
                move.w  d0,d1
                and.w   #$70,d1
                beq.s   loop_cols4
                sub.w   #$10,d0
loop_cols4:
                move.w  d0,d1
                and.w   #7,d1
                beq.s   loop_cols5
                subq.w  #1,d0
loop_cols5:
                move.w  d0,(a1)+
                dbra    d6,loop_cols2
                dbra    d5,loop_cols1
                rts

colo2:          DC.L cols2+7*32
cols:           DC.W $0666,$0555,$0777,$0666
                DS.W 12
                DS.W 7*16
cols2:          DC.W $0666,$0555
                DS.W 14
                DS.W 7*16
cols3:          DC.W $02,$0777,$0223,$0334,$0445,$0556,$0667,$0fff
                DC.W $0210,$0321,$0432,$0543,$0112,$0135,$0246,$03df
                DS.W 7*16
cols4:          DC.W $0666,$0555,$0777,$0666,$0666,$0666,$0777,$0666
                DS.W 16-8
                DS.W 7*16

plot:           movea.l screen1(pc),a1
plot2:          lea     pic(pc),a0

                move.w  #199,d0
dop2:
dis             SET 0
                REPT 20
                move.w  (a0)+,dis(a1)
dis             SET dis+8
                ENDR
                lea     160(a1),a1
                dbra    d0,dop2
                rts
pic:            INCBIN 'CYNIX.B'

init_music:     move    sr,d0
                move    #$2700,sr
                move.w  #1,ST_STE
                movea.l 8.w,a5
                movea.l sp,a6
                move.l  #not_STE,8.w
                tst.w   $ffff8900.w
                beq.s   not_STE
                clr.w   ST_STE
                move.w  #33,d1
                sub.w   d1,pi
                sub.w   d1,qw+2
                subi.w  #30,zz+2
                subi.w  #36,poso
                sub.w   d1,uu+2
                sub.w   d1,pol
                sub.w   d1,we0+2
                sub.w   d1,pop
not_STE:        movea.l a6,sp
                move.l  a5,8.w
                move    d0,sr

                lea     music(pc),a3
                movea.l 2(a3),a0
                adda.l  6(a3),a0
                adda.l  14(a3),a0
                lea     28(a0,a3.l),a0
                lea     28(a3),a3
                move.l  a3,d0
                tst.l   (a0)
                beq.s   end_init_music
                adda.l  (a0)+,a3
                moveq   #0,d1
init_music2:
                add.l   d0,(a3)
init_music3:
                move.b  (a0)+,d1
                beq.s   end_init_music
                cmpi.b  #1,d1
                bne.s   init_music4
                lea     254(a3),a3
                bra.s   init_music3
init_music4:
                adda.l  d1,a3
                bra.s   init_music2
end_init_music:
                move.w  ST_STE(pc),d0
                moveq   #0,d1
                bra.s   music+28

ST_STE:         DC.W 0
music:          INCBIN 'MUSIC.B'

                BSS
bss_anfang:
scrbuffer:      DS.W high*160
la:             DS.B zeil*(flott*10)
                DS.B 230*2
screens:        DS.B 67072
bss_ende:
                DS.L 100
stack:
                END
