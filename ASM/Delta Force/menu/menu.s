*********************************************************************
***                                                               ***
***                     Hauptmenue der DF-Demo                    ***
***                    ~~~~~~~~~~~~~~~~~~~~~~~                    ***
***                    (C) by New Mode                             ***
***---------------------------------------------------------------***
***            Programmerstellung begann am: 23.12.89             ***
***            Aktuelles Datum             : 09.12.90             ***
***---------------------------------------------------------------***
***              Entwickelt mit Devpac-Assembler                  ***
***               Umgestellt auf Seka-Assembler                   ***
*********************************************************************
diskversion=0			; 0 bei Platte/1 bei Diskversion

if diskversion=0
	offset=$280000
else
	offset=0
endif
org     $1000+offset
load    $281000

of=$280000

hiddenscreenline=33		; in dieser Zeile Hiddenscreen w„hlen
				; ^^^^^ ACHTUNG!!!! „ndert sich ^^^^^
anzahl=320              	; Anzahl der Sterne
zeilen=56			; Anzahl der Textzeilen
scanlines=24			; H”he der Scrolline
if diskversion=0
starsreadyflag=$60c		; dort steht "STAR" wenn fertig
megaflag=$600			; dort steht "MEGA" wenn kein 512KB ST
balkenpos=$610			; dort ist der Balken
scrollreadyflag=$616		; dort ist "SCRL" wenn Scrollbuff ok
else
starsreadyflag=$40c		; dort steht "STAR" wenn fertig
megaflag=$400			; dort steht "MEGA" wenn kein 512KB ST
balkenpos=$410
scrollreadyflag=$416
endif

maxzeile=zeilen-9		; bis dorthin darf gescrollt werden

screenbase=$60c00+offset      	; Platz fr 4 Screens
punkttab=$38700+offset		; 129*4*anzahl der Sterne
sourcepointtab=$38200+offset
pointtab=$37d00+offset

if	diskversion=1
megastars=$c0000		; dort sind die Sterne bei 1 Mbyte
scrollsavebuff=$8c600
else
megastars=$3c0000		; dort sind die Sterne bei 4MB
scrollsavebuff=$38c600
endif

; Files zu laden:
; mfchars.img nach font+of
; text.img nach text+of
; madmax3.img nach music+of
; dflogo nach dflogo+of 

     
s:              

		if	diskversion=0
		movem.l $ffff8240.w,d0-d7    ; Farben retten
                movem.l d0-d7,oldpal

                lea     $ffff8240.w,a0
                moveq   #7,d0
clrpal:         clr.l   (a0)+
                dbra    d0,clrpal
		endif

		if	diskversion=0
		move.l	#keyinit,tx_point	; Maus aus
		move.w	#2,tx_count
		bsr	send
		endif

		if	diskversion=0
		lea	font(pc),a6
		lea	fontfile(pc),a0
		bsr	load
		lea	dflogo(pc),a6
		lea	logofile(pc),a0
		bsr	load
		lea	music,a6
		lea	musicfile(pc),a0
		bsr	load
		lea	text,a6
		lea	textfile(pc),a0
		bsr	load
		endif

		lea	dflogo,a0
		move.l	#8160,d0
		bsr	backform

		lea	font,a0
		move.l	#12960,d0
		bsr	backform

		
                move.l  #screenbase,d0
                move.l  d0,screen1
                add.l   #32000,d0
                move.l  d0,screen2
                add.l   #32000,d0
                move.l  d0,screen3
                add.l   #32000,d0
                move.l  d0,screen4
                clr.w   screennumm
                move.l  screen1,workscreen
                
                move.l  screen1,a0
                bsr     cls
                move.l  screen2,a0
                bsr     cls                  
                move.l  screen3,a0
                bsr     cls                  ; alle Screens l”schen
                move.l  screen4,a0
                bsr     cls                  ; beide Screens l”schen

                move.l  screen1,d0
                bsr     setscreen

		if	diskversion=0
		bsr	vsync
                clr.b   $ffff8260.w
                move.b  #2,$ffff820a.w
		endif

                lea     dflogo,a0
                move.l  screen1,a1
                move.l  screen2,a2
                move.l  screen3,a3
                move.l  screen4,a4
                move.w  #[51*40]-1,d0
copylogo:       move.l  (a0),(a1)+
                move.l  (a0),(a2)+
                move.l  (a0),(a3)+
                move.l  (a0)+,(a4)+
                dbra    d0,copylogo
                
                move.l  #restbuff1,restpoint1
                move.l  #restbuff2,restpoint2
                move.l  #restbuff3,restpoint3
                move.l  #restbuff4,restpoint4
                move.l  #restbuff1,restwork
                clr.w   restcount
                
                move.w  #anzahl-1,d0
                lea     restbuff1,a0
                lea     restbuff2,a1
                lea     restbuff3,a2
                lea     restbuff4,a3
makerbuff:      move.l  screen1,(a0)+
                clr.l   (a0)+
                move.l  screen2,(a1)+
                clr.l   (a1)+
                move.l  screen3,(a2)+
                clr.l   (a2)+
                move.l  screen4,(a3)+
                clr.l   (a3)+
                dbra    d0,makerbuff
                
                lea     hblcolors2,a0
                lea     hblcolors,a1    ; Longs machen
                moveq   #31,d0
makecolors:     move.w  (a0),(a1)+
                move.w  (a0)+,(a1)+
                dbra    d0,makecolors


		cmp.l	#"STAR",starsreadyflag
		beq.s	nixmakescroll1
		lea	text2,a0
                bsr     makescrolling
nixmakescroll1:
		move.l	#hiddenscreenkeys,hiddenkeypointer		

                bsr     maketexttable

		clr.b	key

                bsr     hbl_on

                bsr     makestars                
                bsr     preshstars


                move.w  balkenpos,text_y	; auf 2. Zeile gehen
		clr.w	endflag
                clr.w   text_add
                clr.w   text_sub
                clr.w   text_aktiv
                
                moveq   #1,d0           ; Musik anschalten
                jsr     music


		cmp.l	#"SCRL",scrollreadyflag
		bne.s	nixscrollready
		
		move.l	screen1,a0
		lea	177*160(a0),a0
		move.l	screen2,a1
		lea	177*160(a1),a1
		move.l	screen3,a2
		lea	177*160(a2),a2
		move.l	screen4,a3
		lea	177*160(a3),a3
		lea	scrollsavebuff,a4
		move.l	(a4)+,grafik1
		move.l	(a4)+,grafik2
		move.l	(a4)+,textpos
		move.w	(a4)+,scrollcount
		move.w	(a4)+,screennumm


		move.w	#[23*40]-1,d1
copybuff2:	move.l	(a4)+,(a0)+
		move.l	(a4)+,(a1)+
		move.l	(a4)+,(a2)+
		move.l	(a4)+,(a3)+
		dbra	d1,copybuff2
		bra	scrollrest
				

nixscrollready:	lea	text,a0
		bsr	makescrolling		
scrollrest:	move.l	#vbl2,$70.w
		moveq	#0,d0
		move.w	text_y,d0
		divu	#9*40,d0
		mulu	#9*40,d0
		move.w	d0,text_y

mainloop:       tst.w   endflag
                beq.s   mainloop

