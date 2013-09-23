************************************************************
***                                                      ***
***  SUKKASCREEN (WUCHTSCREEN) FOR DELTA FORCE DEMO      ***
***  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~     ***
***     WRITTEN BY NEW MODE - GRAPHIXX BY SLIME          ***
***                                                      ***
***             CURRENT DATE: 09.12.90                   ***
***                                                      ***
************************************************************
; SEKA-Assembler

diskversion=0           ; 0=Developer/1=Diskversion

IF      diskversion=0
        offset=$80000
ELSE
        offset=0
ENDIF

org     $1000+offset
load    $81000

of=$80000

screenbase=$70000+offset        ; Adressen der Screens
shiftbuff=$48000+offset         ; Dorthin wird der Grafikblock geshiftet
logobuff=$43b60+offset          ; Dorthin wird das Logo geshiftet
shapebuff=$3e160+offset         ; Dorthin werden die Shapes geshiftet
scrollbuff=$27960+offset        ; Dort werden die Buchstaben hingeshiftet
scrollbuffer=$276e0+offset      ; In diesem Bereich wird gescrollt
sinusdata=$26000+offset
scanzahl=60                     ; Anzahl der Buchstaben im Zeichensatz

;madmax2.img nach music
;chars.img nach charset
;sinedata.img nach sinus
;text.img nach text



s:      IF      diskversion=0

	lea	textfile(pc),a0
	lea	text(pc),a6
	bsr	load
	lea	musicfile(pc),a0
	lea	music(pc),a6
	bsr	load
	lea	charfile(pc),a0
	lea	charset(pc),a6
	bsr	load
	lea	sinusfile(pc),a0
	lea	sinus(pc),a6
	bsr	load

        movem.l $fffff8240.w,d0-d7
        movem.l d0-d7,oldpalette        ; Palette retten

        clr.b   $ffff8260.w             ; Lowres
        move.b  #2,$ffff820a.w          ; 50Hz

        ENDIF

	lea	$ffff8240.w,a0
	moveq	#7,d0
clrpal:	clr.l	(a0)+
	dbra	d0,clrpal

	lea	sinusdata-$1000,a0
	lea	sinusdata+$1000,a1
clrsin:	clr.l	(a0)+
	cmp.l	a0,a1
	bne.s	clrsin

	lea	sinus,a0
	lea	sinusdata,a1
	move.w	#511,d0
copysin:move.b	(a0)+,(a1)+
	dbra	d0,copysin

        move.l  #screenbase,oldscreen    ; Beide Arbeitsbildschirme setzen
        move.l  #screenbase+$8000,newscreen



        move.l  oldscreen(pc),a0
        move.l  newscreen(pc),a1
        move.w  #7999,d0
cls:    clr.l   (a0)+
        clr.l   (a1)+                     ; Beide Screens lîschen
        dbra    d0,cls

	move.l	oldscreen(pc),d0
	bsr	setscreen

        lea     shapes,a0
        lea     24(a0),a1
        moveq   #9,d1                     ; 10 Shapes
mkol0:  moveq   #11,d0
mkol1:  move.w  (a1)+,d2                 ; Shapes vorbereiten
        not.w   d2                        ; (Rahmen generieren)
        and.w   d2,(a0)+
        dbra    d0,mkol1
        lea     24(a0),a0
        lea     24(a1),a1
        dbra    d1,mkol0


        bsr     ps                          ; Preshiften des Grafikblocks
        bsr     preshift                    ; Preshiften des Logos
        bsr     preshift_sh                 ; Preshiften der Shapes
        bsr     makescroll                  ; Scroller preshiften        

        lea     scrollbuffer,a0             ; Lîschen des Scrollbuffers
        move.w  #[16*20]-1,d0
clrsb:  clr.w   (a0)+
        dbra    d0,clrsb

                                          ; Werte setzen:
        move.l  #ldelta,ldpos             ; Logo
        move.l  #delta,dpos2              ; Hintergrund 
        clr.w   colfadecount              ; FarbzÑhler fÅr abblenden
        clr.w   nixfade
        move.l  #rdelta,rdpos             ; Haupt -> Hintergrund
        move.l  #rastdelta,rastdpos       ; fÅr Raster
        clr.w   scrollstop                ; Scroller an

        moveq   #1,d0
        bsr     music                     ; Musik initialisieren
        
        clr.b   key

        bsr     hbl_on                    ; Raster anschalten

mainloop:
        move.b  key,d0
        cmp.b   #$39,d0                   ; auf Space warten
        bne.s   mainloop

ende:   
        bsr     hbl_off                             ; Raster abschalten

        lea     $ffff8800.w,a1          ; BLANK SOUNDCHIP
        move.l  #$8080000,(a1)
        move.l  #$9090000,(a1)
        move.l  #$A0A0000,(a1)

        IF      diskversion=0
        move.b  #0,$ffff820a.w          ; 60HZ
        move.b  #1,$ffff8260.w
        movem.l oldpalette,d0-d7            ; alte Farben zurÅck
        movem.l d0-d7,$fffffff8240.w
        move.l  #$3f8000,d0
        bsr     setscreen
        illegal
        ELSE
        moveq   #0,d0
        jmp     $500.w
        ENDIF        


drawshapes:
        lea shapebuff,a6                        ; geshiftete Shapedaten
        lea shapekoord,a5                   ; X- und Y-Koordinaten
        moveq #9,d7                             ; 10 Shapes
ml1:    moveq #0,d0                             ; wegen MULU
        moveq #0,d1                             ; wegen MULU
        move.w (a5)+,d0                         ; X holen
        move.w (a5)+,d1                         ; Y holen
        mulu #160,d1                            ; Y mal 160
        ror.l #4,d0                             ; X/16
        lsl.w #3,d0                             ; Ergebnis*8-> Bitblock
        move.l oldscreen(pc),a0                 ; Bildschirmadresse
        add.w d0,a0                             ; Beide Werte addieren
        add.l d1,a0
        clr.w d0                                ; Lowword lîschen
        rol.l #4,d0                             ; Rest von X/16
        mulu #144,d0                            ; Rest*Grîûe eines Shapes
        move.l a6,a2                            ; Shapeadresse
        add.l d0,a2                             ; aktuelle Adresse Shapes
        moveq #5,d0                             ; 2*6=12 Zeilen
ml0:    move.l (a2)+,d1                         ; Maskenwert Bitblock1
        move.l (a2)+,d2                         ; Maskenwert Bitblock2
        move.w (a2)+,d3                         ; Oderwert 1
        move.w (a2)+,d4                         ; Oderwert 2
        and.l d1,(a0)                           ; Maske aus-anden
        and.l d1,4(a0)
        or.w d3,6(a0)                           ; in Plane 4 einodern
        and.l d2,8(a0)                          ; Maske aus-anden
        and.l d2,12(a0)
        or.w d4,14(a0)                          ; in Plane 4 einodern
        move.l (a2)+,d1
        move.l (a2)+,d2                         ; Ditto fÅr Zeile 2
        move.w (a2)+,d3
        move.w (a2)+,d4
        and.l d1,160(a0)
        and.l d1,164(a0)
        or.w d3,166(a0)
        and.l d2,168(a0)
        and.l d2,172(a0)
        or.w d4,174(a0)
        lea 320(a0),a0                          ; Zwei Zeilen tiefer
        dbra d0,ml0
        lea 2304(a6),a6                         ; nÑchste Shapedaten
        dbra d7,ml1
        rts

ps:
; 64 mal den Block durchshiften und hinten immer neues reinschieben
; 2*untereinander kopieren
; immer vorige Zeile nehmen und um 1 nach links schieben
; in a1=Buffer
; in a0=Pointer auf altes geshiftetes

        lea shiftbuff,a1
        lea block,a0
        lea 40*32(a1),a2        ; zuerst mal 0 geshiftet kopieren
        moveq #39,d0            ; 40 Zeilen
copybl: movem.l (a0)+,d1-d7/a3
        movem.l d1-d7/a3,(a1)
        movem.l d1-d7/a3,(a2)
        lea 32(a1),a1
        lea 32(a2),a2
        dbra d0,copybl

        lea shiftbuff,a0        ; altes geshiftetes
        move.l a2,a1            ; Shiftbuffpointer -> dorthin
        lea 32*40(a1),a2
        moveq #63,d0            ; 64 mal shiften
psl0:   moveq #39,d1            ; 40 Zeilen
psl1:   moveq #3,d4             ; 4 Planes      
psl2:   moveq #0,d2
        move.w (a0),d2          ; Wert holen
        ror.l #1,d2
        move.w d2,(a1)
        move.w d2,(a2)
        swap d2
        move.w d2,d3            ; Rest
        moveq #0,d2
        move.w 8(a0),d2         ; Wert holen BB2
        ror.l #1,d2
        or.w d3,d2
        move.w d2,8(a1)
        move.w d2,8(a2)
        swap d2
        move.w d2,d3
        moveq #0,d2
        move.w 16(a0),d2        ; Wert holen BB3
        ror.l #1,d2
        or.w d3,d2
        move.w d2,16(a1)
        move.w d2,16(a2)
        swap d2
        move.w d2,d3
        moveq #0,d2
        move.w 24(a0),d2        ; Wert holen BB3
        ror.l #1,d2
        or.w d3,d2
        move.w d2,24(a1)
        move.w d2,24(a2)
        swap d2
        or.w d2,(a1)+           ; vorne einodern
        or.w d2,(a2)+           ; vorne einodern
        lea 2(a0),a0            ; nÑchste Plane
        dbra d4,psl2
        lea 24(a2),a2
        lea 24(a1),a1
        lea 24(a0),a0
        dbra d1,psl1
        move.l a2,a1
        lea 32*40(a1),a2
        lea 32*40(a0),a0
        dbra d0,psl0
        rts

preshift:
; shiftet Logo
        lea logobuff,a1
        moveq #0,d0
pssl0:  lea dflogo(pc),a0
        move.w #$3c,d1
pssl1:  moveq #7,d2
        moveq #0,d4
pssl2:  moveq #0,d3
        move.w (a0)+,d3
        ror.l d0,d3
        or.w d4,d3
        move.w d3,(a1)+
        swap d3
        move.w d3,d4
        dbra d2,pssl2
        move.w d4,(a1)+
        dbra d1,pssl1
        addq.w #1,d0
        cmp.w #16,d0
        bne.s pssl0
        rts

