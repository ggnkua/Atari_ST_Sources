***********************
* Yet another intro ! *
*---------------------*
* Idea:      12.10.92 *
* Program:   13.10.92 *
***********************
* Code by:            * - This is a converted Turbo Ass
* =======             * - ASCII Text-file.
* THE ATTACKING SHARK *
*---------------------*
* Gfx by:             *
* ======              *
* A CUP OF TEA        *
***********************
                TEXT
                bra.s   start
                DC.B "This is an ICS-Production (c)'92."
                EVEN
start:
                pea     0.w
                move.w  #$20,-(sp)
                trap    #1
                addq.l  #6,sp
                move.l  d0,-(sp)

                btst    #7,$fffffa01.w
                beq     raus

                move.l  sp,oldstack
                lea     stack,sp
                move    sr,oldsr

                move.b  $ffff8209.w,d0
                btst    #4,d0
                bne.s   other
                moveq   #1,d0
                bsr     music
                bra.s   other2
other:
                moveq   #1,d0
                bsr     music2
                move.l  #music2,musiczeiger
                move.w  #765,timer
other2:
                move    #$2700,sr

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

                bsr     skip_it

                move.b  #2,$ffff820a.w
                move.b  #0,$ffff8260.w

                lea     $ffff8201.w,a0
                movep.w 0(a0),d0
                move.l  d0,old_scr

                move.l  #screen,d0
                clr.b   d0
                movea.l d0,a0
                move.l  a0,screen1

                move.l  screen1(pc),d0
                lsr.l   #8,d0
                lea     $ffff8201.w,a0
                movep.w d0,0(a0)

                bsr     clear_bss

                bsr     plot_ics_logo
                bsr     plotlet
                bsr     fade_cols

                bsr     hbl_on
                bsr     key_check

wait:           bra.s   wait
                bsr     credo
                move.b  $fffffc02.w,d0
                cmp.b   #$39+128,d0
                bne.s   wait

                move.w  #$4e71,fader
                movea.l musiczeiger(pc),a0
                move.w  wert(pc),d0
                jsr     12(a0)

out:            bsr     credo
                bra.s   out

                move    #$2700,sr

                movem.l dummies(pc),d0-d7
                movem.l d0-d7,$ffff8240.w

                moveq   #0,d0
                bsr     music

                bsr     hbl_off

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
raus:
                move.w  #$20,-(sp)
                trap    #1
                addq.l  #6,sp

                clr.w   -(sp)
                trap    #1
vbl:
                clr.b   $fffffa19.w
                move.b  #99,$fffffa1f.w
                move.b  #4,$fffffa19.w
                move.b  #0,$ffff8260.w
                movem.l d0-a6,-(sp)

                movea.w #$fa1b,a0
                clr.b   (a0)
                move.b  #1,6(a0)
                move.b  #8,(a0)

                movea.l musiczeiger(pc),a0
                jsr     8(a0)

                movea.l zeiger(pc),a0
                movem.l (a0)+,d0-d7
                movem.l d0-d7,$ffff8240.w

                bsr     fader

                tst.w   timer
                bne.s   noth
                move.l  #move_data+90,move_tab
                move.l  #230+9*8+6,da+2
noth:           subq.w  #1,timer

                movem.l (sp)+,d0-a6
                rte

oben_auf:       move    #$2100,sr
                stop    #$2100
                move    #$2700,sr
                clr.b   $fffffa19.w
                DCB 3,$4e71
                REPT 11
                move.l  #'ICS!',credits
                ENDR
                move.b  #0,$ffff820a.w
                DCB 4,$4e71
                move.l  #'ICS!',credits
                move.l  #'ICS!',credits
                move.b  #2,$ffff820a.w
leer:           rte

ikbd:
                move    #$2500,sr
                rte

hbl_on:
                lea     $fffffa00.w,a0
                lea     save_reg(pc),a1
                move.l  $68.w,(a1)+
                move.l  $70.w,(a1)+
                move.l  $0118.w,(a1)+
                move.l  $0120.w,(a1)+
                move.l  $0134.w,(a1)+
                move.b  $07(a0),(a1)+
                move.b  $09(a0),(a1)+
                move.b  $0f(a0),(a1)+
                move.b  $11(a0),(a1)+
                move.b  $13(a0),(a1)+
                move.b  $15(a0),(a1)+
                move.b  $17(a0),(a1)+
                move.b  $19(a0),(a1)+
                move.b  $1b(a0),(a1)+
                move.b  $1d(a0),(a1)+
                move.b  $1f(a0),(a1)+
                move.b  $21(a0),(a1)+
                andi.b  #$df,$09(a0)
                andi.b  #$fe,$07(a0)
                ori.b   #$21,$07(a0)
                ori.b   #$21,$13(a0)
                move.l  #leer,$68.w
                move.l  #vbl,$70.w
                move.l  #timerb1,$0120.w
                move.l  #oben_auf,$0134.w
                ori.b   #1,$07(a0)
                ori.b   #1,$13(a0)
                bclr    #5,$09(a0)
                bclr    #6,$09(a0)
                move.l  #ikbd,$0118.w
                bset    #6,$09(a0)
                bset    #6,$15(a0)
                bclr    #3,$17(a0)
                clr.b   $15(a0)
                move    #$2300,sr
                rts

hbl_off:
                lea     save_reg(pc),a0
                lea     $fffffa00.w,a1
                move.l  (a0)+,$68.w
                move.l  (a0)+,$70.w
                move.l  (a0)+,$0118.w
                move.l  (a0)+,$0120.w
                move.l  (a0)+,$0134.w
                move.b  (a0)+,$07(a1)
                move.b  (a0)+,$09(a1)
                move.b  (a0)+,$0f(a1)
                move.b  (a0)+,$11(a1)
                move.b  (a0)+,$13(a1)
                move.b  (a0)+,$15(a1)
                move.b  (a0)+,$17(a1)
                move.b  (a0)+,$19(a1)
                move.b  (a0)+,$1b(a1)
                move.b  (a0)+,$1d(a1)
                move.b  (a0)+,$1f(a1)
                move.b  (a0)+,$21(a1)
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
save_reg:       DC.B 'This is an intro by THE ATTACKIN'
old_pal:        DC.B 'G SHARK!'
                DC.B " (c) by ICS '92."
                DS.W 4
oldstack:       DC.L 0
oldsr:          DC.L 0
old_ikbd:       DC.L 0
old_scr:        DC.L 0
old_res:        DC.B 0
old_sync:       DC.B 0
credits:        DC.L $41434621
wert:           DC.W -1,1
timer:          DC.W 320
                EVEN

screen1:        DC.L screen
musiczeiger:    DC.L music

fader:          nop
                tst.w   time
                beq.s   qw
                subq.w  #1,time
                rts
qw:             subi.l  #32,zeiger
qw2:            cmpi.l  #cols,zeiger
                bne.s   as
                bra.s   qw3
                move.w  #$4e71,out+4
qw3:            move.w  #$4e75,fader
                neg.l   qw+2
                move.l  #music-32,qw2+2
                move.w  #$4e71,qw2+12
                move.w  #1,as+2
                move.w  #$4e71,wait
as:             move.w  #5,time
                rts
zeiger:         DC.L cols+7*32
time:           DC.W 0

plot_ics_logo:  lea     ics_logo(pc),a0
                movea.l screen1(pc),a1
                lea     2*230+9*8(a1),a1

                moveq   #7,d2
dap:            moveq   #3,d1
dopin:          moveq   #30,d0
dope:
dis             SET 0
                REPT 6
                move.l  (a0)+,dis(a1)
                move.w  (a0)+,4+dis(a1)
dis             SET dis+8
                ENDR
                lea     230(a1),a1
                dbra    d0,dope
                lea     6*8-31*230(a1),a1
                lea     ics_logo(pc),a0
                dbra    d1,dopin
                lea     31*230-24*8(a1),a1
                dbra    d2,dap
                rts
ics_logo:
			 INCBIN "ICS_LOGO.B"

plott           EQU 384/8
plotlet:
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
                lea     gfx0(pc),a0
                move.w  pos(pc),d0
                adda.w  d0,a0
                move.l  a2,sprung
                btst    #0,d0
                beq.s   leer2
                addq.w  #1,d0
                bra.s   plot
leer2:          addq.w  #1,d0
plot:           move.w  d0,pos
dis             SET 0
                REPT 8
                move.b  (a1)+,dis(a0)
dis             SET dis+plott
                ENDR
                bra.s   plotlet
nzeil:          move.l  a2,sprung
                addi.w  #plott*7,pos
                bra.s   plotlet
nichts:         lea     gfx(pc),a0
                moveq   #0,d0
                moveq   #11,d1
pop:            move.l  d0,(a0)+
                dbra    d1,pop
                rts
credo:          lea     cred(pc),a0
                movea.l screen1(pc),a1
                adda.l  #252*230+4-4*8-160,a1
                moveq   #4,d0
dis             SET 0
dops:           REPT 8
                move.w  (a0)+,dis(a1)
dis             SET dis+8
                ENDR
                lea     160(a1),a1
                dbra    d0,dops
                rts

pos:            DC.W 0
sprung:         DC.L text
text:
; Don't remove or write anything in the first or last text-line!
; And let one column on the left and right side left!
                DC.B '                                                ',0
                DC.B '       /////\\\\\   /////\\\  /////////         ',0
                DC.B '       \\\\\///// //////     ///                ',0
                DC.B '         \\\///  /////       \\\\\\\\\\\        ',0
                DC.B '         ///\\\  \\\\\\             \\\\\       ',0
                DC.B '       /////\\\\\ \\\\\\//// ////////////       ',0
                DC.B '       \\\\\/////   \\\\\// ///////////         ',0
                DC.B '          presents another hot title:           ',0
                DC.B '                                                ',0
                DC.B '                 XXXXXXXXXXX                    ',0
                DC.B '                                                ',0
                DC.B ' Original by:                       Cracked by: ',0
                DC.B '                                                ',0
                DC.B ' -XXXXX/<=>-            -XXXXXXXXXXXXXXXXX/<=>- ',0
                DC.B '                                                ',0
                DC.B '                  <=> boards:                   ',0
                DC.B '                                                ',0
                DC.B ' ENIGMA              -39 831 312 347-  (ITALY)  ',0
                DC.B ' STAMPEDE            - 1 813 754 0685- (USA)    ',0
                DC.B ' TIME WARP           - 1 717 788 5665- (USA)    ',0
                DC.B ' LAZARUS             - 1 813 933 3729- (USA)    ',0
                DC.B ' THE HAPPY HIDEAWAY  - 1 813 596 4999- (USA)    ',0
                DC.B ' EAGLES NEST         -46 182 628 04-   (SWEDEN) ',0
                DC.B ' SARCASTIC EXISTANCE -46 451 910 02-   (SWEDEN) ',0
                DC.B ' CONSPIRACY          -44 705 819 410-  (U.K.)   ',0
                DC.B '                                                ',0
                DC.B -1
                EVEN
cred:
                INCBIN 'CRED.B'
fontt:
                INCBIN 'FONTT.B'

timerb1:        clr.b   $fffffa1b.w
                move    #$2700,sr
                movem.l d0-d1/a0-a1,-(sp)
                movea.w #$fa21,a0
                move.b  #255,(a0)
                move.b  #8,-6(a0)
                move.b  (a0),d0
warte1:         cmp.b   (a0),d0
                beq.s   warte1
                clr.b   -6(a0)
                movea.w #$8209,a0
                moveq   #80,d1
warte2:         move.b  (a0),d0
                cmp.b   #$40,d0
                beq.s   warte2
                sub.w   d0,d1
                lsl.w   d1,d1
                DCB 2,$4e71
                move.l  #"ICS!",credits
                movea.l screen1(pc),a1
da:             adda.l  #21*230+9*8+6,a1
                moveq   #0,d0
                movea.l move_tab(pc),a0
                move.b  (a0),d0
                mulu    #230,d0
                adda.w  d0,a1
                addq.w  #1,a0
                cmpa.l  #fade_cols,a0
                bcs.s   nicht
                lea     move_data(pc),a0
                move.l  a0,move_tab
                bra.s   nicht2
nicht:          move.l  a0,move_tab
                DCB 2,$4e71
                bra.s   nicht2
                DC.L $28632920
                DC.L $6279204a
                DC.L $41434b59
                DC.W $2100
nicht2:         lea     gfx(pc),a0
                move.b  #0,$ffff820a.w
                move.b  #2,$ffff820a.w
                nop
                move.l  #'ICS!',credits
                move.b  #1,$ffff8260.w
                move.b  #0,$ffff8260.w
                DCB 2,$4e71
                move.l  #'ICS!',credits
                move.b  #2,$ffff8260.w
                move.b  #0,$ffff8260.w
                move.w  #197+27,d0
                nop
dumm:
dis             SET 0
                REPT 21
                move.w  (a0)+,dis(a1)
dis             SET dis+8
                ENDR
                move.b  #0,$ffff820a.w
                move.b  #2,$ffff820a.w
                REPT 2
                move.w  (a0)+,dis(a1)
dis             SET dis+8
                ENDR
                move.b  #1,$ffff8260.w
                move.b  #0,$ffff8260.w
                DCB 3,$4e71
                move.w  (a0)+,dis(a1)
                lea     230(a1),a1
                move.b  #2,$ffff8260.w
                move.b  #0,$ffff8260.w
                dbra    d0,dumm
                DCB 6,$4e71
                REPT 11
                move.l  #'ICS!',credits
                ENDR
                move.b  #0,$ffff820a.w
                DCB 5,$4e71
                move.l  #'ICS!',credits
                move.b  #1,$ffff8260.w
                move.b  #0,$ffff8260.w
                DCB 2,$4e71
                move.l  #'ICS!',credits
                move.b  #2,$ffff8260.w
                move.b  #0,$ffff8260.w
                move.b  #2,$ffff820a.w
                DCB 6,$4e71
                REPT 11
                move.l  #'ICS!',credits
                ENDR
                move.b  #0,$ffff820a.w
                move.b  #2,$ffff820a.w
                nop
                move.l  #'ICS!',credits
                move.b  #1,$ffff8260.w
                move.b  #0,$ffff8260.w
                DCB 2,$4e71
                move.l  #'ICS!',credits
                move.b  #2,$ffff8260.w
                move.b  #0,$ffff8260.w
                moveq   #19,d0
                DCB 2,$4e71
dumm2:          REPT 12
                move.l  #'ICS!',credits
                ENDR
                move.b  #0,$ffff820a.w
                move.b  #2,$ffff820a.w
                nop
                move.l  #'ICS!',credits
                move.b  #1,$ffff8260.w
                move.b  #0,$ffff8260.w
                DCB 2,$4e71
                move.l  #'ICS!',credits
                move.b  #2,$ffff8260.w
                move.b  #0,$ffff8260.w
                dbra    d0,dumm2
                DCB 87-4-(11*7)-4,$4e71
                REPT 11
                move.l  #'ICS!',credits
                ENDR
                move.w  #$0666,$ffff8244.w
                move.b  #0,$ffff820a.w
                move.b  #2,$ffff820a.w
                move    #$2300,sr
                movem.l (sp)+,d0-d1/a0-a1
                rte

move_tab:       DC.L dort

dort:           DS.W 390
move_data:
			 INCBIN "MOVE_DAT.B"

fade_cols:      lea     cols(pc),a0
                lea     32(a0),a1
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
cols:
                DCB 8,$0777
                DC.W $00,$0555,$0222,$01,$0110,$0221,$0332,$0443
                DS.W 7*16

music:          INCBIN 'ENDTHEME.MUS'
music2:         INCBIN 'FEELINGS.MUS'

                BSS
bss_anfang:
gfx:            DS.B plott
gfx0:           DS.B (plott*9)*26
screen:         DS.B 32000*2
bss_ende:
                DS.L 100
stack:
                END
