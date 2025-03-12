*********************************************************************
***                                                               ***
***                       M A T C H  -  I T !                     ***
***                      ~~~~~~~~~~~~~~~~~~~~~                    ***
***                                                               ***
***                 (C) by New Mode of Delta Force                ***
***                                                               ***
***---------------------------------------------------------------***
***            Programmerstellung begann am: 29.10.89             ***
***            Aktuelles Datum             : 28.11.90             ***
***---------------------------------------------------------------***
*********************************************************************

; SetVideo() equates.

VERTFLAG	EQU $0100	; double-line on VGA, interlace on ST/TV ;
STMODES		EQU $0080	; ST compatible ;
OVERSCAN	EQU $0040	; Multiply X&Y rez by 1.2, ignored on VGA ;
PAL		EQU $0020	; PAL if set, else NTSC ;
VGA		EQU $0010	; VGA if set, else TV mode ;
COL80		EQU $0008	; 80 column if set, else 40 column ;
BPS16		EQU $0004
BPS8		EQU $0003
BPS4		EQU $0002
BPS2		EQU $0001
BPS1		EQU $0000

		output	d:\coding.s\misc\matchit\matchit.prg

ystartline      EQU 24          ; ab dort beginnen Tiles
eisrand         EQU 8           ; ab dort auf Eisplatte sind die Tiles


                TEXT

                pea     start(PC)
                move.w  #38,-(A7)
                trap    #14
                addq.l  #6,A7
                clr.w   -(A7)
                trap    #1

start: 		move.w	#2,-(a7)
		trap	#14
		addq.l	#2,a7
		move.l	d0,oldscreen
		MOVE.W #-1,-(SP)
		MOVE.W #$58,-(SP)
		TRAP #14
		ADDQ.L #4,SP
		MOVE.W D0,oldres

                move.l  A7,oldstack
                lea     stack,A7

		clr.w	highscoremade

                bsr     loadhighscores

                bsr     initscroller

                lea     leerfeld,A0
                moveq   #7,D0
clrleerfeld:    clr.l   (A0)+
                dbra    D0,clrleerfeld

                lea     scrollsavebuff,A0    ; Scrollbuff l�schen
                move.w  #(15*40)-1,D0
clrscrollbuff:  clr.l   (A0)+
                dbra    D0,clrscrollbuff

                movem.l leerfeld,D0-D7
                movem.l D0-D7,hilfspalette1

                lea     font,A0
                move.l  #7200,D0
                bsr     backform

                lea     eisplatte,A0
                move.l  #28960,D0
                bsr     backform

                bsr     preferences          ; Raster an, usw.

		bsr	do_budgie

		move.l	#vblquit,$70.w

                bsr     make_leveltab        ; zufallsm��ige Verteilung der Levels

                move.w  #1,scrollready       ; nicht Zeichnen

                clr.l   cheatmode            ; Pos.
                move.l  #cheatmode,cheatpoint
                move.w  #1,musicflag         ; Music an

menu:           move.l  #mauszeiger2,mousepointer
                clr.l   rettbuff             ; Maus nicht restaurieren
                move.w  #100,mousex
                move.w  #100,mousey          ; Maus positionieren

                move.w  #1,scrollready

                movem.l leerfeld,D0-D7
                movem.l D0-D7,hilfspalette1

                move.l  #vblmenu,$70.w

                movea.l screen1(PC),A0
                bsr     cls

                lea     menuplatte,A0
                movea.l screen1(PC),A1
                lea     37*160(A1),A1
                lea     37*160(A1),A2        ; Platten reinkopieren
                lea     37*160(A2),A3
                lea     37*160(A3),A4
                move.w  #(16*40)-1,D0
copymenu:       move.l  (A0),(A1)+
                move.l  (A0),(A2)+
                move.l  (A0),(A3)+
                move.l  (A0)+,(A4)+
                dbra    D0,copymenu

                lea     menutext0,A0
                movea.l screen1(PC),A1
                moveq   #40,D0
                moveq   #5,D1
                moveq   #5,D2
                bsr     textaus2

                lea     menutext1,A0
                movea.l screen1(PC),A1
                moveq   #40,D0
                moveq   #5,D1
                move.w  #38,D2
                bsr     textaus
                lea     menutext2,A0
                movea.l screen1(PC),A1
                moveq   #40,D0
                moveq   #3,D1
                move.w  #75,D2
                bsr     textaus
                lea     menutext3,A0
                movea.l screen1(PC),A1
                moveq   #40,D0
                moveq   #4,D1
                move.w  #112,D2
                bsr     textaus
                lea     menutext4,A0
                movea.l screen1(PC),A1
                moveq   #40,D0
                moveq   #8,D1
                move.w  #149,D2
                bsr     textaus

                bsr     vsync
                lea     scrollsavebuff,A0
                movea.l screen1(PC),A1
                lea     184*160(A1),A1
                move.w  #(15*40)-1,D0
copyscrollbuff: move.l  (A0)+,(A1)+
                dbra    D0,copyscrollbuff

                clr.w   scrollready          ; Scroller an

                bsr     fadeup3

                tst.w   musicflag
                bne.s   nixanschalten        ; falls Musik aus war, -> anmachen
                bsr     musiconoff
nixanschalten:

                clr.w   mousek
                clr.b   keybuffer

waitforkey:     cmpi.b  #1,keybuffer         ; Escape?
                beq     ende
                move.b  mousek,D0            ; Maustaste holen
                btst    #1,D0                ; linke Maustaste gedr�ckt?
                beq.s   waitforkey
                moveq   #0,D0
                move.w  mousey,D0
                sub.w   #37,D0
                divu    #37,D0               ; damit Werte von 0-3
                swap    D0
                cmp.w   #16,D0               ; Rest>16?
                bgt.s   waitforkey
                swap    D0
                tst.w   D0
                bne.s   notstartgame
                bsr     rettscrollbuff
                bsr     fadedown3
                bsr     gamestart            ; Spiel beginnen!
                bra     menu
notstartgame:   cmp.w   #1,D0                ; Highscores?
                bne.s   nothighs
                bsr     rettscrollbuff
                bsr     fadedown3
                bsr     highscoreout         ; Highscores zeigen!
                bra     menu
nothighs:       cmp.w   #2,D0
                bne.s   notinstr
                bsr     rettscrollbuff
                bsr     fadedown3
                bsr     instructions         ; Highscores zeigen!
                bra     menu
notinstr:       cmp.w   #3,D0
                beq     ende                 ; Programm beenden
                bra.s   waitforkey

rettscrollbuff:
                move.w  #1,scrollready       ; Scroller aus
                bsr     vsync
                lea     scrollsavebuff,A1
                movea.l screen1(PC),A0
                lea     184*160(A0),A0
                move.w  #(15*40)-1,D0
copyscrollbuff2:move.l  (A0)+,(A1)+
                dbra    D0,copyscrollbuff2
                rts


gamestart:      clr.w   score                ; Score=0
                move.w  #1,stage             ; Level 1
                move.w  #2,helpcount         ; 3 Helps
                move.w  #70,timeverzoegerung
                move.l  #mauszeiger,mousepointer

levelloop:      bsr     initgame

gameloop:       bsr     oneplayermouse       ; jeweilige Joyroutine
                tst.w   endeflag             ; falls Zu Ende-> Main
                bpl     nixgameover          ; Ende des Spiels (Zeit aus!)
                bsr     gameover
                rts
nixgameover:    cmpi.w  #2,endeflag
                beq     endegame             ; zur�ck ins Men�
                cmpi.w  #1,endeflag          ; n�chster Level?
                bne.s   gameloop

nextlevel:      move.w  #1,timestop          ; Zeit sofort anhalten
                move.l  #vblpause,$70.w
                bsr     initpalpointers
                bsr     fadeup2              ; auf wei� hochblenden
                lea     hilfspalette1,A0
                moveq   #15,D0
fillpalweiss:   move.w  #$0777,(A0)+
                dbra    D0,fillpalweiss
                move.l  #vblgame2,$70.w
                bsr     vsync

                bsr     exitpalpointers


                movea.l screen1(PC),A0
                bsr     cls

                lea     welldonetext,A0
                movea.l screen1(PC),A1
                moveq   #40,D0
                moveq   #5,D1
                moveq   #2,D2
                bsr     textaus

                lea     clearedstagetext,A0
                movea.l screen1(PC),A1
                moveq   #40,D0
                moveq   #0,D1
                moveq   #40,D2
                bsr     textaus

                move.w  stage,D0
                bsr     hexdez
                lea     hexdezbuff+4,A0
                moveq   #2,D0
                bsr     nullfix
                movea.l screen1(PC),A1
                moveq   #18,D1
                moveq   #40,D2
                bsr     textaus

                moveq   #0,D0
                move.w  helpcount,D0
                mulu    #100,D0
                move.w  D0,helpbonus

                cmpi.w  #5,helpcount         ; hat schon 5  Helps
                beq.s   nixaddhelp
                tst.w   helpverbraucht       ; hat Help benutzt!
                bne.s   nixaddhelp           ; bekommt kein Help dazu!
                addq.w  #1,helpcount         ; pro Level 1 Help dazu!
nixaddhelp:

                lea     scoretext,A0
                moveq   #40,D0
                moveq   #2,D1
                moveq   #70,D2
                movea.l screen1(PC),A1
                bsr     textaus

                lea     timebonustext,A0
                moveq   #40,D0
                moveq   #2,D1
                move.w  #90,D2
                movea.l screen1(PC),A1
                bsr     textaus

                lea     helpbonustext,A0
                moveq   #40,D0
                moveq   #2,D1
                move.w  #110,D2
                movea.l screen1(PC),A1
                bsr     textaus

                bsr     outputhelpbonus
                bsr     outputscore
                bsr     outputtime

                bsr     fadedown2

                moveq   #20,D7
waitabithere:   bsr     vsync
                dbra    D7,waitabithere

                move.w  time,D7
                subq.w  #1,D7
                bmi.s   nixaddtimetoscore
addtimetoscore: bsr     vsync
                subq.w  #1,time              ; Zeit -1
                addq.w  #1,score             ; Score +1
                bsr     outputscore
                bsr     outputtime
                dbra    D7,addtimetoscore

nixaddtimetoscore:
                moveq   #20,D7
waitabithere2:  bsr     vsync
                dbra    D7,waitabithere2

                moveq   #0,D7
                move.w  helpbonus,D7
                divu    #100,D7
                subq.w  #1,D7
                bmi.s   nixaddhelptoscore
addhelptoscore: moveq   #9,D1
verz:           bsr     vsync
                dbra    D1,verz
                subi.w  #100,helpbonus
                addi.w  #100,score
                bsr     outputscore
                bsr     outputhelpbonus
                dbra    D7,addhelptoscore

nixaddhelptoscore:
                addq.w  #1,stage             ; Level erh�hen
                cmpi.w  #65,stage            ; Spiel geschafft?
                bne     notlaststage         ; Spiel zu Ende!

                move.w  #-3,endeflag

                lea     stage64text,A0
                moveq   #40,D0
                moveq   #0,D1
                move.w  #130,D2
                movea.l screen1(PC),A1
                bsr     textaus2

                lea     bonus64text,A0
                moveq   #40,D0
                moveq   #0,D1
                move.w  #150,D2
                movea.l screen1(PC),A1
                bsr     textaus2

                addi.w  #5000,score
                bsr     outputscore

                bsr     button
                bra     gameovereins


notlaststage:   bsr     button

                bsr     fadedown3

                movea.l screen1(PC),A0
                bsr     cls

                clr.w   endeflag

                cmpi.w  #20,timeverzoegerung ; niedrigestes Niveau
                beq.s   nixsubstarttime
                subq.w  #2,timeverzoegerung  ; Zeit -5 Sekunden n�chster Level
nixsubstarttime:

                bra     levelloop

endegame:       rts



backform:
; formt Bild aus Spezialformat zur�ck
; a0=Adresse
; d0=L�nge
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
                rts




do_budgie:
; Kopiert Logo rein und faded es hoch und runter

		bsr	fadebudgie

                lea     budgie_pic,A0
                movea.l screen1(PC),A1
                move.w  #7999,D0
copy_budgie:    move.l  (A0)+,(A1)+
                dbra    D0,copy_budgie


                moveq   #0,D7
fade_all_white: lea     $ffff8242.w,A0
                moveq   #14,D0
copy_col:       move.w  D7,(A0)+
                dbra    D0,copy_col
                bsr     vsync
                bsr     vsync
                add.w   #$0111,D7
                cmp.w   #$0888,D7
                bne.s   fade_all_white

                moveq   #9,D7
w1:             bsr     vsync                ; kurz warten
                dbra    D7,w1

                bsr     fadefromwhitedown

                moveq   #29,D7
w2:             bsr     vsync                ; kurz warten
                dbra    D7,w2

		bsr	fadebudgie
		rts


fadebudgie:     lea     $ffff8240.w,A0
                moveq   #15,D2
                bsr     fade_down
                bsr     vsync
                bsr     vsync
                lea     $ffff8240.w,A0
                moveq   #15,D0
check:          move.w  (A0)+,D1
                and.w   #$0777,D1
                bne.s   fadebudgie
                dbra    D0,check
		rts


                movea.l screen1(PC),A1
                move.w  #7999,D0
clear_budgie:   clr.l   (A1)+
                dbra    D0,clear_budgie

                rts



fade_down:
; faded Paletten runter
; a0=Zeiger auf Farben
; d2=Anzahl Farben

fdl0a:           move.w  (A0),D0
                and.w   #%111,D0
                beq.s   col2a
                subq.w  #1,D0
                move.w  (A0),D1
                and.w   #%1111111111111000,D1
                or.w    D0,D1
                move.w  D1,(A0)
                bra.s   coloka
col2a:           move.w  (A0),D0
                and.w   #%1110000,D0
                beq.s   col3a
                sub.w   #$10,D0
                move.w  (A0),D1
                and.w   #%1111111110001111,D1
                or.w    D0,D1
                move.w  D1,(A0)
                bra.s   coloka
col3a:           move.w  (A0),D0
                and.w   #%11100000000,D0
                beq.s   coloka
                sub.w   #$0100,D0
                move.w  (A0),D1
                and.w   #%1111100011111111,D1
                or.w    D0,D1
                move.w  D1,(A0)
coloka:          lea     2(A0),A0
                dbra    D2,fdl0a
                rts


fadefromwhitedown:
; faded von Wei� herunter auf Palette

                lea     budgie_pal+2,A0      ; Zielfarben
                lea     $ffff8242.w,A1
                moveq   #14,D0               ; 15 Farben
fadeloop:       move.w  (A0),D1              ; Zielfarbe holen
                move.w  (A1),D2              ; aktuelle Farbe
                and.w   #7,D2                ; nur Blauwert
                and.w   #7,D1
                cmp.w   D1,D2
                beq.s   blau_ok
                subq.w  #1,D2                ; Farbe -1
blau_ok:        move.w  D2,D3                ; Merken
                move.w  (A0),D1              ; Zielfarbe holen
                move.w  (A1),D2              ; aktuelle Farbe
                and.w   #%1110000,D2         ; nur Gr�nwert
                and.w   #%1110000,D1
                cmp.w   D1,D2
                beq.s   gruen_ok
                sub.w   #$10,D2              ; Farbe -1
gruen_ok:       or.w    D2,D3                ; Merken
                move.w  (A0)+,D1             ; Zielfarbe holen
                move.w  (A1),D2              ; aktuelle Farbe
                and.w   #%11100000000,D2     ; nur Rotwert
                and.w   #%11100000000,D1
                cmp.w   D1,D2
                beq.s   rot_ok
                sub.w   #$0100,D2            ; Farbe -1
rot_ok:         or.w    D2,D3
                move.w  D3,(A1)+             ; und abspeichern
                dbra    D0,fadeloop
                bsr     vsync
                bsr     vsync
                bsr     vsync
                bsr     vsync
                lea     $ffff8242.w,A1
                lea     budgie_pal+2,A0
                moveq   #14,D0               ; 15 Farben
comparecols:    move.w  (A1)+,D1
                and.w   #$0777,D1
                cmp.w   (A0)+,D1
                bne.s   fadefromwhitedown
                dbra    D0,comparecols
                rts



gameovererzeug: cmpi.l  #$136d7c22,cheatmode
                bne.s   nixxx
                move.w  #-1,endeflag
nixxx:          rts


button:         lea     pressbuttontext,A0
                moveq   #20,D0
                moveq   #0,D1
                move.w  #180,D2
                movea.l screen1(PC),A1
                bsr     textaus2

                clr.w   mousek
waitforbutt:    move.b  mousek,D0
                and.b   #3,D0
                beq.s   waitforbutt
                rts

gameover:
; Spiel zuende -> Time vorbei

                move.l  #vblpause,$70.w
                bsr     initpalpointers
                bsr     fadeup2
                lea     hilfspalette1,A0
                moveq   #15,D0
fillpalweiss2:  move.w  #$0777,(A0)+
                dbra    D0,fillpalweiss2
                move.l  #vblgame2,$70.w
                bsr     vsync

                bsr     exitpalpointers

gameovereins:   movea.l screen1(PC),A0
                bsr     cls

                lea     gameovermess,A0
                moveq   #40,D0
                moveq   #6,D1
                move.w  #2,D2
                movea.l screen1(PC),A1
                bsr     textaus

                cmpi.w  #-3,endeflag
                beq.s   gamesolved

                cmpi.w  #-2,endeflag         ; war checkmated?
                bne.s   nixendcheckmated

                lea     checkmatedmess,A0
                moveq   #40,D0
                moveq   #5,D1
                move.w  #22,D2
                movea.l screen1(PC),A1
                bsr     textaus
                bra.s   nixendtimeout
nixendcheckmated:
                lea     timeoutmess,A0
                moveq   #40,D0
                moveq   #6,D1
                move.w  #22,D2
                movea.l screen1(PC),A1
                bsr     textaus
                bra.s   nixendtimeout
gamesolved:
                lea     gamesolvedmess,A0
                moveq   #40,D0
                moveq   #5,D1
                move.w  #22,D2
                movea.l screen1(PC),A1
                bsr     textaus

nixendtimeout:


                moveq   #0,D0
                move.w  score,D0             ; schauen ob Highscore gemacht
                lea     highscores,A0
                moveq   #0,D1                ; 10 Pl�tze durchschauen
hiscoreschauen: moveq   #0,D2
                move.w  (A0),D2
                cmp.l   D2,D0                ; Score gr��er?
                bgt.s   highscoregemacht
                lea     12(A0),A0            ; n�chster Platz
                addq.w  #1,D1
                cmp.w   #10,D1
                bne.s   hiscoreschauen
                bra     nixhighscore