preshift_sh:
; Preshiftet Shapes
        lea shapes(pc),a5                       ; Datas
        lea 24(a5),a6                           ; Maske
        lea shapebuff,a2
        moveq #9,d0                             ; 10 Shapes
psssl0: moveq #0,d1
psssl1: moveq #0,d2
        moveq #11,d5                            ; 12 Zeilen
        move.l a5,a0
        move.l a6,a1
psssl2: moveq #0,d2
        move.w (a0)+,d2                         ; Maskenwert holen
        ror.l d1,d2
        move.w d2,d3
        not.w d3
        move.w d3,d2
        swap d3
        move.w d2,d3
        move.l d3,(a2)+
        swap d2
        move.w d2,d3
        not.w d3
        move.w d3,d2
        swap d3
        move.w d2,d3
        move.l d3,(a2)+                         ; Maskenwert longs
        moveq #0,d2
        move.w (a1)+,d2
        ror.l d1,d2
        move.w d2,(a2)+
        swap d2
        move.w d2,(a2)+
        dbra d5,psssl2
        addq.w #1,d1
        cmp.w #16,d1
        bne.s psssl1
        lea 48(a5),a5
        lea 48(a6),a6
        dbra d0,psssl0
        rts

		IF	diskversion=0
load:           clr.w -(a7)
                pea (a0)
                move.w #$3d,-(a7)
                trap #1
                addq.l #8,a7
                move.w d0,-(a7)
                pea (a6)
                move.l #$dfdfdf,-(a7)
                move.w d0,-(a7)
                move.w #$3f,-(a7)
                trap #1
                lea 12(a7),a7
                move.w #$3e,-(a7)
                trap #1
                addq.l #4,a7
                rts
sinusfile:	dc.b	"sinedata.img",0
musicfile:	dc.b	"madmax2.img",0
charfile:	dc.b	"chars.img",0
textfile:	dc.b	"text.img",0
		even
		ENDIF

switch: 
        move.l  oldscreen(pc),d0
        move.l  newscreen(pc),oldscreen
        move.l  d0,newscreen
setscreen:
        lsr.l   #8,d0
        move.b  d0,$ffff8203.w
        lsr     #8,d0
        move.b  d0,$ffff8201.w
        rts


scroll2:macro
         moveq #0,d1
         move.w (a0),d1      ; vom Quellbildschirm
         lsl.l #scrollspeed,d1 ; um Anzahl von Bits nach links schieben
         or.w d0,d1          ; alten Rest einodern
         move.w d1,(a0)      ; abspeichern auf Zielbildschirm
         swap d1             ; Hiword <-> Lowword
         move.w d1,d0        ; Herausgeschobenes merken
         subq.w #2,a0        ; nÑchste Bitplane Quellscr.
        endm

makescroll:
        bsr scrpreshift
        move.w #48,spos
        move.l #text,textpos
        move.w #2,speed
        move.l #scrdelta,scrdpos
        rts

sincopy:macro
; 20 mal aufrufen! und Scroller ist auf Screen!
; in a0=Scrollbuffer
;    a1=Screen
; in a2=Sinustabelle
        move.w (a2)+,d0
        move.l a1,a3
        add.w d0,a3                     ; Sinuswert auf Screen addieren
        move.b (a0),(a3)
        move.b 40(a0),160(a3)
        move.b 80(a0),320(a3)
        move.b 120(a0),480(a3)
        move.b 160(a0),640(a3)
        move.b 200(a0),800(a3)
        move.b 240(a0),960(a3)
        move.b 280(a0),1120(a3)
        move.b 320(a0),1280(a3)
        move.b 360(a0),1440(a3)
        move.b 400(a0),1600(a3)
        move.b 440(a0),1760(a3)
        move.b 480(a0),1920(a3)
        move.b 520(a0),2080(a3)
        move.b 560(a0),2240(a3)
        move.b 600(a0),2400(a3)
        lea 1(a0),a0
        lea 1(a1),a1
        move.w (a2)+,d0
        move.l a1,a3
        add.w d0,a3                     ; Sinuswert auf Screen addieren
        move.b (a0),(a3)
        move.b 40(a0),160(a3)
        move.b 80(a0),320(a3)
        move.b 120(a0),480(a3)
        move.b 160(a0),640(a3)
        move.b 200(a0),800(a3)
        move.b 240(a0),960(a3)
        move.b 280(a0),1120(a3)
        move.b 320(a0),1280(a3)
        move.b 360(a0),1440(a3)
        move.b 400(a0),1600(a3)
        move.b 440(a0),1760(a3)
        move.b 480(a0),1920(a3)
        move.b 520(a0),2080(a3)
        move.b 560(a0),2240(a3)
        move.b 600(a0),2400(a3)
        lea 1(a0),a0
        lea 7(a1),a1
        endm

scrcopy:macro
; erledigt einodern+reinmoven der Grafikblîcke
        movem.w (a0)+,d0-d5                     ; 6 Werte holen
        or.w d0,(a1)+
        move.w d1,(a1)+
        move.w d2,(a1)+
        lea 34(a1),a1
        or.w d3,(a1)+
        move.w d4,(a1)+
        move.w d5,(a1)+
        lea 34(a1),a1
        endm


scrollline: 
        tst.w scrollstop
        beq.s nixscrollstop                     ; Scroller an
        subq.w #1,scrollstop
        bra scl0
nixscrollstop:
        move.w speed,d0
        add.w d0,spos
        cmp.w #32,spos                           ; schon 32 Pixel ?
        blt.L scl0
        clr.w spos                              ; 0 Pixel
        move.l textpos(pc),a0                   ; Position in Abfolgetab.
        cmp.b #60,(a0)
        blt.s scpm0_1                           ; kein Speedwert
        moveq #0,d0
        move.b (a0)+,d0
        sub.b #60,d0                            ; Werte von 0-4
        lsl.w #1,d0                             ; *2 -> Wortwerte
        lea spdtab(pc),a2
        move.w 0(a2,d0.w),speed                 ; neuer Speedwert
        tst.w d0
        bne.s scpm0_1                           ; keine 0 Geschwind.
        moveq #0,d0
        move.b (a0)+,d0                         ; Zahlenwert holen
        sub.b #27,d0
        lsl.w #5,d0                             ; *32
        move.w d0,scrollstop
scpm0_1:
        cmp.b #-1,(a0)                          ; Ende der Tabelle?
        bne.s scpm0
        lea text(pc),a0                         ; Anfang der Tabelle
scpm0:  move.l a0,textpos
        addq.l #1,textpos
        lea pointers(pc),a1                     ; Pointer Tabelle
        lea scrolltable(pc),a2                  ; Pointer auf Adressen
        moveq #10,d7                            ; 11 Blocks
scpm1:  moveq #0,d0
        cmp.b #-1,(a0)                          ; Ende?
        bne.s scpm2
        lea text(pc),a0
scpm2:  move.b (a0)+,d0                         ; Wert aus Tabelle
        cmp.b #60,d0                            ; ist Speedwert?
        bgt.s scpm2                             ; auffiltern
        cmp.b #60,d0
        bne.s scpm2_1
        lea 1(a0),a0                            ; Wenn 0 Zeichen dann +1
        bra scpm2
scpm2_1:        
        lsl.w #2,d0                             ; *4
        move.l 0(a2,d0.w),(a1)+                 ; Pointer holen
        dbra d7,scpm1

scl0:   
        lea scrollbuffer,a6

        lea pointers(pc),a5
        move.w spos,d0                           ; in d0=Pixel
        cmp.w #16,d0                             ; fuer ersten Block
        bge.L scl1                              ; nur rechte HÑlfte
        mulu #96,d0                             ; Block ermitteln
        move.l (a5)+,a0
        add.w d0,a0                             ; jetzt Pointer auf Block
        lea 2(a0),a0                            ; wegen rechter HÑlfte
        move.l a6,a1                            ; Screen
        moveq #15,d7                            ; 16 Zeilen
scfol0: move.w (a0)+,(a1)+
        move.w (a0)+,(a1)+
        lea 2(a0),a0                            ; wegen rechter HÑlfte
        lea 36(a1),a1
        dbra d7,scfol0
        lea 2(a6),a6                            ; Screenpointer +8
        bra.s scl2                              ; Weiter bei Scl2
scl1:   sub.w #16,d0                             ; Fall2: -16
        mulu #96,d0
        move.l (a5)+,a0
        add.w d0,a0
        lea 4(a0),a0                            ; wegen ganz rechts
        move.l a6,a1
        moveq #15,d7                            ; 16 Zeilen
scfol1: move.w (a0)+,(a1)
        lea 4(a0),a0
        lea 40(a1),a1
        dbra d7,scfol1
                                                ; Kein Offset auf Screen
scl2:   moveq #8,d7                             ; 9 Blocks
        move.w d0,d6                            ; in d6=Offset auf Adr.
scl3:   move.l (a5)+,a0                         ; Adresse
        add.w d6,a0
        move.l a6,a1                            ; Screen
        scrcopy
        scrcopy
        scrcopy
        scrcopy
        scrcopy
        scrcopy
        scrcopy
        scrcopy
        lea 4(a6),a6                           ; Screenpointer+16
        dbra d7,scl3    
        
        move.w spos(pc),d0
        cmp.w #16,d0     
        bge.s scrl2                             ; 16er 
        mulu #96,d0                             ; Block ganz rechts
        move.l (a5)+,a0
        add.w d0,a0                             
        move.l a6,a1                            ; Screen
        moveq #15,d7                            ; 16 Zeilen
scrl0:  move.w (a0)+,d0
        or.w d0,(a1)
        lea 4(a0),a0                            ; linke HÑlfte einodern
        lea 40(a1),a1
        dbra d7,scrl0
        bra.s scl4
scrl2:  sub.w #16,d0                            ; Zweiter Teil
        mulu #96,d0                            ; Block ganz rechts
        move.l (a5)+,a0
        add.w d0,a0                             
        move.l a6,a1                            ; Screen
        moveq #15,d7                            ; 16 Zeilen
scrl1:  move.w (a0)+,d0
        or.w d0,(a1)+
        move.w (a0)+,(a1)+
        lea 2(a0),a0                            ; linke HÑlfte einodern
        lea 36(a1),a1
        dbra d7,scrl1
                                
