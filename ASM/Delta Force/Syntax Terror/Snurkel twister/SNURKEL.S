*********************************************************************
***                                                               ***
***                       Snurkel-Scroller                        ***
***                    ~~~~~~~~~~~~~~~~~~~~~~~                    ***
***                 written by New Mode of Delta Force            ***
***---------------------------------------------------------------***
***            Programmerstellung begann am: 18.08.90             ***
***            Aktuelles Datum             : 29.11.90             ***
***---------------------------------------------------------------***
***              Entwickelt mit Devpac-Assembler                  ***
*********************************************************************

charsanzahl     EQU 24          ; Anzahl der zu berechnenden Buchstaben
charberechen    EQU 46

diskversion     EQU 0           ; 0=Develop.version/1=absolute Version


                IFNE diskversion
                OPT X-
                ORG $1000
                OUTPUT 'E:\WRITE\SIDE1\CIRCLE.IMG'
                ENDC

                TEXT

s:              IFEQ diskversion
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
                ENDC

                lea     $ffff8240.w,A0
                moveq   #7,D0
clrpal:         clr.l   (A0)+
                dbra    D0,clrpal


; formt Bild aus Spezialformat zurÅck
; a0=Adresse
; d0=LÑnge
                lea     dflogo,A0
                move.l  #12480,D0
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


                move.l  #screenbuff,D0
                and.l   #-256,D0
                add.l   #3072+256,D0         ; wegen Clipping Screens grîûer
                move.l  D0,oldscreen
                add.l   #32000+3072,D0
                move.l  D0,newscreen

                movea.l oldscreen(PC),A0
                bsr     cls
                movea.l newscreen(PC),A0
                bsr     cls                  ; beide Screens lîschen

                clr.w   zeichen
                move.l  #anfangstext,textpos

                move.l  oldscreen(PC),D0
                bsr     setscreen



                IFEQ diskversion
                move.b  $ffff820a.w,oldsync
                bsr     vsync
                move.b  #2,$ffff820a.w       ; 50 Hz
                clr.b   $ffff8260.w          ; Lowres
                ENDC

                lea     hblfarben+30(PC),A0
                bsr     makehblfarben

                moveq   #2,D0
                jsr     music

                clr.w   littlescroller

                move.l  #hblcolors,hblpointer

                bsr     hbl_on

                bsr     make_drehtab         ; Sinustabelle erstellen

                bsr     initdrehscroller     ; Buchstaben drehen

                bsr     initstarfield        ; Sterne berchnen

                lea     dflogo+52*120,A0
                movea.l oldscreen(PC),A1
                movea.l newscreen(PC),A2
                lea     148*160+16(A1),A1
                lea     148*160+16(A2),A2
                bsr     copylogo

                move.l  #dobbstab,dobbspoint
                clr.w   cleardobbs1
                clr.w   cleardobbs2

                move.w  #-1,littlescroller   ; Scroller abschalten

                bsr     fadeup

                clr.w   key

mainloop:       cmpi.b  #$39,key
                bne.s   mainloop



ende:
                bsr     hbl_off

                moveq   #0,D0
                bsr     music                ; Musik abschalten

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
                moveq   #0,D0                ; in Syntax-Mainmenu zurÅck
                jmp     $0500.w
                ENDC



scroller:
; kleine Laufschrift

                subq.w  #4,zeichen           ; um 2 Zeichen scrollen
                bpl.s   do_it                ; alles gescrollt?
                move.w  #12,zeichen
                movea.l textpos,A0
                tst.b   (A0)
                bpl.s   gweiter              ; noch nicht Ende von Text
                move.l  #anfangstext,textpos
                movea.l textpos,A0
gweiter:        moveq   #0,D0
                move.b  (A0),D0              ; Zeichen holen
                mulu    #28,D0
                lea     charset,A6
                adda.l  D0,A6
                move.l  A6,mempos
                addq.l  #1,textpos

do_it:
                movea.l mempos,A2
                movea.l oldscreen(PC),A0
                lea     93*160+158(A0),A0
                move.w  zeichen,D4           ; Anzahl wieviel gescrollt ist
                moveq   #13,D5               ; Anzahl der Scrollzeilen-1
scrollloop:     moveq   #0,D0
                move.w  (A2),D0              ; 4 mal 16 Pixel von Zeichen
                lsr.w   D4,D0
                and.w   #15,D0
                REPT 20
                moveq   #0,D1
                move.w  (A0),D1              ; vom Quellbildschirm
                lsl.l   #4,D1                ; um 4 Bits nach links schieben
                or.w    D0,D1                ; alten Rest einodern
                move.w  D1,(A0)              ; abspeichern auf Zielbildschirm
                swap    D1                   ; Hiword <-> Lowword
                move.w  D1,D0                ; Herausgeschobenes merken
                lea     -8(A0),A0
                ENDR

                lea     320(A0),A0           ; auf Bitplane1 1 Zeile tiefer
                lea     2(A2),A2             ; im Charscreen 1 Zeile tiefer

                dbra    D5,scrollloop
                rts



fadeup:
; blendet Farbpalette hoch

                lea     $ffff8240.w,A6
                lea     palette(PC),A5

fade_up:        moveq   #7,D7                ; 8 Farben
ful01:          move.w  (A6),D0
                and.w   #%111,D0
                move.w  (A5),D1
                and.w   #%111,D1
                cmp.w   D0,D1
                beq.s   fcol21
                addq.w  #1,D0
                move.w  (A6),D1
                and.w   #%1111111111111000,D1
                or.w    D0,D1
                move.w  D1,(A6)
                bra.s   fcolok1
fcol21:         move.w  (A6),D0
                and.w   #%1110000,D0
                move.w  (A5),D1
                and.w   #%1110000,D1
                cmp.w   D0,D1
                beq.s   fcol31
                add.w   #$10,D0
                move.w  (A6),D1
                and.w   #%1111111110001111,D1
                or.w    D0,D1
                move.w  D1,(A6)
                bra.s   fcolok1
fcol31:         move.w  (A6),D0
                and.w   #%11100000000,D0
                move.w  (A5),D1
                and.w   #%11100000000,D1
                cmp.w   D0,D1
                beq.s   fcolok1
                add.w   #$0100,D0
                move.w  (A6),D1
                and.w   #%1111100011111111,D1
                or.w    D0,D1
                move.w  D1,(A6)
fcolok1:        lea     2(A6),A6
                lea     2(A5),A5
                dbra    D7,ful01

                bsr     vsync
                bsr     vsync
                bsr     vsync
                bsr     vsync

                moveq   #7,D7
                lea     palette(PC),A1
                lea     $ffff8240.w,A0
compcol:        move.w  (A1)+,D0
                and.w   #$0777,D0
                move.w  (A0)+,D1
                and.w   #$0777,D1
                cmp.w   D0,D1
                bne     fadeup
                dbra    D7,compcol

                rts


copylogo:
                moveq   #51,D0               ; 52 Scanlines
copylogo1:      moveq   #29,D1
copylogo2:      move.l  (A0),(A1)+
                move.l  (A0)+,(A2)+
                dbra    D1,copylogo2
                lea     40(A1),A1
                lea     40(A2),A2
                dbra    D0,copylogo1
                rts


makehblfarben:
; wandelt Worte in Longs
                lea     hblcolors,A1
                moveq   #25,D0               ; 26 Farben
makehblcols:    move.w  (A0),(A1)+
                move.w  (A0)+,(A1)+
                dbra    D0,makehblcols
                rts

;-------------------------- dobbsendes Logo --------------------