highscoregemacht:move.w #-1,highscoremade    ; Highscores saven am Ende
                move.w  D1,highscoreplatz
                lea     highscores+(8*12),A1
                move.w  #8,D0                ; 9 Pl�tze maximal kopieren
                sub.w   D1,D0
                bmi     nixcopyhighscore
hiscoredowncopy:move.l  (A1),12(A1)          ; einen Platz nach unten schieben
                move.l  4(A1),16(A1)
                move.l  8(A1),20(A1)
                lea     -12(A1),A1
                dbra    D0,hiscoredowncopy   ; in a0=Platzpointer jetzt
nixcopyhighscore:move.w score,(A0)+
                move.l  A0,-(A7)
                move.w  D1,-(A7)
                lea     madehighscoretext,A0
                movea.l screen1(PC),A1
                moveq   #40,D0
                moveq   #3,D1
                move.w  #60,D2
                bsr     textaus
                lea     onplacetext,A0
                movea.l screen1(PC),A1
                moveq   #40,D0
                moveq   #0,D1
                move.w  #90,D2
                bsr     textaus
                move.w  highscoreplatz,D0
                addq.w  #1,D0
                bsr     hexdez
                lea     hexdezbuff+4,A0
                moveq   #2,D0
                bsr     nullfix
                moveq   #17,D1
                move.w  #90,D2
                movea.l screen1(PC),A1
                bsr     textaus
                lea     enternametext,A0
                movea.l screen1(PC),A1
                moveq   #40,D0
                moveq   #0,D1
                move.w  #140,D2
                bsr     textaus
                bsr     fadedown2
                bsr     eingabe
                move.w  (A7)+,D0
                movea.l (A7)+,A0             ; Namenspos. im Highscore
                lea     namebuff,A1
                tst.b   (A1)                 ; nichts eingegeben
                bne.s   nixcopydefname
                lea     defaultname,A1
nixcopydefname: moveq   #9,D0                ; 10 Zeichen
copynameintab:  move.b  (A1)+,(A0)+
                dbra    D0,copynameintab

                bsr     fadedown3

                movea.l screen1(PC),A0
                bsr     cls

                bsr     drawhighscores
                bsr     fadeup3

                bra.s   warten

nixhighscore:   bsr     fadedown2

warten:         clr.w   mousek
                moveq   #0,D0
waitmoo:        move.b  mousek,D0
                and.w   #3,D0
                beq.s   waitmoo

endgameover:    bsr     fadedown3

                movea.l screen1(PC),A0
                bsr     cls

                rts                          ; zum Menue zur�ck

highscoreout:   movea.l screen1(PC),A0
                bsr     cls
                bsr     drawhighscores
                bsr     waitmouse2
                rts


drawhighscores: lea     highscores,A6
                moveq   #1,D7                ; 10 Pl�tze
                moveq   #5,D6                ; Y-Z�hler
hiscoreloop:    move.w  D7,D0
                bsr     hexdez
                lea     hexdezbuff+4,A0
                moveq   #2,D0
                moveq   #0,D1
                move.w  D6,D2
                movea.l screen1(PC),A1       ; Nummer ausgeben
                bsr     textaus2
                lea     2(A6),A0             ; Name
                moveq   #10,D0               ; max. 10 Zeichen
                moveq   #3,D1
                move.w  D6,D2
                movea.l screen1(PC),A1
                bsr     textaus2
                move.w  (A6),D0
                bsr     hexdez
                lea     hexdezbuff+1,A0
                moveq   #5,D0
                bsr     nullfix
                moveq   #15,D1
                move.w  D6,D2
                movea.l screen1(PC),A1
                bsr     textaus2             ; Score ausgeben
                lea     12(A6),A6
                add.w   #18,D6
                addq.w  #1,D7
                cmp.w   #11,D7
                bne.s   hiscoreloop
                rts




outputscore:
                movea.l screen1(PC),A1
                lea     70*160+13*8(A1),A1
                bsr     cleartext
                move.w  score,D0
                bsr     hexdez
                lea     hexdezbuff+1,A0
                moveq   #5,D0
                bsr     nullfix
                movea.l screen1(PC),A1
                moveq   #13,D1
                moveq   #70,D2
                bsr     textaus2
                rts

outputtime:
                movea.l screen1(PC),A1
                lea     90*160+13*8(A1),A1
                bsr     cleartext

                move.w  time,D0
                bsr     hexdez
                lea     hexdezbuff+3,A0
                moveq   #3,D0
                bsr     nullfix
                movea.l screen1(PC),A1
                moveq   #13,D1
                move.w  #90,D2
                bsr     textaus2
                rts

outputhelpbonus:
                movea.l screen1(PC),A1
                lea     110*160+13*8(A1),A1
                bsr     cleartext
                move.w  helpbonus,D0
                bsr     hexdez
                lea     hexdezbuff+3,A0
                moveq   #3,D0
                bsr     nullfix
                moveq   #13,D1
                move.w  #110,D2
                movea.l screen1(PC),A1
                bsr     textaus2
                rts

cleartext:      moveq   #14,D0               ; 15 Scanlines
cleartextloop:  clr.l   (A1)+
                clr.l   (A1)+
                clr.l   (A1)+
                clr.l   (A1)+
                clr.l   (A1)+
                clr.l   (A1)+
                clr.l   (A1)+
                clr.l   (A1)+
                clr.l   (A1)+
                clr.l   (A1)+
                lea     120(A1),A1
                dbra    D0,cleartextloop
                rts

oneplayermouse:
; diese Routine ist f�r 1 Spieler mit Maus und Tastaturhilfe
                bsr     umrechen             ; Maus.Koord umrechnen
                moveq   #0,D0
                move.b  keybuffer,D0
                moveq   #0,D1
                lea     keytab(PC),A0        ; nur Sonderfunktionen
testkey:        tst.b   (A0)                 ; pr�fen ob erlaubt
                bmi.s   nokeyfound
                cmp.b   (A0)+,D0
                beq.s   keyfound
                addq.w  #4,D1
                bra.s   testkey
nokeyfound:     move.b  mousek,D0            ; Maustaste
                btst    #1,D0                ; linke Taste
                bne     selekttile
                btst    #0,D0                ; rechter Knopf
                bne     deselekttile
                rts

keyfound:       lea     keyroutinen(PC),A0   ; je nach Taste
                movea.l 0(A0,D1.w),A0        ; Routine anspringen
                jsr     (A0)
                rts

initscroller:   move.l  #scrolltext,textpos
                move.l  #fontbuff,mempos
                clr.w   zeichen
                rts

;------------------------------ Instructions -------------------------

instructions:
                lea     instrtext1,A6
                bsr     outputinstructions2

                bsr     waitmouse

                lea     instrtext2,A6
                bsr     outputinstructions2

                bsr     waitmouse


                rts

waitmouse2:     bsr     fadeup3
                bra.s   waitmm
waitmouse:      bsr     fadeup4
waitmm:         clr.b   mousek
waitmousek:     moveq   #0,D0
                move.b  mousek,D0
                and.w   #3,D0
                beq.s   waitmousek
                bsr     fadedown3
                rts


loadhighscores:
		clr.w	-(A7)
		pea	filename
		move.w	#$3d,-(a7)
		trap	#1
		addq.l	#8,a7
		tst.w	d0
		bmi.s	error

		move.w	d0,d7

		pea	highscores
		move.l	#512,-(a7)
		move.w	d0,-(a7)
		move.w	#$3f,-(a7)
		trap	#1
		lea	12(a7),a7
				
		cmp.l	#512,d0
		bne.s	error
		
		move.w	d0,-(A7)
		move.w	#$3e,-(a7)
		trap	#1
		addq.l	#4,a7				

		moveq	#0,d0
                rts

error:		lea	highscores2,a0
		lea	highscores,a1
		move.w	#512-2,d0
copyscores:	move.b	(a0)+,(A1)+
		dbra	d0,copyscores
		move.w	#-1,highscoremade
		rts



writehighscores:
		clr.w	-(A7)
		pea	filename
		move.w	#$3c,-(a7)
		trap	#1
		addq.l	#8,a7
		tst.w	d0
		bmi.s	error2

		move.w	d0,d7

		pea	highscores
		move.l	#512,-(a7)
		move.w	d0,-(a7)
		move.w	#$40,-(a7)
		trap	#1
		lea	12(a7),a7
				
		cmp.l	#512,d0
		bne.s	error2
		
		move.w	d0,-(A7)
		move.w	#$3e,-(a7)
		trap	#1
		addq.l	#4,a7				

		moveq	#0,d0
                rts
error2:		moveq	#-1,d0
		rts



outputinstructions:
; gibt die Instructions zentriert auf dem Screen aus
; a6=pointer auf Text

                movea.l screen1(PC),A0
                bsr     cls

                moveq   #0,D2                ; Y-Counter

instroutloop:   tst.b   (A6)
                bmi.s   endoutput            ; -1, dann Ende Ausgabe

                moveq   #0,D3
                movea.l A6,A0
counttext:      tst.b   (A0)+
                beq.s   textendefound
                addq.w  #1,D3                ; L�nge erh�hen
                bra.s   counttext
textendefound:  movea.l A0,A5                ; Merken!
                moveq   #20,D1
                sub.w   D3,D1
                lsr.w   #1,D1
                movea.l A6,A0
                movea.l screen1(PC),A1
                moveq   #40,D0
                bsr     textaus2
                add.w   #16,D2               ; Y erh�hen
                movea.l A5,A6
                bra.s   instroutloop


outputinstructions2:
; gibt die Instructions zentriert auf dem Screen aus (mit 8er Font)
; a6=pointer auf Text

                movea.l screen1(PC),A0
                bsr     cls

                moveq   #0,D2                ; Y-Counter

instroutloop2:  tst.b   (A6)
                bmi.s   endoutput            ; -1, dann Ende Ausgabe

                moveq   #0,D3
                movea.l A6,A0
counttext2:     tst.b   (A0)+
                beq.s   textendefound2
                addq.w  #1,D3                ; L�nge erh�hen
                bra.s   counttext2
textendefound2: movea.l A0,A5                ; Merken!
                moveq   #40,D1
                sub.w   D3,D1
                lsr.w   #1,D1
                movea.l A6,A0
                movea.l screen1(PC),A1
                moveq   #80,D0
                bsr     textaus3
                add.w   #9,D2                ; Y erh�hen
                movea.l A5,A6
                bra.s   instroutloop2


endoutput:      rts



scroller:
; Laufschrift am unteren Rand

                subq.w  #2,zeichen           ; um 2 Zeichen scrollen
                bpl.s   do_it                ; alles gescrollt?
                move.w  #14,zeichen
                movea.l textpos,A0
                tst.b   (A0)
                bne.s   gweiter              ; noch nicht Ende von Text
                move.l  #scrolltext,textpos
                movea.l textpos,A0
gweiter:        moveq   #0,D0
                move.b  (A0),D0              ; Zeichen holen
                add.w   D0,D0
                lea     fonttabelle,A6
                move.w  0(A6,D0.w),D0
                lea     fontbuff,A6
                adda.w  D0,A6
                lea     2(A6),A6             ; Maske �berspringen
                move.l  A6,mempos
                addq.l  #1,textpos


do_it:          moveq   #2,D7                ; 3 Planes
                movea.l mempos,A4
                movea.l screen1(PC),A3
                lea     184*160+152(A3),A3
planescroll_loop:
                movea.l A4,A2
                movea.l A3,A0
                move.w  zeichen,D4           ; Anzahl wieviel gescrollt ist
                moveq   #14,D5               ; Anzahl der Scrollzeilen-1
scrollloop:     moveq   #0,D0
                move.w  (A2),D0              ; 4 mal 16 Pixel von Zeichen
                lsr.w   D4,D0
                and.w   #3,D0
                REPT 20
                moveq   #0,D1
                move.w  (A0),D1              ; vom Quellbildschirm
                lsl.l   #2,D1                ; um 2 Bits nach links schieben
                or.w    D0,D1                ; alten Rest einodern
                move.w  D1,(A0)              ; abspeichern auf Zielbildschirm
                swap    D1                   ; Hiword <-> Lowword
                move.w  D1,D0                ; Herausgeschobenes merken
                lea     -8(A0),A0
                ENDR

                lea     320(A0),A0           ; auf Bitplane1 1 Zeile tiefer
                lea     10(A2),A2            ; im Charscreen 1 Zeile tiefer

                dbra    D5,scrollloop
                lea     2(A3),A3
                lea     2(A4),A4
                dbra    D7,planescroll_loop
                rts





ende:
; Spiel ganz verlassen

                bsr     fadedown3
                move.w  #1,scrollready
                movem.l leerfeld,D0-D7
                movem.l D0-D7,hilfspalette1
                move.l  #vblquit,$70.w
                bsr     vsync
                moveq   #0,D0
                jsr     music                ; Musik abschalten

                bsr     hbl_off

                movem.l oldpal,D0-D7
                movem.l D0-D7,$ffff8240.w    ; alte Palette

                move.l  oldscreen,D0
                bsr     setscreen

                bsr     vsync
		MOVE.W oldres,-(SP)
		MOVE.W #$58,-(SP)
		TRAP #14
		ADDQ.L #4,SP


                movea.l oldstack,A7

		bsr	writehighscores
                rts


no_new_move:    rts


sendkeyboard:   lea     $fffffc00.w,A0
waitkeyready:   btst    #1,(A0)
                beq.s   waitkeyready
                move.b  D0,2(A0)
                rts


cheatlevel:     cmpi.l  #$136d7c22,cheatmode
                bne.s   nixcheatlevel
                move.w  #1,endeflag          ; Level geschafft (mit Beschi�)
nixcheatlevel:  rts

musiconoff:     eori.w  #1,musicflag
                moveq   #0,D0
                move.w  musicflag,D0         ; 0 oder 1
                jsr     music
                clr.b   keybuffer
                rts

addscore:       
                cmpi.l  #$136d7c22,cheatmode
                bne.s   nixaddscore
                addi.w  #100,score
                movea.l screen1(PC),A1
                bsr     draw_score
nixaddscore:    rts


umrechen:
; rechnet Koordinaten von Maus in Koord. im Feld um

                move.w  mousex,D0
                addq.w  #6,D0                ; Mittelpunkt
                lsr.w   #4,D0                ; X/16
                subq.w  #1,D0                ; -2 wegen Startfeld=16
                moveq   #0,D1
                move.w  mousey,D1
                addq.w  #6,D1                ; Mittelpunkt
                sub.w   #ystartline,D1       ; Startzeile abziehen
                divu    #20,D1               ; / H�he teilen
                move.w  D0,xpos1
                move.w  D1,ypos1
                rts

selekttile:
; diese Routine selektiert das Tile, auf dem geklickt wurde.
                tst.b   tile1selektpos       ; schon selektiert?
                bne.s   tile2selekt          ; dann 2. selekt.
                moveq   #0,D2                ; umrechnen in Pos.
                move.w  xpos1,D0
                move.w  ypos1,D1
                move.w  D1,D2
                mulu    #18,D2               ; * Breite
                add.w   D0,D2                ; + X
                lea     matchitbuff,A0
                tst.b   0(A0,D2.w)           ; dort �berhaupt Tile?
                beq.s   notileselekt
                move.w  #-1,kasten1aktiv
                movem.l D0-A6,-(A7)
                bsr     vsync
                bsr     restmouse            ; Maus restaurieren
                clr.l   rettbuff
joyrest:        movem.l (A7)+,D0-A6
                move.w  D0,tile1selektx      ; Koord. speichern
                move.w  D1,tile1selekty
                move.b  D2,tile1selektpos
                bsr     draw_kasten
                clr.w   kasten1aktiv
notileselekt:   rts

tile2selekt:    tst.b   tile1selektpos
                beq     notileselekt2
                moveq   #0,D5                ; umrechnen in Pos.
                move.w  xpos1,D0
                move.w  ypos1,D1
                move.w  D1,D5
                mulu    #18,D5               ; * Breite
                add.w   D0,D5                ; + X
                lea     matchitbuff,A0
                tst.b   0(A0,D5.w)           ; dort �berhaupt Tile?
                beq     notileselekt2

                cmp.w   tile1selektx,D0      ; = alten Koord.?
                bne.s   tile2xntile1x
                cmp.w   tile1selekty,D1
                beq     notileselekt2
tile2xntile1x:  move.w  D0,tile2selektx      ; Koord. speichern
                move.w  D1,tile2selekty
                move.b  D5,tile2selektpos
                moveq   #0,D4
                move.b  tile1selektpos,D4
                move.b  0(A0,D4.w),D2        ; Wert holen
                move.b  0(A0,D5.w),D3        ; Wert holen
                bsr     tilevergleich        ; Tausch m�glich ?
                tst.w   D7
                bne     notileselekt2        ; Nein-> Nichts

                move.w  D0,D2                ; X2
                move.w  D1,D3                ; Y2
                move.w  tile1selektx,D0      ; X1
                move.w  tile1selekty,D1      ; Y1
                movem.l D0-A6,-(A7)
                move.w  #-1,kasten1aktiv     ; Kasten 1 aus
                bsr     vsync
                bsr     restmouse
                clr.l   rettbuff
tile2selektrj:  move.w  tile2selektx,D0
                move.w  tile2selekty,D1
                bsr     draw_kasten
                movem.l (A7)+,D0-A6

helpeinsprung:
                clr.w   mousek
                bsr     such_weg             ; Verbindungslinie?
                tst.w   D0                   ; geklappt?
                bne     notawegfound

                moveq   #10,D7
waitahalf:      bsr     vsync
                dbra    D7,waitahalf

                addq.w  #1,score             ; Score erh�hen

                bsr     draw_weg

                subq.w  #1,paaranzahl
                bne.s   notallpaars
                move.w  #1,endeflag          ; alle Paare weg! = n�chster Level!
                rts
notallpaars:    clr.w   kasten1aktiv         ; Kasten an
                clr.b   tile1selektpos       ; kein Tile selekt.
                bsr     checkmatetest        ; Kucken ob noch was geht!
notileselekt2:  rts

notawegfound:   move.w  tile2selektx,D0
                move.w  tile2selekty,D1
                movea.l screen1(PC),A0       ; wieder Tiles zeichnen
                bsr     draw_tile
                clr.w   kasten1aktiv         ; Joystick an
                bra.s   notileselekt2