scl4:   addq.l #2,scrdpos
        move.l scrdpos(pc),a2
        cmp.l #deltaende,a2
        blt.s nixendesdelta
        lea scrdelta(pc),a2
nixendesdelta:
        move.l a2,scrdpos
   
        move.l oldscreen(pc),a1
        lea 6(a1),a1
        lea 173*160(a1),a1
        lea scrollbuffer,a0
        sincopy
        sincopy
        sincopy
        sincopy
        sincopy
        sincopy
        sincopy
        sincopy
        sincopy
        sincopy
        sincopy
        sincopy
        sincopy
        sincopy
        sincopy
        sincopy
        sincopy
        sincopy
        sincopy
        sincopy

        rts


        
                                        
scrpreshift:
; Preshift der Grafikbloecke
; erledigt alles was mit den Grafikblîcken zusammenhÑngt
; - Scrolltabelle

        lea scrolltable,a3                      ; Adr. der Blocks
        lea charset,a2                          
        lea scrollbuff,a1
        moveq #0,d6                             ; Anzahl der Blîcke
psbl0:  move.l a1,(a3)+                         ; in Scrolltable
        moveq #15,d2
psbl1:  move.l a2,a0                            ; Adresse des Blocks                            
        moveq #15,d7                            ; 16 Zeilen
psbl2:  moveq #0,d0
        move.w (a0)+,d0
        ror.l d2,d0
        move.w d0,(a1)+
        swap d0
        move.w d0,d1
        moveq #0,d0
        move.w (a0)+,d0
        ror.l d2,d0
        or.w d1,d0
        move.w d0,(a1)+
        swap d0
        move.w d0,(a1)+
        dbra d7,psbl2
        subq.w #1,d2
        bpl psbl1
        lea 16*4(a2),a2                         ; nÑchster Block
        addq.w #1,d6
        cmp.w #scanzahl,d6
        bne psbl0
        rts

scrdelta:
; Sinus fÅr Laufschrift
      dc.w 960,960,960,1120,1120,1280,1280,1280,1440,1440
      dc.w 1440,1600,1600,1600,1600,1760,1760,1760,1760,1760
      dc.w 1760,1760,1760,1760,1760,1760,1760,1760,1760,1760
      dc.w 1760,1600,1600,1600,1600,1440,1440,1440,1280,1280
      dc.w 1280,1120,1120,960,960,960,800,800,640,640
      dc.w 480,480,480,320,320,320,160,160,160,160
      dc.w 0,0,0,0,0,0,0,0,0,0
      dc.w 0,0,0,0,0,0,160,160,160,160
      dc.w 320,320,320,480,480,480,640,640,800,800
deltaende:
      dc.w 960,960,960,1120,1120,1280,1280,1280,1440,1440
      dc.w 1440,1600,1600,1600,1600,1760,1760,1760,1760,1760
      dc.w 1760,1760,1760,1760,1760,1760,1760,1760,1760,1760
      dc.w 1760,1600,1600,1600,1600,1440,1440,1440,1280,1280
      
wuchtlogo:
        moveq #0,d0                             ; wegen Highword
        moveq #0,d1
        move.w logox(pc),d0                     ; Koordinate X
        move.w logoy(pc),d1                     ; Koordinate Y
        ror.l #4,d0                             ; X/16
        lsl.w #3,d0                             ; Ergebnis mal 8
        mulu #160,d1                            ; Y*160
        add.w d0,d1                             ; beide Werte addieren
        move.w #0,d0                            ; Lowword lîschen
        rol.l #4,d0                             ; Rest von X/16
        mulu #1098,d0                           ; mal Grîûe eines Shapes
        lea logobuff,a0                         ; Dort steht Logo
        add.w d0,a0                             ; neue Adresse
        move.l oldscreen(pc),a1                 ; Screenadresse
        lea 6(a1),a1                            ; wegen Plane 4
        add.w d1,a1                             ; Werte aufaddieren
        move.w #$3c,d0                          ; Hîhe=$3d=61
wl:     move.w (a0)+,(a1)                       ; 9 Bitblocks kopieren
        move.w (a0)+,8(a1)
        move.w (a0)+,16(a1)
        move.w (a0)+,24(a1)
        move.w (a0)+,32(a1)
        move.w (a0)+,40(a1)
        move.w (a0)+,48(a1)
        move.w (a0)+,56(a1)
        move.w (a0)+,64(a1)
        lea 160(a1),a1                          ; eine Zeile tiefer
        dbra d0,wl
        rts


scroll:
; Hintergrundscrolling

        lea shiftbuff,a0                        ; dort stehen prehift.Datas
        move.w x(pc),d0                         ; X-Wert des Scrollers         
        and.l #63,d0                            ; nur Bits 0-6 (X=0-63)
        mulu #2*32*40,d0                        ; mal Grîûe eines Blocks
        add.l d0,a0                             ; aufaddieren
        
        moveq #0,d0
        move.w y(pc),d0                         ; Y-Wert
        divu #40,d0                             ; Y/40->nur Werte von 0-39
        swap d0                                 ; Rest von Y/40
        lsl.w #5,d0                             ; *32 -> damit Offset im
        add.w d0,a0                             ; Block selber


        move.l oldscreen(pc),a3                 ; Bildschirmadresse
        lea 161*160(a3),a3                      ; letzte Zeile der Blîcke
        moveq #39,d0                            ; Block=40 Zeilen
scroll1:move.l a3,a1
        movem.l (a0)+,d1-d7/a2          ; eine Zeile des Blocks holen
        movem.l d1-d7/a2,-(a1)          ; einige Male auf Screen kopieren
        movem.l d1-d7/a2,-(a1)
        movem.l d1-d7/a2,-(a1)
        movem.l d1-d7/a2,-(a1)
        movem.l d1-d7/a2,-(a1)
        lea -39*160(a1),a1
        movem.l d1-d7/a2,-(a1)
        movem.l d1-d7/a2,-(a1)
        movem.l d1-d7/a2,-(a1)
        movem.l d1-d7/a2,-(a1)
        movem.l d1-d7/a2,-(a1)
        lea -39*160(a1),a1
        movem.l d1-d7/a2,-(a1)
        movem.l d1-d7/a2,-(a1)
        movem.l d1-d7/a2,-(a1)
        movem.l d1-d7/a2,-(a1)
        movem.l d1-d7/a2,-(a1)
        lea -39*160(a1),a1
        movem.l d1-d7/a2,-(a1)
        movem.l d1-d7/a2,-(a1)
        movem.l d1-d7/a2,-(a1)
        movem.l d1-d7/a2,-(a1)
        movem.l d1-d7/a2,-(a1)
        lea -39*160(a1),a1
        movem.l d1-d7/a2,-(a1)
        movem.l d1-d7/a2,-(a1)
        movem.l d1-d7/a2,-(a1)
        movem.l d1-d7/a2,-(a1)
        movem.l d1-d7/a2,-(a1)
        lea 160(a3),a3
        dbra d0,scroll1
        rts



hbl_on:         move    sr,-(a7)
                ori     #$0700,sr
                lea     hbl_buff(pc),a0
                move.b  $fffffa09.w,(a0)+       ; Werte retten
                move.b  $fffffa07.w,(a0)+
                move.b  $fffffa13.w,(a0)+
                move.b  $fffffa1b.w,(a0)+
                move.b  $fffffa11.w,(a0)+
                move.b  $fffffa21.w,(a0)+
                move.b  $fffffa17.w,(a0)+
                move.b  $fffffa15.w,(a0)+
                move.l  $0118.w,(a0)+
                move.l  $0120.w,(a0)+
                move.l  $70.w,(a0)+
                andi.b  #$df,$fffffa09.w        ; Timer C aus
                andi.b  #$fe,$fffffa07.w        ; Timer B aus
                move.l  #newkey,$0118.w
                move.l  #vbl,$70.w
                move.l  #hbl,$0120.w
                ori.b   #1,$fffffa07.w          ; Timer B an
                ori.b   #1,$fffffa13.w
                bclr    #3,$fffffa17.w          ; automatic EOI
                move    (a7)+,sr
                rts

hbl_off:        move    sr,-(a7)
                ori     #$0700,sr
                lea     hbl_buff(pc),a0         ; Werte zureck!
                move.b  (a0)+,$fffffa09.w
                move.b  (a0)+,$fffffa07.w
                move.b  (a0)+,$fffffa13.w
                move.b  (a0)+,$fffffa1b.w
                move.b  (a0)+,$fffffa11.w
                move.b  (a0)+,$fffffa21.w
                move.b  (a0)+,$fffffa17.w
                move.b  (a0)+,$fffffa15.w
                move.l  (a0)+,$0118.w
                move.l  (a0)+,$0120.w
                move.l  (a0)+,$70.w
                move    (a7)+,sr
                rts


vbl:            movem.l d0-d7/a0-a6,-(a7)
                clr.b  $fffffa1b.w
palwert3:       movem.l palette4,d0-d7
                movem.l d0-d7,$ffff8240.w

                addq.l #2,rastdpos
                move.l rastdpos(pc),a0        ; neue Koord. des Rasters
                cmp.w #-99,(a0)
                bne.s nixendrast              ; nicht am Ende der Tab.
                lea rastdelta(pc),a0
nixendrast:     move.l a0,rastdpos
                move.w (a0),d0                ; Abstand des Rasters von 0
                addq.w #2,d0
                move.b  d0,$fffffa21.w        ; Abstand setzen
                
                move.w #152,d1
                sub.w d0,d1
                move.b d1,abstand             ; alten Wert

                move.l  #hbl2,$120.w
                move.b  #8,$fffffa1b.w
                bsr     music+8                     ; Musik anhupsen
                bsr     spritetale                  ; Spritekoordinaten berechnen

        
                addq.l #4,dpos2                 ; nÑchste Werte
                move.l dpos2(pc),a0
                cmp.w #-99,(a0)                 ; Ende dieser Tabelle?
                bne.s nixx                      ; noch nicht...
                addq.l #4,rdpos                 ; nÑchste Tabelle
                move.l rdpos(pc),a0
                cmp.l #-1,(a0)                  ; Letzte Tabelle?
                bne.s nixendrd                  ; noch nicht....
                lea rdelta(pc),a0               ; erste Tabelle
nixendrd:
                move.l a0,rdpos
                move.l (a0),a0
