; *************************************
; **  Text Slider
; ** By Martin Liesen 1991
; *************************************
* Observe that picturer should be 3 bitplanes
                OPT P-
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
                lea     savetab,A6
                move.l  A7,(A6)+
                move.l  $70.w,(A6)+
                move.l  $0120.w,(A6)+
                move.b  $FFFFFA07.w,(A6)+
                move.b  $FFFFFA09.w,(A6)+
                move.b  $FFFFFA0F.w,(A6)+
                move.b  $FFFFFA11.w,(A6)+
                move.b  $FFFFFA13.w,(A6)+
                move.b  $FFFFFA15.w,(A6)+
                move.l  $68.w,(A6)+
                move.l  $70.w,(A6)+
                move.l  $0118.w,(A6)+
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
                bra.s   startup
                ENDPART
back:           >PART 'RESTORE AND RTS'
******************************************
*** R E S T O R E   E V E R Y T H I N G
******************************************
                move    #$2700,SR
                lea     savetab,A6
                movea.l (A6)+,A7
                move.l  (A6)+,$70.w
                move.l  (A6)+,$0120.w
                move.b  (A6)+,$FFFFFA07.w
                move.b  (A6)+,$FFFFFA09.w
                move.b  (A6)+,$FFFFFA0F.w
                move.b  (A6)+,$FFFFFA11.w
                move.b  (A6)+,$FFFFFA13.w
                move.b  (A6)+,$FFFFFA15.w
                move.l  (A6)+,$68.w
                move.l  (A6)+,$70.w
                move.l  (A6)+,$0118.w
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

vbl:            >PART 'VBL'

                cmpi.b  #$39,$FFFFFC02.w
                beq.s   back
                addq.w  #1,vblflag
                rte

                ENDPART

startup:        >PART 'Init'
                move.b  #$06,$0484.w
                bsr     fixfont
                bsr     makepostab

                move.l  #scr1,D0
                and.l   #$FFFFFF00,D0
                move.l  D0,screen1
                move.l  D0,screen
                move.l  #scr2,D0
                and.l   #$FFFFFF00,D0
                move.l  D0,screen2

                lea     bild(PC),A0
                movea.l screen1(PC),A1
                movea.l screen2(PC),A2
                move.w  #7999,D0
draw:           move.l  (A0),(A1)+
                move.l  (A0)+,(A2)+
                dbra    D0,draw

                movem.l palen(PC),D0-D7
                movem.l D0-D7,$FFFF8240.w


                lea     texten(PC),A0
                movea.l screen1(PC),A5
                movea.l screen2(PC),A6
                moveq   #24,D7

l6:             movem.l D0-A6,-(A7)
                movea.l A5,A1
                bsr     print
                movem.l (A7),D0-A6
                movea.l A6,A1
                bsr     print
                movem.l (A7)+,D0-A6
                lea     8*160(A5),A5
                lea     8*160(A6),A6
                bsr     getnext
                dbra    D7,l6

                movea.l textpekupper(PC),A0
                moveq   #23,D7
l7:             bsr     getnext
                dbra    D7,l7
                move.l  A0,textpeklower



                move.l  #vbl,$70.w
                move.b  #0,$FFFF8260.w
                bclr    #1,$FFFF820A.w
                clr.w   vblflag
                moveq   #5,D7
vsync:          tst.w   vblflag
                bne.s   vsync
                dbra    D7,vsync

                bset    #1,$FFFF820A.w

                ENDPART

loop:           >PART 'Main Loop'

                clr.w   vblflag
waitvsync:      tst.w   vblflag
                beq.s   waitvsync

                move.l  screen1(PC),D0
                not.w   switch
                beq.s   other
                move.l  screen2(PC),D0
other:          move.l  D0,screen
                move.b  screen+1(PC),$FFFF8201.w
                move.b  screen+2(PC),$FFFF8203.w

                movea.l screen(PC),A0

                cmpi.w  #1,doing
                bne.s   notthat
                btst    #1,aloweed
                bne.s   singel
                cmpi.b  #$50,$FFFFFC02.w
                beq.s   dubelup
singel:         bsr     scrollup
                clr.w   doing
                bra.s   loop
