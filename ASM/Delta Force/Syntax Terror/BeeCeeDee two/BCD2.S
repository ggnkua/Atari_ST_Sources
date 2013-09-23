*********************************************************************
***                                                               ***
***                      Ugglywobbly (BCD II)                     ***
***                    ~~~~~~~~~~~~~~~~~~~~~~~                    ***
***                written by New Mode of Delta Force             ***
***---------------------------------------------------------------***
***            Programmerstellung begann am: 03.10.90             ***
***            Aktuelles Datum             : 01.11.90             ***
***---------------------------------------------------------------***
*********************************************************************


diskversion     EQU 0           ; 0=Harddisk, 1=Disk

                IFEQ diskversion
                OPT X+
		ENDC
		IFNE diskversion
                OPT X-
                ORG $1000
                OUTPUT 'E:\WRITE\SIDE1\BCD2.IMG'
                ENDC



start:          lea     bssstart,A0          ; BSS-Segment lîschen
                lea     bssende,A1
clrbss:         clr.l   (A0)+
                cmpa.l  A1,A0
                blt.s   clrbss

                IFEQ diskversion
                clr.l   -(A7)
                move.w  #32,-(A7)            ; in Supervisor gehen
                trap    #1
                addq.l  #6,A7
                move.l  D0,ssp

                move.w  #4,-(A7)
                trap    #14                  ; Auflîsung ?
                addq.l  #2,A7
                cmp.w   #2,D0
                beq     ganzraus             ; bei Monochrom ganz beenden
                move.w  D0,oldres

                move.w  #2,-(A7)
                trap    #14
                addq.l  #2,A7
                move.l  D0,physbase

                move.w  #3,-(A7)
                trap    #14
                addq.l  #2,A7
                move.l  D0,logbase

                bsr     maus_aus

                movem.l $ffff8240.w,D0-D7    ; Farben retten
                movem.l D0-D7,oldpal


                move.b  $ffff820a.w,oldsync
                bsr     vsync
                move.b  #2,$ffff820a.w       ; 50HZ
                clr.b   $ffff8260.w          ; Lowres
                ENDC

                movem.l palette(PC),D0-D7
                movem.l D0-D7,$ffff8240.w

                move.l  #screenbase,D0
                and.l   #-256,D0
                move.l  D0,oldscreen
                move.l  D0,screenpoint

                movea.l oldscreen(PC),A0
                bsr     cls
                movea.l oldscreen(PC),A0
                lea     32000(A0),A0
                bsr     cls                  ; beide Screens lîschen

                move.l  oldscreen(PC),D0
                bsr     setscreen

                bsr     makecolors

                moveq   #1,D0
                jsr     music

                bsr     preparescroller

                bsr     makebox

                bsr     preshiftlogos

                bsr     makebigfont

                movem.l palette,D0-D7
                movem.l D0-D7,$ffff8240.w

                bsr     hbl_on               ; Interrupts anschalten

                clr.b   key
mainloop:       cmpi.b  #$39,key             ; Space gedrÅckt?
                bne.s   mainloop


ende:           bsr     hbl_off

                moveq   #0,D0
                jsr     music

                IFEQ diskversion
                bsr     vsync                ; wegen Sync!
                move.b  oldsync,$ffff820a.w

                movem.l oldpal,D0-D7
                movem.l D0-D7,$ffff8240.w    ; alte Palette

                bsr     maus_an

                move.w  oldres,-(A7)
                move.l  physbase,-(A7)
                move.l  logbase,-(A7)
                move.w  #5,-(A7)
                trap    #14
                lea     12(A7),A7            ; alte Screens

                move.l  ssp,-(A7)
                move.w  #32,-(A7)
                trap    #1
                addq.l  #6,A7                ; aus Supervisor raus

ganzraus:       clr.w   -(A7)
                trap    #1                   ; und tschÅû!
		ENDC
		
		IFNE diskversion
                moveq   #0,D0
                jmp     $0500.w              ; in MCP zurÅck
                ENDC


makebox:        lea     box,A0
                lea     300*40(A0),A1
                lea     boxbuffer,A2
                move.w  #1999,D0             ; 2000 Zeilen
makeboxloop:    moveq   #19,D1               ; 20 Worte pro Zeile
boxloop1:       move.w  (A0)+,(A2)+
                move.w  (A1)+,(A2)+
                dbra    D1,boxloop1
                cmpa.l  #boxende,A1
                bne.s   nixendfuckbox
                lea     box,A1
nixendfuckbox:  dbra    D0,makeboxloop

                rts


laufcount:      DC.W 0          ; welche Bits geholt werden

zeichpoint1:    DC.L chars8     ; Pointer auf 8 Pixel Zeichen
zeichpoint2:    DC.L chars8

laufschrift:
; Scroller in der Mitte, der aus Blîcken aufgebaut wird
; 7*3 Scanlines hoch

                movea.l laufpointer1,A0      ; Buffer nach vorne
                lea     4(A0),A0
                moveq   #20,D0               ; 21 Scanlines (nur 5 wegen flackern)
movebuff:       movem.l (A0)+,D1-D5          ; 5 Longs holen
                movem.l D1-D5,-24(A0)
                movem.l (A0)+,D1-D5          ; 5 Longs holen
                movem.l D1-D5,-24(A0)
                movem.l (A0)+,D1-D5          ; 5 Longs holen
                movem.l D1-D5,-24(A0)
                movem.l (A0)+,D1-D4          ; 5 Longs holen
                movem.l D1-D4,-20(A0)
                lea     4(A0),A0
                dbra    D0,movebuff

                move.w  laufcount,D0
                subq.w  #1,D0
                and.w   #15,D0               ; Bittest 1
                move.w  D0,laufcount
                move.w  D0,D1
                subq.w  #1,D1
                and.w   #15,D1               ; Bittest 2

                tst.w   D0
                bne.s   nixpos0
                lea     zeichpoint1,A0       ; Pointer 1 berechnen
                bsr     berechenpoint
nixpos0:        cmp.w   #15,D0
                bne.s   nixpos1
                lea     zeichpoint2,A0       ; Pointer 2 berechnen
                bsr     berechenpoint
nixpos1:


                movea.l zeichpoint1,A0       ; Zwei Zeichen
                movea.l zeichpoint2,A1

                lea     block,A2
                move.w  (A2)+,D3
                move.w  (A2)+,D4
                move.w  (A2)+,D5

                moveq   #0,D7

                moveq   #6,D2                ; 7 Zeilen
                movea.l laufpointer1,A2
                lea     76(A2),A2
anhaeng:        move.b  (A0),D6
                lsl.w   #8,D6
                move.b  (A1),D6
                btst    D0,D6
                bne.s   nix1
                movep.w D7,0(A2)
                movep.w D7,80(A2)
                movep.w D7,160(A2)
                bra.s   nix10
nix1:           movep.w D3,0(A2)
                movep.w D4,80(A2)
                movep.w D5,160(A2)
nix10:          btst    D1,D6
                bne.s   nix2
                movep.w D7,1(A2)
                movep.w D7,81(A2)
                movep.w D7,161(A2)
                bra.s   nix20
nix2:           movep.w D3,1(A2)
                movep.w D4,81(A2)
                movep.w D5,161(A2)
nix20:          lea     240(A2),A2
                lea     32(A0),A0
                lea     32(A1),A1
                dbra    D2,anhaeng


                movea.l screenpoint(PC),A1
                lea     70*160+4(A1),A1
                lea     192*160(A1),A2
                lea     -8*160(A1),A1

                moveq   #7,D0
                moveq   #0,D2
fuck5:          move.l  D2,(A1)
                move.l  D2,(A2)
                move.l  D2,8(A1)
                move.l  D2,8(A2)
                move.l  D2,16(A1)
                move.l  D2,16(A2)
                move.l  D2,24(A1)
                move.l  D2,24(A2)
                move.l  D2,32(A1)
                move.l  D2,32(A2)
                move.l  D2,40(A1)
                move.l  D2,40(A2)
                move.l  D2,48(A1)
                move.l  D2,48(A2)
                move.l  D2,56(A1)
                move.l  D2,56(A2)
                move.l  D2,64(A1)
                move.l  D2,64(A2)
                move.l  D2,72(A1)
                move.l  D2,72(A2)
                move.l  D2,80(A1)
                move.l  D2,80(A2)
                move.l  D2,88(A1)
                move.l  D2,88(A2)
                move.l  D2,96(A1)
                move.l  D2,96(A2)
                move.l  D2,104(A1)
                move.l  D2,104(A2)
                move.l  D2,112(A1)
                move.l  D2,112(A2)
                move.l  D2,120(A1)
                move.l  D2,120(A2)
                move.l  D2,128(A1)
                move.l  D2,128(A2)
                move.l  D2,136(A1)
                move.l  D2,136(A2)
                move.l  D2,144(A1)
                move.l  D2,144(A2)
                move.l  D2,152(A1)
                move.l  D2,152(A2)
                lea     160(A1),A1
                lea     160(A2),A2
                dbra    D0,fuck5


                movea.l laufpointer1,A0
                moveq   #6,D0                ; 7 Zeilen
paintscroller:  move.l  (A0)+,(A1)
                move.l  (A0)+,8(A1)
                move.l  (A0)+,16(A1)
                move.l  (A0)+,24(A1)
                move.l  (A0)+,32(A1)
                move.l  (A0)+,40(A1)
                move.l  (A0)+,48(A1)
                move.l  (A0)+,56(A1)
                move.l  (A0)+,64(A1)
                move.l  (A0)+,72(A1)
                move.l  (A0)+,80(A1)
                move.l  (A0)+,88(A1)
                move.l  (A0)+,96(A1)
                move.l  (A0)+,104(A1)
                move.l  (A0)+,112(A1)
                move.l  (A0)+,120(A1)
                move.l  (A0)+,128(A1)
                move.l  (A0)+,136(A1)
                move.l  (A0)+,144(A1)
                move.l  (A0)+,152(A1)
                lea     160(A1),A1
                movem.l (A0)+,D2-D7/A2-A3/A5-A6 ; 10 Longs holen
                move.l  D2,(A1)
                move.l  D3,8(A1)
                move.l  D4,16(A1)
                move.l  D5,24(A1)
                move.l  D6,32(A1)
                move.l  D7,40(A1)
                move.l  A2,48(A1)
                move.l  A3,56(A1)
                move.l  A5,64(A1)
                move.l  A6,72(A1)
                move.l  D2,160(A1)
                move.l  D3,168(A1)
                move.l  D4,176(A1)
                move.l  D5,184(A1)
                move.l  D6,192(A1)
                move.l  D7,200(A1)
                move.l  A2,208(A1)
                move.l  A3,216(A1)
                move.l  A5,224(A1)
                move.l  A6,232(A1)
                move.l  D2,320(A1)
                move.l  D3,328(A1)
                move.l  D4,336(A1)
                move.l  D5,344(A1)
                move.l  D6,352(A1)
                move.l  D7,360(A1)
                move.l  A2,368(A1)
                move.l  A3,376(A1)
                move.l  A5,384(A1)
                move.l  A6,392(A1)
                move.l  D2,480(A1)
                move.l  D3,488(A1)
                move.l  D4,496(A1)
                move.l  D5,504(A1)
                move.l  D6,512(A1)
                move.l  D7,520(A1)
                move.l  A2,528(A1)
                move.l  A3,536(A1)
                move.l  A5,544(A1)
                move.l  A6,552(A1)
                move.l  D2,640(A1)
                move.l  D3,648(A1)
                move.l  D4,656(A1)
                move.l  D5,664(A1)
                move.l  D6,672(A1)
                move.l  D7,680(A1)
                move.l  A2,688(A1)
                move.l  A3,696(A1)
                move.l  A5,704(A1)
                move.l  A6,712(A1)
                move.l  D2,800(A1)
                move.l  D3,808(A1)
                move.l  D4,816(A1)
                move.l  D5,824(A1)
                move.l  D6,832(A1)
                move.l  D7,840(A1)
                move.l  A2,848(A1)
                move.l  A3,856(A1)
                move.l  A5,864(A1)
                move.l  A6,872(A1)
                lea     80(A1),A1

                movem.l (A0)+,D2-D7/A2-A3/A5-A6 ; 10 Longs holen
                move.l  D2,(A1)
                move.l  D3,8(A1)
                move.l  D4,16(A1)
                move.l  D5,24(A1)
                move.l  D6,32(A1)
                move.l  D7,40(A1)
                move.l  A2,48(A1)
                move.l  A3,56(A1)
                move.l  A5,64(A1)
                move.l  A6,72(A1)
                move.l  D2,160(A1)
                move.l  D3,168(A1)
                move.l  D4,176(A1)
                move.l  D5,184(A1)
                move.l  D6,192(A1)
                move.l  D7,200(A1)
                move.l  A2,208(A1)
                move.l  A3,216(A1)
                move.l  A5,224(A1)
                move.l  A6,232(A1)
                move.l  D2,320(A1)
                move.l  D3,328(A1)
                move.l  D4,336(A1)
                move.l  D5,344(A1)
                move.l  D6,352(A1)
                move.l  D7,360(A1)
                move.l  A2,368(A1)
                move.l  A3,376(A1)
                move.l  A5,384(A1)
                move.l  A6,392(A1)
                move.l  D2,480(A1)
                move.l  D3,488(A1)
                move.l  D4,496(A1)
                move.l  D5,504(A1)
                move.l  D6,512(A1)
                move.l  D7,520(A1)
                move.l  A2,528(A1)
                move.l  A3,536(A1)
                move.l  A5,544(A1)
                move.l  A6,552(A1)
                move.l  D2,640(A1)
                move.l  D3,648(A1)
                move.l  D4,656(A1)
                move.l  D5,664(A1)
                move.l  D6,672(A1)
                move.l  D7,680(A1)
                move.l  A2,688(A1)
                move.l  A3,696(A1)
                move.l  A5,704(A1)
                move.l  A6,712(A1)
                move.l  D2,800(A1)
                move.l  D3,808(A1)
                move.l  D4,816(A1)
                move.l  D5,824(A1)
                move.l  D6,832(A1)
                move.l  D7,840(A1)
                move.l  A2,848(A1)
                move.l  A3,856(A1)
                move.l  A5,864(A1)
                move.l  A6,872(A1)

                lea     960-80(A1),A1

                move.l  (A0)+,(A1)
                move.l  (A0)+,8(A1)
                move.l  (A0)+,16(A1)
                move.l  (A0)+,24(A1)
                move.l  (A0)+,32(A1)
                move.l  (A0)+,40(A1)
                move.l  (A0)+,48(A1)
                move.l  (A0)+,56(A1)
                move.l  (A0)+,64(A1)
                move.l  (A0)+,72(A1)
                move.l  (A0)+,80(A1)
                move.l  (A0)+,88(A1)
                move.l  (A0)+,96(A1)
                move.l  (A0)+,104(A1)
                move.l  (A0)+,112(A1)
                move.l  (A0)+,120(A1)
                move.l  (A0)+,128(A1)
                move.l  (A0)+,136(A1)
                move.l  (A0)+,144(A1)
                move.l  (A0)+,152(A1)
                lea     160(A1),A1
                dbra    D0,paintscroller

                move.l  laufpointer1,D0      ; Pointer tauschen
                move.l  laufpointer2,laufpointer1
                move.l  D0,laufpointer2

                rts


