*********************************************************************
***                                                               ***
***                    Resetdemo (Fullscreen)                     ***
***                   ~~~~~~~~~~~~~~~~~~~~~~~~                    ***
***                written by New Mode of Delta Force             ***
***---------------------------------------------------------------***
***            Programmerstellung begann am: 13.08.90             ***
***            Aktuelles Datum             : 29.11.90             ***
***---------------------------------------------------------------***
*********************************************************************

diskversion     EQU 0           ; 0=Developervers., 1=Diskversion

                IFNE diskversion
                ORG $080000
                OUTPUT 'E:\WRITE\SIDE0\RESETDEM.IMG'
                ENDC

                IFEQ diskversion
                pea     start(PC)	; Supexec
                move.w  #38,-(A7)
                trap    #14
                addq.l  #6,A7
                clr.w   -(A7)		; Terminate
                trap    #1
                ENDC


start:          
		IFEQ diskversion
                move.l  A7,oldstack
                ENDC
                ori     #$0700,SR            ; Started mit Maske auf 2700
                lea     stack,A7

                lea     $ffff8240.w,A0
                moveq   #7,D0
clrpal:         clr.l   (A0)+
                dbra    D0,clrpal


                lea     muster(PC),A0
                move.l  #13520,D0
; formt Bild aus Spezialformat zurÅck
; a0=Adresse
; d0=LÑnge
                lsr.l   #3,D0                ; Length/Bitblocks
                subq.l  #1,D0
                movea.l A0,A1                ; Dest. (Atari)
backformloop0:  moveq   #0,D1                ; clear Plane 0-3
                moveq   #0,D2
                moveq   #0,D3
                moveq   #0,D4
                moveq   #3,D5                ; 4 words
backformloop1:  move.w  (A0)+,D7             ; get word (Special)
                add.w   D7,D7                ; shift left by 1
                addx.w  D1,D1                ; Plane 0 set
                add.w   D7,D7                ;
                addx.w  D2,D2                ;
                add.w   D7,D7                ;
                addx.w  D3,D3                ;
                add.w   D7,D7                ;
                addx.w  D4,D4                ;
                add.w   D7,D7                ;
                addx.w  D1,D1                ;
                add.w   D7,D7                ;
                addx.w  D2,D2                ;
                add.w   D7,D7                ;
                addx.w  D3,D3                ;
                add.w   D7,D7                ;
                addx.w  D4,D4                ;
                add.w   D7,D7                ;
                addx.w  D1,D1                ;
                add.w   D7,D7                ;
                addx.w  D2,D2                ;
                add.w   D7,D7                ;
                addx.w  D3,D3                ;
                add.w   D7,D7                ;
                addx.w  D4,D4                ;
                add.w   D7,D7                ;
                addx.w  D1,D1                ;
                add.w   D7,D7                ;
                addx.w  D2,D2                ;
                add.w   D7,D7                ;
                addx.w  D3,D3                ;
                add.w   D7,D7                ;
                addx.w  D4,D4                ;
                dbra    D5,backformloop1
                move.w  D4,(A1)+             ;
                move.w  D3,(A1)+
                move.w  D2,(A1)+
                move.w  D1,(A1)+
                dbra    D0,backformloop0


                move.l  #fatscreen,D0
                and.l   #-256,D0
                move.l  D0,oldscreen

                movea.l oldscreen(PC),A0
                bsr     cls

                moveq   #1,D0
                bsr     music

                movea.l oldscreen(PC),A1
                lea     -26(A1),A1
                movea.l A1,A2
                adda.l  #259*230,A2
                lea     muster(PC),A0
                move.w  #129,D0              ; 130 Zeilen
musterloop0:    moveq   #25,D1               ; 28 Longs
musterloop1:    move.l  (A0),(A1)
                move.l  (A0),(A2)
                move.l  (A0),104(A1)
                move.l  (A0)+,104(A2)
                addq.l  #4,A1
                addq.l  #4,A2
                dbra    D1,musterloop1
                lea     126(A1),A1
                lea     -230-104(A2),A2
                dbra    D0,musterloop0


                movea.l oldscreen(PC),A0
                lea     -26(A0),A0
                move.w  #208,D1
                moveq   #0,D2
                move.w  #415,D3
                move.w  #259,D4
                bsr     hflip

                bsr     preparescroller

                clr.w   scrollcounter
                move.l  #scrollbuff,scrollpointer
                move.l  #scrollbuff,scrollpointer2

                move.l  oldscreen(PC),D0
                bsr     setscreen


                move.l  #$03120312,D0
                move.l  D0,$ffff8250.w
                move.l  D0,$ffff8254.w
                move.l  D0,$ffff8258.w
                move.l  D0,$ffff825c.w


                bsr     hbl_on               ; Interrupts anschalten


                IFNE diskversion
                clr.l   $0426.w              ; Resvalid lîschen
                ENDC


mainloop:       bsr     vsync

                IFEQ diskversion
                cmpi.b  #$39,key
                bne.s   mainloop

ende:
                bsr     hbl_off

                moveq   #0,D0
                bsr     music

                movea.l oldstack,A7
                rts
		ENDC
		IFNE	diskversion
                bra.s   mainloop	; Endless loop
                ENDC




preparescroller:
; schreibt Scroller in Buffer (preshiftet)

                lea     scrollbuff,A0
                move.w  #(zeichen*18)-1,D0
clrscrollbuff:  clr.l   (A0)+
                dbra    D0,clrscrollbuff

                lea     scrolltext,A0
                lea     scrollbuff,A1
                move.w  #zeichen-1,D0
puttextinbuff:
                moveq   #0,D1
                move.b  (A0)+,D1             ; ASCII holen
                lea     charset,A2
                divu    #40,D1
                move.w  D1,D2
                mulu    #18*40,D2
                adda.l  D2,A2
                swap    D1
                adda.w  D1,A2                ; Rest=0-39

                movea.l A1,A3
                moveq   #17,D7               ; 18 Scanlines hoch
copycharinbuff: move.b  (A2),(A3)
                lea     40(A2),A2
                lea     zeichen(A3),A3
                dbra    D7,copycharinbuff
                addq.l  #1,A1
                dbra    D0,puttextinbuff

                lea     scrollbuff,A1        ; in 8 Buffer kopieren
                lea     zeichen*18(A1),A1    ; auf zweite Pos.
                moveq   #2,D0                ; 3 mal Kopieren
copyscroller:   lea     scrollbuff,A0
                move.w  #(zeichen*18)-1,D1
copyscroll1:    move.b  (A0)+,(A1)+
                dbra    D1,copyscroll1
                dbra    D0,copyscroller

                lea     scrollbuff+(zeichen*19),A2 ; 1.Buffer (Ende)
                moveq   #4,D0                ; Schiebwert
shiftscroller:  movea.l A2,A0
                moveq   #17,D1               ; 18 Zeilen
shiftscrl1:     move.w  #(zeichen/2)-1,D2    ; Worte pro Zeile
                moveq   #0,D4
shiftscrl2:     moveq   #0,D3
                move.w  -(A0),D3
                lsl.l   D0,D3                ; um d0 nach links
                or.w    D4,D3                ; altes geschobenes einodern
                move.w  D3,(A0)
                swap    D3
                move.w  D3,D4                ; neues geschobenes
                dbra    D2,shiftscrl2
                lea     zeichen*2(A0),A0     ; nÑchste Zeile
                dbra    D1,shiftscrl1
                lea     zeichen*18(A2),A2
                addq.w  #4,D0
                cmp.w   #16,D0
                bne.s   shiftscroller
                rts