ende:
                bsr     hbl_off

		moveq	#0,d0
		jsr	music

		if	diskversion=0
                move.b  #0,$ffff820a.w		; Sync=60hz
                move.b  #1,$ffff8260.w		; Midres
                movem.l oldpal,d0-d7
                movem.l d0-d7,$ffff8240.w    ; alte Palette
		endif
                
		if	diskversion=0
		move.l	#keyexit,tx_point
		move.w	#1,tx_count
		bsr	send
		endif

		if	diskversion=0
                move.l  #$3f8000,d0
		else
		move.l	#$78000,d0
		endif
                bsr     setscreen

		moveq	#0,d1
		move.w	text_y,d1
		move.w	d1,balkenpos
		divu	#9*40,d1
		lea	screenliste,a0
		moveq	#0,d0
		move.b	(a0,d1.w),d0
		
		
		IF	diskversion=1
		cmp.l	#"MEGA",megaflag
		bne.s	nixmegada
		ENDIF

		move.l	screen1,a0
		lea	177*160(a0),a0
		move.l	screen2,a1
		lea	177*160(a1),a1
		move.l	screen3,a2
		lea	177*160(a2),a2
		move.l	screen4,a3		; Scrollbuffer kopieren
		lea	177*160(a3),a3
		lea	scrollsavebuff,a4
		move.l	grafik1,(a4)+
		move.l	grafik2,(a4)+
		move.l	textpos,(a4)+
		move.w	scrollcount,(a4)+
		move.w	screennumm,(a4)+
		move.w	#[23*40]-1,d1
copybuff:	move.l	(a0)+,(a4)+
		move.l	(a1)+,(a4)+
		move.l	(a2)+,(a4)+
		move.l	(a3)+,(a4)+
		dbra	d1,copybuff
	
		move.l	#"SCRL",scrollreadyflag		


nixmegada:      if	diskversion=0
		rts
		else
		jmp	$500.w
		endif


		
backform:
; formt Bild aus Spezialformat zurck
; a0=Adresse
; d0=L„nge
                lsr.l   #3,D0                ; Length/Bitblocks
                subq.l  #1,D0
                move.l  A0,A1                ; Dest. (Atari)
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


swappointers:   ; tauscht Pointer aus
                move.w  restcount,d0
                addq.w  #1,d0
                and.w   #3,d0
                move.w  d0,restcount
                lsl.w   #2,d0
                lea     restpoint1,a0
                move.l  (a0,d0.w),d0
                move.l  d0,restwork
                rts
                

restorestars:   
                move.l  restwork,a0
                lea     anzahl*8(a0),a0         ; letztes Element
                move.w  #anzahl-1,d0
restloop:       move.l  -(a0),d1
                move.l  -(a0),a1
                move.l  d1,(a1)
                dbra    d0,restloop
                rts
                

preshstars:     
; Sterne preshiften
; 2 Longs pro Scanline! 1 Long Maske, 1 Long Oderwert
                lea     starsgraf,a0
                lea     starpreshbuff,a1
                moveq   #2,d0                   ; 3 Sterne (Farbe 1-3)
preshstarloop0: moveq   #0,d1                   ; Shiftcount
preshstarloop1: move.l  a0,a2           
                move.w  (a2)+,d2                ; Plane 0
                lsr.w   d1,d2                   ; um d1 nach rechts
                move.w  d2,4(a1)
                move.w  d2,d3                   ; in Maske
                move.w  (a2)+,d2                ; Plane 1
                lsr.w   d1,d2                   ; um d1 nach rechts
                move.w  d2,6(a1)
                or.w    d2,d3                   ; in Maske
                not.w   d3                      ; Maske invertieren
                move.w  d3,(a1)+
                move.w  d3,(a1)+                ; 2 Mal -> 1 Long Maske
                lea     4(a1),a1
                addq.w  #1,d1
                cmp.w   #16,d1
                bne.s   preshstarloop1          ; 16 mal shiften
                lea     8(a0),a0                ; ein Stern weiter
                dbra    d0,preshstarloop0
                rts

makestars:      
; errechnet die Koordinaten (mit Drehung)
; als Ergebnis: Offset auf Screen und Offset auf Punkt
; Ende der Tabelle mit -99, Punkt nicht zeichnen bei Offset<0
; Bercksichtig ob Logo gesetzt ist oder nicht


		cmp.l	#"STAR",starsreadyflag	; schon gemacht?
		beq	dontmakestars

                lea     sourcepointtab,a5               
                lea     punkttab,a6
		lea	randomstars(pc),a4
                move.w  #anzahl-1,d6            ; maximale Anzahl
makestarloop:   move.l  a6,(a5)+
                move.l  d6,-(a7)
		move.w	(a4)+,d5
		move.w	(a4)+,d6
                move.w  #4096,d7                ; Z
                move.w  #127,d0                 ; 128 mal 32
makekoordloop:  movem.l d0-d4/d7,-(a7)
                move.w  d5,d3
                move.w  d6,d4                   ; X,Y
                bsr     rotation                ; in d5 und d6 ist x,y
                move.w  d5,-(a7)
                move.w  d6,-(a7)
                bsr     calcstars
                move.w  d3,d5                   ; Xe
                move.w  d4,d6                   ; Ye
                add.w   #160,d5                 ; Mitte
                add.w   #100,d6
                move.w  d7,d3                   ; Z
                mulu    #4,d3                   ; Maximalwert (Farbe)
                lsr.l   #8,d3 
                lsr.l   #4,d3 
                moveq   #3,d2                   ; Maximalwert-1 -> Col
                sub.w   d3,d2                   ; d5,d6=X,Y;d2=Farbe (0-3)
                subq.w  #1,d2
                bmi     nix2
                cmp.w   #319,d5                 ; "Clippen"
                bgt     nix2
                tst.w   d5
                bmi     nix2
                tst.w   d6
                bmi     nix2
                cmp.w   #199,d6
                bgt     nix2
                mulu    #160,d6
                and.l   #$ffff,d5
                ror.l   #4,d5                   
                move.w  d5,d3
                lsl.w   #3,d5                   ; d5*8
                add.w   d5,d6
                move.w  #0,d5
                rol.l   #4,d5                   ; Rest (0-15)
                move.w  d5,d4
                lsl.w   #3,d5                   ; *8 -> damit Farbe
                lsl.w   #7,d2                   ; Farbe*128
                add.w   d5,d2                   ; Offset Farbe
                move.l  screen1,a0
                add.w   d6,a0
                btst    d4,(a0)                 ; Punkt gesetzt dort?
                bne     nix2
                btst    d4,2(a0)                ; Punkt gesetzt dort?
                bne     nix2
                btst    d4,4(a0)                ; Punkt gesetzt dort?
                bne     nix2
                btst    d4,6(a0)                ; Punkt gesetzt dort?
                bne     nix2
weiternix:      move.w  d6,(a6)+                ; Offset
                move.w  d2,(a6)+                ; Farbe
                move.w  (a7)+,d6
                move.w  (a7)+,d5                ; Koord. zurck
                movem.l (a7)+,d0-d4/d7
                sub.w   #32,d7                  ; Z=Z-32
                dbra    d0,makekoordloop
                move.w  #-99,(a6)+              ; Letzte                                                                        
                move.l  (a7)+,d6
                dbra    d6,makestarloop 
                
lamertest:	if	diskversion=1
		cmp.l	#"MEGA",megaflag	; Halfmeglamer?
		bne.s	makepointer		; ja-> nix kopieren
		endif

		lea	megastars,a1		; dort sind Sterne bei MBV
		lea	punkttab,a0
		move.w	#20639,d0
copystarsup:	move.l	(a0)+,(a1)+
		move.l	(a0)+,(a1)+
		dbra	d0,copystarsup
		lea	sourcepointtab,a0
		move.w	#319,d0			; $500 Bytes
copystarsup2:	move.l	(a0)+,(a1)+
		dbra	d0,copystarsup2

		move.l	#"STAR",starsreadyflag	; Sterne berechnet...

makepointer:	lea     sourcepointtab,a5
                lea     pointtab,a6
                move.w  #anzahl-1,d7
		moveq	#0,d6
makepoint:      addq.w	#1,d6
		move.w	d6,d0
                and.w   #127,d0                 ; Pointer zuf„llig verteilen
                lsl.w   #2,d0                   ; *4
                move.l  (a5)+,a0
                add.w   d0,a0
                move.l  a0,(a6)+
                dbra    d7,makepoint            

 		rts

