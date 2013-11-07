; *************************************
; ** EUTANASIA "INTRO"
; ** By Martin Liesen 1991
; *************************************
                OPT P+
                bsr     MakeRouts
                >PART 'CALL SUPER PART'
                pea     begin(PC)
                move.w  #38,-(A7)
                trap    #14
                addq.l  #6,A7
                rts
                ENDPART
begin:          >PART 'Save Registers'
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

startup:        >PART 'Init'

s:              lea     s(PC),A6
                move    #$2700,SR
                lea     Vbl(PC),A0
                move.l  A0,$00000070.w
                lea     TimerB(PC),A0
                move.l  A0,$00000120.w
                move.b  #0,$FFFFFA07.w
                move.b  #0,$FFFFFA09.w
                move.b  #0,$FFFFFA13.w
                move.b  #0,$FFFFFA15.w
                move.b  #1,$FFFFFA13.w
                move.b  #1,$FFFFFA07.w
                move    #$2300,SR

                move.b  #0,$FFFF8260.w
                bsr     Vsync
                move.b  #0,$FFFF820A.w
                bsr     Vsync
                bsr     Vsync
                move.b  #2,$FFFF820A.w

                lea     scr_1(PC),A0    ; Get Screens
                move.l  A0,D0
                lea     Screen1(PC),A0
                and.l   #$00FFFF00,D0
                move.l  D0,(A0)+
                add.l   #32000,D0
                move.l  D0,(A0)+
                move.l  D0,(A0)+

                ENDPART

MainLoop:       PART 'Main Loop'

                clr.w   $FFFF8240.w
                move.w  #$0777,$FFFF8242.w
                move    #$2300,SR

                move.w  speed(PC),D0
.slow:          bsr     Vsync
                dbra    D0,.slow

                bsr     Switcha
                move.b  Screen+1(PC),$FFFF8201.w
                move.b  Screen+2(PC),$FFFF8203.w

                clr.b   $FFFFFA1B.w
*                move.b  #1,$FFFFFA21.w
*                move.b  #8,$FFFFFA1B.w

                lea     count1(PC),A0
                move.w  (A0),D0
                move.w  2(A0),D1
                move.w  4(A0),D2
                addq.w  #5,D0
                ror.w   D0,D1
                sub.w   #$0345,D2
                add.w   D2,D0
                ror.w   #3,D0
                add.w   D0,D2
                add.w   D0,D3
                rol.w   D3,D0
                sub.w   D2,D0
                move.w  D0,(A0)+
                move.w  D1,(A0)+
                move.w  D2,(A0)

                bsr.s   MakeLook

                lea     $FFFF8209.w,A0  ; SyncLock
.nigger:        tst.b   (A0)
                beq.s   .nigger
                move.b  (A0),D0
                not.w   D0
                ror.w   D0,D0

*                move.w  #$0220,$FFFF8240.w
                movea.l Screen(PC),A0
                lea     16(A0),A0
                lea     look(PC),A1
                moveq   #4,D0
.loopa:         move.w  (A1)+,D3
                move.w  (A1)+,D4
                move.w  (A1)+,D5
                move.w  (A1)+,D6
                move.w  (A1)+,D7
                jsr     Blasta(PC)
                lea     40*160(A0),A0
                dbra    D0,.loopa

.wait:          move.b  $FFFFFC02.w,D0
                cmpi.b  #$3B,D0
                beq     MainLoop
                cmp.b   #$3C,D0
*                bne.s   .wait



                bra     MainLoop

                ENDPART

MakeLook:       >PART 'Calculate Symbol'
* d0=Random number
                movea.l A0,A1
                moveq   #0,D1
                moveq   #24,D2
                lea     look(PC),A0
.rensa:         move.w  D1,(A0)+
                dbra    D2,.rensa

                ror.w   #1,D0
                bcs.s   .Vertical
                lea     To_Horizont(PC),A1
                bra.s   .joins
.Vertical:      lea     To_Vertical(PC),A1
.joins:         lea     look(PC),A0

                moveq   #14,D7
.Fifthen:       ror.w   #1,D0
                bcc.s   .Clear
                moveq   #-1,D6
                bra.s   .joins2
.Clear:         moveq   #0,D6
.joins2:        move.w  (A1)+,D2
                move.w  D6,0(A0,D2.w)
                move.w  (A1)+,D2
                move.w  D6,0(A0,D2.w)
                dbra    D7,.Fifthen

                rts

To_Vertical:    DC.W 0,8,10,18,20,28,30,38,40,48
                DC.W 2,6,12,16,22,26,32,36,42,46
                DC.W 4,4,14,14,24,24,34,34,44,44
To_Horizont:    DC.W 0,40,2,42,4,44,6,46,8,48
                DC.W 10,30,12,32,14,34,16,36,18,38
                DC.W 20,20,22,22,24,24,26,26,28,28
                ENDPART

look:           DS.W 25

count1:         DC.W $489A
count2:         DC.W $39BE
count3:         DC.W $F48C

Vsync:          >PART 'Vsync'
                tst.w   VblFlag-s(A6)
                beq.s   Vsync
                clr.w   VblFlag-s(A6)
                rts
                ENDPART