deselekttile:   tst.b   tile1selektpos       ; schon Tile selekt.
                beq.s   notiledeselekt


                movea.l cheatpoint,A0
                cmpa.l  #cheatmode+4,A0      ; Pos. in Cheatmode
                beq.s   nomorecheat
                move.b  tile1selektpos,(A0)+
                move.l  A0,cheatpoint
                cmpi.l  #$136d7c22,cheatmode
                bne.s   nomorecheat
                movem.w cheatpalette(PC),D0-D2
                movem.w D0-D2,palette1+26
nomorecheat:
                move.w  #-1,kasten1aktiv
                bsr     restmouse
                clr.l   rettbuff
                move.w  tile1selektx,D0
                move.w  tile1selekty,D1
                movea.l screen1(PC),A0
                bsr     draw_tile            ; Tile zeichnen
                clr.w   kasten1aktiv
                clr.b   tile1selektpos
notiledeselekt: rts


helpfunktion:   tst.w   helpcount
                beq     nomorehelp           ; kein Help mehr da?

                bsr     vsync
                bsr     restmouse
                clr.l   rettbuff
                move.w  #-1,kasten1aktiv

                moveq   #0,D4
                moveq   #0,D5
                lea     posbuff+96,A0        ; Pos.
                moveq   #0,D0                ; 95 Tiles (wegen 2Loop)
searchhelploop: move.b  -(A0),D4             ; Pos. 1
                tst.b   D4
                beq     posgleich0
                movea.l A0,A1
                move.w  #94,D1
                sub.w   D0,D1
searchhelploop2:move.b  -(A1),D5             ; Pos. 2
                tst.b   D5
                beq     pos2gleich0
                lea     matchitbuff,A2

                move.b  0(A2,D4.w),D2        ; 2 Tiles holen
                move.b  0(A2,D5.w),D3

                bsr     tilevergleich        ; m�gliche Kombination?
                tst.w   D7
                bne     pos2gleich0
                move.l  D0,-(A7)
                move.l  D1,-(A7)

                moveq   #0,D2                ; umrechnen in Koord.
                move.w  D4,D2
                divu    #18,D2
                move.w  D2,D1
                swap    D2
                move.w  D2,D0
                moveq   #0,D2
                move.w  D5,D2
                divu    #18,D2
                move.w  D2,D3
                swap    D2

                move.w  D0,tile1selektx
                move.w  D1,tile1selekty
                move.w  D2,tile2selektx
                move.w  D3,tile2selekty

                bsr     such_weg             ; Weg da?

                move.w  D0,D6
                move.l  (A7)+,D1
                move.l  (A7)+,D0
                tst.w   D6
                bne.s   pos2gleich0          ; Ja-Wegnehmen

                move.b  D4,tile1selektpos
                move.b  D5,tile2selektpos
                move.w  tile1selektx,D0
                move.w  tile1selekty,D1
                bsr     draw_kasten          ; Feld umrahmen
                move.w  tile2selektx,D0
                move.w  tile2selekty,D1
                bsr     draw_kasten          ; Feld umrahmen


                move.w  #-1,helpverbraucht
                cmpi.l  #$136d7c22,cheatmode ; Cheatmode an?
                beq.s   unlimitedhelps
                subq.w  #1,helpcount
                bra.s   limitedhelps
unlimitedhelps: move.w  #5,helpcount         ; wieder 5 Helps bei Cheatmode!
limitedhelps:   move.w  tile1selektx,D0
                move.w  tile1selekty,D1
                move.w  tile2selektx,D2
                move.w  tile2selekty,D3
                move.b  tile1selektpos,D4
                move.b  tile2selektpos,D5
                bra     helpeinsprung

pos2gleich0:    dbra    D1,searchhelploop2
posgleich0:     addq.w  #1,D0
                cmp.w   #95,D0
                bne     searchhelploop

                move.w  #-2,endeflag         ; Game over! (checkmated)

nomorehelp:     clr.w   kasten1aktiv
                rts


endgame:        move.w  #2,endeflag          ; zur�ck ins Men� springen
                rts


checkmatetest:
; �berpr�ft ob noch m�gliche Tiles da sind
                moveq   #0,D4
                moveq   #0,D5
                lea     posbuff+96,A0        ; Pos.
                moveq   #0,D0                ; 95 Tiles (wegen 2Loop)
searchhloop:    move.b  -(A0),D4             ; Pos. 1
                tst.b   D4
                beq     posgleich01
                movea.l A0,A1
                move.w  #94,D1
                sub.w   D0,D1
searchhloop2:   move.b  -(A1),D5             ; Pos. 2
                tst.b   D5
                beq     pos2gleich01
                lea     matchitbuff,A2

                move.b  0(A2,D4.w),D2        ; 2 Tiles holen
                move.b  0(A2,D5.w),D3

                bsr     tilevergleich        ; m�gliche Kombination?
                tst.w   D7
                bne     pos2gleich01
                move.l  D0,-(A7)
                move.l  D1,-(A7)

                moveq   #0,D2                ; umrechnen in Koord.
                move.w  D4,D2
                divu    #18,D2
                move.w  D2,D1
                swap    D2
                move.w  D2,D0
                moveq   #0,D2
                move.w  D5,D2
                divu    #18,D2
                move.w  D2,D3
                swap    D2

                move.w  D0,tile1selektx
                move.w  D1,tile1selekty
                move.w  D2,tile2selektx
                move.w  D3,tile2selekty

                bsr     such_weg             ; Weg da?

                move.w  D0,D6
                move.l  (A7)+,D1
                move.l  (A7)+,D0
                tst.w   D6
                bne.s   pos2gleich01         ; Ja-Wegnehmen

                rts                          ; OK! noch was da!

pos2gleich01:   dbra    D1,searchhloop2
posgleich01:    addq.w  #1,D0
                cmp.w   #95,D0
                bne     searchhloop

                move.w  #-2,endeflag         ; Game over! (checkmated)
                rts



make_leveltab:

                lea     leveltab,A6          ; komplett l�schen
                moveq   #63,D7
clrleveltab:    move.b  #-1,(A6)+
                dbra    D7,clrleveltab

                lea     leveltab,A6
                moveq   #63,D7
makelevelsloop: bsr     random
                and.w   #63,D0
                cmpi.b  #-1,0(A6,D0.w)       ; Feld dort belegt
                bne.s   makelevelsloop
                move.b  D7,0(A6,D0.w)        ; Nummer ablegen
                dbra    D7,makelevelsloop

                bsr     random
                move.w  D0,D1
                bsr     random
                mulu    D1,D0
                and.w   #63,D0
                move.w  D0,level
                rts

make_buff:      moveq   #0,D0
                move.w  level,D0
                addq.w  #1,D0
                and.w   #63,D0               ; 64 Level
                move.w  D0,level
                lea     leveltab,A0
                move.b  0(A0,D0.w),D0        ; Levelnummer holen
                mulu    #240,D0
                lea     buffers,A0
                adda.w  D0,A0
                lea     matchitbuff,A1
                move.w  #143,D0
copybuff:       move.b  (A0)+,(A1)+
                dbra    D0,copybuff
                lea     posbuff,A1
                moveq   #95,D0
copypbuff:      move.b  (A0)+,(A1)+
                dbra    D0,copypbuff
                rts


random:         movem.l D1-D7,-(A7)
                move.l  $0466.w,D7           ; VBL-Count
                not.l   D7
                add.l   oldrandom(PC),D7
                move.l  D7,D6
                move.l  #127773,D2
                bsr.s   div
                move.l  D4,D5
                muls    #-2836,D5
                mulu    #42591,D4
                move.l  D4,D6
                add.l   D4,D4
                add.l   D6,D4
                sub.l   D4,D7
                moveq   #4,D4
ran1:           move.l  D7,D6
                lsl.l   #3,D7
                sub.l   D6,D7
                dbra    D4,ran1
                add.l   D5,D7
                bpl.s   exran1
                add.l   #2147483647,D7
exran1:         move.l  D7,D0
                move.l  D0,oldrandom
                movem.l (A7)+,D1-D7
                rts
oldrandom:      DC.L 0
div:            add.l   D6,D6
                moveq   #0,D4
                moveq   #14,D3
                move.w  D6,D5
                swap    D6
                and.l   #$ffff,D6
div1:           add.w   D4,D4
                add.w   D5,D5
                addx.l  D6,D6
                cmp.l   D2,D6
                bmi.s   div2
                sub.l   D2,D6
                addq.w  #1,D4
div2:           dbra    D3,div1
                rts

tilevergleich:
; vergleicht die zwei Tiles und gibt in d7 zur�ck ob es geht.
; (Blumen-Blumen, Jahreszeiten-Jahreszeiten)
; d2,d3=Werte
; d7=0 -> geht, d7<>0 geht nicht

                clr.w   blumjzverz2
                cmp.b   D2,D3
                bne.s   nichtgleich          ; ungleich!
                cmp.b   #35,D2
                blt.s   noverzan
                cmp.b   #42,D2
                bgt.s   noverzan
                move.w  #4,blumjzverz2       ; Verz. einschalten
noverzan:       moveq   #0,D7
                rts
nichtgleich:    cmp.b   #35,D2               ; Jahreszeit?
                blt.s   tileungleich         ; < -> ungleich
                cmp.b   #38,D2
                bgt.s   keinejahresz         ; keine Jahreszeit
                cmp.b   #35,D3               ; anderes Tile?
                blt.s   tileungleich
                cmp.b   #38,D3
                bgt.s   tileungleich         ; geht nicht!
                moveq   #0,D7                ; war Jahreszeit!
                move.w  #4,blumjzverz2
                rts
keinejahresz:   cmp.b   #42,D2               ; gr��er als Blume?
                bgt.s   tileungleich         ; ist verschieden!
                cmp.b   #42,D3
                bgt.s   tileungleich
                cmp.b   #39,D3
                blt.s   tileungleich
                moveq   #0,D7
                move.w  #4,blumjzverz2
                rts
tileungleich:   moveq   #-1,D7               ; geht nicht!
                rts

draw_tile2:
; diese Routine zeichnet ein Steinchen an Pos. X und Y
; diese Koordinaten bezeichnen das Bytefeld "Matchitbuff".
; diese Routine holt auch den entsprechenden Wert aus der
; Tabelle.
; mit Schatten!
;
; �bergabe:
; ---------
; d0 = x
; d1 = y
; a0 = Screenadresse

                movem.l D0-A2,-(A7)
                moveq   #0,D2
                moveq   #0,D3
                move.w  D1,D2                ; Y nach d2
                mulu    #18,D2               ; mal Breite
                add.w   D0,D2                ; + X
                lea     matchitbuff,A1       ; Spielfeld
                move.b  0(A1,D2.w),D3        ; Wert holen
                tst.b   D3
                beq     nixfrei              ; Leerfeld!
                move.w  D2,-(A7)
                subq.w  #1,D3                ; -1 wegen Stein 1=0
                lea     tilesgrafik(PC),A1   ; dort ist die Grafik
                mulu    #20*8,D3             ; so gro� ist ein Tile
                adda.l  D3,A1                ; auf Adresse addieren
                lsl.w   #3,D0                ; X mal 8
                addq.w  #8,D0                ; X + 8 wegen Startfeld
                and.l   #$ffff,D1            ; Y nur Lowword
                mulu    #20*160,D1           ; mal einer "Zeile"
                add.w   #ystartline*160,D1   ; ab dort beginnen Tiles
                add.w   D0,D1
                adda.l  D1,A0                ; auf Screen addieren
                move.l  A0,-(A7)
                movem.l (A1)+,D0-D7          ; 8 Longs (=4 Zeilen)
                move.l  D0,(A0)              ; auf Screen speichern
                move.l  D1,4(A0)
                move.l  D2,160(A0)
                move.l  D3,164(A0)
                move.l  D4,320(A0)
                move.l  D5,324(A0)
                move.l  D6,480(A0)
                move.l  D7,484(A0)
                lea     640(A0),A0           ; 4 Zeilen tiefer
                movem.l (A1)+,D0-D7          ; 8 Longs (=4 Zeilen)
                move.l  D0,(A0)              ; auf Screen speichern
                move.l  D1,4(A0)
                move.l  D2,160(A0)
                move.l  D3,164(A0)
                move.l  D4,320(A0)
                move.l  D5,324(A0)
                move.l  D6,480(A0)
                move.l  D7,484(A0)
                lea     640(A0),A0           ; 4 Zeilen tiefer
                movem.l (A1)+,D0-D7          ; 8 Longs (=4 Zeilen)
                move.l  D0,(A0)              ; auf Screen speichern
                move.l  D1,4(A0)
                move.l  D2,160(A0)
                move.l  D3,164(A0)
                move.l  D4,320(A0)
                move.l  D5,324(A0)
                move.l  D6,480(A0)
                move.l  D7,484(A0)
                lea     640(A0),A0           ; 4 Zeilen tiefer
                movem.l (A1)+,D0-D7          ; 8 Longs (=4 Zeilen)
                move.l  D0,(A0)              ; auf Screen speichern
                move.l  D1,4(A0)
                move.l  D2,160(A0)
                move.l  D3,164(A0)
                move.l  D4,320(A0)
                move.l  D5,324(A0)
                move.l  D6,480(A0)
                move.l  D7,484(A0)
                lea     640(A0),A0           ; 4 Zeilen tiefer
                movem.l (A1)+,D0-D7          ; 8 Longs (=4 Zeilen)
                move.l  D0,(A0)              ; auf Screen speichern
                move.l  D1,4(A0)
                move.l  D2,160(A0)
                move.l  D3,164(A0)
                move.l  D4,320(A0)
                move.l  D5,324(A0)
                move.l  D6,480(A0)
                move.l  D7,484(A0)

                movea.l (A7)+,A1
                move.w  (A7)+,D2
                lea     matchitbuff,A0
                tst.b   1(A0,D2.w)           ; Tile rechts frei?
                beq.s   rechtsfrei           ; Ja->Schatten
                tst.b   18(A0,D2.w)          ; Tile unten frei?
                bne.s   nixfrei
rechtsfrei:     lea     schatten(PC),A0
                lea     schattenmaske(PC),A2
                moveq   #$15,D0              ; 22 Zeilen
drawshadow:     movem.l (A0)+,D1-D4
                move.w  (A2)+,D5             ; Maske
                not.w   D5
                and.w   D5,(A1)
                and.w   D5,2(A1)
                and.w   D5,4(A1)
                and.w   D5,6(A1)
                move.w  (A2)+,D5
                not.w   D5
                and.w   D5,8(A1)
                and.w   D5,10(A1)
                and.w   D5,12(A1)
                and.w   D5,14(A1)
                or.l    D1,(A1)+
                or.l    D2,(A1)+
                or.l    D3,(A1)+
                or.l    D4,(A1)+
                lea     144(A1),A1
                dbra    D0,drawshadow
nixfrei:        movem.l (A7)+,D0-A2
                rts


hexdez:
; in d0=Wort
; wandelt in Dezimal um
; Ergebnis steht rechtsb�ndig in hexdezbuff

                move.l  A0,-(A7)

                move.l  #'0000',hexdezbuff   ; mit Null vorinitialisieren
                move.w  #'00',hexdezbuff+4

                lea     hexdezbuff+6,A0
makedezloop:    moveq   #0,D1
                move.w  D0,D1
                divu    #10,D1
                swap    D1
                add.b   #'0',D1
                move.b  D1,-(A0)
                swap    D1
                move.w  D1,D0
                cmp.w   #10,D0
                bge.s   makedezloop
                add.b   #'0',D0
                move.b  D0,-(A0)
                movea.l (A7)+,A0
                rts

nullfix:
; a0=Textpointer (erste Zahl)
; d0=L�nge (maximal)
; R�ckgabe: a0=neuer Pointer, d0=neue L�nge

                cmpi.b  #'0',(A0)            ; f�hrende Nullen raushauen
                bne.s   gibtwertraus
                lea     1(A0),A0
                subq.w  #1,D0                ; Anzahl -1
                bne.s   nullfix
                moveq   #1,D0                ; wenn Zeit=0 dann nur 1 Null
                lea     hexdezbuff+5,A0
gibtwertraus:   rts


draw_time:
; zeichnet die Zeit (3stellig) auf Screen1

                movem.w hexdezbuff,D0-D2     ; 3 Worte
                movem.w D0-D2,hexdezbuff2    ; retten

                moveq   #0,D0
                move.w  time,D0
                bsr     hexdez               ; Zeit in Hex umwandeln

                lea     obenplatte+80,A0     ; Retten
                movea.l screen1(PC),A1
                lea     80(A1),A1
                moveq   #15,D1               ; 16 Scanlines
restoreoben:    movem.l (A0),D2-D7           ; 6 Longs
                movem.l D2-D7,(A1)
                lea     160(A0),A0
                lea     160(A1),A1
                dbra    D1,restoreoben

                lea     hexdezbuff+3,A0      ; ab dort sehen
                moveq   #3,D0                ; 3 Zeichen maximal
                bsr     nullfix              ; f�hrende Nullen weg

                movea.l screen1(PC),A1
                moveq   #10,D1
                moveq   #1,D2
                bsr     textaus

                movem.w hexdezbuff2,D0-D2    ; 3 Worte
                movem.w D0-D2,hexdezbuff     ; zur�ck retten

                rts


draw_score:
; zeichnet den Score (4stellig) auf Screen1
; a1=Screenpointer

                moveq   #0,D0
                move.w  score,D0
                bsr     hexdez               ; Zeit in Hex umwandeln

                lea     obenplatte+24,A0     ; Retten
                movea.l A1,A3                ; Screen
                lea     24(A3),A3
                moveq   #15,D1               ; 16 Scanlines
restoreoben2:   movem.l (A0),D2-D7/A2/A4-A6  ; 10 Longs
                movem.l D2-D7/A2/A4-A6,(A3)
                lea     160(A0),A0
                lea     160(A3),A3
                dbra    D1,restoreoben2

                lea     hexdezbuff+1,A0      ; ab dort sehen
                moveq   #5,D0                ; 3 Zeichen maximal
                bsr     nullfix              ; f�hrende Nullen weg

                moveq   #3,D1
                moveq   #1,D2
                bsr     textaus
                rts