dontmakestars:	lea	megastars,a0		; dort sind Sterne bei MBV
		lea	punkttab,a1
		move.w	#20639,d0
copystarsdown:	move.l	(a0)+,(a1)+
		move.l	(a0)+,(a1)+
		dbra	d0,copystarsdown
		lea	sourcepointtab,a1
		move.w	#319,d0			; $500 Bytes
copystarsdown2:	move.l	(a0)+,(a1)+
		dbra	d0,copystarsdown2
		bra.s	makepointer		

               
nix2:           ; nicht plotten
                move.w  #-1,d6
                move.w  #0,d2
                bra     weiternix

                
drawstars:      lea     pointtab,a5
                lea     sourcepointtab,a6
                move.l  restwork,a3
                move.w  #anzahl-1,d7
drawstarloop:   move.l  (a5),a4
                cmp.w   #-99,(a4)               ; Ende der Tabelle?
                bne.s   punktpointok
                move.l  (a6),a4                 ; Source
punktpointok:   move.w  (a4)+,d0                ; Offset
                move.w  (a4)+,d1                ; Farbe
                move.l  a4,(a5)+
                addq.l  #4,a6                   ; a6 weiter
                move.l  workscreen,a1
                tst.w   d0
                bmi.s   nixplot
                add.w   d0,a1
                move.l  a1,(a3)+
                lea     starpreshbuff,a0
                add.w   d1,a0
                move.l  (a1),d0
                move.l  d0,(a3)+
                and.l   (a0)+,d0
                or.l    (a0)+,d0
                move.l  d0,(a1)+
                dbra    d7,drawstarloop
                rts
nixplot:        move.l  a1,(a3)+                ; nur Screen
                move.l  #0,(a3)+
                dbra    d7,drawstarloop
                rts

punktpoint:     dc.l    punkttab


		if	diskversion=0
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
		endif

randomstars:
        dc.w  $0140,$FE61,$0197,$011A,$FF81,$FFD3,$FFF1,$FE58
        dc.w  $FF08,$FF34,$FFF1,$FE0C,$FFC3,$0101,$FF61,$0111
        dc.w  $005C,$0176,$00CE,$FE04,$FE40,$008E,$FF84,$0141
        dc.w  $019B,$FE06,$FF8F,$00E4,$0158,$015A,$01BA,$00C8
        dc.w  $FF24,$01C6,$FF92,$FE8A,$FF6B,$FE46,$FF63,$0186
        dc.w  $0159,$0195,$0038,$FED8,$FED9,$FE30,$01DF,$015B
        dc.w  $0098,$FE53,$00E2,$01AC,$FE02,$FFF9,$FE8E,$FE27
        dc.w  $0143,$00DF,$00EE,$FEE8,$FF46,$FE81,$FECF,$01CA
        dc.w  $FFB9,$FE1B,$FFBD,$FE6A,$0105,$00A8,$0004,$FE24
        dc.w  $0059,$FEE6,$00B0,$0013,$01A0,$014F,$FF8C,$0115
        dc.w  $FF85,$001F,$FF25,$FFC4,$FF75,$FF54,$FEC7,$007D
        dc.w  $019B,$FEA8,$FE7D,$015B,$00E5,$0198,$FF15,$FE3C
        dc.w  $FEFD,$FF60,$FE19,$00BA,$0050,$FEFB,$01D6,$0032
        dc.w  $000A,$FF27,$0157,$01BF,$0016,$FE5E,$0069,$003F
        dc.w  $0121,$FEDC,$FF98,$004C,$FE97,$FE9F,$0030,$0043
        dc.w  $FEA4,$FF61,$003D,$003F,$FE33,$FE9F,$FE8A,$FE1E
        dc.w  $00F1,$0195,$FEA4,$017A,$014A,$013E,$00D7,$FFB0
        dc.w  $006A,$FE57,$FE2F,$FFDB,$FE3C,$015C,$0077,$FED9
        dc.w  $016D,$FE89,$FE3C,$FF44,$FF69,$01DA,$FECA,$0179
        dc.w  $005C,$FF0A,$FE2C,$FF93,$FF32,$0196,$0130,$0170
        dc.w  $0196,$00BA,$0160,$00AA,$FFF5,$FF71,$0108,$009D
        dc.w  $017A,$0078,$FF36,$FE67,$0013,$FE4B,$FFB4,$00E2
        dc.w  $006A,$FF26,$FF0F,$00AC,$01EC,$0105,$FE93,$001E
        dc.w  $FEC4,$01A3,$004C,$FF57,$FFE0,$FE7D,$FF05,$0031
        dc.w  $00EA,$00CE,$FE4B,$FE49,$004F,$0194,$FE6A,$FEFB
        dc.w  $FF3B,$0189,$006D,$0163,$0199,$012A,$FE22,$FE5C
        dc.w  $FE16,$00B3,$FE13,$0083,$FE1E,$001F,$FF8C,$0034
        dc.w  $01DD,$FF2C,$FE9B,$FF8B,$003E,$0154,$000A,$FE63
        dc.w  $FEEE,$01D3,$0166,$FE59,$FE59,$FFA7,$00FB,$FEC9
        dc.w  $01AB,$018A,$01D5,$00CF,$FECF,$01F9,$FFBF,$FF46
        dc.w  $FE73,$FF30,$FF46,$FECB,$0001,$FF2A,$01B6,$01BA
        dc.w  $01A5,$FFA4,$011A,$002F,$004D,$FE1A,$0040,$0005
        dc.w  $FFA3,$FFC8,$FEB2,$00D9,$FE14,$01AA,$00BC,$0007
        dc.w  $00CB,$007B,$FF6C,$00AB,$FFB6,$00B8,$008C,$FFA0
        dc.w  $017F,$FE9D,$FEA9,$FF83,$FF93,$FE25,$010F,$00B0
        dc.w  $FE1E,$FF0D,$FFCA,$0143,$000B,$00D1,$FFA5,$0117
        dc.w  $FF07,$FEAD,$FE2D,$01C9,$FF7E,$FF9D,$01AE,$FEB5
        dc.w  $009C,$FE5C,$0133,$00F7,$004C,$0167,$008A,$FF6A
        dc.w  $FF3B,$FEFA,$003D,$FEAB,$00D5,$0110,$0199,$0116
        dc.w  $FF46,$0166,$FEA9,$FEC7,$FF79,$0178,$FE3A,$0199
        dc.w  $011C,$FE82,$FFD8,$0129,$FE98,$017F,$FFCF,$FED3
        dc.w  $011C,$FF2D,$FF2B,$01B2,$0093,$0006,$FFB7,$FEA4
        dc.w  $FFA8,$0046,$0000,$0043,$FFC8,$FFEB,$FF52,$FEEC
        dc.w  $011E,$FEAF,$01B8,$00BA,$FE98,$000F,$0000,$018B
        dc.w  $01E0,$FF47,$FFB4,$FEF9,$FF63,$FF52,$FF21,$0061
        dc.w  $FE4D,$FEEE,$0152,$FEDE,$0089,$0095,$FE14,$014E
        dc.w  $FEC4,$FE83,$01F3,$004B,$006A,$FEB6,$FE3B,$FE32
        dc.w  $FFA7,$FEE8,$00F8,$FF1E,$0166,$0096,$00F5,$00ED
        dc.w  $0154,$00FC,$01BF,$FF39,$01DD,$0115,$FFA2,$FF5F
        dc.w  $002D,$019E,$FFAA,$007A,$002F,$FF13,$FFA2,$FF68
        dc.w  $0090,$01B0,$FE17,$FEC3,$FEBC,$0171,$FE55,$FEE8
        dc.w  $FEDF,$FE11,$0067,$01F2,$FFE5,$FF0D,$011B,$FFBF
        dc.w  $FF79,$FFA1,$01FB,$01E9,$FE08,$FEC8,$0153,$FFCC
        dc.w  $FEBD,$FF3F,$FE31,$FE86,$FF86,$FF82,$005F,$00F1
        dc.w  $010D,$01CD,$006A,$FFAB,$FEBF,$001C,$FF9E,$010D
        dc.w  $FEC7,$002A,$0007,$0136,$FE13,$FF74,$0070,$FE00
        dc.w  $004D,$FF35,$0066,$FF08,$FFE2,$006B,$0035,$01AA
        dc.w  $01FE,$FFD0,$00E8,$0102,$FE8C,$01E1,$004D,$01EB
        dc.w  $0039,$FEDA,$00EE,$FF02,$0071,$FEB6,$FE17,$00A3
        dc.w  $FF60,$0133,$FFD6,$00EA,$FFF1,$01CB,$FEF5,$FFB2
        dc.w  $FFD1,$FFBA,$0101,$FE98,$FF6C,$01FE,$0046,$00F8
        dc.w  $01EE,$FF51,$FFD0,$FFEE,$0142,$FE30,$FF6A,$FE55
        dc.w  $FE16,$00D7,$FFA1,$00CA,$FFD4,$0141,$01C1,$01A9
        dc.w  $00A8,$012B,$FFD5,$010E,$0180,$FE11,$00AB,$00D4
        dc.w  $FE06,$012F,$FFCD,$0098,$00A7,$FF81,$0187,$01B6
        dc.w  $FE8E,$01C2,$FEE7,$FF4A,$FFA9,$006F,$01B7,$FE2F
        dc.w  $FEA2,$FFC4,$0084,$0102,$00E6,$FFBC,$FE9A,$001F
        dc.w  $FEA1,$0014,$0005,$01A2,$FEBE,$0048,$0190,$0166
        dc.w  $FEEA,$FF94,$00C8,$0108,$FF91,$00F4,$FFF9,$FFE4
        dc.w  $FFDF,$FF23,$FE2E,$FF16,$01BF,$009E,$FF35,$0179
        dc.w  $01DE,$FFA1,$FF98,$FFAA,$FFA8,$FE27,$00A4,$0005
        dc.w  $0149,$01ED,$0064,$FEA6,$FFAC,$006F,$01A5,$0168
        dc.w  $FE7F,$FEE9,$FFF3,$FFE8,$002B,$FE56,$FF9A,$FF82
        dc.w  $01DF,$FF74,$01A6,$FF51,$FF86,$FEBD,$FFE2,$0033
        dc.w  $FFCB,$006D,$00DB,$00C2,$001B,$0082,$FFDD,$015B
        dc.w  $00A1,$FEB6,$00F3,$0019,$004B,$FE86,$00EB,$00DA
        dc.w  $00C3,$FF2E,$014F,$0138,$FE76,$FFA9,$006C,$0090
        dc.w  $0090,$FEB5,$014D,$FFFD,$00FC,$FECC,$FFBF,$FE5D
        dc.w  $0067,$FE2A,$004E,$004A,$FE3D,$FECD,$0046,$0021
        dc.w  $00AA,$FE6F,$01B3,$01FD,$0099,$FE8D,$FF60,$FFBC
        dc.w  $0000