;Diese Routine kann ganze Bildschirmteile spiegeln. Diese Bildschirmbereiche
;mÅssen aber auf BBs liegen, d.h. sie clippt die RÑnder nicht!
;  d4: y2
;  d3: x2
;  d2: y1
;  d1: x1
;   a0: Screenadresse


hflip:          movem.l D0-A5,-(A7)
                move.w  D2,D0                ;y1
                mulu    #230,D0
                adda.l  D0,A0
                movea.l A0,A1                ;rechter Rand
                move.w  D1,D0                ;x1
                lsr.w   #4,D0
                lsl.w   #3,D0
                adda.w  D0,A0
                move.w  D3,D0                ;x2
                lsr.w   #4,D0
                lsl.w   #3,D0
                adda.w  D0,A1                ;x1=rechter Rand

                st      ungerade2
                move.w  D3,D7                ;x2
                sub.w   D1,D7                ;-x1=Breite in Pixeln
                lsr.w   #5,D7                ;=Breite in BBs-1/2
                bcs.s   gerade88
                sf      ungerade2
                subq.w  #1,D7                ;ein BB weniger
gerade88:       movea.w D7,A5                ;Breite in BBs-1 merken
                move.w  D7,D0
                addq.w  #1,D0
                lsl.w   #3,D0                ;Breite in Bytes
                movea.w #230,A3
                suba.w  D0,A3                ;Offset fÅr linken Rand
                movea.w #230,A4              ;Offset fÅr rechten Rand
                adda.w  D0,A4
                tst.b   ungerade2
                bne.s   gerade22
                subq.l  #8,A3
                subq.l  #8,A4
gerade22:       move.w  D4,D6
                sub.w   D2,D6                ;Hîhe in Scanlines
                lea     mirror_tab,A2

                moveq   #0,D0
                moveq   #0,D1

mirror_loop2:   move.w  A5,D7                ;Breite in BBs-1

mirror_loop1:   movem.w (A1),D2-D5           ;rechten Rand merken

                move.b  (A0)+,D0
                move.b  (A0)+,D1
                move.b  0(A2,D0.w),D0        ;Byte spiegeln
                move.b  0(A2,D1.w),D1        ;-'-
                move.b  D1,(A1)+
                move.b  D0,(A1)+

                move.b  (A0)+,D0
                move.b  (A0)+,D1
                move.b  0(A2,D0.w),D0        ;Byte spiegeln
                move.b  0(A2,D1.w),D1        ;-'-
                move.b  D1,(A1)+
                move.b  D0,(A1)+

                move.b  (A0)+,D0
                move.b  (A0)+,D1
                move.b  0(A2,D0.w),D0        ;Byte spiegeln
                move.b  0(A2,D1.w),D1        ;-'-
                move.b  D1,(A1)+
                move.b  D0,(A1)+

                move.b  (A0)+,D0
                move.b  (A0)+,D1
                move.b  0(A2,D0.w),D0        ;Byte spiegeln
                move.b  0(A2,D1.w),D1        ;-'-
                move.b  D1,(A1)+
                move.b  D0,(A1)+

                subq.l  #8,A0                ;zurÅck an Anfang des linken BBs
                lea     -16(A1),A1           ;An Anfang des nÑchsten BBs rechts

                move.b  D2,D0
                move.b  0(A2,D0.w),D0
                move.b  D0,(A0)+
                lsr.w   #8,D2                ;2. Byte holen
                move.b  0(A2,D2.w),D2
                move.b  D2,(A0)+

                move.b  D3,D0
                move.b  0(A2,D0.w),D0
                move.b  D0,(A0)+
                lsr.w   #8,D3                ;2. Byte holen
                move.b  0(A2,D3.w),D3
                move.b  D3,(A0)+

                move.b  D4,D0
                move.b  0(A2,D0.w),D0
                move.b  D0,(A0)+
                lsr.w   #8,D4                ;2. Byte holen
                move.b  0(A2,D4.w),D4
                move.b  D4,(A0)+

                move.b  D5,D0
                move.b  0(A2,D0.w),D0
                move.b  D0,(A0)+
                lsr.w   #8,D5                ;2. Byte holen
                move.b  0(A2,D5.w),D5
                move.b  D5,(A0)+
                dbra    D7,mirror_loop1

                tst.b   ungerade2
                bne.s   wt62

                move.b  (A0)+,D0
                move.b  (A0)+,D1
                move.b  0(A2,D0.w),D0        ;Byte spiegeln
                move.b  0(A2,D1.w),D1        ;-'-
                move.b  D1,(A1)+
                move.b  D0,(A1)+

                move.b  (A0)+,D0
                move.b  (A0)+,D1
                move.b  0(A2,D0.w),D0        ;Byte spiegeln
                move.b  0(A2,D1.w),D1        ;-'-
                move.b  D1,(A1)+
                move.b  D0,(A1)+

                move.b  (A0)+,D0
                move.b  (A0)+,D1
                move.b  0(A2,D0.w),D0        ;Byte spiegeln
                move.b  0(A2,D1.w),D1        ;-'-
                move.b  D1,(A1)+
                move.b  D0,(A1)+

                move.b  (A0)+,D0
                move.b  (A0)+,D1
                move.b  0(A2,D0.w),D0        ;Byte spiegeln
                move.b  0(A2,D1.w),D1        ;-'-
                move.b  D1,(A1)+
                move.b  D0,(A1)+

wt62:           adda.l  A3,A0
                adda.l  A4,A1
                dbra    D6,mirror_loop2

                movem.l (A7)+,D0-A5
                rts




setscreen:      lsr.l   #8,D0
                move.b  D0,$ffff8203.w
                lsr.w   #8,D0
                move.b  D0,$ffff8201.w
                rts

vsync:          move.l  $0466.w,D0
waitvsync:      cmp.l   $0466.w,D0
                beq.s   waitvsync
                rts

cls:
; Parameter:    a0=Screenadresse

                move.w  #15999,D0
clsloop:        clr.l   (A0)+
                dbra    D0,clsloop

                rts


hbl_on:
                IFEQ diskversion
                lea     hbl_buff,A0
                move.l  $0118.w,(A0)+
                move.l  $0120.w,(A0)+
                move.l  $70.w,(A0)+
                move.l  $68.w,(A0)+
                move.b  $fffffa09.w,(A0)+    ; Werte retten
                move.b  $fffffa07.w,(A0)+
                move.b  $fffffa13.w,(A0)+
                move.b  $fffffa1b.w,(A0)+
                move.b  $fffffa11.w,(A0)+
                move.b  $fffffa21.w,(A0)+
                move.b  $fffffa17.w,(A0)+
		ENDC
		
		IFNE	diskversion		; RTE on all Vectors
                lea     $70.w,A0
fillloop:       move.l  #rtevector,(A0)+
                cmpa.l  #$0120,A0
                bne.s   fillloop
                ENDC

                andi.b  #$df,$fffffa09.w     ; Timer C aus
                andi.b  #$fe,$fffffa07.w     ; Timer B aus
                move.l  #newkey,$0118.w
                move.l  #vbl2,$70.w
                moveq   #0,D7

                move    #$2300,SR            ; Sync und Res setzen
                bsr     vsync
                move.b  #2,$ffff820a.w
                clr.b   $ffff8260.w

                move.l  #vbl,$70.w
                move.l  #ha_be_el,$68.w
                move.w  #31,hbl_counter
                rts

                IFEQ diskversion