berechenpoint:
; in a0=Pointer auf Pointer
                addq.l  #1,textpos
                movea.l textpos(PC),A1
                tst.b   (A1)                 ; Ende?
                bpl.s   isoktext
                lea     text,A1
isoktext:       move.l  A1,textpos
                moveq   #0,D2
                move.b  (A1),D2
                sub.b   #' ',D2
                cmp.b   #32,D2
                blt.s   fu
                and.w   #31,D2
                add.w   #7*32,D2
fu:             lea     chars8,A1
                adda.w  D2,A1
                move.l  A1,(A0)
                rts
makebigfont:
; Pumpt TEX-Zeichensatz auf-> 1 Pixel wird zu einem Byte (Font 30 breit!)

                lea     bigchars,A0
                lea     bigfontbuff,A1
                moveq   #0,D0                ; ZeichenzÑhler
makebigfontl0:  moveq   #15,D1               ; 16 Scanlines hoch
                movea.l A0,A2
makebigfontl1:  move.l  (A2),D3              ; 32 Bits holen
                lsl.l   #1,D3                ; linkes Bit raus
                moveq   #29,D2               ; 30 Pixel
makebigfontl2:  lsl.l   #1,D3                ; Bit rausschieben
                bcc.s   nixbitset            ; Pixel gesetzt oder nicht gesetzt
                move.b  #-1,(A1)+
                bra.s   bitwasset
nixbitset:      move.b  #0,(A1)+
bitwasset:      dbra    D2,makebigfontl2
                lea     40(A2),A2            ; eine Zeile tiefer
                dbra    D1,makebigfontl1
                lea     30(A1),A1            ; eine Zeile Åberspringen (leer)
                lea     4(A0),A0             ; nÑchstes Zeichen
                addq.w  #1,D0
                cmp.w   #50,D0
                beq.s   endmake              ; fertig!
                moveq   #0,D1
                move.w  D0,D1
                divu    #10,D1
                swap    D1
                tst.w   D1                   ; Rest<>0
                bne.s   makebigfontl0
                lea     15*40(A0),A0
                bra.s   makebigfontl0
endmake:        rts






copylogo2:      movea.l screenpoint(PC),A1
                lea     146*160+32+4(A1),A1
                lea     50*160(A1),A2
                lea     -8*160(A1),A1
                lea     preshiftbuff+(50*16*13*4),A3

                addq.l  #2,wabbeldpos2
                movea.l wabbeldpos2(PC),A5
                cmpa.l  #deltaende,A5
                bne.s   nixenddelta2
                lea     delta(PC),A5
nixenddelta2:   move.l  A5,wabbeldpos2

                bra     fuck2



copylogo:       movea.l screenpoint(PC),A1
                lea     4*160+32+4(A1),A1
                lea     192*160(A1),A2
                lea     -8*160(A1),A1
                lea     preshiftbuff,A3

                subq.l  #2,wabbeldpos1
                movea.l wabbeldpos1(PC),A5
                cmpa.l  #delta,A5
                bne.s   nixenddelta1
                lea     deltaende(PC),A5
nixenddelta1:   move.l  A5,wabbeldpos1


fuck2:          moveq   #7,D0
                moveq   #0,D2
fuck3:          move.l  D2,(A1)
                move.l  D2,(A2)
                move.l  D2,8(A1)
                move.l  D2,8(A2)
                move.l  D2,16(A1)
                move.l  D2,16(A2)
                move.l  D2,24(A1)
                move.l  D2,24(A2)
                move.l  D2,32(A1)
                move.l  D2,32(A2)
                move.l  D2,40(A1)
                move.l  D2,40(A2)
                move.l  D2,48(A1)
                move.l  D2,48(A2)
                move.l  D2,56(A1)
                move.l  D2,56(A2)
                move.l  D2,64(A1)
                move.l  D2,64(A2)
                move.l  D2,72(A1)
                move.l  D2,72(A2)
                move.l  D2,80(A1)
                move.l  D2,80(A2)
                move.l  D2,88(A1)
                move.l  D2,88(A2)
                move.l  D2,96(A1)
                move.l  D2,96(A2)
                lea     160(A1),A1
                lea     160(A2),A2
                dbra    D0,fuck3

                movea.l A3,A2
                moveq   #49,D0
fuckl1:         movea.l A2,A0
                adda.w  (A5)+,A0
                move.l  (A0)+,(A1)
                move.l  (A0)+,8(A1)
                move.l  (A0)+,16(A1)
                move.l  (A0)+,24(A1)
                move.l  (A0)+,32(A1)
                move.l  (A0)+,40(A1)
                move.l  (A0)+,48(A1)
                move.l  (A0)+,56(A1)
                move.l  (A0)+,64(A1)
                move.l  (A0)+,72(A1)
                move.l  (A0)+,80(A1)
                move.l  (A0)+,88(A1)
                move.l  (A0)+,96(A1)
                lea     160(A1),A1
                lea     16*13*4(A2),A2
                dbra    D0,fuckl1

                rts

scroll:         subq.w  #1,bigscrollcount
                bpl.s   nixnewchar

                addq.l  #1,textpos2
                movea.l textpos2,A0
                tst.b   (A0)
                bpl.s   nixendtext
                lea     text2,A0
nixendtext:     move.l  A0,textpos2
                moveq   #0,D0
                move.b  (A0),D0              ; Zeichen holen
                mulu    #30*17,D0
                lea     bigfontbuff,A0
                adda.l  D0,A0
                move.l  A0,charpoint
                move.w  #16,bigscrollcount

nixnewchar:
                movea.l screenpoint,A0
                lea     -8*160+18(A0),A1
                lea     192*160+18(A0),A0
                movea.l charpoint(PC),A2

                moveq   #2,D6                ; 4 Mal
copybigscroll:
                movem.w (A2)+,D0-D4
                move.w  D0,(A0)
                move.w  D0,320(A0)
                move.w  D0,320*2(A0)
                move.w  D0,320*3(A0)
                move.w  D0,(A1)
                move.w  D0,320(A1)
                move.w  D0,320*2(A1)
                move.w  D0,320*3(A1)

                move.w  D1,8(A0)
                move.w  D1,8+320(A0)
                move.w  D1,8+320*2(A0)
                move.w  D1,8+320*3(A0)
                move.w  D1,8(A1)
                move.w  D1,8+320(A1)
                move.w  D1,8+320*2(A1)
                move.w  D1,8+320*3(A1)

                move.w  D2,16(A0)
                move.w  D2,16+320(A0)
                move.w  D2,16+320*2(A0)
                move.w  D2,16+320*3(A0)
                move.w  D2,16(A1)
                move.w  D2,16+320(A1)
                move.w  D2,16+320*2(A1)
                move.w  D2,16+320*3(A1)

                move.w  D3,24(A0)
                move.w  D3,24+320(A0)
                move.w  D3,24+320*2(A0)
                move.w  D3,24+320*3(A0)
                move.w  D3,24(A1)
                move.w  D3,24+320(A1)
                move.w  D3,24+320*2(A1)
                move.w  D3,24+320*3(A1)

                move.w  D4,32(A0)
                move.w  D4,32+320(A0)
                move.w  D4,32+320*2(A0)
                move.w  D4,32+320*3(A0)
                move.w  D4,32(A1)
                move.w  D4,32+320(A1)
                move.w  D4,32+320*2(A1)
                move.w  D4,32+320*3(A1)

                lea     40(A0),A0
                lea     40(A1),A1
                dbra    D6,copybigscroll


                addi.l  #30,charpoint


; kleiner Scroller
                movea.l dpos(PC),A0
                tst.w   (A0)
                bpl.s   deltaisok
                lea     deltatab(PC),A0
deltaisok:      moveq   #0,D0
                moveq   #0,D1
                move.w  (A0)+,D0             ; Wert aus Tabelle holen
                move.l  A0,dpos
                move.w  D0,D1
                and.w   #15,D1
                mulu    #zeichen*4,D1
                lea     scrollbuff,A0
                adda.l  D1,A0

                and.w   #-16,D0
                lsr.w   #3,D0
                adda.l  D0,A0

                movea.l screenpoint(PC),A1
                lea     -8*160(A1),A2
                lea     192*160(A1),A1
                moveq   #3,D0                ; 4 Zeilen
copyscroller1:  movem.w (A0)+,D1-D7/A3/A5-A6 ; 10 Worte
                move.w  D1,(A1)
                move.w  D1,(A2)
                move.w  D2,8(A1)
                move.w  D2,8(A2)
                move.w  D3,16(A1)
                move.w  D3,16(A2)
                move.w  D4,24(A1)
                move.w  D4,24(A2)
                move.w  D5,32(A1)
                move.w  D5,32(A2)
                move.w  D6,40(A1)
                move.w  D6,40(A2)
                move.w  D7,48(A1)
                move.w  D7,48(A2)
                move.w  A3,56(A1)
                move.w  A3,56(A2)
                move.w  A5,64(A1)
                move.w  A5,64(A2)
                move.w  A6,72(A1)
                move.w  A6,72(A2)
                movem.w (A0)+,D1-D7/A3/A5-A6 ; 10 Worte
                move.w  D1,80(A1)
                move.w  D1,80(A2)
                move.w  D2,88(A1)
                move.w  D2,88(A2)
                move.w  D3,96(A1)
                move.w  D3,96(A2)
                move.w  D4,104(A1)
                move.w  D4,104(A2)
                move.w  D5,112(A1)
                move.w  D5,112(A2)
                move.w  D6,120(A1)
                move.w  D6,120(A2)
                move.w  D7,128(A1)
                move.w  D7,128(A2)
                move.w  A3,136(A1)
                move.w  A3,136(A2)
                move.w  A5,144(A1)
                move.w  A5,144(A2)
                move.w  A6,152(A1)
                move.w  A6,152(A2)
                lea     320(A1),A1
                lea     320(A2),A2
                lea     zeichen-40(A0),A0
                dbra    D0,copyscroller1

                addi.l  #8*160,screenpoint
                addq.w  #1,scrollcount
                cmpi.w  #25,scrollcount
                bne.s   nix
                clr.w   scrollcount
                move.l  oldscreen(PC),screenpoint
nix:
                rts

preshiftlogos:
; Preshiftet das 2 Plane Logo (50 hoch, 192 Breit)

                lea     dflogo,A0            ; DELTA
                lea     preshiftbuff,A1
                bsr     preshift
                lea     dflogo+(50*12*4),A0  ; FORCE
                lea     preshiftbuff+(16*13*4*50),A1
                bsr     preshift
                rts

preshift:
                moveq   #49,D1               ; ZeilenzÑhler=50
preshiftloop:   moveq   #0,D0                ; Preshiftcounter
preshiftloop1:  movea.l A0,A2
                moveq   #11,D2               ; 12 Bitblocks breit
                moveq   #0,D3                ; Einoderwerte auf 0
                moveq   #0,D4
preshiftloop2:  moveq   #0,D5
                move.w  (A2)+,D5             ; Grafikwert (P0)
                ror.l   D0,D5
                or.w    D3,D5
                move.w  D5,(A1)+
                swap    D5
                move.w  D5,D3
                moveq   #0,D5
                move.w  (A2)+,D5             ; Grafikwert (P1)
                ror.l   D0,D5
                or.w    D4,D5
                move.w  D5,(A1)+
                swap    D5
                move.w  D5,D4
                dbra    D2,preshiftloop2
                move.w  D3,(A1)+
                move.w  D4,(A1)+
                addq.w  #1,D0
                cmp.w   #16,D0
                bne.s   preshiftloop1
                lea     12*4(A0),A0
                dbra    D1,preshiftloop
                rts



converttext:
                lea     scrolltext,A0
                movea.l A0,A1
                movea.l #contab,A2