makescrolling:  clr.w   scrollcount
                move.l  #font+[89*6*scanlines],grafik1 ; Space
                move.l  #font+[89*6*scanlines],grafik2 ; Space
                move.l  a0,textpos
		rts

               

scroll:         move.l  workscreen,a0
                lea     177*160(a0),a0 
                bsr     movebuffer              ; Buffer um 16 schieben
                
                move.l  workscreen,a0
                lea     177*160(a0),a0
                move.w  scrollcount,d7          ; Schiebewert
                move.l  grafik2,a1              ; neues Zeichen
                move.l  grafik1,a2              ; altes Zeichen
                bsr     nachschubpuffer         ; Rest anh„ngen            
                
                move.w  scrollcount,d1
                addq.w  #4,d1                   ; n„chster Buffer
                and.w   #15,d1                  ; nur Werte von 0-15
                bne     nixlastbuffer
                addq.l  #1,textpos
                move.l  textpos,a0
                cmp.b   #-1,(a0)                ; Ende des Textes
                bne.s   nixendetext
                lea     text,a0
nixendetext:    move.l  a0,textpos
                moveq   #0,d0
                move.b  (a0)+,d0
                mulu    #scanlines*6,d0
                lea     font,a1
                add.w   d0,a1
                move.l  a1,grafik1              ; altes Zeichen
                moveq   #0,d0
                move.b  (a0)+,d0
                cmp.b   #-1,d0
                bne.s   nixendetext2
                lea     text,a0
                move.b  (a0),d0
nixendetext2:   mulu    #scanlines*6,d0
                lea     font,a1
                add.w   d0,a1
                move.l  a1,grafik2
nixlastbuffer:  move.w  d1,scrollcount
                rts

nachschubpuffer:
; Vorbereiten des Nachschubpuffers
; in a0=Scrollbuffer            
; in a1=Neues Zeichen
; in a2=Altes Zeichen
; in d7=Scrollwert (0-15)
                
                lea     152(a0),a0              ; letzter Bitblock
                moveq   #22,d0                  ; 23 Zeilen
nachschubloop:  move.w	(a1)+,d1
		move.w	(a1)+,d2
		move.w	(a1)+,d3
                swap    d1                      ; ins Highword
                swap    d2                      ; schmeissen
                swap    d3
                move.w  (a2)+,d1                ; altes Zeichen
                move.w  (a2)+,d2
                move.w  (a2)+,d3
                rol.l   d7,d1                   ; Werte schieben
                rol.l   d7,d2
                rol.l   d7,d3
                movem.w d1-d3,(a0)              
                lea     160(a0),a0              ; eine Zeile tiefer
                dbra    d0,nachschubloop
                rts

movebuffer:
; schiebt Scrollbuffer um 16 Pixel vor
; šbergabe in a0=Scrollbuffer
                lea     8(a0),a0
                move.w  #10,d0                          ; 11*2=22
sl0:            movem.l (a0)+,d1-d7/a1-a6
                movem.l d1-d7/a1-a6,-60(a0)
                movem.l (a0)+,d1-d7/a1-a6
                movem.l d1-d7/a1-a6,-60(a0)
                movem.l (a0)+,d1-d7/a1-a5
                movem.l d1-d7/a1-a5,-56(a0)
                lea     8(a0),a0
                movem.l (a0)+,d1-d7/a1-a6
                movem.l d1-d7/a1-a6,-60(a0)
                movem.l (a0)+,d1-d7/a1-a6
                movem.l d1-d7/a1-a6,-60(a0)
                movem.l (a0)+,d1-d7/a1-a5
                movem.l d1-d7/a1-a5,-56(a0)
                lea     8(a0),a0
                dbra    d0,sl0
                movem.l (a0)+,d1-d7/a1-a6
                movem.l d1-d7/a1-a6,-60(a0)
                movem.l (a0)+,d1-d7/a1-a6
                movem.l d1-d7/a1-a6,-60(a0)
                movem.l (a0)+,d1-d7/a1-a5
                movem.l d1-d7/a1-a5,-56(a0)
                rts     





drawtext:       move.l  workscreen,a1
                lea     61*160+4(a1),a1
                lea     texttable,a0
                add.w   text_y,a0
                move.l  #160,d1
                move.w  #71,d0