draw_tile:
; diese Routine zeichnet ein Steinchen an Pos. X und Y
; diese Koordinaten bezeichnen das Bytefeld "Matchitbuff".
; diese Routine holt auch den entsprechenden Wert aus der
; Tabelle.
; ohne Schatten!
;
; �bergabe:
; ---------
; d0 = x
; d1 = y
; a0 = Screenadresse

                movem.l D0-A2,-(A7)
                moveq   #0,D2
                moveq   #0,D3
                move.w  D1,D2                ; Y nach d2
                mulu    #18,D2               ; mal Breite
                add.w   D0,D2                ; + X
                lea     matchitbuff,A1       ; Spielfeld
                move.b  0(A1,D2.w),D3        ; Wert holen
                tst.b   D3
                beq     nixfrei2             ; Leerfeld!
                subq.w  #1,D3                ; -1 wegen Stein 1=0
                lea     tilesgrafik(PC),A1   ; dort ist die Grafik
                mulu    #20*8,D3             ; so gro� ist ein Tile
                adda.l  D3,A1                ; auf Adresse addieren
                lsl.w   #3,D0                ; X mal 8
                addq.w  #8,D0                ; X + 8 wegen Startfeld
                and.l   #$ffff,D1            ; Y nur Lowword
                mulu    #20*160,D1           ; mal einer "Zeile"
                add.w   #ystartline*160,D1   ; ab dort beginnen Tiles
                add.w   D0,D1
                adda.l  D1,A0                ; auf Screen addieren
                movem.l (A1)+,D0-D7          ; 8 Longs (=4 Zeilen)
                move.l  D0,(A0)              ; auf Screen speichern
                move.l  D1,4(A0)
                move.l  D2,160(A0)
                move.l  D3,164(A0)
                move.l  D4,320(A0)
                move.l  D5,324(A0)
                move.l  D6,480(A0)
                move.l  D7,484(A0)
                lea     640(A0),A0           ; 4 Zeilen tiefer
                movem.l (A1)+,D0-D7          ; 8 Longs (=4 Zeilen)
                move.l  D0,(A0)              ; auf Screen speichern
                move.l  D1,4(A0)
                move.l  D2,160(A0)
                move.l  D3,164(A0)
                move.l  D4,320(A0)
                move.l  D5,324(A0)
                move.l  D6,480(A0)
                move.l  D7,484(A0)
                lea     640(A0),A0           ; 4 Zeilen tiefer
                movem.l (A1)+,D0-D7          ; 8 Longs (=4 Zeilen)
                move.l  D0,(A0)              ; auf Screen speichern
                move.l  D1,4(A0)
                move.l  D2,160(A0)
                move.l  D3,164(A0)
                move.l  D4,320(A0)
                move.l  D5,324(A0)
                move.l  D6,480(A0)
                move.l  D7,484(A0)
                lea     640(A0),A0           ; 4 Zeilen tiefer
                movem.l (A1)+,D0-D7          ; 8 Longs (=4 Zeilen)
                move.l  D0,(A0)              ; auf Screen speichern
                move.l  D1,4(A0)
                move.l  D2,160(A0)
                move.l  D3,164(A0)
                move.l  D4,320(A0)
                move.l  D5,324(A0)
                move.l  D6,480(A0)
                move.l  D7,484(A0)
                lea     640(A0),A0           ; 4 Zeilen tiefer
                movem.l (A1)+,D0-D7          ; 8 Longs (=4 Zeilen)
                move.l  D0,(A0)              ; auf Screen speichern
                move.l  D1,4(A0)
                move.l  D2,160(A0)
                move.l  D3,164(A0)
                move.l  D4,320(A0)
                move.l  D5,324(A0)
                move.l  D6,480(A0)
                move.l  D7,484(A0)
nixfrei2:       movem.l (A7)+,D0-A2
                rts


clear_tile:
; diese Routine l�scht zwei Steinchen an Pos. X und Y
; mehrere M�glichkeiten, das Tile zu verschwinden lassen
; diese Koordinaten bezeichnen das Bytefeld "Matchitbuff".
; kopiert Eisplatte an die Stelle
; l�scht auch in Tabelle
;
; �bergabe:
; ---------
; d0 = x1
; d1 = y1
; d2 = x2
; d3 = y2
; a0 = Screenadresse

                and.l   #$ffff,D0
                and.l   #$ffff,D1
                and.l   #$ffff,D2
                and.l   #$ffff,D3
                movea.l A0,A3
                bsr.s   makeparasforclear
                movem.l A0-A2,regs1          ; Register f�r Stein 1
                move.l  D2,D0
                move.l  D3,D1
                movea.l A3,A0                ; Screen
                bsr.s   makeparasforclear    ; Regsiter f�r Stein 2
                movem.l A0-A2,regs2

                lea     removeani1(PC),A6
                moveq   #14,D7               ; 15 Animationsstufen
clearloop:      movea.l A6,A3
                movem.l regs1,A0-A2
                bsr     clearrout1
                movea.l A6,A3
                movem.l regs2,A0-A2
                bsr.s   clearrout1
                movea.l A3,A6
                bsr     vsync
                dbra    D7,clearloop
                rts


makeparasforclear:
; erstellt Register f�r Clear-Routine
                moveq   #0,D4
                move.w  D1,D4                ; Y nach d2
                mulu    #18,D4               ; mal Breite
                add.w   D0,D4                ; + X
                lea     matchitbuff,A1
                moveq   #0,D5
                move.b  0(A1,D4.w),D5        ; Wert holen
                subq.b  #1,D5
                clr.b   0(A1,D4.w)           ; Tile l�schen
                move.w  #95,D6               ; 96 Tiles
                lea     posbuff,A1
searchinposbuff:cmp.b   (A1),D4              ; in Posbuff l�schen
                bne.s   notthereinpos
                clr.b   (A1)                 ; l�schen
                bra.s   readyinpos
notthereinpos:  lea     1(A1),A1
                dbra    D6,searchinposbuff
readyinpos:     lea     eisplatte,A1         ; Eisplatte holen
                lsl.w   #3,D0                ; X mal 8
                addq.w  #8,D0                ; X + 8 wegen Startfeld
                adda.l  D0,A1                ; auf Eisplatte addieren
                and.l   #$ffff,D1            ; Y nur Lowword
                mulu    #20*160,D1           ; mal einer "Zeile"
                adda.l  D1,A1                ; auf Eisplatte
                adda.l  #(eisrand-1)*160,A1  ; ab dort Steinchen

                add.l   #ystartline*160,D1   ; ab dort beginnen Tiles
                add.l   D0,D1
                adda.l  D1,A0                ; auf Screen addieren
                lea     tilesgrafik(PC),A2
                mulu    #160,D5              ; Nummer des Tiles*160
                adda.l  D5,A2
                rts


clearrout1:
; erste L�schroutine
; in a0=Screenadresse
; in a1=Eisplatte
;    a2=altes Tile

                moveq   #19,D0               ; 20 Zeilen
                movea.l A0,A4                ; Screen
                movea.l A1,A5                ; Eisplatte
clearr1l1:      move.l  (A5)+,(A4)+          ; Eisplatte kopieren
                move.l  (A5)+,(A4)+
                lea     152(A5),A5
                lea     152(A4),A4
                dbra    D0,clearr1l1

                movea.l A0,A4                ; Screen
                movea.l A2,A5                ; Tile
                moveq   #19,D0               ; 20 Zeilen
clearr1l2:      move.w  (A3)+,D1             ; Maske holen
                move.w  (A5)+,D2
                and.w   D1,D2
                move.w  (A5)+,D3
                and.w   D1,D3
                move.w  (A5)+,D4
                and.w   D1,D4
                move.w  (A5)+,D5
                and.w   D1,D5
                move.w  D2,D6                ; Maske bilden
                or.w    D3,D6
                or.w    D4,D6
                or.w    D5,D6
                not.w   D6
                and.w   D6,(A4)
                or.w    D2,(A4)+
                and.w   D6,(A4)
                or.w    D3,(A4)+
                and.w   D6,(A4)
                or.w    D4,(A4)+
                and.w   D6,(A4)
                or.w    D5,(A4)+
                lea     152(A4),A4
                dbra    D0,clearr1l2
                rts

draw_screen:
; baut Spielbildschirm auf
; mit Platte

                lea     obenplatte(PC),A0
                movea.l screen2(PC),A1
                move.w  #(16*40)-1,D0
copyobenplatte: move.l  (A0)+,(A1)+
                dbra    D0,copyobenplatte


                movea.l screen2(PC),A1
                lea     17*160(A1),A1        ; ab Zeile 16
                lea     eisplatte,A0
                move.w  #(181*40)-1,D0
copyeisplatte:  move.l  (A0)+,(A1)+
                dbra    D0,copyeisplatte

                moveq   #1,D0                ; X-Start-Pos.
dsl0:           moveq   #1,D1                ; Y-Start-Pos.
dsl1:           movea.l screen2(PC),A0
                move.l  D0,-(A7)
                move.l  D1,-(A7)
                bsr     draw_tile2
                move.l  (A7)+,D1
                move.l  (A7)+,D0
                addq.w  #1,D1                ; Y+1
                cmp.w   #7,D1
                bne.s   dsl1
                addq.w  #1,D0
                cmp.w   #17,D0
                bne.s   dsl0


                movea.l screen2(PC),A1
                bsr     draw_score

                movea.l screen2(PC),A1
                bsr     draw_helps

                rts



draw_kasten:
; kn�pft Kasten ein (bei Helpfunktion)
; d0,d1=X,Y
                movem.l D0-A1,-(A7)
                lea     kasten(PC),A0
                movea.l screen1(PC),A1
                lsl.w   #3,D0                ; X mal 8
                addq.w  #8,D0                ; X + 8 wegen Startfeld
                and.l   #$ffff,D1            ; Y nur Lowword
                mulu    #20*160,D1           ; mal einer "Zeile"
                add.w   #ystartline*160,D1   ; ab dort beginnen Tiles
                add.w   D0,D1
                adda.l  D1,A1                ; auf Screen addieren
                moveq   #19,D0
dkl0:           move.w  (A0)+,D1             ; Werte holen
                move.w  (A0)+,D2
                move.w  (A0)+,D3
                move.w  (A0)+,D4
                moveq   #0,D5                ; Maske bilden
                move.w  D1,D5
                or.w    D2,D5
                or.w    D3,D5
                or.w    D4,D5
                not.w   D5
                and.w   D5,(A1)
                or.w    D1,(A1)+
                and.w   D5,(A1)
                or.w    D2,(A1)+
                and.w   D5,(A1)
                or.w    D3,(A1)+
                and.w   D5,(A1)
                or.w    D4,(A1)+
                lea     152(A1),A1
                dbra    D0,dkl0
                movem.l (A7)+,D0-A1
                rts


new_mouse:      movem.l D0-D1/A0,-(A7)
                lea     keybuffer,A0
                move.b  (A0)+,D0
                cmp.b   #$f8,D0              ; Testen ob Mauspaket
                bcs.s   nomousepak
                cmp.b   #$fc,D0
                bcc.s   nomousepak

                move.b  D0,mousek            ; Taste

                move.b  (A0)+,D0             ; Deltax
                move.b  (A0)+,D1             ; Deltay
                ext.w   D0
                ext.w   D1
                tst.w   D0
                bne.s   nix_x_m
                tst.w   D1
                bne.s   nix_x_m
                bra.s   nix_x_m1
nix_x_m:        clr.w   mousek               ; falls Maus bewegt und Taste->nix T.
nix_x_m1:       add.w   D0,mousex
                add.w   D1,mousey
                cmpi.w  #281,mousex
                blt.s   nixxzgr
                move.w  #281,mousex
nixxzgr:        cmpi.w  #28,mousex
                bgt.s   nixxzkl
                move.w  #28,mousex
nixxzkl:        cmpi.w  #ystartline+20-6,mousey
                bgt.s   nixyzkl
                move.w  #ystartline+20-6,mousey
nixyzkl:        cmpi.w  #ystartline+140-7,mousey
                blt.s   nomousepak
                move.w  #ystartline+140-7,mousey
nomousepak:     movem.l (A7)+,D0-D1/A0
                rts

restmouse:
; Maus restaurieren
                movem.l D0-D4/A0-A1,-(A7)
                lea     rettbuff,A0
                movea.l (A0)+,A1             ; Screenwert
                cmpa.l  #0,A1
                beq.s   nichtrest            ; nicht restaur.
                moveq   #12,D0               ; 13 Zeilen
reml0:          movem.l (A0)+,D1-D4          ; 4 Longs
                movem.l D1-D4,(A1)
                lea     160(A1),A1
                dbra    D0,reml0
nichtrest:      movem.l (A7)+,D0-D4/A0-A1
                rts


putmouse:
; Maus zeichnen
                movem.l D0-A6,-(A7)
                moveq   #0,D0
                moveq   #0,D1
                move.w  mousex,D0            ; Koord. holen
                move.w  mousey,D1
                move.w  D0,D4
                ror.l   #4,D0                ; x/16
                rol.w   #3,D0                ; x*8
                movea.l screen1(PC),A1
                move.w  D1,D2
                mulu    #160,D1
                adda.w  D0,A1
                adda.w  D1,A1                ; Screenpos
                clr.w   D0
                rol.l   #4,D0                ; Rest -> Schiebwert
                movea.l mousepointer,A0      ; Grafik der Maus (13 hoch)
                lea     rettbuff,A2
                moveq   #12,D1               ; 13 Zeilen
                move.l  A1,(A2)+             ; Screen in Buff
pml0:           moveq   #0,D2                ; Shapewert 0
                movem.l (A1),D4-D7           ; in Buffer retten
                movem.l D4-D7,(A2)
                lea     16(A2),A2
                moveq   #0,D2
                move.w  (A0)+,D2             ; 1 Wort holen
                ror.l   D0,D2                ; Shiften
                moveq   #0,D3
                move.w  (A0)+,D3             ; 1 Wort holen
                ror.l   D0,D3                ; Shiften
                moveq   #0,D4
                move.w  (A0)+,D4             ; 1 Wort holen
                ror.l   D0,D4                ; Shiften
                moveq   #0,D5
                move.w  (A0)+,D5             ; 1 Wort holen
                ror.l   D0,D5                ; Shiften
                move.l  D2,D6                ; Maske bilden
                or.l    D3,D6
                or.l    D4,D6
                or.l    D5,D6
                not.l   D6
                and.w   D6,(A1)
                or.w    D2,(A1)+
                and.w   D6,(A1)
                or.w    D3,(A1)+
                and.w   D6,(A1)
                or.w    D4,(A1)+
                and.w   D6,(A1)
                or.w    D5,(A1)+
                swap    D2
                swap    D3
                swap    D4
                swap    D5
                swap    D6
                and.w   D6,(A1)
                or.w    D2,(A1)+
                and.w   D6,(A1)
                or.w    D3,(A1)+
                and.w   D6,(A1)
                or.w    D4,(A1)+
                and.w   D6,(A1)
                or.w    D5,(A1)+
                lea     144(A1),A1           ; eine Zeile tiefer
                dbra    D1,pml0
                movem.l (A7)+,D0-A6
                rts


textaus:
; gibt Text aus (kn�pft ein)
; a0=Textpointer
; a1=Screenpointer
; d0=L�nge in Bytes     h�rt aber auch bei 0 als ASCII auf
; d1=X (0-19)
; d2=Y (0-199)
                movem.l D0-D6/A0-A4,-(A7)
                subq.w  #1,D0                ; -1 wegen DBRA
                bmi.s   textausende

                mulu    #160,D2              ; y
                lsl.w   #3,D1                ; x
                adda.w  D1,A1
                adda.l  D2,A1                ; Screen aufaddieren
                lea     fonttabelle,A2
textausloop:    moveq   #0,D1
                move.b  (A0)+,D1
                beq.s   textausende          ; 0 bekommen -> Textende
                add.w   D1,D1                ; *2 wegen Worttabelle
                move.w  0(A2,D1.w),D1        ; Offset auf Font holen
                lea     fontbuff,A3
                adda.w  D1,A3                ; Offset aufaddieren
                movea.l A1,A4
                moveq   #14,D1               ; 15 Scanlines
knuepfcharloop: movem.w (A3)+,D2-D6          ; 1 Wort Maske, 4 Worte Daten
                and.w   D2,(A4)
                or.w    D3,(A4)+
                and.w   D2,(A4)
                or.w    D4,(A4)+
                and.w   D2,(A4)
                or.w    D5,(A4)+
                and.w   D2,(A4)
                or.w    D6,(A4)+
                lea     152(A4),A4           ; eine Scanline tiefer
                dbra    D1,knuepfcharloop
                lea     8(A1),A1             ; 16 Pixel weiter
                dbra    D0,textausloop
textausende:    movem.l (A7)+,D0-D6/A0-A4
                rts

textaus2:
; gibt Text aus
; a0=Textpointer
; a1=Screenpointer
; d0=L�nge in Bytes     h�rt aber auch bei 0 als ASCII auf
; d1=X (0-19)
; d2=Y (0-199)
                movem.l D0-D6/A0-A4,-(A7)
                subq.w  #1,D0                ; -1 wegen DBRA
                bmi.s   textausende2

                mulu    #160,D2              ; y
                lsl.w   #3,D1                ; x
                adda.w  D1,A1
                adda.l  D2,A1                ; Screen aufaddieren
                lea     fonttabelle,A2
textausloop2:   moveq   #0,D1
                move.b  (A0)+,D1
                beq.s   textausende2         ; 0 bekommen -> Textende
                add.w   D1,D1                ; *2 wegen Worttabelle
                move.w  0(A2,D1.w),D1        ; Offset auf Font holen
                lea     fontbuff,A3
                adda.w  D1,A3                ; Offset aufaddieren
                movea.l A1,A4
                moveq   #14,D1               ; 15 Scanlines
knuepfcharloop2:movem.w (A3)+,D2-D6          ; 1 Wort Maske, 4 Worte Daten
                movem.w D3-D6,(A4)
                lea     160(A4),A4           ; eine Scanline tiefer
                dbra    D1,knuepfcharloop2
                lea     8(A1),A1             ; 16 Pixel weiter
                dbra    D0,textausloop2
textausende2:   movem.l (A7)+,D0-D6/A0-A4
                rts


textaus3:
; gibt Text aus (8er Font)
; a0=Textpointer
; a1=Screenpointer
; d0=L�nge in Bytes     h�rt aber auch bei 0 als ASCII auf
; d1=X (0-39)
; d2=Y (0-199)
                movem.l D0-D6/A0-A4,-(A7)
                subq.w  #1,D0                ; -1 wegen DBRA
                bmi.s   textausende3

                mulu    #160,D2              ; y
                adda.l  D2,A1

                move.w  D1,D2
                moveq   #0,D2
                lsr.w   #1,D1                ; x/2 = 0-19
                lsl.w   #3,D1
                adda.w  D1,A1
                and.w   #1,D2
                beq.s   nixadd1
                addq.l  #1,A1
                moveq   #1,D2
                bra.s   textausloop3
nixadd1:        moveq   #7,D2

textausloop3:   moveq   #0,D1
                move.b  (A0)+,D1
                beq.s   textausende3         ; 0 bekommen -> Textende
                move.w  D1,D3
                lea     chars8,A2
                and.w   #31,D3
                adda.w  D3,A2
                lsr.w   #5,D1
                lsl.w   #8,D1
                adda.w  D1,A2                ; Zeichen errechnet
                move.b  (A2),(A1)
                move.b  32(A2),160(A1)
                move.b  64(A2),320(A1)
                move.b  96(A2),480(A1)
                move.b  128(A2),640(A1)
                move.b  160(A2),800(A1)
                move.b  192(A2),960(A1)
                move.b  224(A2),1120(A1)

                eori.w  #6,D2
                adda.w  D2,A1                ; 1 oder 7 Bytes weiter
                dbra    D0,textausloop3
textausende3:   movem.l (A7)+,D0-D6/A0-A4
                rts

such_weg:
; Routine, die eine Verbindungslinie von Tile 1 zu Tile 2 sucht.
; Die Verbindungslinie darf nicht mehr als 2 Knicke haben.
; Die L�sung des Problems ist iterativ und nicht rekursiv.
; (Alles in einem 20*10 gro�en Bytefeld)
;
; �bergabewerte:
; --------------
; d0=x1,d1=y1,d2=x2,d3=y2
; R�ckgabewerte:
; --------------
; d0=0          -> geklappt
; d0=-1         -> nicht geklappt
; in der Tabelle Weg ist der Weg zu finden, wobei bedeutet:
; 1=rechts, 2=links, 3=unten, 4=oben

                movem.l D1-A6,-(A7)

                lea     matchitbuff2,A0
                move.w  #(20*10)-1,D4
fillhelpbuff:   move.b  #-1,(A0)+            ; mit -1 f�llen
                dbra    D4,fillhelpbuff

                lea     matchitbuff,A0
                lea     matchitbuff2+21,A1
                moveq   #7,D4                ; 8 Zeilen
fillhelpl:      moveq   #17,D5               ; 18 Spalten
fillhelpl1:     move.b  (A0)+,(A1)+
                dbra    D5,fillhelpl1        ; Feld reinkopieren
                lea     2(A1),A1
                dbra    D4,fillhelpl


                mulu    #20,D1               ; H�he * 20
                add.w   #21,D1               ; wegen Rahmen
                add.w   D0,D1                ; + Breite
                lea     matchitbuff2,A5      ; Hilfsbuffer
                lea     0(A5,D1.w),A5        ; Pointer auf Pos.Start

                mulu    #20,D3               ; H�he * 20
                add.w   #21,D3               ; wegen Rahmen
                add.w   D2,D3                ; + Breite
                lea     matchitbuff2,A6      ; Hilfsbuffer
                lea     0(A6,D3.w),A6        ; Pointer auf Pos. Ziel

                lea     weg,A0
                lea     wege,A1

                moveq   #-1,D0               ; alte Richtung
                moveq   #-1,D1               ; Knicke wegen Startknick
                bsr.s   suchweg

                moveq   #-1,D0               ; nix gefunden
                cmpa.l  #wege,A1
                beq.s   foundnoweg
                moveq   #0,D0                ; gefunden
                lea     wege,A2
                move.l  #10000,D1            ; aktuelle L�nge
countwegloop:   cmpa.l  A1,A2
                bge.s   allesgesucht
                movea.l A2,A3                ;aktuellen Weg merken
                moveq   #0,D7
laenge:         tst.b   (A2)+
                beq.s   endweg
                addq.w  #1,D7
                bra.s   laenge
endweg:         cmp.w   D1,D7
                bge.s   countwegloop
                move.w  D7,D1
                movea.l A3,A4
                bra.s   countwegloop
allesgesucht:   lea     weg,A0
copywegeinweg:  move.b  (A4)+,(A0)+
                dbra    D1,copywegeinweg
foundnoweg:     movem.l (A7)+,D1-A6
                rts

suchweg:        movem.l D0-D1/A5,-(A7)       ; Parameter retten

                cmp.b   #2,D0
                beq.s   linksrout            ; von links kommend?
                cmp.b   #1,D0                ; wieder rechts?
                beq.s   keinknickrechts
                cmp.w   #2,D1                ; Anz. Knicke=2?
                beq.s   linksrout
                addq.w  #1,D1                ; Knicke +1
                moveq   #1,D0                ; Richt. rechts
keinknickrechts:lea     1(A5),A5             ; Pos. +1
                cmpa.l  A5,A6                ; Ziel erreicht?
                bne.s   rechtskeinz
                bsr     wegsave
                bra     nixmoeglich          ; eins zur�ck
rechtskeinz:    tst.b   (A5)                 ; Feld frei?
                bne.s   linksrout            ; dort Rand oder Tile
                move.b  D0,(A0)+             ; Weg
                bsr.s   suchweg
                lea     -1(A0),A0
linksrout:      movem.l (A7),D0-D1/A5
                cmp.b   #1,D0
                beq.s   untenrout            ; von rechts kommend?
                cmp.b   #2,D0                ; wieder links?
                beq.s   keinknicklinks
                cmp.w   #2,D1                ; Anz. Knicke=2?
                beq.s   untenrout
                addq.w  #1,D1                ; Knicke +1
                moveq   #2,D0                ; Richt. links
keinknicklinks: lea     -1(A5),A5            ; Pos. -1
                cmpa.l  A5,A6                ; Ziel erreicht?
                bne.s   linkskeinz
                bsr.s   wegsave
                bra.s   nixmoeglich          ; eins zur�ck
linkskeinz:     tst.b   (A5)                 ; Feld frei?
                bne.s   untenrout            ; dort Rand oder Tile
                move.b  D0,(A0)+             ; Weg
                bsr.s   suchweg
                lea     -1(A0),A0
untenrout:      movem.l (A7),D0-D1/A5
                cmp.b   #4,D0
                beq.s   obenrout             ; von oben kommend?
                cmp.b   #3,D0                ; wieder unten?
                beq.s   keinknickunten
                cmp.w   #2,D1                ; Anz. Knicke=2?
                beq.s   obenrout
                addq.w  #1,D1                ; Knicke +1
                moveq   #3,D0                ; Richt. unten
keinknickunten: lea     20(A5),A5            ; ypos1. +1
                cmpa.l  A5,A6                ; Ziel erreicht?
                bne.s   untenkeinz
                bsr.s   wegsave
                bra.s   nixmoeglich          ; eins zur�ck
untenkeinz:     tst.b   (A5)                 ; Feld frei?
                bne.s   obenrout             ; dort Rand oder Tile
                move.b  D0,(A0)+             ; Weg
                bsr     suchweg
                lea     -1(A0),A0
obenrout:       movem.l (A7),D0-D1/A5
                cmp.b   #3,D0
                beq.s   nixmoeglich          ; von unten kommend?
                cmp.b   #4,D0                ; wieder oben?
                beq.s   keinknickoben
                cmp.w   #2,D1                ; Anz. Knicke=2?
                beq.s   nixmoeglich
                addq.w  #1,D1                ; Knicke +1
                moveq   #4,D0                ; Richt. unten
keinknickoben:  lea     -20(A5),A5           ; ypos1. -1
                cmpa.l  A5,A6                ; Ziel erreicht?
                bne.s   obenkeinz
                bsr.s   wegsave
                bra.s   nixmoeglich          ; eins zur�ck
obenkeinz:      tst.b   (A5)                 ; Feld frei?
                bne.s   nixmoeglich          ; dort Rand oder Tile
                move.b  D0,(A0)+             ; Weg
                bsr     suchweg
                lea     -1(A0),A0
nixmoeglich:    lea     12(A7),A7
                rts

wegsave:        move.b  D0,(A0)+             ; letztes Wegst�ck
                clr.b   (A0)
                lea     weg,A2
copyweg:        move.b  (A2)+,(A1)+          ; Weg kopieren
                bne.s   copyweg
                lea     -1(A0),A0
                rts

draw_weg:
; zeichnet den Weg von Tile 1 zu Tile 2

                move.w  tile1selektx,D0
                move.w  tile1selekty,D1      ; beide Steine zeichnen
                movea.l screen1(PC),A0
                bsr     draw_tile
                move.w  tile2selektx,D0
                move.w  tile2selekty,D1
                movea.l screen1(PC),A0
                bsr     draw_tile

                lea     weg,A0               ; dort liegt der Weg
                move.w  tile1selektx,D0      ; Koord.
                move.w  tile1selekty,D1
                move.w  tile2selektx,D2
                move.w  tile2selekty,D3
makeweg:        move.b  (A0)+,D4             ; Weg holen
                cmp.b   #1,D4                ; rechts?
                bne.s   wegnotrechts
                moveq   #0,D7
                addq.w  #1,D0                ; X+1
                cmpi.b  #3,(A0)              ; n�chstes St�ck unten
                bne.s   nixnextur
                move.w  #4*160,D7
                bra.s   wegweiter
nixnextur:      cmpi.b  #4,(A0)
                bne.s   wegweiter
                move.w  #3*160,D7
                bra.s   wegweiter
wegnotrechts:   cmp.b   #3,D4                ; unten?
                bne.s   wegnotunten
                move.w  #160,D7
                addq.w  #1,D1                ; Y+1
                cmpi.b  #1,(A0)
                bne.s   nixnextru
                move.w  #2*160,D7
                bra.s   wegweiter
nixnextru:      cmpi.b  #2,(A0)
                bne.s   wegweiter
                move.w  #3*160,D7
                bra.s   wegweiter
wegnotunten:    cmp.b   #4,D4                ; oben?
                bne.s   wegnotoben
                move.w  #160,D7
                subq.w  #1,D1                ; Y-1
                cmpi.b  #1,(A0)
                bne.s   nixnextul
                move.w  #5*160,D7
                bra.s   wegweiter
nixnextul:      cmpi.b  #2,(A0)
                bne.s   wegweiter
                move.w  #4*160,D7
                bra.s   wegweiter
wegnotoben:     subq.w  #1,D0                ; X-1
                moveq   #0,D7
                cmpi.b  #3,(A0)
                bne.s   nixnextlu
                move.w  #5*160,D7
                bra.s   wegweiter
nixnextlu:      cmpi.b  #4,(A0)
                bne.s   wegweiter
                move.w  #2*160,D7
wegweiter:      cmp.w   D0,D2                ; X1=X2?
                bne.s   nixkoorgleich
                cmp.w   D1,D3
                bne.s   nixkoorgleich

                move.w  tile1selektx,D0
                move.w  tile1selekty,D1
                move.w  tile2selektx,D2
                move.w  tile2selekty,D3
                movea.l screen1(PC),A0
                bsr     clear_tile           ; Tile 1+2 l�schen

                bsr     draw_screen

                bsr     switch

                tst.w   blumjzverz2
                beq.s   nixnewverz
                move.w  blumjzverz2,blumjzverz ; falls Verz. -> an
nixnewverz:
                rts

nixkoorgleich:  movem.l D0-A0,-(A7)
                movea.l screen1(PC),A2
                lsl.w   #3,D0                ; X mal 8
                addq.w  #8,D0                ; X + 8 wegen Startfeld
                and.l   #$ffff,D1            ; Y nur Lowword
                mulu    #20*160,D1           ; mal einer "Zeile"
                add.w   #ystartline*160,D1   ; ab dort beginnen Tiles
                add.w   D0,D1
                adda.l  D1,A2                ; auf Screen addieren
                lea     weggrafik(PC),A1
                adda.w  D7,A1                ; Element addieren
                moveq   #19,D0
dwgrf:          movem.w (A1)+,D1-D4          ; 4 Worte holen
                moveq   #0,D5
                move.w  D1,D5                ; Maske bilden
                or.w    D2,D5
                or.w    D3,D5
                or.w    D4,D5
                not.w   D5
                and.w   D5,(A2)              ; Wert ausmaskieren
                or.w    D1,(A2)+
                and.w   D5,(A2)              ; Wert ausmaskieren
                or.w    D2,(A2)+
                and.w   D5,(A2)              ; Wert ausmaskieren
                or.w    D3,(A2)+
                and.w   D5,(A2)              ; Wert ausmaskieren
                or.w    D4,(A2)+
                lea     152(A2),A2           ; eine Zeile tiefer
                dbra    D0,dwgrf

                bsr     vsync
                movem.l (A7)+,D0-A0
                bra     makeweg



preferences:
; Diese Routine setzt Bildschirm und Palette.
; erstellt auch Font
                move.l  #screenbase,D0
                and.l   #-256,D0             ; wegen fehlenden 8 Bit
                add.l   #256,D0
                move.l  D0,screen1
                add.l   #200*160,D0
                move.l  D0,screen2
                add.l   #200*160,D0
                move.l  D0,screen3
                add.l   #200*160,D0
                move.l  D0,screen4

                clr.w   screennumm           ; auf Bildschirm 0 (=1)
                move.w  #-1,timestop         ; Zeit anhalten

                movem.l $ffff8240.w,D0-D7    ; Farben retten
                movem.l D0-D7,oldpal


                movea.l screen1(PC),A0
                bsr     cls                  ; alle Screens l�schen
                movea.l screen2(PC),A0
                bsr     cls                  ; alle Screens l�schen
                movea.l screen3(PC),A0
                bsr     cls                  ; alle Screens l�schen
                movea.l screen4(PC),A0
                bsr     cls                  ; alle Screens l�schen

                bsr     vsync

		;bset	#1,$ffff820a.w		; 50Hz
                ;move.b  #0,$ffff8260.w       ; Lowres

		MOVE.W #STMODES+VGA+VERTFLAG+BPS4,-(SP)
		MOVE.W #$58,-(SP)
		TRAP #14
		ADDQ.L #4,SP


                move.l  #palette1,palpointer1 ; Palettenpointer setzen
                move.l  #palette2,palpointer2 ; Palettenpointer setzen
                move.l  #blinkcolors,blinkpos
                move.w  #0,blinkanaus        ; Blinken aus
                clr.w   blinkdelay

                move.l  screen1(PC),D0       ; Screen 1 setzen
                lsr.l   #8,D0
                move.b  D0,$ffff8203.w
                lsr.w   #8,D0
                move.b  D0,$ffff8201.w

                move.l  #keybuffer,keypointer
                clr.w   keycounter
                clr.l   keybuffer
                clr.l   keybuffer+4

                bsr     makefont

                moveq   #1,D0
                jsr     music

                moveq   #$08,D0
                bsr     sendkeyboard         ; Maus anschalten

                bsr     hbl_on               ; Interrupts anschalten

                rts


makefont:
; erstellt Tabelle f�r Font und schreibt Zeichen mit Maske in Buffer

                lea     fonttabelle,A0
                move.w  #(fonttabellelaenge/2)-1,D0
multab:         moveq   #0,D1
                move.w  (A0),D1              ; Werte multiplizieren
                mulu    #150,D1
                move.w  D1,(A0)+
                dbra    D0,multab

                lea     font,A0
                lea     fontbuff,A1          ; dort kommen die Zeichen hin
                moveq   #0,D0                ; 40 Zeichen
makefontloop:   movea.l A0,A2
                moveq   #14,D1               ; 15 Scanlines
makefontloop2:  moveq   #0,D2
                movem.w (A2),D3-D6           ; 4 Worte holen
                move.w  D3,D2
                or.w    D4,D2
                or.w    D5,D2
                or.w    D6,D2                ; Maske erstellen
                not.w   D2
                movem.w D2-D6,(A1)
                lea     10(A1),A1
                lea     160(A2),A2           ; eine Scanline tiefer
                dbra    D1,makefontloop2
                lea     8(A0),A0             ; ein Zeichen weiter
                addq.w  #1,D0
                cmp.w   #20,D0
                bne.s   nixnextline1
                lea     14*160(A0),A0        ; eine Zeichenzeile tiefer
                bra.s   makefontloop
nixnextline1:   cmp.w   #40,D0
                bne.s   nixnextline
                lea     14*160(A0),A0
                bra.s   makefontloop
nixnextline:    cmp.w   #47,D0               ; schon 47 Zeichen?
                bne.s   makefontloop
                rts


initgame:
; Inititalisiert alle Spielparameter

                move.l  #vblgame2,$70.w

                movem.l leerfeld,D0-D7
                movem.l D0-D7,hilfspalette1

                bsr     vsync

                movea.l screen1(PC),A0
                bsr     cls

                clr.l   rettbuff             ; Maus nicht restaurieren
                move.w  #1,timestop          ; Zeit anhalten

                move.w  #8*16,mousex
                move.w  #ystartline+80,mousey
                clr.w   mousek


                clr.w   helpverbraucht       ; noch kein Help verbraucht!
                move.w  #-1,kasten1aktiv     ; Kasten 1 aus
                clr.w   endeflag             ; noch spielen!
                clr.b   tile1selektpos       ; noch kein Tile selekt.
                move.w  #48,paaranzahl       ; Anzahl der Paare
                bsr     make_buff            ; erstellt Spielbuffer
                bsr     draw_screen          ; zeichnet Spielscreen
                bsr     switch
                clr.w   kasten1aktiv         ; Kasten an

                move.w  #200,time            ; Zeit
                clr.w   vblcount
                clr.w   blumjzverz           ; Verz. von BlumeJz=0
                clr.w   blumjzverz2

welchpalette:   bsr     random               ; Welche Plattenfarben?
                and.w   #7,D0                ; Werte von 0-7
                cmp.w   #5,D0
                bgt.s   welchpalette         ; nur Werte von 0-5
                lea     plattenfarben(PC),A0
                lsl.w   #5,D0                ; d0*32
                adda.w  D0,A0
                movem.l (A0),D0-D7
                movem.l D0-D7,palette2

                move.w  #1,blinkanaus        ; Blinken an

                move.l  #vblgame,$70.w
                bsr     initpalpointers
                movem.l leerfeld,D0-D7
                movem.l D0-D7,hilfspalette1
                movem.l D0-D7,hilfspalette2
                bsr     fadeup
                bsr     exitpalpointers

                clr.w   timestop             ; Time starten
                rts

pause:
; geht in Pausemodus und entfernt Platte vom Screen

                move.l  #vblpause,$70.w      ; neuer VBL

                bsr     initpalpointers

                clr.l   rettbuff
                bsr     vsync

suchpauserout:  bsr     random
                and.w   #3,D0                ; Routine 1,2 oder 3
                cmp.w   #2,D0
                bgt.s   suchpauserout        ; Zufallsm��ige Routine
                lsl.w   #2,D0                ; d0 * 4
                lea     pauseroutinen(PC),A0 ; welche Routine?
                movea.l 0(A0,D0.w),A0
                jsr     (A0)
                move.l  #vblgame,$70.w
exitpalpointers:move.l  savepalpoint1,palpointer1
                move.l  savepalpoint2,palpointer2
                rts


initpalpointers:movea.l palpointer1,A0
                move.l  A0,savepalpoint1     ; retten
                movem.l (A0),D0-D7
                movem.l D0-D7,hilfspalette1  ; Palette w�hrend Pause
                move.l  #hilfspalette1,palpointer1
                movea.l palpointer2,A0
                move.l  A0,savepalpoint2     ; retten
                movem.l (A0),D0-D7
                movem.l D0-D7,hilfspalette2  ; Palette w�hrend Pause
                move.l  #hilfspalette2,palpointer2
                rts


pausedraw:
; zeichnet Pausezeichen aus Wegelementen
                bsr     fadeup2              ; Farben auf Wei�
                movea.l screen1(PC),A0
                bsr     cls                  ; Bildschirm l�schen
                bsr     fadedown

                lea     pausegraf(PC),A0     ; Elemente
                movea.l screen1(PC),A1
                lea     50*160(A1),A1        ; auf Zeile 50
                moveq   #4,D0                ; 5 Zeilen
makepause:      moveq   #19,D1               ; 20 Bl�cke
                movea.l A1,A2
makepause1:     moveq   #0,D3
                move.b  (A0)+,D3             ; Wert holen
                beq.s   notdrawpause         ; Leerfeld
                subq.w  #1,D3
                mulu    #160,D3              ; mal Gr��e eines Felds
                lea     weggrafik(PC),A3
                adda.w  D3,A3
                movea.l A2,A4
                moveq   #19,D3               ; 20 Zeilen
makepause2:     move.l  (A3)+,(A4)+
                move.l  (A3)+,(A4)+
                lea     152(A4),A4
                dbra    D3,makepause2
notdrawpause:   lea     8(A2),A2
                dbra    D1,makepause1
                lea     20*160(A1),A1
                dbra    D0,makepause

                bsr     fadeup
                bsr.s   waitforpauseend
                rts

pausescroll:
; scrollt Screen raus
                bsr.s   scrollraus
                bra.s   pausedraw


waitforpauseend:
                cmpi.b  #$39,keybuffer
                beq.s   endepause

                move.b  mousek,D0
                btst    #1,D0
                bne.s   endepause
                bra.s   waitforpauseend

endepause:      bsr     fadedown
                bsr     draw_screen
                bsr     switch
                tst.b   tile1selektpos       ; ein Tile selektiert?
                beq.s   nottilepause
                move.w  tile1selektx,D0
                move.w  tile1selekty,D1
                bsr     draw_kasten
nottilepause:   bsr     fadeup
                clr.w   mousek
                rts


scrollraus:     movea.l screen1(PC),A0       ; auf alle Screens kopieren
                movea.l screen2(PC),A1
                movea.l screen3(PC),A2
                movea.l screen4(PC),A3
                move.w  #(264*40)-1,D0
copyonallscreens:
                move.l  (A0),(A1)+
                move.l  (A0),(A2)+
                move.l  (A0)+,(A3)+
                dbra    D0,copyonallscreens

                movea.l screen1(PC),A0       ; Screen 2 shiften
                movea.l screen2(PC),A1
                bsr     preshift
                movea.l screen2(PC),A0       ; Screen 3 shiften
                movea.l screen3(PC),A1
                bsr     preshift
                movea.l screen3(PC),A0       ; Screen 4 shiften
                movea.l screen4(PC),A1
                bsr     preshift

                clr.w   screennumm
                clr.w   readycount           ; counter1 init.
scrolloutloop:  bsr     scroll
                bsr     switchall            ; zwischen 4 Screens
                cmpi.w  #100,readycount
                bne.s   scrolloutloop
                rts

eingabe:        lea     namebuff,A0
                moveq   #9,D0                ; 10 Zeichen
clrnamebuff:    clr.b   (A0)+
                dbra    D0,clrnamebuff

                lea     namebuff,A6
                lea     cursortext(PC),A0
                moveq   #1,D0
                moveq   #5,D1
                move.w  #170,D2
                movea.l screen1(PC),A1
                bsr     textaus2
                moveq   #0,D5                ; Anz. der schon eing. Zeichen=0
eingabeloop0:   clr.b   keybuffer
                bsr     vsync
                move.b  keybuffer,D0
                tst.b   D0
                beq.s   eingabeloop0
                cmp.b   #$0e,D0              ; Backspace?
                beq     backspace
                cmp.b   #$1c,D0              ; Return?
                beq     endeingabe
                cmp.w   #10,D5               ; Zeichen schon maximal
                bge     eingabeloop0
                bsr     scantoascii
                tst.b   D0
                beq     eingabeloop0
                move.b  D0,(A6)+
                addq.w  #1,D5                ; Zeichen +1
                lea     -1(A6),A0
                moveq   #1,D0
                move.w  D5,D1
                addq.w  #4,D1
                move.w  #170,D2
                movea.l screen1(PC),A1
                bsr     textaus2
                addq.w  #1,D1                ; X-Pos +1
                cmp.w   #20,D1
                beq     eingabeloop0
                lea     cursortext(PC),A0
                moveq   #1,D0
                move.w  #170,D2
                movea.l screen1(PC),A1
                bsr     textaus2             ; gibt Cursor aus
                bra     eingabeloop0
endeingabe:     move.b  #0,(A6)+
                rts
backspace:      tst.w   D5
                beq     eingabeloop0         ; noch kein Zeichen eingegeben
                lea     -1(A6),A6
                clr.b   (A6)
                subq.w  #1,D5                ; Zeichen -1

                cmp.w   #20,D1
                beq     notspaceit

                lea     cursortext+1(PC),A0
                moveq   #1,D0
                move.w  #170,D2
                movea.l screen1(PC),A1
                bsr     textaus2

notspaceit:     subq.w  #1,D1
                cmp.w   #20,D1
                beq     eingabeloop0

                lea     cursortext(PC),A0
                moveq   #1,D0
                move.w  #170,D2
                movea.l screen1(PC),A1
                bsr     textaus2
                bra     eingabeloop0

scantoascii:    moveq   #0,D7
                move.b  D0,D7
                lea     asciitab(PC),A0
                moveq   #0,D0
                move.b  0(A0,D7.w),D0
                rts

cursortext:     DC.B "? "
asciitab:       DC.B 0,0        ; 0 und ESC
                DC.B "1234567890" ; 2 bis $b
                DC.B 0,0,0,0    ; $c-$f
                DC.B "QWERTZUIOP" ; $E-$19
                DC.B 0,0,0,0    ; $1a-$1d
                DC.B "ASDFGHJKL" ; $1e-$26
                DC.B 0,0,0,0,0  ; $27-$2b
                DC.B "YXCVBNM"  ; $2c-$32
                DC.B 0,0,0,0,0,0," ",0 ; $33-$3a
                DS.B 256-$38
                EVEN

preshift:
; shiftet Bild um 4 Pixel nach links
; in a0=Pointer auf Bild (source)
; a1=Dest.
                lea     152(A0),A0           ; Pointer um an Ende Scanline
                lea     152(A1),A1           ; Pointer um an Ende Scanline
                lea     17*160(A0),A0        ; ab Zeile 17
                lea     17*160(A1),A1
                move.w  #180,D0              ; 181 Zeilen
sh8screen1:     moveq   #19,D1               ; 20 Bitblocks
                moveq   #0,D4
                moveq   #0,D5
                moveq   #0,D6
                moveq   #0,D7
sh8screen2:     moveq   #0,D2
                move.w  (A0),D2
                lsl.l   #4,D2
                or.w    D4,D2
                move.w  D2,(A1)
                swap    D2
                move.w  D2,D4
                moveq   #0,D2
                move.w  2(A0),D2
                lsl.l   #4,D2
                or.w    D5,D2
                move.w  D2,2(A1)
                swap    D2
                move.w  D2,D5
                moveq   #0,D2
                move.w  4(A0),D2
                lsl.l   #4,D2
                or.w    D6,D2
                move.w  D2,4(A1)
                swap    D2
                move.w  D2,D6
                moveq   #0,D2
                move.w  6(A0),D2
                lsl.l   #4,D2
                or.w    D7,D2
                move.w  D2,6(A1)
                swap    D2
                move.w  D2,D7
                lea     -8(A0),A0
                lea     -8(A1),A1
                dbra    D1,sh8screen2
                lea     320(A0),A0
                lea     320(A1),A1
                dbra    D0,sh8screen1
                rts

scroll:
; schiebt die Screens dann raus
                cmpi.w  #3,readycount
                ble.s   notscrollout
                move.w  screennumm,D0
                lea     screen1(PC),A0
                lsl.w   #2,D0
                movea.l 0(A0,D0.w),A0
                lea     17*160(A0),A0        ; Zeile 16
                movea.l A0,A1
                move.l  A1,-(A7)
                lea     8(A0),A0
                move.w  #180,D0              ; 181 Zeilen
sl0:            movem.l (A0)+,D1-D7/A1-A6
                movem.l D1-D7/A1-A6,-60(A0)
                movem.l (A0)+,D1-D7/A1-A6
                movem.l D1-D7/A1-A6,-60(A0)
                movem.l (A0)+,D1-D7/A1-A5
                movem.l D1-D7/A1-A5,-56(A0)
                lea     8(A0),A0
                dbra    D0,sl0
                movea.l (A7)+,A1
                lea     152(A1),A1
                moveq   #0,D1
                move.w  #180,D0              ; 180 Zeilen
clrhinten:      move.l  D1,(A1)+
                move.l  D1,(A1)+
                lea     152(A1),A1
                dbra    D0,clrhinten
notscrollout:   addq.w  #1,readycount        ; Z�hler +1
                rts

switchall:
; Diese Routine stellt n�chsten der 4 Bildschirme dar.
                bsr     vsync                ; auf VBL warten
                move.w  screennumm,D0        ; aktueller Screen
                addq.w  #1,D0                ; n�chster Screen
                and.w   #3,D0                ; nur Werte von 0-3
                move.w  D0,screennumm        ; wieder zur�ck
                lsl.w   #2,D0                ; d0*4 -> Longs
                lea     screen1(PC),A0       ; Basisadresse
                move.l  0(A0,D0.w),D0        ; Adresse holen
                lsr.l   #8,D0                ; Screen setzen
                move.b  D0,$ffff8203.w
                lsr.w   #8,D0
                move.b  D0,$ffff8201.w
                rts


zerkriesel:
; zerkrieselt die Platte
                bsr     random               ; Opcode (ROR Dx,D0)
                and.w   #3,D0
                cmp.w   #3,D0
                beq.s   zerkriesel           ; nur Werte von 0-2
                add.w   D0,D0                ; *2 wegen Opcode
                lea     krieslopcodes(PC),A0
                move.w  0(A0,D0.w),krieslopcode

                bsr     random
                and.w   #7,D0
                move.w  D0,D3                ; Wert 1 f�r Krieseln
                lea     kriesldat(PC),A6
                movea.l screen1(PC),A5
                lea     17*160(A5),A5
                moveq   #19,D7
krieslloop:     cmpi.w  #-1,(A6)
                bne.s   nixendkriesl
                lea     kriesldat(PC),A6
nixendkriesl:   movea.l A5,A1
                movea.l A6,A0
                move.w  #19,D2
kloop0:         move.w  #180,D1
                movea.l A1,A3
                move.w  (A0)+,D0
                cmp.w   #-1,D0
                bne.s   nixendkries2
                lea     kriesldat(PC),A0
                move.w  (A0)+,D0
nixendkries2:   and.w   D0,(A3)+
                and.w   D0,(A3)+
                and.w   D0,(A3)+
                and.w   D0,(A3)+
krieslopcode:   ror.w   D2,D0
                lea     152(A3),A3
                dbra    D1,nixendkries2
                lea     8(A1),A1
                dbra    D2,kloop0
                lea     2(A6),A6
                bsr     vsync
                dbra    D7,krieslloop
                bra     pausedraw




fadedown:
; blendet Farbpaletten runter
                lea     hilfspalette1,A6     ; w�hrend VBL dort Pal1
                bsr.s   fadedwn
                bsr     vsync
                lea     hilfspalette2,A6     ; w�hrend VBL dort Pal3
                bsr.s   fadedwn

                moveq   #31,D7               ; 3 Pal. sind hintereinand.
                lea     hilfspalette1,A0     ; im Speicher -> eine Rout.
count0col:      move.w  (A0)+,D0
                and.w   #$0777,D0
                bne.s   fadedown
                dbra    D7,count0col
                rts


fadedwn:        moveq   #15,D7
fdl0:           move.w  (A6),D0
                and.w   #%111,D0
                beq.s   col2
                subq.w  #1,D0
                move.w  (A6),D1
                and.w   #%1111111111111000,D1
                or.w    D0,D1
                move.w  D1,(A6)
                bra.s   colok
col2:           move.w  (A6),D0
                and.w   #%1110000,D0
                beq.s   col3
                sub.w   #$10,D0
                move.w  (A6),D1
                and.w   #%1111111110001111,D1
                or.w    D0,D1
                move.w  D1,(A6)
                bra.s   colok
col3:           move.w  (A6),D0
                and.w   #%11100000000,D0
                beq.s   colok
                sub.w   #$0100,D0
                move.w  (A6),D1
                and.w   #%1111100011111111,D1
                or.w    D0,D1
                move.w  D1,(A6)
colok:          lea     2(A6),A6
                dbra    D7,fdl0
                rts

fadeup2:
; blendet Farbpalette hoch (auf Wei�)
                lea     hilfspalette1,A6
                bsr     fade_up2
                bsr     vsync
                bsr     vsync
                lea     hilfspalette2,A6
                bsr     fade_up2

                moveq   #31,D7
                lea     hilfspalette1,A0
compcol2:       move.w  (A0)+,D0
                and.w   #$0777,D0
                cmp.w   #$0777,D0
                bne.s   fadeup2
                dbra    D7,compcol2
                rts

fadedown2:
; blendet Farbpalette von wei� runter auf Palette

                lea     hilfspalette1,A6
                lea     palette1(PC),A5
                bsr     fade_down2

                bsr     vsync
                bsr     vsync
                bsr     vsync

                moveq   #15,D7
                lea     hilfspalette1,A0
                lea     palette1(PC),A1
compcol3:       move.w  (A0)+,D0
                and.w   #$0777,D0
                move.w  (A1)+,D1
                and.w   #$0777,D1
                cmp.w   D0,D1
                bne.s   fadedown2
                dbra    D7,compcol3
                rts

fadeup:
; blendet Farbpalette hoch

                lea     hilfspalette1,A6
                lea     palette1(PC),A5
                bsr     fade_up
                lea     hilfspalette2,A6
                lea     palette2(PC),A5
                bsr     fade_up

                bsr     vsync
                bsr     vsync

                moveq   #31,D7
                lea     palette1(PC),A1
                lea     hilfspalette1,A0
compcol:        move.w  (A1)+,D0
                and.w   #$0777,D0
                move.w  (A0)+,D1
                and.w   #$0777,D1
                cmp.w   D0,D1
                bne.s   fadeup
                dbra    D7,compcol

                rts

fadeup3:
; blendet Farbpalette hoch

                lea     hilfspalette1,A6
                lea     palette1(PC),A5
                bsr     fade_up

                bsr     vsync
                bsr     vsync

                moveq   #15,D7
                lea     palette1(PC),A1
                lea     hilfspalette1,A0
compcol6:       move.w  (A1)+,D0
                and.w   #$0777,D0
                move.w  (A0)+,D1
                and.w   #$0777,D1
                cmp.w   D0,D1
                bne.s   fadeup3
                dbra    D7,compcol6

                rts
fadedown3:
; blendet Farbpalette runter

                lea     hilfspalette1,A6
                bsr     fadedwn

                bsr     vsync
                bsr     vsync

                moveq   #15,D7
                lea     hilfspalette1,A0
compcol5:       move.w  (A0)+,D0
                and.w   #$0777,D0
                bne.s   fadedown3
                dbra    D7,compcol5

                rts


fadeup4:
; blendet Farbpalette hoch

                lea     hilfspalette1,A6
                lea     instrpal(PC),A5
                bsr     fade_up

                bsr     vsync
                bsr     vsync

                moveq   #15,D7
                lea     instrpal(PC),A1
                lea     hilfspalette1,A0
compcol7:       move.w  (A1)+,D0
                and.w   #$0777,D0
                move.w  (A0)+,D1
                and.w   #$0777,D1
                cmp.w   D0,D1
                bne.s   fadeup4
                dbra    D7,compcol7

                rts

fade_up2:                                    ; blendet auf Weiss hoch
                moveq   #15,D7
ful0:           move.w  (A6),D0
                and.w   #%111,D0
                moveq   #7,D1
                cmp.w   D0,D1
                beq.s   fcol2
                addq.w  #1,D0
                move.w  (A6),D1
                and.w   #%1111111111111000,D1
                or.w    D0,D1
                move.w  D1,(A6)
                bra.s   fcolok
fcol2:          move.w  (A6),D0
                and.w   #%1110000,D0
                move.w  #$70,D1
                cmp.w   D0,D1
                beq.s   fcol3
                add.w   #$10,D0
                move.w  (A6),D1
                and.w   #%1111111110001111,D1
                or.w    D0,D1
                move.w  D1,(A6)
                bra.s   fcolok
fcol3:          move.w  (A6),D0
                and.w   #%11100000000,D0
                move.w  #$0700,D1
                cmp.w   D0,D1
                beq.s   fcolok
                add.w   #$0100,D0
                move.w  (A6),D1
                and.w   #%1111100011111111,D1
                or.w    D0,D1
                move.w  D1,(A6)
fcolok:         lea     2(A6),A6
                lea     2(A5),A5
                dbra    D7,ful0
                rts

fade_up:        moveq   #15,D7
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
                rts

fade_down2:     moveq   #15,D7
ful012:         move.w  (A6),D0
                and.w   #%111,D0
                move.w  (A5),D1
                and.w   #%111,D1
                cmp.w   D0,D1
                beq.s   fcol212
                subq.w  #1,D0
                move.w  (A6),D1
                and.w   #%1111111111111000,D1
                or.w    D0,D1
                move.w  D1,(A6)
                bra.s   fcolok12
fcol212:        move.w  (A6),D0
                and.w   #%1110000,D0
                move.w  (A5),D1
                and.w   #%1110000,D1
                cmp.w   D0,D1
                beq.s   fcol312
                sub.w   #$10,D0
                move.w  (A6),D1
                and.w   #%1111111110001111,D1
                or.w    D0,D1
                move.w  D1,(A6)
                bra.s   fcolok12
fcol312:        move.w  (A6),D0
                and.w   #%11100000000,D0
                move.w  (A5),D1
                and.w   #%11100000000,D1
                cmp.w   D0,D1
                beq.s   fcolok12
                sub.w   #$0100,D0
                move.w  (A6),D1
                and.w   #%1111100011111111,D1
                or.w    D0,D1
                move.w  D1,(A6)
fcolok12:       lea     2(A6),A6
                lea     2(A5),A5
                dbra    D7,ful012
                rts


draw_helps:
; a1=Screen
                lea     128(A1),A1
                moveq   #0,D0
                move.w  helpcount,D0
                lsl.w   #8,D0                ; *512
                add.w   D0,D0
                lea     helpplatten(PC),A0
                adda.w  D0,A0
                moveq   #15,D0               ; 16 Zeilen
copyhelps:      movem.l (A0)+,D1-D7/A2       ; 8 Longs
                movem.l D1-D7/A2,(A1)
                lea     160(A1),A1
                dbra    D0,copyhelps
                rts


;--------------------------------- System ----------------------------

switch:
; Diese Routine tauscht die Bildschirme 1 + 2

                bsr.s   vsync                ; auf VBL warten
                move.l  screen2(PC),D0
                move.l  screen1(PC),screen2  ; Screen 1+2 tauschen
                move.l  D0,screen1
setscreen:      lsr.l   #8,D0                ; Screen setzen
                move.b  D0,$ffff8203.w
                lsr.w   #8,D0
                move.b  D0,$ffff8201.w
                rts

vsync:
; Diese Routine wartet auf das Vertical Blank Signal
                move.l  $0466.w,D0
waitstrahl:     cmp.l   $0466.w,D0
                beq.s   waitstrahl
                rts



cls:
; L�scht Bildschirm
; Parameter:    a0=Screenadresse

                moveq   #0,D1                ; alle Register l�schen
                move.l  D1,D2
                move.l  D1,D3
                move.l  D1,D4
                move.l  D1,D5
                move.l  D1,D6
                move.l  D1,D7
                movea.l D1,A1
                movea.l D1,A2
                movea.l D1,A3
                adda.l  #200*160,A0          ; auf unteren Rand gehen
                move.w  #199,D0              ; 200 Scanlines l�schen
clsloop:        movem.l D1-D7/A1-A3,-(A0)
                movem.l D1-D7/A1-A3,-(A0)
                movem.l D1-D7/A1-A3,-(A0)
                movem.l D1-D7/A1-A3,-(A0)
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
		move.l	$70.w,old_vbl
                andi.b  #$df,$fffffa09.w     ; Timer C aus
                andi.b  #$fe,$fffffa07.w     ; Timer B aus
                move.l  #newkey,$0118.w
                move.l  #vblstart,$70.w
                move.l  #hbl1,$0120.w
                ori.b   #1,$fffffa07.w       ; Timer B an
                ori.b   #1,$fffffa13.w
                bclr    #3,$fffffa17.w       ; automatic EOI
                move    (A7)+,SR
                rts

hbl_off:        move    SR,-(A7)
                ori     #$0700,SR
                lea     hbl_buff,A0          ; Werte zur�ck!
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

vblgame:        movem.l D0-A6,-(A7)
                lea     $fffffa21.w,A0       ; Timer B DATA
                clr.b   -6(A0)               ; Timer B Stop
                move.b  #15,(A0)             ; 15 Zeilen z�hlen
                move.b  #8,-6(A0)            ; Timer B Start
                move.l  #hbl1,$0120.w

                movea.l palpointer1,A0
                movem.l (A0),D0-D7
                movem.l D0-D7,$ffff8240.w

                tst.w   blinkanaus
                beq.s   nixblinken
                eori.w  #1,blinkdelay
                beq.s   nixblinken
                addq.l  #2,blinkpos
                movea.l blinkpos,A0
                cmpi.w  #-1,(A0)
                bne.s   nixendblinkpos
                lea     blinkcolors(PC),A0
nixendblinkpos: move.w  (A0),palette2+2
                move.l  A0,blinkpos

nixblinken:
                bsr     controlmouse         ; jeweilige Routine

                cmpi.l  #$136d7c22,cheatmode ; Cheat aktiviert?
                beq.s   timenotende

                tst.w   timestop             ; Zeit aus?
                bne.s   timenotdraw
                addq.w  #1,vblcount
                move.w  timeverzoegerung,D0  ; Wartezeit
                cmp.w   vblcount,D0          ; Wartezeit erreicht?
                bne.s   timenotende
                clr.w   vblcount
                tst.w   blumjzverz           ; Verz. an?
                beq.s   noverzoegerung
                subq.w  #1,blumjzverz
                bra.s   timenotende          ; Zeit anhalten!
noverzoegerung: subi.w  #1,time              ; Zeit -1
                bne.s   timenotende
                move.w  #-1,endeflag         ; Spiel zu Ende
                clr.w   time
timenotende:    bsr     draw_time
timenotdraw:    jsr     music+8

                addq.l  #1,$0466.w           ; System VBL ganz abgeklemmt
                movem.l (A7)+,D0-A6
                rte

vblpause:
; VBL w�hrend der Pausefunktion
                movem.l D0-A6,-(A7)
                lea     $fffffa21.w,A0       ; Timer B DATA
                clr.b   -6(A0)               ; Timer B Stop
                move.b  #15,(A0)             ; 15 Zeilen z�hlen
                move.b  #8,-6(A0)            ; Timer B Start
                move.l  #hbl1,$0120.w

                movea.l palpointer1,A0       ; Palette setzen
                movem.l (A0),D0-D7
                movem.l D0-D7,$ffff8240.w

                jsr     music+8

                addq.l  #1,$0466.w           ; VSYNC
                movem.l (A7)+,D0-A6
                rte

vblgame2:       movem.l D0-A6,-(A7)
                clr.b   $fffffa1b.w

                movem.l hilfspalette1,D0-D7
                movem.l D0-D7,$ffff8240.w

                jsr     music+8

                addq.l  #1,$0466.w           ; VSYNC
                movem.l (A7)+,D0-A6
                rte

vblmenu:        movem.l D0-A6,-(A7)
                clr.b   $fffffa1b.w

                movem.l hilfspalette1,D0-D7
                movem.l D0-D7,$ffff8240.w

                tst.w   scrollready
                bne.s   nixdoscroller
                bsr     restmouse
                bsr     putmouse
                bsr     scroller
nixdoscroller:
                jsr     music+8

                addq.l  #1,$0466.w           ; VSYNC
                movem.l (A7)+,D0-A6
                rte

controlmouse:   tst.w   kasten1aktiv
                bne.s   notdrawmouse
                bsr     restmouse
                bsr     putmouse
notdrawmouse:   rts


vblquit:        movem.l D0-D7,-(A7)
                clr.b   $fffffa1b.w
                movem.l hilfspalette1,D0-D7
                movem.l D0-D7,$ffff8240.w
                movem.l (A7)+,D0-D7
                addq.l  #1,$0466.w
                rte

vblstart:	addq.l	#1,$466.w
		rte

;---------------------- Keyvector ----------------------------------------
newkey:
; neuer Keyinterrupt
                move    #$2500,SR
                movem.l D0/A0-A1,-(A7)
                moveq   #0,D0
                lea     $fffffc00.w,A0       ; ACIA-Statusregister
abhol_loop:     move.b  (A0),D0              ; Wert holen
                btst    #7,D0                ; Interrupt-Request?
                beq.s   nixmehrkey           ; nix mehr Interrupt

                move.b  2(A0),D0             ; Wert abholen
                tst.b   keycounter           ; geh�rt das zum Paket?
                bne.s   warpaketbyte

                cmp.w   #$f7,D0              ; ist da ein Paket?
                blt.s   istkeinpaket

                move.l  #keybuffer+1,keypointer
                move.b  D0,keybuffer
                sub.w   #$f7,D0
                lea     paket_tabelle,A1     ; dort sind L�ngen der Pakete
                move.b  0(A1,D0.w),D0        ; L�nge holen
                subq.w  #1,D0                ; -1 weil das erste Byte schon da
                move.b  D0,keycounter
                bra.s   keytest
istkeinpaket:   move.b  D0,keybuffer         ; einfach ablegen
                bra.s   keytest

warpaketbyte:   subq.b  #1,keycounter
                movea.l keypointer,A1
                move.b  D0,(A1)+
                move.l  A1,keypointer
                tst.w   keycounter
                bne.s   keytest
                bsr     new_mouse            ; Mausroutine

keytest:        move.b  (A0),D0              ; Status holen
                btst    #0,D0                ; noch was zum abholen da?
                bne     abhol_loop
nixmehrkey:     movem.l (A7)+,D0/A0-A1
                bclr    #6,$fffffa11.w       ; Interrupt in Service l�schen
                rte


hbl1:
; setzt in Zeile 16 die Eispalette
                movem.l D0-A2,-(A7)
                lea     $fffffa21.w,A0
                clr.b   -6(A0)
                move.b  #4,(A0)
                move.b  #8,-6(A0)
                movea.l palpointer2,A2       ; Palette 2
                movem.l (A2),D1-D7/A1        ; Palette holen
                move.b  (A0),D0              ; Zeile holen
waitrand2:      cmp.b   (A0),D0              ; noch gleiche Zeile?
                beq.s   waitrand2
                movem.l D1-D7/A1,$ffff8240.w ; Palette setzen
                clr.b   -6(A0)               ; Timer B stop
                movem.l (A7)+,D0-A2
                rte

hbl2:
; setzt in Zeile 32 die Eispalette
                movem.l D0-A1,-(A7)
                lea     $fffffa21.w,A0
                clr.b   -6(A0)
                move.b  #4,(A0)
                move.b  #8,-6(A0)
                movem.l hilfspalette2,D1-D7/A1 ; Palette holen
                move.b  (A0),D0              ; Zeile holen
waitrand3:      cmp.b   (A0),D0              ; noch gleiche Zeile?
                beq.s   waitrand3
                movem.l D1-D7/A1,$ffff8240.w ; Palette setzen
                clr.b   -6(A0)               ; Timer B stop
                movem.l (A7)+,D0-A1
                rte


                DATA

screen1:        DS.L 1          ; Screen 1-4
screen2:        DS.L 1
screen3:        DS.L 1
screen4:        DS.L 1


keyroutinen:    DC.L endgame
                DC.L helpfunktion
                DC.L pause
                DC.L cheatlevel
                DC.L gameovererzeug
                DC.L addscore
                DC.L musiconoff

keytab:         DC.B 1          ; Escape
                DC.B $62        ; HELP
                DC.B $19        ; P
                DC.B $44        ; f10
                DC.B 2          ; 1
                DC.B 3          ; 2
                DC.B $32        ; M
                DC.B -1
                EVEN


pauseroutinen:  DC.L pausedraw  ; Farben faden
                DC.L pausescroll ; Platte rausscrollen
                DC.L zerkriesel ; Platte nach Zufall krieseln

blinkcolors:
                DC.W $10,$20,$30,$40,$50,$60
                DCB.W 10,$70
                DC.W $60,$50,$40,$30,$20,$10
                DC.W $0100,$0200,$0300,$0400,$0500,$0600
                DCB.W 10,$0700
                DC.W $0600,$0500,$0400,$0300,$0200,$0100
                DC.W $01,$02,$03,$04,$05,$06
                DCB.W 10,$07
                DC.W $06,$05,$04,$03,$02,$01
                DC.W -1


instrpal:       DC.W $00,$0777

palette1:                                    ; Palette f�r Zahlen
                DC.W $20,$0761,$0640,$0430,$0764,$0555,$0333,$00
                DC.W $12,$23,$34,$45,$56,$0201,$0403,$0705
palette2:                                    ; Palette f�r Eisplatte
                DC.W $20,$70,$0300,$0533,$0333,$00,$0124,$0225
                DC.W $0235,$0335,$0346,$0457,$0557,$0567,$0677,$0777

cheatpalette:
; Plattenfarben (oben) im Cheatmodus
                DC.W $0102,$0304,$0507


plattenfarben:                               ; Paletten f�r Eisplatte
                DC.W $20,$70,$0300,$0533,$0333,$00,$0124,$0225
                DC.W $0235,$0335,$0346,$0457,$0557,$0567,$0677,$0777

                DC.W $20,$70,$0300,$0533,$0333,$00,$0323,$0333
                DC.W $0434,$0444,$0545,$0555,$0656,$0666,$0767,$0777

                DC.W $20,$70,$0300,$0533,$0333,$00,$0100,$0200
                DC.W $0310,$0420,$0531,$0642,$0753,$0764,$0775,$0776

                DC.W $20,$70,$0300,$0533,$0333,$00,$01,$02
                DC.W $13,$24,$0135,$0246,$0357,$0467,$0577,$0677

                DC.W $20,$70,$0300,$0533,$0333,$00,$0232,$0333
                DC.W $0343,$0444,$0454,$0555,$0565,$0666,$0676,$0777

                DC.W $20,$70,$0300,$0533,$0333,$00,$0322,$0332
                DC.W $0433,$0443,$0544,$0554,$0655,$0665,$0766,$0777


pausegraf:
; Nummern der Wegelemente f�r Pause aus Wegst�cken
                DC.B 6,1,5,0,6,1,5,0,2,0,2,0,6,1,1,0,6,1,1,0
                DC.B 2,0,2,0,2,0,2,0,2,0,2,0,2,0,0,0,2,0,0,0
                DC.B 2,1,4,0,2,1,2,0,2,0,2,0,3,1,5,0,2,1,1,0
                DC.B 2,0,0,0,2,0,2,0,2,0,2,0,0,0,2,0,2,0,0,0
                DC.B 2,0,0,0,2,0,2,0,3,1,4,0,1,1,4,0,3,1,1,0

schatten:
;$16
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$c000,$00,$c000,$00
                DC.W $00,$00,$00,$00,$c000,$00,$c000,$00
                DC.W $00,$00,$00,$00,$c000,$00,$c000,$00
                DC.W $00,$00,$00,$00,$c000,$00,$c000,$00
                DC.W $00,$00,$00,$00,$c000,$00,$c000,$00
                DC.W $00,$00,$00,$00,$c000,$00,$c000,$00
                DC.W $00,$00,$00,$00,$c000,$00,$c000,$00
                DC.W $00,$00,$00,$00,$c000,$00,$c000,$00
                DC.W $00,$00,$00,$00,$c000,$00,$c000,$00
                DC.W $00,$00,$00,$00,$c000,$00,$c000,$00
                DC.W $00,$00,$00,$00,$c000,$00,$c000,$00
                DC.W $00,$00,$00,$00,$c000,$00,$c000,$00
                DC.W $00,$00,$00,$00,$c000,$00,$c000,$00
                DC.W $00,$00,$00,$00,$c000,$00,$c000,$00
                DC.W $00,$00,$00,$00,$c000,$00,$c000,$00
                DC.W $00,$00,$00,$00,$c000,$00,$c000,$00
                DC.W $00,$00,$00,$00,$c000,$00,$c000,$00
                DC.W $00,$00,$00,$00,$c000,$00,$c000,$00
                DC.W $00,$00,$00,$00,$c000,$00,$c000,$00
                DC.W $3fff,$00,$3fff,$00,$c000,$00,$c000,$00
                DC.W $3fff,$00,$3fff,$00,$c000,$00,$c000,$00
schattenmaske:
                DC.W $00,$00,$00,$c000,$00,$c000,$00,$c000
                DC.W $00,$c000,$00,$c000,$00,$c000,$00,$c000
                DC.W $00,$c000,$00,$c000,$00,$c000,$00,$c000
                DC.W $00,$c000,$00,$c000,$00,$c000,$00,$c000
                DC.W $00,$c000,$00,$c000,$00,$c000,$00,$c000
                DC.W $3fff,$c000,$3fff,$c000

mauszeiger:
                DC.W $00,$0f00,$00,$00,$0680,$0f00,$80,$00
                DC.W $0680,$0f00,$80,$00,$0680,$0f00,$80,$00
                DC.W $00,$fff0,$00,$00,$76e8,$fff0,$08,$00
                DC.W $76e8,$fff0,$08,$00,$08,$fff0,$08,$00
                DC.W $76f8,$0f00,$70f8,$00,$0680,$0f00,$80,$00
                DC.W $0680,$0f00,$80,$00,$80,$0f00,$80,$00
                DC.W $0780,$00,$0780,$00

mauszeiger2:
; f�r Menue
                DC.W $00,$80,$ff00,$00,$7e00,$0100,$8000,$00
                DC.W $7c00,$0200,$8000,$00,$7e00,$0100,$8000,$00
                DC.W $7f00,$80,$8000,$00,$7f80,$40,$8000,$00
                DC.W $7fc0,$00,$8000,$00,$4fc0,$3000,$8000,$00
                DC.W $07c0,$4800,$8000,$00,$03c0,$8400,$00,$00
                DC.W $01c0,$0200,$00,$00,$c0,$0100,$00,$00
                DC.W $40,$80,$00,$00