prepare:        cmpa.l  #scrollende,A0
                beq.s   convende
                moveq   #0,D0
                move.b  (A0)+,D0
                move.b  0(A2,D0.w),(A1)+
                bra.s   prepare
convende:       rts

;-----------------------------
contab:         DCB.B 33,26      ; 0-32
                DC.B 40,42,26,26,26,26,43,44,45,26,46,48,47,37,49 ; Sonder
                DC.B 27,28,29,30,31,32,33,34,35,36 ; 0-9
                DC.B 38,39,26,26,26,41,26 ; Sonder
                DC.B 0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17
                DC.B 18,19,20,21,22,23,24,25 ; A-Z
                EVEN





preparescroller:
                bsr     converttext

                lea     scrollbuff,A0
                move.l  #(zeichen*4*4)-1,D0
clrscrollbuff:  clr.l   (A0)+
                subq.l  #1,D0
                bne.s   clrscrollbuff

                lea     scrolltext(PC),A0
                lea     scrollbuff,A1
                move.w  #zeichen-1,D0
puttextinbuff:
                moveq   #0,D1
                move.b  (A0)+,D1             ; ASCII holen
                moveq   #0,D2
                move.w  D1,D2
                lea     charset(PC),A2
                divu    #40,D2
                move.w  D2,D1
                swap    D2
                adda.w  D2,A2
                mulu    #160,D1
                adda.w  D1,A2

                move.b  (A2),(A1)            ; nur 4 Scanlines hoch
                move.b  40(A2),zeichen*1(A1)
                move.b  80(A2),zeichen*2(A1)
                move.b  120(A2),zeichen*3(A1)
                addq.l  #1,A1
                dbra    D0,puttextinbuff

                lea     scrollbuff,A1        ; in 16 Buffer kopieren
                lea     zeichen*4(A1),A1     ; auf zweite Pos.
                moveq   #14,D0               ; 15 mal Kopieren
copyscroller:   lea     scrollbuff,A0
                move.w  #(zeichen*4)-1,D1
copyscroll1:    move.b  (A0)+,(A1)+
                dbra    D1,copyscroll1
                dbra    D0,copyscroller

                lea     scrollbuff+(zeichen*5),A0 ; 1.Buffer (Ende)
                moveq   #1,D0                ; Schiebwert
shiftscroller:  moveq   #3,D1                ; 4 Zeilen
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
                addq.w  #1,D0
                cmp.w   #16,D0
                bne.s   shiftscroller
                rts



makecolors:
; erstellt Farbwerte

                lea     hblcolbuff,A0        ; Dort kommen die Farben rein
                lea     hblcols1,A1
                lea     hblcols4,A2
                lea     hblcols3,A3
                lea     hblcolsscroller,A4
                lea     hblcols2+50,A5
                moveq   #99,D0               ; 90 Farbwerte
makecolloop:
                move.w  (A4)+,(A0)+

                move.l  #$030003,(A0)+
;                move.w  (A5),(A0)+
;                move.w  (A5)+,(A0)+

                move.w  (A1)+,(A0)+
                move.w  (A2)+,(A0)+
                move.w  (A3)+,(A0)+
                dbra    D0,makecolloop
                clr.l   (A0)+
                clr.w   (A0)+
                move.w  #-1,(A0)             ; Endekennung
                rts


coldelay:       DC.W 0

umblend1:
; Blendet Farben fÅr Wabbler1 um

                addq.w  #1,coldelay
                andi.w  #3,coldelay
                beq.s   do_umblend           ; jedes 4te Mal umblenden
                rts
do_umblend:     lea     palette+8,A0         ; dort kommen Farben rein
                movea.l colpointer,A1        ; auf diese Palette umblenden
                bsr     machumblend
                cmp.w   #3,D3                ; 3 gleiche Farben?
                blt.s   nixnextpalette

                addi.l  #6,colpointer        ; nÑchste Palette
                movea.l colpointer,A0
                cmpi.w  #-1,(A0)
                bne.s   nixendumblend
                lea     umblendfarben,A0
nixendumblend:  move.l  A0,colpointer
                move.l  #nothing,fuckroutine+2
nixnextpalette: rts


coldelay2:      DC.W 0

umblend2:
; Blendet Farben fÅr Scroller um

                addq.w  #1,coldelay2
                andi.w  #3,coldelay2
                beq.s   do_umblend2          ; jedes 4te Mal umblenden
                rts
do_umblend2:    lea     palette2,A0          ; dort kommen Farben rein
                movea.l colpointer2,A1       ; auf diese Palette umblenden
                bsr     machumblend
                cmp.w   #3,D3                ; 3 gleiche Farben?
                blt.s   nixnextpalette2

                addi.l  #6,colpointer2       ; nÑchste Palette
                movea.l colpointer2,A0
                cmpi.w  #-1,(A0)
                bne.s   nixendumblend2
                lea     umblendfarben,A0
nixendumblend2: move.l  A0,colpointer2
                move.l  #nothing2,fuckroutine2+2
nixnextpalette2:rts

coldelay3:      DC.W 0

umblend3:
; Blendet Farben fÅr Wabbler2 um

                addq.w  #1,coldelay3
                andi.w  #3,coldelay3
                beq.s   do_umblend3          ; jedes 4te Mal umblenden
                rts
do_umblend3:    lea     palette3,A0          ; dort kommen Farben rein
                movea.l colpointer3,A1       ; auf diese Palette umblenden
                bsr     machumblend
                cmp.w   #3,D3                ; 3 gleiche Farben?
                blt.s   nixnextpalette3

                addi.l  #6,colpointer3       ; nÑchste Palette
                movea.l colpointer3,A0
                cmpi.w  #-1,(A0)
                bne.s   nixendumblend3
                lea     umblendfarben,A0
nixendumblend3: move.l  A0,colpointer3
                move.l  #nothing3,fuckroutine3+2
nixnextpalette3:rts



machumblend:    moveq   #2,D0                ; 3 Farben
                moveq   #0,D3
umblendloop:    move.w  (A0),D5              ; diese Farbe wird umgeblendet
                move.w  (A1)+,D6             ; auf diese Farbe
                move.w  D5,D1
                move.w  D6,D2
                and.w   #7,D1                ; Bits 0-3=Blauwert
                and.w   #7,D2                ; Bits 0-3=Blauwert
                cmp.w   D1,D2
                beq.s   blauwertok
                bgt.s   blauwertklein
                subi.w  #$01,D5              ; Blau-1
                bra.s   blauwertok
blauwertklein:  addi.w  #$01,D5              ; Blau+1
blauwertok:     move.w  D5,D1                ; diese Farbe wird umgeblendet
                move.w  D6,D2                ; auf diese Farbe
                and.w   #%1110000,D1         ; Bits 4-7=GrÅnwert
                and.w   #%1110000,D2         ; Bits 4-7=GrÅnwert
                cmp.w   D1,D2
                beq.s   gruenwertok
                bgt.s   gruenwertklein
                subi.w  #$10,D5              ; GrÅn-1
                bra.s   gruenwertok
gruenwertklein: addi.w  #$10,D5              ; GrÅn+1
gruenwertok:    move.w  D5,D1                ; diese Farbe wird umgeblendet
                move.w  D6,D2                ; auf diese Farbe
                and.w   #%11100000000,D1     ; Rotwert
                and.w   #%11100000000,D2     ; Rotwert
                cmp.w   D1,D2
                beq.s   rotwertok
                bgt.s   rotwertklein
                subi.w  #$0100,D5            ; Rot-1
                bra.s   rotwertok
rotwertklein:   addi.w  #$0100,D5            ; Rot+1
rotwertok:      move.w  D5,(A0)+
                move.w  D5,(A0)+
                move.w  D5,(A0)+
                move.w  D5,(A0)+
                cmp.w   D5,D6
                bne.s   nixcolgleich
                addq.w  #1,D3                ; Gleiche Farben zÑhlen
nixcolgleich:   dbra    D0,umblendloop
                rts

verzoeger:      DC.W 300

nothing:        subq.w  #1,verzoeger
                bne.s   nixendverz
                move.l  #umblend1,fuckroutine+2
                move.w  #300,verzoeger
nixendverz:     rts

verzoeger2:     DC.W 450

nothing2:       subq.w  #1,verzoeger2
                bne.s   nixendverz2
                move.l  #umblend2,fuckroutine2+2
                move.w  #300,verzoeger2
nixendverz2:    rts

verzoeger3:     DC.W 600

nothing3:       subq.w  #1,verzoeger3
                bne.s   nixendverz3
                move.l  #umblend3,fuckroutine3+2
                move.w  #300,verzoeger3
nixendverz3:    rts

drawbox:
; zeichnet die Box in Plane 0

                addi.l  #80,boxpointer
                movea.l boxpointer(PC),A0
                cmpa.l  #boxbuffende,A0
                bne.s   nixendbox
                lea     boxbuffer,A0
nixendbox:      move.l  A0,boxpointer

                movea.l screenpoint(PC),A5
                lea     160(A5),A5
weiterbox:      movea.l A5,A1
                movem.l (A0)+,D1-D7/A2-A3/A6 ; 10 Worte der Box holen (links)

                moveq   #99,D0               ; 100 Zeilen hoch
copylefthalf:   move.l  D1,(A1)
                move.l  D2,8(A1)
                move.l  D3,16(A1)
                move.l  D4,24(A1)
                move.l  D5,32(A1)
                move.l  D6,40(A1)
                move.l  D7,48(A1)
                move.l  A2,56(A1)
                move.l  A3,64(A1)
                move.l  A6,72(A1)
                lea     320(A1),A1           ; zwei Zeilen tiefer
                dbra    D0,copylefthalf

                lea     80(A5),A1
                movem.l (A0)+,D1-D7/A2-A3/A6 ; 10 Worte der Box holen (rechts)

                moveq   #99,D0               ; 100 Zeilen hoch
copyrighthalf:  move.l  D1,(A1)
                move.l  D2,8(A1)
                move.l  D3,16(A1)
                move.l  D4,24(A1)
                move.l  D5,32(A1)
                move.l  D6,40(A1)
                move.l  D7,48(A1)
                move.l  A2,56(A1)
                move.l  A3,64(A1)
                move.l  A6,72(A1)
                lea     320(A1),A1           ; zwei Zeilen tiefer
                dbra    D0,copyrighthalf

                rts





setscreen:      lsr.l   #8,D0
                move.b  D0,$ffff8203.w
                lsr.w   #8,D0
                move.b  D0,$ffff8201.w
                rts

vsync:          move.l  $0466.w,D0
waitstrahl:     cmp.l   $0466.w,D0
                beq.s   waitstrahl
                rts

                IFEQ diskversion
maus_aus:       move.w  #$12,-(A7)
                move.w  #$04,-(A7)           ; Maus-aus Signal
                move.w  #3,-(A7)
                trap    #13
                addq.l  #6,A7
                rts

maus_an:        move.w  #$08,-(A7)
                move.w  #$04,-(A7)
                move.w  #3,-(A7)
                trap    #13
                addq.l  #6,A7
                rts

                ENDC

cls:            move.w  #7999,D0
clsloop:        clr.l   (A0)+
                dbra    D0,clsloop
                rts


hbl_on:         move    SR,-(A7)
                ori     #$0700,SR
                lea     hbl_buff,A0
                move.l  $0118.w,(A0)+
                move.l  $0120.w,(A0)+
                move.l  $70.w,(A0)+
                move.b  $fffffa09.w,(A0)+    ; Werte retten
                move.b  $fffffa07.w,(A0)+
                move.b  $fffffa13.w,(A0)+
                move.b  $fffffa1b.w,(A0)+
                move.b  $fffffa11.w,(A0)+
                move.b  $fffffa21.w,(A0)+
                move.b  $fffffa17.w,(A0)+
                andi.b  #$df,$fffffa09.w     ; Timer C aus
                andi.b  #$fe,$fffffa07.w     ; Timer B aus
                move.l  #newkey,$0118.w
                move.l  #vbl,$70.w
                move.l  #hbl,$0120.w
                ori.b   #1,$fffffa07.w       ; Timer B an
                ori.b   #1,$fffffa13.w
                bclr    #3,$fffffa17.w       ; automatic EOI
                move    (A7)+,SR
                rts

hbl_off:        move    SR,-(A7)
                ori     #$0700,SR
                lea     hbl_buff,A0          ; Werte zurueck!
                move.l  (A0)+,$0118.w
                move.l  (A0)+,$0120.w
                move.l  (A0)+,$70.w
                move.b  (A0)+,$fffffa09.w
                move.b  (A0)+,$fffffa07.w
                move.b  (A0)+,$fffffa13.w
                move.b  (A0)+,$fffffa1b.w
                move.b  (A0)+,$fffffa11.w
                move.b  (A0)+,$fffffa21.w
                move.b  (A0)+,$fffffa17.w
                move    (A7)+,SR
                rts

vbl:
; !!!!!VORSICHT!!!!! Register a4 nicht verÑndern!!!!!!!!

                clr.w   hblcount

                clr.b   $fffffa1b.w
                move.b  #1,$fffffa21.w
                move.b  #8,$fffffa1b.w
                move.l  #hbl,$0120.w
                movem.l palette+8(PC),D0-D5
                movem.l D0-D5,$ffff8248.w

                lea     hblcolbuff,A4
                move.l  (A4)+,$ffff8242.w
                move.w  (A4)+,$ffff8246.w

                bsr     drawbox


                bsr     copylogo2


                bsr     scroll


                bsr     laufschrift


                bsr     copylogo



fuckroutine:    jsr     nothing
fuckroutine2:   jsr     nothing2
fuckroutine3:   jsr     nothing3

                move.l  screenpoint(PC),D0
                bsr     setscreen

                jsr     music+8
                addq.l  #1,$0466.w
                rte

delay:          DC.W 0

newkey:         move.w  D0,-(A7)
                move.b  $fffffc00.w,D0
                btst    #7,D0
                beq.s   endkey
                move.b  $fffffc02.w,key
endkey:         move.w  (A7)+,D0
                rte

hbl:            move.l  (A4)+,$ffff8242.w
                move.w  (A4)+,$ffff8246.w
                addq.w  #1,hblcount
                cmpi.w  #65,hblcount
                bne.s   hblende
                move.l  palette2(PC),$ffff8248.w
                move.l  palette2+4(PC),$ffff824c.w
                move.l  palette2+8(PC),$ffff8250.w
                move.l  palette2+12(PC),$ffff8254.w
                move.l  palette2+16(PC),$ffff8258.w
                move.l  palette2+20(PC),$ffff825c.w
                move.l  #hbl2,$0120.w
hblende:        rte

hbl2:           move.l  (A4)+,$ffff8242.w
                move.w  (A4)+,$ffff8246.w
                addq.w  #1,hblcount
                cmpi.w  #140,hblcount
                bne.s   hblende2
                move.l  palette3(PC),$ffff8248.w
                move.l  palette3+4(PC),$ffff824c.w
                move.l  palette3+8(PC),$ffff8250.w
                move.l  palette3+12(PC),$ffff8254.w
                move.l  palette3+16(PC),$ffff8258.w
                move.l  palette3+20(PC),$ffff825c.w
hblende2:       rte


                DATA

hblcount:       DC.W 0

oldscreen:      DS.L 1
screenpoint:    DS.L 1
scrollcount:    DC.W 0

textpos:        DC.L text

text:
                DC.B "     FUCK OFF! ASSHOLE!   WHY DID YOU SELECT THIS SCREEN?  WE'RE OUT OF"
                DC.B " IDEAS OF WHAT WE SHOULD WRITE, 'COZ THIS IS THE LAST SCROLLTEXT OF THE"
                DC.B " DEMO WE'RE WRITING! SCHULZ JETZT! WIR HABEN KEINEN BOCK MEHR! GO TO HELL!"
                DC.B "           OK, LET'S TRY TO FILL UP THOSE FUCKING BYTES WITH SOME ASCII'S!"
                DC.B "      WHAT'S NEXT WITH DELTA FORCE?     CHAOS, INC. WILL CONTINUE WITH"
                DC.B " HIS GAME (TO BE PRECISE: HE'S WRITING THE SEQUEL TO HIS FIRST ONE). IT"
                DC.B " WILL BE FINISHED AROUND JUNE 1991.   I (NEW MODE) WILL WRITE A DIGIDEMO"
                DC.B " (OR TWO).  I WILL ALSO DO SOME ROUTINES FOR NEOCHROME MASTER AND A SUBGAME"
                DC.B " FOR CHAOS' GAME.   SLIME WILL MARCH ON (HARHARHAR).   PERHAPS WE'LL DO SOME"
                DC.B " GAMECONVERSIONS AGAIN.    BUT FIRST THERE WILL BE A PERIOD OF LAZYNESS (GRIN)"
                DC.B " AND LEARNING, AND SO THERE WON'T BE MUCH TIME FOR WRITING DEMOS.  PERHAPS"
                DC.B " WE'LL HAVE SOME GUEST APPEARANCES IN OTHER BIG DEMOS, BUT THAT'S NOT SURE."
                DC.B "    LET'S GO TO ANOTHER TOPIC...    LET'S THINK.....  OK BUDDY! WE'LL TALK"
                DC.B " ABOUT RECENT DEMOS...      ONE OF THE BEST DEMOS I RECENTLY GOT WAS"
                DC.B " THE 'SKID ROW DEMO' BY THE GERMAN ALLIANCE...    GOSH! THEY HAVE IMPROVED"
                DC.B " VERY MUCH SINCE THEIR 'XTC-DEMO'.  WHEN I SAW THE MAINMENU, IT NEARLY"
                DC.B " KNOCKED ME OFF MY SOCKS COZ WE WANTED TO DO THE SAME THING IN A PARTYDEMO"
                DC.B " WE'VE PLANNED (OH NO!).   THE BEST SCREEN IN THE DEMO IS THE THIRD ONE"
                DC.B " BY BMT (THE ONE WITH THE ZOOMED DOG). NICE IDEA GUYS!      ANOTHER"
                DC.B " GREAT DEMO WAS THE 'LIFE'S A BITCH'-DEMO BY THE LOST BOYS (AND OTHERS)."
                DC.B " THE BEST SCREEN WAS THE 'BEAT-NICK' SCREEN. THE CLF-TECHNIQUE IS GRRREAT."
                DC.B "          THIS IS MY LAST SCREEN FOR THE DEMO AND I'M ALMOST FINISHED WITH"
                DC.B " IT (YEAAAAAHHHH!).   THIS ISN'T MY BEST SCREEN (SLIME AND CHAOS DON'T LIKE"
                DC.B " IT COZ THEY CAN'T READ THE SCROLLERS).   WHAT MEANS 'BEECEEDEE2' I HEAR"
                DC.B " YOU ASK?  THAT'S VERY SIMPLE....   DO YOU REMEMBER THE 'BIG-CHAOS-DEMO'"
                DC.B " BY CHAOS, INC.?  NO?  THAT WAS A VERY GOOD INTRO FROM US ABOUT THREE YEARS"
                DC.B " AGO. 'BEECEEDEE2' JUST STANDS FOR 'BIG-CHAOS-DEMO NO.2'.  BUT THIS TIME"
                DC.B " IT'S WRITTEN BY NEW MODE (WHO ELSE). THIS SCREEN IS DEDICATED TO THE"
                DC.B " MOST CHAOTIC GUY IN DELTA FORCE: CHAOS, INC. FOR ALL THE GREAT WORK (AND THE BUGS - GRIN!)"
                DC.B " HE HAS DONE FOR DELTA FORCE.          "
                DC.B "  WHAT CAN WE TALK ABOUT RIGHT NOW? HAVE YOU EVER PLAYED"
                DC.B " SOME GAMES ON A GAMEBOY? (THE PORTABLE VIDEOGAME FROM"
                DC.B " NINTENDO - SCHMUCK (THAT'S WHAT NICK WOULD SAY RIGHT"
                DC.B " NOW)).   VERY GOOD, ALTHOUGH IT'S JUST MONOCHROME"
                DC.B "  JUST PLAY 'SUPER MARIOLAND' (WOW!). VERY ADDICTIVE!"
                DC.B "    ANOTHER TIP FROM ME:  GO AND WATCH 'DIE HARD 2'!"
                DC.B " VERY FUNNY!               "
                DC.B "    THAT'S ALL TO IT DUDES! YEAAAAAAHHHH! OUR LAST SCROLLTEXT IS FINISHED.."
                DC.B "   LET ME DO THE WRAP....   WRRRRRRRAPPPPPP......                        "
                DC.B "                                                                   "
                DC.B -1
                EVEN




blinktab:       DC.W $00,$01,$02,$03,$04,$05,$06,$07
                DC.W $0117,$0227,$0337,$0447,$0557,$0667,$0777
                DC.W $0667,$0557,$0447,$0337,$0227,$0117,$07
                DC.W $06,$05,$04,$03,$02,$01
                DC.W -1

blinkpoint:     DC.L blinktab


palette:        DS.W 4
                DCB.W 4,$0756
                DCB.W 4,$0534
                DCB.W 4,$0312

palette2:       DCB.W 4,$0665
                DCB.W 4,$0443
                DCB.W 4,$0221

palette3:       DCB.W 4,$0565
                DCB.W 4,$0343
                DCB.W 4,$0121


wabbeldpos1:    DC.L deltaende
wabbeldpos2:    DC.L delta

delta:
                DC.W 416,416,468,468,520,520,572,572
                DC.W 624,624,676,676,676,728,728,728
                DC.W 780,780,780,780,780,780,780,780
                DC.W 780,780,780,780,780,780,728,728
                DC.W 728,676,676,676,624,624,572,572
                DC.W 520,520,468,468,416,416,364,312
                DC.W 312,260,260,208,208,156,156,104
                DC.W 104,104,52,52,52,0,0,0
                DC.W 0,0,0,0,0,0,0,0
                DC.W 0,0,0,52,52,52,104,104
                DC.W 104,156,156,208,208,260,260,312
                DC.W 312,364,364


                DC.W 416,416,468,520,520,572,624,624
                DC.W 676,676,728,728,728,780,780,780
                DC.W 780,780,780,780,780,780,780
                DC.W 728,728,728,676,676,624,624,572
                DC.W 520,520,468,416,416,364,312,260
                DC.W 260,208,156,156,104,104,52,52
                DC.W 52,0,0,0,0,0,0,0
                DC.W 0,0,0,0,52,52,52,104
                DC.W 104,156,156,208,260,260,312,364
                DC.W 364

                DC.W 416,416,468,520,572,624,624,676
                DC.W 676,728,728,780,780,780,780
                DC.W 780,780,780,780,728,728,676,676
                DC.W 624,624,572,520,468,416,416,364
                DC.W 312,260,208,156,156,104,104,52
                DC.W 52,0,0,0,0,0,0,0
                DC.W 0,0,52,52,104,104,156,156
                DC.W 208,260,312,364,364

                DC.W 416,468,520,572,624,676,676,728
                DC.W 780,780,780,780,780,780,780,728
                DC.W 728,676,624,572,520,468,416,364
                DC.W 312,260,208,156,104,52,52,0
                DC.W 0,0,0,0,0,0,52,104
                DC.W 104,156,208,260,312,364

                DC.W 416,468,520,572,624,676,728,780
                DC.W 780,780,780,780,780,728,676
                DC.W 624,572,520,468,416,312,260,208
                DC.W 156,104,52,0,0,0,0,0
                DC.W 0,0,52,104,156,208,260,312
                DC.W 364


deltaende:
                DC.W 416,416,468,468,520,520,572,572
                DC.W 624,624,676,676,676,728,728,728
                DC.W 780,780,780,780,780,780,780,780
                DC.W 780,780,780,780,780,780,728,728
                DC.W 728,676,676,676,624,624,572,572
                DC.W 520,520,468,468,416,416,364,312
                DC.W 312,260,260,208,208,156,156,104
                DC.W 104,104,52,52,52,0,0,0
                DC.W 0,0,0,0,0,0,0,0
                DC.W 0,0,0,52,52,52,104,104
                DC.W 104,156,156,208,208,260,260,312
                DC.W 312,364,364




colpointer:     DC.L umblendfarben
colpointer2:    DC.L umblendfarben+24
colpointer3:    DC.L umblendfarben+48

umblendfarben:  DC.W $0700,$0500,$0300 ; Damit wird Logo umgeblendet!
                DC.W $0770,$0550,$0330
                DC.W $77,$55,$33
                DC.W $0765,$0543,$0321
                DC.W $70,$50,$30
                DC.W $0777,$0555,$0333
                DC.W $0756,$0534,$0312
                DC.W $07,$05,$03
                DC.W $0707,$0505,$0303
                DC.W $0777,$0777,$0777
                DC.W $0700,$0500,$0300
                DC.W $0567,$0234,$12
                DC.W $00,$00,$00
                DC.W $0776,$0554,$0332
                DC.W -1


charpoint:      DC.L bigfontbuff

charset:
                DC.W $fefc,$fefc,$fefe,$fcc6,$7e06,$66c0,$c666,$fefe
                DC.W $fefe,$fe7e,$c6c6,$c666,$c6fe,$fe,$18fe,$fec0
                DC.W $fefe,$fefe,$fe00,$30,$c6c6,$c0c6,$c0c0,$c0c6
                DC.W $1806,$78c0,$fe76,$c6c6,$c6c6,$c018,$c66c,$d618
                DC.W $fe1e,$c6,$3806,$06c6,$c0c0,$06fe,$fe00,$6000
                DC.W $fefc,$c0c6,$f0f0,$fefe,$18c6,$78c0,$d66e,$c6fe
                DC.W $cefc,$7e18,$c638,$fe18,$06f0,$c6,$18fc,$1efe
                DC.W $7cfe,$0c7c,$0260,$30,$c6fe,$fefc,$fec0,$fec6
                DC.W $7efe,$66fe,$c666,$fec0,$fece,$fe18,$fe10,$c666
                DC.W $fefe,$fe,$18fe,$fe06,$fefe,$18fe,$fe60,$6060
                DC.W $3078,$6c60,$3c3c,$00,$06,$00,$00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$3018,$6c60,$300c,$1000
                DC.W $0c,$3c00,$00,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $00,$00,$300c,$383c,$1818,$00,$00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$3018,$00,$3c3c,$1000
                DC.W $3030,$3c00,$00,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00


scrolltext:
                DCB.B 53," "
                DC.B "ALOHA! YOU FUCKING PC-LAMERS! TRY TO BEAT DIS!"
                DC.B "  TODAYS THE 1ST OF NOVEMBER AND I'M DOING"
                DC.B " THE FINAL TOUCHES TO THIS SCREEN (THE LAST"
                DC.B " ONE FOR THIS DEMO - THANXX GOD!).  "
                DC.B " IF YOU WANT TO KNOW HOW TO GET INTO THE"
                DC.B " HIDDENSCREEN JUST READ THE BACKGROUND-SCROLLER"
                DC.B " (YOU CAN'T READ IT? TOUGH SHIT!) OR JUST WAIT FOR THE"
                DC.B " SOLUTION TO IT IN ANY DISKMAGAZINE (ST-NEWS PERHAPS)"
                DC.B "  BUT YOU KNOW:"
                DC.B " TIME IS MONEY AND SO LET'S WRAAAZZZZ...."
                DCB.B 40," "

scrollende:
zeichen         EQU scrollende-scrolltext


deltatab:
                DC.W 0,2,5,8,11,13,16,19
                DC.W 22,25,27,30,33,35,38,41
                DC.W 44,46,49,52,54,57,59,62
                DC.W 65,67,70,72,75,77,80,82
                DC.W 84,87,89,91,94,96,98,100
                DC.W 102,104,107,109,111,113,115,117
                DC.W 118,120,122,124,126,127,129,131
                DC.W 132,134,135,137,138,139,141,142
                DC.W 143,145,146,147,148,149,150,151
                DC.W 152,153,153,154,155,155,156,157
                DC.W 157,158,158,158,159

                DC.W 160,162,164,166,168,170,172,174
                DC.W 176,178,180,181,183,185,186,188
                DC.W 189,191,192,193,194,195,196,197
                DC.W 198,198,199,199,199,199,200,199
                DC.W 199,199,199,198,198,197,196,195
                DC.W 194,193,192,191,189,188,186,185
                DC.W 183,181,180,178,176,174,172,170
                DC.W 168,166,164,162,160,157,155,153
                DC.W 151,149,147,145,143,141,139,138
                DC.W 136,134,133,131,130,128,127,126
                DC.W 125,124,123,122,121,121,120,120
                DC.W 120,120,120,120,120,120,120,121
                DC.W 121,122,123,124,125,126,127,128
                DC.W 130,131,133,134,136,138,139,141
                DC.W 143,145,147,149,151,153,155,157
                DC.W 159

                DC.W 160,162,164,167,169,172,174,177
                DC.W 179,181,184,186,189,191,193,196
                DC.W 198,200,203,205,207,210,212,214
                DC.W 216,219,221,223,225,227,230,232
                DC.W 234,236,238,240,242,244,246,248
                DC.W 249,251,253,255,257,258,260,262
                DC.W 264,265,267,268,270,271,273,274
                DC.W 276,277,278,280,281,282,283,284
                DC.W 285,286,287,288,289,290,291,292
                DC.W 293,293,294,295,295,296,296,297
                DC.W 297,298,298,298,299,299,299,299
                DC.W 299,299,300

                DC.W 306,313,320,327,334,340,346
                DC.W 352,358,364,369,374,378,382,386
                DC.W 389,392,395,397,398,399,399,399
                DC.W 399,398,397,395,392,389,386,382
                DC.W 378,374,369,364,358,352,346,340
                DC.W 334,327,320,313,306,300,293,286
                DC.W 279,272,265,259,253,247,241,235
                DC.W 230,225,221,217,213,210,207,204
                DC.W 202,201,200,200,200,200,201,202
                DC.W 204,207,210,213,217,221,225,230
                DC.W 235,241,247,253,259,265,272,279
                DC.W 286,293,299

                DC.W 300,303,306,310,313,317,320,324
                DC.W 327,331,334,338,341,344,348,351
                DC.W 355,358,361,365,368,371,374,378
                DC.W 381,384,387,390,393,396,400,403
                DC.W 405,408,411,414,417,420,423,425
                DC.W 428,431,433,436,438,441,443,446
                DC.W 448,450,453,455,457,459,461,463
                DC.W 465,467,469,471,473,474,476,478
                DC.W 479,481,482,484,485,486,487,489
                DC.W 490,491,492,493,494,494,495,496
                DC.W 496,497,498,498,498,499,499,499
                DC.W 499,499,500

                DC.W 503,506,510,513,516,520,522
                DC.W 525,528,530,532,534,536,537,538
                DC.W 539,539,540,539,539,538,537,536
                DC.W 534,532,530,528,525,522,520,516
                DC.W 513,510,506,503,500,496,493,489
                DC.W 486,483,479,477,474,471,469,467
                DC.W 465,463,462,461,460,460,460,460
                DC.W 460,461,462,463,465,467,469,471
                DC.W 474,477,479,483,486,489,493,496
                DC.W 499

fuckcount       SET 500
                REPT 100
                DC.W fuckcount
fuckcount       SET fuckcount+2
                ENDR

                REPT 6
                DC.W 701,702,703,704,703,702,701,700
                ENDR


                DC.W 700,706,713,720,727,734,740,746
                DC.W 752,758,764,769,774,778,782,786
                DC.W 789,792,795,797,798,799,799,799
                DC.W 799,798,797,795,792,789,786,782
                DC.W 778,774,769,764,758,752,746,740
                DC.W 734,727,720,713,706,700,693,686
                DC.W 679,672,665,659,653,647,641,635
                DC.W 630,625,621,617,613,610,607,604
                DC.W 602,601,600,600,600,600,601,602
                DC.W 604,607,610,613,617,621,625,630
                DC.W 635,641,647,653,659,665,672,679
                DC.W 686,693,699

                DC.W 700,703,706,710,713,717,720,724
                DC.W 727,731,734,738,741,744,748,751
                DC.W 755,758,761,765,768,771,774,778
                DC.W 781,784,787,790,793,796,800,803
                DC.W 805,808,811,814,817,820,823,825
                DC.W 828,831,833,836,838,841,843,846
                DC.W 848,850,853,855,857,859,861,863
                DC.W 865,867,869,871,873,874,876,878
                DC.W 879,881,882,884,885,886,887,889
                DC.W 890,891,892,893,894,894,895,896
                DC.W 896,897,898,898,898,899,899,899
                DC.W 899,899,900,899,899,899,899,899
                DC.W 898,898,898,897,896,896,895,894
                DC.W 894,893,892,891,890,889,887,886
                DC.W 885,884,882,881,879,878,876,874
                DC.W 873,871,869,867,865,863,861,859
                DC.W 857,855,853,850,848,846,843,841
                DC.W 838,836,833,831,828,825,823,820
                DC.W 817,814,811,808,805,803,800,796
                DC.W 793,790,787,784,781,778,774,771
                DC.W 768,765,761,758,755,751,748,744
                DC.W 741,738,734,731,727,724,720,717
                DC.W 713,710,706,703,700,696,693,689
                DC.W 686,682,679,675,672,668,665,661
                DC.W 658,655,651,648,644,641,638,634
                DC.W 631,628,625,621,618,615,612,609
                DC.W 606,603,599,596,594,591,588,585
                DC.W 582,579,576,574,571,568,566,563
                DC.W 561,558,556,553,551,549,546,544
                DC.W 542,540,538,536,534,532,530,528
                DC.W 526,525,523,521,520,518,517,515
                DC.W 514,513,512,510,509,508,507,506
                DC.W 505,505,504,503,503,502,501,501
                DC.W 501,500,500,500,500,500,500,500
                DC.W 500,500,500,500,501,501,501,502
                DC.W 503,503,504,505,505,506,507,508
                DC.W 509,510,512,513,514,515,517,518
                DC.W 520,521,523,525,526,528,530,532
                DC.W 534,536,538,540,542,544,546,549
                DC.W 551,553,556,558,561,563,566,568
                DC.W 571,574,576,579,582,585,588,591
                DC.W 594,596,599,603,606,609,612,615
                DC.W 618,621,625,628,631,634,638,641
                DC.W 644,648,651,655,658,661,665,668
                DC.W 672,675,679,682,686,689,693,696
                DC.W 699


                DC.W 700,701,703,705,706,708,710,712
                DC.W 713,715,717,719,720,722,724,725
                DC.W 727,729,730,732,734,735,737,739
                DC.W 740,742,743,745,746,748,750,751
                DC.W 752,754,755,757,758,760,761,762
                DC.W 764,765,766,768,769,770,771,773
                DC.W 774,775,776,777,778,779,780,781
                DC.W 782,783,784,785,786,787,788,789
                DC.W 789,790,791,792,792,793,793,794
                DC.W 795,795,796,796,797,797,797,798
                DC.W 798,798,799,799,799,799

                DC.W 800,803,806,810,813,817,820,823
                DC.W 826,829,832,834,837,839,841,843
                DC.W 844,846,847,848,849,849,849,849
                DC.W 849,849,848,847,846,844,843,841
                DC.W 839,837,834,832,829,826,823,820
                DC.W 817,813,810,806,803,800,796,793
                DC.W 789,786,782,779,776,773,770,767
                DC.W 765,762,760,758,756,755,753,752
                DC.W 751,750,750,750,750,750,750,751
                DC.W 752,753,755,756,758,760,762,765
                DC.W 767,770,773,776,779,782,786,789
                DC.W 793,796,799


fuckcount       SET 800
                REPT 100
                DC.W fuckcount
fuckcount       SET fuckcount+1
                ENDR


                DC.W 900,903,906,909,912,915,917,920
                DC.W 922,924,925,927,928,929,929,930
                DC.W 929,929,928,927,925,924,922,920
                DC.W 917,915,912,909,906,903,900,896
                DC.W 893,890,887,884,882,879,877,875
                DC.W 874,872,871,870,870,870,870,870
                DC.W 871,872,874,875,877,879,882,884
                DC.W 887,890,893,896,899

                DC.W 900,902,905,907,910,913,915,918
                DC.W 920,923,926,928,931,933,936,938
                DC.W 941,943,946,948,951,953,956,958
                DC.W 961,963,965,968,970,972,975,977
                DC.W 979,981,983,986,988,990,992,994
                DC.W 996,998,1000,1002,1004,1006,1007,1009
                DC.W 1011,1013,1014,1016,1018,1019,1021,1022
                DC.W 1024,1025,1027,1028,1029,1031,1032,1033
                DC.W 1034,1035,1037,1038,1039,1040,1040,1041
                DC.W 1042,1043,1044,1044,1045,1046,1046,1047
                DC.W 1047,1048,1048,1048,1049,1049,1049,1049

                DC.W 1050,1051,1052,1053,1054,1055,1056,1057
                DC.W 1058,1059,1060,1061,1062,1063,1064,1065
                DC.W 1065,1066,1067,1068,1069,1070,1070,1071
                DC.W 1072,1072,1073,1074,1074,1075,1075,1076
                DC.W 1076,1077,1077,1078,1078,1078,1079,1079
                DC.W 1079,1079,1079,1079,1079,1080,1079,1079
                DC.W 1079,1079,1079,1079,1079,1078,1078,1078
                DC.W 1077,1077,1076,1076,1075,1075,1074,1074
                DC.W 1073,1072,1072,1071,1070,1070,1069,1068
                DC.W 1067,1066,1065,1065,1064,1063,1062,1061
                DC.W 1060,1059,1058,1057,1056,1055,1054,1053
                DC.W 1052,1051,1050,1048,1047,1046,1045,1044
                DC.W 1043,1042,1041,1040,1039,1038,1037,1036
                DC.W 1035,1034,1034,1033,1032,1031,1030,1029
                DC.W 1029,1028,1027,1027,1026,1025,1025,1024
                DC.W 1024,1023,1023,1022,1022,1021,1021,1021
                DC.W 1020,1020,1020,1020,1020,1020,1020,1020
                DC.W 1020,1020,1020,1020,1020,1020,1020,1021
                DC.W 1021,1021,1022,1022,1023,1023,1024,1024
                DC.W 1025,1025,1026,1027,1027,1028,1029,1029
                DC.W 1030,1031,1032,1033,1034,1034,1035,1036
                DC.W 1037,1038,1039,1040,1041,1042,1043,1044
                DC.W 1045,1046,1047,1048,1049

                DC.W 1050,1050,1051,1052,1053,1054,1055,1056
                DC.W 1056,1057,1058,1059,1060,1061,1062,1062
                DC.W 1063,1064,1065,1066,1067,1067,1068,1069
                DC.W 1070,1071,1071,1072,1073,1074,1075,1075
                DC.W 1076,1077,1077,1078,1079,1080,1080,1081
                DC.W 1082,1082,1083,1084,1084,1085,1085,1086
                DC.W 1087,1087,1088,1088,1089,1089,1090,1090
                DC.W 1091,1091,1092,1092,1093,1093,1094,1094
                DC.W 1094,1095,1095,1096,1096,1096,1096,1097
                DC.W 1097,1097,1098,1098,1098,1098,1098,1099

fuckcount       SET 1100
                REPT 100
                DC.W fuckcount
fuckcount       SET fuckcount+1
                ENDR


                DC.W 1200,1203,1206,1210,1213,1217,1220,1224
                DC.W 1227,1230,1234,1237,1240,1243,1246,1250
                DC.W 1252,1255,1258,1261,1264,1266,1269,1271
                DC.W 1274,1276,1278,1280,1282,1284,1286,1288
                DC.W 1289,1291,1292,1293,1295,1296,1297,1297
                DC.W 1298,1299,1299,1299,1299,1300,1299,1299
                DC.W 1299,1299,1298,1297,1297,1296,1295,1293
                DC.W 1292,1291,1289,1288,1286,1284,1282,1280
                DC.W 1278,1276,1274,1271,1269,1266,1264,1261
                DC.W 1258,1255,1252,1250,1246,1243,1240,1237
                DC.W 1234,1230,1227,1224,1220,1217,1213,1210
                DC.W 1206,1203,1200,1196,1193,1189,1186,1182
                DC.W 1179,1175,1172,1169,1165,1162,1159,1156
                DC.W 1153,1149,1147,1144,1141,1138,1135,1133
                DC.W 1130,1128,1125,1123,1121,1119,1117,1115
                DC.W 1113,1111,1110,1108,1107,1106,1104,1103
                DC.W 1102,1102,1101,1100,1100,1100,1100,1100
                DC.W 1100,1100,1100,1100,1101,1102,1102,1103
                DC.W 1104,1106,1107,1108,1110,1111,1113,1115
                DC.W 1117,1119,1121,1123,1125,1128,1130,1133
                DC.W 1135,1138,1141,1144,1147,1149,1153,1156
                DC.W 1159,1162,1165,1169,1172,1175,1179,1182
                DC.W 1186,1189,1193,1196,1199

                DC.W 1200,1203,1206,1210,1213,1217,1220,1224
                DC.W 1227,1230,1234,1237,1240,1243,1246,1250
                DC.W 1252,1255,1258,1261,1264,1266,1269,1271
                DC.W 1274,1276,1278,1280,1282,1284,1286,1288
                DC.W 1289,1291,1292,1293,1295,1296,1297,1297
                DC.W 1298,1299,1299,1299,1299,1300,1299,1299

                DC.W 1300,1303,1306,1309,1312,1315,1317,1320
                DC.W 1322,1324,1325,1327,1328,1329,1329,1330
                DC.W 1329,1329,1328,1327,1325,1324,1322,1320
                DC.W 1317,1315,1312,1309,1306,1303,1300,1296
                DC.W 1293,1290,1287,1284,1282,1279,1277,1275
                DC.W 1274,1272,1271,1270,1270,1270,1270,1270
                DC.W 1271,1272,1274,1275,1277,1279,1282,1284
                DC.W 1287,1290,1293,1296,1299

fuckcount       SET 1300
                REPT 350
                DC.W fuckcount
fuckcount       SET fuckcount+2
                ENDR

                DC.W 2000,2003,2006,2010,2013,2017,2020,2024
                DC.W 2027,2030,2034,2037,2040,2043,2046,2050
                DC.W 2052,2055,2058,2061,2064,2066,2069,2071
                DC.W 2074,2076,2078,2080,2082,2084,2086,2088
                DC.W 2089,2091,2092,2093,2095,2096,2097,2097
                DC.W 2098,2099,2099,2099,2099,2100,2099,2099
                DC.W 2099,2099,2098,2097,2097,2096,2095,2093
                DC.W 2092,2091,2089,2088,2086,2084,2082,2080
                DC.W 2078,2076,2074,2071,2069,2066,2064,2061
                DC.W 2058,2055,2052,2050,2046,2043,2040,2037
                DC.W 2034,2030,2027,2024,2020,2017,2013,2010
                DC.W 2006,2003,2000,1996,1993,1989,1986,1982
                DC.W 1979,1975,1972,1969,1965,1962,1959,1956
                DC.W 1953,1949,1947,1944,1941,1938,1935,1933
                DC.W 1930,1928,1925,1923,1921,1919,1917,1915
                DC.W 1913,1911,1910,1908,1907,1906,1904,1903
                DC.W 1902,1902,1901,1900,1900,1900,1900,1900
                DC.W 1900,1900,1900,1900,1901,1902,1902,1903
                DC.W 1904,1906,1907,1908,1910,1911,1913,1915
                DC.W 1917,1919,1921,1923,1925,1928,1930,1933
                DC.W 1935,1938,1941,1944,1947,1949,1953,1956
                DC.W 1959,1962,1965,1969,1972,1975,1979,1982
                DC.W 1986,1989,1993,1996,1999

fuckcount       SET 2000
                REPT 125
                DC.W fuckcount
fuckcount       SET fuckcount+4
                ENDR

                DC.W 2500,2503,2506,2510,2513,2517,2520,2524
                DC.W 2527,2531,2534,2538,2541,2544,2548,2551
                DC.W 2555,2558,2561,2565,2568,2571,2574,2578
                DC.W 2581,2584,2587,2590,2593,2596,2600,2603
                DC.W 2605,2608,2611,2614,2617,2620,2623,2625
                DC.W 2628,2631,2633,2636,2638,2641,2643,2646
                DC.W 2648,2650,2653,2655,2657,2659,2661,2663
                DC.W 2665,2667,2669,2671,2673,2674,2676,2678
                DC.W 2679,2681,2682,2684,2685,2686,2687,2689
                DC.W 2690,2691,2692,2693,2694,2694,2695,2696
                DC.W 2696,2697,2698,2698,2698,2699,2699,2699
                DC.W 2699,2699,2700,2699,2699,2699,2699,2699
                DC.W 2698,2698,2698,2697,2696,2696,2695,2694
                DC.W 2694,2693,2692,2691,2690,2689,2687,2686
                DC.W 2685,2684,2682,2681,2679,2678,2676,2674
                DC.W 2673,2671,2669,2667,2665,2663,2661,2659
                DC.W 2657,2655,2653,2650,2648,2646,2643,2641
                DC.W 2638,2636,2633,2631,2628,2625,2623,2620
                DC.W 2617,2614,2611,2608,2605,2603,2600,2596
                DC.W 2593,2590,2587,2584,2581,2578,2574,2571
                DC.W 2568,2565,2561,2558,2555,2551,2548,2544
                DC.W 2541,2538,2534,2531,2527,2524,2520,2517
                DC.W 2513,2510,2506,2503,2500,2496,2493,2489
                DC.W 2486,2482,2479,2475,2472,2468,2465,2461
                DC.W 2458,2455,2451,2448,2444,2441,2438,2434
                DC.W 2431,2428,2425,2421,2418,2415,2412,2409
                DC.W 2406,2403,2399,2396,2394,2391,2388,2385
                DC.W 2382,2379,2376,2374,2371,2368,2366,2363
                DC.W 2361,2358,2356,2353,2351,2349,2346,2344
                DC.W 2342,2340,2338,2336,2334,2332,2330,2328
                DC.W 2326,2325,2323,2321,2320,2318,2317,2315
                DC.W 2314,2313,2312,2310,2309,2308,2307,2306
                DC.W 2305,2305,2304,2303,2303,2302,2301,2301
                DC.W 2301,2300,2300,2300,2300,2300,2300,2300
                DC.W 2300,2300,2300,2300,2301,2301,2301,2302
                DC.W 2303,2303,2304,2305,2305,2306,2307,2308
                DC.W 2309,2310,2312,2313,2314,2315,2317,2318
                DC.W 2320,2321,2323,2325,2326,2328,2330,2332
                DC.W 2334,2336,2338,2340,2342,2344,2346,2349
                DC.W 2351,2353,2356,2358,2361,2363,2366,2368
                DC.W 2371,2374,2376,2379,2382,2385,2388,2391
                DC.W 2394,2396,2399,2403,2406,2409,2412,2415
                DC.W 2418,2421,2425,2428,2431,2434,2438,2441
                DC.W 2444,2448,2451,2455,2458,2461,2465,2468
                DC.W 2472,2475,2479,2482,2486,2489,2493,2496
                DC.W 2499

                DC.W 2500,2505,2511,2516,2522,2527,2533,2538
                DC.W 2544,2550,2555,2561,2566,2571,2577,2582
                DC.W 2588,2593,2598,2604,2609,2614,2619,2625
                DC.W 2630,2635,2640,2645,2650,2655,2660,2664
                DC.W 2669,2674,2678,2683,2688,2692,2697,2701
                DC.W 2705,2709,2714,2718,2722,2726,2730,2734
                DC.W 2737,2741,2745,2748,2752,2755,2758,2762
                DC.W 2765,2768,2771,2774,2777,2779,2782,2785
                DC.W 2787,2790,2792,2794,2796,2798,2800,2802
                DC.W 2804,2806,2807,2809,2810,2811,2813,2814
                DC.W 2815,2816,2816,2817,2818,2818,2819,2819


                DC.W 2820,2822,2824,2826,2828,2830,2831,2833
                DC.W 2834,2836,2837,2838,2839,2839,2839,2840
                DC.W 2839,2839,2839,2838,2837,2836,2834,2833
                DC.W 2831,2830,2828,2826,2824,2822,2820,2817
                DC.W 2815,2813,2811,2809,2808,2806,2805,2803
                DC.W 2802,2801,2800,2800,2800,2800,2800,2800
                DC.W 2800,2801,2802,2803,2805,2806,2808,2809
                DC.W 2811,2813,2815,2817,2819

                DC.W 2820,2826,2832,2838,2845,2851,2857,2863
                DC.W 2869,2875,2881,2887,2893,2898,2904,2910
                DC.W 2915,2920,2925,2930,2935,2940,2945,2949
                DC.W 2953,2957,2961,2965,2969,2972,2975,2978
                DC.W 2981,2984,2986,2989,2991,2993,2994,2996
                DC.W 2997,2998,2999,2999,2999,3000

                DC.W 3000,3005,3010,3015,3020,3025,3030,3035
                DC.W 3040,3045,3050,3054,3058,3062,3066,3070
                DC.W 3074,3077,3080,3083,3086,3089,3091,3093
                DC.W 3095,3096,3097,3098,3099,3099,3100,3099
                DC.W 3099,3098,3097,3096,3095,3093,3091,3089
                DC.W 3086,3083,3080,3077,3074,3070,3066,3062
                DC.W 3058,3054,3050,3045,3040,3035,3030,3025
                DC.W 3020,3015,3010,3005,3000,2994,2989,2984
                DC.W 2979,2974,2969,2964,2959,2954,2949,2945
                DC.W 2941,2937,2933,2929,2925,2922,2919,2916
                DC.W 2913,2910,2908,2906,2904,2903,2902,2901
                DC.W 2900,2900,2900,2900,2900,2901,2902,2903
                DC.W 2904,2906,2908,2910,2913,2916,2919,2922
                DC.W 2925,2929,2933,2937,2941,2945,2949,2954
                DC.W 2959,2964,2969,2974,2979,2984,2989,2994
                DC.W 2999

fuckcount       SET 3000
                REPT 200
                DC.W fuckcount
fuckcount       SET fuckcount+2
                ENDR


                DC.W 3400,3411,3422,3433,3444,3454,3465,3475
                DC.W 3484,3494,3502,3511,3518,3526,3532,3538
                DC.W 3543,3548,3552,3555,3557,3559,3559,3559
                DC.W 3559,3557,3555,3552,3548,3543,3538,3532
                DC.W 3526,3518,3511,3502,3494,3484,3475,3465
                DC.W 3454,3444,3433,3422,3411,3400,3388,3377
                DC.W 3366,3355,3345,3334,3324,3315,3305,3297
                DC.W 3288,3281,3273,3267,3261,3256,3251,3247
                DC.W 3244,3242,3240,3240,3240,3240,3242,3244
                DC.W 3247,3251,3256,3261,3267,3273,3281,3288
                DC.W 3297,3305,3315,3324,3334,3345,3355,3366
                DC.W 3377,3388,3399

                DC.W 3400,3403,3406,3410,3413,3417,3420,3424
                DC.W 3427,3431,3434,3438,3441,3444,3448,3451
                DC.W 3455,3458,3461,3465,3468,3471,3474,3478
                DC.W 3481,3484,3487,3490,3493,3496,3500,3503
                DC.W 3505,3508,3511,3514,3517,3520,3523,3525
                DC.W 3528,3531,3533,3536,3538,3541,3543,3546
                DC.W 3548,3550,3553,3555,3557,3559,3561,3563
                DC.W 3565,3567,3569,3571,3573,3574,3576,3578
                DC.W 3579,3581,3582,3584,3585,3586,3587,3589
                DC.W 3590,3591,3592,3593,3594,3594,3595,3596
                DC.W 3596,3597,3598,3598,3598,3599,3599,3599
                DC.W 3599,3599,3600,3599,3599,3599,3599,3599


                DC.W 3600,3603,3606,3610,3613,3616,3620,3622
                DC.W 3625,3628,3630,3632,3634,3636,3637,3638
                DC.W 3639,3639,3640,3639,3639,3638,3637,3636
                DC.W 3634,3632,3630,3628,3625,3622,3620,3616
                DC.W 3613,3610,3606,3603,3600,3596,3593,3589
                DC.W 3586,3583,3579,3577,3574,3571,3569,3567
                DC.W 3565,3563,3562,3561,3560,3560,3560,3560
                DC.W 3560,3561,3562,3563,3565,3567,3569,3571
                DC.W 3574,3577,3579,3583,3586,3589,3593,3596
                DC.W 3599

                DC.W 3600,3602,3605,3608,3611,3613,3616,3619
                DC.W 3622,3625,3627,3630,3633,3635,3638,3641
                DC.W 3644,3646,3649,3652,3654,3657,3659,3662
                DC.W 3665,3667,3670,3672,3675,3677,3680,3682
                DC.W 3684,3687,3689,3691,3694,3696,3698,3700
                DC.W 3702,3704,3707,3709,3711,3713,3715,3717
                DC.W 3718,3720,3722,3724,3726,3727,3729,3731
                DC.W 3732,3734,3735,3737,3738,3739,3741,3742
                DC.W 3743,3745,3746,3747,3748,3749,3750,3751
                DC.W 3752,3753,3753,3754,3755,3755,3756,3757
                DC.W 3757,3758,3758,3758,3759,3759,3759,3759


                DC.W -99


dpos:           DC.L deltatab


boxpointer:     DC.L boxbuffer


hblcols1:
; Hintergrund
                DC.W $01,$02,$03,$04,$05,$06,$07,$17,$27
                DC.W $37,$47,$57,$67,$77,$0177,$0277,$0377,$0477
                DC.W $0577,$0677,$0777,$0776,$0775,$0774,$0773,$0772,$0771
                DC.W $0770,$0760,$0750,$0740,$0730,$0720,$0710,$0700,$0701
                DC.W $0702,$0703,$0704,$0705,$0706,$0707,$0717,$0727,$0737
                DC.W $0747,$0757,$0767,$0777,$0766,$0755,$0744,$0733,$0722
                DC.W $0711,$0700,$0601,$0502,$0403,$0304,$0205,$0106,$07
                DC.W $0117,$0227,$0337,$0447,$0557,$0667,$0777,$0676,$0575
                DC.W $0474,$0373,$0272,$0171,$70,$0170,$0270,$0370,$0470
                DC.W $0570,$0670,$0770,$0660,$0550,$0440,$0330,$0220,$0110
                DC.W 0


hblcols2:       INCBIN 'HBL2.PAL',180

hblcols4:       INCBIN 'HBL.PAL',180,200

hblcolsscroller:
                DCB.W 4,$0303
                DCB.W 4,$0404
                DCB.W 4,$0505
                DCB.W 4,$0606
                DCB.W 4,$0707
                DCB.W 4,$0706
                DCB.W 4,$0705
                DCB.W 4,$0703
                DCB.W 4,$0702
                DCB.W 4,$0701
                DCB.W 4,$0700
                DCB.W 4,$0710
                DCB.W 4,$0720
                DCB.W 4,$0730
                DCB.W 4,$0740
                DCB.W 4,$0750
                DCB.W 4,$0760
                DCB.W 4,$0770
                DCB.W 4,$0771
                DCB.W 4,$0772
                DCB.W 4,$0773
                DCB.W 4,$0774
                DCB.W 4,$0775
                DCB.W 4,$0776
                DCB.W 4,$0777




hblcols3:       DC.W $0706,$0705,$0704,$0703,$0702,$0701,$0700
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

hblpointer:     DC.L hblcolbuff

music:          INCBIN 'J1_TITL.IMG'
                EVEN

bigchars:                                    ; TEX-Zeichensatz
                DC.W $03ff,$ffc0,$3fff,$ffe0,$03ff,$fffc,$3fff,$ffc0
                DC.W $3fff,$fffc,$3fff,$fffc,$03ff,$fffc,$3f00,$fc
                DC.W $0fff,$fff0,$3fff,$fffc,$0fff,$fff0,$7fff,$fff8
                DC.W $0fff,$fffe,$7fff,$fff0,$7fff,$fffe,$7fff,$fffe
                DC.W $0fff,$fffe,$7f80,$01fe,$1fff,$fff8,$7fff,$fffe
                DC.W $1fff,$fff8,$7fff,$fffc,$1fff,$fffe,$7fff,$fff8
                DC.W $7fff,$fffe,$7fff,$fffe,$1fff,$fffe,$7f80,$01fe
                DC.W $1fff,$fff8,$7fff,$fffe,$3fff,$fffc,$7fff,$fffc
                DC.W $3fff,$fffe,$7fff,$fffc,$7fff,$fffe,$7fff,$fffe
                DC.W $3fff,$fffe,$7f80,$01fe,$1fff,$fff8,$7fff,$fffe
                DC.W $3fff,$fffc,$7fff,$fffe,$3fff,$fffe,$7fff,$fffc
                DC.W $7fff,$fffc,$7fff,$fffc,$7fff,$fffe,$7f80,$01fe
                DC.W $1fff,$fff8,$7fff,$fffe,$7fff,$fffe,$7f80,$fe
                DC.W $7fff,$fffe,$7fff,$fffe,$7f80,$00,$7f80,$00
                DC.W $7fff,$fffc,$7f80,$01fe,$0fff,$fff0,$7fff,$fffe
                DC.W $7fc0,$03fe,$7f80,$7e,$7fff,$fffc,$7fff,$fffe
                DC.W $7fff,$fff0,$7fff,$fff0,$7f80,$00,$7fff,$fffe
                DC.W $1f,$f000,$3fff,$fffe,$7f80,$01fe,$7fff,$fffc
                DC.W $7f80,$00,$7f80,$01fe,$7fff,$fff8,$7fff,$fff8
                DC.W $7f01,$fffc,$7fff,$fffe,$1f,$f000,$00,$01fe
                DC.W $7f80,$01fe,$7fff,$fffc,$7f80,$00,$7f80,$01fe
                DC.W $7fff,$fff8,$7fff,$fff8,$7f03,$fffe,$7fff,$fffe
                DC.W $1f,$f000,$00,$01fe,$7fff,$fffe,$7fff,$fffe
                DC.W $7fff,$fffc,$7fff,$fffe,$7fff,$fff0,$7fff,$fff0
                DC.W $7f03,$fffe,$7fff,$fffe,$1f,$f000,$3fff,$fffe
                DC.W $7fff,$fffe,$7f80,$7e,$7fff,$fffe,$7fff,$fffe
                DC.W $7f80,$00,$7f80,$00,$7f01,$fffe,$7f80,$01fe
                DC.W $0fff,$fff0,$7fff,$fffe,$7fff,$fffe,$7f80,$fe
                DC.W $3fff,$fffe,$7fff,$fffc,$7fff,$fffc,$7f80,$00
                DC.W $7f80,$7e,$7f80,$01fe,$1fff,$fff8,$7fff,$fffc
                DC.W $7fff,$fffe,$7fff,$fffc,$3fff,$fffe,$7fff,$fffc
                DC.W $7fff,$fffe,$7f80,$00,$3fff,$fffe,$7f80,$01fe
                DC.W $1fff,$fff8,$7fff,$fffc,$7fff,$fffe,$7fff,$fffc
                DC.W $1fff,$fffe,$7fff,$fff8,$7fff,$fffe,$7f80,$00
                DC.W $3fff,$fffe,$7f80,$01fe,$1fff,$fff8,$7fff,$fff8
                DC.W $7f80,$01fe,$7fff,$fff8,$0fff,$fffe,$7fff,$fff0
                DC.W $7fff,$fffe,$7f80,$00,$1fff,$fffe,$7f80,$01fe
                DC.W $1fff,$fff8,$7fff,$fff0,$3f00,$fc,$3fff,$ffe0
                DC.W $03ff,$fffc,$3fff,$ffc0,$3fff,$fffc,$3f00,$00
                DC.W $07ff,$fffc,$3f00,$fc,$0fff,$fff0,$3fff,$ffc0
                DC.W $3f00,$01f8,$3f80,$00,$3f00,$fc,$3ff8,$fc
                DC.W $03ff,$ffc0,$3fff,$ffe0,$03ff,$ffc0,$3fff,$ffe0
                DC.W $0fff,$fffc,$3fff,$fffc,$7f80,$07fc,$7fc0,$00
                DC.W $7fc0,$03fe,$7ffe,$01fe,$0fff,$fff0,$7fff,$fff8
                DC.W $0fff,$fff0,$7fff,$fff8,$3fff,$fffe,$7fff,$fffe
                DC.W $7f80,$0ff8,$7fc0,$00,$7fe0,$07fe,$7fff,$01fe
                DC.W $1fff,$fff8,$7fff,$fffc,$1fff,$fff8,$7fff,$fffc
                DC.W $7fff,$fffe,$7fff,$fffe,$7f80,$1ff0,$7fc0,$00
                DC.W $7ff0,$0ffe,$7fff,$81fe,$3fff,$fffc,$7fff,$fffc
                DC.W $3fff,$fffc,$7fff,$fffc,$7fff,$fffe,$7fff,$fffe
                DC.W $7f80,$3fe0,$7fc0,$00,$7ff8,$1ffe,$7fff,$c1fe
                DC.W $3fff,$fffc,$7fff,$fffe,$3fff,$fffc,$7fff,$fffe
                DC.W $7fff,$fffe,$7fff,$fffe,$7fff,$ffc0,$7fc0,$00
                DC.W $7ffc,$3ffe,$7fff,$e1fe,$7fff,$fffe,$7f80,$fe
                DC.W $7fff,$fffe,$7f80,$7e,$7fff,$fffc,$7fff,$fffe
                DC.W $7fff,$ff80,$7fc0,$00,$7ffe,$7ffe,$7fff,$f1fe
                DC.W $7fc0,$03fe,$7fff,$fffe,$7f80,$01fe,$7fff,$fffe
                DC.W $3fff,$f000,$3fff,$fffc,$7fff,$ff00,$7fc0,$00
                DC.W $7fff,$fffe,$7fbf,$f9fe,$7f80,$01fe,$7fff,$fffc
                DC.W $7f00,$fe,$7fff,$fffe,$1fff,$fe00,$1f,$f000
                DC.W $7fff,$ff00,$7fc0,$00,$7fff,$fffe,$7f9f,$fdfe
                DC.W $7f80,$01fe,$7fff,$fffc,$7f00,$7e,$7fff,$fffc
                DC.W $07ff,$ffc0,$1f,$f000,$7fff,$ff80,$7fc0,$00
                DC.W $7fff,$fffe,$7f8f,$fffe,$7fc0,$03fe,$7fff,$fff8
                DC.W $7f80,$7fbe,$7fff,$fffc,$ff,$fff8,$1f,$f000
                DC.W $7fff,$ffc0,$7fff,$fffc,$7fbf,$fdfe,$7f87,$fffe
                DC.W $7fff,$fffe,$7fff,$ffe0,$7fff,$bfde,$7fff,$fff8
                DC.W $3fff,$fffc,$1f,$f000,$7f80,$3fe0,$7fff,$fffe
                DC.W $7f9f,$f9fe,$7f83,$fffe,$3fff,$fffc,$7f80,$00
                DC.W $3fff,$dfee,$7f80,$3fe0,$7fff,$fffe,$1f,$f000
                DC.W $7f80,$1ff0,$7fff,$fffe,$7f8f,$f1fe,$7f81,$fffe
                DC.W $3fff,$fffc,$7f80,$00,$3fff,$eff4,$7f80,$1ff0
                DC.W $7fff,$fffe,$1f,$f000,$7f80,$0ff8,$7fff,$fffe
                DC.W $7f87,$e1fe,$7f80,$fffe,$1fff,$fff8,$7f80,$00
                DC.W $1fff,$f7f8,$7f80,$0ff8,$7fff,$fffe,$1f,$f000
                DC.W $7f80,$07fc,$7fff,$fffe,$7f81,$81fe,$7f80,$7ffe
                DC.W $0fff,$fff0,$7f80,$00,$0fff,$fbfc,$7f80,$07fc
                DC.W $7fff,$fffc,$1f,$f000,$3f00,$01f8,$3fff,$fffc
                DC.W $3f00,$fc,$3f00,$1ffc,$03ff,$ffc0,$3f00,$00
                DC.W $03ff,$fdfe,$3f00,$01f8,$3fff,$fff0,$0f,$e000
                DC.W $3f00,$fc,$3f00,$fc,$3f00,$fc,$1f80,$01f8
                DC.W $3f00,$fc,$3fff,$fffe,$07,$ffe0,$3fff,$fff8
                DC.W $3fff,$ffc0,$07,$e000,$7f80,$01fe,$7fc0,$03fe
                DC.W $7f80,$01fe,$3fe0,$07fc,$7fc0,$03fe,$7fff,$fffc
                DC.W $0f,$fff0,$7fff,$fffc,$7fff,$fff0,$1f,$f000
                DC.W $7f80,$01fe,$3fe0,$07fc,$7f81,$81fe,$1ff0,$0ff8
                DC.W $3fe0,$07fc,$7fff,$fff8,$0f,$fff0,$7fff,$fffe
                DC.W $7fff,$fff8,$3f,$e000,$7f80,$01fe,$1ff0,$0ff8
                DC.W $7f83,$c1fe,$0ff8,$1ff0,$1ff0,$0ff8,$7fff,$fff0
                DC.W $0f,$fff0,$7fff,$fffe,$7fff,$fffc,$7f,$c7e0
                DC.W $7f80,$01fe,$0ff8,$1ff0,$7f87,$e1fe,$07fc,$3fe0
                DC.W $0ff8,$1ff0,$7fff,$ffe0,$0f,$fff0,$7fff,$fffe
                DC.W $3fff,$fffc,$ff,$8ff0,$7f80,$01fe,$07fc,$3fe0
                DC.W $7f8f,$f1fe,$03ff,$ffc0,$07fc,$3fe0,$7fff,$ffc0
                DC.W $0f,$fff0,$7fff,$fffc,$00,$01fe,$01ff,$0ff0
                DC.W $7f80,$01fe,$03fe,$7fc0,$7f9f,$f9fe,$01ff,$ff80
                DC.W $03fe,$7fc0,$3fff,$ff80,$07,$fff0,$3fff,$fff8
                DC.W $0fff,$fffe,$03ff,$fffc,$7f80,$01fe,$01ff,$ff80
                DC.W $7fbf,$fdfe,$ff,$ff00,$01ff,$ff80,$7f,$ff00
                DC.W $00,$0ff0,$7f,$fff0,$1fff,$fffe,$07ff,$fffe
                DC.W $7fc0,$03fe,$ff,$ff00,$7fff,$fffe,$ff,$ff00
                DC.W $ff,$ff00,$ff,$fe00,$00,$0ff0,$ff,$ffe0
                DC.W $1fff,$fffe,$0fff,$fffe,$7fff,$fffe,$7f,$fe00
                DC.W $7fff,$fffe,$01ff,$ff80,$7f,$fe00,$01ff,$fffc
                DC.W $00,$0ff0,$01ff,$fffc,$0fff,$fffe,$1fff,$fffe
                DC.W $7fff,$fffe,$3f,$fc00,$7fff,$fffe,$03ff,$ffc0
                DC.W $3f,$fc00,$03ff,$fffe,$00,$0ff0,$03ff,$fffe
                DC.W $00,$01fe,$1fff,$fffe,$3fff,$fffc,$1f,$f800
                DC.W $3ffe,$7ffc,$07fc,$3fe0,$1f,$f800,$07ff,$fffe
                DC.W $00,$0ff0,$07ff,$fffe,$3fff,$fffc,$0fff,$fffc
                DC.W $3fff,$fffc,$0f,$f000,$3ffc,$3ffc,$0ff8,$1ff0
                DC.W $1f,$f800,$0fff,$fffe,$00,$0ff0,$0fff,$fffe
                DC.W $7fff,$fffc,$00,$0ff0,$1fff,$fff8,$07,$e000
                DC.W $1ff8,$1ff8,$1ff0,$0ff8,$1f,$f800,$1fff,$fffe
                DC.W $00,$0ff0,$1fff,$fffe,$7fff,$fff8,$00,$0ff0
                DC.W $0fff,$fff0,$03,$c000,$0ff0,$0ff0,$3fe0,$07fc
                DC.W $1f,$f800,$3fff,$fffe,$00,$0ff0,$3fff,$fffe
                DC.W $7fff,$fff0,$00,$0ff0,$03ff,$ffc0,$01,$8000
                DC.W $03c0,$03c0,$1f80,$01f8,$0f,$f000,$7fff,$fffc
                DC.W $00,$07e0,$7fff,$fffc,$3fff,$ffc0,$00,$07e0
                DC.W $3fff,$fffc,$7f,$8000,$7f,$fff0,$00,$00
                DC.W $07ff,$ffc0,$07ff,$ff80,$03,$e000,$00,$07
                DC.W $3800,$00,$00,$00,$7fff,$fffe,$01ff,$8000
                DC.W $01ff,$fff8,$03ff,$ffc0,$1fff,$fff0,$1fff,$ffe0
                DC.W $07,$f000,$00,$1f,$3e00,$00,$00,$00
                DC.W $7fff,$fffe,$03ff,$00,$03ff,$fff8,$0fff,$fff0
                DC.W $3fff,$fff8,$3fff,$fff0,$07,$f000,$00,$3f
                DC.W $3f00,$00,$00,$00,$7fff,$fffe,$07fe,$00
                DC.W $07ff,$fff0,$1fff,$fff8,$3fff,$fff8,$7fff,$fff8
                DC.W $07,$f000,$00,$7f,$3f80,$00,$00,$00
                DC.W $7fff,$fffc,$0ffc,$00,$0fff,$ffe0,$1f80,$01f8
                DC.W $7fff,$fffc,$7fff,$fff8,$ff,$ff80,$00,$7f
                DC.W $3f80,$00,$00,$00,$7f80,$00,$1fff,$ffe0
                DC.W $0fff,$ffc0,$1fff,$fff8,$7e00,$03fc,$ffff,$fffc
                DC.W $01ff,$ffc0,$00,$ff,$3fc0,$00,$00,$00
                DC.W $7fff,$fff8,$3fff,$fff8,$07ff,$ff80,$0fff,$fff0
                DC.W $7fff,$fffc,$ff87,$f7fc,$01ff,$ffc0,$00,$fe
                DC.W $1fc0,$00,$00,$00,$7fff,$fffc,$3fff,$fffc
                DC.W $03,$ff00,$0fff,$fff0,$3fff,$fffc,$ff0f,$e3fc
                DC.W $01ff,$ffc0,$00,$fc,$0fc0,$00,$00,$00
                DC.W $7fff,$fffc,$7fff,$fffc,$07,$fe00,$3fff,$fffc
                DC.W $3fff,$fff8,$ff1f,$c3fc,$01ff,$ffc0,$00,$fc
                DC.W $0fc0,$00,$00,$00,$3fff,$fffe,$7fff,$fffe
                DC.W $0f,$fc00,$7fff,$fffe,$1fff,$fff8,$ffbf,$87fc
                DC.W $01ff,$ffc0,$00,$fe,$1fc0,$00,$00,$00
                DC.W $00,$fe,$7fc0,$fe,$1f,$f800,$7f00,$7e
                DC.W $07ff,$fff0,$ffff,$fffc,$ff,$ff80,$00,$ff
                DC.W $3fc0,$00,$03c0,$00,$3fff,$fffe,$7fff,$fffe
                DC.W $3f,$f000,$7f80,$fe,$00,$7fe0,$7fff,$fff8
                DC.W $07,$f000,$00,$7f,$3f80,$00,$07e0,$00
                DC.W $7fff,$fffe,$3fff,$fffc,$7f,$e000,$3fff,$fffc
                DC.W $00,$ffc0,$7fff,$fff8,$07,$f000,$00,$7f
                DC.W $3f80,$00,$07e0,$00,$7fff,$fffc,$3fff,$fffc
                DC.W $ff,$c000,$3fff,$fffc,$01,$ff80,$3fff,$fff0
                DC.W $07,$f000,$00,$3f,$3f00,$00,$07e0,$00
                DC.W $7fff,$fffc,$1fff,$fff8,$01ff,$8000,$1fff,$fff8
                DC.W $03,$ff00,$1fff,$ffe0,$03,$e000,$00,$1f
                DC.W $3e00,$00,$07e0,$00,$3fff,$fff8,$07ff,$ffe0
                DC.W $01fe,$00,$07ff,$ffe0,$03,$fc00,$07ff,$ff80
                DC.W $00,$00,$00,$07,$3800,$00,$03c0,$00
                DC.W $00,$00,$03f0,$00,$3fff,$ffc0,$00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$00,$00,$07f8,$00
                DC.W $7fff,$ffe0,$00,$00,$0780,$00,$07,$8000
                DC.W $00,$00,$0787,$8000,$00,$00,$00,$00
                DC.W $0780,$00,$07f8,$00,$7fff,$ffe0,$00,$00
                DC.W $0fc0,$00,$0f,$c000,$00,$00,$0fcf,$c000
                DC.W $00,$00,$00,$00,$0fc0,$00,$07f8,$00
                DC.W $3fff,$fff0,$00,$00,$0fc0,$00,$0f,$c000
                DC.W $00,$00,$0fcf,$c000,$00,$00,$00,$00
                DC.W $0fc0,$00,$07f8,$00,$00,$03f0,$00,$00
                DC.W $0fc0,$00,$0f,$c000,$00,$00,$0fcf,$c000
                DC.W $ff,$ff80,$00,$00,$0fc0,$00,$07f8,$00
                DC.W $3fff,$fff0,$00,$00,$0fc0,$00,$0f,$c000
                DC.W $00,$00,$0fcf,$c000,$01ff,$ffc0,$00,$00
                DC.W $0fc0,$00,$07f8,$00,$7fff,$ffe0,$00,$00
                DC.W $0780,$00,$07,$c000,$00,$00,$07c7,$c000
                DC.W $01ff,$ffc0,$00,$00,$0780,$00,$07f8,$00
                DC.W $7fff,$ffe0,$00,$00,$00,$00,$0f,$8000
                DC.W $00,$00,$0f8f,$8000,$01ff,$ffc0,$00,$00
                DC.W $00,$00,$07f8,$00,$7fff,$ffc0,$0780,$00
                DC.W $0780,$00,$1f,$00,$0787,$8000,$1f1f,$00
                DC.W $01ff,$ffc0,$00,$00,$00,$00,$03f0,$00
                DC.W $3fff,$00,$0fc0,$00,$0fc0,$00,$00,$00
                DC.W $0fcf,$c000,$00,$00,$01ff,$ffc0,$00,$00
                DC.W $0780,$00,$00,$00,$00,$00,$0fc0,$00
                DC.W $0fc0,$00,$00,$00,$0fcf,$c000,$00,$00
                DC.W $ff,$ff80,$00,$00,$0fc0,$00,$03f0,$00
                DC.W $3ffe,$00,$0fc0,$00,$0fc0,$00,$00,$00
                DC.W $0fcf,$c000,$00,$00,$00,$00,$00,$00
                DC.W $0fc0,$00,$07f8,$00,$7fff,$00,$0fc0,$00
                DC.W $0fc0,$00,$00,$00,$0fcf,$c000,$00,$00
                DC.W $00,$00,$00,$00,$0fc0,$00,$07f8,$00
                DC.W $7fff,$00,$07c0,$00,$07c0,$00,$00,$00
                DC.W $07c7,$c000,$00,$00,$00,$00,$00,$00
                DC.W $0fc0,$00,$07f8,$00,$7fff,$00,$0f80,$00
                DC.W $0f80,$00,$00,$00,$0f8f,$8000,$00,$00
                DC.W $00,$00,$00,$00,$0780,$00,$03f0,$00
                DC.W $3ffe,$00,$1f00,$00,$1f00,$00,$00,$00
                DC.W $1f1f,$00,$00,$00,$00,$00,$00,$00