copytext:       move.w  (a0)+,(a1)
                move.w  (a0)+,8(a1)
                move.w  (a0)+,16(a1)
                move.w  (a0)+,24(a1)
                move.w  (a0)+,32(a1)
                move.w  (a0)+,40(a1)
                move.w  (a0)+,48(a1)
                move.w  (a0)+,56(a1)
                move.w  (a0)+,64(a1)
                move.w  (a0)+,72(a1)
                move.w  (a0)+,80(a1)
                move.w  (a0)+,88(a1)
                move.w  (a0)+,96(a1)
                move.w  (a0)+,104(a1)
                move.w  (a0)+,112(a1)
                move.w  (a0)+,120(a1)
                move.w  (a0)+,128(a1)
                move.w  (a0)+,136(a1)
                move.w  (a0)+,144(a1)
                move.w  (a0)+,152(a1)
                add.l   d1,a1
                dbra    d0,copytext
                
                tst.w   text_add
                beq.s   nixtextadd
                subq.w  #1,text_add
                add.w   #40,text_y
                move.w  #-1,text_aktiv
                bra.s   textweiter
nixtextadd:     tst.w   text_sub
                beq.s   nixtextsub
                subq.w  #1,text_sub
                sub.w   #40,text_y
                move.w  #-1,text_aktiv
                bra.s   textweiter
nixtextsub:     clr.w   text_aktiv
textweiter:     rts
                
 
calcstars:      
; erh„lt in d5,d6,d7 x,y,z
; gibt in d3,d4 die Ebenenkoordinaten zurck
                move.l  d0,-(a7)
		move.w	#-150,d0
		muls	d0,d5
		muls	d0,d6
		sub.w	d7,d0
		divs	d0,d5
		divs	d0,d6
		move.w	d5,d3
		move.w	d6,d4
                move.l  (a7)+,d0
                rts 


maketexttable:  lea     texttable,a0
                move.w  #[zeilen*2*40]-1,d0
clrtexttable:   clr.l   (a0)+
                dbra    d0,clrtexttable
                
                lea     textzeile1,a6
                moveq   #zeilen-1,d7
                moveq   #0,d6
textoutloop:    move.l  a6,a0
                moveq   #40,d0
                moveq   #0,d1
                move.w  d6,d2
                bsr     textaus2
                lea     40(a6),a6
                addq.w  #1,d6
                dbra    d7,textoutloop
                
                rts
                        


textaus2:
; gibt Text in Texttable aus
; Parameter: in a0: Pointer auf Text
;             in d0: Laenge des Textes
;             in d1: x-Pos (0-39)
;             in d2: y-Pos (0-49) 

                movem.l d0-d7/a0-a6,-(a7)
                lea     texttable,a1
                and.l   #$ffff,d2
                moveq   #0,d3
                moveq   #0,d4
                move.w  d0,d7
                subq.w  #1,d7
                move.w  d1,d3
                ror.w   #1,d3           ; Bitblock ermitteln
                move.w  d3,d4
                lsl.w   #1,d4           ; *2 -> Bitblock
                adda.w  d4,a1
                rol.w   #1,d3           ; Rest zurck
                and.w   #1,d3
                adda.w  d3,a1           ; +1 oder 0
                mulu    #9*40,d2        ; Y-Pos
                adda.l  d2,a1
textloop2:      moveq   #0,d0
                move.b  (a0)+,d0        ; Text holen (ASCII)
                cmp.b   #0,d0           ; Ende
                beq     endtext2

		lea	chars8(pc),a4	; Zeichensatz
		move.w	d0,d4
		lsr.w	#5,d4			; Zeile/32
		lsl.w	#8,d4			; *128
		add.w	d4,a4
		and.w	#31,d0
		add.w	d0,a4
             

                moveq   #7,d6           ; 8 Scanlines
                move.l  a1,a5
copyt2:         move.b  (a4),(a5)
                lea     32(a4),a4       ; im Charscreen tiefer
                lea     40(a5),a5       ; eine Scanline tiefer
                dbra    d6,copyt2
                addq.w  #1,a1           ; nur 1 Byte weiter
                dbra    d7,textloop2
endtext2:       movem.l (a7)+,d0-d7/a0-a6
                rts

switch:         move.w  screennumm,d0
                addq.w  #1,d0
                and.w   #3,d0
                move.w  d0,screennumm
                lsl.w   #2,d0
                lea     screen1,a0
                move.l  0(a0,d0.w),d0
                move.l  d0,workscreen           
setscreen:      lsr.l   #8,d0
                move.b  d0,$ffff8203.w
                lsr.w   #8,d0
                move.b  d0,$ffff8201.w
                rts

		if	diskversion=0
vsync:          move.l  $466.w,d0
waitforstrahl:  cmp.l   $466.w,d0
                beq.s   waitforstrahl
                rts
		endif

sinus:          equ     -286
cosinus:        equ     16381

rotation:
; rotiert um Z-achse jeweils um  Winkel
; empf„ngt x und y in d3,d4
; gibt x und y wieder in d5,d6 zurck

                movem.l d0-d4/d7,-(a7)
                move.w  #sinus,d0
                move.w  #cosinus,d1
                moveq   #14,d7
                move.w  d3,d5
                move.w  d4,d6
                muls    d1,d5                   ; x*cos
                muls    d0,d6                   ; y*sin
                sub.l   d6,d5                   ; x'=x*cos-y*sin
                lsr.l   d7,d5                   ; um 14 nach rechts=X
                muls    d0,d3                   ; x*sin
                muls    d1,d4                   ; y*cos
                add.l   d3,d4
                lsr.l   d7,d4                   ; um 14 nach rechts
                move.w  d4,d6                   ; Y
                movem.l (a7)+,d0-d4/d7
                rts
cls:
; Parameter:    a0=Screenadresse

                moveq   #0,d1                ; Register l”schen
                move.l  d1,d2
                move.l  d1,d3
                move.l  d1,d4
                move.l  d1,d5
                move.l  d1,d6
                move.l  d1,d7
                move.l  d1,a1
                move.l  d1,a2
                move.l  d1,a3
                lea     200*160(a0),a0       ; auf Screenadresse unten
                move.w  #199,d0
clsloop:        movem.l d1-d7/a1-a3,-(a0)
                movem.l d1-d7/a1-a3,-(a0)
                movem.l d1-d7/a1-a3,-(a0)
                movem.l d1-d7/a1-a3,-(a0)
                dbra    d0,clsloop
                rts

hbl_on:         move    sr,-(a7)
                ori     #$0700,sr
                lea     hbl_buff,a0
                move.b  $fffffa09.w,(a0)+       ; Werte retten
                move.b  $fffffa07.w,(a0)+
                move.b  $fffffa13.w,(a0)+
                move.b  $fffffa1b.w,(a0)+
                move.b  $fffffa11.w,(a0)+
                move.b  $fffffa21.w,(a0)+
                move.b  $fffffa17.w,(a0)+
                move.b	$fffffa15.w,(a0)+
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
		bset	#6,$fffffa09.w
		bset	#6,$fffffa15.w
                move    (a7)+,sr
                rts

hbl_off:        move    sr,-(a7)
                ori     #$0700,sr
                lea     hbl_buff,a0         ; Werte zureck!
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

vbl:		movem.l	d0-d7/a0-a6,-(a7)

		lea	$ffff8240.w,a0
		moveq	#7,d0
clrpal2:	clr.l	(a0)+
		dbra	d0,clrpal2		

		cmp.l	#"STAR",starsreadyflag
		beq.s	nixvbl1

		bsr	switch

		clr.b	$fffffa1b.w
		move.b	#170,$fffffa21.w
		move.b	#8,$fffffa1b.w		
		move.l	#hbl9,$120.w

		bsr	scroll
nixvbl1:	movem.l	(a7)+,d0-d7/a0-a6
		rte

vbl2:           movem.l d0-d7/a0-a6,-(a7)
                bsr     switch

                movem.l palette,d0-d7
                movem.l d0-d7,$ffff8240.w


                move.l  blinkpoint,a0
                cmp.w   #-1,(a0)
                bne.s   nixendblink
                lea     blinkcolors,a0