dubelup:        bsr     decrease
                bsr     scrollup2
                bra.s   loop


notthat:        cmpi.w  #2,doing
                bne.s   notthat2
                btst    #0,aloweed
                bne.s   singel1
                cmpi.b  #$48,$FFFFFC02.w
                beq.s   dubeldown
singel1:        bsr     scrolldown
                clr.w   doing
                bra     loop
dubeldown:      bsr.s   increase
                bsr     scrolldown2
                bra     loop


notthat2:       cmpi.b  #$50,$FFFFFC02.w
                bne.s   notup
                btst    #1,aloweed
                bne.s   notup
                bsr     decrease
                bsr     scrollup
                move.w  #1,doing
                bra     loop
notup:
                cmpi.b  #$48,$FFFFFC02.w
                bne.s   notdown
                btst    #0,aloweed
                bne.s   notdown
                bsr.s   increase
                bsr     scrolldown
                move.w  #2,doing
                bra     loop
notdown:

                bra     loop

                ENDPART

increase:       >PART 'Increase Y pos'
                addq.w  #2,ypos
                cmpi.w  #8,ypos
                blo.s   notnew2

                movea.l textpekupper(PC),A0
                cmpi.b  #-1,-1(A0)
                bne.s   notend2
                move.w  #8,ypos
                bset    #0,aloweed
                bra.s   notnew2
notend2:        subq.w  #8,ypos
                bsr     getprevious
                move.l  A0,textpekupper
                movea.l textpeklower(PC),A0
                bsr     getprevious
                move.l  A0,textpeklower
notnew2:        bclr    #1,aloweed
                rts
                ENDPART
decrease:       >PART 'Decrease Y Pos'
                subq.w  #2,ypos
                tst.w   ypos
                bpl.s   notnew
                movea.l textpeklower(PC),A0
                bsr     getnext
                bsr     getnext
                cmpi.b  #-1,(A0)
                bne.s   notend1
                move.w  #0,ypos
                bset    #1,aloweed
                bra.s   notnew
notend1:        addq.w  #8,ypos
                movea.l textpeklower(PC),A0
                bsr     getnext
                move.l  A0,textpeklower
                movea.l textpekupper(PC),A0
                bsr     getnext
                move.l  A0,textpekupper
notnew:         bclr    #0,aloweed
                rts
                ENDPART

scrollup:       >PART 'Scroll Screen Upwards'
                movea.l screen(PC),A0
                lea     2*160(A0),A1
joinwith2:      move.w  #198,D7
flytta1:        move.w  0*8(A1),0*8(A0)
                move.w  1*8(A1),1*8(A0)
                move.w  2*8(A1),2*8(A0)
                move.w  3*8(A1),3*8(A0)
                move.w  4*8(A1),4*8(A0)
                move.w  5*8(A1),5*8(A0)
                move.w  6*8(A1),6*8(A0)
                move.w  7*8(A1),7*8(A0)
                move.w  8*8(A1),8*8(A0)
                move.w  9*8(A1),9*8(A0)
                move.w  10*8(A1),10*8(A0)
                move.w  11*8(A1),11*8(A0)
                move.w  12*8(A1),12*8(A0)
                move.w  13*8(A1),13*8(A0)
                move.w  14*8(A1),14*8(A0)
                move.w  15*8(A1),15*8(A0)
                move.w  16*8(A1),16*8(A0)
                move.w  17*8(A1),17*8(A0)
                move.w  18*8(A1),18*8(A0)
                move.w  19*8(A1),19*8(A0)
                lea     160(A0),A0
                lea     160(A1),A1
                dbra    D7,flytta1

                movea.l screen(PC),A1
                lea     23*8*160(A1),A1
                move.w  ypos(PC),D0
                mulu    #160,D0
                adda.w  D0,A1
                movea.l textpeklower(PC),A0
                movem.l A0-A1,-(A7)
                bsr     print
                movem.l (A7)+,A0-A1
                lea     8*160(A1),A1
                bsr     getnext
                bsr     print
                rts
                ENDPART