laufpointer1:   DC.L laufschriftbuff
laufpointer2:   DC.L laufschriftbuff+(80*7*3)

block:
; fÅr mittleren Scroller (2 Planes) nur 3 Zeilen
                DC.B $ff,$00,$81,$7f
                DC.B $ff,$ff

chars8:                                      ;7 hoch
                DC.W $18,$6666,$10c4,$3e0c,$1c70,$00,$00,$06
                DC.W $1c08,$7c3e,$463e,$1e7e,$1e7e,$1818,$0e00,$70fe
                DC.W $18,$66ff,$7ccc,$6618,$3018,$6c30,$00,$0c
                DC.W $3618,$0606,$c660,$3086,$36e6,$1818,$1800,$1806
                DC.W $18,$6666,$6018,$6630,$600c,$3830,$00,$18
                DC.W $6638,$0606,$c6c0,$600c,$66c6,$00,$30fe,$0c06
                DC.W $08,$66,$3830,$3c60,$600c,$fefc,$fe,$30
                DC.W $c618,$3c1c,$fefc,$fe18,$fefe,$00,$6000,$067c
                DC.W $00,$66,$0c60,$7800,$600c,$3830,$0800,$60
                DC.W $c618,$6006,$0606,$c630,$c606,$1808,$30fe,$0c60
                DC.W $18,$ff,$7ccc,$cc00,$3018,$6c30,$1800,$18c0
                DC.W $c618,$c0c6,$06c6,$c630,$c606,$1818,$1800,$1800
                DC.W $18,$66,$108c,$fe00,$1c70,$00,$3000,$1880
                DC.W $7c18,$fefe,$027c,$fe30,$fe02,$30,$0e00,$7060
                DC.W $1e,$f01e,$f01e,$1e1e,$4608,$0246,$4046,$461e
                DC.W $781e,$781e,$7e46,$4646,$4646,$7e78,$3c,$3020
                DC.W $3c36,$d830,$d830,$3030,$c618,$06cc,$c0c6,$c636
                DC.W $cc36,$cc30,$18c6,$c6c6,$c6c6,$0c60,$0c,$7860
                DC.W $6666,$cc60,$cc60,$6060,$c618,$06d8,$c0ee,$e666
                DC.W $c666,$c660,$18c6,$c6c6,$6cc6,$1860,$0c,$fcfe
                DC.W $6ec6,$fec0,$c6f8,$f8c0,$fe18,$06f0,$c0fe,$f6c6
                DC.W $c6c6,$c6c0,$18c6,$c6d6,$386c,$3060,$0c,$30fe
                DC.W $6ec6,$c6c0,$c6c0,$c0ce,$c618,$46d8,$c0d6,$dec6
                DC.W $fed6,$fefe,$18c6,$ccd6,$6c38,$6060,$0c,$3060
                DC.W $60fe,$c6c0,$c6c0,$c0c6,$c618,$c6cc,$c0c6,$cec6
                DC.W $c0dc,$cc06,$18c6,$d8dc,$c618,$c060,$0c,$3020
                DC.W $3ec6,$fefe,$fefe,$c0fe,$c618,$fec6,$fec6,$c6fe
                DC.W $c0fa,$c6fe,$10fe,$f0f8,$c618,$fe78,$3c,$3000

bigscrollcount: DC.W 0

textpos2:       DC.L text2

text2:          INCBIN 'BIGTEXT.IMG'
                EVEN

dflogo:         INCBIN 'DFLOGO2P.IMG'


box:            INCBIN 'BOX.IMG'
boxende:
preshiftbuff    EQU box         ; ACHTUNG!!! wird Åberschrieben!!!!
; ist 2*16*50*13*4 Bytes groû

                BSS
bssstart:       DS.B 3200

key:            DS.W 1
hbl_buff:       DS.W 10
                IFEQ diskversion
ssp:            DS.L 1
oldres:         DS.W 1
oldsync:        DS.W 1
logbase:        DS.L 1
physbase:       DS.L 1
oldpal:         DS.L 8
                ENDC
hblcolbuff:     DS.W 3*200+1

boxbuffer:      DS.L 40000
boxbuffende:

bigfontbuff:    DS.B 50*30*17   ; 50 Zeichen*30 Bytes/Scanline*17 Scanlines
charende:
laufschriftbuff:DS.B 80*7*3     ; dort wird 2 Plane Scroller gescrollt
                DS.B 80*7*3

scrollbuff:     DS.B zeichen*4*16
                DS.B 256+8*160
screenbase:     DS.B 2*32000    ; Platz fÅr 2 Screens
bssende:
                END