hbl_off:        move    SR,-(A7)
                ori     #$0700,SR
                lea     hbl_buff,A0          ; Werte zurueck!
                move.l  (A0)+,$0118.w
                move.l  (A0)+,$0120.w
                move.l  (A0)+,$70.w
                move.l  (A0)+,$68.w
                move.b  (A0)+,$fffffa09.w
                move.b  (A0)+,$fffffa07.w
                move.b  (A0)+,$fffffa13.w
                move.b  (A0)+,$fffffa1b.w
                move.b  (A0)+,$fffffa11.w
                move.b  (A0)+,$fffffa21.w
                move.b  (A0)+,$fffffa17.w
                move    (A7)+,SR
                rts
                ENDC


vbl2:           addq.l  #1,$0466.w
rtevector:      rte


vbl:            movem.l D0-A6,-(A7)
                move.l  #ha_be_el,$68.w
                move.w  #31,hbl_counter
                move.b  #3,$fffffc00.w
                move.b  #$96,$fffffc00.w
                subq.l  #2,colpointer1
                cmpi.l  #colors,colpointer1
                bne.s   nixendcolpointer
                move.l  #colende,colpointer1

nixendcolpointer:
                move.l  colpointer1(PC),colpointer2

                movea.l colpointer2(PC),A0
                move.w  (A0)+,$ffff8242.w
                move.w  8(A0),$ffff8244.w
                move.w  18(A0),$ffff8246.w
                move.w  28(A0),$ffff8248.w
                move.w  38(A0),$ffff824a.w
                move.w  48(A0),$ffff824c.w
                move.w  58(A0),$ffff824e.w
                move.l  A0,colpointer2
                addq.l  #1,$0466.w
                movem.l (A7)+,D0-A6
                andi.w  #$f1ff,(A7)
                rte

hbl_counter:    DC.W 31

ha_be_el:       subq.w  #1,hbl_counter
                bmi.s   hblisda
                rte
hblisda:        move.l  #hbl2,$68.w
waithere:       stop    #$2100
                bra.s   waithere

hbl2:           move    #$2700,SR
                DCB.W 92,$4e71
                move.b  #0,$ffff820a.w       ; oberer Rand weg
                DCB.W 16,$4e71
                move.b  #2,$ffff820a.w
                addq.l  #6,A7
                movem.l D0-A6,-(A7)
                movea.w #$8209,A0            ; Lowbyte Screencounter
                movea.w #$820a,A1            ; Sync
                movea.w #$8260,A2            ; Res

                movea.l oldscreen(PC),A6
                lea     -20+10*230(A6),A6
                movea.l dpos(PC),A5

                movea.l scrollpointer2,A4

                moveq   #12,D3               ; 13*6=78 Zeilen den Rand aufklappen

                moveq   #0,D0
                moveq   #7,D1                ; add-Wert
                moveq   #6,D2                ; eor-Wert
                moveq   #2,D4
                moveq   #1,D7
                moveq   #0,D5
wait:           move.b  (A0),D0
                cmp.w   #64,D0
                blt.s   wait
                sub.w   #64,D0
                not.w   D0
                lsr.w   D0,D0

klapp_loop:
; Klappt 6 Zeilen lang den Rand auf
                nop
                nop
                nop
                nop
                move.b  D5,(A1)              ; 60Hz
                move.b  D4,(A1)              ; 50Hz

                movea.l A6,A3                ; 52 TZ
                adda.l  (A5)+,A3
                move.b  D5,(A3)
                move.b  D5,230(A3)
                move.b  D5,460(A3)

                move.b  D4,(A2)              ; Highres
                eor.w   D2,D1
                move.b  D5,(A2)              ; Lowres

                move.b  D5,4830(A3)          ; 48TZ
                move.b  D5,5060(A3)
                move.b  D5,5290(A3)
                adda.l  D1,A6
                nop

                move.b  D4,(A2)              ; Highres
                nop
                move.b  D5,(A2)              ; Lowres

                move.b  (A4)+,690(A3)        ; 356
                move.b  zeichen-1(A4),920(A3)
                move.b  2*zeichen-1(A4),1150(A3)
                move.b  3*zeichen-1(A4),1380(A3)
                move.b  4*zeichen-1(A4),1610(A3)
                move.b  5*zeichen-1(A4),1840(A3)
                move.b  6*zeichen-1(A4),2070(A3)
                move.b  7*zeichen-1(A4),2300(A3)
                move.b  8*zeichen-1(A4),2530(A3)
                move.b  9*zeichen-1(A4),2760(A3)
                move.b  10*zeichen-1(A4),2990(A3)
                move.b  11*zeichen-1(A4),3220(A3)
                move.b  12*zeichen-1(A4),3450(A3)
                move.b  13*zeichen-1(A4),3680(A3)
                move.b  14*zeichen-1(A4),3910(A3)
                move.b  15*zeichen-1(A4),4140(A3)
                move.b  16*zeichen-1(A4),4370(A3)
                move.b  17*zeichen-1(A4),4600(A3)


                move.b  D5,(A1)              ; 60Hz
                move.b  D4,(A1)              ; 50Hz

                movea.l A6,A3                ; 52 TZ
                adda.l  (A5)+,A3
                move.b  D5,(A3)
                move.b  D5,230(A3)
                move.b  D5,460(A3)

                move.b  D4,(A2)              ; Highres
                eor.w   D2,D1
                move.b  D5,(A2)              ; Lowres

                move.b  D5,4830(A3)          ; 48TZ
                move.b  D5,5060(A3)
                move.b  D5,5290(A3)
                adda.l  D1,A6
                nop

                move.b  D4,(A2)              ; Highres
                nop
                move.b  D5,(A2)              ; Lowres

                move.b  (A4)+,690(A3)        ; 356
                move.b  zeichen-1(A4),920(A3)
                move.b  2*zeichen-1(A4),1150(A3)
                move.b  3*zeichen-1(A4),1380(A3)
                move.b  4*zeichen-1(A4),1610(A3)
                move.b  5*zeichen-1(A4),1840(A3)
                move.b  6*zeichen-1(A4),2070(A3)
                move.b  7*zeichen-1(A4),2300(A3)
                move.b  8*zeichen-1(A4),2530(A3)
                move.b  9*zeichen-1(A4),2760(A3)
                move.b  10*zeichen-1(A4),2990(A3)
                move.b  11*zeichen-1(A4),3220(A3)
                move.b  12*zeichen-1(A4),3450(A3)
                move.b  13*zeichen-1(A4),3680(A3)
                move.b  14*zeichen-1(A4),3910(A3)
                move.b  15*zeichen-1(A4),4140(A3)
                move.b  16*zeichen-1(A4),4370(A3)
                move.b  17*zeichen-1(A4),4600(A3)


                move.b  D5,(A1)              ; 60Hz
                move.b  D4,(A1)              ; 50Hz

                movea.l A6,A3                ; 52 TZ
                adda.l  (A5)+,A3
                move.b  D5,(A3)
                move.b  D5,230(A3)
                move.b  D5,460(A3)

                move.b  D4,(A2)              ; Highres
                eor.w   D2,D1
                move.b  D5,(A2)              ; Lowres

                move.b  D5,4830(A3)          ; 48TZ
                move.b  D5,5060(A3)
                move.b  D5,5290(A3)
                adda.l  D1,A6
                nop

                move.b  D4,(A2)              ; Highres
                nop
                move.b  D5,(A2)              ; Lowres

                move.b  (A4)+,690(A3)        ; 356
                move.b  zeichen-1(A4),920(A3)
                move.b  2*zeichen-1(A4),1150(A3)
                move.b  3*zeichen-1(A4),1380(A3)
                move.b  4*zeichen-1(A4),1610(A3)
                move.b  5*zeichen-1(A4),1840(A3)
                move.b  6*zeichen-1(A4),2070(A3)
                move.b  7*zeichen-1(A4),2300(A3)
                move.b  8*zeichen-1(A4),2530(A3)
                move.b  9*zeichen-1(A4),2760(A3)
                move.b  10*zeichen-1(A4),2990(A3)
                move.b  11*zeichen-1(A4),3220(A3)
                move.b  12*zeichen-1(A4),3450(A3)
                move.b  13*zeichen-1(A4),3680(A3)
                move.b  14*zeichen-1(A4),3910(A3)
                move.b  15*zeichen-1(A4),4140(A3)
                move.b  16*zeichen-1(A4),4370(A3)
                move.b  17*zeichen-1(A4),4600(A3)

                move.b  D5,(A1)              ; 60Hz
                move.b  D4,(A1)              ; 50Hz

                movea.l A6,A3                ; 52 TZ
                adda.l  (A5)+,A3
                move.b  D5,(A3)
                move.b  D5,230(A3)
                move.b  D5,460(A3)

                move.b  D4,(A2)              ; Highres
                eor.w   D2,D1
                move.b  D5,(A2)              ; Lowres

                move.b  D5,4830(A3)          ; 48TZ
                move.b  D5,5060(A3)
                move.b  D5,5290(A3)
                adda.l  D1,A6
                nop

                move.b  D4,(A2)              ; Highres
                nop
                move.b  D5,(A2)              ; Lowres

                move.b  (A4)+,690(A3)        ; 356
                move.b  zeichen-1(A4),920(A3)
                move.b  2*zeichen-1(A4),1150(A3)
                move.b  3*zeichen-1(A4),1380(A3)
                move.b  4*zeichen-1(A4),1610(A3)
                move.b  5*zeichen-1(A4),1840(A3)
                move.b  6*zeichen-1(A4),2070(A3)
                move.b  7*zeichen-1(A4),2300(A3)
                move.b  8*zeichen-1(A4),2530(A3)
                move.b  9*zeichen-1(A4),2760(A3)
                move.b  10*zeichen-1(A4),2990(A3)
                move.b  11*zeichen-1(A4),3220(A3)
                move.b  12*zeichen-1(A4),3450(A3)
                move.b  13*zeichen-1(A4),3680(A3)
                move.b  14*zeichen-1(A4),3910(A3)
                move.b  15*zeichen-1(A4),4140(A3)
                move.b  16*zeichen-1(A4),4370(A3)
                move.b  17*zeichen-1(A4),4600(A3)


                move.b  D5,(A1)              ; 60Hz
                move.b  D4,(A1)              ; 50Hz
                DCB.W 13,$4e71
                move.b  D4,(A2)              ; Highres
                nop
                move.b  D5,(A2)              ; Lowres
                DCB.W 12,$4e71
                move.b  D4,(A2)              ; Highres
                nop
                move.b  D5,(A2)              ; Lowres

                DCB.W 89,$4e71


                move.b  D5,(A1)              ; 60Hz
                move.b  D4,(A1)              ; 50Hz
                DCB.W 13,$4e71
                move.b  D4,(A2)              ; Highres
                nop
                move.b  D5,(A2)              ; Lowres
                DCB.W 12,$4e71
                move.b  D4,(A2)              ; Highres
                nop
                move.b  D5,(A2)              ; Lowres

                DCB.W 85-53,$4e71