logohupps:      addq.l  #2,dobbspoint
                movea.l dobbspoint,A2
                cmpi.w  #-99,(A2)
                bne.s   nixenddobbstab
                lea     dobbstab,A2
nixenddobbstab: move.l  A2,dobbspoint

                moveq   #0,D0
                move.w  cleardobbs1,D0
                move.w  (A2),D2              ; neuer Dobbswert
                move.w  D2,cleardobbs1
                movea.l oldscreen(PC),A1
                lea     14*160+16(A1),A1
                adda.w  D2,A1                ; dobbspos aufaddieren
                cmp.w   D0,D2
                beq.s   nixclear             ; beide Positionen gleich-> nix
                bgt.s   obenclear            ; neue grîûer -> oben lîschen
                lea     52*160(A1),A1        ; unterhalb des Logos
                sub.w   D2,D0
                bra.s   untenclear
obenclear:      sub.w   D2,D0
                neg.w   D0
                suba.w  D0,A1

untenclear:     divu    #160,D0
                subq.w  #1,D0
                bmi.s   nixclear
                moveq   #0,D1                ; 8 Lîschwerte
                moveq   #0,D3
                moveq   #0,D4
                moveq   #0,D5
                moveq   #0,D6
                moveq   #0,D7
                suba.l  A0,A0
                suba.l  A2,A2
                lea     128(A1),A1
clearloop:      movem.l D1/D3-A0/A2,-(A1)
                movem.l D1/D3-A0/A2,-(A1)
                movem.l D1/D3-A0/A2,-(A1)
                movem.l D1/D3-A0/A2,-(A1)
                lea     160+128(A1),A1
                dbra    D0,clearloop

nixclear:       lea     dflogo,A0
                movea.l oldscreen(PC),A1
                lea     14*160+16(A1),A1     ; zentrieren
                adda.w  D2,A1                ; dobbswert aufaddieren

                REPT 52
                movem.l (A0)+,D0-D7/A2-A4    ; 11 Longs
                movem.l D0-D7/A2-A4,(A1)
                movem.l (A0)+,D0-D7/A2-A4    ; 11 Longs
                movem.l D0-D7/A2-A4,44(A1)
                movem.l (A0)+,D0-D7          ; 8 Longs
                movem.l D0-D7,88(A1)
                lea     160(A1),A1
                ENDR

                move.w  cleardobbs1,D0
                move.w  cleardobbs2,cleardobbs1
                move.w  D0,cleardobbs2

                rts





;---------------------- Starfieldroutinen ------------------------

starsanzahl     EQU 120         ; muû durch 3 teilbar sein!

initstarfield:                               ;bsr     makelamestarfield

                lea     lamestartab3(PC),A0
                lea     megastartab3,A1
                moveq   #4,D7                ; Speed
                move.w  #80,D6               ; 80 mal
                bsr     makemegastartab

                lea     lamestartab2(PC),A0
                lea     megastartab2,A1
                moveq   #2,D7                ; Speed
                move.w  #160,D6              ; 160 mal
                bsr     makemegastartab

                lea     lamestartab1(PC),A0
                lea     megastartab1,A1
                moveq   #1,D7                ; Speed
                move.w  #320,D6              ; 320 mal
                bsr     makemegastartab

                lea     megastarbuff,A0
                lea     megastartab3,A1
                move.w  #(starsanzahl/3)-1,D0
initbuff:       move.l  A1,(A0)+             ; Pointer
                move.l  A1,(A0)+
                lea     80*3*2(A1),A1        ; nÑchste Koord.tab
                dbra    D0,initbuff

                lea     megastartab2,A1
                move.w  #(starsanzahl/3)-1,D0
initbuff2:      move.l  A1,(A0)+             ; Pointer
                move.l  A1,(A0)+
                lea     160*3*2(A1),A1
                dbra    D0,initbuff2

                lea     megastartab1,A1
                move.w  #(starsanzahl/3)-1,D0
initbuff3:      move.l  A1,(A0)+             ; Pointer
                move.l  A1,(A0)+
                lea     320*3*2(A1),A1
                dbra    D0,initbuff3

                clr.w   stars1counter
                clr.w   stars2counter
                clr.w   stars3counter

                move.l  #megaclearbuff,megaclearpoint1
                move.l  #megaclearbuff+(starsanzahl*2*4),megaclearpoint2

                lea     megaclearbuff,A0
                move.w  #(starsanzahl*2)-1,D0
makeclearbuff:  move.l  oldscreen(PC),(A0)+
                clr.l   (A0)+
                dbra    D0,makeclearbuff
                rts


clearoldstarfield:
; restauriert immer (zuerst Sterne vorne dann Mitte dann hinten)

                movea.l megaclearpoint1,A0
                lea     2*starsanzahl/3*8(A0),A0
                REPT starsanzahl/3
                movea.l (A0)+,A1             ; Adresse
                move.l  (A0)+,(A1)           ; Wert wieder zurÅck
                ENDR
                movea.l megaclearpoint1,A0
                lea     starsanzahl/3*8(A0),A0
                REPT starsanzahl/3
                movea.l (A0)+,A1             ; Adresse
                move.l  (A0)+,(A1)           ; Wert wieder zurÅck
                ENDR
                movea.l megaclearpoint1,A0
                REPT starsanzahl/3
                movea.l (A0)+,A1             ; Adresse
                move.l  (A0)+,(A1)           ; Wert wieder zurÅck
                ENDR
                rts


drawstarfield:
                movea.l megaclearpoint1,A6   ; dorthin werden Daten abgelegt

                lea     megastarbuff,A0
                move.w  #(starsanzahl/3)-1,D7
                move.w  stars3counter,D6
                bsr     drawspeed4stars

                lea     megastarbuff+(8*starsanzahl/3),A0
                move.w  #(starsanzahl/3)-1,D7
                move.w  stars2counter,D6
                bsr     drawspeed2stars


                lea     megastarbuff+(8*2*starsanzahl/3),A0
                move.w  #(starsanzahl/3)-1,D7
                move.w  stars1counter,D6
                bsr     drawspeed1stars

                move.w  stars3counter,D6
                addq.w  #1,D6
                cmp.w   #80,D6               ; Ende der Tabelle
                bne.s   nixstars3counter0
                moveq   #0,D6
nixstars3counter0:
                move.w  D6,stars3counter

                move.w  stars2counter,D6
                addq.w  #1,D6
                cmp.w   #160,D6              ; Ende der Tabelle
                bne.s   nixstars2counter0
                moveq   #0,D6
nixstars2counter0:
                move.w  D6,stars2counter

                move.w  stars1counter,D6
                addq.w  #1,D6
                cmp.w   #320,D6              ; Ende der Tabelle
                bne.s   nixstars1counter0
                moveq   #0,D6
nixstars1counter0:
                move.w  D6,stars1counter

                move.l  megaclearpoint1,D0
                move.l  megaclearpoint2,megaclearpoint1
                move.l  D0,megaclearpoint2

                rts

drawspeed4stars:
                movea.l oldscreen(PC),A1
                lea     stargraf(PC),A2
                tst.w   D6
                bne.s   nixnewtab
                move.l  4(A0),(A0)           ; neue Startab
nixnewtab:      movea.l (A0),A3              ; Werte
                adda.w  (A3)+,A1             ; Screenoffset
                move.w  (A3)+,D0             ; Bitnummer
                adda.w  (A3)+,A2             ; Grafikoffset
                move.l  A3,(A0)              ; und wieder speichern
                move.w  (A2)+,D5             ; Grafikwert holen
                movem.w (A1),D1-D3           ; Screenwerte holen
                btst    D0,D1
                bne.s   nixdrawstar
                btst    D0,D2
                bne.s   nixdrawstar
                btst    D0,D3
                bne.s   nixdrawstar
                move.l  A1,(A6)+             ; Clearpos
                move.w  D1,(A6)+             ; Daten ablegen
                move.w  D2,(A6)+
                or.w    D5,D1
                or.w    D5,D2
                move.w  D1,(A1)+
                move.w  D2,(A1)+
                bra.s   starwasdrawn