nixx:           move.l a0,dpos2
                move.w (a0),x                   ; X-Wert vom Background
                move.w 2(a0),y                  ; Y-Wert vom Background

                addq.l #4,ldpos                 ; NÑchste Werte des Logos
                move.l ldpos(pc),a0             
                cmp.w #-99,(a0)                 ; Tabelle am Ende?
                bne.s nixx2                     ; noch nicht...
                lea ldelta,a0                   ; Anfang der Tabelle
nixx2:          move.l a0,ldpos
                move.w (a0),logox               ; Koord.Werte fÅr Logo
                addq.w #8,logox                 ; X+8 -> links und rechts 8 Pixel
                move.w 2(a0),logoy              

                bsr scroll                      ; Hintergrund reinkopieren
                bsr wuchtlogo                   ; Logo reinkopieren
                bsr scrollline                  ; Laufschrift
                bsr drawshapes                  ; Shapes reinknÅppeln

                bsr switch                      ; Bildschirm umschalten


                addq.l  #1,$0466.w           ; System VBL ganz abgeklemmt
                movem.l (a7)+,d0-d7/a0-a6
                rte

newkey:         move.w  d0,-(a7)
                move.b  $fffffc00.w,d0
                btst    #7,d0
                beq.s   key_end
                move.b  $fffffc02.w,d0
                move.b  d0,key
key_end:        move.w  (a7)+,d0
                bclr    #6,$ffffffa11.w
                rte


hbl:        movem.l d0-d7,-(a7)
            movem.l palette2(pc),d0-d7          ; neue Palette in Zeile 172
            movem.l d0-d7,$ffff8240.w
            clr.b   $fffffa1b.w
            movem.l (a7)+,d0-d7
            rte

hbl2:       movem.l d0-d7/a0-a3,-(a7)
            lea pal_oben(pc),a3
            moveq #5,d1                         ; 6 Paletten
            clr.b $fffffa1b.w
            move.b #20,$fffffa21.w              ; neuer Abstand 20
            move.b #8,$fffffa1b.w
palwert1:   lea $ffff8240.w,a0
palcopy1:   movem.l (a3)+,d2-d7/a1-a2   
            move.b $fffffa21.w,d0
waitrand:   cmp.b $fffffa21.w,d0                ; auf rechten Rand warten
            beq.s waitrand
            nop
            nop
            nop
            nop
            nop
            nop
            nop
            nop
            movem.l d2-d7/a1-a2,(a0)
            dbra d1,palcopy1
            move.l #hbl3,$120.w
            movem.l (a7)+,d0-d7/a0-a3
            rte

hbl3:       movem.l d0-d7/a0-a3,-(a7)
            lea pal_unten(pc),a3
            moveq #5,d1                         ; 6 Paletten
            clr.b $fffffa1b.w
            move.b abstand(pc),$fffffa21.w      ; neuer Abstand unten
            move.b #8,$fffffa1b.w
palwert2:   lea $ffff8240.w,a0
palcopy2:   movem.l (a3)+,d2-d7/a1-a2   
            move.b $fffffa21.w,d0
waitrand2:  cmp.b $fffffa21.w,d0                ; auf rechten Rand warten
            beq.s waitrand2
            nop
            nop
            nop
            nop
            nop
            nop
            nop
            nop
            movem.l d2-d7/a1-a2,(a0)
            dbra d1,palcopy2
            move.l #hbl,$120.w
            movem.l (a7)+,d0-d7/a0-a3
            rte



;Werte fÅr Shapes
spd_x1:         dc.b $fa
spd_x2:         dc.b $02
spd_x3:         dc.b $05
spd_y1:         dc.b $fc
spd_y2:         dc.b $fd
spd_y3:         dc.b $02
add_x1:         dc.b $fb
add_x2:         dc.b $04
add_x3:         dc.b $f8
add_y1:         dc.b $11
add_y2:         dc.b $03
add_y3:         dc.b $f9

spritetale:
        move.b spd_x1   ,d0
        add.b d0        ,sinex1+3        
        move.b spd_x2   ,d0
        add.b d0        ,sinex3+3
        move.b spd_x3   ,d0
        add.b d0        ,sinex5+3
        move.b spd_y1   ,d0
        add.b d0        ,siney1+3
        move.b spd_y2   ,d0
        add.b d0        ,siney3+3
        move.b spd_y3   ,d0
        add.b d0        ,siney5+3
        move.l sinex1   ,sinex2
        move.l sinex3   ,sinex4
        move.l sinex5   ,sinex6
        move.l siney1   ,siney2
        move.l siney3   ,siney4
        move.l siney5   ,siney6

        lea.l shapekoord,a0             ; spritelocation y
        move.b #10      ,spr_nr         ; number of sprites
        move.b add_x1   ,d3
        move.b add_x2   ,d4
        move.b add_x3   ,d0

        move.b add_y1   ,d5
        move.b add_y2   ,d6
        move.b add_y3   ,d7
spr_loop:
        add.b d3        ,sinex2+3
        add.b d4        ,sinex4+3
        add.b d0        ,sinex6+3
        add.b d5        ,siney2+3
        add.b d6        ,siney4+3
        add.b d7        ,siney6+3

        move.l siney2   ,a2
        move.b (a2)     ,d1
        move.l siney4   ,a2
        move.b (a2)     ,d2
        add.b d2        ,d1
        move.l siney6   ,a2
        move.b (a2)     ,d2
        add.b d2        ,d1

        lsr.b #1,d1
        and.w #255,d1
        add.w #40,d1
        move.w d1       ,2(a0)

        move.l sinex2   ,a2
        move.b (a2)     ,d1
        move.l sinex4   ,a2
        move.b (a2)     ,d2
        add.b d2        ,d1
        move.l sinex6   ,a2
        move.b (a2)     ,d2
        add.b d2        ,d1
        move.l d1       ,d2
        and.w #255,d1
        add.w #16,d1
        move.w d1       ,(a0)
        lea 4(a0),a0
        subq.b #$01     ,spr_nr
        bne spr_loop
        rts

spr_nr: dc.b $00
        even



palette:
        dc.w $0000,$0667,$0556,$0445,$0334,$0223,$0112,$0001
        dc.w $0000,$0770,$0760,$0750,$0740,$0730,$0720,$0710
palette2:
        dc.w $0000,$0667,$0556,$0445,$0334,$0223,$0112,$0001
        dc.w $0000,$0700,$0600,$0500,$0400,$0300,$0200,$0100
palette3:
        dc.w $0000,$0107,$0106,$0105,$0104,$0103,$0102,$0101
        dc.w $0000,$0070,$0060,$0050,$0040,$0030,$0020,$0010
palette4:
        dc.w $0000,$0760,$0650,$0540,$0430,$0320,$0210,$0100
        dc.w $0000,$0707,$0606,$0505,$0404,$0303,$0202,$0101

pal_oben:
        dc.w $0001,$0551,$0541,$0430,$0320,$0210,$0100,$0000
        dc.w $0000,$0515,$0515,$0404,$0303,$0202,$0101,$0000
        dc.w $0002,$0442,$0432,$0321,$0221,$0211,$0100,$0000
        dc.w $0000,$0424,$0424,$0313,$0212,$0212,$0101,$0000 
        dc.w $0003,$0333,$0323,$0222,$0212,$0111,$0101,$0000
        dc.w $0000,$0333,$0333,$0222,$0222,$0111,$0111,$0000
        dc.w $0004,$0224,$0214,$0113,$0112,$0102,$0001,$0000
        dc.w $0000,$0242,$0242,$0131,$0121,$0121,$0010,$0000
        dc.w $0005,$0115,$0105,$0004,$0003,$0002,$0001,$0000
        dc.w $0000,$0151,$0151,$0040,$0030,$0020,$0010,$0000
        dc.w $0006,$0107,$0106,$0105,$0104,$0103,$0102,$0101
        dc.w $0000,$0070,$0060,$0050,$0040,$0030,$0020,$0010

pal_unten:
        dc.w $0005,$0117,$0106,$0105,$0104,$0103,$0102,$0101
        dc.w $0000,$0170,$0160,$0150,$0140,$0130,$0120,$0110
        dc.w $0004,$0227,$0216,$0215,$0114,$0103,$0102,$0001
        dc.w $0000,$0270,$0260,$0250,$0240,$0230,$0220,$0210
        dc.w $0003,$0337,$0326,$0225,$0214,$0113,$0102,$0001
        dc.w $0000,$0370,$0360,$0350,$0340,$0330,$0320,$0310
        dc.w $0002,$0447,$0336,$0325,$0224,$0113,$0102,$0001
        dc.w $0000,$0470,$0460,$0450,$0440,$0430,$0420,$0410
        dc.w $0001,$0557,$0446,$0335,$0224,$0113,$0102,$0001
        dc.w $0000,$0570,$0560,$0550,$0540,$0530,$0520,$0510
        dc.w $0000,$0667,$0556,$0445,$0334,$0223,$0112,$0001
        dc.w $0000,$0770,$0760,$0750,$0740,$0730,$0720,$0710
        