nixendblink:    move.w  (a0)+,blinkcol
                move.l  a0,blinkpoint

                addq.l  #2,hblpoint2
                move.l  hblpoint2,a0
                cmp.l   #hblcol3ende,a0
                bne.s   nixendhblcol2
                lea     hblcolors3,a0
nixendhblcol2:  move.l  a0,hblpoint2
                
                clr.b   $fffffa1b.w
                move.b  #59,$fffffa21.w
                move.b  #8,$fffffa1b.w
                move.l  #hblcolors,hblpoint
                move.l  #hbl,$120.w
                
                bsr     restorestars
                bsr     scroll
                bsr     drawtext
                bsr     drawstars
                bsr     swappointers
                
		cmp.w	#hiddenscreenline*40*9,text_y
		bne.s	nixmoeglichhiddenscreen	
		move.l	hiddenkeypointer(pc),a0
		move.b	key,d0
		cmp.b	(a0)+,d0	; gleich
		bne.s	nixmoeglichhiddenscreen
		addq.l	#1,hiddenkeypointer
		cmp.b	#-1,(a0)
		beq.s	geschaffthidden	
		bra.s	nixmoeglichhiddenscreen
		
geschaffthidden:move.w	#-1,endflag		; Ende!		
		bra.s	weiter

nixmoeglichhiddenscreen:
	

weiter:         move.b  key,d0
                tst.w   text_aktiv
                bne.s   notscroll
                cmp.b   #$50,d0
                bne.s   notscrolldown
                cmp.w   #maxzeile*40*9,text_y	; unten ?
                beq.s   notscrolldown
                move.w  #8,text_add
                add.w   #40,text_y
                move.w  #-1,text_aktiv
                bra.s   endvbl
notscrolldown:  cmp.b   #$48,d0
                bne.s   notscroll
                tst.w   text_y			; oben?
                beq.s   notscroll
                sub.w   #40,text_y
                move.w  #8,text_sub
                move.w  #-1,text_aktiv
                bra.s   endvbl
notscroll:      cmp.b   #$39,d0                   ; Space?
                beq.s   space
		cmp.b	#$1c,d0			; Return
		bne.s	endvbl
space:		cmp.w	#hiddenscreenline*40*9,text_y
		beq	endvbl
		lea	screenliste,a0
		moveq	#0,d0
		move.w	text_y,d0
		divu	#9*40,d0
		move.b	(a0,d0.w),d0	; Screen holen
		tst.b	d0
		beq.s	endvbl

                move.w  #-1,endflag
endvbl:		jsr     music+$8
                addq.l  #1,$0466.w           ; System VBL ganz abgeklemmt
                movem.l (a7)+,d0-d7/a0-a6
                rte

hbl9:		clr.b	$fffffa1b.w
		movem.l	d0-d7,-(a7)
		movem.l	charpalette(pc),d0-d7
		movem.l	d0-d7,$fffff8240.w
		movem.l	(a7)+,d0-d7
		rte


newkey:		move.w	#$2500,sr
		move.w	d0,-(a7)
		move.l	a0,-(a7)
		lea	$fffffc00.w,a0
keyloop:	move.b	(a0),d0
		btst	#7,d0
		beq.s	endkey
		move.b	2(a0),d0
		move.b	d0,key
		move.b	(a0),d0
		btst	#0,d0
		bne.s	keyloop
endkey:		bclr	#6,$fffffa11.w
		move.l	(a7)+,a0
		move.w	(a7)+,d0
		rte

		if	diskversion=0
send:
        	tst.w  tx_count
        	beq    eos
        	move.l tx_point,a0
        	subq.w #1,tx_count
        	addq.l #1,tx_point
        	move.b (a0),$fffffc02.w
eos:		rts

keyinit:	dc.b	$12,$1a
keyexit:	dc.b	$8,0
		endif

hbl:            move.l  #hbl2,$120.w
                move.w  #15,hblcount
                clr.b   $fffffa1b.w
                move.b  #2,$fffffa21.w
                move.b  #8,$fffffa1b.w          
                rte
hbl2:           move.l  a0,-(a7)        
                move.l  hblpoint,a0
                move.l  (a0),$ffff8248.w
                move.l  (a0)+,$ffff824c.w
                move.l  a0,hblpoint
                move.l  (a7)+,a0
                subq.w  #1,hblcount
                bpl.s   nixendhbl
                clr.b   $fffffa1b.w
                move.b  #5,$fffffa21.w
                move.l  #hbl4,$120.w
                move.b  #8,$fffffa1b.w
nixendhbl:      rte             
                
hbl4:           move.w  blinkcol,$ffff8248.w
                move.w  blinkcol,$ffff824a.w
                move.w  blinkcol,$ffff824c.w
                move.w  blinkcol,$ffff824e.w
                clr.b   $fffffa1b.w
                move.b  #8,$fffffa21.w	;7
                move.b  #8,$fffffa1b.w
                move.l  #hbl5,$120.w
                rte
hbl5:           clr.b   $fffffa1b.w
                move.b  #1,$fffffa21.w
                move.l  #hbl6,$120.w
                move.b  #8,$fffffa1b.w
                rte
hbl6:           move.l  #$00000222,$ffff8240.w
                move.l  #$04440666,$ffff8244.w
                                
                move.l  a0,-(a7)
                move.l  hblpoint,a0
                move.l  (a0),$ffff8248.w
                move.l  (a0)+,$ffff824c.w
                move.l  a0,hblpoint
                move.l  (a7)+,a0
                clr.b   $fffffa1b.w
                move.w  #15,hblcount
                move.b  #2,$fffffa21.w
                move.l  #hbl7,$120.w
                move.b  #8,$fffffa1b.w
                rte
                                
hbl7:           move.l  a0,-(a7)        
                move.l  hblpoint,a0
                move.l  (a0),$ffff8248.w
                move.l  (a0)+,$ffff824c.w
                move.l  a0,hblpoint
                move.l  (a7)+,a0
                subq.w  #1,hblcount
                bpl.s   nixendhbl2
                clr.b   $fffffa1b.w
                move.b  #39,$fffffa21.w
                move.b  #8,$fffffa1b.w
                move.l  #hbl8,$120.w
nixendhbl2:     rte             


hbl8:           movem.l d0-d7/a0-a6,-(a7)
                movem.l charpalette,d0-d7
                movem.l d0-d7,$ffff8240.w
                clr.b   $fffffa1b.w
                lea     $ffff824e.w,a0
                lea     $ffff8209.w,a5
                lea     noptable,a6
                move.l  hblpoint2,a2
                moveq   #20,d7
                clr.l   d0
waitrand:       tst.b   (a5)
                beq.s   waitrand
                move.b  (a5),d0
                adda.l  d0,a6
                jmp     (a6)
noptable:       blk.w   100,$4e71
lastnop:        nop
                lea     (a2),a3
                nop
                nop
                nop
                nop
test:           blk.w	40,$309b		; move.w (a3)+,(a0)
                dbra    d7,lastnop
                movem.l (a7)+,d0-d7/a0-a6
                rte

hblcolors2:     dc.w    $001,$002,$003,$004,$005,$006,$007
                dc.w    $017,$027,$037,$047,$057,$067,$077
                dc.w    $177,$277
                dc.w    $277,$177,$077
                dc.w    $067,$057,$047,$037,$027,$017,$007
                dc.w    $006,$005,$004,$003,$002,$001