************** Farben scrollen ******************

                move.l  A3,-(A7)             ; 12
                move.l  A4,-(A7)             ; 12
                lea     $ffff8242.w,A4       ; 8
                movea.l colpointer2(PC),A3   ; 16

                move.w  (A3)+,(A4)+          ; 12
                move.w  8(A3),(A4)+          ; 16
                move.w  18(A3),(A4)+         ; 16
                move.w  28(A3),(A4)+         ; 16
                move.w  38(A3),(A4)+         ; 16
                move.w  48(A3),(A4)+         ; 16
                move.w  58(A3),(A4)+         ; 16

                move.l  A3,colpointer2       ; 20

                movea.l (A7)+,A4             ; 12
                movea.l (A7)+,A3             ; 12

************ Farben scrollen Ende **************

                dbra    D3,klapp_loop

                moveq   #24,D3               ; 25*6=150 Scanlines aufklappen
                nop

klapp_loop2:    nop
                move.b  D5,(A1)              ; 60Hz
                move.b  D4,(A1)              ; 50Hz
                DCB.W 13,$4e71
                move.b  D4,(A2)              ; Highres
                nop
                move.b  D5,(A2)              ; Lowres
                DCB.W 12,$4e71
                move.b  D4,(A2)              ; Highres
                nop
                move.b  D5,(A2)              ; Lowres
                DCB.W 89,$4e71

                move.b  D5,(A1)              ; 60Hz
                move.b  D4,(A1)              ; 50Hz
                DCB.W 13,$4e71
                move.b  D4,(A2)              ; Highres
                nop
                move.b  D5,(A2)              ; Lowres
                DCB.W 12,$4e71
                move.b  D4,(A2)              ; Highres
                nop
                move.b  D5,(A2)              ; Lowres
                DCB.W 89,$4e71

                move.b  D5,(A1)              ; 60Hz
                move.b  D4,(A1)              ; 50Hz
                DCB.W 13,$4e71
                move.b  D4,(A2)              ; Highres
                nop
                move.b  D5,(A2)              ; Lowres
                DCB.W 12,$4e71
                move.b  D4,(A2)              ; Highres
                nop
                move.b  D5,(A2)              ; Lowres
                DCB.W 89,$4e71

                move.b  D5,(A1)              ; 60Hz
                move.b  D4,(A1)              ; 50Hz
                DCB.W 13,$4e71
                move.b  D4,(A2)              ; Highres
                nop
                move.b  D5,(A2)              ; Lowres
                DCB.W 12,$4e71
                move.b  D4,(A2)              ; Highres
                nop
                move.b  D5,(A2)              ; Lowres
                DCB.W 89,$4e71

                move.b  D5,(A1)              ; 60Hz
                move.b  D4,(A1)              ; 50Hz
                DCB.W 13,$4e71
                move.b  D4,(A2)              ; Highres
                nop
                move.b  D5,(A2)              ; Lowres
                DCB.W 12,$4e71
                move.b  D4,(A2)              ; Highres
                nop
                move.b  D5,(A2)              ; Lowres
                DCB.W 89,$4e71

                move.b  D5,(A1)              ; 60Hz
                move.b  D4,(A1)              ; 50Hz
                DCB.W 13,$4e71
                move.b  D4,(A2)              ; Highres
                nop
                move.b  D5,(A2)              ; Lowres
                DCB.W 12,$4e71
                move.b  D4,(A2)              ; Highres
                nop
                move.b  D5,(A2)              ; Lowres

                DCB.W 85-50,$4e71

************** Farben scrollen ******************

                move.l  A3,-(A7)             ; 12
                move.l  A4,-(A7)             ; 12
                lea     $ffff8242.w,A4       ; 8
                movea.l colpointer2(PC),A3   ; 16

                move.w  (A3)+,(A4)+          ; 12
                move.w  8(A3),(A4)+          ; 16
                move.w  18(A3),(A4)+         ; 16
                move.w  28(A3),(A4)+         ; 16
                move.w  38(A3),(A4)+         ; 16
                move.w  48(A3),(A4)+         ; 16
                move.w  58(A3),(A4)+         ; 16

                move.l  A3,colpointer2       ; 20

                movea.l (A7)+,A4             ; 12
                movea.l (A7)+,A3             ; 12