dflogo:
;$80,$3d
         DC.W   $0000,$0000,$0000,$7FFF,$FFFF,$FE00,$0000,$0000
         DC.W   $0000,$0000,$0000,$4000,$0000,$0200,$0000,$0000
         DC.W   $0000,$0000,$0000,$5FFC,$FBE7,$FA00,$0000,$0000
         DC.W   $0000,$0000,$0000,$5FFD,$FBE7,$FA00,$0000,$0000
         DC.W   $0000,$0000,$0000,$53E5,$F7EF,$1200,$0000,$0000
         DC.W   $0000,$0000,$0000,$47C7,$F7CF,$0600,$0000,$0000
         DC.W   $0000,$0000,$0000,$67D3,$FFCF,$EC00,$0000,$0000
         DC.W   $0000,$0000,$0000,$CFC7,$C79F,$E800,$0000,$0000
         DC.W   $0000,$0000,$0000,$9F8F,$8F9E,$0800,$0000,$0000
         DC.W   $0000,$0000,$0000,$BF9F,$AFBF,$E800,$0000,$0000
         DC.W   $07FF,$FE03,$FFFF,$BFBF,$AFFF,$CFFF,$0000,$0000
         DC.W   $0400,$03C2,$0000,$0000,$0000,$0001,$0000,$0000
         DC.W   $05FF,$F876,$FFFE,$FFFF,$FFFF,$DFFD,$0000,$0000
         DC.W   $05FF,$FF1C,$FFFF,$FFDF,$FFFF,$DFFD,$0000,$0000
         DC.W   $04FF,$FFCD,$FFFD,$FFDF,$FFFF,$8FFD,$0000,$0000
         DC.W   $06FF,$3FE9,$FE3D,$FFDE,$3FE3,$9FFD,$8000,$0000
         DC.W   $06FE,$1FEB,$FC89,$FF98,$3FCB,$3FFC,$8000,$0000
         DC.W   $04FE,$DFE3,$FDE1,$FF03,$7FD9,$3FFE,$8000,$0000
         DC.W   $05FE,$CFF3,$FC05,$FF7F,$7FDC,$FFFE,$8000,$0000
         DC.W   $0DFE,$EFF7,$FFF1,$FF43,$7FDC,$FCFE,$8000,$0000
         DC.W   $09FC,$CFF7,$FFF3,$FE42,$7F99,$F8FE,$8000,$0000
         DC.W   $1BFD,$DFF7,$FFE3,$FEC6,$FFB3,$F2FE,$C000,$0000
         DC.W   $13FD,$9FE7,$F00B,$FC84,$FFA7,$E4FE,$4000,$0000
         DC.W   $17F9,$BFEF,$F7F3,$FDFD,$FF0F,$E1FF,$4000,$0000
         DC.W   $37FB,$3FCF,$F707,$FD8D,$FF1F,$FFFF,$4000,$0000
         DC.W   $27F2,$7FDF,$E467,$F829,$FE3F,$FFFF,$4000,$0000
         DC.W   $6FE4,$FF9F,$E1EF,$F8EB,$FE7F,$FFFF,$6000,$0000
         DC.W   $4FE1,$FF3F,$CFEF,$FBE3,$FC7F,$807F,$2000,$0000
         DC.W   $DFFF,$FE3F,$FFEF,$FFC7,$FCFF,$3F7F,$A000,$0000
         DC.W   $9FFF,$F8FF,$FFFF,$FFDF,$FDFF,$617F,$A000,$0000
         DC.W   $BFFF,$C3FF,$FFFF,$FFFF,$FFFF,$7F7F,$BFFF,$FFFF
         DC.W   $8000,$1800,$0000,$0000,$0000,$007F,$B000,$0001
         DC.W   $FFFF,$FFFF,$7FFF,$F07F,$8FBF,$FF1F,$87FF,$3FFD
         DC.W   $0000,$0001,$7FFF,$F3FF,$E7BF,$FFE0,$3FFE,$7FFD
         DC.W   $0000,$0001,$3FFF,$E3FF,$F33F,$FFF4,$7FFE,$7FFD
         DC.W   $0000,$0001,$9FF9,$EFF3,$F97F,$FFF1,$FF3C,$FF1D
         DC.W   $0000,$0000,$DFF1,$DFE1,$FD7F,$87FB,$FE18,$FF45
         DC.W   $0000,$0000,$9FE4,$DFCB,$FD7F,$A7FB,$FCC0,$FE71
         DC.W   $0000,$0000,$BFCE,$3FDB,$FC7F,$0FF3,$F9FD,$FE01
         DC.W   $0000,$0001,$BFC0,$3FD3,$FCFF,$3FF7,$FB0D,$FFFB
         DC.W   $0000,$0001,$3FFF,$3F97,$FCFF,$FFE7,$FA09,$FFFA
         DC.W   $0000,$0001,$7FFF,$FFB7,$FDFF,$FFCF,$F21B,$FFF2
         DC.W   $0000,$0003,$7FFE,$7FA7,$FDFF,$FF0F,$F613,$FFF6
         DC.W   $0000,$0002,$7F00,$7F2F,$F9FC,$FE6F,$F417,$F804
         DC.W   $0000,$0002,$FF7F,$7F6F,$FBFC,$FE6F,$E7F7,$F38C
         DC.W   $0000,$0006,$FF41,$7F4F,$FBF8,$FF6F,$E607,$F628
         DC.W   $0000,$0004,$FE41,$7F1F,$F3FA,$FF27,$F0E7,$F0E8
         DC.W   $0000,$000D,$FCC1,$3FBF,$E7F2,$FFB7,$FFCF,$F3E8
         DC.W   $0000,$0009,$FD81,$9FFF,$8FF6,$FF93,$FFCF,$FFE8
         DC.W   $0000,$001B,$F900,$CFFF,$3FF6,$7FD8,$FFFF,$FFE8
         DC.W   $0000,$0013,$FB00,$61F8,$0007,$001E,$0000,$0008
         DC.W   $0000,$0017,$FB00,$3C03,$FFFD,$FFF3,$FFFF,$FFF8
         DC.W   $0000,$0037,$F900,$07FE,$0000,$0000,$0000,$0000
         DC.W   $0000,$0027,$FD00,$0000,$0000,$0000,$0000,$0000
         DC.W   $0000,$006F,$FD00,$0000,$0000,$0000,$0000,$0000
         DC.W   $0000,$004F,$F100,$0000,$0000,$0000,$0000,$0000
         DC.W   $0000,$00DF,$8700,$0000,$0000,$0000,$0000,$0000
         DC.W   $0000,$009E,$3C00,$0000,$0000,$0000,$0000,$0000
         DC.W   $0000,$00B8,$E000,$0000,$0000,$0000,$0000,$0000
         DC.W   $0000,$0083,$8000,$0000,$0000,$0000,$0000,$0000
         DC.W   $0000,$00FE,$0000,$0000,$0000,$0000,$0000,$0000

shapes:
         DC.W   $FFF0,$FFFC,$FFFE,$FFFE,$F83F,$F81F,$F81F,$F83F
         DC.W   $FFFE,$FFFE,$FFFC,$FFF0
         DC.W   $0000,$7FE0,$7FF8,$701C,$700C,$700E,$700E,$700C
         DC.W   $701C,$7FF8,$7FE0,$0000
         DC.W   $FFFF,$FFFF,$FFFF,$F800,$F800,$FFC0,$FFC0,$FFC0
         DC.W   $F800,$FFFF,$FFFF,$FFFF
         DC.W   $0000,$7FFE,$7000,$7000,$7000,$7000,$7F80,$7000
         DC.W   $7000,$7000,$7FFE,$0000
         DC.W   $F800,$F800,$F800,$F800,$F800,$F800,$F800,$F800
         DC.W   $FFFF,$FFFF,$FFFF,$FFFF
         DC.W   $0000,$7000,$7000,$7000,$7000,$7000,$7000,$7000
         DC.W   $7000,$7FFE,$7FFE,$0000
         DC.W   $FFFF,$FFFF,$FFFF,$FFFF,$07E0,$07E0,$07E0,$07E0
         DC.W   $07E0,$07E0,$07E0,$07E0
         DC.W   $0000,$7FFE,$7FFE,$03C0,$03C0,$03C0,$03C0,$03C0
         DC.W   $03C0,$03C0,$03C0,$0000
         DC.W   $0FF0,$3FFC,$7FFE,$7FFE,$FC3F,$F81F,$FFFF,$FFFF
         DC.W   $FFFF,$FFFF,$F81F,$F81F
         DC.W   $0000,$07E0,$1FF8,$381C,$300C,$700E,$700E,$7FFE
         DC.W   $7FFE,$700E,$700E,$0000
         DC.W   $FFFF,$FFFF,$FFFF,$FFFF,$F800,$FFC0,$FFC0,$FFC0
         DC.W   $FFC0,$F800,$F800,$F800
         DC.W   $0000,$7FFE,$7FFE,$7000,$7000,$7000,$7F80,$7F80
         DC.W   $7000,$7000,$7000,$0000
         DC.W   $0FF0,$3FFC,$7FFE,$7FFE,$FFFF,$FE7F,$FE7F,$FFFF
         DC.W   $7FFE,$7FFE,$3FFC,$0FF0
         DC.W   $0000,$07E0,$1FF8,$3FFC,$3C3C,$781E,$781E,$3C3C
         DC.W   $3FFC,$1FF8,$07E0,$0000
         DC.W   $FFFC,$FFFE,$FFFF,$FFFF,$F81F,$F83F,$FFFE,$FFFC
         DC.W   $FFFC,$FFFE,$F87F,$F83F
         DC.W   $0000,$7FF8,$7FFC,$700E,$700E,$700C,$7018,$7FF8
         DC.W   $7FF8,$7038,$701C,$0000
         DC.W   $0FFF,$3FFF,$7FFF,$7FFF,$FC00,$F800,$F800,$FC00
         DC.W   $7FFF,$7FFF,$3FFF,$0FFF
         DC.W   $0000,$07FE,$1FFE,$3800,$3000,$7000,$7000,$3000
         DC.W   $3800,$1FFE,$07FE,$0000
         DC.W   $FFFF,$FFFF,$FFFF,$F800,$F800,$FFC0,$FFC0,$FFC0
         DC.W   $F800,$FFFF,$FFFF,$FFFF
         DC.W   $0000,$7FFE,$7000,$7000,$7000,$7000,$7F80,$7000
         DC.W   $7000,$7000,$7FFE,$0000



block:
         DC.W   $4D2B,$3E34,$FFC0,$0000,$0DCC,$FC30,$03FF,$0000
         DC.W   $8A46,$F7C6,$0039,$0000,$6196,$1FE6,$FFF9,$0000
         DC.W   $5BA4,$3C3B,$FFC0,$0000,$9999,$7861,$07FE,$0000
         DC.W   $DDB5,$E277,$0008,$0000,$7CDB,$03E3,$FFFC,$0000
         DC.W   $AA42,$1C7D,$FF80,$0000,$EB61,$1881,$07FE,$0000
         DC.W   $36C9,$C93F,$0000,$0000,$16CA,$09F2,$FFFD,$0000
         DC.W   $525A,$BC65,$FF80,$0000,$4D96,$BC17,$03E8,$0000
         DC.W   $7073,$8F8F,$0000,$0000,$49ED,$07F0,$FFFF,$0000
         DC.W   $35A6,$F9D9,$FE00,$0000,$BAAD,$F83E,$07C0,$0000
         DC.W   $D58F,$2FFF,$0000,$0000,$7902,$07FD,$FFFF,$0000
         DC.W   $CBD1,$33EF,$FC00,$0000,$4272,$407F,$BF80,$0000
         DC.W   $4D71,$BF71,$008E,$0000,$645D,$1BA2,$FFFF,$0000
         DC.W   $7256,$03EE,$FC01,$0000,$B19E,$01FF,$FE00,$0000
         DC.W   $9A4E,$FE40,$01BF,$0000,$3A77,$0180,$FFFF,$0000
         DC.W   $152B,$06DB,$F804,$0000,$3B19,$03FF,$FC00,$0000
         DC.W   $AEBB,$FE04,$01FF,$0000,$E344,$0080,$FFFF,$0000
         DC.W   $ABD8,$AC38,$5007,$0000,$97E0,$07FF,$F800,$0000
         DC.W   $4DE4,$FC1B,$03FF,$0000,$2A9B,$C81B,$F7E4,$0000
         DC.W   $DA27,$FDE0,$001F,$0000,$6907,$91F8,$FE00,$0000
         DC.W   $113A,$F007,$0FFF,$0000,$497F,$897F,$F680,$0000
         DC.W   $24D2,$DBC1,$003F,$0000,$96EE,$F8F1,$FF00,$0000
         DC.W   $6805,$E002,$1FFF,$0000,$CD9C,$0DFF,$F200,$0000
         DC.W   $D549,$2BC0,$003F,$0000,$6C24,$F03B,$FFC0,$0000
         DC.W   $B6F7,$B600,$49FF,$0000,$3742,$C7FD,$F800,$0000
         DC.W   $1AAE,$E6A1,$015F,$0000,$CB94,$F39B,$FC60,$0000
         DC.W   $4D18,$FCE7,$03FF,$0000,$92BD,$E3C2,$FC00,$0000
         DC.W   $6672,$FE71,$018F,$0000,$BAD7,$C3D8,$FC20,$0000
         DC.W   $9B47,$78FF,$07FF,$0000,$29C6,$C1F9,$FE00,$0000
         DC.W   $94CD,$9CFC,$6303,$0000,$523B,$E3FC,$FC00,$0000
         DC.W   $223B,$E1C7,$1FFF,$0000,$58B9,$A0BF,$FF40,$0000
         DC.W   $6855,$686C,$9783,$0000,$094A,$F1BD,$FE00,$0000
         DC.W   $ECF4,$E30F,$1FFF,$0000,$F44D,$044F,$FBB0,$0000
         DC.W   $E755,$E76C,$1883,$0000,$DB64,$239B,$FC00,$0000
         DC.W   $915A,$8E27,$7FFF,$0000,$D2B2,$22B2,$FD4D,$0000
         DC.W   $28AE,$EFDE,$1001,$0000,$A27D,$0383,$FC00,$0000
         DC.W   $6E48,$1037,$FFFF,$0000,$ABCD,$73FD,$FC02,$0000
         DC.W   $B32A,$7CDA,$0005,$0000,$19A6,$19D9,$E600,$0000
         DC.W   $B8BD,$8002,$7FFF,$0000,$D626,$27DF,$F800,$0000
         DC.W   $8ED3,$7133,$000C,$0000,$64A8,$7CDF,$8300,$0000
         DC.W   $444E,$C441,$3BBF,$0000,$7574,$868F,$F800,$0000
         DC.W   $EC35,$13F1,$000E,$0000,$4697,$7EEF,$8100,$0000
         DC.W   $2DB3,$EDF0,$120F,$0000,$3B5B,$CCA4,$F000,$0000
         DC.W   $99F6,$67F0,$000F,$0000,$D4BA,$ECC6,$0301,$0000
         DC.W   $FA5D,$FBBC,$0403,$0000,$7A85,$8D7A,$F000,$0000
         DC.W   $6B2C,$F720,$00DF,$0000,$A961,$D99F,$0600,$0000
         DC.W   $04C6,$FF3E,$0001,$0000,$9238,$1DFF,$E000,$0000
         DC.W   $D4D1,$DC00,$23FF,$0000,$5E4D,$7FBF,$8000,$0000
         DC.W   $7BD3,$842F,$0000,$0000,$7257,$7DD7,$8028,$0000
         DC.W   $19F4,$1804,$E7FB,$0000,$29EE,$3E1F,$C000,$0000
         DC.W   $7436,$8BCE,$0001,$0000,$C9C2,$FFC2,$003D,$0000
         DC.W   $E896,$0866,$F7F9,$0000,$E437,$FFCF,$0000,$0000
         DC.W   $8BB3,$FFCF,$0000,$0000,$B7E4,$F7E0,$081F,$0000
         DC.W   $D673,$2003,$FFFC,$0000,$7D8D,$FE7F,$0000,$0000
         DC.W   $F673,$FF8F,$0000,$0000,$531E,$B300,$0CFF,$0000
         DC.W   $8D4B,$7233,$FFFC,$0000,$1A31,$FBFF,$0400,$0000
         DC.W   $7325,$7FDF,$8000,$0000,$A579,$E106,$1EFF,$0000
         DC.W   $B1D4,$7E27,$FFF8,$0000,$E5DA,$1DFE,$0201,$0000
         DC.W   $45D9,$7BFF,$8000,$0000,$3642,$F03F,$0FFF,$0000
         DC.W   $30B6,$FF07,$FFF8,$0000,$921A,$6FFE,$0001,$0000
         DC.W   $BA72,$C5FF,$0000,$0000,$9388,$707F,$0FFF,$0000
         DC.W   $EFDB,$F003,$FFFC,$0000,$44C9,$BFFF,$0000,$0000
         DC.W   $212D,$DEF3,$0000,$0000,$267C,$E1FF,$1FFF,$0000
         DC.W   $8868,$F000,$FFFF,$0000,$AB9D,$FBFF,$0400,$0000
         DC.W   $999A,$E667,$0000,$0000,$E73F,$E0FF,$1FFF,$0000
         DC.W   $3BAE,$C380,$FC7F,$0000,$D0EE,$F0EF,$0F10,$0000
         DC.W   $CCB7,$F34F,$0000,$0000,$4986,$407F,$BFFF,$0000
         DC.W   $C6B3,$0780,$F87F,$0000,$4916,$7807,$87F8,$0000
         DC.W   $E9E3,$F61F,$0000,$0000,$9FB8,$8047,$7FFF,$0000
         DC.W   $9EC1,$1FC0,$E03F,$0000,$6B71,$7801,$87FE,$0000
         DC.W   $11CD,$EE3D,$0002,$0000,$977F,$8800,$7FFF,$0000
         DC.W   $3F5C,$3FDC,$C023,$0000,$DA4E,$F830,$07FF,$0000
         DC.W   $933B,$ECFB,$0004,$0000,$2502,$1A00,$FFFF,$0000
         DC.W   $E1AD,$E1FD,$1E02,$0000,$B6B5,$F079,$0FFE,$0000
         DC.W   $C6E2,$F9E2,$001D,$0000,$49B9,$3E39,$FFC6,$0000
         DC.W   $4EC3,$C0FF,$3F00,$0000,$92D6,$F038,$0FFF,$0000
         DC.W   $4D26,$7326,$80D9,$0000,$CCA6,$3F3F,$FFC0,$0000
         DC.W   $52D8,$CCE7,$3F00,$0000,$D983,$F87C,$07FF,$0000
         DC.W   $598C,$678C,$8073,$0000,$D559,$2F9F,$FFE0,$0000
         DC.W   $AB6F,$9C70,$7F80,$0000,$3DC6,$FC38,$03FF,$0000
         DC.W   $CC87,$F387,$0078,$0000,$7366,$0F86,$FFF9,$0000


SINEx1:         dc.l sinusdata
SINEx2:         dc.l sinusdata
SINEx3:         dc.l sinusdata
SINEx4:         dc.l sinusdata
SINEx5:         dc.l sinusdata
SINEx6:         dc.l sinusdata
SINEy1:         dc.l sinusdata+$100
SINEy2:         dc.l sinusdata+$100
SINEy3:         dc.l sinusdata+$100     
SINEy4:         dc.l sinusdata+$100
SINEy5:         dc.l sinusdata+$100     
SINEy6:         dc.l sinusdata+$100

rdelta: 	dc.l delta
        	dc.l -1