scrollup2:      >PART 'Scroll Screen Upwards 2 steps'

                movea.l screen(PC),A0
                lea     4*160(A0),A1
                bra     joinwith2

                ENDPART
scrolldown:     >PART 'Scroll Screen down'
                movea.l screen(PC),A0
                lea     197*160(A0),A1
                lea     199*160(A0),A0
joinwith3:      move.w  #198,D7
flytta3:        move.w  0*8(A1),0*8(A0)
                move.w  1*8(A1),1*8(A0)
                move.w  2*8(A1),2*8(A0)
                move.w  3*8(A1),3*8(A0)
                move.w  4*8(A1),4*8(A0)
                move.w  5*8(A1),5*8(A0)
                move.w  6*8(A1),6*8(A0)
                move.w  7*8(A1),7*8(A0)
                move.w  8*8(A1),8*8(A0)
                move.w  9*8(A1),9*8(A0)
                move.w  10*8(A1),10*8(A0)
                move.w  11*8(A1),11*8(A0)
                move.w  12*8(A1),12*8(A0)
                move.w  13*8(A1),13*8(A0)
                move.w  14*8(A1),14*8(A0)
                move.w  15*8(A1),15*8(A0)
                move.w  16*8(A1),16*8(A0)
                move.w  17*8(A1),17*8(A0)
                move.w  18*8(A1),18*8(A0)
                move.w  19*8(A1),19*8(A0)
                lea     -160(A0),A0
                lea     -160(A1),A1
                dbra    D7,flytta3


                movea.l screen(PC),A1
                lea     -1*8*160(A1),A1
                move.w  ypos(PC),D0
                mulu    #160,D0
                adda.w  D0,A1
                movea.l textpekupper(PC),A0
                movem.l A0-A1,-(A7)
                bsr.s   print
                movem.l (A7)+,A0-A1
                lea     8*160(A1),A1
                bsr.s   getnext
                bsr.s   print
                rts
                ENDPART
scrolldown2:    >PART 'Scroll Screen down 2 steps'

                movea.l screen(PC),A0
                lea     195*160(A0),A1
                lea     199*160(A0),A0
                bra     joinwith3

                ENDPART

                >PART 'Get Next Line'
getnext:        cmpi.b  #-1,(A0)
                beq.s   allan2
                tst.b   (A0)+
                bne.s   getnext
                rts
allan2:         addq.w  #1,A0
                rts
                ENDPART
                >PART 'Get Previous Line'
getprevious:    subq.w  #1,A0
letare:         cmpi.b  #-1,-1(A0)
                beq.s   allan
                tst.b   -(A0)
                bne.s   letare
                addq.w  #1,A0
allan:          rts
                ENDPART

*********************************************

fixfont:        >PART 'Fix Font To Word'
                lea     font(PC),A0
                lea     font1,A1
                lea     font2,A2
                move.w  #2047,D7

l1:             moveq   #0,D0
                move.b  (A0)+,D0
                move.b  D0,(A1)+
                clr.b   (A1)+
                lsl.w   #4,D0
                move.w  D0,(A2)+
                dbra    D7,l1
                rts

                ENDPART
makepostab:     >PART 'Make Position Tab'
                lea     postab,A0
                moveq   #0,D0
                moveq   #19,D7

l3:             move.w  D0,(A0)+
                addq.w  #1,D0
                move.w  D0,(A0)+
                addq.w  #7,D0
                dbra    D7,l3
                rts

                ENDPART
print:          PART 'Print A0 on A1'

                movea.l A1,A2
                moveq   #2*8-1,D7

rensa:          clr.w   0*8(A2)
                clr.w   1*8(A2)
                clr.w   2*8(A2)
                clr.w   3*8(A2)
                clr.w   4*8(A2)
                clr.w   5*8(A2)
                clr.w   6*8(A2)
                clr.w   7*8(A2)
                clr.w   8*8(A2)
                clr.w   9*8(A2)
                lea     10*8(A2),A2
                dbra    D7,rensa

                movea.l A0,A2
                moveq   #0,D7
count:          tst.b   (A2)+
                beq.s   nomore
                addq.w  #1,D7
                bra.s   count