************ Farben scrollen Ende **************

                dbra    D3,klapp_loop2

                move.b  D5,(A1)              ; unteren Rand auf
                move.b  D4,(A1)
                move.b  D5,(A1)
                DCB.W 11,$4e71
                move.b  D4,(A2)
                nop
                move.b  D5,(A2)
                DCB.W 11,$4e71

                moveq   #31,D3               ; 32 Scanlines weiter aufmachen

                move.b  D4,(A2)
                nop
                move.b  D5,(A2)
                move.b  D4,(A1)

                DCB.W 87,$4e71

klapp_loop3:    move.b  D5,(A1)              ; 60Hz
                move.b  D4,(A1)              ; 50Hz
                DCB.W 13,$4e71
                move.b  D4,(A2)              ; Highres
                nop
                move.b  D5,(A2)              ; Lowres
                DCB.W 12,$4e71
                move.b  D4,(A2)              ; Highres
                nop
                move.b  D5,(A2)              ; Lowres
                DCB.W 86,$4e71
                dbra    D3,klapp_loop3

                bsr     music+8

                subq.l  #4,dpos
                cmpi.l  #delta,dpos
                bne.s   nixenddpos
                move.l  #deltaende,dpos
nixenddpos:
doscroll:       moveq   #0,D0
                move.w  scrollcounter,D0
                addq.w  #1,D0
                and.w   #3,D0
                bne.s   nixaddpointer
                addq.l  #2,scrollpointer
                cmpi.l  #scrollbuff+(zeichen-52),scrollpointer
                bne.s   nixaddpointer
                move.l  #scrollbuff,scrollpointer
nixaddpointer:  move.w  D0,scrollcounter
                movea.l scrollpointer,A0
                mulu    #zeichen*18,D0
                adda.l  D0,A0
                move.l  A0,scrollpointer2

                movem.l (A7)+,D0-A6
                ori.w   #$0300,(A7)

                rte


newkey:         
		IFNE diskversion
                move.b  $fffffc02.w,key
		ENDC

		IFEQ diskversion
                move.w  D0,-(A7)
                move.b  $fffffc00.w,D0
                btst    #7,D0
                beq.s   endkeyvec
                move.b  $fffffc02.w,key
endkeyvec:      bclr    #6,$fffffa11.w
                move.w  (A7)+,D0
                ENDC

                bclr    #6,$fffffa11.w
                rte


                DATA

oldscreen:      DS.L 1

music:          INCBIN 'JAMLOOP2.IMG'

muster:         INCBIN 'INTERFE4.IMG'

colpointer1:    DC.L colende
colpointer2:    DC.L colende

colors:         INCBIN 'HBL.PAL',310
                DC.W $0706,$0705,$0704,$0703,$0702,$0701,$0700
                DC.W $0710,$0721,$0732,$0743,$0754,$0765,$0776,$0777
                DC.W $0677,$0567,$0456,$0345,$0234,$0123,$12,$01
                DC.W $0100,$0200,$0300,$0410,$0520,$0630,$0741,$0752
                DC.W $0763,$0774,$0775,$0776,$0777
                DC.W $0767,$0756,$0645,$0534,$0423,$0312,$0201,$0100
                DC.W $01,$0102,$0203,$0304,$0405,$0506,$0607,$0707
                DC.W $0717,$0727,$0737,$0747,$0757,$0767,$0777
                DC.W $0666,$0555,$0444,$0333,$0222,$0111
                DC.W $0110,$0221,$0332,$0443,$0554,$0665,$0776,$0777
                DC.W $0677,$0566,$0455,$0344,$0233,$0122,$11
                DC.W $01,$12,$23,$34,$45,$56,$67,$77
                DC.W $0177,$0277,$0377,$0477,$0577,$0677,$0777
                DC.W $0677,$0576,$0465,$0354,$0243,$0132,$21,$10
                DC.W $01,$02,$03,$0104,$0205,$0306,$0417,$0527
                DC.W $0637,$0747,$0757,$0767,$0777
                DC.W $0776,$0775,$0774,$0773,$0772,$0771,$0770
                DC.W $0760,$0750,$0740,$0730,$0720,$0710,$0700
                DC.W $0710,$0720,$0730,$0740,$0750,$0760,$0770
                DC.W $0660,$0550,$0440,$0330,$0220,$0110
                DC.W $0100,$0200,$0300,$0401,$0502,$0603,$0714,$0725
                DC.W $0736,$0774,$0775,$0776,$0777
                DC.W $0666,$0555,$0444,$0333,$0222,$0111
                DC.W $0101,$0202,$0303,$0404,$0505,$0606,$0707
                DC.W $0607,$0507,$0407,$0307,$0207,$0107,$07
                DC.W $06,$05,$04,$03,$02,$01
                DC.W $0111,$0222,$0333,$0444,$0555,$0666,$0777
                DC.W $0666,$0555,$0444,$0333,$0222,$0111
                DC.W $0101,$0202,$0303,$0404,$0505,$0606,$0707


colende:        INCBIN 'HBL.PAL',150

scrolltext:     DCB.B 52,51
                INCBIN 'TEXT.IMG'
                DCB.B 52,51

scrollende:     EVEN

zeichen         EQU scrollende-scrolltext



dpos:           DC.L deltaende

delta:                                       ; Schwingdaten fÅr Scroller
                DC.L 27600,27830,28060,28290,28520,28750,28980,29210
                DC.L 29440,29670,29900,30130,30360,30590,30820,31050
                DC.L 31050,31280,31510,31740,31970,32200,32200,32430
                DC.L 32660,32660,32890,33120,33120,33350,33350,33580
                DC.L 33580,33810,33810,34040,34040,34040,34270,34270
                DC.L 34270,34270,34270,34270,34270,34500,34270,34270
                DC.L 34270,34270,34270,34270,34270,34040,34040,34040
                DC.L 33810,33810,33580,33580,33350,33350,33120,33120
                DC.L 32890,32660,32660,32430,32200,32200,31970,31740
                DC.L 31510,31280,31050,31050,30820,30590,30360,30130
                DC.L 29900,29670,29440,29210,28980,28750,28520,28290
                DC.L 28060,27830,27600,27140,26910,26680,26450,26220
                DC.L 25990,25760,25530,25300,25070,24840,24610,24380
                DC.L 24150,23920,23920,23690,23460,23230,23000,22770
                DC.L 22770,22540,22310,22310,22080,21850,21850,21620
                DC.L 21620,21390,21390,21160,21160,20930,20930,20930
                DC.L 20700,20700,20700,20700,20700,20700,20700,20700
                DC.L 20700,20700,20700,20700,20700,20700,20700,20930
                DC.L 20930,20930,21160,21160,21390,21390,21620,21620
                DC.L 21850,21850,22080,22310,22310,22540,22770,22770
                DC.L 23000,23230,23460,23690,23920,23920,24150,24380
                DC.L 24610,24840,25070,25300,25530,25760,25990,26220
                DC.L 26450,26680,26910,27140,27370

                DC.L 27600,27830,28290,28750,28980,29440,29900,30360
                DC.L 30590,31050,31510,31740,32200,32430,32890,33350
                DC.L 33580,33810,34270,34500,34960,35190,35420,35650
                DC.L 36110,36340,36570,36800,37030,37260,37490,37720
                DC.L 37720,37950,38180,38180,38410,38640,38640,38640
                DC.L 38870,38870,38870,38870,38870,39100,38870,38870
                DC.L 38870,38870,38870,38640,38640,38640,38410,38180
                DC.L 38180,37950,37720,37720,37490,37260,37030,36800
                DC.L 36570,36340,36110,35650,35420,35190,34960,34500
                DC.L 34270,33810,33580,33350,32890,32430,32200,31740
                DC.L 31510,31050,30590,30360,29900,29440,28980,28750
                DC.L 28290,27830,27600,27140,26680,26220,25990,25530
                DC.L 25070,24610,24380,23920,23460,23230,22770,22540
                DC.L 22080,21620,21390,21160,20700,20470,20010,19780
                DC.L 19550,19320,18860,18630,18400,18170,17940,17710
                DC.L 17480,17250,17250,17020,16790,16790,16560,16330
                DC.L 16330,16330,16100,16100,16100,16100,16100,16100
                DC.L 16100,16100,16100,16100,16100,16330,16330,16330
                DC.L 16560,16790,16790,17020,17250,17250,17480,17710
                DC.L 17940,18170,18400,18630,18860,19320,19550,19780
                DC.L 20010,20470,20700,21160,21390,21620,22080,22540
                DC.L 22770,23230,23460,23920,24380,24610,25070,25530
                DC.L 25990,26220,26680,27140,27370



                DC.L 27600,27830,28060,28290,28520,28750,28980,29210
                DC.L 29440,29670,29900,30130,30360,30590,30820,31050
                DC.L 31280,31510,31740,31970,32200,32430,32660,32890
                DC.L 33120,33350,33580,33810,34040,34270,34500,34500
                DC.L 34730,34960,35190,35420,35650,35880,35880,36110
                DC.L 36340,36570,36800,36800,37030,37260,37490,37490
                DC.L 37720,37950,37950,38180,38410,38410,38640,38870
                DC.L 38870,39100,39100,39330,39330,39560,39560,39790
                DC.L 39790,40020,40020,40250,40250,40480,40480,40480
                DC.L 40710,40710,40710,40710,40940,40940,40940,40940
                DC.L 41170,41170,41170,41170,41170,41170,41170,41170
                DC.L 41170,41170,41400,41170,41170,41170,41170,41170
                DC.L 41170,41170,41170,41170,41170,40940,40940,40940
                DC.L 40940,40710,40710,40710,40710,40480,40480,40480
                DC.L 40250,40250,40020,40020,39790,39790,39560,39560
                DC.L 39330,39330,39100,39100,38870,38870,38640,38410
                DC.L 38410,38180,37950,37950,37720,37490,37490,37260
                DC.L 37030,36800,36800,36570,36340,36110,35880,35880
                DC.L 35650,35420,35190,34960,34730,34500,34500,34270
                DC.L 34040,33810,33580,33350,33120,32890,32660,32430
                DC.L 32200,31970,31740,31510,31280,31050,30820,30590
                DC.L 30360,30130,29900,29670,29440,29210,28980,28750
                DC.L 28520,28290,28060,27830,27600,27140,26910,26680
                DC.L 26450,26220,25990,25760,25530,25300,25070,24840
                DC.L 24610,24380,24150,23920,23690,23460,23230,23000
                DC.L 22770,22540,22310,22080,21850,21620,21390,21160
                DC.L 20930,20700,20470,20470,20240,20010,19780,19550
                DC.L 19320,19090,19090,18860,18630,18400,18170,18170
                DC.L 17940,17710,17480,17480,17250,17020,17020,16790
                DC.L 16560,16560,16330,16100,16100,15870,15870,15640
                DC.L 15640,15410,15410,15180,15180,14950,14950,14720
                DC.L 14720,14490,14490,14490,14260,14260,14260,14260
                DC.L 14030,14030,14030,14030,13800,13800,13800,13800
                DC.L 13800,13800,13800,13800,13800,13800,13800,13800
                DC.L 13800,13800,13800,13800,13800,13800,13800,13800
                DC.L 13800,14030,14030,14030,14030,14260,14260,14260
                DC.L 14260,14490,14490,14490,14720,14720,14950,14950
                DC.L 15180,15180,15410,15410,15640,15640,15870,15870
                DC.L 16100,16100,16330,16560,16560,16790,17020,17020
                DC.L 17250,17480,17480,17710,17940,18170,18170,18400
                DC.L 18630,18860,19090,19090,19320,19550,19780,20010
                DC.L 20240,20470,20470,20700,20930,21160,21390,21620
                DC.L 21850,22080,22310,22540,22770,23000,23230,23460
                DC.L 23690,23920,24150,24380,24610,24840,25070,25300
                DC.L 25530,25760,25990,26220,26450,26680,26910,27140
                DC.L 27370


deltaende:
                DC.L 27600,27830,28060,28290,28520,28750,28980,29210
                DC.L 29440,29670,29900,30130,30360,30590,30820,31050
                DC.L 31050,31280,31510,31740,31970,32200,32200,32430
                DC.L 32660,32660,32890,33120,33120,33350,33350,33580
                DC.L 33580,33810,33810,34040,34040,34040,34270,34270
                DC.L 34270,34270,34270,34270,34270,34500,34270,34270
                DC.L 34270,34270,34270,34270



mirror_tab:     DC.B $00,$80,$40,$c0,$20,$a0,$60,$e0
                DC.B $10,$90,$50,$d0,$30,$b0,$70,$f0
                DC.B $08,$88,$48,$c8,$28,$a8,$68,$e8
                DC.B $18,$98,$58,$d8,$38,$b8,$78,$f8
                DC.B $04,$84,$44,$c4,$24,$a4,$64,$e4
                DC.B $14,$94,$54,$d4,$34,$b4,$74,$f4
                DC.B $0c,$8c,$4c,$cc,$2c,$ac,$6c,$ec
                DC.B $1c,$9c,$5c,$dc,$3c,$bc,$7c,$fc
                DC.B $02,$82,$42,$c2,$22,$a2,$62,$e2
                DC.B $12,$92,$52,$d2,$32,$b2,$72,$f2
                DC.B $0a,$8a,$4a,$ca,$2a,$aa,$6a,$ea
                DC.B $1a,$9a,$5a,$da,$3a,$ba,$7a,$fa
                DC.B $06,$86,$46,$c6,$26,$a6,$66,$e6
                DC.B $16,$96,$56,$d6,$36,$b6,$76,$f6
                DC.B $0e,$8e,$4e,$ce,$2e,$ae,$6e,$ee
                DC.B $1e,$9e,$5e,$de,$3e,$be,$7e,$fe
                DC.B $01,$81,$41,$c1,$21,$a1,$61,$e1
                DC.B $11,$91,$51,$d1,$31,$b1,$71,$f1
                DC.B $09,$89,$49,$c9,$29,$a9,$69,$e9
                DC.B $19,$99,$59,$d9,$39,$b9,$79,$f9
                DC.B $05,$85,$45,$c5,$25,$a5,$65,$e5
                DC.B $15,$95,$55,$d5,$35,$b5,$75,$f5
                DC.B $0d,$8d,$4d,$cd,$2d,$ad,$6d,$ed
                DC.B $1d,$9d,$5d,$dd,$3d,$bd,$7d,$fd
                DC.B $03,$83,$43,$c3,$23,$a3,$63,$e3
                DC.B $13,$93,$53,$d3,$33,$b3,$73,$f3
                DC.B $0b,$8b,$4b,$cb,$2b,$ab,$6b,$eb
                DC.B $1b,$9b,$5b,$db,$3b,$bb,$7b,$fb
                DC.B $07,$87,$47,$c7,$27,$a7,$67,$e7
                DC.B $17,$97,$57,$d7,$37,$b7,$77,$f7
                DC.B $0f,$8f,$4f,$cf,$2f,$af,$6f,$ef
                DC.B $1f,$9f,$5f,$df,$3f,$bf,$7f,$ff

ungerade2:      DC.B 0
                EVEN

charset:                                     ; 18 hoch
                DC.W $fffe,$fff0,$1ffe,$fff0,$fffe,$fffe,$7ffe,$f83e
                DC.W $feff,$fef8,$3ef8,$f0,$1ef8,$3e1f,$f0ff,$f01f
                DC.W $f0ff,$f01f,$feff,$fef8,$fffe,$fffc,$7ffe,$fffc
                DC.W $fffe,$fffe,$fffe,$f83e,$feff,$fef8,$7ef8,$f8
                DC.W $3ef8,$3e7f,$fcff,$fc7f,$fcff,$fc7f,$feff,$fef8
                DC.W $fffe,$fffe,$fffe,$fffe,$fffe,$fffe,$fffe,$f83e
                DC.W $feff,$fef8,$fcf8,$f8,$7ef8,$3eff,$feff,$feff
                DC.W $feff,$feff,$feff,$fef8,$fffe,$fffe,$fffe,$fffe
                DC.W $fffe,$fffe,$fffe,$f83e,$feff,$fef9,$f8f8,$fa
                DC.W $fefa,$3eff,$feff,$feff,$feff,$feff,$feff,$fef8
                DC.W $00,$00,$00,$00,$00,$00,$00,$f83e
                DC.W $00,$fb,$f0f8,$fb,$fefa,$3e00,$00,$00
                DC.W $00,$00,$00,$f8,$f83e,$f83e,$f800,$f83e
                DC.W $f800,$f800,$f800,$f83e,$7c00,$3efb,$e0f8,$fb
                DC.W $fefb,$3ef8,$3ef8,$3ef8,$3ef8,$3ef8,$07,$c0f8
                DC.W $f83e,$f83e,$f800,$f83e,$f800,$f800,$f800,$f83e
                DC.W $7c00,$3efb,$c0f8,$fb,$fefb,$3ef8,$3ef8,$3ef8
                DC.W $3ef8,$3e00,$07,$c0f8,$f83e,$fbfc,$f800,$f83e
                DC.W $fbc0,$fbc0,$fbfe,$fbbe,$7c00,$3efb,$80f8,$fb
                DC.W $befb,$bef8,$3efb,$fef8,$3efb,$feff,$f007,$c0f8
                DC.W $f83e,$fbf8,$f800,$f83e,$fbc0,$fbc0,$fbfe,$fbbe
                DC.W $7c00,$3efb,$f8,$f9,$3efb,$bef8,$3efb,$fef8
                DC.W $3efb,$feff,$fc07,$c0f8,$f83e,$fbf8,$f800,$f83e
                DC.W $fbc0,$fbc0,$fbfe,$fbbe,$7c00,$3efb,$f8,$f8
                DC.W $3efb,$bef8,$3efb,$fcf8,$3efb,$fc7f,$fe07,$c0f8
                DC.W $fbbe,$fbfc,$f800,$f83e,$fbc0,$fbc0,$fbfe,$fbbe
                DC.W $7c00,$3efb,$80f8,$f8,$3ef9,$bef8,$3efb,$f0fb
                DC.W $befb,$f01f,$fe07,$c0f8,$fbbe,$f83e,$f800,$f83e
                DC.W $f800,$f800,$f83e,$f83e,$7cf8,$3efb,$c0f8,$f8
                DC.W $3ef9,$bef8,$3ef8,$fb,$bef8,$00,$07,$c0f8
                DC.W $fbbe,$f83e,$f800,$f83e,$f800,$f800,$f83e,$f83e
                DC.W $7cf8,$3efb,$e0f8,$f8,$3ef8,$bef8,$3ef8,$fb
                DC.W $befb,$e000,$3e07,$c0f8,$fbbe,$00,$00,$00
                DC.W $00,$f800,$00,$f83e,$00,$fb,$f000,$f8
                DC.W $3ef8,$be00,$f8,$00,$fb,$f000,$07,$c000
                DC.W $f83e,$fffe,$fffe,$fffe,$fffe,$f800,$fffe,$f83e
                DC.W $feff,$fef9,$f8ff,$fef8,$3ef8,$3eff,$fef8,$ff
                DC.W $bef9,$f8ff,$fe07,$c0ff,$f83e,$fffe,$fffe,$fffe
                DC.W $fffe,$f800,$fffe,$f83e,$feff,$fef8,$fcff,$fef8
                DC.W $3ef8,$3eff,$fef8,$ff,$bef8,$fcff,$fe07,$c0ff
                DC.W $f83e,$fffc,$7ffe,$fffc,$fffe,$f800,$fffe,$f83e
                DC.W $feff,$fef8,$7eff,$fef8,$3ef8,$3e7f,$fcf8,$7f
                DC.W $bef8,$7eff,$fc07,$c0ff,$f83e,$fff0,$1ffe,$fff0
                DC.W $fffe,$f800,$7ffe,$f83e,$feff,$fef8,$3eff,$fef8
                DC.W $3ef8,$3e1f,$f0f8,$1f,$bef8,$3eff,$f007,$c0ff
                DC.W $3ef8,$3ef8,$3ef8,$3ef8,$3eff,$fe00,$1ff0,$0eff
                DC.W $f0ff,$f0f8,$3eff,$fe1f,$fcff,$fe1f,$f01f,$f000
                DC.W $00,$387f,$d06c,$601e,$3ef8,$3ef8,$3efc,$7ef8
                DC.W $3eff,$fe00,$7ffc,$1eff,$fcff,$fcf8,$3eff,$fe7f
                DC.W $fcff,$fe7f,$fc7f,$fc00,$00,$7c7f,$dc6c,$603e
                DC.W $3ef8,$3ef8,$3efe,$fef8,$3eff,$fe00,$fffe,$3eff
                DC.W $feff,$fef8,$3eff,$feff,$fcff,$feff,$feff,$fe00
                DC.W $00,$7c7f,$de6c,$6000,$3ef8,$3ef8,$3e7f,$fcf8
                DC.W $3eff,$fe00,$fffe,$7eff,$feff,$fef8,$3eff,$feff
                DC.W $fcff,$feff,$feff,$fe00,$00,$7c00,$1e6c,$6070
                DC.W $3ef8,$3ef8,$3e3f,$f8f8,$3e00,$00,$00,$fe00
                DC.W $00,$f8,$3e00,$00,$00,$00,$00,$00
                DC.W $3800,$7c00,$1e00,$6070,$3ef8,$3ef8,$3e1f,$f0f8
                DC.W $3e00,$fc00,$f83e,$fe00,$3e00,$3ef8,$3ef8,$f8
                DC.W $00,$7ef8,$3ef8,$3e00,$7c00,$7c17,$de00,$70
                DC.W $3ef8,$3ef8,$3e0f,$e000,$3e01,$f800,$f83e,$fe00
                DC.W $00,$3e00,$00,$f8,$00,$fef8,$3ef8,$3e00
                DC.W $7c00,$7c77,$dc00,$70,$3ef8,$3ef8,$3e07,$c0ff
                DC.W $be03,$f000,$f8be,$fe1f,$fe07,$fcff,$feff,$f0fb
                DC.W $f001,$fe7f,$fcff,$be00,$3800,$7cf7,$d000,$70
                DC.W $3ef8,$3ef8,$3e00,$ff,$be07,$e000,$f9be,$7f
                DC.W $fe07,$f8ff,$feff,$fcfb,$fc03,$fc3f,$f8ff,$be00
                DC.W $00,$7cf0,$00,$70,$3ef8,$3ef9,$3e03,$80ff
                DC.W $be0f,$c000,$fb3e,$3eff,$fc07,$f8ff,$feff,$fefb
                DC.W $fe07,$f83f,$f87f,$be00,$00,$7cf0,$00,$70
                DC.W $3ef8,$3efb,$be07,$c07f,$be1f,$8000,$fa3e,$3eff
                DC.W $f007,$fcff,$feff,$fefb,$fe0f,$f07f,$fc1f,$be00
                DC.W $3838,$7cf7,$fc00,$70,$3e00,$fb,$fe0f,$e000
                DC.W $3e3f,$00,$f83e,$3e00,$00,$3e00,$00,$f8
                DC.W $3e1f,$e0f8,$3e00,$3e00,$7c38,$7c77,$fc00,$70
                DC.W $3efc,$7efb,$fe1f,$f000,$3e7e,$00,$f83e,$3ef8
                DC.W $00,$3e00,$3e00,$3ef8,$3e3f,$c0f8,$3e00,$3e00
                DC.W $7c38,$3817,$fc00,$70,$7e,$fcfb,$fe3f,$f800
                DC.W $00,$00,$00,$3e00,$00,$00,$3e00,$00
                DC.W $7f,$8000,$00,$00,$3800,$00,$00,$70
                DC.W $fe3e,$f8fa,$fe7f,$fcff,$feff,$fe00,$fffe,$3eff
                DC.W $feff,$fe00,$3eff,$feff,$feff,$ff,$fe7f,$fe38
                DC.W $38,$3803,$8000,$70,$fe1e,$f0f8,$7efe,$feff
                DC.W $feff,$fe00,$fffe,$3eff,$feff,$fe00,$3eff,$feff
                DC.W $fefe,$ff,$fe7f,$fe7c,$38,$7c07,$c000,$00
                DC.W $fe0e,$e0f8,$3efc,$7eff,$feff,$fe00,$7ffc,$3eff
                DC.W $feff,$fc00,$3eff,$fc7f,$fcfc,$7f,$fc7f,$fc7c
                DC.W $78,$7c07,$c000,$3e,$fe06,$c0f0,$1ef8,$3eff
                DC.W $fcff,$fe00,$1ff0,$3eff,$feff,$f000,$3eff,$f01f
                DC.W $f0f8,$1f,$f07f,$f038,$70,$3803,$8000,$1e
                DC.W $e000,$00,$00,$00,$00,$00,$00,$0600
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $00,$00,$01,$bb00,$f000,$00,$00,$0c
                DC.W $00,$2008,$00,$0900,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$00,$00,$01,$bb00
                DC.W $00,$00,$00,$1c,$00,$17d0,$00,$0900
                DC.W $00,$00,$00,$00,$00,$0f07,$67e3,$c1c7
                DC.W $bc1c,$7000,$01,$bb00,$3807,$c000,$00,$3c
                DC.W $00,$1ff0,$00,$0900,$3d00,$21,$10,$4040
                DC.W $00,$0f8e,$67e7,$c38f,$be3c,$e038,$1c01,$bb00
                DC.W $3807,$c000,$00,$7c,$7ffc,$0fe0,$00,$0f00
                DC.W $3d00,$21,$18,$c040,$00,$0fdc,$67ee,$c71f
                DC.W $bf7d,$c07c,$3c01,$bb00,$3807,$c000,$00,$fc
                DC.W $7ffc,$600c,$00,$0f00,$2120,$31,$1d,$c040
                DC.W $00,$0dd8,$618c,$c61d,$b371,$807c,$7c01,$bb00
                DC.W $3800,$00,$00,$01f8,$7ffc,$711c,$2eee,$6f6c
                DC.W $2120,$39,$1f,$c040,$02,$0cd8,$618c,$c619
                DC.W $b361,$8038,$f801,$bb00,$387f,$fc7f,$fc00,$03f0
                DC.W $7ffc,$f11e,$6aaa,$fffe,$2100,$3d,$17,$4040
                DC.W $02,$0cd8,$618c,$c619,$b361,$8001,$f001,$bb00
                DC.W $387f,$fc7f,$fc00,$07e0,$00,$fffe,$2eea,$fffe
                DC.W $3d2f,$382f,$7452,$5ddc,$02,$0cde,$618f,$c799
                DC.W $bf61,$e003,$e001,$bb00,$387f,$fc7f,$fc00,$0fc0
                DC.W $00,$dff6,$222a,$fffe,$3d2f,$a827,$5450,$5dd4
                DC.W $3b8e,$0cde,$618f,$c799,$bf61,$e007,$c003,$bb80
                DC.W $387f,$fc7f,$fc00,$1f80,$7ffc,$cfe6,$2eee,$7ffc
                DC.W $052a,$a823,$5550,$5554,$7bde,$0cd8,$618c,$c619
                DC.W $bc61,$800f,$8003,$bb80,$3800,$00,$00,$3f00
                DC.W $7ffc,$6aac,$2eee,$7ffc,$052a,$b821,$7550,$555c
                DC.W $4a52,$0cd8,$618c,$c619,$be61,$801f,$07,$bbc0
                DC.W $3807,$c000,$00,$7e00,$7ffc,$755c,$00,$3ff8
                DC.W $052a,$a021,$4550,$5550,$4a52,$0cd8,$618c,$c619
                DC.W $b661,$803e,$380f,$bbe0,$3807,$c000,$1c,$7c00
                DC.W $7ffc,$3ff8,$00,$1ff0,$3daa,$b821,$77d0,$5ddc
                DC.W $6a5e,$0fdf,$7d8c,$c61f,$b77d,$f07c,$7c1f,$bbf0
                DC.W $3807,$c000,$3c,$7800,$00,$1ff0,$00,$0fe0
                DC.W $3daa,$b821,$77d0,$5ddc,$6a5e,$0fdf,$7d8c,$c61f
                DC.W $b37d,$f078,$7cff,$39fe,$00,$00,$78,$7000
                DC.W $00,$07c0,$00,$0fe0,$00,$00,$00,$00
                DC.W $00,$0fdf,$7d8c,$c61f,$b37d,$f070,$38ff,$39fe
                DC.W $f000,$00,$f0,$6000,$00,$00,$00,$0fe0
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $00,$00,$fe,$38fe,$e000,$00,$e0,$00
                DC.W $00,$00,$00,$0fe0,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$00,$00,$f8,$383e



                BSS
scrollcounter:  DS.W 1
scrollpointer:  DS.L 1
scrollpointer2: DS.L 1
key:            DS.W 1
oldstack:       DS.L 1
                IFEQ diskversion
hbl_buff:       DS.W 12
                ENDC
screenmem:      DS.L 1
scrollbuff:     DS.B zeichen*18*4 ; Anzahl Bytes*Hîhe*Anzahl Shifts
                DS.B 512
fatscreen:      DS.B 64000	
                DS.B 512
stack:
                END