ldelta:
      dc.w 150,50,147,51,144,53,141,55,138,56,135,58,132,60,129,62,126,63,122,65
      dc.w 119,67,116,68,112,70,108,71,105,73,101,75,98,76,94,77,90,79,87,80
      dc.w 83,82,79,83,76,84,72,85,68,87,65,88,61,89,58,90,54,91,51,92
      dc.w 48,93,44,94,41,94,38,95,35,96,32,96,29,97,27,98,24,98,21,98
      dc.w 19,99,17,99,15,99,13,99,11,99,9,100,7,99,6,99,5,99,4,99
      dc.w 2,99,2,98,1,98,0,98,0,97,0,96,0,96,0,95,0,94,0,94
      dc.w 1,93,1,92,2,91,3,90,4,89,5,88,7,87,8,85,10,84,12,83
      dc.w 14,82,16,80,18,79,20,77,23,76,25,75,28,73,31,71,34,70,37,68
      dc.w 40,67,43,65,46,63,49,62,53,60,56,58,59,56,63,55,67,53,70,51
      dc.w 74,50,77,48,81,46,85,44,88,43,92,41,96,39,99,37,103,36,107,34
      dc.w 110,32,114,31,117,29,121,28,124,26,127,24,131,23,134,22,137,20,140,19
      dc.w 143,17,146,16,148,15,151,14,154,12,156,11,158,10,160,9,162,8,164,7
      dc.w 166,6,168,5,169,5,170,4,171,3,173,3,173,2,174,1,175,1,175,1
      dc.w 175,0,175,0,175,0,175,0,175,0,174,0,174,0,173,0,172,0,171,0
      dc.w 170,0,168,1,167,1,165,1,163,2,161,3,159,3,157,4,155,5,152,5
      dc.w 150,6,147,7,144,8,141,9,138,10,135,11,132,12,129,14,126,15,122,16
      dc.w 119,17,116,19,112,20,108,22,105,23,101,24,98,26,94,28,90,29,87,31
      dc.w 83,32,79,34,76,36,72,37,68,39,65,41,61,43,58,44,54,46,51,48
      dc.w 48,49,44,51,41,53,38,55,35,56,32,58,29,60,27,62,24,63,21,65
      dc.w 19,67,17,68,15,70,13,71,11,73,9,75,7,76,6,77,5,79,4,80
      dc.w 2,82,2,83,1,84,0,85,0,87,0,88,0,89,0,90,0,91,0,92
      dc.w 1,93,1,94,2,94,3,95,4,96,5,96,7,97,8,98,10,98,12,98
      dc.w 14,99,16,99,18,99,20,99,23,99,25,100,28,99,31,99,34,99,37,99
      dc.w 40,99,43,98,46,98,49,98,53,97,56,96,59,96,63,95,67,94,70,94
      dc.w 74,93,77,92,81,91,85,90,88,89,92,88,96,87,99,85,103,84,107,83
      dc.w 110,82,114,80,117,79,121,77,124,76,127,75,131,73,134,71,137,70,140,68
      dc.w 143,67,146,65,148,63,151,62,154,60,156,58,158,56,160,55,162,53,164,51
      dc.w 166,50,168,48,169,46,170,44,171,43,173,41,173,39,174,37,175,36,175,34
      dc.w 175,32,175,31,175,29,175,28,175,26,174,24,174,23,173,22,172,20,171,19
      dc.w 170,17,168,16,167,15,165,14,163,12,161,11,159,10,157,9,155,8,152,7
      dc.w 150,6,147,5,144,5,141,4,138,3,135,3,132,2,129,1,126,1,122,1
      dc.w 119,0,116,0,112,0,108,0,105,0,101,0,98,0,94,0,90,0,87,0
      dc.w 83,0,79,1,76,1,72,1,68,2,65,3,61,3,58,4,54,5,51,5
      dc.w 48,6,44,7,41,8,38,9,35,10,32,11,29,12,27,14,24,15,21,16
      dc.w 19,17,17,19,15,20,13,22,11,23,9,24,7,26,6,28,5,29,4,31
      dc.w 2,32,2,34,1,36,0,37,0,39,0,41,0,43,0,44,0,46,0,48
      dc.w 1,49,1,51,2,53,3,55,4,56,5,58,7,60,8,62,10,63,12,65
      dc.w 14,67,16,68,18,70,20,71,23,73,25,75,28,76,31,77,34,79,37,80
      dc.w 40,82,43,83,46,84,49,85,53,87,56,88,59,89,63,90,67,91,70,92
      dc.w 74,93,77,94,81,94,85,95,88,96,92,96,96,97,99,98,103,98,107,98
      dc.w 110,99,114,99,117,99,121,99,124,99,127,100,131,99,134,99,137,99,140,99
      dc.w 143,99,146,98,148,98,151,98,154,97,156,96,158,96,160,95,162,94,164,94
      dc.w 166,93,168,92,169,91,170,90,171,89,173,88,173,87,174,85,175,84,175,83
      dc.w 175,82,175,80,175,79,175,77,175,76,174,75,174,73,173,71,172,70,171,68
      dc.w 170,67,168,65,167,63,165,62,163,60,161,58,159,56,157,55,155,53,152,51
      dc.w 150,49,147,48,144,46,141,44,138,43,135,41,132,39,129,37,126,36,122,34
      dc.w 119,32,116,31,112,29,108,28,105,26,101,24,98,23,94,22,90,20,87,19
      dc.w 83,17,79,16,76,15,72,14,68,12,65,11,61,10,58,9,54,8,51,7
      dc.w 48,6,44,5,41,5,38,4,35,3,32,3,29,2,27,1,24,1,21,1
      dc.w 19,0,17,0,15,0,13,0,11,0,9,0,7,0,6,0,5,0,4,0
      dc.w 2,0,2,1,1,1,0,1,0,2,0,3,0,3,0,4,0,5,0,5
      dc.w 1,6,1,7,2,8,3,9,4,10,5,11,7,12,8,14,10,15,12,16
      dc.w 14,17,16,19,18,20,20,22,23,23,25,24,28,26,31,28,34,29,37,31
      dc.w 40,32,43,34,46,36,49,37,53,39,56,41,59,43,63,44,67,46,70,48
      dc.w 74,49,77,51,81,53,85,55,88,56,92,58,96,60,99,62,103,63,107,65
      dc.w 110,67,114,68,117,70,121,71,124,73,127,75,131,76,134,77,137,79,140,80
      dc.w 143,82,146,83,148,84,151,85,154,87,156,88,158,89,160,90,162,91,164,92
      dc.w 166,93,168,94,169,94,170,95,171,96,173,96,173,97,174,98,175,98,175,98
      dc.w 175,99,175,99,175,99,175,99,175,99,174,100,174,99,173,99,172,99,171,99
      dc.w 170,99,168,98,167,98,165,98,163,97,161,96,159,96,157,95,155,94,152,94
      dc.w 150,93,147,92,144,91,141,90,138,89,135,88,132,87,129,85,126,84,122,83
      dc.w 119,82,116,80,112,79,108,77,105,76,101,75,98,73,94,71,90,70,87,68
      dc.w 83,67,79,65,76,63,72,62,68,60,65,58,61,56,58,55,54,53,51,51
      dc.w 48,50,44,48,41,46,38,44,35,43,32,41,29,39,27,37,24,36,21,34
      dc.w 19,32,17,31,15,29,13,28,11,26,9,24,7,23,6,22,5,20,4,19
      dc.w 2,17,2,16,1,15,0,14,0,12,0,11,0,10,0,9,0,8,0,7
      dc.w 1,6,1,5,2,5,3,4,4,3,5,3,7,2,8,1,10,1,12,1
      dc.w 14,0,16,0,18,0,20,0,23,0,25,0,28,0,31,0,34,0,37,0
      dc.w 40,0,43,1,46,1,49,1,53,2,56,3,59,3,63,4,67,5,70,5
      dc.w 74,6,77,7,81,8,85,9,88,10,92,11,96,12,99,14,103,15,107,16
      dc.w 110,17,114,19,117,20,121,22,124,23,127,24,131,26,134,28,137,29,140,31
      dc.w 143,32,146,34,148,36,151,37,154,39,156,41,158,43,160,44,162,46,164,48
      dc.w 166,49,168,51,169,53,170,55,171,56,173,58,173,60,174,62,175,63,175,65
      dc.w 175,67,175,68,175,70,175,71,175,73,174,75,174,76,173,77,172,79,171,80
      dc.w 170,82,168,83,167,84,165,85,163,87,161,88,159,89,157,90,155,91,152,92
      dc.w 150,93,147,94,144,94,141,95,138,96,135,96,132,97,129,98,126,98,122,98
      dc.w 119,99,116,99,112,99,108,99,105,99,101,100,98,99,94,99,90,99,87,99
      dc.w 83,99,79,98,76,98,72,98,68,97,65,96,61,96,58,95,54,94,51,94
      dc.w 48,93,44,92,41,91,38,90,35,89,32,88,29,87,27,85,24,84,21,83
      dc.w 19,82,17,80,15,79,13,77,11,76,9,75,7,73,6,71,5,70,4,68
      dc.w 2,67,2,65,1,63,0,62,0,60,0,58,0,56,0,55,0,53,0,51
      dc.w 1,49,1,48,2,46,3,44,4,43,5,41,7,39,8,37,10,36,12,34
      dc.w 14,32,16,31,18,29,20,28,23,26,25,24,28,23,31,22,34,20,37,19
      dc.w 40,17,43,16,46,15,49,14,53,12,56,11,59,10,63,9,67,8,70,7
      dc.w 74,6,77,5,81,5,85,4,88,3,92,3,96,2,99,1,103,1,107,1
      dc.w 110,0,114,0,117,0,121,0,124,0,127,0,131,0,134,0,137,0,140,0
      dc.w 143,0,146,1,148,1,151,1,154,2,156,3,158,3,160,4,162,5,164,5
      dc.w 166,6,168,7,169,8,170,9,171,10,173,11,173,12,174,14,175,15,175,16
      dc.w 175,17,175,19,175,20,175,22,175,23,174,24,174,26,173,28,172,29,171,31
      dc.w 170,32,168,34,167,36,165,37,163,39,161,41,159,43,157,44,155,46,152,48
        dc.w -99


delta:
      dc.w 273,100,268,102,263,105,258,108,252,111,247,113,241,116,235,119,229,122,223,124
      dc.w 217,127,211,129,204,132,198,135,191,137,185,140,178,142,171,144,165,147,158,149
      dc.w 151,151,144,153,138,155,131,157,125,159,118,161,112,163,105,164,99,166,93,167
      dc.w 87,169,81,170,75,171,70,173,64,174,59,175,54,176,49,176,44,177,39,178
      dc.w 35,178,31,179,27,179,24,179,20,179,17,180,14,179,11,179,9,179,7,179
      dc.w 5,178,3,178,2,177,1,176,0,176,0,175,0,174,0,173,0,171,1,170
      dc.w 1,169,3,167,4,166,6,164,8,163,10,161,13,159,15,157,18,155,22,153
      dc.w 25,151,29,149,33,147,37,144,42,142,46,140,51,137,56,135,61,132,67,129
      dc.w 72,127,78,124,84,122,90,119,96,116,102,113,108,111,115,108,121,105,128,102
      dc.w 134,100,141,97,148,94,154,91,161,88,168,86,175,83,181,80,188,77,194,75
      dc.w 201,72,207,70,214,67,220,64,226,62,232,59,238,57,244,55,249,52,255,50
      dc.w 260,48,265,46,270,44,275,42,280,40,284,38,288,36,292,35,295,33,299,32
      dc.w 302,30,305,29,308,28,310,26,312,25,314,24,316,23,317,23,318,22,319,21
      dc.w 319,21,319,20,319,20,319,20,318,20,318,20,316,20,315,20,313,20,311,20
      dc.w 309,21,306,21,304,22,301,23,297,23,294,24,290,25,286,26,282,28,277,29
      dc.w 273,30,268,32,263,33,258,35,252,36,247,38,241,40,235,42,229,44,223,46
      dc.w 217,48,211,50,204,52,198,55,191,57,185,59,178,62,171,64,165,67,158,70
      dc.w 151,72,144,75,138,77,131,80,125,83,118,86,112,88,105,91,99,94,93,97
      dc.w 87,99,81,102,75,105,70,108,64,111,59,113,54,116,49,119,44,122,39,124
      dc.w 35,127,31,129,27,132,24,135,20,137,17,140,14,142,11,144,9,147,7,149
      dc.w 5,151,3,153,2,155,1,157,0,159,0,161,0,163,0,164,0,166,1,167
      dc.w 1,169,3,170,4,171,6,173,8,174,10,175,13,176,15,176,18,177,22,178
      dc.w 25,178,29,179,33,179,37,179,42,179,46,180,51,179,56,179,61,179,67,179
      dc.w 72,178,78,178,84,177,90,176,96,176,102,175,108,174,115,173,121,171,128,170
      dc.w 134,169,141,167,148,166,154,164,161,163,168,161,175,159,181,157,188,155,194,153
      dc.w 201,151,207,149,214,147,220,144,226,142,232,140,238,137,244,135,249,132,255,129
      dc.w 260,127,265,124,270,122,275,119,280,116,284,113,288,111,292,108,295,105,299,102
      dc.w 302,100,305,97,308,94,310,91,312,88,314,86,316,83,317,80,318,77,319,75
      dc.w 319,72,319,70,319,67,319,64,318,62,318,59,316,57,315,55,313,52,311,50
      dc.w 309,48,306,46,304,44,301,42,297,40,294,38,290,36,286,35,282,33,277,32
      dc.w 273,30,268,29,263,28,258,26,252,25,247,24,241,23,235,23,229,22,223,21
      dc.w 217,21,211,20,204,20,198,20,191,20,185,20,178,20,171,20,165,20,158,20
      dc.w 151,21,144,21,138,22,131,23,125,23,118,24,112,25,105,26,99,28,93,29
      dc.w 87,30,81,32,75,33,70,35,64,36,59,38,54,40,49,42,44,44,39,46
      dc.w 35,48,31,50,27,52,24,55,20,57,17,59,14,62,11,64,9,67,7,70
      dc.w 5,72,3,75,2,77,1,80,0,83,0,86,0,88,0,91,0,94,1,97
      dc.w 1,99,3,102,4,105,6,108,8,111,10,113,13,116,15,119,18,122,22,124
      dc.w 25,127,29,129,33,132,37,135,42,137,46,140,51,142,56,144,61,147,67,149
      dc.w 72,151,78,153,84,155,90,157,96,159,102,161,108,163,115,164,121,166,128,167
      dc.w 134,169,141,170,148,171,154,173,161,174,168,175,175,176,181,176,188,177,194,178
      dc.w 201,178,207,179,214,179,220,179,226,179,232,180,238,179,244,179,249,179,255,179
      dc.w 260,178,265,178,270,177,275,176,280,176,284,175,288,174,292,173,295,171,299,170
      dc.w 302,169,305,167,308,166,310,164,312,163,314,161,316,159,317,157,318,155,319,153
      dc.w 319,151,319,149,319,147,319,144,318,142,318,140,316,137,315,135,313,132,311,129
      dc.w 309,127,306,124,304,122,301,119,297,116,294,113,290,111,286,108,282,105,277,102
      dc.w 273,99,268,97,263,94,258,91,252,88,247,86,241,83,235,80,229,77,223,75
      dc.w 217,72,211,70,204,67,198,64,191,62,185,59,178,57,171,55,165,52,158,50
      dc.w 151,48,144,46,138,44,131,42,125,40,118,38,112,36,105,35,99,33,93,32
      dc.w 87,30,81,29,75,28,70,26,64,25,59,24,54,23,49,23,44,22,39,21
      dc.w 35,21,31,20,27,20,24,20,20,20,17,20,14,20,11,20,9,20,7,20
      dc.w 5,21,3,21,2,22,1,23,0,23,0,24,0,25,0,26,0,28,1,29
      dc.w 1,30,3,32,4,33,6,35,8,36,10,38,13,40,15,42,18,44,22,46
      dc.w 25,48,29,50,33,52,37,55,42,57,46,59,51,62,56,64,61,67,67,70
      dc.w 72,72,78,75,84,77,90,80,96,83,102,86,108,88,115,91,121,94,128,97
      dc.w 134,99,141,102,148,105,154,108,161,111,168,113,175,116,181,119,188,122,194,124
      dc.w 201,127,207,129,214,132,220,135,226,137,232,140,238,142,244,144,249,147,255,149
      dc.w 260,151,265,153,270,155,275,157,280,159,284,161,288,163,292,164,295,166,299,167
      dc.w 302,169,305,170,308,171,310,173,312,174,314,175,316,176,317,176,318,177,319,178
      dc.w 319,178,319,179,319,179,319,179,318,179,318,180,316,179,315,179,313,179,311,179
      dc.w 309,178,306,178,304,177,301,176,297,176,294,175,290,174,286,173,282,171,277,170
      dc.w 273,169,268,167,263,166,258,164,252,163,247,161,241,159,235,157,229,155,223,153
      dc.w 217,151,211,149,204,147,198,144,191,142,185,140,178,137,171,135,165,132,158,129
      dc.w 151,127,144,124,138,122,131,119,125,116,118,113,112,111,105,108,99,105,93,102
      dc.w 87,100,81,97,75,94,70,91,64,88,59,86,54,83,49,80,44,77,39,75
      dc.w 35,72,31,70,27,67,24,64,20,62,17,59,14,57,11,55,9,52,7,50
      dc.w 5,48,3,46,2,44,1,42,0,40,0,38,0,36,0,35,0,33,1,32
      dc.w 1,30,3,29,4,28,6,26,8,25,10,24,13,23,15,23,18,22,22,21
      dc.w 25,21,29,20,33,20,37,20,42,20,46,20,51,20,56,20,61,20,67,20
      dc.w 72,21,78,21,84,22,90,23,96,23,102,24,108,25,115,26,121,28,128,29
      dc.w 134,30,141,32,148,33,154,35,161,36,168,38,175,40,181,42,188,44,194,46
      dc.w 201,48,207,50,214,52,220,55,226,57,232,59,238,62,244,64,249,67,255,70
      dc.w 260,72,265,75,270,77,275,80,280,83,284,86,288,88,292,91,295,94,299,97
      dc.w 302,99,305,102,308,105,310,108,312,111,314,113,316,116,317,119,318,122,319,124
      dc.w 319,127,319,129,319,132,319,135,318,137,318,140,316,142,315,144,313,147,311,149
      dc.w 309,151,306,153,304,155,301,157,297,159,294,161,290,163,286,164,282,166,277,167
      dc.w 273,169,268,170,263,171,258,173,252,174,247,175,241,176,235,176,229,177,223,178
      dc.w 217,178,211,179,204,179,198,179,191,179,185,180,178,179,171,179,165,179,158,179
      dc.w 151,178,144,178,138,177,131,176,125,176,118,175,112,174,105,173,99,171,93,170
      dc.w 87,169,81,167,75,166,70,164,64,163,59,161,54,159,49,157,44,155,39,153
      dc.w 35,151,31,149,27,147,24,144,20,142,17,140,14,137,11,135,9,132,7,129
      dc.w 5,127,3,124,2,122,1,119,0,116,0,113,0,111,0,108,0,105,1,102
      dc.w 1,99,3,97,4,94,6,91,8,88,10,86,13,83,15,80,18,77,22,75
      dc.w 25,72,29,70,33,67,37,64,42,62,46,59,51,57,56,55,61,52,67,50
      dc.w 72,48,78,46,84,44,90,42,96,40,102,38,108,36,115,35,121,33,128,32
      dc.w 134,30,141,29,148,28,154,26,161,25,168,24,175,23,181,23,188,22,194,21
      dc.w 201,21,207,20,214,20,220,20,226,20,232,20,238,20,244,20,249,20,255,20
      dc.w 260,21,265,21,270,22,275,23,280,23,284,24,288,25,292,26,295,28,299,29
      dc.w 302,30,305,32,308,33,310,35,312,36,314,38,316,40,317,42,318,44,319,46
      dc.w 319,48,319,50,319,52,319,55,318,57,318,59,316,62,315,64,313,67,311,70
      dc.w 309,72,306,75,304,77,301,80,297,83,294,86,290,88,286,91,282,94,277,97
      dc.w -99
rastdelta:
      dc.w 70,72,74,77,79,82,84,86,89,91
      dc.w 93,96,98,100,102,105,107,109,111,113
      dc.w 114,116,118,120,122,123,125,126,128,129
      dc.w 130,131,132,133,134,135,136,137,137,138
      dc.w 138,139,139,139,139,140,139,139,139,139
      dc.w 138,138,137,137,136,135,134,133,132,131
      dc.w 130,129,128,126,125,123,122,120,118,116
      dc.w 114,113,111,109,107,105,102,100,98,96
      dc.w 93,91,89,86,84,82,79,77,74,72
      dc.w 70,67,65,62,60,57,55,53,50,48
      dc.w 46,43,41,39,37,34,32,30,28,26
      dc.w 25,23,21,19,17,16,14,13,11,10
      dc.w 9,8,7,6,5,4,3,2,2,1
      dc.w 1,0,0,0,0,0,0,0,0,0
      dc.w 1,1,2,2,3,4,5,6,7,8
      dc.w 9,10,11,13,14,16,17,19,21,23
      dc.w 25,26,28,30,32,34,37,39,41,43
      dc.w 46,48,50,53,55,57,60,62,65,67
      dc.w -99

spdtab:         dc.w 1,1,2,4,8

oldscreen:      blk.l 1,0
newscreen:      blk.l 1,0
charset:        blk.b   3840,0
music:          blk.b   7424,0
text:           blk.b   $bfe,0
sinus:		blk.b	512,0
IF diskversion=0
oldpalette:     blk.l 8
ENDIF
dpos2:          blk.l 1,0
x:              blk.w 1,0
y:              blk.w 1,0
logox:          blk.w 1,0
logoy:          blk.w 1,0
nixfade:        blk.w 1,0
colfadecount:   blk.w 1,0
shapekoord:     blk.w 20,0
ldpos:          blk.l 1,0
rdpos:          blk.l 1,0
hbl_buff:       blk.w 10,0
textpos:        blk.l 1,0
pointers:       blk.l 21,0
scrolltable:    blk.l scanzahl+1,0
speed:          blk.w 1,0
spos:           blk.w 1,0
scrdpos:        blk.l 1,0
rastdpos:       blk.l 1,0
abstand:        blk.w 1,0
key:            blk.w 1,0
scrollstop:     blk.w 1,0
e:
