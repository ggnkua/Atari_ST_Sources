; *************************************
; ** 2bit cheat dist with raster pattern
; ** By Martin Liesen 1991
; *************************************
                OPT P-
                PATH 'D:\LIESEN\ASM\DISTIT'

x               EQU 80
h”jd            EQU (77+6+4)
bred            EQU 96
logosize        EQU (h”jd+1)*bred
speed           EQU 2

                >PART 'CALL SUPER PART'
                pea     begin(PC)
                move.w  #38,-(A7)
                trap    #14
                addq.l  #6,A7
                clr.w   -(A7)
                trap    #1
                ENDPART
begin:          >PART 'SAVE REGISTERS'
****************************************
**   S A V E    R E G I S T E R S
****************************************
                lea     savetab(PC),A6
                move.l  A7,(A6)+
                move.l  $00000070.w,(A6)+
                move.l  $00000120.w,(A6)+
                move.b  $FFFFFA07.w,(A6)+
                move.b  $FFFFFA09.w,(A6)+
                move.b  $FFFFFA0F.w,(A6)+
                move.b  $FFFFFA11.w,(A6)+
                move.b  $FFFFFA13.w,(A6)+
                move.b  $FFFFFA15.w,(A6)+
                move.l  $00000068.w,(A6)+
                move.l  $00000070.w,(A6)+
                move.l  $00000118.w,(A6)+
                move.l  $00000120.w,(A6)+
                move.w  #4,-(A7)
                trap    #14
                move.w  D0,(A6)+
                move.w  #2,-(A7)
                trap    #14
                move.l  D0,(A6)+
                movem.l $FFFF8240.w,D0-D7
                movem.l D0-D7,(A6)
                lea     32(A6),A6
                bra.s   startup
                ENDPART
back:           >PART 'RESTORE AND RTS'
******************************************
*** R E S T O R E   E V E R Y T H I N G
******************************************
                move    #$2700,SR
                lea     savetab(PC),A6
                movea.l (A6)+,A7
                move.l  (A6)+,$00000070.w
                move.l  (A6)+,$00000120.w
                move.b  (A6)+,$FFFFFA07.w
                move.b  (A6)+,$FFFFFA09.w
                move.b  (A6)+,$FFFFFA0F.w
                move.b  (A6)+,$FFFFFA11.w
                move.b  (A6)+,$FFFFFA13.w
                move.b  (A6)+,$FFFFFA15.w
                move.l  (A6)+,$00000068.w
                move.l  (A6)+,$00000070.w
                move.l  (A6)+,$00000118.w
                move.l  (A6)+,$00000120.w
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
startup:

                >PART 'CHANGE LOGO LAYOUT'
                lea     logo(PC),A0
                lea     scr1(PC),A1
                moveq   #15,D0
ch1:            movea.l A0,A2
                addq.l  #8,A0
                moveq   #h”jd-1,D1
ch2:            move.l  (A2),(A1)+
                move.w  4(A2),(A1)+
                lea     128(A2),A2
                dbra    D1,ch2
                dbra    D0,ch1

                lea     scr1(PC),A0
                lea     logo(PC),A1
                move.w  #(h”jd*96/4)-1,D0
ch3:            move.l  (A0)+,(A1)+
                dbra    D0,ch3
                ENDPART

                >PART 'FIX MULUS'

                lea     kurvan(PC),A0
jehovas:        move.w  (A0),D0
                mulu    #20,D0
                move.w  D0,(A0)+
                move.w  (A0),D0
                lsl.w   #2,D0
                move.w  D0,(A0)+
                cmpa.l  #slutkurvan,A0
                bne.s   jehovas

                ENDPART

                >PART 'F™R BERŽKNING BLŽŽŽŽ'

                lea     logos,A0
                lea     yepp(PC),A1

looping:
                cmpi.w  #$0080,(A1)
                beq     donenow


                moveq   #7,D7
                move.l  #$C000C000,D5
rotat:
                moveq   #0,D0
                move.w  (A1)+,D0
                mulu    #6,D0

                lea     logo(PC),A3
                movea.l A0,A5
                adda.w  D0,A5
                move.w  #((h”jd*bred)/64)-1,D6

height:         REPT 16
                move.l  (A3)+,D1
                and.l   D5,D1
                or.l    D1,(A5)+
                ENDR
                dbra    D6,height

                lsr.l   #2,D5
                dbra    D7,rotat

                lea     5*6+2(A5),A5
                movea.l A0,A3           ; thoos lines to fullfill the undrawn
                moveq   #7,D6           ; areas at the begining and at the end.
muppfel:        move.l  #0,-(A5)        ; this is becouse of the fact that
                move.w  #-1,-(A5)       ; the program would "rather have" the
                move.l  #$FFFF0000,(A3)+ ; maximum delta per 16 in extra height.
                move.w  #0,(A3)+        ; on the logo, but I don't, and this
                move.w  #$0000,4(A3)    ; works fine on this logo.....
                dbra    D6,muppfel

                lea     logosize(A0),A0
                bra     looping