hblcolors3:     dc.w    $001,$002,$003,$004,$005,$006,$007
                dc.w    $107,$207,$307,$407,$507,$607,$707
                dc.w    $717,$727,$737,$747,$757,$767,$777
                dc.w    $776,$775,$774,$773,$772,$771,$770
                dc.w    $760,$750,$740,$730,$720,$710,$700
                dc.w    $600,$500,$400,$300,$200,$100,$000
                dc.w    $111,$222,$333,$444,$555,$666,$777
                dc.w    $677,$577,$477,$377,$277,$177,$077
                dc.w    $076,$075,$074,$073,$072,$071,$070
                dc.w    $060,$050,$040,$030,$020,$010,$000
                dc.w    $100,$200,$300,$410,$520,$630,$741
                dc.w    $752,$763,$774,$775,$776,$777
                dc.w    $677,$577,$477,$367,$257,$147,$036
                dc.w    $025,$014,$003,$002,$001,$000
                dc.w    $110,$220,$330,$440,$550,$660,$770
                dc.w    $771,$772,$773,$774,$775,$776,$777
                dc.w    $666,$555,$444,$333,$222,$111,$000
                

hblcol3ende:    dc.w    $001,$002,$003,$004,$005,$006,$007
                dc.w    $107,$207,$307,$407,$507,$607,$707
                dc.w    $717,$727,$737,$747,$757,$767,$777
                dc.w    $776,$775,$774,$773,$772,$771,$770
                dc.w    $760,$750,$740,$730,$720,$710,$700
                dc.w    $600,$500,$400,$300,$200,$100,$000                              


hblpoint2:      dc.l    hblcolors3

blinkcol:       dc.w    $777
blinkpoint:     dc.l    blinkcolors
blinkcolors:    dc.w    $111,$111,$222,$222,$333,$333,$444,$444
                dc.w    $555,$555,$666,$666,$777,$777
                dc.w    $666,$666,$555,$555,$444,$444,$333,$333
                dc.w    $222,$222,$111,$111,-1
hblpoint:       dc.l    hblcolors
hblcount:       dc.w    0

palette:        dc.w $0000,$0333,$0555,$0777,$0775,$0331,$0555,$0666
                dc.w $0664,$0220,$0442,$0553,$0565,$0653,$0765,$0777

starsgraf:      DC.W    $8000,$0000,$0000,$0000,$0000,$8000,$0000,$0000
                DC.W    $8000,$8000,$0000,$0000,$0000,$0000,$8000,$0000
                DC.W    $8000,$0000,$8000,$0000,$0000,$8000,$8000,$0000
                DC.W    $8000,$8000,$8000,$0000

chars8:
; Computerfont
		dc.w	$FF7C,$7C7C,$707C,$7C7C,$0000,$0000,$006C,$407C
		dc.w	$7C7C,$7C7C,$7C00,$0000,$4444,$7C0C,$0060,$7C00
		dc.w	$FF82,$8280,$8880,$8080,$8210,$0288,$8092,$A282
		dc.w	$8282,$8280,$1082,$8282,$2828,$0810,$4010,$0210
		dc.w	$FF82,$8280,$8480,$8080,$8210,$0290,$8092,$9282
		dc.w	$8282,$8280,$1082,$8282,$1010,$1010,$2010,$0210
		dc.w	$FF7C,$7C00,$007C,$7C0C,$7C00,$0060,$0000,$0000
		dc.w	$7C10,$7C7C,$0000,$0000,$0000,$0000,$1000,$0C10
		dc.w	$FF82,$8280,$8480,$8082,$8210,$8290,$8082,$9282
		dc.w	$808A,$8402,$1082,$4492,$1010,$1010,$1010,$1010
		dc.w	$FF82,$8280,$8880,$8082,$8210,$8288,$8082,$8A82
		dc.w	$8086,$8202,$1082,$28AA,$2810,$2010,$0810,$0000
		dc.w	$FF00,$7C7C,$707C,$007C,$0000,$7C00,$7C00,$047C
		dc.w	$007C,$007C,$007C,$1044,$4400,$7C0C,$0460,$1010
		dc.w	$FF00,$0000,$0000,$0000,$0000,$0000,$0000,$0000
		dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
		dc.w	$0010,$6C24,$1800,$7818,$1818,$0000,$0000,$0004
		dc.w	$7E08,$7E7C,$447E,$7E7E,$3C7E,$0000,$0800,$107E
		dc.w	$0010,$247E,$7E64,$4008,$2004,$5408,$0000,$0008
		dc.w	$4208,$4204,$4440,$4002,$2442,$1818,$1000,$0802
		dc.w	$0018,$0024,$4008,$4400,$2004,$3808,$0000,$0010
		dc.w	$4208,$0204,$4440,$4002,$2442,$0000,$203C,$0402
		dc.w	$0018,$007E,$7E10,$FE00,$2004,$7C3E,$003C,$0020
		dc.w	$4618,$7E3E,$7F7E,$7E06,$7E7E,$0000,$4000,$027E
		dc.w	$0018,$0024,$0620,$C400,$2004,$3808,$0000,$0040
		dc.w	$4618,$6006,$0C06,$4606,$4606,$1818,$203C,$0460
		dc.w	$0000,$0024,$7E06,$C400,$2004,$5408,$0000,$0080
		dc.w	$4618,$6006,$0C46,$4606,$4606,$0008,$1000,$0800
		dc.w	$0018,$0000,$1800,$FC00,$1818,$0000,$1800,$1800
		dc.w	$7E18,$7E7E,$0C7E,$7E06,$7E06,$0000,$0800,$1060
		dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0800,$0000
		dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
		dc.w	$7E3C,$3C7E,$7C7E,$7E7E,$4210,$0440,$40FE,$7E7E
		dc.w	$7E7E,$7C7E,$FE42,$6292,$4242,$7E1C,$4038,$1000
		dc.w	$5E24,$2442,$4240,$4042,$4210,$0444,$4092,$4246
		dc.w	$4242,$4442,$1042,$6292,$4242,$0210,$2008,$2800
		dc.w	$5624,$2440,$4240,$4040,$4210,$0444,$4092,$4242
		dc.w	$4242,$4440,$1042,$6292,$4242,$0210,$1008,$4400
		dc.w	$567E,$7E60,$627E,$7E66,$7E18,$067E,$60D2,$6242
		dc.w	$7E42,$7E7E,$1862,$22D2,$3C7E,$7E30,$080C,$0000
		dc.w	$5E62,$6260,$6260,$6062,$6218,$0662,$60D2,$6242
		dc.w	$6042,$6206,$1862,$24D2,$6218,$6030,$040C,$0000
		dc.w	$4062,$6262,$6260,$6062,$6218,$4662,$60D2,$6242
		dc.w	$604E,$6246,$1862,$24D2,$6218,$6230,$020C,$0000
		dc.w	$7E62,$7E7E,$7C7E,$607E,$6218,$7E62,$7ED2,$627E
		dc.w	$607E,$627E,$187E,$3CFE,$6218,$7E3C,$003C,$007E
		dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
		dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
		dc.w	$1800,$4000,$0200,$1E00,$4000,$0040,$1000,$0000
		dc.w	$0000,$0000,$1000,$0000,$0000,$0000,$0000,$0000
		dc.w	$1000,$4000,$0200,$1000,$4018,$1840,$1000,$0000
		dc.w	$0000,$0000,$1000,$0000,$0000,$000C,$1030,$0000
		dc.w	$007E,$7E7E,$7E7E,$7C7E,$7E00,$0044,$10FE,$7E7E
		dc.w	$7E7E,$7E7E,$7C42,$6292,$4262,$7E10,$1008,$0010
		dc.w	$0002,$4242,$4242,$1042,$4210,$107E,$1092,$4242
		dc.w	$4242,$4240,$1042,$6292,$4262,$0220,$1004,$3628
		dc.w	$007E,$6260,$627E,$1842,$6218,$1862,$18DA,$6262
		dc.w	$6262,$607E,$1862,$62DA,$3C62,$7E10,$1008,$D844
		dc.w	$0062,$6262,$6260,$187E,$6218,$1862,$18DA,$6262
		dc.w	$6262,$6006,$1862,$26DA,$627E,$6010,$1008,$0082
		dc.w	$007E,$7E7E,$7E7E,$1802,$6218,$0862,$18DA,$627E
		dc.w	$7E7E,$607E,$187E,$3CFE,$6202,$7E0C,$1030,$00FE
		dc.w	$0000,$0000,$0000,$007E,$0000,$3800,$0000,$0000
		dc.w	$4002,$0000,$0000,$0000,$007E,$0000,$0000,$0000

                        ;                                        ;