nixdrawstar:    move.l  oldscreen(PC),(A6)+  ; Clearpos
                move.l  #0,(A6)+             ; das wird restauriert
starwasdrawn:   lea     8(A0),A0             ; nÑchster Buffer
                dbra    D7,drawspeed4stars
                rts

drawspeed2stars:
                movea.l oldscreen(PC),A1
                lea     stargraf(PC),A2
                tst.w   D6
                bne.s   nixnewtab2
                move.l  4(A0),(A0)           ; neue Startab
nixnewtab2:     movea.l (A0),A3              ; Werte
                adda.w  (A3)+,A1             ; Screenoffset
                move.w  (A3)+,D0             ; Bitnummer
                adda.w  (A3)+,A2             ; Grafikoffset
                move.l  A3,(A0)              ; und wieder speichern
                move.w  (A2)+,D5             ; Grafikwert holen
                movem.w (A1),D1-D3           ; Screenwerte holen
                btst    D0,D1
                bne.s   nixdrawstar2
                btst    D0,D2
                bne.s   nixdrawstar2
                btst    D0,D3
                bne.s   nixdrawstar2
                move.l  A1,(A6)+
                move.w  D1,(A6)+
                move.w  D2,(A6)+
                or.w    D5,D2
                move.w  D2,2(A1)
                bra.s   starwasdrawn2
nixdrawstar2:   move.l  oldscreen(PC),(A6)+
                move.l  #0,(A6)+
starwasdrawn2:  lea     8(A0),A0
                dbra    D7,drawspeed2stars
                rts

drawspeed1stars:
                movea.l oldscreen(PC),A1
                lea     stargraf(PC),A2
                tst.w   D6
                bne.s   nixnewtab3
                move.l  4(A0),(A0)           ; neue Startab
nixnewtab3:     movea.l (A0),A3              ; Werte
                adda.w  (A3)+,A1             ; Screenoffset
                move.w  (A3)+,D0             ; Bitnummer
                adda.w  (A3)+,A2             ; Grafikoffset
                move.l  A3,(A0)              ; und wieder speichern
                move.w  (A2)+,D5             ; Grafikwert holen
                movem.w (A1),D1-D3           ; Screenwerte holen
                btst    D0,D1
                bne.s   nixdrawstar3
                btst    D0,D2
                bne.s   nixdrawstar3
                btst    D0,D3
                bne.s   nixdrawstar3
                move.l  A1,(A6)+
                move.w  D1,(A6)+
                move.w  D2,(A6)+
                or.w    D5,D1
                move.w  D1,(A1)
                bra.s   starwasdrawn3
nixdrawstar3:   move.l  oldscreen(PC),(A6)+
                move.l  #0,(A6)+
starwasdrawn3:  lea     8(A0),A0
                dbra    D7,drawspeed1stars
                rts




makemegastartab:
; errechnet sÑmtliche Wege der Sterne durch
                move.w  #(starsanzahl/3)-1,D0
makemegaloop:   move.w  (A0)+,D1             ; Start-x
                move.w  (A0)+,D2             ; Start-y
                mulu    #160,D2              ; y wird nicht mehr verÑndert
                move.w  D6,D5                ; ZÑhlwert (80,160,320)
                subq.w  #1,D5
makemegal2:     move.w  D1,D3
                and.w   #-16,D3
                lsr.w   #1,D3
                add.w   D2,D3                ; Screenoffset
                move.w  D3,(A1)+
                move.w  D1,D3
                and.w   #15,D3               ; nur Bits 0-15
                move.w  D3,D4
                add.w   D4,D4                ; Grafikoffset
                eori.w  #15,D3               ; wegen Bittest
                move.w  D3,(A1)+
                move.w  D4,(A1)+

                sub.w   D7,D1                ; x-dx
                bpl.s   x_is_noch_ok

                move.w  #320,D3
                add.w   D1,D3                ; 320-x
                move.w  D3,D1

x_is_noch_ok:   dbra    D5,makemegal2
                dbra    D0,makemegaloop

                rts



;------------------------ Drehscroller ---------------------------


make_drehtab:
; erstellt Drehtabelle um die Buchstaben zeitsparend zu drehen

                lea     drehtab,A0           ; dort kommen Daten hin
                moveq   #0,D0                ; WinkelzÑhler (0-512)
                lea     sintab,A2
makedrehloop0:  moveq   #0,D1
                moveq   #0,D2
                move.w  D0,D1                ; Winkelwerte
                move.w  D0,D2
                add.w   #128,D2              ; Cosinus=Sinus+90 Grad
                and.w   #511,D2
                add.w   D1,D1                ; *2 wegen Worten
                add.w   D2,D2
                move.w  0(A2,D1.w),D1        ; Sinus
                move.w  0(A2,D2.w),D2        ; Cosinus
                moveq   #0,D3                ; Y-Counter
makedrehloop1:  moveq   #0,D4                ; X-Counter
makedrehloop2:  move.l  D3,-(A7)
                move.l  D4,-(A7)
                moveq   #0,D5
                moveq   #0,D6
                sub.w   #12,D4               ; x1=x-12
                sub.w   #9,D3                ; y1=y-9
                move.w  D3,D5                ; y1
                move.w  D4,D6                ; x1
                muls    D1,D4                ; x1*sin
                muls    D2,D6                ; x1*cos
                muls    D1,D3                ; y1*sin
                muls    D2,D5                ; y1*cos


                sub.l   D3,D6                ; xrot=x1*cos-y1*sin
                add.l   D4,D5                ; yrot=x1*sin+y1*cos

                add.l   D5,D5                ; Multiplikation ausgleichen
                add.l   D5,D5
                swap    D5
                add.l   D6,D6                ; Multiplikation ausgleichen
                add.l   D6,D6
                swap    D6
                addq.w  #7,D5                ; yrot=yrot+7
                addq.w  #8,D6                ; xrot=xrot+8

                tst.w   D6                   ; xrot>=0?
                bmi.s   nixrotok
                cmp.w   #16,D6               ; xrot<16?
                bge.s   nixrotok
                tst.w   D5                   ; yrot>=0?
                bmi.s   nixrotok
                cmp.w   #14,D5               ; yroty<14?
                bge.s   nixrotok
                add.w   D5,D5                ; yrot=yrot*2
                and.w   #15,D6               ; xrot=xrot and 15
                move.w  D5,(A0)+             ; Werte speichern
                move.w  D6,(A0)+
                bra.s   rotwarok
nixrotok:       move.w  #-1,(A0)+
                move.w  #0,(A0)+
rotwarok:       move.l  (A7)+,D4
                move.l  (A7)+,D3
                addq.w  #1,D4                ; x=x+1
                cmp.w   #22,D4               ; x<22?
                bne.s   makedrehloop2
                addq.w  #1,D3                ; y=y+1
                cmp.w   #18,D3               ; y<18?
                bne.s   makedrehloop1
                addq.w  #8,D0                ; Winkel=Winkel+8
                cmp.w   #512,D0
                bne     makedrehloop0
                rts



calculate_coords:
; berechnet die Buchstaben und gibt sie in koord_buffer zurÅck

                move.w  startwinkel,D0       ; dort beginnt Sinusschwingung
                add.w   sinus_speed1,D0      ; Winkel aufaddieren
                and.w   #511,D0
                move.w  D0,startwinkel       ; nÑchster Winkel

                lea     sintab(PC),A0
                move.w  drehwert,D0          ; aktueller Winkel in Sintab
                add.w   drehspeed,D0         ; + Sinusgeschwindigkeit
                and.w   #511,D0
                move.w  D0,drehwert
                add.w   D0,D0                ; wegen Wortwerten
                move.w  0(A0,D0.w),D0        ; Sinus holen
                move.w  dreh_amplitude,D1
                muls    D1,D0                ; * Drehamplitude
                add.l   D0,D0                ; 16384 multipl. ausgleichen
                add.l   D0,D0
                swap    D0
                and.w   #511,D0
                move.w  D0,drehwinkel


                addi.l  #charsanzahl*2,movementpointer
                addq.w  #1,movementcounter
                andi.w  #3,movementcounter
                bne     nixoldpointer
                move.l  #movementtab,movementpointer
                lea     chartab+4(PC),A1     ; Pointer vorkopieren
                moveq   #charsanzahl-2,D0
copyvor:        move.l  (A1)+,-8(A1)
                dbra    D0,copyvor

                addq.l  #1,textpointer
                movea.l textpointer,A0
                cmpi.b  #-1,(A0)
                bne.s   nixlastbyte
                lea     text,A0
nixlastbyte:    cmpi.b  #$df,(A0)            ; Parameter verÑndern?
                bne.s   nixnextparas
                addq.l  #1,A0                ; Textpos +1

                move.l  A1,-(A7)
                move.l  A0,-(A7)
                movea.l parameterpos(PC),A1
                cmpi.w  #-1,(A1)
                bne.s   nixendparas
                lea     parametertab(PC),A1
nixendparas:    move.w  (A1)+,amplitude      ; Parameter verÑndern
                move.w  (A1)+,drehwinkel
                move.w  (A1)+,sinus_speed1
                move.w  (A1)+,sinus_speed2
                move.w  (A1)+,startwinkel
                move.w  (A1)+,drehspeed
                move.w  (A1)+,dreh_amplitude
                move.w  #128,drehwert
                move.l  A1,parameterpos      ; Parameterpointer speichern

                move.l  $0466.w,D0
                and.w   #127,D0
                add.w   D0,D0
                lea     hblfarben(PC),A0
                adda.w  D0,A0
                bsr     makehblfarben
                movea.l (A7)+,A0
                movea.l (A7)+,A1
nixnextparas:   move.l  A0,textpointer
weitr:          moveq   #0,D0
                move.b  (A0),D0              ; Zeichen holen
                mulu    #18*64*4,D0
                lea     drehbuffer,A0
                adda.l  D0,A0
                move.l  A0,-4(A1)            ; in Charbuffer kopieren


nixoldpointer:  movea.l movementpointer,A0   ; dort sind die normalen x-Koord.
                lea     sintab(PC),A1        ; Sinuswerte mit 16384 multipl.
                lea     koord_buffer,A2      ; dort kommen Koordinaten rein
                lea     winkelangleichtab,A3 ; Spezielle Winkel bei Sinus
                moveq   #charsanzahl-1,D0    ; Soviele berechnen
                move.w  amplitude,D1         ; Amplitude der Schwingung
                move.w  startwinkel,D2       ; Startwinkel der Schwingung
                move.w  sinus_speed2,D4      ; wird jeweils auf Winkel addiert
                move.w  D4,D5
                lsr.w   #2,D5
                muls    movementcounter,D5
                sub.w   D5,D2
sinusloop:      move.w  (A0)+,(A2)           ; x-Koord. nur kopieren
                and.w   #511,D2
                move.w  D2,D3
                add.w   D3,D3                ; *2 wegen Worten
                move.w  0(A3,D3.w),4(A2)     ; Winkel kopieren
                move.w  0(A1,D3.w),D3        ; Sinuswert holen
                muls    D1,D3                ; mit Amplitude multiplizieren
                add.l   D3,D3                ; d3 zweimal schieben um die
                add.l   D3,D3                ; Multiplikation mit 16384
                swap    D3                   ; rÅckgÑngig zu machen
                move.w  D3,2(A2)             ; y-Koord.
                lea     6(A2),A2             ; nÑchste Koordinaten
                add.w   D4,D2                ; nÑchster Winkel
                dbra    D0,sinusloop


                lea     sintab(PC),A0        ; Sinuswerte
                move.w  drehwinkel,D1        ; um diesen Winkel wird gedreht
                move.w  D1,D2
                move.w  D1,D3                ; aufheben fÅr spÑter
                add.w   #128,D2              ; Cosinuswinkel=Sinuswinkel+90¯
                and.w   #511,D2              ; Werte von 0-511
                add.w   D1,D1                ; mal 2 wegen Wortwerten
                add.w   D2,D2
                move.w  0(A0,D1.w),D1        ; Sinus holen
                move.w  0(A0,D2.w),D2        ; Cosinus holen
                moveq   #charsanzahl-1,D0    ; soviele Koord. berechnen
                lea     koord_buffer,A0      ; dort sind Koordinaten drin
rotateloop:     move.w  (A0),D4              ; x-Koordinate
                move.w  D4,D5                ; kopieren
                move.w  2(A0),D6             ; y-Koordinate
                move.w  D6,D7
                muls    D1,D4                ; x*sin
                muls    D2,D5                ; x*cos
                muls    D1,D6                ; y*sin
                muls    D2,D7                ; y*cos
                sub.l   D6,D5                ; x'=x*cos-y*sin
                add.l   D7,D4                ; y'=y*cos+x*sin
                add.l   D5,D5                ; zweimal schieben um multipl.
                add.l   D5,D5                ; mit 16384 auszugleichen
                add.l   D4,D4
                add.l   D4,D4
                swap    D4                   ; y-Koordinate
                swap    D5                   ; x-Koordinate
                move.w  D5,(A0)+             ; Speichern
                move.w  D4,(A0)+
                add.w   D3,(A0)+             ; Drehwinkel aufaddieren
                dbra    D0,rotateloop

                rts

initdrehscroller:
                lea     charset(PC),A5
                lea     drehbuffer,A6
                moveq   #charberechen-1,D7
drehit:         movem.l D7/A5-A6,-(A7)
                movea.l A5,A0
                movea.l A6,A1
                bsr     drehchar
                movem.l (A7)+,D7/A5-A6
                lea     14*2(A5),A5
                lea     18*64*4(A6),A6
                dbra    D7,drehit


                move.w  #0,amplitude         ; erste Amplitude
                move.w  #0,drehwinkel        ; um diesen Winkel wird gedreht
                move.w  #0,sinus_speed1      ; so verÑndert sich der Sinus
                move.w  #0,sinus_speed2      ; bei jedem Buchstaben addiert
                move.w  #0,startwinkel       ; hier beginnt der Sinus
                move.w  #0,drehspeed         ; Rotationsgeschwindigkeit
                move.w  #128,dreh_amplitude  ; -amplitude bis +amplitude
                move.w  #128,drehwert
                move.l  #movementtab,movementpointer
                clr.w   movementcounter
                move.l  #text,textpointer
                move.l  #clearbuffer,clearpointer1
                move.l  #clearbuffer+charsanzahl*4,clearpointer2
                lea     clearbuffer,A0
                move.w  #(charsanzahl*2)-1,D0
clrclrbuffer:   clr.l   (A0)+
                dbra    D0,clrclrbuffer

                rts


clearchars:     movea.l clearpointer1,A0
                move.w  #charsanzahl-1,D7
                moveq   #0,D0
clrchars:       movea.l (A0)+,A1
                cmpa.l  #0,A1
                beq     dontclearchar
                move.w  D0,(A1)
                move.w  D0,8(A1)
                move.w  D0,16(A1)
                move.w  D0,160(A1)
                move.w  D0,168(A1)
                move.w  D0,176(A1)
                move.w  D0,320(A1)
                move.w  D0,328(A1)
                move.w  D0,336(A1)
                move.w  D0,480(A1)
                move.w  D0,488(A1)
                move.w  D0,496(A1)
                move.w  D0,640(A1)
                move.w  D0,648(A1)
                move.w  D0,656(A1)
                move.w  D0,800(A1)
                move.w  D0,808(A1)
                move.w  D0,816(A1)
                move.w  D0,960(A1)
                move.w  D0,968(A1)
                move.w  D0,976(A1)
                move.w  D0,1120(A1)
                move.w  D0,1128(A1)
                move.w  D0,1136(A1)
                move.w  D0,1280(A1)
                move.w  D0,1288(A1)
                move.w  D0,1296(A1)
                move.w  D0,1440(A1)
                move.w  D0,1448(A1)
                move.w  D0,1456(A1)
                move.w  D0,1600(A1)
                move.w  D0,1608(A1)
                move.w  D0,1616(A1)
                move.w  D0,1760(A1)
                move.w  D0,1768(A1)
                move.w  D0,1776(A1)
                move.w  D0,1920(A1)
                move.w  D0,1928(A1)
                move.w  D0,1936(A1)
                move.w  D0,2080(A1)
                move.w  D0,2088(A1)
                move.w  D0,2096(A1)
                move.w  D0,2240(A1)
                move.w  D0,2248(A1)
                move.w  D0,2256(A1)
                move.w  D0,2400(A1)
                move.w  D0,2408(A1)
                move.w  D0,2416(A1)
                move.w  D0,2560(A1)
                move.w  D0,2568(A1)
                move.w  D0,2576(A1)
                move.w  D0,2720(A1)
                move.w  D0,2728(A1)
                move.w  D0,2736(A1)

dontclearchar:  dbra    D7,clrchars
                rts

drawchars:
; zeichnet alle Buchstaben
                lea     koord_buffer,A6      ; dort sind die Koord. drin
                movea.l clearpointer1,A5     ; dort Lîschdaten hinschreiben
                lea     andtable,A4          ; spezielle Andwerte
                lea     chartab(PC),A3       ; dort sind Pointer auf Chars
                move.w  #charsanzahl-1,D7    ; soviele Shapes zeichnen
drawcharloop:   move.w  (A6)+,D0             ; x
                move.w  (A6)+,D1             ; y
                move.w  (A6)+,D2             ; Winkel
                add.w   #151,D0              ; Mittelpunkt aufaddieren
                add.w   #91,D1
                and.w   #511,D2              ; Winkel (0-511)
                lsr.w   #3,D2                ; /8 -> 0-63
                mulu    #18*4,D2
                movea.l (A3)+,A0             ; Zeichen holen
                adda.l  D2,A0                ; in a0 jetzt Zeichen
                cmp.w   #-18,D1
                ble     nixpaint
                cmp.w   #200,D1
                bge     nixpaint
                movea.l oldscreen(PC),A1
                lea     6(A1),A1             ; auf Plane 3 gehen
                tst.w   D0
                bmi     cliplinks
                cmp.w   #320-32,D0
                bgt     cliprechts
                move.w  D1,D2                ; y*160
                lsl.w   #7,D2
                lsl.w   #5,D1
                add.w   D2,D1
                adda.w  D1,A1                ; auf Screen addieren
                move.w  D0,D1
                and.w   #-16,D1
                lsr.w   #1,D1
                adda.w  D1,A1
                move.l  A1,(A5)+             ; Pointer reinschreiben
                and.w   #15,D0               ; Rest 0-15
                move.w  D0,D1
                add.w   D1,D1                ; *2 wegen Wortwerten
                move.w  0(A4,D1.w),D3        ; Andwert holen
                move.w  D3,D4
                not.w   D4                   ; zweiter Andwert=not(andwert1)

                REPT 18         ; 18 Zeilen hoch
                move.l  (A0)+,D1             ; Wert aus Shape holen
                ror.l   D0,D1                ; um d0 (0-15) schieben
                move.w  D1,D2
                and.w   D3,D2
                and.w   D4,D1
                or.w    D1,(A1)
                or.w    D2,16(A1)
                swap    D1
                or.w    D1,8(A1)
                lea     160(A1),A1
                ENDR

weiter:         dbra    D7,drawcharloop

                move.l  clearpointer1,D0     ; Pointer tauschen
                move.l  clearpointer2,clearpointer1
                move.l  D0,clearpointer2
                rts

nixpaint:       move.l  #0,(A5)+             ; spÑter nichts lîschen
                bra.s   weiter

cliplinks:      cmp.w   #-16,D0
                ble     cliplinks2
                move.w  D1,D2                ; y*160
                lsl.w   #7,D2
                lsl.w   #5,D1
                add.w   D2,D1
                adda.w  D1,A1                ; auf Screen addieren
                move.l  A1,(A5)+             ; Pointer reinschreiben
                and.w   #15,D0               ; Rest 0-15
                move.w  D0,D1
                add.w   D1,D1                ; *2 wegen Wortwerten
                move.w  0(A4,D1.w),D3        ; Andwert holen
                move.w  D3,D4
                not.w   D4                   ; zweiter Andwert=not(andwert1)

                REPT 18         ; 18 Zeilen hoch
                move.l  (A0)+,D1             ; Wert aus Shape holen
                ror.l   D0,D1                ; um d0 (0-15) schieben
                move.w  D1,D2
                and.w   D3,D2
                and.w   D4,D1
                or.w    D2,8(A1)
                swap    D1
                or.w    D1,(A1)
                lea     160(A1),A1
                ENDR

                bra     weiter

cliplinks2:     cmp.w   #-32,D0
                ble     nixpaint
                move.w  D1,D2                ; y*160
                lsl.w   #7,D2
                lsl.w   #5,D1
                add.w   D2,D1
                adda.w  D1,A1                ; auf Screen addieren
                move.l  A1,(A5)+             ; Pointer reinschreiben
                and.w   #15,D0               ; Rest 0-15
                move.w  D0,D1
                add.w   D1,D1                ; *2 wegen Wortwerten
                move.w  0(A4,D1.w),D3        ; Andwert holen
                move.w  D3,D4
                not.w   D4                   ; zweiter Andwert=not(andwert1)

                REPT 18         ; 18 Zeilen hoch
                move.l  (A0)+,D1             ; Wert aus Shape holen
                ror.l   D0,D1                ; um d0 (0-15) schieben
                and.w   D3,D1
                or.w    D1,(A1)
                lea     160(A1),A1
                ENDR

                bra     weiter

cliprechts:     cmp.w   #320-16,D0
                bge     cliprechts2
                move.w  D1,D2                ; y*160
                lsl.w   #7,D2
                lsl.w   #5,D1
                add.w   D2,D1
                adda.w  D1,A1                ; auf Screen addieren
                lea     144(A1),A1           ; rechtes Ende
                move.l  A1,(A5)+             ; Pointer reinschreiben
                and.w   #15,D0               ; Rest 0-15
                move.w  D0,D1
                add.w   D1,D1                ; *2 wegen Wortwerten
                move.w  0(A4,D1.w),D3        ; Andwert holen
                move.w  D3,D4
                not.w   D4                   ; zweiter Andwert=not(andwert1)

                REPT 18         ; 18 Zeilen hoch
                move.l  (A0)+,D1             ; Wert aus Shape holen
                ror.l   D0,D1                ; um d0 (0-15) schieben
                and.w   D4,D1
                or.w    D1,(A1)
                swap    D1
                or.w    D1,8(A1)
                lea     160(A1),A1
                ENDR

                bra     weiter