donenow:
                ENDPART

                >PART 'CALCULATE DRAW'
                lea     drawhim(PC),A0
                moveq   #94,D7
                moveq   #0,D0
                move.w  #((95*2)-1)*160,D1
loopa1:
                movea.l A0,A2
                lea     mall(PC),A1
                move.w  (A1)+,(A0)+     ; move.l (a5)+,d0
                move.w  (A1)+,(A0)+     ; move.w (a5)+,d1
                move.l  (A1)+,(A0)+     ; move.l d0,0*160(a6)
                move.l  (A1)+,(A0)+     ; move.w d1,0*+4160(a6)
                move.l  (A1)+,(A0)+     ; move.l d0,0*160(a6)
                move.l  (A1)+,(A0)+     ; move.w d1,0*+4160(a6)
                move.w  D0,D2
                move.w  D1,D3
                addq.w  #4,D2
                addq.w  #4,D3
                move.w  D0,6(A2)
                move.w  D2,10(A2)
                move.w  D1,14(A2)
                move.w  D3,18(A2)

                add.w   #160,D0
                sub.w   #160,D1
                dbra    D7,loopa1
                move.w  slutmarkering(PC),(A0)+
                bra.s   seeyou

mall:           move.l  (A5)+,D0
                move.w  (A5)+,D1
                move.l  D0,0*160(A6)    ; +6
                move.w  D1,0*160+4(A6)  ; +10
                move.l  D0,h”jd*160(A6) ; +14
                move.w  D1,h”jd*160+4(A6) ; +18
slutmarkering:  rts
seeyou:
                ENDPART

                >PART 'FIX MULUS 2'
                lea     mulutab(PC),A0
                move.w  #255,D0
                lea     logos,A1
                moveq   #0,D1
makemulutab:    move.w  D1,D2
                addq.w  #1,D1
                mulu    #logosize,D2
                movea.l A1,A2
                adda.l  D2,A2
                move.l  A2,(A0)+
                dbra    D0,makemulutab
                ENDPART

                >PART 'INIT'

                movem.l palen(PC),D0-D7
                movem.l D0-D7,$FFFF8240.w
                move.l  #scr1,D0
                and.l   #$FFFFFF00,D0
                move.l  D0,screen1
                move.l  D0,screen
                move.l  #scr2,D0
                and.l   #$FFFFFF00,D0
                move.l  D0,screen2
                move.w  #0,switch

                lea     rasterfield(PC),A0
                movea.l screen1(PC),A1
                movea.l screen2(PC),A2
                tst.w   comp_type
                bmi.s   hepp
                addq.l  #8,A0
hepp:
                move.w  #199,D7
loopying:       move.l  (A0)+,D0
                move.l  (A0)+,D1
                addq.l  #8,A0
                moveq   #19,D6
loopxing:       move.l  D0,(A1)+
                move.l  D1,(A1)+
                move.l  D0,(A2)+
                move.l  D1,(A2)+
                dbra    D6,loopxing
                dbra    D7,loopying

*                lea     kurvan+(x*4)(PC),A1
*                movea.l screen1(PC),A0
*                bsr.s   hepps

*                lea     kurvan+(x*4)(PC),A1
*                movea.l screen2(PC),A0
*                bsr.s   hepps


                move.l  #vbl,$00000070.w
                move    #$2300,SR
                move.b  #0,$FFFFFA07.w  ; set timers
                move.b  #0,$FFFFFA09.w
                move.b  #1,$FFFFFA07.w
                move.b  #1,$FFFFFA13.w

waitkey:        cmpi.b  #$0039+$0080,$FFFFFC02.w
                bne.s   waitkey
                bra     back
                ENDPART



hepps:          >PART 'DRAW LOGO'

* a1=kurva addr (1.w delta y  1.w komb to use)

* a0=drawpogget
* a2=mulutab
* a6=screen
* a5=source
* a4=hoppaddress


                moveq   #0,D4
                moveq   #16,D5
                moveq   #15,D7
loopx:
                moveq   #0,D0
                move.w  (A1)+,D0
                lea     drawhim(PC),A0
                adda.l  D0,A0

                move.w  (A1)+,D1
                lea     mulutab(PC),A5
                movea.l 0(A5,D1.w),A5
                adda.l  D4,A5

                cmp.w   #95*20,D0
                bhs.s   skiphim

                move.w  20*h”jd(A0),D2
                move.w  slutmarkering(PC),20*h”jd(A0) ; set rts
                movea.l screen(PC),A6
                adda.l  D5,A6
                jsr     (A0)
                move.w  D2,20*h”jd(A0)  ; remove rts


skiphim:        lea     (32-4)(A1),A1
                add.l   #8,D5
                add.l   #h”jd*6,D4
                dbra    D7,loopx

                rts


                ENDPART

                >PART 'RASTER'
*********************************
**     R A S T E R
*********************************
raster1:        move.l  A0,-(A7)
                movea.l colpek(PC),A0
                move.w  (A0)+,$FFFF8252.w
                move.w  (A0)+,$FFFF8242.w
                move.l  A0,colpek
                movea.l avstpek(PC),A0
                move.b  #0,$FFFFFA1B.w
                move.b  (A0)+,$FFFFFA21.w
                move.b  #8,$FFFFFA1B.w
                move.l  A0,avstpek
                movea.l (A7)+,A0
                move.b  #0,$FFFFFA0F.w
                rte
                ENDPART

                >PART 'VBL'
*********************************
**     V B L
*********************************
vbl:            movem.l D0-A6,-(A7)
                move.w  palen(PC),$FFFF8240.w
                move.b  #0,$FFFF8260.w

                lea     avstand(PC),A0
                lea     coltab1(PC),A1
                tst.w   comp_type
                beq.s   stecom
                lea     coltab2(PC),A1
stecom:         move.w  (A1)+,$FFFF8252.w
                move.w  (A1)+,$FFFF8242.w
                move.b  #0,$FFFFFA1B.w
                move.b  (A0)+,$FFFFFA21.w
                move.b  #8,$FFFFFA1B.w
                move.l  #raster1,$00000120.w
                move.l  A1,colpek
                move.l  A0,avstpek
                move    #$2500,SR

                cmpi.b  #1,$FFFFFC02.w
                beq.s   pause

                movea.l screen1(PC),A0
                not.w   switch
                bne.s   other
                movea.l screen2(PC),A0
other:          move.l  A0,screen
                move.b  screen+1(PC),$FFFF8201.w
                move.b  screen+2(PC),$FFFF8203.w

                movea.l screen(PC),A0
                movea.l kurvapek(PC),A1
                jsr     hepps(PC)
                move.l  kurvaspeed(PC),D0
                add.l   D0,kurvapek
                cmpi.l  #kurvan,kurvapek
                bls.s   wend
                lea     slutkurvan-(600)(PC),A0
                cmpa.l  kurvapek(PC),A0
                bhi.s   managed
wend:           move.l  kurvaspeed(PC),D0
                neg.l   D0
                move.l  D0,kurvaspeed
                add.l   D0,kurvapek
managed:

                move.w  #$0202,$FFFF8240.w
pause:          movem.l (A7)+,D0-A6
                rte
                ENDPART

************** D A T A ********

comp_type:      DC.W 0          ; 0=STe  -1=ST
screen:         DS.L 1
screen1:        DS.L 1
screen2:        DS.L 1
switch:         DS.W 1
savetab:        DS.L 64
kurvapek:       DC.L kurvan
kurvaspeed:     DC.L 4*speed


                >PART 'RASTER COLORS'
avstpek:        DS.L 1
colpek:         DS.L 1
avstand:        DC.B 4,8,7,8,7,8,7,8,7,8,15,16,15,16,15,16,15
                EVEN
coltab1:        DC.W $000F,$0007 ; ste
                DC.W $0007,$000E
                DC.W $000E,$0006
                DC.W $0006,$000D
                DC.W $000D,$0805
                DC.W $0805,$010C
                DC.W $010C,$0904
                DC.W $0904,$020B
                DC.W $020B,$0A03
                DC.W $0A03,$0B0A

                DC.W $0B09,$0301
                DC.W $0409,$0B09
                DC.W $0C02,$0409
                DC.W $0502,$0C02
                DC.W $0D0A,$0502
                DC.W $0603,$0D0A
                DC.W $0E0B,$0603
                DC.W $0704,$0E0B
                DC.W $0F0C,$0705


coltab2:        DC.W $0007,$0006 ; st
                DC.W $0007,$0006
                DC.W $0006,$0005
                DC.W $0006,$0005
                DC.W $0005,$0104
                DC.W $0805,$0104
                DC.W $0104,$0203
                DC.W $0104,$0203
                DC.W $0203,$0302
                DC.W $0203,$0302

                DC.W $0027,$0007
                DC.W $0027,$0007

                DC.W $0007,$0027
                DC.W $0007,$0027

                DC.W $0006,$0007
                DC.W $0006,$0007

                DC.W $0005,$0006
                DC.W $0005,$0006

                REPT 5
                DC.W 0,-1
                DC.W $0300,$0237
                ENDR


                ENDPART

palen:          DC.W $0013,$0070,$0024,$0035,$0046,$0057,$0077,$0777
                DC.W $0013,$0070,$0024,$0035,$0046,$0057,$0077,$0777

                PART 'LOGO  & TABS TO TAKE OVER....'
drawhim:                                ; 100*2 *22
mulutab         EQU drawhim+4400 ;        256 * 4

logo:           REPT 6*16
                DC.L $FFFF0000,0
                ENDR
                IBYTES 'LOGO.IMG'
                REPT 4*16
                DC.L $FFFF0000,0
                ENDR
                ENDPART

rasterfield:
                IBYTES 'RASTER.IMG'
kurvan:         IBYTES 'MESKURVA.IMG'
slutkurvan:
                PART 'Kombinationerna'
yepp:           IBYTES 'KOMBINAT.IMG'
                DC.W $0080,$0080,$0080,$0080
                DC.W $0080,$0080,$0080,$0080
slutyepp:       ENDPART

                BSS
                DS.B 256
scr1:           DS.L 8000
scr2:           DS.L 8000
logos:          DS.B logosize*((slutyepp-yepp)/16-1)
                END