Switcha:        >PART 'Screen Switch'
                lea     Switch(PC),A0
                not.w   (A0)
                beq.s   .Other
                move.l  Screen1(PC),Screen-Switch(A0)
                bra.s   .joina
.Other:         move.l  Screen2(PC),Screen-Switch(A0)
.joina:         rts
                ENDPART

TimerB:         >PART 'Raster Irq'
                eori.w  #$0630,$FFFF8240.w
                bclr    #0,$FFFFFA0F.w
                rte
                ENDPART
Vbl:            >PART 'VBL Irq'
                addq.w  #1,VblFlag-s(A6)
                cmpi.b  #$39,$FFFFFC02.w
                beq     back

                cmpi.b  #$0D,$FFFFFC02.w
                bhi.s   .fuck
                cmpi.b  #1,$FFFFFC02.w
                blo.s   .fuck
                move.l  A0,-(A7)
                lea     speed(PC),A0
                move.b  $FFFFFC02.w,1(A0)
                movea.l (A7)+,A0
.fuck:

                rte
                ENDPART


MakeRouts:      >PART 'Make Draw boxes routines'

                lea     Blasta(PC),A0
                lea     instruk(PC),A1

                moveq   #39,D7          ; 1st segment
                moveq   #1,D6           ; -1 11 11
.loop_1:        move.w  (A1),(A0)+
                move.w  D6,(A0)+
                addq.w  #7,D6
                move.w  4(A1),(A0)+
                move.w  D6,(A0)+
                addq.w  #8,D6
                move.w  4(A1),(A0)+
                move.w  D6,(A0)+
                add.w   #160-16+1,D6
                dbra    D7,.loop_1

                move.l  8(A1),(A0)+     ; 2nd segment
                moveq   #39,D7          ; 12 22 22
                moveq   #24,D6
.loop_2:        move.w  4(A1),(A0)+
                move.w  D6,(A0)+
                addq.w  #8,D6
                move.w  12(A1),(A0)+
                move.w  D6,(A0)+
                addq.w  #8,D6
                move.w  12(A1),(A0)+
                move.w  D6,(A0)+
                add.w   #160-16,D6
                dbra    D7,.loop_2

                move.w  8(A1),(A0)+     ; 3rd segment
                move.w  16(A1),(A0)+    ; 23 33 33
                moveq   #39,D7
                moveq   #48,D6
.loop_3:        move.w  4(A1),(A0)+
                move.w  D6,(A0)+
                addq.w  #8,D6
                move.w  18(A1),(A0)+
                move.w  D6,(A0)+
                addq.w  #8,D6
                move.w  18(A1),(A0)+
                move.w  D6,(A0)+
                add.w   #160-16,D6
                dbra    D7,.loop_3

                move.w  8(A1),(A0)+     ; 4th segment
                move.w  22(A1),(A0)+    ; 34 44 44
                moveq   #39,D7
                moveq   #72,D6
.loop_4:        move.w  4(A1),(A0)+
                move.w  D6,(A0)+
                addq.w  #8,D6
                move.w  24(A1),(A0)+
                move.w  D6,(A0)+
                addq.w  #8,D6
                move.w  24(A1),(A0)+
                move.w  D6,(A0)+
                add.w   #160-16,D6
                dbra    D7,.loop_4

                move.w  8(A1),(A0)+     ; 5th segment
                move.w  28(A1),(A0)+    ; 45 55 55 5-
                moveq   #39,D7
                moveq   #96,D6
.loop_5:        move.w  4(A1),(A0)+
                move.w  D6,(A0)+
                addq.w  #8,D6
                move.w  30(A1),(A0)+
                move.w  D6,(A0)+
                addq.w  #8,D6
                move.w  30(A1),(A0)+
                move.w  D6,(A0)+
                addq.w  #8,D6
                move.w  34(A1),(A0)+
                move.w  D6,(A0)+
                add.w   #160-24,D6
                dbra    D7,.loop_5

                move.w  38(A1),(A0)+
                rts

instruk:        move.b  D3,1(A0)        ; 0   4
                move.w  D3,0(A0)        ; 4   4
                lsl.w   #8,D3           ; 8   2
                move.b  D4,D3           ; 10  2
                move.w  D4,0(A0)        ; 12  4
                move.b  D5,D3           ; 16  2
                move.w  D5,0(A0)        ; 18  4
                move.b  D6,D3           ; 22  2
                move.w  D6,0(A0)        ; 24  4
                move.b  D7,D3           ; 28  2
                move.w  D7,0(A0)        ; 30  4
                move.b  D7,0(A0)        ; 34  4
                rts                     ; 38  2

*      d3=   pattern 1
*      d4=   pattern 2
*      d5=   pattern 3
*      d6=   pattern 4
*      d7=   pattern 5


                ENDPART

Screen1:        DS.L 1
Screen2:        DS.L 1
Screen:         DS.L 1
Switch:         DS.W 1

speed:          DC.W 1

VblFlag:        DS.W 1
savetab:        DS.L 64
                BSS
Blasta:         DS.B 2578
                DS.B 256
scr_1:          DS.B 32000
scr_2:          DS.B 32000
save:           DS.W 200
                END