cliprechts2:    cmp.w   #320,D0
                bge     nixpaint
                move.w  D1,D2                ; y*160
                lsl.w   #7,D2
                lsl.w   #5,D1
                add.w   D2,D1
                adda.w  D1,A1                ; auf Screen addieren
                lea     152(A1),A1
                move.l  A1,(A5)+             ; Pointer reinschreiben
                and.w   #15,D0               ; Rest 0-15
                move.w  D0,D1
                add.w   D1,D1                ; *2 wegen Wortwerten
                move.w  0(A4,D1.w),D3        ; Andwert holen
                move.w  D3,D4
                not.w   D4                   ; zweiter Andwert=not(andwert1)

                REPT 18         ; 18 Zeilen hoch
                move.l  (A0)+,D1             ; Wert aus Shape holen
                ror.l   D0,D1                ; um d0 (0-15) schieben
                and.w   D4,D1
                or.w    D1,(A1)
                lea     160(A1),A1
                ENDR


                bra     weiter




drehchar:
; dreht Buchstaben 64 mal
; in a0=Sourcebuchstabe (16*14)
; in a1=Buffer fÅr gedrehten Buchstaben (64*4*18)

                lea     drehtab,A2
                moveq   #63,D0               ; 64 * 8 Grad Schritte
drehloop0:      moveq   #17,D1               ; 18 hoch
drehloop1:      moveq   #21,D2               ; 22 breit
                moveq   #0,D7                ; dort wird Wert erzeugt
drehloop2:      move.w  (A2)+,D3             ; Offset (mal 2)
                move.w  (A2)+,D4             ; Bit
                tst.w   D3
                bmi.s   no_plot
                move.w  0(A0,D3.w),D5        ; Wert holen
                btst    D4,D5                ; Bit gesetzt ?
                beq.s   no_plot
                move.w  D2,D6
                eori.w  #31,D6
                bset    D6,D7
no_plot:        dbra    D2,drehloop2
                swap    D7                   ; wegen speziellem Zeichnen
                move.l  D7,(A1)+             ; Wert abspeicheren
                dbra    D1,drehloop1         ; Zeichenroutine
                dbra    D0,drehloop0
                rts

;-------------------- Drehscroller Ende ------------------------


switch:         move.l  oldscreen,D0         ; auf Oldscreen arbeiten!!
                move.l  newscreen,oldscreen
                move.l  D0,newscreen
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

cls:
; Screen in a0
                move.w  #7999,D0
clsloop:        clr.l   (A0)+
                dbra    D0,clsloop
                rts


hbl_on:         move    SR,-(A7)
                ori     #$0700,SR
                lea     hbl_buff,A0
                move.b  $fffffa09.w,(A0)+    ; Werte retten
                move.b  $fffffa07.w,(A0)+
                move.b  $fffffa13.w,(A0)+
                move.b  $fffffa1b.w,(A0)+
                move.b  $fffffa11.w,(A0)+
                move.b  $fffffa21.w,(A0)+
                move.b  $fffffa17.w,(A0)+
                lea     1(A0),A0
                move.l  $0118.w,(A0)+
                move.l  $0120.w,(A0)+
                move.l  $70.w,(A0)+
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
                lea     hbl_buff,A0          ; Werte zureck!
                move.b  (A0)+,$fffffa09.w
                move.b  (A0)+,$fffffa07.w
                move.b  (A0)+,$fffffa13.w
                move.b  (A0)+,$fffffa1b.w
                move.b  (A0)+,$fffffa11.w
                move.b  (A0)+,$fffffa21.w
                move.b  (A0)+,$fffffa17.w
                lea     1(A0),A0
                move.l  (A0)+,$0118.w
                move.l  (A0)+,$0120.w
                move.l  (A0)+,$70.w
                move    (A7)+,SR
                rts

vbl:            movem.l D0-A6,-(A7)

                clr.b   $fffffa1b.w
                move.b  #8,$fffffa21.w
                move.b  #8,$fffffa1b.w
                lea     hblcolors,A0
                move.l  (A0),$ffff8250.w
                move.l  (A0),$ffff8254.w
                move.l  (A0),$ffff8258.w
                move.l  (A0)+,$ffff825c.w
                move.l  A0,hblpointer


                tst.w   littlescroller
                bne.s   screennormal
                bsr     scroller
                bra.s   endvbl
screennormal:
                bsr     clearoldstarfield
                bsr     clearchars
                bsr     calculate_coords
                bsr     logohupps
                bsr     drawstarfield
                bsr     drawchars
                bsr     switch


endvbl:         jsr     music+8
                addq.l  #1,$0466.w
                movem.l (A7)+,D0-A6
                rte


newkey:         move.w  D0,-(A7)
                move.b  $fffffc00.w,D0
                btst    #7,D0
                beq.s   nixkey
                move.b  $fffffc02.w,key
nixkey:         move.w  (A7)+,D0
                rte

hbl:            move.l  A0,-(A7)
                movea.l hblpointer,A0
                move.l  (A0),$ffff8250.w
                move.l  (A0),$ffff8254.w
                move.l  (A0),$ffff8258.w
                move.l  (A0)+,$ffff825c.w
                move.l  A0,hblpointer
                movea.l (A7)+,A0
                rte

                DATA

newscreen:      DC.L 0
oldscreen:      DC.L 0


palette:
;Palette of DELTASTR.IFF: Saved by NEOchrome V2.15 by Chaos, Inc.
                DC.W $00,$0333,$0555,$0777,$0223,$0334,$0445,$07

charset:        INCBIN 'FONT.IMG' ; 58 Zeichen (16*14)

xcount          SET -176        ; Tabelle mit Bewegung von rechts nach links
movementtab:    REPT charsanzahl ; nur x-Werte
                DC.W xcount
xcount          SET xcount+16
                ENDR
xcount          SET -180        ; Tabelle mit Bewegung von rechts nach links
                REPT charsanzahl ; nur x-Werte
                DC.W xcount
xcount          SET xcount+16
                ENDR
xcount          SET -184
                REPT charsanzahl
                DC.W xcount
xcount          SET xcount+16
                ENDR
xcount          SET -188
                REPT charsanzahl
                DC.W xcount
xcount          SET xcount+16
                ENDR

chartab:        REPT charsanzahl ; Tabelle mit Pointern auf Buchstaben
                DC.L drehbuffer+38*18*64*4
                ENDR

sintab:
; Sinustabelle mit 16384 multipliziert (512 Werte)

                DC.W 0,196,411,607,803,1000,1214,1410
                DC.W 1605,1801,2014,2209,2403,2598,2809,3003
                DC.W 3196,3388,3598,3789,3980,4171,4378,4567
                DC.W 4755,4943,5147,5334,5519,5704,5904,6087
                DC.W 6269,6450,6647,6826,7004,7182,7374,7549
                DC.W 7723,7896,8083,8253,8422,8590,8772,8938
                DC.W 9102,9264,9441,9601,9759,9916,10086,10240
                DC.W 10393,10545,10708,10855,11002,11147,11303,11445
                DC.W 11585,11723,11871,12006,12139,12270,12411,12539
                DC.W 12664,12788,12921,13041,13159,13275,13400,13512
                DC.W 13622,13730,13846,13950,14052,14152,14259,14355
                DC.W 14449,14540,14638,14725,14810,14893,14981,15060
                DC.W 15136,15210,15289,15358,15425,15491,15559,15619
                DC.W 15678,15734,15792,15843,15892,15939,15987,16029
                DC.W 16068,16105,16143,16176,16206,16233,16261,16284
                DC.W 16304,16323,16339,16352,16363,16372,16378,16382
                DC.W 16384,16382,16378,16372,16363,16352,16338,16323
                DC.W 16304,16284,16259,16233,16206,16176,16140,16105
                DC.W 16068,16029,15983,15939,15892,15843,15787,15734
                DC.W 15678,15619,15553,15491,15425,15358,15282,15210
                DC.W 15136,15060,14974,14893,14810,14725,14630,14540
                DC.W 14449,14355,14250,14152,14052,13950,13836,13730
                DC.W 13622,13512,13389,13275,13159,13041,12910,12788
                DC.W 12664,12539,12399,12270,12139,12006,11859,11723
                DC.W 11585,11445,11290,11147,11002,10855,10694,10545
                DC.W 10393,10240,10072,9916,9759,9601,9426,9264
                DC.W 9102,8938,8757,8590,8422,8253,8067,7896
                DC.W 7723,7549,7358,7182,7004,6826,6631,6450
                DC.W 6269,6087,5888,5704,5519,5334,5130,4943
                DC.W 4755,4567,4361,4171,3980,3789,3580,3388
                DC.W 3196,3003,2792,2598,2403,2209,1996,1801
                DC.W 1605,1410,1196,1000,803,607,393,196
                DC.W 0,-197,-412,-608,-804,-1001,-1215,-1411
                DC.W -1606,-1802,-2015,-2210,-2404,-2599,-2810,-3004
                DC.W -3197,-3389,-3599,-3790,-3981,-4172,-4379,-4568
                DC.W -4756,-4944,-5148,-5335,-5520,-5705,-5905,-6088
                DC.W -6270,-6451,-6648,-6827,-7005,-7183,-7375,-7550
                DC.W -7724,-7897,-8084,-8254,-8423,-8591,-8773,-8939
                DC.W -9103,-9265,-9442,-9602,-9760,-9917,-10087,-10241
                DC.W -10394,-10546,-10709,-10856,-11003,-11148,-11304,-11446
                DC.W -11586,-11724,-11872,-12007,-12140,-12271,-12412,-12540
                DC.W -12665,-12789,-12922,-13042,-13160,-13276,-13401,-13513
                DC.W -13623,-13731,-13847,-13951,-14053,-14153,-14260,-14356
                DC.W -14450,-14541,-14639,-14726,-14811,-14894,-14982,-15061
                DC.W -15137,-15211,-15290,-15359,-15426,-15492,-15560,-15620
                DC.W -15679,-15735,-15793,-15844,-15893,-15940,-15988,-16030
                DC.W -16069,-16106,-16144,-16177,-16207,-16234,-16262,-16285
                DC.W -16305,-16324,-16340,-16353,-16364,-16373,-16379,-16383
                DC.W -16384,-16383,-16379,-16373,-16364,-16353,-16339,-16324
                DC.W -16305,-16285,-16260,-16234,-16207,-16177,-16141,-16106
                DC.W -16069,-16030,-15984,-15940,-15893,-15844,-15788,-15735
                DC.W -15679,-15620,-15554,-15492,-15426,-15359,-15283,-15211
                DC.W -15137,-15061,-14975,-14894,-14811,-14726,-14631,-14541
                DC.W -14450,-14356,-14251,-14153,-14053,-13951,-13837,-13731
                DC.W -13623,-13513,-13390,-13276,-13160,-13042,-12911,-12789
                DC.W -12665,-12540,-12400,-12271,-12140,-12007,-11860,-11724
                DC.W -11586,-11446,-11291,-11148,-11003,-10856,-10695,-10546
                DC.W -10394,-10241,-10073,-9917,-9760,-9602,-9427,-9265
                DC.W -9103,-8939,-8758,-8591,-8423,-8254,-8068,-7897
                DC.W -7724,-7550,-7359,-7183,-7005,-6827,-6632,-6451
                DC.W -6270,-6088,-5889,-5705,-5520,-5335,-5131,-4944
                DC.W -4756,-4568,-4362,-4172,-3981,-3790,-3581,-3389
                DC.W -3197,-3004,-2793,-2599,-2404,-2210,-1997,-1802
                DC.W -1606,-1411,-1197,-1001,-804,-608,-394,-197


stargraf:       DC.W $8000,$4000,$2000,$1000,$0800,$0400,$0200,$0100
                DC.W $80,$40,$20,$10,$08,$04,$02,$01

lamestars:      INCBIN 'STARS.IMG'
lamestartab1    EQU lamestars
lamestartab2    EQU lamestars+160
lamestartab3    EQU lamestars+320




winkelangleichtab:
; wegen Sinuswerten (Sinus stimmt nicht ganz)

wink            SET 384         ; 0-90 entspricht 270-360
                REPT 128
                DC.W wink
wink            SET wink+1
                ENDR
wink            SET 0           ; 90-180 entspricht 0-90
                REPT 128
                DC.W wink
wink            SET wink+1
                ENDR
wink            SET 128         ; 180-270 entspricht 90-0
                REPT 128
                DC.W wink
wink            SET wink-1
                ENDR
wink            SET 512         ; 270-360 entspricht 360-270
                REPT 128
                DC.W wink
wink            SET wink-1
                ENDR


text:           INCBIN 'TEXT.IMG'
                EVEN

music:          INCBIN 'ROBOCOP3.IMG'
                EVEN

anfangstext:
; Scroller ganz am Anfang wÑhrend Berechnung
                INCBIN 'BEGIN.IMG'
                EVEN



dobbstab:

                DC.W 13120,12800,12640,12480,12320,12000,11840,11680
                DC.W 11680,11520,11360,11360,11200,11200,11200,11200
                DC.W 11200,11200,11200,11360,11360,11520,11680,11680
                DC.W 11840,12000,12320,12480,12640,12800,12960


                DC.W 13120,12800,12480,12160,11840,11520,11200,11040
                DC.W 10720,10560,10400,10080,9920,9920,9760,9600
                DC.W 9600,9600,9600,9600,9600,9600,9760,9920
                DC.W 9920,10080,10400,10560,10720,11040,11200,11520
                DC.W 11840,12160,12480,12800,12960


                DC.W 13120,12640,12160,11680,11360,10880,10400,10080
                DC.W 9760,9440,9120,8800,8640,8320,8160,8160
                DC.W 8000,8000,8000,8000,8000,8160,8160,8320
                DC.W 8640,8800,9120,9440,9760,10080,10400,10880
                DC.W 11360,11680,12160,12640,12960


                DC.W 13120,12640,12160,11680,11200,10720,10240,9920
                DC.W 9440,9120,8800,8320,8000,7680,7520,7200
                DC.W 7040,6880,6720,6560,6400,6400,6400,6400
                DC.W 6400,6400,6560,6720,6880,7040,7200,7520
                DC.W 7680,8000,8320,8800,9120,9440,9920,10240
                DC.W 10720,11200,11680,12160,12640,12960


                DC.W 13120,12640,12160,11680,11360,10880,10400,10080
                DC.W 9600,9280,8800,8480,8160,7840,7520,7200
                DC.W 6880,6560,6240,6080,5760,5600,5440,5280
                DC.W 5120,4960,4960,4800,4800,4800,4800,4800
                DC.W 4800,4800,4960,4960,5120,5280,5440,5600
                DC.W 5760,6080,6240,6560,6880,7200,7520,7840
                DC.W 8160,8480,8800,9280,9600,10080,10400,10880
                DC.W 11360,11680,12160,12640,12960


                DC.W 13120,12480,12000,11520,11040,10400,9920,9440
                DC.W 8960,8480,8000,7680,7200,6720,6400,6080
                DC.W 5600,5280,4960,4800,4480,4160,4000,3840
                DC.W 3680,3520,3360,3200,3200,3200,3200,3200
                DC.W 3200,3200,3360,3520,3680,3840,4000,4160
                DC.W 4480,4800,4960,5280,5600,6080,6400,6720
                DC.W 7200,7680,8000,8480,8960,9440,9920,10400
                DC.W 11040,11520,12000,12480,12960


                DC.W 13120,12480,11840,11200,10720,10080,9440,8960
                DC.W 8320,7840,7200,6720,6240,5760,5280,4960
                DC.W 4480,4160,3680,3360,3040,2720,2560,2240
                DC.W 2080,1920,1760,1600,1600,1600,1600,1600
                DC.W 1600,1600,1760,1920,2080,2240,2560,2720
                DC.W 3040,3360,3680,4160,4480,4960,5280,5760
                DC.W 6240,6720,7200,7840,8320,8960,9440,10080
                DC.W 10720,11200,11840,12480,12960


                DC.W 13120,12320,11680,11040,10240,9600,8960,8320
                DC.W 7680,7040,6400,5920,5280,4800,4320,3840
                DC.W 3360,2880,2400,2080,1600,1280,1120,800
                DC.W 640,320,160,160,0,0,0,0
                DC.W 0,160,160,320,640,800,1120,1280
                DC.W 1600,2080,2400,2880,3360,3840,4320,4800
                DC.W 5280,5920,6400,7040,7680,8320,8960,9600
                DC.W 10240,11040,11680,12320,12960,-99


parameterpos:   DC.L parametertab

parametertab:
; dort sind die Parameter fÅr den Scroller
; 7 Worte=14 Bytes
                DC.W -40,0,6,32,0,2,128
                DC.W 0,0,0,0,128,0,0
                DC.W -60,0,-4,16,0,4,32
                DC.W -40,0,-4,16,0,1,128
                DC.W -100,0,-4,8,0,4,25
                DC.W 0,0,0,0,128,3,50
                DC.W -60,0,2,32,0,0,0
                DC.W -20,0,2,64,0,0,0
                DC.W -20,0,2,64,0,4,40
                DC.W -60,0,8,0,0,0,0
                DC.W -100,0,1,16,0,1,128
                DC.W 0,0,0,0,128,5,40
                DC.W 0,0,0,0,0,0,128
                DC.W -100,0,-2,16,0,4,20
                DC.W -80,0,-4,8,0,0,0
                DC.W -70,0,1,-16,0,0,0
                DC.W 0,0,0,0,128,-2,120
                DC.W -60,0,6,24,128,-10,30
                DC.W -40,0,6,32,0,4,60
                DC.W -40,0,6,48,0,0,0
                DC.W -80,0,6,16,0,0,0
                DC.W -80,0,-2,16,0,0,0
                DC.W 60,0,-2,16,128,-4,32
                DC.W -60,0,-2,16,128,-8,32
                DC.W -30,0,-8,16,128,-2,32
                DC.W -30,0,-8,16,0,0,0
                DC.W -60,0,-1,16,0,-4,32
                DC.W -80,0,-1,16,0,2,128
                DC.W -20,0,-1,16,0,-2,32
                DC.W -40,0,-8,8,0,8,96
                DC.W 0,0,0,0,128,0,0
                DC.W -1



andtable:
; this is a table of 16 words I need to and out what I want out of the
; shiftet gfx.
                DC.W %0
                DC.W %1000000000000000
                DC.W %1100000000000000
                DC.W %1110000000000000
                DC.W %1111000000000000
                DC.W %1111100000000000
                DC.W %1111110000000000
                DC.W %1111111000000000
                DC.W %1111111100000000
                DC.W %1111111110000000
                DC.W %1111111111000000
                DC.W %1111111111100000
                DC.W %1111111111110000
                DC.W %1111111111111000
                DC.W %1111111111111100
                DC.W %1111111111111110

hblfarben:      INCBIN 'HBL2.PAL'

dflogo:         INCBIN 'DFLOGO3.IMG' ; 240*2*52




                BSS

drehtab:        DS.L 101376/4

; Megastartab ist 134400 groû
; VORSICHT !hier nichts einfÅgen!!!!!!!!!!!!

megastartab1    EQU drehtab     ; Drehtab Åberschreiben
megastartab2    EQU megastartab1+76800
megastartab3    EQU megastartab2+38400

; megastartab: 0.w = Screenoffset, 2.w Bit 15-0, 4.w Grafikoffset
                DS.B 33024

megaclearbuff:
; jeweils Pointer un dann Data (Longs)
                DS.L starsanzahl*2*2 ; (2 Buffer)


megastarbuff:   DS.L 2*starsanzahl ; zuerst Sterne vorne, mitte, hinten
; 0.l=  Dpos
; 4.l = Deltawerte (nicht verÑndert)


;----------------------- Variable --------------------
stars1counter:  DS.W 1          ; Speed 1
stars2counter:  DS.W 1          ; Speed 2
stars3counter:  DS.W 1          ; Speed 4
megaclearpoint1:DS.L 1
megaclearpoint2:DS.L 1
;------------------------ Buffer ----------------------

********************* System *******************

hbl_buff:       DS.W 10
                IFEQ diskversion
ssp:            DS.L 1
oldres:         DS.W 1
oldsync:        DS.W 1
logbase:        DS.L 1
physbase:       DS.L 1
oldpal:         DS.L 8
                ENDC
********************** Variable ****************
;---------- Kleiner Scroller
mempos:         DS.L 1          ; Zeiger auf Zeichen fÅr Scroller
textpos:        DS.L 1
zeichen:        DS.W 1
littlescroller: DS.W 1          ; 0=kleiner Scroller an/1=aus
;---------------------------

key:            DS.W 1
amplitude:      DS.W 1          ; Amplitude in y-Richtung fÅr Schwingung
startwinkel:    DS.W 1          ; von dort beginnt Sinusschwingung
sinus_speed1:   DS.W 1          ; erster GeschwindigkeitszÑhler
sinus_speed2:   DS.W 1          ; zweiter GeschwindigkeitszÑhler
dreh_amplitude: DS.W 1
drehspeed:      DS.W 1          ; wird auf den aktuellen Drehwinkel addiert
drehwinkel:     DS.W 1          ; um diesen Winkel wird gedreht (0-511)
drehwert:       DS.W 1          ; dort steht Winkel in Sintab fÅr Rotation
textpointer:    DS.L 1          ; Dort steht Pointer im Text
movementpointer:DS.L 1          ; Pointer in Movement-Tabelle
movementcounter:DS.W 1          ; Werte von 0-7 zum ZÑhlen
hblpointer:     DS.L 1          ; dort ist Pointer auf Farben
clearpointer1:  DS.L 1
clearpointer2:  DS.L 1
dobbspoint:     DS.L 1          ; Pointer in Dobbstabelle
cleardobbs1:    DS.W 1          ; Werte zum lîschen des Logos
cleardobbs2:    DS.W 1
********************** Buffer *********************
hblcolors:      DS.L 26
clearbuffer:    DS.L 2*charsanzahl ; jeweils Pointer.l
koord_buffer:   DS.W 3*charsanzahl ; dort sind x,y,Drehwinkel drin
drehbuffer:     DS.L 18*64*charberechen ; Hîhe*Drehanzahl*Anzahl Buchstaben
                DS.B 256
screenbuff:     DS.B 38144*2    ; Screens grîûer um Clipping zu sparen
                END