textzeile1:     dc.b    "                                        "
                dc.b    "                                        "
                dc.b    "                                        "
                dc.b    "                                        "
                DC.B    "----------------------------------------"
                dc.b    "         Delta Force presents           "
                dc.b    "    >>> The Syntax Terror Demo <<<      "
                DC.B    "----------------------------------------"
		dc.b	"            Sum big shapez              "
		dc.b	"               Soko-Ban                 "
		dc.b	"            Colorshock III              "
		dc.b	"              Big Border                "
		dc.b	"            Snurkel-Twister             "
		dc.b	"           The Ball-Scroller            "
		dc.b	"               Match-It!                "
		dc.b	"             Sukka-Screen               "
		dc.b	"   Are you a lamer or not? (THE test)   "
		dc.b	"             BeeCeeDee Two              "
		dc.b	"        The official greetings          "
		dc.b	"----------------------------------------"
		dc.b	" >>> I.C.C. #1  Competition-Screens <<< "
		dc.b	"----------------------------------------"
		dc.b	" Twentyfourhourscreen by Nick from TCB  "
		dc.b	" Onedayscreen by Ford Perfect from BMT  "
		dc.b	"    Realtime-Zoomer by Gigabyte-Crew    "
		dc.b	"----------------------------------------"
		dc.b	"       >>>  Guest Department <<<        "
		dc.b	"----------------------------------------"
		dc.b	"       Guestscreen by The Lost Boys     "
		dc.b	"           Guestscreen by NeXT          "
		dc.b	"    Guestscreen by The Respectables     "
		dc.b	"  Guestscreen by The Exceptions (TEX)   "
		dc.b	"         Guestscreen by Legacy          "
		dc.b	"   Multicolorsounddisplay by Level 16   "
                DC.B    "----------------------------------------"
                DC.B    "Current member status of the Delta Force"
                DC.B    "        (in alphabetical order)         "
                DC.B    "                                        "
                DC.B    "A.B.C.                      (Programmer)"
                DC.B    "Chaos, Inc.                 (Programmer)"
                DC.B    "Green Beret                 (Programmer)"
                DC.B    "New Mode                    (Programmer)"
                DC.B    "Questlord                      (Painter)"
                DC.B    "Slime                          (Painter)"
                DC.B    "----------------------------------------"
		dc.b	"       >>>> CONTACT ADDRESS: <<<<       "
		dc.b	"             PLK 136681 E               "
		dc.b	"           7050  Waiblingen             "
		dc.b	"             WEST-Germany               "
		dc.b	"----------------------------------------"
		dc.b	" Just contact us for LEGAL reasons, NO  "
		dc.b	"swapping or hacking, just demo-stuff!!!!"
		dc.b	"                                        "
		dc.b	"                                        "
		dc.b	"                                        "
                even

screenliste:
; jeweils Bytes mit der Nummer des Screens (0=kein Screen w„hlbar)
; Vorsicht!!!! bei Žnderungen im Text „ndert sich die Tabelle auch!!!!
		blk.b	4,0
		dc.b	8	; OSS
		dc.b	4	; SOKO
		dc.b	7	; COLSHOCK
		dc.b	12	; Big Border
		dc.b	15	; Snurkel
		dc.b	10	; Ballscroller
		dc.b	11	; Matchit
		dc.b	14	; Sukka
		dc.b	16	; Lamertest
		dc.b	20	; BCD2
		dc.b	3	; Greetings
		dc.b	0,0,0
		dc.b	6	; TCB
		dc.b	17	; BMT
		dc.b	13	; Zoomer
		dc.b	0,0,0
		dc.b	5	; Lost Boys
		dc.b	21	; Next
		dc.b	22	; Respectables
		dc.b	24	; Guest TEX
		dc.b	9	; Legacy
		dc.b	23	; Level 16
		dc.b	0,0,0
		dc.b	18	; Hidden
		blk.b	18,0
                even
    
charpalette:    dc.w $0000,$0765,$0654,$0543,$0432,$0321,$0210,$0542
		dc.w $0000,$0222,$0444,$0666,$0377,$0377,$0377,$0377
                
		if	diskversion=0
logofile:	dc.b	"dflogo.img",0
fontfile:	dc.b	"mfchars.img",0
musicfile:	dc.b	"madmax3.img",0
textfile:	dc.b	"text.img",0
		even
		endif

endflag:        dc.w    0

text2:
        dc.w  $5959,$2728,$2324,$0809,$5959,$0001,$2122,$2122
        dc.w  $1B1C,$2B2C,$2324,$5959,$2526,$1B1C,$5959,$2324
        dc.w  $0405,$2122,$1B1C,$1516,$1516,$5959,$0001,$191A
        dc.w  $0607,$5959,$2324,$1D1E,$0001,$0405,$0809,$5959
        dc.w  $2526,$1B1C,$5959,$2324,$0809,$1516,$0809,$0405
        dc.w  $2526,$5555,$5559,$5959,$5959,$5959,$5959,$5959
        dc.w  $5959,$5959,$5959,$5959,$5959,$5959,$5959,$5959
        dc.w  $5959,$5959,$5959,$5959,$5959,$5959,$5959,$5959
        dc.w  $5959,$5959,$5959,$5959,$5959,$5959,$5959,$5959
        dc.w  $5959,$5959,$5959,$5959,$5959,$5959,$5959,$5959
        dc.w  $5959,$5959,$5959,$5959,$5959,$5959,$5959,$5959
        dc.w  $59FF

hiddenscreenkeys:
; HEMMELHERRGOTTSJESASWILLA
		dc.b	35,18,50,50,18,38,35,18,19,19,34,24,20,20,31
		dc.b	36,18,31,30,31,17,23,38,38,30,-1
		EVEN
hiddenkeypointer:
		dc.l	hiddenscreenkeys


font:           blk.b	 12960	
dflogo:		blk.b	 8160
text:		blk.b	 10090
restbuff1:      blk.l    anzahl*2,0
restbuff2:      blk.l    anzahl*2,0
restbuff3:      blk.l    anzahl*2,0
restbuff4:      blk.l    anzahl*2,0
restpoint1:     blk.l    1,0                     ; Pointer auf Buffer
restpoint2:     blk.l    1,0                     ; Pointer auf Buffer
restpoint3:     blk.l    1,0                     ; Pointer auf Buffer
restpoint4:     blk.l    1,0                     ; Pointer auf Buffer
restcount:      blk.w    1,0
restwork:       blk.l    1,0
hbl_buff:       blk.w    10,0
music:          blk.b	 15032
screen1:        blk.l    1,0
screen2:        blk.l    1,0
screen3:        blk.l    1,0
screen4:        blk.l    1,0
screennumm:     blk.w    1,0
workscreen:     blk.l    1,0
key:		blk.w	 1,0	
if diskversion=0
oldpal:         blk.l    8,0
tx_point:	blk.l	 1,0
tx_count:	blk.w	 1,0
endif
text_y:         blk.w    1,0
text_add:       blk.w    1,0
text_sub:       blk.w    1,0
text_aktiv:     blk.w    1,0
hblcolors:      blk.l    40,0
starpreshbuff:  blk.l    2*16*3,0
texttable:      blk.b    zeilen*40*9,0
grafik1:        blk.l    1,0
grafik2:        blk.l    1,0
textpos:        blk.l    1,0
scrollcount:    blk.w    1,0
e:
