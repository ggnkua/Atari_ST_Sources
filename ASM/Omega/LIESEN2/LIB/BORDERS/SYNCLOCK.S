; *************************************
; ** Synclock scroller
; ** By Martin Liesen 1991
; *************************************
                >PART 'CALL SUPER PART'
                pea     begin(PC)
                move.w  #38,-(A7)
                trap    #14
                addq.l  #6,A7
                clr.w   -(A7)
                trap    #1
                ENDPART
begin:          >PART 'SAVE REGISTER'
                lea     savetab(PC),A6
                move.l  A7,(A6)+
                lea     stack,A7
                move.b  $FFFFFA07.w,(A6)+
                move.b  $FFFFFA09.w,(A6)+
                move.b  $FFFFFA0F.w,(A6)+
                move.b  $FFFFFA11.w,(A6)+
                move.b  $FFFFFA13.w,(A6)+
                move.b  $FFFFFA15.w,(A6)+
                move.l  $68.w,(A6)+
                move.l  $70.w,(A6)+
                move.l  $0120.w,(A6)+
                move.w  #4,-(A7)
                trap    #14
                move.w  D0,(A6)+
                move.w  #2,-(A7)
                trap    #14
                move.l  D0,(A6)+
                movem.l $FFFF8240.w,D0-D7
                movem.l D0-D7,(A6)
                lea     32(A6),A6
                bra.s   startsynclock
                ENDPART
                >PART 'CLEAR BUFFERT'
                lea     minne(PC),A0
                lea     minneend,A1
                moveq   #0,D0
                moveq   #0,D1
                moveq   #0,D2
                moveq   #0,D3
                moveq   #0,D4
                moveq   #0,D5
                moveq   #0,D6
                moveq   #0,D7
rensa:          movem.l D0-D7,-(A1)
                cmpa.l  A0,A1
                bne.s   rensa
                ENDPART
back:           >PART 'RESTORE AND RTS'
                move    #$2700,SR
                lea     savetab(PC),A6
                movea.l (A6)+,A7
                move.b  (A6)+,$FFFFFA07.w
                move.b  (A6)+,$FFFFFA09.w
                move.b  (A6)+,$FFFFFA0F.w
                move.b  (A6)+,$FFFFFA11.w
                move.b  (A6)+,$FFFFFA13.w
                move.b  (A6)+,$FFFFFA15.w
                move.l  (A6)+,$68.w
                move.l  (A6)+,$70.w
                move.l  (A6)+,$0120.w
                move.w  (A6)+,-(A7)
                move.l  (A6),-(A7)
                move.l  (A6)+,-(A7)
                move.w  #5,-(A7)
                trap    #14
                lea     12(A7),A7
                movem.l (A6)+,D0-D7
                movem.l D0-D7,$FFFF8240.w
                rts
                ENDPART

startsynclock:  >PART 'MAKE FILL'
                moveq   #0,D0
                moveq   #0,D1
                moveq   #0,D2
                lea     col1(PC),A0
                lea     col2(PC),A1
                lea     col3(PC),A2
                lea     colcool(PC),A3
                moveq   #15,D6
koolta:         moveq   #15,D7
koolt:          move.w  0(A0,D0.w),D3
                addq.w  #2,D0
                and.w   #$1E,D0
                or.w    0(A2,D2.w),D3
                addq.w  #2,D2
                and.w   #$1E,D2
                or.w    0(A1,D1.w),D3
                move.w  D3,(A3)+
                dbra    D7,koolt
                addq.w  #2,D1
                and.w   #$1E,D1
                addq.w  #2,D2
                and.w   #$1E,D2
                dbra    D6,koolta
                ENDPART
                >PART 'FIXA SINUS'
                lea     sinusen(PC),A0
                move.w  #1023,D0
fixing:         andi.w  #$FF00,(A0)+
                dbra    D0,fixing
                ENDPART
                >PART 'FIX FONT'
                lea     fonten(PC),A0
                lea     font(PC),A1

                moveq   #59,D1
floop2:         lea     colcool(PC),A3
                lea     fulpal(PC),A5
                movea.l A1,A2
                moveq   #15,D0
floop1:         move.w  (A2),D7
                movea.l A5,A4
                addq.l  #2,A5

                moveq   #15,D4
rotat:          move.w  (A4)+,D5
                move.w  (A3)+,D6
                rol.w   #1,D7
                bcc.s   nixtan
                exg     D6,D5
nixtan:         move.w  D5,(A0)+
                dbra    D4,rotat
                lea     120(A2),A2
                dbra    D0,floop1

                addq.l  #2,A1
                dbra    D1,floop2

                ENDPART
                >PART 'FIX BACKGROUND'
                lea     fulpal(PC),A6
                lea     colbuf-(56*256)+16,A0
                moveq   #0,D6
                moveq   #30,D5
ork2:           moveq   #127,D7

ork1:           move.w  0(A6,D6.w),D0
                moveq   #13,D3
hej:            move.w  D0,(A0)
                lea     256(A0),A0
                dbra    D3,hej

                lea     (-14*256)+2(A0),A0
                addq.w  #2,D6
                and.w   #$1F,D6
                dbra    D7,ork1

                lea     13*256(A0),A0
                addq.w  #2,D6
                and.w   #$1F,D6
                dbra    D5,ork2

                ENDPART
                >PART 'SETUP'

                lea     xadd(PC),A0
                move.l  #380*256,(A0)

                lea     sinpek(PC),A0
                move.w  #800,(A0)
                lea     drawpek(PC),A0
                lea     fonten(PC),A1
                move.l  A1,(A0)
                lea     newchar(PC),A0
                clr.w   (A0)
                lea     colours+32,A0
                lea     scrollpek(PC),A1
                move.l  A0,(A1)
                lea     scrolltext(PC),A0
                lea     textpek(PC),A1
                move.l  A0,(A1)

                move.l  #skarm,D0
                and.l   #$FFFFFF00,D0
                lea     screen(PC),A1
                move.l  D0,(A1)
                moveq   #0,D1
                move.w  #270*40,D0
                movea.l screen(PC),A0
rensar:         move.l  D1,(A0)+
                dbra    D0,rensar
                move.b  screen+1(PC),$FFFF8201.w
                move.b  screen+2(PC),$FFFF8203.w

                lea     dummyvbl(PC),A0 ; set vbl
                move.l  A0,$70.w
                move.w  #0,-(A7)        ; set rez
                pea     -1
                pea     -1
                move.w  #5,-(A7)
                trap    #14
                lea     12(A7),A7

                lea     vbl(PC),A0      ; set vbl
                move.l  A0,$70.w
                lea     hbl(PC),A0      ; set hbl
                move.l  A0,$68.w

                move.b  #0,$FFFFFA07.w  ; set timers
                move.b  #0,$FFFFFA09.w
                move.b  #1,$FFFFFA07.w
                move.b  #1,$FFFFFA13.w
                ENDPART
                >PART 'WAITFORKEY'
stopit:         move    #$2300,SR
                cmpi.b  #$39,$FFFFFC02.w ; wait for space
                bne.s   stopit
                bra     back
                ENDPART
                >PART 'VBL'
; *****************************************
; *   V  B  L
; *****************************************
vbl:
                movem.l D0-A6,-(A7)
                move    #$2300,SR
                clr.w   $FFFF8240.w


                lea     lines(PC),A0    ; counter for HBL
                move.w  #33,(A0)

                move    #$2100,SR

                addi.w  #12,sinpek      ; move sinus pointer
                andi.w  #$07FE,sinpek
                lea     scrollpek(PC),A0 ; move scroll pointer
                addi.l  #2,(A0)
                cmpi.l  #colours+128+32,(A0)
                bne.s   surehey
                move.l  #colours+32,(A0)
surehey:

                subq.w  #1,newchar      ; new character ??
                bpl.s   no_new
                move.w  #15,newchar
                movea.l textpek(PC),A0
                moveq   #0,D0
                move.b  (A0)+,D0
                cmp.b   #32,D0
                bhs.s   okin
                cmp.b   #1,D0
                bne.s   not1
                move.w  #1,doing
                bra.s   yepp
not1:           cmp.b   #2,D0
                bne.s   not2
                move.w  #2,doing
                bra.s   yepp
not2:           cmp.b   #3,D0
                beq     synclockover
                lea     scrolltext(PC),A0
yepp:           move.b  (A0)+,D0
okin:           move.l  A0,textpek
                sub.w   #32,D0
                lsl.w   #8,D0
                add.l   D0,D0
                lea     fonten(PC),A1
                lea     0(A1,D0.w),A1
                move.l  A1,drawpek
no_new:

                movea.l drawpek(PC),A1
                addi.l  #2,drawpek
                movea.l scrollpek(PC),A0
                lea     92*256(A0),A0
                moveq   #14,D6
runne2:
                move.w  (A1),D0
                REPT 2
                move.w  D0,96(A0)
                move.w  D0,-32(A0)
                move.w  D0,1*256+96(A0)
                move.w  D0,1*256-32(A0)
                move.w  D0,2*256+96(A0)
                move.w  D0,2*256-32(A0)
                move.w  D0,3*256+96(A0)
                move.w  D0,3*256-32(A0)
                move.w  D0,4*256+96(A0)
                move.w  D0,4*256-32(A0)
                move.w  D0,5*256+96(A0)
                move.w  D0,5*256-32(A0)
                move.w  D0,6*256+96(A0)
                move.w  D0,6*256-32(A0)
                lea     7*256(A0),A0
                ENDR
                lea     32(A1),A1
                dbra    D6,runne2



stopad:         bra.s   stopad

resume:         move    #$2700,SR

waitscreen:     move.b  $FFFF8209.w,D0
                beq.s   waitscreen
                not.w   D0
                lsl.b   D0,D0
                lea     $FFFF8240.w,A6
                movea.l scrollpek(PC),A5
                moveq   #0,D0
                move.w  sinpek(PC),D0
                lea     sinusen(PC),A0
                move.w  0(A0,D0.w),D0
                and.l   #$FFFF,D0
                add.l   xadd(PC),D0
                adda.l  D0,A5
                move.w  #265,D0
                DS.W 60-10,$4E71
loop:           REPT 40
                move.w  (A5)+,(A6)
                ENDR
                nop
                nop
                nop
                lea     256-80(A5),A5
                dbra    D0,loop



                cmpi.w  #1,doing        ; flytta in och ut
                bne.s   oops
                subi.l  #2*256,xadd
                bpl.s   oops
                move.l  #0,xadd
                clr.w   doing
oops:           cmpi.w  #2,doing
                bne.s   oops2
                subi.l  #5*256,xadd
                cmpi.l  #-400*256,xadd
                bhi.s   oops2
                move.l  #-400*256,xadd
                clr.w   doing
oops2:


                movem.l (A7)+,D0-A6
dummyvbl:       addq.l  #1,$0466.w
                rte
                ENDPART
                >PART 'HBL'
********************************************
**      HBL
********************************************
hbl:            move    #$2700,SR
                subq.w  #1,lines
                bpl     NOTY

                DS.W 84,$4E71
                move.b  #0,$FFFF820A.w
                DS.W 12,$4E71
                move.b  #2,$FFFF820A.w
                move.w  #$FF,lines
                lea     6(A7),A7
                bra     resume
NOTY:           rte
                ENDPART
                >PART 'DATA'
scrolltext:     DC.B " ",1,"         PRESENTS:   ",2
                DC.B "     ",3
                EVEN
doing:          DS.W 1
xadd:           DS.L 1
sinpek:         DS.W 1
drawpek:        DS.L 1
newchar:        DS.W 1
scrollpek:      DS.L 1
textpek:        DS.L 1
screen:         DS.L 1
savetab:        DS.L 64
lines:          DS.W 1
colcool:        DS.W 16*16,4    ; Tabell med font f„rgerna
fulpal:         DC.W $08,$01,$09,$02,$0A,$03,$0B,$04,$04,$0B,$03,$0A,$02,$09,$01,$08
                DC.W $08,$01,$09,$02,$0A,$03,$0B,$04,$04,$0B,$03,$0A,$02,$09,$01,$08
col1:           DC.W $00,$08,$01,$09,$02,$0A,$03,$0B,$04,$0C,$05,$0D,$06,$0E,$07,$0F
col2:           DC.W $40,$50,$60,$70,$70,$60,$50,$40,$30,$20,$10,$00,$00,$10,$20,$30
col3:           DC.W $0700,$0600,$0500,$0400,$0300,$0200,$0100,$00,$00,$0100,$0200,$0300,$0400,$0500,$0600,$0700


                PATH '\DATA'
font:           IBYTES 'ALTAFONT.RAW'
                EVEN
sinusen:        IBYTES 'SYNCSIN.IMG'
                ENDPART
synclockover:   >PART 'DONE WITH DIS'
                bra     back
                ENDPART

                >PART 'BUFFRAR'
                BSS
minne:          DS.B 350*1024
minneend:       DS.B 1024
stack:
                ENDPART

                >PART 'SYNCLOCK MINNE'
fonten          EQU minne
colours         EQU minne+(130*1024)
colbuf          EQU colours+(48*256)
skarm           EQU minne+(290*1024)
                ENDPART
                END