chars8:
                DC.W $fe18,$3c18,$183c,$ffe7,$7e,$1818,$f000,$05a0
                DC.W $7c06,$7c7c,$c67c,$7c7c,$7c7c,$78,$07f0,$1104
                DC.W $fe3c,$241c,$3899,$ffc3,$c3,$3c1c,$c000,$05a0
                DC.W $c606,$0606,$c6c0,$c006,$c6c6,$60,$0ff8,$0b28
                DC.W $fe66,$24f6,$6fc3,$fe99,$d3,$3c16,$fe00,$05a0
                DC.W $c606,$0606,$c6c0,$c006,$c6c6,$3c78,$1fec,$0dd8
                DC.W $fec3,$e783,$c1e7,$fc3c,$d3,$3c10,$d800,$0db0
                DC.W $00,$7c7c,$7c7c,$7c00,$7c7c,$0660,$1804,$0628
                DC.W $fee7,$c383,$c1c3,$f999,$db,$7e10,$de00,$0db0
                DC.W $c606,$c006,$0606,$c606,$c606,$7e7e,$1804,$07d0
                DC.W $fe24,$66f6,$6f99,$f3c3,$c3,$1070,$1800,$1998
                DC.W $c606,$c006,$0606,$c606,$c606,$6618,$1004,$2e10
                DC.W $fe24,$3c1c,$383c,$e7e7,$c3,$38f0,$1800,$799e
                DC.W $7c06,$7c7c,$067c,$7c06,$7c7c,$3c1e,$1e3c,$39e0
                DC.W $fe3c,$1818,$1800,$00,$7e,$1060,$00,$718e
                DC.W $00,$00,$00,$00,$00,$00,$1754,$3800
                DC.W $30,$cc00,$1800,$3818,$0e70,$00,$00,$02
                DC.W $7c18,$fcfc,$c0fe,$7efe,$7c7c,$00,$0600,$603c
                DC.W $30,$cc6c,$3e66,$6c18,$1c38,$6618,$00,$06
                DC.W $c638,$0606,$c0c0,$c006,$c6c6,$1818,$0c00,$3066
                DC.W $30,$ccfe,$606c,$3818,$1818,$3c18,$00,$0c
                DC.W $e678,$0606,$d8c0,$c00c,$c6c6,$1818,$187e,$1806
                DC.W $30,$6c,$3c18,$7000,$1818,$ff7e,$7e,$18
                DC.W $d618,$7c3e,$fefc,$fc18,$7c7e,$00,$3000,$0c0c
                DC.W $30,$6c,$0630,$de00,$1818,$3c18,$00,$30
                DC.W $ce18,$c006,$1806,$c630,$c606,$1818,$1800,$1818
                DC.W $00,$fe,$7c66,$cc00,$1c38,$6618,$3000,$1860
                DC.W $c618,$c006,$1806,$c660,$c606,$1818,$0c7e,$3000
                DC.W $30,$6c,$1846,$7600,$0e70,$00,$3000,$1840
                DC.W $7cfe,$fefc,$18fc,$7cc0,$7c7c,$30,$0600,$6018
                DC.W $00,$00,$00,$00,$00,$00,$6000,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $787c,$fc7c,$fc7e,$7e7e,$c6fe,$fec6,$c082,$867c
                DC.W $fc7c,$fc7e,$fec6,$c6c6,$c6c6,$fe3c,$80f0,$2000
                DC.W $ccc6,$c6c6,$c6c0,$c0c0,$c638,$06cc,$c0c6,$c6c6
                DC.W $c2c6,$c6c0,$38c6,$c6c6,$6c6c,$0e30,$c030,$7000
                DC.W $dcc6,$c6c0,$c6c0,$c0c0,$c638,$06d8,$c0ee,$e6c6
                DC.W $c2c6,$c6c0,$38c6,$c6c6,$3838,$1c30,$6030,$d800
                DC.W $d4fe,$fec0,$c6f8,$f8de,$fe38,$06f0,$c0d6,$d6c6
                DC.W $fcd6,$fc7c,$38c6,$c6d6,$1038,$3830,$3031,$8c00
                DC.W $dcc6,$c6c0,$c6c0,$c0c6,$c638,$06d8,$c0c6,$cec6
                DC.W $c0ca,$d806,$38c6,$6cee,$3838,$7030,$1830,$00
                DC.W $c0c6,$c6c6,$c6c0,$c0c6,$c638,$06cc,$c0c6,$c6c6
                DC.W $c0c4,$cc06,$38c6,$38c6,$6c38,$e030,$0c30,$00
                DC.W $7cc6,$fc7c,$fc7e,$c07c,$c6fe,$fcc6,$7ec6,$c67c
                DC.W $c07a,$c6fc,$387c,$1082,$c638,$fe3c,$04f0,$01fc
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $c000,$c000,$0600,$1e00,$c038,$18c0,$3800,$00
                DC.W $00,$00,$3000,$00,$00,$0e,$1870,$1000
                DC.W $6000,$c000,$0600,$3000,$c000,$cc,$1800,$00
                DC.W $00,$00,$3000,$00,$00,$18,$1818,$3860
                DC.W $307c,$fc7c,$7e7c,$307c,$fc38,$18d8,$18c6,$fc7c
                DC.W $fc7e,$f87e,$78c6,$c6c6,$c6c6,$7e18,$1818,$6cf2
                DC.W $06,$c6c6,$c6c6,$fcc6,$c638,$18f0,$18ee,$c6c6
                DC.W $c6c6,$ccc0,$30c6,$c6c6,$6cc6,$0c30,$180c,$c69e
                DC.W $7e,$c6c0,$c6fc,$30c6,$c638,$18d8,$18d6,$c6c6
                DC.W $c6c6,$c07c,$30c6,$6cd6,$38c6,$1818,$1818,$0c
                DC.W $c6,$c6c6,$c6c0,$307e,$c638,$18cc,$18c6,$c6c6
                DC.W $fc7e,$c006,$30c6,$38ee,$6c7e,$3018,$1818,$00
                DC.W $7e,$fc7c,$7e7e,$3006,$c638,$18c6,$3cc6,$c67c
                DC.W $c006,$c0fc,$1c7c,$10c6,$c606,$7e0e,$1870,$00
                DC.W $00,$00,$00,$30fc,$00,$f000,$00,$00
                DC.W $c006,$00,$00,$00,$fc,$00,$1800,$00

kasten:
                DC.W $ffff,$00,$00,$00,$8001,$00,$00,$00
                DC.W $8001,$00,$00,$00,$8001,$00,$00,$00
                DC.W $8001,$00,$00,$00,$8001,$00,$00,$00
                DC.W $8001,$00,$00,$00,$8001,$00,$00,$00
                DC.W $8001,$00,$00,$00,$8001,$00,$00,$00
                DC.W $8001,$00,$00,$00,$8001,$00,$00,$00
                DC.W $8001,$00,$00,$00,$8001,$00,$00,$00
                DC.W $8001,$00,$00,$00,$8001,$00,$00,$00
                DC.W $8001,$00,$00,$00,$8001,$00,$00,$00
                DC.W $8001,$00,$00,$00,$ffff,$00,$00,$00

kriesldat:
                DC.W $fffd,$fff7,$fdff,$fffb,$bfff,$feff,$fffe,$ffdf
                DC.W $dfff,$7fff,$ffef,$ffbf,$efff,$f7ff,$fbff,$ff7f
                DC.W -1
krieslopcodes:  DC.W $e278,$e478,$e678

removeani1:     INCBIN 'REMOVEAN.IMG'

obenplatte:     INCBIN 'OBENPLAT.IMG'

tilesgrafik:    INCBIN 'TILES.IMG'
weggrafik       EQU tilesgrafik+(43*160)

helpplatten:    INCBIN 'HELPPLAT.IMG'

font:           INCBIN 'FONT2.IMG'

eisplatte:      INCBIN 'EISPLA2.IMG'
buffers:        INCBIN 'GAMEAREA.IMG'

menuplatte:     INCBIN 'MENUPLAT.IMG'

music:          INCBIN 'MATCHIT.MUS'

paket_tabelle:
; hier steht die L�nge der Tastaturpakete in Bytes
                DC.B 6          ; $f7 (absolute Mausposition)
                DC.B 3          ; $f8 - $fb (relative Mausposition)
                DC.B 3          ; $f9
                DC.B 3          ; $fa
                DC.B 3          ; $fb
                DC.B 7          ; $fc (Uhrzeit abfragen)
                DC.B 1          ; $fd (?)
                DC.B 2          ; $fe-$ff (Joystick)
                DC.B 2          ; $ff
                EVEN


fonttabelle:
; in der Tabelle liegen die Positionen der Zeichen im Font, gleich mit
; Gr��e multipliziert (14*10)=140 daher auch Words

                DCB.W 33,46      ; 0-Space
                DC.W 26         ; !
                DC.W 41,46,46,46,46,40,43,44,46,46,42,45,39,46 ; "-/
                DC.W 27,28,29,30,31,32,33,34,35,36 ; 0-9
                DC.W 37,46,46,46,46,38,46 ; : bis @
                DC.W 0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15
                DC.W 16,17,18,19,20,21,22,23,24,25 ; A-Z
fonttabelleende:
fonttabellelaenge EQU fonttabelleende-fonttabelle


welldonetext:   DC.B "WELL DONE!",0
clearedstagetext:DC.B "YOU CLEARED STAGE ",0
scoretext:      DC.B "SCORE     :",0
timebonustext:  DC.B "TIME BONUS:",0
helpbonustext:  DC.B "HELP BONUS:",0
pressbuttontext:DC.B "HIT BUTTON TO GO ON!",0
gameovermess:   DC.B "GAME OVER",0
checkmatedmess: DC.B "CHECKMATED!",0
timeoutmess:    DC.B "TIME OUT!",0
gamesolvedmess: DC.B "GAME SOLVED!",0
madehighscoretext:DC.B "NEW HIGHSCORE!",0
onplacetext:    DC.B "YOU ARE ON PLACE",0
enternametext:  DC.B "NOW ENTER YOUR NAME:",0
defaultname:    DC.B "MR RETURN ",0
stage64text:    DC.B "YOU SOLVED THE GAME!",0
bonus64text:    DC.B "SOLUTION BONUS: 5000",0


instrtext1:     DC.B "****************",0
                DC.B "* INSTRUCTIONS *",0
                DC.B "****************",0
                DC.B "MATCH-IT! is a game very similiar to",0
                DC.B "'Shanghai'. Your target is to remove",0
                DC.B "all tiles from a gameboard.",0
                DC.B "This sounds easy, but there's a time-",0
                DC.B "limit that makes the game very hard.",0
                DC.B "You can select tiles by clicking on",0
                DC.B "them with the left mousebutton.",0
                DC.B "Deselect them with right mousebutton.",0
                DC.B "You just can remove two similiar tiles",0
                DC.B "and the connection line just can have",0
                DC.B "two corners and must be on free area.",0
                DC.B "There are some special tiles:",0
                DC.B "FLOWERS AND SEASONS",0
                DC.B "You can remove every flower with every",0
                DC.B "flower (the same with seasons).",0
                DC.B "Flowers and Seasons stop the timer for",0
                DC.B "some seconds.",0
                DC.B " ",0
                DC.B "PRESS MOUSE-BUTTON TO GO TO NEXT PAGE!",0
                DC.B -1

instrtext2:     DC.B "To make the game easier, there is a",0
                DC.B "HELP-option. At the beginning of the",0
                DC.B "game you have two helps. If you need",0
                DC.B "help, just press on the HELP-KEY.",0
                DC.B "If you completed a level without",0
                DC.B "using the helpfunction, you get",0
                DC.B "one help for free. All helps left",0
                DC.B "will be added to your score at the",0
                DC.B "end of each stage, so think when",0
                DC.B "using them.",0
                DC.B " ",0
                DC.B "Possible keys during game:",0
                DC.B "-P-         Pause game (try this) ",0
                DC.B "-HELP-      Get help from computer",0
                DC.B "-ESC-       Abort game            ",0
                DC.B "-M-         Toggle Music on/off   ",0
                DC.B " ",0
                DC.B "PRESS MOUSE-BUTTON TO GO TO MENU!",0
                DC.B -1


scrolltext:
		DC.B "      WELCOME TO MATCH-IT!    THIS GAME IS"
		DC.B " BUDGIE LICENCEWARE!    IT WAS WRITTEN BY"
		DC.B " NEW MODE (CODING), SLIME (GRAPHICS) AND BIG ALEC"
		DC.B " (MUSIC).     HIGHSCORES WILL BE SAVED ON DISK!"
		DC.B "  SO NOW HAVE FUN WITH THIS GAME!!!!    BYE!"
		DC.B "           ",0

                EVEN

menutext1:      DC.B "START GAME",0
menutext2:      DC.B "SEE HIGHSCORES",0
menutext3:      DC.B "INSTRUCTIONS",0
menutext4:      DC.B "QUIT",0
menutext0:      DC.B "MATCH-IT !",0
savemess:       DC.B "SAVING HIGHSCORES!",0
wpmess:         DC.B " ",0
                DC.B " ",0
                DC.B "CAN'T SAVE SCORES",0
                DC.B " ",0
                DC.B "YOUR DISK IS",0
                DC.B "WRITEPROTECTED....",0
                DC.B " ",0
                DC.B "SPACE TO TRY AGAIN",0
                DC.B "OR -ESC- TO CANCEL",0,-1
                EVEN

filename:	DC.B "HIGHSCOR.ES",0
		EVEN

highscores2:
                DC.W 1000
                DC.B 'NEW MODE  '
                DC.W 900
                DC.B 'SLIME     '
                DC.W 800
		DC.B 'BIG ALEC  '
		DC.W 700
                DC.B 'GRIFF     '
                DC.W 600
                DC.B 'DELTAFORCE'
                DC.W 500
                DC.B 'FRONT 242 '
                DC.W 400
                DC.B 'KRAFTWERK '
                DC.W 300
                DC.B 'NITZER EBB'
                DC.W 200
                DC.B 'THE SHAMEN'
                DC.W 100
                DC.B 'THE CURE  '
                DS.B 512-120
                EVEN

budgie_pal:
		dc.w	$0000,$0200,$0300,$0410,$0520,$0631,$0742,$0753
		dc.w	$0764,$0775,$0776,$0777,$0000,$0000,$0000,$0777

budgie_pic:	INCBIN 'BUDGIE.IMG'


                BSS
; ---------- System -------------
ssp:            DS.L 1          ; alter Supervisor Stack
hbl_buff:       DS.L 5          ; alte Interruptwerte
oldpal:         DS.L 8          ; alte Palette (16 Werte)
oldstack:       DS.L 1
leerfeld:       DS.L 8
oldscreen:	DS.L 1
oldres:		DS.W 1
old_vbl:	DS.L 1
; ------------- Variable --------------
leveltab:       DS.B 64         ; dort sind die Levelnummern zufallsm. verteilt
highscoremade:  DS.W 1          ; ist Highscore gemacht worden?
keycounter:     DS.W 1
keybuffer:      DS.B 8          ; dort werden die Pakete abgelegt
keypointer:     DS.L 1          ; jeweils ein Pointer auf die Daten

palpointer1:    DS.L 1          ; Palettenpointer f�r Raster
palpointer2:    DS.L 1
savepalpoint1:  DS.L 1          ; dort wird Pointer gerettet
savepalpoint2:  DS.L 1          ; dort wird Pointer gerettet
blinkpos:       DS.L 1          ; Pointer f�r blinkenden Kasten
blinkanaus:     DS.W 1          ; 0=Blinken aus, 1=Blinken an
blinkdelay:     DS.W 1          ; Verz�gerer f�r Blinken
screennumm:     DS.W 1          ; dort steht aktuelle ScreenNr.
weg:            DS.B 18*8       ; Dort wird der Weg gespeichert
matchitbuff2:   DS.B 20*10
matchitbuff:    DS.B 18*8       ; Dort sind die Tiles abgelegt
workbuff:       DS.B 18*8       ; Dort drin wird gearbeitet
posbuff:        DS.B 16*6       ; Die Positionen der Tiles
anzahl:         DS.W 1          ; Schleifenz�hler
mousek:         DS.W 1          ; Maustaste
mousex:         DS.W 1          ; Mauskoordinaten
mousey:         DS.W 1
hilfspalette1:  DS.L 8          ; Palette 1 w�hrend Pause
hilfspalette2:  DS.L 8          ; Palette 2 w�hrend Pause
musicflag:      DS.W 1          ; 0 oder 1
rettbuff:       DS.B 212        ; Rettbuffer f�r Maus
counter1:       DS.W 1          ; Zwischenvariable zum Z�hlen
counter2:       DS.W 1          ; daselbe f�r Port 0
textpos:        DS.L 1          ; Position im Scrolltext
mempos:         DS.L 1          ; Position im Fontbuffer
mousepointer:   DS.L 1          ; Zeiger auf Grafik f�r Mauszeiger
zeichen:        DS.W 1          ; soviel schon gescrollt
endeflag:       DS.W 1          ; dort wird Ende angezeigt
regs1:          DS.L 3          ; Register f�r L�schroutine
regs2:          DS.L 3          ; Register f�r L�schroutine
xpos1:          DS.W 1          ; Koord. im Feld
ypos1:          DS.W 1
level:          DS.W 1          ; aktueller Level
paaranzahl:     DS.W 1          ; Anzahl der Paare auf dem Feld
helpcount:      DS.W 1          ; Anzahl der Helps
blumjzverz:     DS.W 1          ; Verz�gerung durch Blume, etc.
blumjzverz2:    DS.W 1          ; Hilfs-Verz�gerung f�r Blume
kasten1aktiv:   DS.W 1          ; Kasten 1 an/aus Flag

time:           DS.W 1          ; Zeit Spieler1
timeverzoegerung:
                DS.W 1          ; Werte von 70-20
highscoreplatz: DS.W 1
namebuff:       DS.B 22
score:          DS.W 1          ; Punkte!
stage:          DS.W 1
scrollready:    DS.W 1
scrollsavebuff: DS.B 15*160
helpverbraucht: DS.W 1          ; 0= Keins verbraucht,1=verbraucht
helpbonus:      DS.W 1          ; Restliche Helps * 100
timestop:       DS.W 1          ; Zeit anhalten=1 sonst 0
readycount:     DS.W 1          ; Z�hler f�r Scrolling
vblcount:       DS.W 1          ; Z�hlvariable
tile1selektx:   DS.W 1          ; X-Koord. des 1. Tiles
tile1selekty:   DS.W 1          ; Y-Koord. des 1. Tiles
tile2selektx:   DS.W 1          ; X-Koord. des 2. Tiles
tile2selekty:   DS.W 1          ; Y-Koord. des 2. Tiles
tile1selektpos: DS.B 1          ; Pos. des 1. Tiles
tile2selektpos: DS.B 1          ; Pos. des 2. Tiles
cheatmode:      DS.L 1          ; Pos. f�r Cheatmode
cheatpoint:     DS.L 1          ; dort Cheatmode
hexdezbuff:     DS.B 6          ; 6 Zahlen
hexdezbuff2:    DS.B 6          ; f�r Retten
fontbuff:       DS.B 47*15*10   ; 47 Zeichen*15 Scanlines*10 Bytes
wege:           DS.B 20*10*200
highscores:     DS.B 512
                DS.B 512
screenbase:     DS.B 32000*4    ; Platz f�r 4 Screen
                DS.B 20000      ; 20 Kilo Stack gen�gt!
stack:
                END