nomore:         subq.w  #1,D7
                bmi     slut
                btst    #0,D7           ; get font
                beq.s   other2
                lea     font1,A2
                bra.s   join
other2:         lea     font2,A2
join:           moveq   #39,D6
                sub.w   D7,D6
                and.w   #$FFFE,D6
                lea     postab,A3
                adda.w  D6,A3



l2:             moveq   #0,D0
                move.b  (A0)+,D0
                lsl.w   #4,D0
                lea     0(A2,D0.w),A4
                move.w  (A3)+,D0
                lea     0(A1,D0.w),A5
                move.w  (A3),D0
                lea     0(A1,D0.w),A6


                move.b  (A4)+,D0
                or.b    D0,0*160(A5)
                move.b  (A4)+,D0
                or.b    D0,0*160(A6)
                move.b  (A4)+,D0
                or.b    D0,1*160(A5)
                move.b  (A4)+,D0
                or.b    D0,1*160(A6)
                move.b  (A4)+,D0
                or.b    D0,2*160(A5)
                move.b  (A4)+,D0
                or.b    D0,2*160(A6)
                move.b  (A4)+,D0
                or.b    D0,3*160(A5)
                move.b  (A4)+,D0
                or.b    D0,3*160(A6)
                move.b  (A4)+,D0
                or.b    D0,4*160(A5)
                move.b  (A4)+,D0
                or.b    D0,4*160(A6)
                move.b  (A4)+,D0
                or.b    D0,5*160(A5)
                move.b  (A4)+,D0
                or.b    D0,5*160(A6)
                move.b  (A4)+,D0
                or.b    D0,6*160(A5)
                move.b  (A4)+,D0
                or.b    D0,6*160(A6)
                move.b  (A4)+,D0
                or.b    D0,7*160(A5)
                move.b  (A4)+,D0
                or.b    D0,7*160(A6)

                dbra    D7,l2


slut:           rts

                ENDPART

*********************************************

                >PART 'D A T A'

aloweed:        DC.W $0100
doing:          DC.W 0
vblflag:        DC.W 0
switch:         DC.W 0
screen:         DC.L 0
screen1:        DC.L 0
screen2:        DC.L 0
ypos:           DC.W 0          ; (0-7)
textpekupper:   DC.L lineabove
textpeklower:   DC.L 0
font:           PATH 'D:\LIESEN\DATA'
                IBYTES 'IBMFNT8.FNT'

                ENDPART
                >PART 'Texten'

                DC.B -1,-1
lineabove:      DC.B -1
texten:         DC.B 0
                DC.B 0
                DC.B "ษอออออออออออออออออออออออป",0
                DC.B "บ                       บ",0
                DC.B "บ   E U T A N A S I A   บ",0
                DC.B "บ                       บ",0
                DC.B "ศอออออออออออออออออออออออผ",0
                DC.B 0
                DC.B 0
                DC.B 0
                DC.B "Created By SYNCHRON ASSEMBLY",0
                DC.B "for Expose software",0
                DC.B 0
                DC.B 0
                DC.B 0
                DC.B "Programming",0
                DC.B "Martin Liesen",0
                DC.B 0
                DC.B "Graphics & Co-design",0
                DC.B "Johannes S”derqvist",0
                DC.B 0
                DC.B 0
                DC.B 0
                DC.B "OBSERVE  use the cursor keys to control",0
                DC.B "         this text.                    ",0
                DC.B 0
                DC.B 0
                DC.B 0
                DC.B 0
                DC.B "This is a DEMO version, at early stage.",0
                DC.B "Here's some features of the game:",0
                DC.B 0
                DC.B "* Two players playing at the same time.",0
                DC.B "* About 30 different weapons.          ",0
                DC.B "* A third layer of parallax on         ",0
                DC.B "  certain levels.                      ",0
                DC.B "* Among the fastest sprite and scroll  ",0
                DC.B "  routines ever made on the ST.        ",0
                DC.B "* An 'amazing' story.                  ",0
                DC.B "* Mega enemies. (bigger than screen)   ",0
                DC.B "* Soundtracker Music (using            ",0
                DC.B "  Audio Sculpture, also from 'us').    ",0
                DC.B "* Advanced memory support (more        ",0
                DC.B "  memory, less loading, ect.).         ",0
                DC.B "* A lot of cheat modes (and other      ",0
                DC.B "  strange things....).                 ",0
                DC.B "* Loading at maximum speed.            ",0
                DC.B "* TT support, and a Amiga version.     ",0
                DC.B "* A lot of graphics (both inside and   ",0
                DC.B "  outside game).                       ",0
                DC.B "* Using our ST hardware scroller       ",0
                DC.B "  where suitable.                      ",0
                DC.B "* Probably 50 frames per second on TT. ",0
                DC.B "* Highscore save (20-1000 names??).    ",0
                DC.B "* More than 16 colors on screen        ",0
                DC.B "  (rasters you know...).               ",0
                DC.B "* NOT including Pepsi (Urk!)           ",0
                DC.B "                Tina Turner (Urk!)     ",0
                DC.B "                Princesses (maybe)     ",0
                DC.B "* Perhaps (!!) Remote playing using    ",0
                DC.B "  RS232/Midi/Centronics ports.         ",0
                DC.B "* A lot of levels, around 50.          ",0
                DC.B "* A map based level system.            ",0
                DC.B "* Both easy and hard levels, and       ",0
                DC.B "  together with the map system, they   ",0
                DC.B "  satisfy all ages.                    ",0
                DC.B "* About 64003 pixels on screen.        ",0

                DC.B 0
                DC.B 0
                DC.B 0
                DC.B "This preview version is perhaps not as",0
                DC.B "good as we wanted it to.... but with",0
                DC.B "the essential pressure from Expose....",0
                DC.B 0
                DC.B 0
                DC.B "Well, if you against all odds would like",0
                DC.B "to contact us, here's a good clue..",0
                DC.B 0
                DC.B "Martin Liesen (17 years old)",0
                DC.B "Pl 6035",0
                DC.B "44033 Harestad",0
                DC.B "Sweden",0
                DC.B "Phone: +46-303-21311",0
                DC.B 0
                DC.B "Johannes S”derqvist (18 years old)",0
                DC.B "Paradisgatan 26B",0
                DC.B "41316 Gothenburg",0
                DC.B "Sweden",0
                DC.B "Phone: +46-31-243007",0
                DC.B 0
                DC.B "Or at Omega Hq BBS  +46-303-21685",0
                DC.B "      ฿฿฿฿฿                      ",0
                DC.B 0
                DC.B 0
                DC.B 0
                DC.B 0
                DC.B 0
                DC.B "Keys on the demoversion",0
                DC.B "อออออออออออออออออออออออ",0
                DC.B "F1 Full energy player 1",0
                DC.B "F2 Full energy player 2",0
                DC.B "F3 Blow an enemy",0
                DC.B "F4 Remove all shoots",0
                DC.B "F5 Clear screen from enemies",0
                DC.B "F6 Color Time",0
                DC.B "F7 Time used as percent (3 Frames)",0
                DC.B "F8 Remove all time viewers",0
                DC.B "F9 Show percent of memory used",0
                DC.B "P  Pause",0
                DC.B "Esc-  Slowmotion",0
                DC.B 0
                DC.B "This version is ment to work on a",0
                DC.B "520 Atari ST, but (always), I haven't",0
                DC.B "been able to test it on one. To be",0
                DC.B "abel to load using the TOS, I had to",0
                DC.B "leave about 60kb of memory for the",0
                DC.B "TOS, that's the explanation to why",0
                DC.B "this demo version only works in AUTO",0
                DC.B "folder on 520 (if it works) and why",0
                DC.B "only 90 percent of the memory is used.",0
                DC.B "(test the F9 function..)",0
                DC.B "This means that I can have about",0
                DC.B "10 percent more enemies/weapons/ect.",0
                DC.B "on the finished 520 version...",0
                DC.B 0
                DC.B 0
                DC.B 0
                DC.B 0
                DC.B 0
                DC.B 0
                DC.B "What is Synchron Assembly??",0
                DC.B 0
                DC.B "Well, It's a newly founded cooperation",0
                DC.B "between the Swedish demo groups",0
                DC.B "Omega, Sync and Electra (and any other",0
                DC.B "who fits our standards) The Label will",0
                DC.B "only be used on commercial products, not",0
                DC.B "connected to the demo world. It's also",0
                DC.B "a deeper cooperation than just using the",0
                DC.B "the same label, we also develope indoor",0
                DC.B "product to make life easier for us.",0
                DC.B "Another product from S.A. is",0
                DC.B "Audio Sculpture, which is likly to be",0
                DC.B "released before this game will. It's",0
                DC.B "a high standard soundtracker for the",0
                DC.B "Atari ST series.",0
                DC.B 0
                DC.B 0
                DC.B 0
                DC.B 0
                DC.B 0
                DC.B 0
                DC.B 0
                DC.B 0
                DC.B "ษออออออออออออออออออออออออออออออออออป",0
                DC.B "บ                                  บ",0
                DC.B "บ Copyright 1990,91  Martin Liesen บ",0
                DC.B "บ                                  บ",0
                DC.B "ศออออออออออออออออออออออออออออออออออผ",0
                DC.B 0
                DC.B 0
                DC.B 0
                DC.B "This is a demo version and may not be",0
                DC.B "copied without permission from either",0
                DC.B "EXPOSE SOFTWARE or SYNCHRON ASSEMBLY.",0
                DC.B 0
                DC.B "EXPOSE SOFTWARE is only aloweed to      ",0
                DC.B "to give copies to MAGGAZINES.           ",0
                DC.B "Maggazines may not copy the demoversion,",0
                DC.B "not even make a backup!                 ",0
                DC.B "If they do so, we can easily track which",0
                DC.B "one and WILL take action on unleagal    ",0
                DC.B "copying.(Magazinnes may be 'Blacklisted'",0
                DC.B "in the final version and leagal actions ",0
                DC.B "can be considered to be taken)          ",0
                DC.B 0
                DC.B "Only with written permisson from the ",0
                DC.B "owner of the copyright may someone   ",0
                DC.B "except EXPOSE SOFTW. or SYNCHRON.ASM.",0
                DC.B "make a copy of this demoversion.     ",0
                DC.B "(like including a copy in each number",0
                DC.B "of a maggazine.)                     ",0
                DC.B 0
                DC.B 0
                DC.B "ษออออออออออออออออออออออออออออออออออป",0
                DC.B "บ                                  บ",0
                DC.B "บ Copyright 1990,91  Martin Liesen บ",0
                DC.B "บ                                  บ",0
                DC.B "ศออออออออออออออออออออออออออออออออออผ",0
                DC.B 0
                DC.B 0
                DC.B 0
                DC.B 0
                DC.B 0
                DC.B 0
                DC.B 0
                DC.B 0
                DC.B 0
                DC.B 0
                DC.B 0
                DC.B 0
                DC.B 0
                DC.B 0
                DC.B 0
                DC.B 0
                DC.B 0
                DC.B 0
                DC.B 0
                DC.B 0
                DC.B 0
                DC.B 0
                DC.B 0
                DC.B 0

                DC.B "<< END of TEXT >>",0
                DC.B -1,-1,-1
                EVEN
                ENDPART
                PART 'BILDEN'
palen           EQU *+4
*;Palette of SAES.DOO: Saved by NEOchrome V2.21 by Chaos, Inc.
*                DC.W $00,$0777,$0111,$0777,$0222,$0777,$0333,$0777
*                DC.W $0777,$0777,$0777,$0777,$0777,$0777,$0777,$0777

bild            EQU *+128
                IBYTES 'FLORIAN1.NEO'
*                PATH 'D:\LIESEN\ASM\MORE\SHOWTEXT\'
*                IBYTES 'SAES.DOO'
                ENDPART
                >PART 'BSS'
                BSS
font1:          DS.B 4096
font2:          DS.B 4096
postab:         DS.B 80
savetab:        DS.L 64
                DS.B 256
                DS.B 8*160
scr1:           DS.B 32000
                DS.B 8*160
                DS.B 256
                DS.B 8*160
scr2:           DS.B 32000
                DS.B 8*160
                ENDPART
                END
