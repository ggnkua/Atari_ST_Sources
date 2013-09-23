*********************************************************************
***                                                               ***
***                    SOKO-BAN fÅr DF-Demo!!!                    ***
***                    ~~~~~~~~~~~~~~~~~~~~~~~                    ***
***               written by New Mode of Delta Force              ***
***---------------------------------------------------------------***
***            Programmerstellung begann am: 28.05.89             ***
***            Aktuelles Datum             : 04.10.90             ***
***---------------------------------------------------------------***
***              Entwickelt mit Kuma Seka-Assembler               ***
*********************************************************************
                                                                                                                                                                
diskversion=0		; bei 0=Developer, 1=Diskversion

if diskversion=0
	offset=$80000	; Developerversion in upper 512 KB
else
	offset=0
endif

of=$80000

org	$1000+offset
load	$81000

screenbase=$70000+offset
unionshift=$6e200+offset
dfshift=$69d60+offset
hightable=$65ee0+offset
hiscores=$658e0+offset
scrollbuffer=$657c8+offset

; sokodta.img nach databuff+of laden

                                                                                               
s:		if	diskversion=0		; bei Platte alles init.
		bsr	load			; File laden
		move.w	#37,-(a7)
		trap	#14
		addq.l	#2,a7
		clr.b	$ffff8260.w		; Lowres
		move.b	#2,$ffff820a.w		; 50Hz
		endif		

		bsr	loadhighscores		

		bsr	initall
		
		bsr	deselect
		
		clr.b	key
		clr.b	zeichen

waitforanykey:	move.b	key(pc),d0
		cmp.b	#01,d0			; Escape?
		beq	ende		
		cmp.b	#$39,d0			; Space?
		bne.s	notsp
		bsr	gameanfang
		clr.b	key
		bra	waitforanykey		
notsp:		move.b	zeichen(pc),d0
		btst	#7,d0			; Fire?
		beq	waitforanykey
		bsr	gameanfang
		clr.b	zeichen
		clr.b	key
		bra	waitforanykey
      

gameanfang:	move.l	#vblgame,$70.w
		move.l	#rout,musicanaus+2
     		
		movem.l	leerfeld,d0-d7
		movem.l	d0-d7,$ffff8240.w

		move.l  screen(pc),a0
                bsr     cls
		
		move.l	screen(pc),d0
		bsr	setscreen	
	
                tst.b   namebuff        
                bne.s   nameistda                    ; Name ist eingegeben
                lea     defaultname,a0
                lea     namebuff,a1
copyunknown:    move.b  (a0)+,(a1)+
                tst.b   (a0)
                bne.s   copyunknown
                clr.b   (a1)+
nameistda:

gamestart:      clr.w   hblonoff                ; HBL aus               
                clr.b   key
                clr.b   zeichen
                clr.w   balkenpos
		clr.w	exitfrommenu

                bsr     menu
		tst.w	exitfrommenu		; Escape im Menu gedrÅckt
		beq.s	notescape
		bsr	fadedown
		bsr	endgame
		rts		
		
notescape:	bsr	fadedown
game:           
                move.l #anitab,anipos           ; fÅr grinsen
                move.l #anitab2,anipos2         ; fÅr OH
                move.l #anitab3,anipos3         ; fÅr Nicken

                move.l  screen(pc),a0
                bsr     cls
                moveq   #0,d0
                move.w  currentlevel,d0
                subq.w  #1,d0
                mulu    #306,d0
                lea     daten,a0
                add.l   d0,a0
                move.l  a0,levelpointer

                bsr     copylevel
                bsr     createlevel          ; Baut Level auf
                bsr     getendfelder         ; Endefelder in Tabelle
                bsr     koord_umr
                clr.l   restorebuff
                clr.l   clearpos
                bsr     draw_smilie
                clr.b   key
                clr.b   zeichen
                clr.w   moves
                clr.w   pushes
                clr.w   delay
                lea     statustext,a0
                moveq   #-1,d0
                moveq   #0,d1
                moveq   #24,d2
                bsr     textaus
                move.w  currentlevel,d0
                bsr     hex_dez
                lea     dezzahl+4,a0
                moveq   #2,d0
                moveq   #7,d1
                moveq   #24,d2
                bsr     textaus
                lea     palette(pc),a6
                bsr     fadeup

waitkeyloop:    move.b  key(pc),d0              ; Hauptschleife
                moveq   #0,d1
                lea     keytab,a0
testkey:        tst.b   (a0)
                bmi.s   nokeyfound
                cmp.b   (a0)+,d0
                beq     keyfound
                addq.w  #4,d1
                bra.s   testkey
nokeyfound:     move.b  zeichen(pc),d0          ; Joystick 1
                btst    #0,d0
                bne     cursorup
                btst    #1,d0
                bne     cursordown
                btst    #2,d0
                bne     cursorleft
                btst    #3,d0
                bne     cursorright
                bsr     vsync
                addq.w  #1,delay                ; ZÑhlzeit ?
                cmp.w   #300,delay              ; 7 Sekunden vergangen? 
                blt     waitkeyloop
                move.l  anipos,a1
                cmp.l   #-1,(a1)
                bne.s   nixendeanitab
                move.l  #anitab,anipos
                clr.w   delay
                bra     waitkeyloop
nixendeanitab:  move.l  (a1)+,a0
                move.l  a1,anipos
                bsr     smiliezungezeichen
                bra     waitkeyloop

mainloop:       move.l  #anitab,anipos
                cmp.w   #9999,moves
                bge.s   gameover                ; zu viele ZÅge!
                clr.w   delay
                bsr     getendfelder2           ; wieviele Endfelder ?
                move.w  nochda,d0
                tst.w   d0
                bne     waitkeyloop
                bra     completed               ; alle geschafft!

gameover:       movem.l leerfeld,d0-d7          ; Farben auf 0
                movem.l d0-d7,$ffff8240.w
                move.l  screen(pc),a0
                bsr     cls
                lea     gameovertxt,a0          ; zu viele moves!
                moveq   #-1,d0
                moveq   #1,d1
                moveq   #12,d2
                bsr     textaus
                lea     palette(pc),a6
                bsr     fadeup
                moveq   #100,d7                 ; 2 Sekunden warten
waitabit:       bsr     vsync
                dbra    d7,waitabit
                bra     game                    ; Level neustarten

newmuzak1:      move.b #7,$ffff8800.w
                move.b #255,$ffff8802.w

                move.l #nothing,musicanaus+2
                bsr     vsync
                lea     music1,a0
                lea     $60000,a1
                move.w  #2927,d0
copynewmus:     move.b  (a0)+,(a1)+
                dbra    d0,copynewmus
                moveq   #0,d0
                bsr     clear
                bsr     vsync
                move.l  #rout,musicanaus+2
                bra     waitkeyloop

newmuzak2:      move.b  #7,$ffff8800.w
                move.b  #255,$ffff8802.w
                move.l  #nothing,musicanaus+2
                bsr     vsync
                lea     music2,a0
                lea     $60000,a1
                move.w  #3007,d0
copynewmus2:    move.b  (a0)+,(a1)+
                dbra    d0,copynewmus2
                moveq   #0,d0
                bsr     clear
                bsr     vsync
                move.l  #rout,musicanaus+2
                bra     waitkeyloop

setscreen:	lsr.l 	#8,d0
                move.b 	d0,$ffff8203.w
                lsr.w  	#8,d0
                move.b 	d0,$ffff8201.w
		rts


initall:        
		movem.l	leerfeld,d0-d7
		movem.l	d0-d7,$ffff8240.w

                lea     music3,a0
                lea     $60000,a1
                move.w  #4015,d0
copymus1:       move.b  (a0)+,(a1)+
                dbra    d0,copymus1

                move.l  #screenbase,d0       ; spÑter rausschmeissen!
                move.l  d0,screen2
                add.l	#32000,d0
		move.l	d0,screen
		bsr	setscreen

		move.l	screen(pc),a0
		bsr	cls
		move.l	screen2(pc),a0
		bsr	cls
            
                move.l 	#rout,musicanaus+2
		moveq 	#0,d0
                bsr 	clear
        
                move.w 	#1,currentlevel
		clr.w	hblonoff
		clr.w	highy			; dort Highscoretab.
		clr.w	highscoremade		; öberhaupt Highscore?

		clr.w	scrollzeichen
		move.l	#scrolltext,textpos

		lea	scrollbuffer,a0
		move.w	#[7*20]-1,d0
clrscrollbuff:	clr.w	(a0)+
		dbra	d0,clrscrollbuff
		
                move.l  screen(pc),clrpos1
                move.l  screen2(pc),clrpos2
                move.l  screen(pc),clr2pos1  ; dort wird gelîscht
                move.l  screen2(pc),clr2pos2

                bsr     shiftunionlogo          ; preshiftet Logo
                bsr     shiftdflogo

                bsr     hbl_on
		
		move.l	#keyinit,tx_point
		if	diskversion=0
		move.w	#2,tx_count
		else
		move.w	#1,tx_count
		endif
		bsr	send

                rts

		
newmuzak3:      move.b  #7,$ffff8800.w
                move.b  #255,$ffff8802.w
                move.l  #nothing,musicanaus+2
                bsr     vsync
                lea     music3,a0
                lea     $60000,a1
                move.w  #4015,d0
copynewmus3:    move.b  (a0)+,(a1)+
                dbra    d0,copynewmus3
                moveq   #0,d0
                bsr     clear
                bsr     vsync
                move.l  #rout,musicanaus+2
                bra     waitkeyloop

muzakaus:       move.b  #7,$ffff8800.w
                move.b  #255,$ffff8802.w
                move.l  #nothing,musicanaus+2
                bsr     vsync
                bra     mainloop

completed:      bsr     vsync                   ; Level geschafft
                move.l  anipos3,a1
                cmp.l   #-1,(a1)
                bne.s   nixendeanitab3
                move.l  #anitab3,anipos3
                bra     completedready          ; zeichnet Nicken
nixendeanitab3: move.l  (a1)+,a0
                move.l  a1,anipos3
                bsr     smiliezungezeichen
                bra.s   completed
completedready:
                bsr     fadedown
		bsr	fadewhitetoblack

                move.l  screen(pc),a0
                bsr     cls

                lea     geschaffttext,a6
                moveq   #7,d7                   ; 8 Zeilen
                moveq   #7,d6
printloop:      move.l  a6,a0
                moveq   #20,d0                  ; 20 Zeichen
                moveq   #0,d1                   ; x=0
                move.w  d6,d2                   ; y
                bsr     textaus2
                add.w   #25,d6
                lea     20(a6),a6
                dbra    d7,printloop


                move.w  currentlevel,d0
                bsr     hex_dez

                lea     dezzahl+4(pc),a0
                moveq   #2,d0
                moveq   #12,d1
                move.w  #57,d2
                bsr     textaus2

                move.w  moves,d0
                bsr     hex_dez
                
                bsr     killzeros                       ; lîscht NULLER
                
                lea     dezzahl+2(pc),a0
                moveq   #4,d0
                moveq   #3,d1
                move.w  #107,d2
                bsr     textaus2        

                move.w  pushes,d0
                bsr     hex_dez
                
                bsr     killzeros                       ; lîscht NULLER
                
                lea     dezzahl+2(pc),a0
                moveq   #4,d0
                moveq   #5,d1
                move.w  #132,d2
                bsr     textaus2        

                move.w  currentlevel,d0
                subq.w  #1,d0
                mulu    #24,d0                          ; Highscoretab
                lea     hiscores,a0
                add.w   d0,a0
                move.w  20(a0),d0                       ; Moves
                add.w   22(a0),d0                       ; +Pushes
                move.w  moves,d1
                add.w   pushes,d1
                cmp.w   d0,d1
                bge.s   nonewhigh

                move.w  moves,20(a0)
                move.w  pushes,22(a0)
                
		move.w	#-1,highscoremade		; spÑter saven


                move.l  a0,a1
                moveq   #19,d0
clrnameinhigh:  clr.b   (a1)+                           ; alter Name weg
                dbra    d0,clrnameinhigh
                                
                lea     namebuff,a1
copynameinhigh: move.b  (a1)+,(a0)+
                bne.s   copynameinhigh

                lea     newhightext,a0                  ; HIGHSCORE!!!
                moveq   #20,d0
                moveq   #0,d1
                move.w  #157,d2
                bsr     textaus2
                
nonewhigh:      lea     colortab2,a0
                move.w  #[8*3]-1,d0
clrcolortab:    clr.w   (a0)+
                dbra    d0,clrcolortab          

                move.w  #1,hblonoff                     ; HBL an
       
                bsr     colortext

wait:           btst    #7,zeichen                      ; Feuer?
                bne.s   waitende
                cmp.b   #$39,key                        ; auf Space wart
                bne.s   wait

waitende:       move.l  screen(pc),a6
                lea     198*160(a6),a5                  ; unten!
                moveq   #49,d0                          ; 2*50*2 Zeilen
                movem.l leerfeld,d2-d7/a0-a1
ritschratsch:   move.l  a6,a2
                move.l  a5,a3
                moveq   #9,d1
ritschratsch2:  movem.l d2-d7/a0-a1,(a2)        
                lea     32(a2),a2
                movem.l d2-d7/a0-a1,(a3)        
                lea     32(a3),a3
                dbra    d1,ritschratsch2
                lea     2*160(a6),a6
                lea     -2*160(a5),a5
                bsr     vsync
                dbra    d0,ritschratsch 

                clr.w   hblonoff                        ; HBL aus

                bsr     vsync
                movem.l leerfeld,d0-d7
                movem.l d0-d7,$ffff8240.w
		bsr	fadeblacktowhite

                bra     newlevel3                               


killzeros:      ; lîscht fÅhrende Nullen in Dezzahl
                moveq   #5,d0                           ; 6 Zahlen
                lea     dezzahl(pc),a0
killzeroloop:   move.b  (a0),d1
                cmp.b   #'0',d1
                bne.s   killzeroover
                move.b  #' ',(a0)+
                dbra    d0,killzeroloop
killzeroover:   rts


colortext:      ; zieht Farben fÅr Text hoch

                moveq   #7,d7                       ; 8 Paletten
                lea     colortab,a3                 ; dort Farben
                lea     colortab2,a4

fadetextup:     bsr     vsync
                bsr     vsync
                bsr     vsync
                
                moveq   #2,d6                           ; 3 Farbwerte           
                move.l  a3,a5
                move.l  a4,a6
colfadeloop:    move.w  (a6),d0                         ; aktuelle Farbe
                move.w  (a5),d1                         ; Zielfarbe
                move.w  d0,d2
                and.w   #$007,d0                        ; nur Blauwert
                and.w   #$007,d1
                cmp.w   d0,d1
                beq.s   blue_ok
                addq.w  #1,d2                           ; Blau+1
blue_ok:        move.w  (a6),d0                         ; aktuelle Farbe
                move.w  (a5),d1                         ; Zielfarbe
                and.w   #$070,d0                        ; nur GrÅnwert
                and.w   #$070,d1
                cmp.w   d0,d1
                beq.s   green_ok
                add.w   #$010,d2                        ; GrÅn+1
green_ok:       move.w  (a6),d0                         ; aktuelle Farbe
                move.w  (a5)+,d1                        ; Zielfarbe
                and.w   #$700,d0                        ; nur Rotwert
                and.w   #$700,d1
                cmp.w   d0,d1
                beq.s   red_ok
                add.w   #$100,d2                        ; Rot+1
red_ok:         move.w  d2,(a6)+                        ; Farbwert Neu
                dbra    d6,colfadeloop  
                move.l  a3,a0
                move.l  a4,a1
                moveq   #2,d0
compare:        move.w  (a0)+,d1
                cmp.w   (a1)+,d1
                bne.s   fadetextup              
                dbra    d0,compare
                lea     6(a3),a3                        ; nÑchste Farben
                lea     6(a4),a4
                dbra    d7,fadetextup

                rts

keyfound:       lea routinen,a0
                move.l 0(a0,d1.w),a0
                jmp (a0)

restartlevel:   move.l  $466.w,d0
                and.l   #3,d0
                lea     undotab,a0
                lsl.w   #2,d0
                add.w   d0,a0
                move.l  (a0),anipos2

restartlevel2:  bsr     vsync
                move.l  anipos2,a1
                cmp.l   #-1,(a1)
                bne     nixendanitab2
                move.l  #anitab2,anipos2
                bsr     fadedown
                bra     game
nixendanitab2:  move.l  (a1)+,a0
                move.l  a1,anipos2
                bsr     smiliezungezeichen
                bra     restartlevel2


newlevel:       addq.w  #1,currentlevel
                cmp.w   #51,currentlevel
                bne     game
                move.w  #1,currentlevel
                bra     game

newlevel3:      addq.w  #1,currentlevel
                cmp.w   #51,currentlevel
                bne     game
                bra     endgame              ; bei Level 50=Ende

newlevel2:      subq.w  #1,currentlevel
                cmp.w   #0,currentlevel
                bne     game
                move.w  #50,currentlevel
                bra     game    

endgame:	move.l	screen(pc),a0
		bsr	cls
		move.l	screen2(pc),a0
		bsr	cls
		move.l	#vblintro,$70.w
		rts


cryptscores:    lea     hiscores,A0
                move.w  #[3*128]-1,D0
                move.l  #$30d7f460,D1
cryptloop:      eor.l   D1,(A0)+
                add.l   #$327465,D1
		ror.l	#7,d1
                dbra    D0,cryptloop
                rts

loadhighscores:
; LÑdt Hiscores von Seite 0,Track 81,Sektor 8-10
		
		if	diskversion=1

		bsr	select			; Drive A selektieren

		bsr	seektrack81		; Auf Spur 81 fahren

		bsr	readsectors

		bsr	cryptscores		; EntschlÅsselt Scores

		rts		

		endif


		if	diskversion=0		

		lea	hiscores,a0
		moveq	#49,d0
mhtl0:		lea	dev_name,a1
		moveq	#19,d1			; Create Highscores
copy_dev:	move.b	(a1)+,(a0)+
		dbra	d1,copy_dev
		move.w	#9999,(a0)+
		move.w	#9999,(a0)+
		dbra	d0,mhtl0

		rts

dev_name:	dc.b	"NEW MODE OF DELTA F."
		even
		
		endif


writehighscores:
; schreibt Hiscores von Seite 0,Track 81,Sektor 8-10
		
		if	diskversion=1
		
		bsr	select			; Drive A selektieren

		bsr	seektrack81		; Auf Spur 80 fahren

		bsr	writesectors

		move.w	d0,status		; wenn Bit 6=0->OK
						; sonst Writeprot.
		endif

		if	diskversion=0
		clr.w	status			; everything ok!
		endif			

		rts


readsectors:	move.w	#$84,$ffff8606.w	; Sektorreg.
		moveq	#8,d7
		bsr	writefdc
		
		pea	hiscores
		move.b	3(a7),$ffff860d.w	; Adresse setzen
		move.b	2(a7),$ffff860b.w
		move.b	1(a7),$ffff8609.w
		lea	4(a7),a7

		move.w	#$90,$ffff8606.w	; Togglen
		move.w	#$190,$ffff8606.w
		move.w	#$90,$ffff8606.w

		move.w	#3,$ffff8604.w		; 3*512 Bytes

		move.w	#$80,$ffff8606.w	; Command
		move.w	#$90,d7
		bsr	writefdc

		bsr	waitdma

		rts


status:		dc.w	0

writesectors:	move.w	#$184,$ffff8606.w	; Sektorreg.
		moveq	#8,d7			; ab Sektor 8
		bsr	writefdc
		
		pea	hiscores
		move.b	3(a7),$ffff860d.w	; Adresse setzen
		move.b	2(a7),$ffff860b.w
		move.b	1(a7),$ffff8609.w
		lea	4(a7),a7

		move.w	#$190,$ffff8606.w	; Togglen
		move.w	#$90,$ffff8606.w
		move.w	#$190,$ffff8606.w

		move.w	#3,$ffff8604.w		; 3*512 Bytes

		move.w	#$180,$ffff8606.w	; Command
		move.w	#$b0,d7			; Write Sektor (Mult)
		bsr	writefdc

		bsr	waitdma

		move.w	#$80,$ffff8606.w	; Status
		move.w	$ffff8604.w,d0

		rts

		
		
		

seektrack81:	
		move.w	#$80,$ffff8606.w
		moveq	#3,d7			; Restore
		bsr	writefdc
		bsr	waitdma

		move.w	#$86,$ffff8606.w	; Datareg.
		moveq	#81,d7			; Track 81
		bsr	writefdc

		move.w	#$80,$ffff8606.w	; Commandreg.
		moveq	#$17,d7			; Seek mit Verify
		bsr	writefdc

		bsr	waitdma

		rts

waitdma:	move.l	#$60000,d0
warteloop:	subq.l	#1,d0
		beq.s	waitfertig
		btst	#5,$fffffa01.w
		bne.s	warteloop
waitfertig:	rts

writefdc:	blk.w	3,$4e71
		move.w	d7,$ffff8604.w
		blk.w	3,$4e71
		rts	

select:		move.w	sr,-(a7)
		ori.w	#$0700,sr
		moveq	#2,d0			; Laufwerk A
		eor.b	#7,d0
		and.b	#7,d0
		move.b	#14,$ffff8800.w
		move.b	$ffff8802.w,d1
		and.b	#$f8,d1
		or.b	d0,d1
		move.b	d1,$ffff8802.w
		move.w	(a7)+,sr
		rts

deselect:	lea	$ffff8604.w,a0
		move.w	#$80,2(a0)
getstat:	move.w	(a0),d0
		btst	#7,d0
		bne.s	getstat	
		move.w	sr,-(a7)
		ori.w	#$0700,sr
		move.b	#14,$ffff8800.w
		move.b	$ffff8802.w,d1
		and.b	#$f8,d1
		or.b	#7,d1
		move.b	d1,$ffff8802.w
		move.w	(a7)+,sr
		rts


ende:		move.l	#nixdovbl,$70.w
		
                move.b #7,$ffff8800.w		; Sound aus
                move.b #255,$ffff8802.w
		lea 	$ffff8800.w,a1		; BLANK SOUNDCHIP
		move.l 	#$8080000,(a1)
		move.l 	#$9090000,(a1)
		move.l 	#$A0A0000,(a1)
		
		movem.l	menupalette,d0-d7
		movem.l	d0-d7,$ffff8240.w

		move.l	screen(pc),a0
		bsr	cls

		move.l	screen(pc),d0
		bsr	setscreen
		
		tst.w	highscoremade
		beq	allesklar2		; nix saven!

		bsr	cryptscores		; Hiscores verschlÅsseln

writescoreloop:	bsr	fadedown
		move.l	screen(pc),a0
		bsr	cls
		
		lea	menupalette,a6
		bsr	fadeup

		lea	savemessage,a0
		moveq	#18,d0
		moveq	#1,d1
		move.w	#80,d2
		bsr	textaus2

		bsr	vsync
		bsr	vsync
		bsr	vsync
		bsr	vsync

		bsr	writehighscores
		move.w	status(pc),d0
		btst	#6,d0			; Writeprotect?
		beq	allesklar		
		
		bsr	fadedown
		move.l	screen(pc),a0
		bsr	cls

		lea	menupalette,a6
		bsr	fadeup
		bsr	printwpmess		; Nachricht ausgeben

		clr.b	key
waithere:	move.b	key(pc),d0
		cmp.b	#$39,d0			; bei Space nochmal
		beq.s	writescoreloop		
		cmp.b	#01,d0			; Escape=Quit
		bne.s	waithere

allesklar:	bsr	deselect
allesklar2:
		bsr 	hbl_off

		move.l	#keyexit,tx_point
		if	diskversion=0
		move.w	#3,tx_count		; Maus an
		else
		move.w	#1,tx_count
		endif
		bsr	send

		if	diskversion=1
                move.l  #$78000,d0
		else
		move.l	#$3f8000,d0
		endif
		bsr	setscreen         
		if	diskversion=1
		lea	$78000,a0
		bsr	cls
		else
		move.b	#0,$ffff820a.w		; 60Hz
		move.b	#1,$ffff8260.w		; Midres
		move.l	#$07770700,$ffff8240.w
		move.l	#$00500000,$ffff8244.w
		illegal
		endif
ganzraus:       moveq	#0,d0			; zurÅck in Laderoutine
		jmp	$500


printwpmess:	lea	wpmessage1,a0
		moveq	#20,d0
		moveq	#0,d1
		moveq	#60,d2
		bsr	textaus2
		lea	wpmessage2,a0
		moveq	#20,d0
		moveq	#0,d1
		move.w	#90,d2
		bsr	textaus2
		lea	wpmessage3,a0
		moveq	#20,d0
		moveq	#0,d1
		move.w	#120,d2
		bsr	textaus2
		lea	wpmessage4,a0
		moveq	#20,d0
		moveq	#0,d1
		move.w	#150,d2
		bsr	textaus2
		rts
		

fadedown:	; blendet auf Weiû hoch, dann auf Schwarz runter
		lea	$ffff8240.w,a0
		moveq	#15,d0			; 16 Farben
fadedownloop:	move.w	(a0),d1
		move.w	d1,d2
		and.w	#7,d2			; Blauwert
		cmp.w	#7,d2			; schon maximal?
		beq.s	col2
		addq.w	#1,d1			; sonst Blau+1
col2:		move.w	d1,d2
		and.w	#$070,d2		; GrÅnwert
		cmp.w	#$070,d2
		beq.s	col3
		add.w	#$010,d1		; GrÅn+1
col3:		move.w	d1,d2
		and.w	#$700,d2
		cmp.w	#$700,d2
		beq.s	col4
		add.w	#$100,d1
col4:		move.w	d1,(a0)+		; Farbwert speichern
		dbra	d0,fadedownloop
		bsr	vsync
		bsr	vsync
		bsr	vsync		
		lea	$ffff8240.w,a0
		moveq	#15,d0			; 16 Farben
testcolors:	move.w	(a0)+,d1
		and.w	#$777,d1
		cmp.w	#$777,d1		; schon weiû?
		bne.s	fadedown    	
		dbra	d0,testcolors
		rts
fadewhitetoblack:
		moveq	#6,d1			; 7mal von $7 auf $0
whitetoblack:	moveq	#15,d0			; 16 Farben
		lea	$ffff8240.w,a0
whitetoblack2:	move.w	(a0),d2
		and.w	#$777,d2
		sub.w	#$111,d2
		move.w	d2,(a0)+
		dbra	d0,whitetoblack2
		bsr	vsync
		bsr	vsync
		bsr	vsync
		dbra	d1,whitetoblack
		rts

fadeblacktowhite:
		moveq	#6,d1			; 7mal von $0 auf $7
blacktowhite:	moveq	#15,d0			; 16 Farben
		lea	$ffff8240.w,a0
blacktowhite2:	move.w	(a0),d2
		and.w	#$777,d2
		add.w	#$111,d2
		move.w	d2,(a0)+
		dbra	d0,blacktowhite2
		bsr	vsync
		bsr	vsync
		bsr	vsync
		dbra	d1,blacktowhite
		rts
fadeup:	; in a6=Palette
		lea	$ffff8240.w,a0
		moveq	#15,d0
makewhite:	move.w	#$777,(a0)+
		dbra	d0,makewhite

fadeuploop:	move.l	a6,a1			; Palette
		lea	$ffff8240.w,a0
		moveq	#15,d0			; 16 Farben
fadeuploop2:	move.w	(a0),d1
		move.w	(a1)+,d2		; Palettenwert
		move.w	d1,d3
		move.w	d2,d4
		and.w	#$007,d3
		and.w	#$007,d4
		cmp.w	d4,d3
		beq.s	colgreen
		subq.w	#1,d1
colgreen:	move.w	d1,d3
		move.w	d2,d4
		and.w	#$070,d3
		and.w	#$070,d4
		cmp.w	d4,d3
		beq.s	colred
		sub.w	#$010,d1
colred:		move.w	d1,d3
		move.w	d2,d4
		and.w	#$700,d3
		and.w	#$700,d4
		cmp.w	d4,d3
		beq.s	colok
		sub.w	#$100,d1
colok:		move.w	d1,(a0)+
		dbra	d0,fadeuploop2		
		bsr	vsync
		bsr	vsync
		bsr	vsync
		move.l	a6,a1
		lea	$ffff8240.w,a0
		moveq	#15,d0
compcolors:	move.w	(a0)+,d1
		move.w	(a1)+,d2
		and.w	#$777,d1
		and.w	#$777,d2
		cmp.w	d1,d2
		bne	fadeuploop
		dbra	d0,compcolors
		rts


clrlogos:       move.l  clrpos1,a0
                moveq   #39,d0                  ; 40 Zeilen
                moveq   #0,d1
clrunilogo:     move.w  d1,(a0)
                move.w  d1,8(a0)
                move.w  d1,16(a0)
                move.w  d1,24(a0)
                move.w  d1,32(a0)
                move.w  d1,40(a0)
                move.w  d1,48(a0)
                lea     160(a0),a0
                dbra    d0,clrunilogo
                move.l  clr2pos1,a0
                moveq   #60,d0                  ; 61 Zeilen
                moveq   #0,d1
clrdflogo:      move.w  d1,(a0)
                move.w  d1,8(a0)
                move.w  d1,16(a0)
                move.w  d1,24(a0)
                move.w  d1,32(a0)
                move.w  d1,40(a0)
                move.w  d1,48(a0)
                move.w  d1,56(a0)
                move.w  d1,64(a0)
                move.w  d1,72(a0)
                lea     160(a0),a0
                dbra    d0,clrdflogo
                rts
                

wuchtunilogo:   addq.l  #2,dpos2
                move.l  dpos2(pc),a2
                cmp.l   #enddelta,a2
                bne.s   nixenddelta2
                lea     delta(pc),a2
nixenddelta2:   move.l  a2,dpos2

                move.l  screen(pc),a1
                lea     6(a1),a1                ; letzte Plane

                addq.l  #4,dpos3
                move.l  dpos3(pc),a3
                cmp.w   #-99,(a3)
                bne.s   nixenddelta3
                lea     lissa2(pc),a3
nixenddelta3:   move.l  a3,dpos3
                move.w  (a3)+,d7
                add.w   (a3)+,a1                ; y
                moveq   #0,d0
                move.w  d7,d0
                ror.l   #4,d0
                lsl.w   #3,d0
                add.w   d0,a1
                and.w   #15,d7
                move.l  a1,clrpos1
                lea     unionshift,a3
                moveq   #39,d0                  ; 40 Zeilen
ll:             move.l  a1,a4
                move.l  a3,a0
                move.w  (a2)+,d1
                add.w   d7,d1
                cmp.w   #16,d1
                blt.s   grt16                   ; grîûer als 16?
                lea     8(a4),a4                ; um 16 nach rechts
grt16:          and.w   #15,d1
                mulu    #12,d1
                add.w   d1,a0
                movem.w (a0)+,d1-d6
                or.w    d1,(a4)
                or.w    d2,8(a4)
                or.w    d3,16(a4)
                or.w    d4,24(a4)
                or.w    d5,32(a4)
                or.w    d6,40(a4)
                lea     160(a1),a1
                lea     16*12(a3),a3
                dbra    d0,ll
                
                move.l  clrpos1,d0
                move.l  clrpos2,clrpos1
                move.l  d0,clrpos2
                
                rts

wuchtdflogo:    addq.l  #2,dpos4
                move.l  dpos4(pc),a2
                cmp.l   #enddelta,a2
                bne.s   nixenddelta4
                lea     delta(pc),a2
nixenddelta4:   move.l  a2,dpos4

                move.l  screen(pc),a1
                lea     6(a1),a1                ; letzte Plane

                addq.l  #4,dpos5
                move.l  dpos5(pc),a3
                cmp.w   #-99,(a3)
                bne.s   nixenddelta5
                lea     lissa(pc),a3
nixenddelta5:   move.l  a3,dpos5
                move.w  (a3)+,d7
                add.w   (a3)+,a1                ; y
                moveq   #0,d0
                move.w  d7,d0
                ror.l   #4,d0
                lsl.w   #3,d0
                add.w   d0,a1
                and.w   #15,d7
                move.l  a1,clr2pos1
                lea     dfshift,a3
                moveq   #60,d0                  ; 61 Zeilen
ll2:            move.l  a1,a4
                move.l  a3,a0
                move.w  (a2)+,d1
                add.w   d7,d1
                cmp.w   #16,d1
                blt.s   grt216                  ; grîûer als 16?
                lea     8(a4),a4                ; um 16 nach rechts
grt216:         and.w   #15,d1
                mulu    #18,d1
                add.w   d1,a0
                movem.w (a0)+,d1-d6
                move.w  d1,(a4)
                move.w  d2,8(a4)
                move.w  d3,16(a4)
                move.w  d4,24(a4)
                move.w  d5,32(a4)
                move.w  d6,40(a4)
                movem.w (a0)+,d1-d3
                move.w  d1,48(a4)
                move.w  d2,56(a4)
                move.w  d3,64(a4)
                lea     160(a1),a1
                lea     16*18(a3),a3
                dbra    d0,ll2
                
                move.l  clr2pos1,d0
                move.l  clr2pos2,clr2pos1
                move.l  d0,clr2pos2
                
                rts

shiftunionlogo:
; jede Zeile 16 mal untereinander
                lea     unionshift,a1       ; Buffer
                moveq   #39,d0                  ; 40 Zeilen
                lea     unionlogo(pc),a2
sul0:           moveq   #0,d1                   ; Shiftcounter
sul1:           move.l  a2,a0
                moveq   #4,d2                   ; 5*16=80 Pixel
                moveq   #0,d3
sul2:           moveq   #0,d4
                move.w  (a0)+,d4
                ror.l   d1,d4                   ; um d1 nach rechts
                or.w    d3,d4
                move.w  d4,(a1)+
                swap    d4
                move.w  d4,d3
                dbra    d2,sul2
                move.w  d3,(a1)+                ; letzter Rest
                addq.w  #1,d1
                cmp.w   #16,d1
                bne.s   sul1
                lea     10(a2),a2               ; eine Zeile tiefer
                dbra    d0,sul0
                rts             

shiftdflogo:
; preshiftet DFlogo 128*61
; jede Zeile 16 mal untereinander
                lea     dfshift,a1          ; Buffer
                moveq   #60,d0                  ; 61 Zeilen
                lea     dflogo(pc),a2
sdl0:           moveq   #0,d1                   ; Shiftcounter
sdl1:           move.l  a2,a0
                moveq   #7,d2                   ; 8*16=128 Pixel
                moveq   #0,d3
sdl2:           moveq   #0,d4
                move.w  (a0)+,d4
                ror.l   d1,d4                   ; um d1 nach rechts
                or.w    d3,d4
                move.w  d4,(a1)+
                swap    d4
                move.w  d4,d3
                dbra    d2,sdl2
                move.w  d3,(a1)+                ; letzter Rest
                addq.w  #1,d1
                cmp.w   #16,d1
                bne.s   sdl1
                lea     16(a2),a2               ; eine Zeile tiefer
                dbra    d0,sdl0
                rts             

drawname:
; zeichnet Sokoban auf den Bildschirm
; mit phasenverschobenen Kugeln
                addq.l  #2,dpos
                move.l  dpos(pc),a3
                cmp.l   #endtabelle,a3
                bne.s   nixenddpos
                lea     tabelle(pc),a3
nixenddpos:     move.l  a3,dpos

                lea     werte(pc),a4            ; dort sind die Pointer
                moveq   #76,d0                  ; 77 Kugeln
drawnameloop:   lea     kucheln(pc),a5
                move.w  (a3)+,d1
                add.w   d1,a5
                move.l  a3,-(a7)
                move.l  screen(pc),a6
                add.w   (a4)+,a6                ; Pointer auf Screen
                movem.l (a5)+,d1-d7/a0-a3       ; 11 Longs holen
                move.l  d1,(a6)
                move.l  d2,4(a6)
                move.l  d3,160(a6)
                move.l  d4,164(a6)
                move.l  d5,320(a6)
                move.l  d6,324(a6)
                move.l  d7,480(a6)
                move.l  a0,484(a6)
                move.l  a1,640(a6)
                move.l  a2,644(a6)
                move.l  a3,800(a6)
                movem.l (a5)+,d1-d7/a0-a3
                move.l  d1,804(a6)
                move.l  d2,960(a6)
                move.l  d3,964(a6)
                move.l  d4,1120(a6)
                move.l  d5,1124(a6)
                move.l  d6,1280(a6)
                move.l  d7,1284(a6)
                move.l  a0,1440(a6)
                move.l  a1,1444(a6)
                move.l  a2,1600(a6)
                move.l  a3,1604(a6)
                movem.l (a5)+,d1-d7/a0-a2             ; 10 Longs
                move.l  d1,1760(a6)
                move.l  d2,1764(a6)
                move.l  d3,1920(a6)
                move.l  d4,1924(a6)
                move.l  d5,2080(a6)
                move.l  d6,2084(a6)
                move.l  d7,2240(a6)
                move.l  a0,2244(a6)
                move.l  a1,2400(a6)
                move.l  a2,2404(a6)
                move.l  (a7)+,a3
                dbra    d0,drawnameloop
                rts


drawscores:	
; zeichnet Highscores auf Screen
		move.l	screen(pc),a1
		lea	60*160(a1),a1
		lea	hightable,a0
		add.w	highy,a0
		move.w	#135,d0			; 136 Zeilen
dhsl:		move.w	(a0)+,(a1)
		move.w	(a0)+,8(a1)
		move.w	(a0)+,16(a1)
		move.w	(a0)+,24(a1)
		move.w	(a0)+,32(a1)
		move.w	(a0)+,40(a1)
		move.w	(a0)+,48(a1)
		move.w	(a0)+,56(a1)
		move.w	(a0)+,64(a1)
		move.w	(a0)+,72(a1)
		move.w	(a0)+,80(a1)
		move.w	(a0)+,88(a1)
		move.w	(a0)+,96(a1)
		move.w	(a0)+,104(a1)
		move.w	(a0)+,112(a1)
		move.w	(a0)+,120(a1)
		move.w	(a0)+,128(a1)
		move.w	(a0)+,136(a1)
		move.w	(a0)+,144(a1)
		move.w	(a0)+,152(a1)
		lea	160(a1),a1
		dbra	d0,dhsl
		rts		

makehightable:	lea	hightable,a0
		move.w	#[50*2*40]-1,d0
clrhightable:	clr.l	(a0)+
		dbra	d0,clrhightable
		
		lea	hiscores,a6
		moveq	#0,d7			; 50 Namen 
putscores:	move.w	d7,d0
		addq.w	#1,d0
		bsr	hex_dez
		lea	dezzahl+4(pc),a0
		moveq	#2,d0
		moveq	#0,d1
		move.w	d7,d2
		bsr	textaus3	
		move.l	a6,a0
		moveq	#20,d0			; 24 Zeichen
		moveq	#3,d1			; X=3
		move.w	d7,d2			; Y
		bsr	textaus3
		move.w	20(a6),d0
		bsr	hex_dez
		lea	dezzahl+2(pc),a0
		moveq	#4,d0
		moveq	#29,d1
		move.w	d7,d2
		bsr	textaus3		
		move.w	22(a6),d0
		bsr	hex_dez
		lea	dezzahl+2(pc),a0
		moveq	#4,d0
		moveq	#36,d1
		move.w	d7,d2
		bsr	textaus3		
		lea	24(a6),a6
		addq.w	#1,d7
		cmp.w	#50,d7
		bne.s	putscores
		rts


nixdovbl:	clr.b	$fffffa1b.w
		addq.l	#1,$466.w
		rte
                                
vblintro:       movem.l d0-d7/a0-a6,-(a7)
                movem.l hblpaletten(pc),d0-d7
                movem.l d0-d7,$ffff8240.w
                move.l  #hblpaletten+32,hblpointer
                clr.b   $fffffa1b.w
                move.b  #15,$fffffa21.w
                move.b  #8,$fffffa1b.w
		move.l	#hblintro,$120.w
                bsr     drawname
                bsr     clrlogos
                bsr     wuchtdflogo
                bsr     wuchtunilogo
		bsr	scroll
		bsr	rout
                bsr     switch
                addq.l  #1,$0466.w           ; System VBL ganz abgeklemmt
                movem.l (a7)+,d0-d7/a0-a6
                rte


scroll:         subq.w 	#2,scrollzeichen
                bpl.s 	do_it           	; alles gescrollt?
	     	move.w 	#6,scrollzeichen
                move.l 	textpos,a0
                tst.b 	(a0)         
                bne.s 	gweiter               ; noch nicht Ende von Text
                move.l 	#scrolltext,textpos
                move.l 	textpos,a0  
gweiter:        moveq 	#0,d0
                move.b 	(a0),d0
                bsr 	berechnung            ; Speicherposition errechnen
                move.l 	a6,mempos
                addq.l 	#1,textpos

                
do_it:          
		lea	scrollbuffer+38,a0
		move.l	mempos,a2
		
		move.w 	scrollzeichen,d2       ; Anzahl wieviel gescrollt ist
                moveq 	#6,d5                  ; Anzahl der Scrollzeilen-1
scrollloop:     moveq	#0,d0
		move.b 	(a2),d0            	; 16 Pixel von Zeichen
                lsr.w 	d2,d0               	; um d2 nach rechts
                and.w 	#3,d0               	; bis auf 2 Pixel lîschen
                                          
		moveq	#19,d3
scrl:		moveq 	#0,d1
         	move.w 	(a0),d1      		; vom Quellbildschirm
         	lsl.l 	#2,d1         		; um 2 Bits nach links schieben
         	or.w 	d0,d1          		; alten Rest einodern
         	move.w 	d1,(a0)      		; abspeichern auf Zielbildschirm
         	swap 	d1             		; Hiword <-> Lowword
         	move.w 	d1,d0        		; Herausgeschobenes merken
		lea	-2(a0),a0
		dbra	d3,scrl	
                     
                lea 	80(a0),a0          	; auf Bitplane1 1 Zeile tiefer
                lea 	40(a2),a2           	; im Charscreen 1 Zeile tiefer
                
                dbra 	d5,scrollloop


		lea	scrollbuffer,a0
		move.l	screen(pc),a1
		lea	190*160(a1),a1
		move.w	#[7*20]-1,d0
copyscroller:	move.w	(a0)+,(a1)
		lea	8(a1),a1
		dbra	d0,copyscroller

                rts
 
		if	diskversion=0		; bei Platte Lader
load:           clr.w 	-(a7)
                pea 	sokofile(pc)
                move.w 	#$3d,-(a7)
                trap 	#1
                addq.l 	#8,a7
                move.w 	d0,-(a7)
                pea 	databuff
                move.l 	#$dfdfdf,-(a7)
                move.w 	d0,-(a7)
                move.w 	#$3f,-(a7)
                trap 	#1
                lea 	12(a7),a7
                move.w 	#$3e,-(a7)
                trap 	#1
                addq.l 	#4,a7
                rts
sokofile:	dc.b	"sokodta.img",0
		even
		endif


switch:		move.l	screen(pc),d0
		move.l	screen2(pc),screen
		move.l	d0,screen2
		bsr	setscreen
		rts

hblintro:       movem.l d0-d7/a0-a3,-(a7)
                clr.b   $fffffa1b.w             ; Timer Stop
                move.l  hblpointer(pc),a1
                movem.l (a1)+,d1-d7/a0             ; Farbwerte holen
                move.l  a1,hblpointer
                lea     $fffffa21.w,a1
                move.b  #16,(a1)                ; 16 Zeilen
                move.b  #8,-6(a1)               ; Timer Start
                move.b  (a1),d0
waitrand:       cmp.b   (a1),d0
                beq.s   waitrand                ; auf Ende der Zeile warten
                movem.l d1-d7/a0,$ffff8240.w
                movem.l (a7)+,d0-d7/a0-a3                                             
                rte


vsync:          move.l  d0,-(a7)
                move.l  $466.w,d0
waitstrahl:     cmp.l   $466.w,d0
                beq.s   waitstrahl
                move.l  (a7)+,d0
                rts

getendfelder:   lea endfeldtab,a1
                lea level+2,a0
                moveq #0,d0
                moveq #0,d1
suchendefeld:   cmp.b #3,(a0)
                bne.s nixendfeldfound
                addq.w #1,d1                 ; EndfeldzÑhler +1
                move.w d0,(a1)+
                bra.s nixendkisteaufblock
nixendfeldfound:cmp.b #$17,(a0)              ; oder Kiste auf Block?
                bne.s nixendkisteaufblock
                addq.w #1,d1
                move.w d0,(a1)+
nixendkisteaufblock:
                lea 1(a0),a0
                addq.w #1,d0
                cmp.w #304,d0
                bne.s suchendefeld
                move.w d1,endfeldanz
                rts

getendfelder2:  lea level+2,a0
                moveq #0,d0
                moveq #0,d1
suchendefeld2:  cmp.b #3,(a0)+
                bne.s nixendfeldfound2
                addq.w #1,d1                 ; EndfeldzÑhler +1
nixendfeldfound2:addq.w #1,d0
                cmp.w #304,d0
                bne.s suchendefeld2
                move.w d1,nochda
                rts

cursorleft:     clr.w counter
                lea level+2,a0
                moveq #0,d0
                move.w man_y,d0
                mulu #19,d0
                add.w man_x,d0                ; Dort steht das MÑnnchen
                add.w d0,a0
                cmp.b #0,-1(a0)               ; Dort Leerfeld ?
                bne.s nixmoveleft
trotzdemlinks:  bsr koord_umr
                bsr walkleft
                subq.w #1,man_x               ; auf Leerfeld bewegen
                bsr koord_umr
                bra mainloop
nixmoveleft:    cmp.b #3,-1(a0)               ; Dort Endezeichen
                beq.s trotzdemlinks           ; man kann trotzdem moven 
                cmp.b #$14,-1(a0)             ; ist dort Kiste ?
                bne.s nixnormalekistelinks
                tst.b -2(a0)                  ; Leerfeld ?
                beq.s ganznormalelinks
                cmp.b #3,-2(a0)               ; oder Endfeld ?
                bne mainloop                  ; kein Verschieben mîglich
                clr.b -1(a0)
                move.b #$17,-2(a0)            ; Kiste auf Endfeld
                subq.w #1,man_x
                bsr koord_umr
                bsr movekistelinks
                bsr koord_umr
                bsr endkistezeichenl          ; zeichnet Kiste rechts
                bsr testsmilie
                bra mainloop
ganznormalelinks:
                clr.b -1(a0)                  ; jetzt Leerfeld
                move.b #$14,-2(a0)            ; normale Kiste rechts
                subq.w #1,man_x
                bsr koord_umr
                bsr movekistelinks
                bsr koord_umr
                bsr testsmilie
                bra mainloop
nixnormalekistelinks:
                cmp.b #$17,-1(a0)             ; keine Endkiste ?
                bne mainloop
                cmp.b #3,-2(a0)               ; auf Endfeld verschieben
                beq.s verschkisteendl
                tst.b -2(a0)
                bne mainloop                  ; kein Leerfeld
                move.b #3,-1(a0)
                move.b #$14,-2(a0)
                subq.w #1,man_x
                bsr koord_umr
                bsr movekistelinks2
                bsr kistezeichenl               
                bsr koord_umr
                bsr testsmilie
                bra mainloop
verschkisteendl:                
                move.b #3,-1(a0)
                move.b #$17,-2(a0)
                subq.w #1,man_x
                bsr koord_umr
                bsr movekistelinks2
                bsr koord_umr
                bsr endkistezeichenl
                bsr testsmilie
                bra mainloop



cursorright:    clr.w counter
                lea level+2,a0
                moveq #0,d0
                move.w man_y,d0
                mulu #19,d0
                add.w man_x,d0                ; Dort steht das MÑnnchen
                add.w d0,a0
                cmp.b #0,1(a0)                ; Dort Leerfeld ?
                bne.s nixmoveright
trotzdemrechts: bsr walkright
                addq.w #1,man_x
                bsr koord_umr
                bra mainloop
nixmoveright:   cmp.b #3,1(a0)                ; Dort Endezeichen
                beq.s trotzdemrechts          ; kann sich normal bewegen
                cmp.b #$14,1(a0)              ; ist dort Kiste ?
                bne.s nixnormalekisterechts
                tst.b 2(a0)                   ; Leerfeld ?
                beq.s ganznormalerechts
                cmp.b #3,2(a0)                ; oder Endfeld ?
                bne mainloop                  ; kein Verschieben mîglich
                clr.b 1(a0)
                move.b #$17,2(a0)             ; Kiste auf Endfeld
                bsr koord_umr
                bsr movekisterechts
                addq.w #1,man_x
                bsr koord_umr
                bsr endkistezeichenr          ; zeichnet Kiste rechts
                bsr testsmilie
                bra mainloop
ganznormalerechts:
                clr.b 1(a0)                   ; jetzt Leerfeld
                move.b #$14,2(a0)             ; normale Kiste rechts
                bsr koord_umr
                bsr movekisterechts
                addq.w #1,man_x
                bsr koord_umr
                bsr testsmilie
                bra mainloop
nixnormalekisterechts:
                cmp.b #$17,1(a0)              ; keine Endkiste ?
                bne mainloop
                cmp.b #3,2(a0)                ; auf Endfeld verschieben
                beq.s verschkisteendr
                tst.b 2(a0)
                bne mainloop                  ; kein Leerfeld
                move.b #3,1(a0)
                move.b #$14,2(a0)
                bsr koord_umr
                bsr movekisterechts2
                addq.w #1,man_x
                bsr koord_umr
                bsr kistezeichenr
                bsr testsmilie
                bra mainloop
verschkisteendr:                
                move.b #3,1(a0)
                move.b #$17,2(a0)
                bsr koord_umr
                bsr movekisterechts2
                addq.w #1,man_x
                bsr koord_umr
                bsr endkistezeichenr
                bsr testsmilie
                bra mainloop
                        
testsmilie:
                bsr searchendfeld             ; schaut ob dort Endf. ist
                tst.w d0
                bne.s warendfeld1
                bsr clearsmilie
                bra.s warendfeld2               
warendfeld1:    bsr endfeldzeichen            ; restauriert Endefeld
warendfeld2:    bsr draw_smilie
                rts
endfeldzeichen: 
                lea endfeld(pc),a0
                move.l screen(pc),a1
                moveq #0,d0
                move.w man_ys,d0
                mulu #160,d0
                add.w d0,a1
                moveq #0,d0
                move.w man_xs,d0
                ror.l #4,d0
                lsl.w #3,d0
                add.w d0,a1
                bsr drawobject
                rts

endkistezeichenr:       
                lea endfeldkiste(pc),a0
                move.l screen(pc),a1
                moveq #0,d0
                move.w man_ys,d0
                mulu #160,d0
                add.w d0,a1
                moveq #0,d0
                move.w man_xs,d0
                add.w #16,d0
                ror.l #4,d0
                lsl.w #3,d0
                add.w d0,a1
                bsr drawobject
                rts

endkistezeichenl:       
                lea endfeldkiste(pc),a0
                move.l screen(pc),a1
                moveq #0,d0
                move.w man_ys,d0
                mulu #160,d0
                add.w d0,a1
                moveq #0,d0
                move.w man_xs,d0
                sub.w #16,d0
                ror.l #4,d0
                lsl.w #3,d0
                add.w d0,a1
                bsr drawobject
                rts


kistezeichenl:  
                lea kiste(pc),a0
                move.l screen(pc),a1
                moveq #0,d0
                move.w man_ys,d0
                mulu #160,d0
                add.w d0,a1
                moveq #0,d0
                move.w man_xs,d0
                ror.l #4,d0
                lsl.w #3,d0
                add.w d0,a1
                bsr drawobject
                rts


kistezeichenr:  
                lea kiste(pc),a0
                move.l screen(pc),a1
                moveq #0,d0
                move.w man_ys,d0
                mulu #160,d0
                add.w d0,a1
                moveq #0,d0
                move.w man_xs,d0
                add.w #16,d0
                ror.l #4,d0
                lsl.w #3,d0
                add.w d0,a1
                bsr drawobject
                rts


smiliezungezeichen:     
                move.l screen(pc),a1
                moveq #0,d0
                move.w man_ys,d0
                mulu #160,d0
                add.w d0,a1
                moveq #0,d0
                move.w man_xs,d0
                ror.l #4,d0
                lsl.w #3,d0
                add.w d0,a1
                bsr drawobject
                rts

endkistezeichenu:       
                lea endfeldkiste(pc),a0
                move.l screen(pc),a1
                moveq #0,d0
                move.w man_ys,d0
                add.w #12,d0
                mulu #160,d0
                add.w d0,a1
                moveq #0,d0
                move.w man_xs,d0
                ror.l #4,d0
                lsl.w #3,d0
                add.w d0,a1
                bsr drawobject
                rts

endkistezeicheno:       
                lea endfeldkiste(pc),a0
                move.l screen(pc),a1
                moveq #0,d0
                move.w man_ys,d0
                sub.w #12,d0
                mulu #160,d0
                add.w d0,a1
                moveq #0,d0
                move.w man_xs,d0
                ror.l #4,d0
                lsl.w #3,d0
                add.w d0,a1
                bsr drawobject
                rts

kistezeichenu:  
                lea kiste(pc),a0
                move.l screen(pc),a1
                moveq #0,d0
                move.w man_ys,d0
                add.w #12,d0
                mulu #160,d0
                add.w d0,a1
                moveq #0,d0
                move.w man_xs,d0
                ror.l #4,d0
                lsl.w #3,d0
                add.w d0,a1
                bsr drawobject
                rts

kistezeicheno:  
                lea kiste(pc),a0
                move.l screen(pc),a1
                moveq #0,d0
                move.w man_ys,d0
                sub.w #12,d0
                mulu #160,d0
                add.w d0,a1
                moveq #0,d0
                move.w man_xs,d0
                ror.l #4,d0
                lsl.w #3,d0
                add.w d0,a1
                bsr drawobject
                rts

searchendfeld:  moveq #0,d0
                move.w man_y,d0
                mulu #19,d0
                add.w man_x,d0
                lea endfeldtab,a0
                move.w endfeldanz,d1
                subq.w #1,d1
kucknach:       cmp.w (a0)+,d0
                beq.s found
                dbra d1,kucknach
                moveq #0,d0
                rts
found:          moveq #-1,d0
                rts

cursorup:       clr.w counter
                lea level+2,a0
                moveq #0,d0
                move.w man_y,d0
                mulu #19,d0
                add.w man_x,d0                ; Dort steht das MÑnnchen
                add.w d0,a0
                cmp.b #0,-19(a0)              ; Dort Leerfeld ?
                bne.s nixmoveup
trotzdemup:     bsr walkup
                subq.w #1,man_y
                bsr koord_umr
                bra mainloop
nixmoveup:      cmp.b #3,-19(a0)
                beq.s trotzdemup
                cmp.b #$14,-19(a0)            ; ist dort Kiste ?
                bne.s nixnormalekisteoben
                tst.b -38(a0)                 ; Leerfeld ?
                beq.s ganznormaleoben
                cmp.b #3,-38(a0)              ; oder Endfeld ?
                bne mainloop                  ; kein Verschieben mîglich
                clr.b -19(a0)
                move.b #$17,-38(a0)           ; Kiste auf Endfeld
                subq.w #1,man_y
                bsr koord_umr
                bsr movekistehoch
                bsr koord_umr
                bsr endkistezeicheno          ; zeichnet Kiste rechts
                bsr testsmilie
                bra mainloop
ganznormaleoben:
                clr.b -19(a0)                 ; jetzt Leerfeld
                move.b #$14,-38(a0)           ; normale Kiste rechts
                subq.w #1,man_y
                bsr koord_umr
                bsr movekistehoch
                bsr koord_umr
                bsr testsmilie
                bra mainloop
nixnormalekisteoben:
                cmp.b #$17,-19(a0)            ; keine Endkiste ?
                bne mainloop
                cmp.b #3,-38(a0)              ; auf Endfeld verschieben
                beq.s verschkisteendo
                tst.b -38(a0)
                bne mainloop                  ; kein Leerfeld
                move.b #3,-19(a0)
                move.b #$14,-38(a0)
                subq.w #1,man_y
                bsr koord_umr
                bsr movekistehoch2
                bsr koord_umr
                bsr kistezeicheno
                bsr testsmilie
                bra mainloop
verschkisteendo:                
                move.b #3,-19(a0)
                move.b #$17,-38(a0)
                subq.w #1,man_y
                bsr koord_umr
                bsr movekistehoch2
                bsr koord_umr
                bsr endkistezeicheno
                bsr testsmilie
                bra mainloop

cursordown:     clr.w counter
                lea level+2,a0
                moveq #0,d0
                move.w man_y,d0
                mulu #19,d0
                add.w man_x,d0                ; Dort steht das MÑnnchen
                add.w d0,a0
                cmp.b #0,19(a0)               ; Dort Leerfeld ?
                bne.s nixmovedown
trotzdemdown:   bsr walkdown
                addq.w #1,man_y
                bsr koord_umr
                bra mainloop
nixmovedown:    cmp.b #3,19(a0)
                beq.s trotzdemdown
                cmp.b #$14,19(a0)             ; ist dort Kiste ?
                bne.s nixnormalekisteunten
                tst.b 38(a0)                  ; Leerfeld ?
                beq.s ganznormaleunten
                cmp.b #3,38(a0)               ; oder Endfeld ?
                bne mainloop                  ; kein Verschieben mîglich
                clr.b 19(a0)
                move.b #$17,38(a0)            ; Kiste auf Endfeld
                bsr koord_umr
                bsr movekisterunter
                addq.w #1,man_y
                bsr koord_umr
                bsr endkistezeichenu          ; zeichnet Kiste rechts
                bsr testsmilie
                bra mainloop
ganznormaleunten:
                clr.b 19(a0)                  ; jetzt Leerfeld
                move.b #$14,38(a0)            ; normale Kiste rechts
                bsr koord_umr
                bsr movekisterunter
                addq.w #1,man_y
                bsr koord_umr
                bsr testsmilie
                bra mainloop
nixnormalekisteunten:
                cmp.b #$17,19(a0)             ; keine Endkiste ?
                bne mainloop
                cmp.b #3,38(a0)               ; auf Endfeld verschieben
                beq.s verschkisteendu
                tst.b 38(a0)
                bne mainloop                  ; kein Leerfeld
                move.b #3,19(a0)
                move.b #$14,38(a0)
                bsr koord_umr
                bsr movekisterunter2
                addq.w #1,man_y
                bsr koord_umr
                bsr kistezeichenu
                bsr testsmilie
                bra mainloop
verschkisteendu:                
                move.b #3,19(a0)
                move.b #$17,38(a0)
                bsr koord_umr
                bsr movekisterunter2
                addq.w #1,man_y
                bsr koord_umr
                bsr endkistezeichenu
                bsr testsmilie
                bra mainloop


walkup:         subq.w #1,man_ys
                addq.w #1,counter
                cmp.w #13,counter
                beq.s walkupende
                bsr vsync
                bsr restoresmilie            ; altes Smilie lîschen
                bsr draw_smilie
                bra.s walkup
walkupende:     addq.w #1,moves
                bsr movesout
                rts

walkdown:       add.w #1,man_ys
                addq.w #1,counter
                cmp.w #13,counter
                beq.s walkdownende
                bsr vsync
                bsr restoresmilie            ; altes Smilie lîschen
                bsr draw_smilie
                bra.s walkdown
walkdownende:   addq.w #1,moves
                bsr movesout
                rts

walkright:      addq.w #1,man_xs
                addq.w #1,counter
                cmp.w #17,counter
                beq.s walkrightende
                bsr vsync
                bsr restoresmilie            ; altes Smilie lîschen
                bsr draw_smilie
                bra.s walkright
walkrightende:  addq.w #1,moves
                bsr movesout
                rts

movekistelinks: subq.w #1,man_xs
                bsr vsync
                bsr restoresmilie
                lea smiliekistelinks,a0                         
                bsr draw_kiste
                addq.w #1,counter
                cmp.w #16,counter
                bne.s movekistelinks
movekleftende:  addq.w #1,moves
                addq.w #1,pushes
                bsr movesout
                rts


movekistelinks2:subq.w #1,man_xs
                bsr vsync
                bsr restoresmilie
                lea smilieekistelinks,a0                                
                bsr draw_kiste
                addq.w #1,counter
                cmp.w #16,counter
                bne.s movekistelinks2
                addq.w #1,moves
                addq.w #1,pushes
                bsr movesout
                rts


movekistehoch:  subq.w #1,man_ys
                bsr vsync
                bsr restoresmilie
                lea smiliekisteoben,a0                          
                bsr draw_kiste2
                addq.w #1,counter
                cmp.w #12,counter
                bne.s movekistehoch
movekupende:    addq.w #1,moves
                addq.w #1,pushes
                bsr movesout
                rts

movekistehoch2: subq.w #1,man_ys
                bsr vsync
                bsr restoresmilie
                lea smilieekisteoben,a0                         
                bsr draw_kiste2
                addq.w #1,counter
                cmp.w #12,counter
                bne.s movekistehoch2
                addq.w #1,moves
                addq.w #1,pushes
                bsr movesout
                rts

movekisterunter:addq.w #1,man_ys
                bsr vsync
                bsr restoresmilie
                lea smiliekisteunten,a0                         
                bsr draw_kiste2
                addq.w #1,counter
                cmp.w #12,counter
                bne.s movekisterunter
movekdownende:  addq.w #1,moves
                addq.w #1,pushes
                bsr movesout
                rts

movekisterunter2:
                addq.w #1,man_ys
                bsr vsync
                bsr restoresmilie
                lea smilieekisteunten,a0                                
                bsr draw_kiste2
                addq.w #1,counter
                cmp.w #12,counter
                bne.s movekisterunter2
                addq.w #1,moves
                addq.w #1,pushes
                bsr movesout
                rts


movekisterechts:addq.w #1,man_xs
                bsr vsync
                bsr restoresmilie
                lea smiliekisterechts,a0                                
                bsr draw_kiste
                addq.w #1,counter
                cmp.w #16,counter
                bne.s movekisterechts
movekrechtsende:addq.w #1,moves
                addq.w #1,pushes
                bsr movesout
                rts

movekisterechts2:
                addq.w #1,man_xs
                bsr vsync
                bsr restoresmilie
                lea smilieekisterechts,a0                               
                bsr draw_kiste
                addq.w #1,counter
                cmp.w #16,counter
                bne.s movekisterechts2
movekrechtsende2:
                addq.w #1,moves
                addq.w #1,pushes
                bsr movesout
                rts

walkleft:       subq.w #1,man_xs
                addq.w #1,counter
                cmp.w #17,counter
                beq.s walkleftende
                bsr vsync
                bsr restoresmilie            ; altes Smilie lîschen
                bsr draw_smilie
                bra.s walkleft
walkleftende:   addq.w #1,moves
                bsr movesout
                rts

movesout:       move.w moves,d0
                bsr hex_dez
                lea dezzahl+2,a0
                moveq #4,d0
                moveq #19,d1
                moveq #24,d2
                bsr textaus
                move.w pushes,d0
                bsr hex_dez
                lea dezzahl+2,a0
                moveq #4,d0
                moveq #33,d1
                moveq #24,d2
                bsr textaus
                rts

restoresmilie:  lea restorebuff,a0
                move.l (a0)+,a1
                cmp.l #0,a1
                beq.s nixrestsmile
                move.w (a0)+,d0
                cmp.w #1,d0
                beq.s restkiste1
                cmp.w #2,d0
                beq.s restkiste2
                moveq #11,d0
restloop0:      movem.l (a0)+,d1-d4
                movem.l d1-d4,(a1)
                lea 160(a1),a1
                dbra d0,restloop0
nixrestsmile:   rts

restkiste2:     moveq #23,d0
restloop3:      movem.l (a0)+,d1-d4
                movem.l d1-d4,(a1)
                lea 160(a1),a1
                dbra d0,restloop3
                rts

restkiste1:     moveq #11,d0
restloop1:      movem.l (a0)+,d1-d6
                movem.l d1-d6,(a1)
                lea 160(a1),a1
                dbra d0,restloop1
                rts

copylevel:      move.l levelpointer,a0
                lea level,a1
                move.w #305,d0
copylevelloop:  move.b (a0)+,(a1)+
                dbra d0,copylevelloop
                rts

createlevel:    lea level,a6
                moveq #0,d0
                move.b 1(a6),d0
                lsl.w #8,d0
                move.b (a6),d0
                divu #19,d0
                move.w d0,man_y                 ; Werte von 0-15
                swap d0
                move.w d0,man_x                 ; Koord. des Smilies
                lea 2(a6),a6            
                move.l screen(pc),a5
                moveq #15,d7                    ; 16 Zeilen
createlevel1:   moveq #18,d6                    ; 20 Spalten
createlevel2:   move.b (a6)+,d0                 ; Wert aus Level holen
                tst.b d0
                beq.s space                     ; Leerfeld
                cmp.b #1,d0                     ; Wand?
                bne.s nixwand
                lea wand(pc),a0
                move.l a5,a1
                bsr drawobject
                bra.s space
nixwand:        cmp.b #3,d0                     ; Endezeichen
                bne.s nixendezeichen
                lea endfeld(pc),a0
                move.l a5,a1
                bsr drawobject
                bra.s space
nixendezeichen: cmp.b #$14,d0                   ; Kiste
                bne.s nixkiste                  ; kein weiteres Objekt
                lea kiste(pc),a0
                move.l a5,a1
                bsr drawobject
                bra.s space
nixkiste:       cmp.b #$17,d0
                bne.s space
                lea endfeldkiste(pc),a0
                move.l a5,a1
                bsr drawobject
space:          lea 8(a5),a5                    ; Screenpointer +8
                dbra d6,createlevel2
                lea 1768(a5),a5                 ; 12 Zeilen tiefer
                dbra d7,createlevel1
                rts

drawobject:     moveq #11,d0                    ; 12 Zeilen
drawobjloop:    move.l (a0)+,(a1)
                move.l (a0)+,4(a1)
                lea 160(a1),a1
                dbra d0,drawobjloop
                rts                     
                
koord_umr:      
; rechnet Koordinaten des MÑnnchens vom Tabellenwert zum Screenwert um
                moveq #0,d0
                move.w man_x,d0             ; Werte von 0-18
                lsl.w #4,d0                     ; *16
                move.w d0,man_xs                ; Screenkoordinaten
                move.w man_y,d0
                mulu #12,d0                     ; Screenkoord.
                move.w d0,man_ys
                rts


clearsmilie:    move.l screen(pc),a1
                moveq #0,d0
                move.w man_xs,d0                            
                lsr.w #4,d0
                lsl.w #3,d0                     ; Erg. *8 -> BB
                add.w d0,a1             
                move.w #0,d0
                rol.l #4,d0                     ; Rest zurÅck
                moveq #0,d1
                move.w man_ys,d1
                mulu #160,d1
                add.w d1,a1
                moveq #11,d0
clearsml0:      clr.l (a1)+
                clr.l (a1)+
                lea 152(a1),a1
                dbra d0,clearsml0
                rts


                

draw_smilie:    
; zeichnet Smilie mit Koord. in man_xs und man_ys
; shiftet gegebenenfalls

                lea smilie(pc),a0
                move.l screen(pc),a1
                lea restorebuff,a2
                moveq #0,d0
                move.w man_xs,d0                            
                ror.l #4,d0                     ; /16
                lsl.w #3,d0                     ; Erg. *8 -> BB
                add.w d0,a1             
                move.w #0,d0
                rol.l #4,d0                     ; Rest zurÅck
                moveq #0,d1
                move.w man_ys,d1
                mulu #160,d1
                add.w d1,a1
                move.l a1,(a2)+                 ; dort lîschen
                move.w #0,(a2)+
                moveq #11,d1                    ; 12 Zeilen
dsml0:          movem.l (a1),d2-d5
                movem.l d2-d5,(a2)
                lea 16(a2),a2                   ; Screendaten retten
                moveq #0,d2
                move.w (a0)+,d2                 ; 1 Wort holen
                ror.l d0,d2                     ; Shiften
                moveq #0,d3
                move.w (a0)+,d3                 ; 1 Wort holen
                ror.l d0,d3                     ; Shiften
                moveq #0,d4
                move.w (a0)+,d4                 ; 1 Wort holen
                ror.l d0,d4                     ; Shiften
                moveq #0,d5
                move.w (a0)+,d5                 ; 1 Wort holen
                ror.l d0,d5                     ; Shiften
                move.l d2,d6                    ; Maske bilden
                or.l d3,d6
                or.l d4,d6
                or.l d5,d6
                not.l d6
                and.w d6,(a1)
                or.w d2,(a1)+
                and.w d6,(a1)
                or.w d3,(a1)+
                and.w d6,(a1)
                or.w d4,(a1)+
                and.w d6,(a1)
                or.w d5,(a1)+
                swap d2
                swap d3
                swap d4
                swap d5
                swap d6
                and.w d6,(a1)
                or.w d2,(a1)+
                and.w d6,(a1)
                or.w d3,(a1)+
                and.w d6,(a1)
                or.w d4,(a1)+
                and.w d6,(a1)
                or.w d5,(a1)+
                lea 144(a1),a1                  ; eine Zeile tiefer
                dbra d1,dsml0
                rts             

draw_kiste2:    
; zeichnet Kiste mit Koord. in man_xs und man_ys
; shiftet gegebenenfalls
; in a0=welche Kiste
                move.l screen(pc),a1
                lea restorebuff,a2
                moveq #0,d0
                move.w man_xs,d0                            
                ror.l #4,d0                     ; /16
                lsl.w #3,d0                     ; Erg. *8 -> BB
                add.w d0,a1             
                move.w #0,d0
                rol.l #4,d0                     ; Rest zurÅck
                moveq #0,d1
                move.w man_ys,d1
                mulu #160,d1
                add.w d1,a1
                move.l a1,(a2)+                 ; dort lîschen
                move.w #2,(a2)+
                moveq #23,d1                    ; 24 Zeilen
dsml2:          movem.l (a1),d2-d5
                movem.l d2-d5,(a2)
                lea 16(a2),a2                   ; Screendaten retten
                moveq #0,d2
                move.w (a0)+,d2                 ; 1 Wort holen
                ror.l d0,d2                     ; Shiften
                moveq #0,d3
                move.w (a0)+,d3                 ; 1 Wort holen
                ror.l d0,d3                     ; Shiften
                moveq #0,d4
                move.w (a0)+,d4                 ; 1 Wort holen
                ror.l d0,d4                     ; Shiften
                moveq #0,d5
                move.w (a0)+,d5                 ; 1 Wort holen
                ror.l d0,d5                     ; Shiften
                move.l d2,d6                    ; Maske bilden
                or.l d3,d6
                or.l d4,d6
                or.l d5,d6
                not.l d6
                and.w d6,(a1)
                or.w d2,(a1)+
                and.w d6,(a1)
                or.w d3,(a1)+
                and.w d6,(a1)
                or.w d4,(a1)+
                and.w d6,(a1)
                or.w d5,(a1)+
                swap d2
                swap d3
                swap d4
                swap d5
                swap d6
                and.w d6,(a1)
                or.w d2,(a1)+
                and.w d6,(a1)
                or.w d3,(a1)+
                and.w d6,(a1)
                or.w d4,(a1)+
                and.w d6,(a1)
                or.w d5,(a1)+
                lea 144(a1),a1                  ; eine Zeile tiefer
                dbra d1,dsml2
                rts             

draw_kiste:     
; zeichnet Kiste mit Koord. in man_xs und man_ys
; shiftet gegebenenfalls
; in a0=Grafik
                move.l screen(pc),a1
                lea restorebuff,a2
                moveq #0,d0
                move.w man_xs,d0                            
                ror.l #4,d0                     ; /16
                lsl.w #3,d0                     ; Erg. *8 -> BB
                add.w d0,a1             
                move.w #0,d0
                rol.l #4,d0                     ; Rest zurÅck
                moveq #0,d1
                move.w man_ys,d1
                mulu #160,d1
                add.w d1,a1
                move.l a1,(a2)+                 ; dort lîschen
                move.w #1,(a2)+
                moveq #11,d1                    ; 12 Zeilen
dsml1:          move.w d1,-(a7)
                movem.l (a1),d2-d7
                movem.l d2-d7,(a2)
                lea 24(a2),a2                   ; Screendaten retten
                moveq #0,d1
                move.w (a0)+,d1
                ror.l d0,d1                     
                move.w d1,d7                    ; Maskenwert
                moveq #0,d2
                move.w (a0)+,d2
                ror.l d0,d2                     
                or.w d2,d7                      ; Maskenwert
                moveq #0,d3
                move.w (a0)+,d3
                ror.l d0,d3                     
                or.w d3,d7                      ; Maskenwert
                moveq #0,d4
                move.w (a0)+,d4
                ror.l d0,d4                     
                or.w d4,d7                      ; Maskenwert
                not.w d7
                and.w d7,(a1)
                or.w d1,(a1)+
                and.w d7,(a1)
                or.w d2,(a1)+
                and.w d7,(a1)
                or.w d3,(a1)+
                and.w d7,(a1)
                or.w d4,(a1)+
                swap d1
                swap d2
                swap d3
                swap d4
                moveq #0,d5
                move.w (a0)+,d5
                ror.l d0,d5
                or.w d1,d5                      ; herausgeschobenes
                moveq #0,d1
                move.w (a0)+,d1
                ror.l d0,d1
                or.w d2,d1                      ; herausgeschobenes
                moveq #0,d2
                move.w (a0)+,d2
                ror.l d0,d2
                or.w d3,d2                      ; herausgeschobenes
                moveq #0,d3
                move.w (a0)+,d3
                ror.l d0,d3
                or.w d4,d3                      ; herausgeschobenes
                move.w d5,d6
                or.w d1,d6
                or.w d2,d6
                or.w d3,d6
                not.w d6
                and.w d6,(a1)
                or.w d5,(a1)+
                and.w d6,(a1)
                or.w d1,(a1)+
                and.w d6,(a1)
                or.w d2,(a1)+
                and.w d6,(a1)
                or.w d3,(a1)+
                swap d5
                swap d1
                swap d2
                swap d3
                move.w d5,d6
                or.w d1,d6
                or.w d2,d6
                or.w d3,d6
                not.w d6
                and.w d6,(a1)
                or.w d5,(a1)+
                and.w d6,(a1)
                or.w d1,(a1)+
                and.w d6,(a1)
                or.w d2,(a1)+
                and.w d6,(a1)
                or.w d3,(a1)+
                lea 136(a1),a1          
                move.w (a7)+,d1
                dbra d1,dsml1
                rts             
                
cls:
; Parameter:    a0=Screenadresse

                moveq   #0,d1                ; Register lîschen
                move.l  d1,d2
                move.l  d1,d3
                move.l  d1,d4
                move.l  d1,d5
                move.l  d1,d6
                move.l  d1,d7
                move.l 	d1,a1
                move.l 	d1,a2
                move.l 	d1,a3
                add.l   #200*160,a0
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
                lea 	1(a0),a0
                move.l  $0118.w,(a0)+
                move.l  $0120.w,(a0)+
                move.l  $70.w,(a0)+
                andi.b  #$df,$fffffa09.w        ; Timer C aus
                andi.b  #$fe,$fffffa07.w        ; Timer B aus
                move.l  $0118.w,keybackjump+2
                move.l  #newkey,$0118.w
                move.l  #vblintro,$70.w
                move.l  #hblintro,$0120.w
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
                lea 1(a0),a0
                move.l  (a0)+,$0118.w
                move.l  (a0)+,$0120.w
                move.l  (a0)+,$70.w
                move    (a7)+,sr
                rts

screen:		blk.l	1
screen2:	blk.l	1

vblhighscores:	movem.l	d0-d7/a0-a6,-(a7)
		clr.b	$fffffa1b.w
		move.b	#24,$fffffa21.w
		move.b	#8,$fffffa1b.w
		move.l	#hblhighscores,$120.w
		move.l	#hblcolors,hblpointer3
		bsr	drawscores
		bsr	rout
		bsr	switch
		addq.l	#1,$466.w
		movem.l	(a7)+,d0-d7/a0-a6
		rte

hblhighscores:	clr.b	$fffffa1b.w
		move.b	#1,$fffffa21.w
		move.b	#8,$fffffa1b.w
		move.l	#hblhighscores2,$120.w
		rte

hblhighscores2:	move.l	a0,-(a7)
		move.l	hblpointer3,a0
		move.w	(a0)+,$ffff8242.w
		move.l	a0,hblpointer3
		move.l	(a7)+,a0
		rte

vblgame:        ; VBL-Routine wÑhrend Spiel
                movem.l d0-d7/a0-a6,-(a7)
musicanaus:     jsr     rout
                addq.l  #1,$0466.w              ; Vsynccounter

                clr.b   $fffffa1b.w
                tst.w   hblonoff                ; HBL an oder aus?
                beq.s   hblisoff                
                move.b  #7,$fffffa21.w
                move.b  #8,$fffffa1b.w
                move.l  #hblgame,$120.w
                move.l  #colortab2,hblpointer3

hblisoff:       movem.l (a7)+,d0-d7/a0-a6
                rte

nothing:        rts

hblgame:        clr.b   $fffffa1b.w
                move.b  #25,$fffffa21.w
                move.b  #8,$fffffa1b.w
                move.l  #hbl2,$120.w
hbl2:           move.l  a0,-(a7)
                move.l  hblpointer3,a0
                move.l  (a0)+,$ffff8242.w
                move.w  (a0)+,$ffff8246.w
                move.l  a0,hblpointer3
                move.l  (a7)+,a0
                rte

keyinit:        dc.b $14,$12
if diskversion=1
keyexit:	dc.b $1a,0
else
keyexit:	dc.b $8,$80,1,0
endif
key:            dc.b 0
zeichen:        dc.b 0
joy_flag:       dc.w 0
joy_0_flag:     dc.w 0
tx_point:       dc.l 0
tx_count:       dc.w 0

newkey:         move    #$2500,sr
                movem.l d0-d1/a0,-(sp)
                move.b $fffffc00.w,d0
                btst   #7,d0
                beq    eoi
                btst   #0,d0
                beq    eoi
                move.b $fffffc02.w,d1
                tst.w  joy_0_flag
                beq    joy_1
                clr.w  joy_0_flag
                bra    eoi

joy_1:
                tst.w  joy_flag
                beq    no_data
                move.b d1,zeichen

                clr.w  joy_flag
                bra    eoi
no_data:
                cmp.b  #$ff,d1
                bne    joy_0

                move.w #1,joy_flag
                bra    eoi

joy_0:
                cmp.b  #$fe,d1
                bne    scancode
                move.w #1,joy_0_flag
                bra    eoi
scancode:
                clr.b key
                btst   #7,d1
                bne    eoi
                move.b d1,key
eoi:
                btst   #1,d0
                beq    eoi_2
                tst.w  tx_count
                beq    eoi_2
                move.l tx_point,a0
                subq.w #1,tx_count
                move.b (a0)+,$fffffc02.w
                move.l a0,tx_point

eoi_2:
                bclr   #6,$fffffa11.w
                movem.l (sp)+,d0-d1/a0
                rte

send:
                tst.w  tx_count
                beq    eos
                move.l tx_point,a0
                subq.w #1,tx_count
                addq.l #1,tx_point
                move.b (a0),$fffffc02.w
eos:            rts

keybackjump:    jmp     $00




cursoraus:      dc.b 27,"f",0
cursoran:       dc.b 27,"e",0

palette:
 dc.w $0000,$0055,$0770,$0660,$0550,$0440,$0330,$0000
 dc.w $0700,$0500,$0300,$0643,$0532,$0421,$0077,$0033




smilie:
         DC.W   $0A50,$13C8,$1C38,$0000,$2814,$0FF0,$300C,$0000
         DC.W   $2004,$3FFC,$4002,$0000,$4424,$FFFD,$8E73,$0000
         DC.W   $0A51,$7BDC,$8A53,$0420,$8005,$FFFC,$0003,$0000
         DC.W   $8991,$FFF8,$118F,$0000,$1429,$77E8,$981F,$0000
         DC.W   $4A52,$EBD1,$9C3F,$0000,$37E6,$37E0,$4FFE,$0000
         DC.W   $1A0C,$1A00,$25FC,$0000,$0870,$1008,$1FF8,$0000

smiliezunge:
         DC.W   $0810,$0000,$0000,$0FF0,$2004,$0000,$0000,$3FFC
         DC.W   $4002,$0000,$0000,$7FFE,$8E71,$0E70,$0E70,$F18F
         DC.W   $0460,$0460,$0460,$F99F,$0000,$0000,$0000,$FFFF
         DC.W   $1008,$1008,$1008,$EFF7,$1C38,$0810,$0810,$F7EF
         DC.W   $8FF1,$0660,$0660,$F99F,$4182,$0180,$07E0,$781E
         DC.W   $2004,$0180,$03C0,$3DBC,$0810,$0000,$03C0,$0C30


wand:
         DC.W   $0000,$0000,$0000,$FFFF,$7E7E,$0101,$0000,$FFFF
         DC.W   $7E7E,$0101,$0000,$FFFF,$0000,$7F7F,$0000,$FFFF
         DC.W   $0000,$0000,$0000,$FFFF,$E7E7,$1010,$0000,$FFFF
         DC.W   $E7E7,$1010,$0000,$FFFF,$0000,$F7F7,$0000,$FFFF
         DC.W   $0000,$0000,$0000,$FFFF,$7E7E,$0101,$0000,$FFFF
         DC.W   $7E7E,$0101,$0000,$FFFF,$0000,$7F7F,$0000,$FFFF

endfeldkiste:
         DC.W   $7F06,$00FA,$00FA,$00FA,$BECB,$5D35,$5D35,$5D35
         DC.W   $7FE3,$A0DD,$A0DD,$A0DD,$1CFF,$E301,$E301,$E301
         DC.W   $7E7F,$9DBD,$9DBD,$9DBD,$FFFF,$7261,$7261,$7261
         DC.W   $72F7,$8D09,$8D09,$8D09,$39FF,$C611,$C611,$C611
         DC.W   $3F3B,$D8C5,$D8C5,$D8C5,$F827,$17D9,$17D9,$17D9
         DC.W   $FFFF,$8003,$8003,$8003,$7FFE,$7FFE,$7FFE,$7FFE

kiste:
         DC.W   $00FA,$00F8,$7F06,$7FFE,$5D35,$4134,$BECB,$FFFF
         DC.W   $A0DD,$801C,$7FE3,$FFFF,$E301,$E300,$1CFF,$FFFF
         DC.W   $9DBD,$8180,$7E7F,$FFFF,$7261,$0000,$FFFF,$FFFF
         DC.W   $8D09,$8D08,$72F7,$FFFF,$C611,$C600,$39FF,$FFFF
         DC.W   $D8C5,$C0C4,$3F3B,$FFFF,$17D9,$07D8,$F827,$FFFF
         DC.W   $8003,$0000,$FFFF,$FFFF,$7FFE,$0000,$7FFE,$7FFE

endfeld:
         DC.W   $0000,$0000,$0000,$0000,$0000,$0180,$0180,$0180
         DC.W   $0180,$03C0,$03C0,$03C0,$0240,$0660,$0660,$0660
         DC.W   $0420,$0C30,$0C30,$0C30,$0810,$1818,$1818,$1818
         DC.W   $0810,$1818,$1818,$1818,$0420,$0C30,$0C30,$0C30
         DC.W   $0240,$0660,$0660,$0660,$0180,$03C0,$03C0,$03C0
         DC.W   $0000,$0180,$0180,$0180,$0000,$0000,$0000,$0000

smilieekisterechts:
         DC.W   $EA57,$F3CF,$FC3F,$0000,$FF07,$80FB,$80FB,$00FA
         DC.W   $E817,$CFF3,$F00F,$0000,$BECB,$5D35,$5D35,$5D35
         DC.W   $A005,$BFFD,$C003,$0000,$7FE3,$A0DD,$A0DD,$A0DD
         DC.W   $4424,$FFFD,$8E73,$0000,$1CFF,$E301,$E301,$E301
         DC.W   $0A51,$7BDC,$8A53,$0420,$7E7F,$9DBD,$9DBD,$9DBD
         DC.W   $8005,$FFFC,$0003,$0000,$FFFF,$7261,$7261,$7261
         DC.W   $8991,$FFF8,$118F,$0000,$72F7,$8D09,$8D09,$8D09
         DC.W   $1429,$77E8,$981F,$0000,$39FF,$C611,$C611,$C611
         DC.W   $4A52,$EBD1,$9C3F,$0000,$3F3B,$D8C5,$D8C5,$D8C5
         DC.W   $B7E7,$B7E1,$CFFF,$0000,$F827,$17D9,$17D9,$17D9
         DC.W   $DA0F,$DA03,$E5FF,$0000,$FFFF,$8003,$8003,$8003
         DC.W   $E877,$F00F,$FFFF,$0000,$FFFF,$FFFF,$FFFF,$7FFE
smilieekistelinks:
         DC.W   $FF07,$80FB,$80FB,$00FA,$EA57,$F3CF,$FC3F,$0000
         DC.W   $BECB,$5D35,$5D35,$5D35,$E817,$CFF3,$F00F,$0000
         DC.W   $7FE3,$A0DD,$A0DD,$A0DD,$A005,$BFFD,$C003,$0000
         DC.W   $1CFF,$E301,$E301,$E301,$4424,$FFFD,$8E73,$0000
         DC.W   $7E7F,$9DBD,$9DBD,$9DBD,$0A51,$7BDC,$8A53,$0420
         DC.W   $FFFF,$7261,$7261,$7261,$8005,$FFFC,$0003,$0000
         DC.W   $72F7,$8D09,$8D09,$8D09,$8991,$FFF8,$118F,$0000
         DC.W   $39FF,$C611,$C611,$C611,$1429,$77E8,$981F,$0000
         DC.W   $3F3B,$D8C5,$D8C5,$D8C5,$4A52,$EBD1,$9C3F,$0000
         DC.W   $F827,$17D9,$17D9,$17D9,$B7E7,$B7E1,$CFFF,$0000
         DC.W   $FFFF,$8003,$8003,$8003,$DA0F,$DA03,$E5FF,$0000
         DC.W   $FFFF,$FFFF,$FFFF,$7FFE,$E877,$F00F,$FFFF,$0000
smilieekisteoben:
         DC.W   $FF07,$80FB,$80FB,$00FA,$BECB,$5D35,$5D35,$5D35
         DC.W   $7FE3,$A0DD,$A0DD,$A0DD,$1CFF,$E301,$E301,$E301
         DC.W   $7E7F,$9DBD,$9DBD,$9DBD,$FFFF,$7261,$7261,$7261
         DC.W   $72F7,$8D09,$8D09,$8D09,$39FF,$C611,$C611,$C611
         DC.W   $3F3B,$D8C5,$D8C5,$D8C5,$F827,$17D9,$17D9,$17D9
         DC.W   $FFFF,$8003,$8003,$8003,$FFFF,$FFFF,$FFFF,$7FFE
         DC.W   $EA57,$F3CF,$FC3F,$0000,$E817,$CFF3,$F00F,$0000
         DC.W   $A005,$BFFD,$C003,$0000,$4424,$FFFD,$8E73,$0000
         DC.W   $0A51,$7BDC,$8A53,$0420,$8005,$FFFC,$0003,$0000
         DC.W   $8991,$FFF8,$118F,$0000,$1429,$77E8,$981F,$0000
         DC.W   $4A52,$EBD1,$9C3F,$0000,$B7E7,$B7E1,$CFFF,$0000
         DC.W   $DA0F,$DA03,$E5FF,$0000,$E877,$F00F,$FFFF,$0000
smilieekisteunten:
         DC.W   $EA57,$F3CF,$FC3F,$0000,$E817,$CFF3,$F00F,$0000
         DC.W   $A005,$BFFD,$C003,$0000,$4424,$FFFD,$8E73,$0000
         DC.W   $0A51,$7BDC,$8A53,$0420,$8005,$FFFC,$0003,$0000
         DC.W   $8991,$FFF8,$118F,$0000,$1429,$77E8,$981F,$0000
         DC.W   $4A52,$EBD1,$9C3F,$0000,$B7E7,$B7E1,$CFFF,$0000
         DC.W   $DA0F,$DA03,$E5FF,$0000,$E877,$F00F,$FFFF,$0000
         DC.W   $FF07,$80FB,$80FB,$00FA,$BECB,$5D35,$5D35,$5D35
         DC.W   $7FE3,$A0DD,$A0DD,$A0DD,$1CFF,$E301,$E301,$E301
         DC.W   $7E7F,$9DBD,$9DBD,$9DBD,$FFFF,$7261,$7261,$7261
         DC.W   $72F7,$8D09,$8D09,$8D09,$39FF,$C611,$C611,$C611
         DC.W   $3F3B,$D8C5,$D8C5,$D8C5,$F827,$17D9,$17D9,$17D9
         DC.W   $FFFF,$8003,$8003,$8003,$FFFF,$FFFF,$FFFF,$7FFE



smiliekisterechts:
         DC.W   $EA57,$F3CF,$FC3F,$0000,$80FB,$80F9,$FF07,$7FFE
         DC.W   $E817,$CFF3,$F00F,$0000,$5D35,$4134,$BECB,$FFFF
         DC.W   $A005,$BFFD,$C003,$0000,$A0DD,$801C,$7FE3,$FFFF
         DC.W   $4424,$FFFD,$8E73,$0000,$E301,$E300,$1CFF,$FFFF
         DC.W   $0A51,$7BDC,$8A53,$0420,$9DBD,$8180,$7E7F,$FFFF
         DC.W   $8005,$FFFC,$0003,$0000,$7261,$0000,$FFFF,$FFFF
         DC.W   $8991,$FFF8,$118F,$0000,$8D09,$8D08,$72F7,$FFFF
         DC.W   $1429,$77E8,$981F,$0000,$C611,$C600,$39FF,$FFFF
         DC.W   $4A52,$EBD1,$9C3F,$0000,$D8C5,$C0C4,$3F3B,$FFFF
         DC.W   $B7E7,$B7E1,$CFFF,$0000,$17D9,$07D8,$F827,$FFFF
         DC.W   $DA0F,$DA03,$E5FF,$0000,$8003,$0000,$FFFF,$FFFF
         DC.W   $E877,$F00F,$FFFF,$0000,$FFFF,$8001,$FFFF,$7FFE

smiliekistelinks:
         DC.W   $80FB,$80F9,$FF07,$7FFE,$EA57,$F3CF,$FC3F,$0000
         DC.W   $5D35,$4134,$BECB,$FFFF,$E817,$CFF3,$F00F,$0000
         DC.W   $A0DD,$801C,$7FE3,$FFFF,$A005,$BFFD,$C003,$0000
         DC.W   $E301,$E300,$1CFF,$FFFF,$4424,$FFFD,$8E73,$0000
         DC.W   $9DBD,$8180,$7E7F,$FFFF,$0A51,$7BDC,$8A53,$0420
         DC.W   $7261,$0000,$FFFF,$FFFF,$8005,$FFFC,$0003,$0000
         DC.W   $8D09,$8D08,$72F7,$FFFF,$8991,$FFF8,$118F,$0000
         DC.W   $C611,$C600,$39FF,$FFFF,$1429,$77E8,$981F,$0000
         DC.W   $D8C5,$C0C4,$3F3B,$FFFF,$4A52,$EBD1,$9C3F,$0000
         DC.W   $17D9,$07D8,$F827,$FFFF,$B7E7,$B7E1,$CFFF,$0000
         DC.W   $8003,$0000,$FFFF,$FFFF,$DA0F,$DA03,$E5FF,$0000
         DC.W   $FFFF,$8001,$FFFF,$7FFE,$E877,$F00F,$FFFF,$0000

smiliekisteunten:
         DC.W   $EA57,$F3CF,$FC3F,$0000,$E817,$CFF3,$F00F,$0000
         DC.W   $A005,$BFFD,$C003,$0000,$4424,$FFFD,$8E73,$0000
         DC.W   $0A51,$7BDC,$8A53,$0420,$8005,$FFFC,$0003,$0000
         DC.W   $8991,$FFF8,$118F,$0000,$1429,$77E8,$981F,$0000
         DC.W   $4A52,$EBD1,$9C3F,$0000,$B7E7,$B7E1,$CFFF,$0000
         DC.W   $DA0F,$DA03,$E5FF,$0000,$E877,$F00F,$FFFF,$0000
         DC.W   $80FB,$80F9,$FF07,$7FFE,$5D35,$4134,$BECB,$FFFF
         DC.W   $A0DD,$801C,$7FE3,$FFFF,$E301,$E300,$1CFF,$FFFF
         DC.W   $9DBD,$8180,$7E7F,$FFFF,$7261,$0000,$FFFF,$FFFF
         DC.W   $8D09,$8D08,$72F7,$FFFF,$C611,$C600,$39FF,$FFFF
         DC.W   $D8C5,$C0C4,$3F3B,$FFFF,$17D9,$07D8,$F827,$FFFF
         DC.W   $8003,$0000,$FFFF,$FFFF,$FFFF,$8001,$FFFF,$7FFE
smiliekisteoben:
         DC.W   $80FB,$80F9,$FF07,$7FFE,$5D35,$4134,$BECB,$FFFF
         DC.W   $A0DD,$801C,$7FE3,$FFFF,$E301,$E300,$1CFF,$FFFF
         DC.W   $9DBD,$8180,$7E7F,$FFFF,$7261,$0000,$FFFF,$FFFF
         DC.W   $8D09,$8D08,$72F7,$FFFF,$C611,$C600,$39FF,$FFFF
         DC.W   $D8C5,$C0C4,$3F3B,$FFFF,$17D9,$07D8,$F827,$FFFF
         DC.W   $8003,$0000,$FFFF,$FFFF,$FFFF,$8001,$FFFF,$7FFE
         DC.W   $EA57,$F3CF,$FC3F,$0000,$E817,$CFF3,$F00F,$0000
         DC.W   $A005,$BFFD,$C003,$0000,$4424,$FFFD,$8E73,$0000
         DC.W   $0A51,$7BDC,$8A53,$0420,$8005,$FFFC,$0003,$0000
         DC.W   $8991,$FFF8,$118F,$0000,$1429,$77E8,$981F,$0000
         DC.W   $4A52,$EBD1,$9C3F,$0000,$B7E7,$B7E1,$CFFF,$0000
         DC.W   $DA0F,$DA03,$E5FF,$0000,$E877,$F00F,$FFFF,$0000

hex_dez:
; Parameter: d0=Hexzahl
                movem.l d0-d1/a0,-(a7)
                lea     dezzahl(pc),a0
                move.l  #"0000",(a0)+
                move.w  #"00",(a0)+
                lea     dezzahl+6,a0
umr:            moveq   #0,d1
                move.w  d0,d1
                divu    #10,d1
                swap    d1
                addi.b  #'0',d1
                move.b  d1,-(a0)
                swap    d1
                move.w  d1,d0
                cmp.w   #10,d1
                bge.s   umr
                addi.b  #'0',d1
                move.b  d1,-(a0)
                movem.l (a7)+,d0-d1/a0
                rts

dezzahl:        blk.b 6
                dc.b 0,0

menu:
; gibt Menu aus, wo Level und soweiter selektiert werden kann
                
                move.l  screen(pc),a0
                bsr     cls
                movem.l leerfeld,d0-d7
                movem.l d0-d7,$ffff8240.w

                lea     menutext,a6
                moveq   #3,d7                   ; 4 Zeilen
                moveq   #35,d6                  ; Start Y
menutextloop:   move.l  a6,a0
                moveq   #20,d0
                moveq   #0,d1
                move.w  d6,d2
                bsr     textaus2
                add.w   #35,d6
                lea     20(a6),a6
                dbra    d7,menutextloop

                bsr     printlevel              

                lea     namebuff,a0             ; LÑnge ermitteln
                moveq   #0,d0                   ; max. 20 Zeichen
searchlength:   tst.b   (a0)+
                beq.s   nullfound
                addq.w  #1,d0
                cmp.w   #21,d0
                bne.s   searchlength
nullfound:      moveq   #20,d1                  ; Zentrieren
                sub.w   d0,d1
                lsr.w   #1,d1
                lea     namebuff,a0
                move.w  #180,d2
                bsr     textaus2

                move.l  screen(pc),a0
                lea     180*160(a0),a0
                move.w  #[18*20]-1,d0
fillplane2:     move.w  #-1,4(a0)
                lea     8(a0),a0
                dbra    d0,fillplane2

                move.l  screen(pc),a0
                lea     35*160(a0),a0
                moveq   #17,d0
fillplane2b:    move.w  #-1,132(a0)
                move.w  #-1,140(a0)
                lea     160(a0),a0
                dbra    d0,fillplane2b

                movem.l menupalette,d0-d7
                movem.l d0-d7,$ffff8240.w

                bsr     drawbalken

waitmenukey:    move.b  key(pc),d0
		cmp.b	#1,d0			; Escape?
		bne.s	nixendmenu
		move.w	#-1,exitfrommenu
		rts                

nixendmenu:	cmp.b   #$48,d0                 ; Cursor hoch?
                bne.s   notbalkenhoch
                tst.w   balkenpos               ; schon oben?
                bne.s   nixbalkenoben
		bsr	drawbalken
		bsr	vsync
		move.w	#3,balkenpos
		bsr	drawbalken
		clr.b	key
		bra.s	waitmenukey			
nixbalkenoben:  bsr     drawbalken              ; Balken lîschen
                subq.w  #1,balkenpos
                bsr     vsync
                bsr     drawbalken              ; Balken zeichnen
                clr.b   key
                bra.s   waitmenukey
notbalkenhoch:  cmp.b   #$50,d0                 ; Cursor runter ?
                bne.s   notbalkenrunter
                cmp.w   #3,balkenpos            ; schon unten?
                bne.s   nixbalkenunten
		bsr	drawbalken
		bsr	vsync
		move.w	#0,balkenpos
		bsr	drawbalken
		clr.b	key
		bra	waitmenukey			
nixbalkenunten: bsr     drawbalken
                addq.w  #1,balkenpos
                bsr     vsync
                bsr     drawbalken
                clr.b   key
                bra     waitmenukey
notbalkenrunter:cmp.b   #$4b,d0                 ; Cursor links?
                bne     notcursorleft
                tst.w   balkenpos               ; nicht oben!
                bne     waitmenukey
                cmp.w   #1,currentlevel
                beq     from1to50               ; schon Level 1!
                subq.w  #1,currentlevel
prl:            bsr     vsync
                ;clr.b   key
                bsr     printlevel
                bsr	vsync
                bsr	vsync
                bsr	vsync
                bsr	vsync
                bsr	vsync
                bsr	vsync
		bra     waitmenukey
from1to50:	move.w	#50,currentlevel
		bra.s	prl
notcursorleft:  cmp.b   #$4d,d0                 ; Cursor rechts?
                bne     notcursorright
                tst.w   balkenpos               ; nicht oben!
                bne     waitmenukey
                cmp.w   #50,currentlevel
                beq     from50to1               ; schon Level 50!
                addq.w  #1,currentlevel
prl2:           bsr     vsync
                ;clr.b   key
                bsr     printlevel
		bsr	vsync
		bsr	vsync
		bsr	vsync
                bsr	vsync
                bsr	vsync
                bsr	vsync
                bra     waitmenukey
from50to1:	move.w	#1,currentlevel
		bra.s	prl2
notcursorright: cmp.b   #$1c,d0                 ; Return?
                bne     nixstartgame
wurscht:        tst.w	balkenpos
		bne.s	nixbalkob
		clr.b	key
		bra	waitmenukey
nixbalkob:	cmp.w   #1,balkenpos
                bne.s   nixentername
                bra     entername
nixentername:   cmp.w   #2,balkenpos
                bne.s   nixshowhighs
		clr.b	key
                bra     showhighscores
nixshowhighs:   cmp.w   #3,balkenpos
                bne.s   nixstartgame
                clr.b   key
                rts             
nixstartgame:   
		cmp.b   #$39,d0                 ; Space?
                beq     wurscht

		move.b  zeichen(pc),d0          ; Joystick!
                btst    #0,d0                   ; Joy up?
                beq.s   notbalkenhoch2
                tst.w   balkenpos               ; schon oben?
                bne     nixbalkenoben2
                bsr	drawbalken
		bsr	vsync
		move.w	#3,balkenpos
		bsr	drawbalken
		clr.b	zeichen
		bra	waitmenukey
nixbalkenoben2:	bsr     drawbalken              ; Balken lîschen
                subq.w  #1,balkenpos
                bsr     vsync
                bsr     drawbalken              ; Balken zeichnen
                clr.b   zeichen
                bra     waitmenukey
notbalkenhoch2: btst    #1,d0                   ; Joy runter ?
                beq.s   notbalkenrunter2
                cmp.w   #3,balkenpos            ; schon unten?
                bne     nixbalkenunten2
                bsr	drawbalken
		bsr	vsync
		move.w	#0,balkenpos
		bsr	drawbalken
		clr.b	zeichen
		bra	waitmenukey
nixbalkenunten2:bsr     drawbalken
                addq.w  #1,balkenpos
                bsr     vsync
                bsr     drawbalken
                clr.b   zeichen
                bra     waitmenukey
notbalkenrunter2:btst   #2,d0                   ; Cursor links?
                beq     notcursorleft2
                tst.w   balkenpos               ; nicht oben!
                bne     waitmenukey
                cmp.w   #1,currentlevel
                beq     from1to50_2             ; schon Level 1!
                subq.w  #1,currentlevel
prl3:           bsr     vsync
;                clr.b   zeichen
                bsr     printlevel
		bsr	vsync
		bsr	vsync
		bsr	vsync
		bsr	vsync
		bsr	vsync
		bsr	vsync
                bra     waitmenukey
from1to50_2:	move.w	#50,currentlevel
		bra.s	prl3
notcursorleft2: btst    #3,d0                   ; Cursor rechts?
                beq     notcursorright2
                tst.w   balkenpos               ; nicht oben!
                bne     waitmenukey
                cmp.w   #50,currentlevel
                beq     from50to1_2             ; schon Level 50!
                addq.w  #1,currentlevel
prl4:           bsr     vsync
;                clr.b   zeichen
                bsr     printlevel
		bsr	vsync
		bsr	vsync
		bsr	vsync
		bsr	vsync
		bsr	vsync
		bsr	vsync
                bra     waitmenukey
from50to1_2:	move.w	#1,currentlevel
		bra.s	prl4
notcursorright2:btst    #7,d0                   ; Fire?
                beq     waitmenukey
                cmp.w   #1,balkenpos
                bne.s   nixentername2
                bra     entername
nixentername2:  cmp.w   #2,balkenpos
                bne.s   nixshowhighs2
                bra     showhighscores
nixshowhighs2:  cmp.w   #3,balkenpos
                bne     waitmenukey
                clr.b   zeichen
                rts             

entername:      bsr     eingabe                 ; Namen eingeben        
                cmp.b   #0,namebuff
                bne.s   notnoname               ; nix eingegeben?
                lea     namebuff,a1
                lea     defaultname(pc),a0
copydefname:    move.b  (a0)+,(a1)+             ; Defaultname!
                bne.s   copydefname                             

notnoname:      clr.b   zeichen
                clr.b   key
                bra     menu

showhighscores:	movem.l	leerfeld,d0-d7
		movem.l	d0-d7,$ffff8240.w	

		bsr	makehightable

		move.l	screen(pc),a0
		bsr	cls
		move.l	screen2(pc),a0
		bsr	cls
		

		bsr	inithighs		; Texte...
		bsr	switch
		bsr	inithighs

		movem.l	menupalette,d0-d7
		movem.l	d0-d7,$ffff8240.w
		
		move.l	#vblhighscores,$70.w		

		clr.b	zeichen
		clr.b	key

waiitt:		bsr	vsync
		move.b	key(pc),d0
		cmp.b	#$39,d0			; Space?
		beq	endhighs		
		cmp.b	#$48,d0			; UP?
		bne.s	nixupscores
		tst.w	highy			; schon oben?
		beq.s	waiitt
		sub.w	#40,highy
		bra.s	waiitt
nixupscores:	cmp.b	#$50,d0			; DOWN?
		bne.s	nixdownscores
		cmp.w	#10560,highy
		beq	waiitt
		add.w	#40,highy
		bra.s	waiitt
nixdownscores:	move.b	zeichen(pc),d0
		btst	#7,d0			; Fire?
		bne	endhighs		
		btst	#0,d0			; UP?
		beq.s	nixupscores2
		tst.w	highy			; schon oben?
		beq.s	waiitt
		sub.w	#40,highy
		bra.s	waiitt
nixupscores2:	btst	#1,d0			; DOWN?
		beq.s	waiitt
		cmp.w	#10560,highy
		beq	waiitt
		add.w	#40,highy
		bra.L	waiitt


endhighs:	clr.b   zeichen
                clr.b   key

		move.l	#vblgame,$70.w

		move.l	screen(pc),d0
		bsr	setscreen

                bra     menu


inithighs:	lea	highzeile1,a0
		move.w	#163,d0
		moveq	#0,d1
		moveq	#3,d2
		bsr	textaus

		lea	highzeile0,a0
		moveq	#18,d0
		moveq	#1,d1
		moveq	#3,d2
		bsr	textaus2
		
		move.l	screen(pc),a0
		lea	3*160(a0),a0
		move.w	#[18*20]-1,d0
filll:		move.w	#-1,4(a0)
		lea	8(a0),a0
		dbra	d0,filll
		rts

drawbalken:     move.w  balkenpos,d0
                addq.w  #1,d0
                mulu    #35*160,d0      
                move.l  screen(pc),a0
                add.w   d0,a0
                move.w  #[18*20]-1,d0
drawbalkenloop: eor.w   #-1,6(a0)
                lea     8(a0),a0
                dbra    d0,drawbalkenloop
                rts     
                

printlevel:     move.w  currentlevel,d0
                bsr     hex_dez
                lea     dezzahl+4(pc),a0
                moveq   #2,d0
                moveq   #16,d1
                moveq   #35,d2
                bsr     textaus2
                rts

eingabe:        

                lea     namebuff,a0
                moveq   #19,d0                  ; 20 Zeichen
clrnamebuff:    clr.b   (a0)+
                dbra    d0,clrnamebuff
        
                move.l  screen(pc),a0
                bsr     cls

                movem.l eingabepalette(pc),d0-d7
                movem.l d0-d7,$ffff8240.w

                lea     enternametext(pc),a0
                moveq   #20,d0
                moveq   #0,d1
                move.w  #70,d2
                bsr     textaus2


                move.l  screen(pc),a0
                lea     111*160(a0),a0
                move.w  #[18*20]-1,d0
fillpl:         move.w  #-1,4(a0)
                lea     8(a0),a0
                dbra    d0,fillpl

                lea     cursortext(pc),a0
                moveq   #1,d0
                moveq   #0,d1
                move.w  #111,d2
                bsr     textaus2                

                lea     namebuff,a6
                moveq   #0,d5                   ; Anz. der schon eing. Zeichen=0
eingabeloop0:   clr.b   key
                bsr     vsync
                move.b  key,d0
                tst.b   d0
                beq.s   eingabeloop0
                cmp.b   #$0e,d0                 ; Backspace?
                beq     backspace
                cmp.b   #$1c,d0                 ; Return?
                beq     endeingabe
                cmp.w   #20,d5                  ; Zeichen schon maximal
                bge     eingabeloop0
                bsr     scantoascii
                tst.b   d0
                beq     eingabeloop0
                move.b  d0,(a6)+
                addq.w  #1,d5                   ; Zeichen +1
                lea     -1(a6),a0
                moveq   #1,d0
                move.w  d5,d1
                subq.w  #1,d1
                move.w  #111,d2
                bsr     textaus2
                addq.w  #1,d1                   ; X-Pos +1
                cmp.w   #20,d1
                beq     eingabeloop0
                lea     cursortext(pc),a0
                moveq   #1,d0
                move.w  #111,d2
                bsr     textaus2                ; gibt Cursor aus
                bra     eingabeloop0
endeingabe:     move.b  #0,(a6)+
                rts
backspace:      tst.w   d5
                beq     eingabeloop0    ; noch kein Zeichen eingegeben
                lea    -1(a6),a6
                clr.b   (a6)
                subq.w  #1,d5           ; Zeichen -1

                cmp.w   #20,d1
                beq     notspaceit

                lea     cursortext+1(pc),a0                
                moveq   #1,d0
                move.w  #111,d2
                bsr     textaus2

notspaceit:     subq.w  #1,d1
                cmp.w   #20,d1
                beq     eingabeloop0

                lea     cursortext(pc),a0
                moveq   #1,d0
                move.w  #111,d2
                bsr     textaus2
                bra     eingabeloop0

scantoascii:    moveq   #0,d7
                move.b  d0,d7
                lea     asciitab(pc),a0
                moveq   #0,d0
                move.b  0(a0,d7.w),d0
                rts

cursortext:     dc.b    ". "
asciitab:       dc.b 0,0                ; 0 und ESC
                dc.b "1234567890"       ; 2 bis $b
                dc.b 0,0,0,0            ; $c-$f
                dc.b "QWERTZUIOP"       ; $E-$19
                dc.b 0,0,0,0            ; $1a-$1d
                dc.b "ASDFGHJKL"        ; $1e-$26
                dc.b 0,0,0,0,0          ; $27-$2b
                dc.b "YXCVBNM"          ; $2c-$32
                dc.b 0,0,0,0,0,0," ",0  ; $33-$3a
                blk.b 200,0
                even


textaus3:
; gibt Text in Hightable aus
; Parameter: in a0: Pointer auf Text
;             in d0: Laenge des Textes
;             in d1: x-Pos (0-39)
;             in d2: y-Pos (0-49) 

                movem.l d0-d7/a0-a6,-(a7)
		lea	hightable,a1
		and.l	#$ffff,d2
                moveq   #0,d3
                moveq   #0,d4
                move.w  d0,d7
                subq.w  #1,d7
                move.w  d1,d3
                ror.w   #1,d3           ; Bitblock ermitteln
                move.w  d3,d4
                lsl.w   #1,d4           ; *2 -> Bitblock
                adda.w  d4,a1
                rol.w   #1,d3           ; Rest zurÅck
                and.w   #1,d3
                adda.w  d3,a1           ; +1 oder 0
                mulu    #8*40,d2        ; Y-Pos
                adda.l  d2,a1
textloop2:	lea     chars8(pc),a4
                moveq   #0,d0
                move.b  (a0)+,d0        ; Text holen (ASCII)
                cmp.b   #0,d0           ; Ende
                beq     endtext2
                cmp.b   #'_',d0
                bne.s   isnixunter2
                move.b  #' ',d0
isnixunter2:	subi.b  #' ',d0         ; erstes Zeichen
                divu    #40,d0          ; Zeile
                move.w  d0,d1
                mulu    #7*40,d1        ; Zeile*40
                swap    d0
                adda.w  d0,a4
                adda.w  d1,a4

                move.w  #6,d6           ; 7 Scanlines
                move.l a1,a5
copyt2:         move.b  (a4),(a5)
                lea     40(a4),a4       ; im Charscreen tiefer
                lea     40(a5),a5       ; eine Scanline tiefer
                dbra    d6,copyt2
                addq.w  #1,a1           ; nur 1 Byte weiter
	        dbra    d7,textloop2
endtext2:       movem.l (a7)+,d0-d7/a0-a6
                rts


textaus2:
; gibt 16*18 Font aus!
; a0=Pointer
; d0=LÑnge
; d1=X-Pos (0-19)
; d2=Y-Pos (0-199-18)
                movem.l d0-d7/a0-a3,-(a7)
                subq.w  #1,d0           ; LÑnge-1
                mulu    #160,d2         ; Y*Bytes/Scanlines
                lsl.w   #3,d1           ; X*8 -> Bitblock
                move.l  screen(pc),a1
                add.w   d2,a1
                add.w   d1,a1
textausloop2:   moveq   #0,d1
                move.b  (a0)+,d1
                cmp.b   #' ',d1         ; bei Space nur addieren
                beq     warspace
                cmp.b   #'A',d1
                blt     warkeinbuchstabe
                cmp.b   #'Z',d1
                bgt     warkeinbuchstabe
                sub.b   #'A',d1
                bra     charfound
warkeinbuchstabe:
                cmp.b   #'!',d1
                bne.s   warkeinausrufe
                moveq   #37,d1
                bra.s   charfound
warkeinausrufe: cmp.b   #'.',d1
                bne.s   warkeinpunkt
                moveq   #39,d1
                bra.s   charfound
warkeinpunkt:   cmp.b   #'0',d1
                blt     warspace
                cmp.b   #'9',d1
                bgt     warspace
                sub.b   #'0',d1
                add.w   #27,d1
charfound:      mulu    #18*4,d1
                lea     font,a2
                add.w   d1,a2           ; damit Zeichen
                move.l  a1,a3
                moveq   #17,d1          ; 18 Zeilen
copychar:       move.l  (a2)+,(a3)
                lea     160(a3),a3
                dbra    d1,copychar
conttext:       lea     8(a1),a1        ; nÑchster Bitblock
                dbra    d0,textausloop2
                movem.l (a7)+,d0-d7/a0-a3
                rts
warspace:       move.l  a1,a3
                moveq   #17,d1
drawspace:      clr.l   (a3)
                lea     160(a3),a3
                dbra    d1,drawspace
                bra.s   conttext


textaus:
; Parameter: in a0: Pointer auf Text
;             in d0: Laenge des Textes
;             in d1: x-Pos (0-39)
;             in d2: y-Pos (0-24)

                movem.l d0-d7/a0-a6,-(a7)
                moveq   #0,d3
                moveq   #0,d4
                move.w  d0,d7
                subq.w  #1,d7
                move.w  d1,d3
                ror.w   #1,d3           ; Bitblock ermitteln
                move.w  d3,d4
                lsl.w   #3,d4           ; *8 -> Bitblock
                move.l screen,a1
                lea 160(a1),a1
                adda.w  d4,a1
                rol.w   #1,d3           ; Rest zurÅck
                and.w   #1,d3
                adda.w  d3,a1           ; +1 oder 0
                mulu    #8*160,d2       ; Y-Pos
                adda.w  d2,a1
textloop:
                lea     chars8(pc),a4
                moveq   #0,d0
                move.b  (a0)+,d0        ; Text holen (ASCII)
                cmp.b   #13,d0          ; CR
                beq     carr_ret
                cmp.b   #0,d0           ; Ende
                beq     endtext
                cmp.b   #'_',d0
                bne.s   isnixunter
                move.b  #' ',d0
isnixunter:
                subi.b  #' ',d0         ; erstes Zeichen
                divu    #40,d0          ; Zeile
                move.w  d0,d1
                mulu    #7*40,d1        ; Zeile*40
                swap    d0
                adda.w  d0,a4
                adda.w  d1,a4

                move.w  #6,d6           ; 7 Scanlines
                move.l a1,a5
copyt:          move.b  (a4),(a5)
                lea     40(a4),a4       ; im Charscreen tiefer
                lea     160(a5),a5      ; eine Scanline tiefer
                dbra    d6,copyt
                move.w  a1,d0
                btst    #0,d0
                bne     addsev
                addq.w  #1,a1           ; nur 1 Byte weiter
                bra     tweiter
addsev:         addq.w  #7,a1           ; naechster Bitblock
tweiter:        dbra    d7,textloop
endtext:        movem.l (a7)+,d0-d7/a0-a6
                rts

berechnung:     lea	chars8,a6
		subi.b  #' ',d0         ; erstes Zeichen
                divu    #40,d0          ; Zeile
                move.w  d0,d1
                mulu    #7*40,d1        ; Zeile*40
                swap    d0
                adda.w  d0,a6
                adda.w  d1,a6
		rts
carr_ret:
                move.l  a1,d0           ; Textpos on Screen
                sub.l   screen,d0
                divu    #160,d0         ; damit Zeile
                addq.w  #8,d0           ; eine Charzeile drauf)
                and.l   #$ffff,d0
                mulu    #160,d0
                move.l  screen(pc),a1
                adda.w  d0,a1
                bra     tweiter

BASIS=$60000

FSTTAB: DC.B 1,$2F,1,$2F,3,$2F,$FF
SNDTAB: DC.B 1,$2F,$1,$28,1,$20,1,$28,1,$2F,$FF
TRDTAB: DC.B 1,$2F,$2,$2F,$2,$2F,2,$2F,3,$2F,3,$2F,3,$2F,3,$2F
        DC.B $FF
EVEN
;---------------------------------------------------------------------------
;RAUSCHTABELLEN  (SUPER)
;STARTS
RTAB:   DC.L  R0,R1,R2,R3,R4,R5,R6,R7,R8,R9,RA,RB,RC,RD,RE,RF
R0:     DC.B 1,$2F,$2,$2F,$3,$2F,2,$2F,1,$2F,3,$2F,2,$2F,2,$2F
        DC.B $FF
R1:     DC.B 1,$2F,2,$2F,3,$2F,$FF
R2:     DC.B 1,$2F,1,$2F,3,$2F,$2,$2F,$1,$28,1,$30,$FF
R3:     DC.B 1,$2F,$3,$2F,$1,$2F,1,$2F,3,$2F,3,$2F,3,$2F,3,$2F,$FF
R4:
        DC.B 1,$2F,$2,$2F,$3,$2F,2,$2F,1,$2F,3,$2F,3,$2F,3,$2F
        DC.B $FF
R5:
        DC.B 1,$2F
        DC.B 1,$2F
        DC.B 1,$2F
        DC.B 1,$2F
        DC.B 1,$2F
        DC.B 1,$2F
        DC.B 1,$2F
        DC.B 1,$2F
        DC.B 1,$2F
        DC.B 1,$2F
        DC.B 1,$2F
        DC.B 1,$2F
        DC.B 1,$2F
        DC.B $FF


R6:     DC.B 3,$2F,$FF
R7:     DC.B 3,$2F,$FF
;FUER DRUMS RESERVIERT
R8:     DC.B 1,$33,$1,$33,$3,$2F,3,$2F,1,$32,1,$33,1,$33,3,$33
        DC.B $FF
R9:     DC.B 3,$33,1,$33,$3,$33,$3,$33,$3,$33,$3,$33,$FF


RA:     DC.B 3,$2F,$FF
RB:     DC.B 3,$2F,$FF
RC:     DC.B 3,$2F,$FF
RD:     DC.B 3,$2F,$FF
RE:     DC.B 3,$2F,$FF
RF:     DC.B 3,$2F,$FF

;----------------------------------------------------------------------------
;DIE MODULATION DER MODULATION .
;IDEE VON ERIK SIMON
;1.BYTE VIBRATO-SPEED      ($80) FUER NICHT SETZEN
;2.BYTE VIBRATO-STAERKE    ($80)  ''    ''    ''
;3.BYTE VOLUME-OFFSET
;4.FREQUENZ-OFFSET
;$FF FUER AUFHOEREN
;$FE FUER WIEDER VON VORNE
;----------------------------------------------------------------------------
MODULA:
        DC.L M0+1,M1+1,M2+1,M3+1,M4+1,M5+1,M6+1,M7+1,M8+1,M9+1
        DC.L MA+1,MB+1,MC+1,MD+1,ME+1,MF+1
M0:     DC.B 4
        DC.B   1,  2,0,0
        DC.B   2,  3,0 ,0
        DC.B   3,  4,0 ,0
        DC.B   4,  5,0 ,0
        DC.B   3,  4,0,0
        DC.B   2,  3,0,0
        dC.B $FE
M1:     DC.B 5
        DC.B 1,2,0,0
        DC.B 2,3,0,0
        DC.B $FE
M2:     DC.B 8
        DC.B 1,2,0,0
        DC.B 3,4,0,0,$FE
        DC.B $80,$80,$0,$0,$FF
M3:     DC.B 3
        DC.B $80,$80,$0,$0
        DC.B $80,$80,$0,$0
        DC.B $80,$80,-1,$0
        DC.B $80,$80,-2,$0
        DC.B $80,$80,-3,$0
        DC.B $80,$80,-4,$0
        DC.B $80,$80,-4,$0
        DC.B $80,$80,-5,$0
        DC.B $80,$80,-6,$0
        DC.B $80,$80,-6,$0
        DC.B $80,$80,-7,$0
        DC.B $80,$80,-7,$0
        DC.B $80,$80,-8,$0
        DC.B $80,$80,-8,$0
        DC.B $80,$80,-7,$0
        DC.B $80,$80,-6,$0
        DC.B $80,$80,-5,$0
        DC.B $80,$80,-4,$0
        DC.B $80,$80,-3,$0
        DC.B $80,$80,-2,$0
        DC.B $80,$80,-1,$0
        DC.B $80,$80, 0,$0
        DC.B $80,$80,-1,$0
        DC.B $80,$80,-2,0
        DC.B $80,$80,-3,$0
        DC.B $80,$80,-4,$0
        DC.B $80,$80,-5,$0
        DC.B $80,$80,-6,$0
        DC.B $80,$80,-7,$0
        DC.B $80,$80,-8,$0
        DC.B $80,$80,-9,$0
        DC.B $80,$80,-10,$0
        DC.B $80,$80,-11,$0
        DC.B $80,$80,-12,$0
        DC.B $FE
M4:     DC.B 3
        DC.B $00,$00,$0,$00
        DC.B $01,$02,$0,$00
        DC.B $02,$03,$0,$00
        DC.B $03,$04,$0,$00
        DC.B $04,$05,$0,$00
        DC.B $05,$06,$0,$00
        DC.B $06,$07,$0,$00
        DC.B $07,$08,$0,$00
        DC.B $08,$09,$0,$00
        DC.B $09,$0A,$0,$00
        DC.B $0A,$0B,$0,$00
        DC.B $0B,$0C,$0,$00
        DC.B $0C,$0E,$0,$00
        DC.B $0D,$10,$0,$00
        DC.B $0E,$11,$0,$00
        DC.B $0F,$12,$0,$00
        DC.B $10,$13,$0,$00
        DC.B $11,$14,$0,$00
        DC.B $12,$15,$0,$00
        DC.B $13,$16,$0,$00
        DC.B $14,$17,$0,$00
        DC.B $15,$18,$0,$00
        DC.B $16,$19,$0,$00
        DC.B $17,$20,$0,$00
        DC.B $18,$21,$0,$00
        DC.B $19,$22,$0,$00
        DC.B $20,$23,$0,$00





        DC.B $FF

M5:     DC.B 2
        DC.B $80,$80,$0,$0
        DC.B $80,$80,-1,$0
        DC.B $80,$80,-2,$0
        DC.B $80,$80,-3,$0
        DC.B $80,$80,-4,$0
        DC.B $80,$80,-4,$0
        DC.B $80,$80,-5,$0
        DC.B $80,$80,-6,$0
        DC.B $80,$80,-6,$0
        DC.B $80,$80,-7,$0
        DC.B $80,$80,-7,$0
        DC.B $80,$80,-8,$0
        DC.B $80,$80,-8,$0
        DC.B $80,$80,-7,$0
        DC.B $80,$80,-6,$0
        DC.B $80,$80,-5,$0
        DC.B $80,$80,-4,$0
        DC.B $80,$80,-3,$0
        DC.B $80,$80,-2,$0
        DC.B $80,$80,-1,$0
        DC.B $FE
M6:     DC.B 1
        DC.B $80,$80,$0,$0,$FF
M7:     DC.B 1
        DC.B $80,$80,$0,$0,$FF
M8:     DC.B 1
        DC.B $80,$80,$0,$0,$FF
M9:     DC.B 1
        DC.B $80,$80,$0,$0,$FF
MA:     DC.B 1
        DC.B $80,$80,$0,$0,$FF
MB:     DC.B 1
        DC.B $80,$80,$0,$0,$FF
MC:     DC.B 1
        DC.B $80,$80,$0,$0,$FF
MD:     DC.B 1
        DC.B $80,$80,$0,$0,$FF
ME:     DC.B 1
        DC.B $80,$80,$0,$0,$FF
MF:     DC.B 1
        DC.B $80,$80,$0,$0,$FF

EVEN
;------------------------------------------------------------------
TABS:   DC.L FSNDTAB+1,SSNDTAB+1,TSNDTAB+1,TSNDTAB+1,TSNDTAB+1

FSNDTAB:DC.B $01,$0C,$0C,$00,$FF
SSNDTAB:DC.B $01,$F4,$F4,$F4,$FF
TSNDTAB:DC.B $01,$0C,$F4,$00,$FF
EVEN
NTABS:  DC.L N1NDTAB+1,N2NDTAB+1,N3NDTAB+1,N4NDTAB+1,N5NDTAB+1
        DC.L N6NDTAB+1,N7NDTAB+1,N8NDTAB+1
        DC.L N9NDTAB+1,NANDTAB+1,NBNDTAB+1,NCNDTAB+1,NDNDTAB+1
        DC.L NENDTAB+1,NFNDTAB+1,NGNDTAB+1

N1NDTAB:DC.B $01,$30,$30,$30,$FF
N2NDTAB:DC.B $01,$13,$13,$13,$FF
N3NDTAB:DC.B $01,$2E,$2E,$2E,$FF
N4NDTAB:DC.B $01,$16,$16,$16,$FF
N5NDTAB:DC.B $01,$14,$14,$14,$FF
N6NDTAB:DC.B $01,$14,$14,$14,$FF
N7NDTAB:DC.B $01,$14,$14,$14,$FF
N8NDTAB:DC.B $01,$14,$14,$14,$FF

;FUER DRUMS RESERVIERT
N9NDTAB:DC.B $01,$1C,$1C,$20,$FF
NANDTAB:DC.B $01,$18,$19,$17,$12,$FF
NBNDTAB:DC.B $01,$14,$14,$14,$FF
NCNDTAB:DC.B $01,$14,$14,$14,$FF
NDNDTAB:DC.B $01,$14,$14,$14,$FF
NENDTAB:DC.B $01,$14,$14,$14,$FF
NFNDTAB:DC.B $01,$14,$14,$14,$FF
NGNDTAB:DC.B $01,$14,$14,$14,$FF




EVEN
;----------------------------------------------------------------------------
B1F85E:
        dc.b 000,000,000,000,000,000,025,248,000,000,000,000,000,000,000,000
        dc.b 014,238,014,023,013,077,012,142,011,217,011,047,010,142,009,247
        dc.b 009,103,008,224,008,097,007,232,007,119,007,011,006,166,006,071
        dc.b 005,236,005,151,005,071,004,251,004,179,004,112,004,048,003,244
        dc.b 003,187,003,133,003,083,003,035,002,246,002,203,002,163,002,125
        dc.b 002,089,002,056,002,024,001,250,001,221,001,194,001,169,001,145
        dc.b 001,123,001,101,001,081,001,062,001,044,001,028,001,012,000,253
        dc.b 000,238,000,225,000,212,000,200,000,189,000,178,000,168,000,159
        dc.b 000,150,000,142,000,134,000,126,000,119,000,112,000,106,000,100
        dc.b 000,094,000,089,000,084,000,079,000,075,000,071,000,067,000,063
        dc.b 000,059,000,056,000,053,000,050,000,047,000,044,000,042,000,039
        dc.b 000,037,000,035,000,033,000,031,000,029,000,028,000,026,000,025
        dc.b 000,023,000,022,000,021,000,019,000,018,000,017,000,016,000,015

B1F92E: DC.L B1F96A+1,F_CK+1,B1F970+1,B1F974+1
        DC.L B1F979+1,B1F97E+1,B1F982+1,B1F986+1
        DC.L B1F98A+1,B1F98E+1,B1F991+1,B1F994+1
        DC.L DEMO_J+1,DEMO_JT+1,CLAVE+1,BASEDR+1
        DC.L ZERO+1
        DC.L ONE+1,TWO+1,THREE+1,FOUR+1
        DC.L FIVE+1,SIX+1,SEVEN+1,EIGHT+1,NINE+1
        DC.L TEN+1,ELEVEN+1,TWELVE+1,THIRTT+1,FOURTT+1,FIFTT+1
        DC.L ZERO+1
        DC.L NONE+1,NTWO+1,NTHREE+1,NFOUR+1
        DC.L NFIVE+1,NSIX+1,NSEVEN+1,NEIGHT+1,NNINE+1
        DC.L NTEN+1,NELEVEN+1,NTWELVE+1,NTHIRTT+1,NFOURTT+1,NFIFTT+1
        DC.L UP+1,DOWN+1,DDOWN+1,DTOWN+1,DCOWN+1
        DC.L IBALL1+1,IBALL2+1,IBALL3+1,IBALL4+1,IBALL5+1,IBALL6+1,IBALL7+1
        DC.L PHANT1+1,PHANT2+1,UKNOWN1+1,UKNOWN2+1
        DC.L UKNOWN3+1,UKNOWN4+1,UKNOWN5+1,UKNOWN6+1,UKNOWN7+1
        DC.L UKNOWN8+1,UKNOWN9+1,UKNOWNA+1
        DC.L LN1+1,LN2+1,LN3+1,LN4+1,LN5+1
        DC.L ZOIDS1+1,ZOIDS2+1,THING1+1
        DC.L WIZ+1
        DC.L LF1+1,LF2+1,LF3+1,LF4+1,LF5+1,LF6+1
        DC.L WAR1+1,WAR2+1,WAR3+1,WAR4+1,THRUST1+1,THRUST2+1
        DC.L BN0+1,BN1+1,SCOUT1+1,SCOUT2+1,SCOUT3+1,SCOUT4+1,SCOUT5+1
        DC.L JT0+1,JT1+1,JT2+1,JT3+1,JT4+1,JT5+1
        DC.L CYBER0+1,CYBER1+1,CYBER2+1,CYBER3+1,CYBER4+1,CYBER5+1,CB6+1,CB7+1
CB6:    DC.B 0,$0,$3,$7,$8F
CB7:    DC.B 0,$0,$4,$9,$8F
F_CK:
        DC.B 0,0,4,8,12,16,20,24,28,32,36,40,44,48,52,56,60,64,68,72,$8F

CYBER0: DC.B 0,$0,$3,$7,$8F
CYBER1: DC.B 0,$0,$4,$7,$8F
CYBER2: DC.B 0,$0,$5,$8,$8F
CYBER3: DC.B 0,$0,$5,$9,$8F
CYBER4: DC.B 0,$0,$3,$6,$8F
CYBER5: DC.B 0,$0,$5,$7,$8F

JT0:
        DC.B 0,$0,$7,$A,$8F
JT1:
        DC.B 0,$0,$5,$9,$8F
JT2:
        DC.B 0,$0,$4,7,$8F
JT3:
        DC.B 0,$0,$7,$C,$8F
JT4:
        DC.B 0,$0,$2,$5,$8F
JT5:
        DC.B 0,$0,$7,$8F

SCOUT4: DC.B $0,$0,$C,$18,$8F
SCOUT1:
        DC.B $0,$0,$08,$05,$8F
SCOUT2:
        DC.B $0,$0,$04,$07,$8F
SCOUT3:
        DC.B $0,$0,$05,$09,$8F
SCOUT5: DC.B 0,$2D,$28,$25,$20,$1D,$19,$19,$14,$14,$0D,$0D,$14,$14,$8F


THRUST2:DC.B 0,0,0,0,0,0,0,-1,-2,-3,-4,-5,-6,-7,-8,$8E
THRUST1:DC.B 0
        DC.B $D5,$D5,$E1,$E1,$D6,$D6,$E2,$E2,$D7,$D7,$E3,$E3,$D8,$D8,$E4,$E4
        DC.B $D9,$D9,$E5,$E5,$DA,$DA,$E6,$E6,$DB,$DB,$E7,$E7,$DC,$DC,$E8,$E8
        DC.B $DD,$DD,$E9,$E9,$DE,$DE,$EA,$EA,$DF,$DF,$EB,$EB,$E0,$E0,$EC,$EC
        DC.B $E1,$E1,$ED,$ED,$E2,$E2,$EE,$EE,$E3,$E3,$EF,$EF
        DC.B $E4,$E4,$F0,$F0,$E5,$E5,$F1,$F1,$E6,$E6,$F2,$F2,$E7,$E7,$F3,$F3
        DC.B $E8,$E8,$F4,$F4,$E9,$E9,$F5,$F5,$EA,$EA,$F6,$F6
        DC.B $EB,$EB,$F7,$F7,$EC,$EC,$F8,$F8,$ED,$ED,$F9,$F9,$EE,$EE,$FA,$FA
        DC.B $EF,$EF,$FB,$FB,$F0,$F0,$FC,$FC,$F1,$F1,$FD,$FD
        DC.B $F2,$F2,$FE,$FE,$F3,$F3,$FF,$FF,$F4,$F4,$00,$00,$F5,$F5,$01,$01
        DC.B $F6,$F6,$02,$02,$F7,$F7,$03,$03,$F8,$F8,$04,$04
        DC.B $F9,$F9,$05,$05,$FA,$FA,$06,$06,$FB,$FB,$07,$07,$FC,$FC,$08,$08
        DC.B $FD,$FD,$09,$09,$FE,$FE,$0A,$0A,$FF,$FF,$0B,$0B
        DC.B $00,$00,$0C,$0C,$01,$01,$0D,$0D,$02,$02,$0E,$0E,$03,$03,$0F,$0F
        DC.B $04,$04,$10,$10,$05,$05,$11,$11,$06,$06,$12,$12
        DC.B $07,$07,$13,$13,$08,$08,$14,$14,$09,$09,$15,$15,$0A,$0A,$16,$16
        DC.B $0B,$0B,$17,$17,$0C,$0C,$18,$18,$0D,$0D,$19,$19
        DC.B $0E,$0E,$1A,$1A,$0F,$0F,$1B,$1B,$10,$10,$1C,$1C,$11,$11,$1D,$1D
        DC.B $12,$12,$1E,$1E,$13,$13,$1F,$1F,$14,$14,$20,$20,$15,$15,$21,$21
        DC.B $16,$16,$22,$22,$17,$17,$23,$23,$18,$18,$24,$24,$19,$19,$25,$25
        DC.B $1A,$1A,$26,$26,$1B,$1B,$27,$27,$1C,$1C,$28,$28,$1D,$1D,$29,$29
        DC.B $1E,$1E,$2A,$2A,$1F,$1F,$2B,$2B,$20,$20,$2C,$2C,$21,$21,$2D,$2D
        DC.B $22,$22,$2E,$2E,$23,$23,$2F,$2F,$24,$24,$30,$30,$25,$25,$31,$31
        DC.B $26,$26,$32,$32,$27,$27,$8F
LF1:    DC.B $0,$FC,$0,$F9,0,$8F
LF2:    DC.B $0,$FB,$0,$F7,0,$8F
LF3:    DC.B $0,$FD,$0,$F8,0,$8F
LF4:    DC.B $0,$FD,$0,$F9,0,$8F
LF5:    DC.B $0,$FB,$0,$F8,0,$8F
LF6:    DC.B $0,$FC,$0,$F7,0,$8F
BN0:    DC.B $0,$0C,$0,$00,0,$8F
BN1:    DC.B $0,$FB,$0,$F8,0,$8F
WAR1:   DC.B $0,0,$FC,$F7,$8F
WAR2:   DC.B $0,0,$FD,$F9,$8F
WAR3:   DC.B $0,0,$FC,$F7,$8F
WAR4:   DC.B $0,0,$0C,$F4,$8F

;WAR1:   DC.B $0,$FC,$0,$F7,0,$8F
;WAR2:   DC.B $0,$FD,$0,$F9,0,$8F
;WAR3:   DC.B $0,$FC,$0,$F7,0,$8F
;WAR4:   DC.B $0,$0C,$0,$F4,0,$8F


WIZ:    DC.B $0,$FE,$FF,$00,$8E
CLAVE:  DC.B 0,$0,$FF,$FE,$FD,$8E
BASEDR: DC.B 0,$0,$FC,$F8,$F4,$F0,$EC,$E8,$E4,$8E
LN1:    DC.B $0,$00,$03,$07,$0C,$8F
LN2:    DC.B $0,$00,$05,$09,$0C,$8F
LN3:    DC.B $0,$00,$FC,$03,$08,$8F
LN4:    DC.B $0,$00,$05,$09,$0C,$8F
LN5:    DC.B $0,$00,$07,$0C,$07,$8F
UKNOWN1:DC.B 0,$FC,$0,$F9,0,$8F
UKNOWN2:DC.B 0,$FC,$0,$F9,0,$8F
UKNOWN3:DC.B 0,$FD,$0,$F9,0,$8F
UKNOWN4:DC.B 0,$FD,$0,$F8,0,$8F
UKNOWN5:DC.B 0,$FB,$0,$F9,0,$8F
UKNOWN6:DC.B 0,$FB,$0,$F8,0,$8F
UKNOWN7:DC.B 0,$FA,$0,$F7,0,$8F
UKNOWN8:DC.B 0,$FC,$0,$F7,0,$8F
UKNOWN9:DC.B 0,$FB,$0,$F8,0,$8F
UKNOWNA:DC.B 0,$FD,$0,$FA,0,$8F
DEMO_JT:
        DC.B 1,0,0,24,12,0,24,12,0,24,12,0,24,12,0,-1,-1,-2,-2,-3,-3,-4,-4,-5,-5,-6,-6,-7,-7,-8,-8,-9,-9
        DC.B -10,-10,-11,-11,-12,-12,-13,-13,-14,-14,-15,-15,-16,-16,-17,-17
        DC.B -18,-18,-19,-19,-20,-20,-21,-21,-22,-22,-23,-23,-24,-24,-25,-25
        DC.B -26,-26,-27,-27,-28,-28,-29,-29,-30,-30,-31,-31,-32,-32,-33,-33
        DC.B -34,-34,-35,-35,-36,-36,-37,-37,-38,-38,-39,-39,-40,-40,-41,-41
        DC.B -42,-42,-43,-43,-44,-44,-45,-45,-46,-46,-47,-47
        DC.B 0,$8E
DEMO_J:
        DC.B 1,0,0,0,0,0,0,0,-1,-1,-2,-2,-3,-3,-4,-4,-5,-5,-6,-6,-7,-7,-8,-8,-9,-9
        DC.B -10,-10,-11,-11,-12,-12,-13,-13,-14,-14,-15,-15,-16,-16,-17,-17
        DC.B -18,-18,-19,-19,-20,-20,-21,-21,-22,-22,-23,-23,-24,-24,-25,-25
        DC.B -26,-26,-27,-27,-28,-28,-29,-29,-30,-30,-31,-31,-32,-32,-33,-33
        DC.B -34,-34,-35,-35,-36,-36,-37,-37,-38,-38,-39,-39,-40,-40,-41,-41
        DC.B -42,-42,-43,-43,-44,-44,-45,-45,-46,-46,-47,-47
        DC.B 0,$8E
IBALL1: DC.B 1,$00,$18,$8F
IBALL2: DC.B 1,$00,$18,$8F
IBALL3: DC.B 1,$00,$07,$8F
IBALL4: DC.B 1,$0C,$04,$8F
IBALL5: DC.B 1,$09,$05,$8F
IBALL6: DC.B 1,$08,$05,$8F
IBALL7: DC.B 1,$00,$00,$8F

B1F96A: DC.B $00,$00,$00,$00,$00,$8E
TTT:
B1F96C: DC.B $00,$00,$0C,$00,$0C,$8F
B1F970: DC.B $00,$0C,$07,$03,$00,$8F
B1F974: DC.B $00,$0C,$07,$0C,$07,$8F
B1F979: DC.B $01,$00,$05,$8F,$0C,$FF
B1F97E: DC.B $00,$00,$00,$0C,$8F,0
B1F982: DC.B $00,$07,$0C,$10,$8F,0
B1F986: DC.B $00,$03,$07,$0C,$8F,0
B1F98A: DC.B $00,$0C,$00,$0C,$8F,0
B1F98E: DC.B $00,$00,$0C,$8F
B1F991: DC.B $00,$00,$04,$8f
B1F994: DC.B $00,$00,$03,$8f
B1F997: DC.B $00,$00,$03,$8f
;BASEDR: DC.B 0,$0,$FC,$F8,$F4,$F0,$EC,$E8,$E4,$8E
B1F99A: DC.B $00,$F4,$F2,$EC,$EE,$EC,$E7,$E4,$E0,$8E
B1F99D: DC.B $01,$00,$00,$00,$0c,$8F
ONE:    DC.B $00,$00,$01,$8F
TWO:    DC.B $00,$00,$02,$8F
THREE:  DC.B $00,$00,$03,$8F
FOUR:   DC.B $00,$00,$04,$8F
FIVE:   DC.B $00,$00,$05,$8F
SIX:    DC.B $00,$00,$06,$8F
SEVEN:  DC.B $00,$00,$07,$8F
EIGHT:  DC.B $00,$00,$08,$8F
NINE:   DC.B $00,$00,$09,$8F
ELEVEN: DC.B $00,$00,$0B,$8F
TWELVE: DC.B $00,$00,$0C,$8F
ZERO:   DC.B $00,$00,$00,$8F
TEN:    DC.B $00,$00,$0A,$8F
THIRTT: DC.B $00,$00,$0D,$8F
FOURTT: DC.B $00,$00,$0E,$8F
FIFTT:  DC.B $00,$00,$0F,$8F
NONE:   DC.B $00,$00,$FF,$8F
NTWO:   DC.B $01,$00,$FE,$8F
NTHREE: DC.B $01,$00,$FD,$8F
NFOUR:  DC.B $01,$00,$FC,$8F
NFIVE:  DC.B $01,$00,$FB,$8F
NSIX:   DC.B $01,$00,$FA,$8F
NSEVEN: DC.B $01,$00,$F9,$8F
NEIGHT: DC.B $01,$00,$F8,$8F
NNINE:  DC.B $01,$00,$F7,$8F
NELEVEN:DC.B $01,$00,$F6,$8F
NTWELVE:DC.B $01,$00,$F5,$8F
NZERO:  DC.B $01,$00,$F4,$8F
NTEN:   DC.B $01,$00,$F3,$8F
NTHIRTT:DC.B $01,$00,$F2,$8F
NFOURTT:DC.B $01,$00,$F1,$8F
NFIFTT: DC.B $01,$00,$F0,$8F
UP:     DC.B $01 ,0,12,0,13,0,14,0,15,0,16,0,17,0,18,0,19,0,20,0,21,0,22
        DC.B 0,23,0,24,0,25,0,26,0,27,0,28,0,29,0,30,0,31,0,32,0,33,0,34
        DC.B 0,35,0,36,0,37,0,38,0,39,0,40,0,41,0,42,0,43,0,40,0,41,0,42
        DC.B 0,43,0,44,0,45,0,46,0,47,0,48,$8E

DOWN: DC.B $01,0,-12,0,-13,0,-14,0,-15,0,-16,0,-17,0,-18,0,-19,0,-20,0,-21,0,-22
      DC.B 0,-23,0,-24,0,-25,0,-26,0,-27,0,-28,0,-29,0,-30,0,-31,0,-32,0,-33,0,-34
      DC.B 0,-35,0,-36,0,-37,0,-38,0,-39,0,-40,0,-41,0,-42,0,-43,0,-44,0,-45
      DC.B 0,-46,0,-47,0,-48,$8E
DDOWN:DC.B $01,0,12,$00,12,$00,12,-1,11,-2,10,-3,9,-4,8,-5,7,-6,6,-7,5,-8,4,-9,3,-10,2,-11,1
      DC.B -12,0,-13,-1,-14,-2,-15,-3,-16,-4,-17,-5,-18,-6,-19,-7,-20,-8,-21,-9,-22,-10,-23,-11,-24,-12
      DC.B -25,-13,-26,-14,-27,-15,-28,-16,-29,-17,-30,-18,-31,-19,-32,-20,-33,-21,-34,-22,-35,-23
      DC.B -36,-24,-37,-25,-38,-26,$8E
DTOWN:DC.B 1,0,0,0,0,0,0,0,0,0,0
      DC.B 0,00,$00,00,$00,00,-1,11,-2,10,-3,9,-4,8,-5,7,-6,6,-7,5,-8,4,-9,3,-10,2,-11,1
      DC.B -12,0,-13,-1,-14,-2,-15,-3,-16,-4,-17,-5,-18,-6,-19,-7,-20,-8,-21,-9,-22,-10,-23,-11,-24,-12
      DC.B -25,-13,-26,-14,-27,-15,-28,-16,-29,-17,-30,-18,-31,-19,-32,-20,-33,-21,-34,-22,-35,-23
      DC.B -36,-24,-37,-25,-38,-26,$8E
DCOWN:DC.B 1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
      DC.B 0,00,$00,00,$00,00,-1,11,-2,10,-3,9,-4,8,-5,7,-6,6,-7,5,-8,4,-9,3,-10,2,-11,1
      DC.B -12,0,-13,-1,-14,-2,-15,-3,-16,-4,-17,-5,-18,-6,-19,-7,-20,-8,-21,-9,-22,-10,-23,-11,-24,-12
      DC.B -25,-13,-26,-14,-27,-15,-28,-16,-29,-17,-30,-18,-31,-19,-32,-20,-33,-21,-34,-22,-35,-23
      DC.B -36,-24,-37,-25,-38,-26,$8E
PHANT1: DC.B $01,0,0,0,0,0,0,0,0,0,0,0,0,12,0,13,0,14,0,15,0,16,0,17,0,18,0,19,0,20,0,21,0,22
        DC.B 0,23,0,24,0,25,0,26,0,27,0,28,0,29,0,30,0,31,0,32,0,33,0,34
        DC.B 0,35,0,36,0,37,0,38,0,39,0,40,0,41,0,42,0,43,0,40,0,41,0,42
        DC.B 0,43,0,44,0,45,0,46,0,47,0,48,$8E
PHANT2: DC.B 1,0,0,0,12,$8F
ZOIDS1: DC.B 0,0,0,$18,$18,$00,$8F
ZOIDS2: DC.B 1,0,0,0,0,0,0,0,0,0,0,0,0,0,0  ,0,0,0

      DC.B 0,00,$00,00,$00,00,-1,11,-2,10,-3,9,-4,8,-5,7,-6,6,-7,5,-8,4,-9,3,-10,2,-11,1
      DC.B -12,0,-13,-1,-14,-2,-15,-3,-16,-4,-17,-5,-18,-6,-19,-7,-20,-8,-21,-9,-22,-10,-23,-11,-24,-12
      DC.B -25,-13,-26,-14,-27,-15,-28,-16,-29,-17,-30,-18,-31,-19,-32,-20,-33,-21,-34,-22,-35,-23
      DC.B -36,-24,-37,-25,-38,-26,$8E
THING1: DC.B 0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22
        DC.B 23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42
        DC.B 43,44,45,46,47,48,49,50,51,52,53,54,55,56,57,58,59,60,61,62
        DC.B $8F
EVEN
startsyn:
VOICE1: DC.B 033,000,000,006,001,099,000,006,003,032,000,000,000,032,000,031
        DC.L B1F96A,B1F974
        DC.B 001,001,015,027,032,046,014,010
        DC.B 000,002,010,081,000,006,000,081,014,001,001,001,064,000,000,009
        DC.B 000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000
        DC.B 000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000
        DC.B 000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000
        DC.B 000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000

VOICE2: DC.B $33,000,000,006,000,187,000,006,003,096,000,000,000,208,000,008
        DC.L B1F96A,B1F974
        DC.B 001,001,002,003,004,027,014,000
        DC.B 000,002,010,034,000,002,010,033,014,001,001,000,064,000,000,018
        DC.B 000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000
        DC.B 000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000
        DC.B 000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000
        DC.B 000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000

VOICE3: DC.B 033,000,000,006,001,099,000,006,004,176,000,000,000,036,000,031
        DC.L B1F96A,B1F974
        DC.B 001,001,015,029,032,046,014,002
        DC.B 000,002,010,081,000,002,010,081,014,001,001,000,096,000,000,036
        DC.B 000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000
        DC.B 000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000
        DC.B 000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000
        DC.B 000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000

LBL:    DC.B 004,004,025,025,248,005,005,000,000,000,000,000,000,000,000,000
        DC.B 016,016
endsyn:
XP:DC.B 3,3,3,3
YP:DC.B 0,0
ROUT:
        ADDQ.B #1,YP
NEIN1:  TST.B SDST+6
        BEQ B1F42C
        MOVE.B LBL+2,LBL+3
        SUBQ.B #1,LBL+0
        BNE B1F3B0
        MOVE.L #VOICE1,A0
        BSR B1F604
        MOVE.L #VOICE2,A0
        BSR B1F604
        MOVE.L #VOICE3,A0
        BSR B1F604
        MOVE.B LBL+1,LBL+0
B1F3B0: MOVE.L #VOICE1,A0
        BSR B1F6F2
        MOVE.W D0,FLAGS
        MOVE.W D0,FREQ1
        MOVE.B D0,B1F85E
        MOVE.B FLAGS,B1F85E+$1
        MOVE.B D1,B1F85E+$8
        AND.W  #$F,D1
        MOVE.W  D1,VOL1
        MOVE.L #VOICE2,A0
        BSR B1F6F2
        MOVE.W D0,FREQ2
        MOVE.W D0,FLAGS
        MOVE.B D0,B1F85E+$2
        MOVE.B FLAGS,B1F85E+$3
        MOVE.B D1,B1F85E+$9
        AND.W  #$F,D1
        MOVE.W  D1,VOL2
        MOVE.L #VOICE3,A0
        BSR B1F6F2
        MOVE.W D0,FREQ3
        MOVE.W D0,FLAGS
        MOVE.B D0,B1F85E+$4
        MOVE.B FLAGS,B1F85E+$5
        MOVE.B D1,B1F85E+$A
        AND.W  #$F,D1
        MOVE.W  D1,VOL3
        MOVE.B LBL+3,B1F85E+$6
B1F42C: TST.B SDST+6
        BNE B1F44E
        MOVE.W #$A,D0
        MOVE.L #B1F85E,A0
B1F440: MOVE.B #0,(A0)+
        DBF D0,B1F440
        MOVE.B #$3F,B1F85E+$7
B1F44E: MOVE.B #$7,$FF8800
        MOVE.B $FF8800,D0
        ANDI.B #$C0,D0

        ANDI.B #$3F,B1F85E+$7
        OR.B D0,B1F85E+$7
        MOVE.B  B1F85E+6(PC),D1
        AND.L   #$FF,D1
    ;   BSR     PRINTR
        MOVE.L #B1F85E+$D,A0
        MOVE.W #$C,D0
B1F478: MOVE.B D0,$FF8800
        MOVE.B -(A0),$FF8802
        DBF D0,B1F478
B1F346: RTS
B1F4CA: DC.L FUNC0 ,FUNC1
        DC.L FUNC2 ,FUNC3
        DC.L FUNC4 ,FUNC5
        DC.L FUNC6 ,FUNC7
        DC.L FUNC8 ,FUNC9
        DC.L FUNC10,FUNC11
        DC.L FUNCAP,FUNC13
        DC.L FUNC14,FUNC15
        DC.L FUNC16,FUNC17
        DC.L FUNC18
FUNCAP:
        MOVE.B (A1)+,D0
        BSR KLINGEL
        BRA B1F612
FUNC14:
        MOVE.B #$1,$2E(A0)
        BRA B1F612
FUNC7:  MOVE.L $A(A0),D0
        MOVE.B #$19,LBL+2
        BCLR #$0,$60(A0)
        BCLR #$2,$60(A0)
        BCLR #$1,$60(A0)
        BCLR #$0,$40(A0)
        MOVE.L $6(A0),A2
        ADDA.L D0,A2
        ADDQ.L #$1,D0
        CMP.B #$80,(A2)
        BNE NONO9
        MOVE.B $1(A2),$3F(A0)
WWW:    ADD.L #$2,$A(A0)
        BRA FUNC7
NONO9:  CMP.B #$FE,(A2)
        BNE NONO91
        CLR.B SDST+6
        BRA WWW
NONO91: CMP.B #$FD,(A2)
        BNE NONO92
        MOVE.B $1(A2),LBL+17
        BRA WWW
NONO92: CMP.B #$FF,(A2)
        BNE B1F52A
        MOVE.L $6(A0),A2
        CMP.B #$80,(A2)
        BNE JA80C
        MOVE.L #$3,D0
        MOVE.B 1(A2),$3F(A0)
        ADD.L #2,A2
        BRA B1F52A
JA80C:  MOVE.L #$1,D0
B1F52A:
        MOVE.L D0,$A(A0)
        MOVEQ #0,D0
        MOVE.B (A2),D0
        ASL #2,D0
        MOVE.L TAB,A1
        MOVE.L $0(A1,D0.L),A1
        MOVE.L $A(A0),D0
        BRA B1F612

FUNC11: MOVE.B $2F(A0),D0
        MOVE.B D0,D1
        ANDI.B #$7,D0
        MOVE.B LBL+4,D2
        EOR.B D2,D0
        AND.B D1,D0
        EOR.B D2,D0
        MOVE.B D0,LBL+4
        MOVE.B #$1,$2D(A0)
        brA B1F612
FUNC15:
        MOVE.B $2F(A0),D0
        MOVE.B D0,D1
        ANDI.B #$7,D0
        MOVE.B LBL+4,D2
        EOR.B D2,D0
        AND.B D1,D0
        EOR.B D2,D0
        MOVE.B D0,LBL+4
        MOVE.B #$1,$2D(A0)
        BSET #$1,$36(A0)
        MOVE.B #$40,$37(A0)
        BRA FUNC11
FUNC10: MOVE.B $2F(A0),D0
        MOVE.B D0,D1
        ANDI.B #$38,D0
        MOVE.B LBL+4,D2
        EOR.B D2,D0
        AND.B D1,D0
        EOR.B D2,D0
        MOVE.B D0,LBL+4
        MOVE.B #$0,$2D(A0)
        BRA B1F612
FUNC12: MOVE.B $2F(A0),D0
        EORI.B #$FF,D0
        MOVE.B LBL+4,D2
        AND.B D2,D0
        AND.B D0,LBL+4
        MOVE.B #$1,$2D(A0)
        BRA B1F612
FUNC4:  MOVE.W #0,$E(A0)
        BSET #$2,(A0)
        CLR.B $6C(A0)
        MOVE.B (A1)+,$18(A0)
        MOVE.B (A1)+,$19(A0)
        BRA B1F612
FUNC18: MOVE.W #0,$E(A0)
        BSET #$2,(A0)
        MOVE.B #-1,$6C(A0)
        MOVE.B (A1)+,$18(A0)
        MOVE.B (A1)+,$19(A0)
        MOVE.B (A1)+,$6D(A0)
        BRA B1F612
FUNC9:  MOVE.B (A1)+,SDST+4
        BRA B1F612
FUNC8:  MOVE.B (A1)+,D0; $2A(A0)
        MOVE.B (A1),D0; $29(A0)
        MOVE.B (A1)+,D0;,$2B(A0)
        MOVE.B (A1),D0;      $30(A0)
        MOVE.B (A1)+,D0;  $32(A0)
        BRA B1F612
FUNC6:  BSET #$7,(A0)
FUNC5:  BSET #$3,(A0)
        MOVE.B (A1)+,$33(A0)
        BRA B1F612
FUNC1:  MOVE.B #0,$2C(A0)
        BRA B1F612
FUNC2:  MOVE.B #$40,$2C(A0)
        MOVE.B #$19,LBL+2
        CLR.B $6E(A0)
        BRA B1F612
FUNC3:  MOVE.B #$40,$2C(A0)
        MOVE.B #$19,LBL+2
        MOVE.B #1,$6E(A0)
        BRA B1F612
FUNC13: BSET #$1,(A0)
        BRA B1F612
FUNC16: BSET #$2,$36(A0)
        MOVE.B (A1)+,$39(A0)
        MOVE.B $39(A0),$38(A0)
        BRA B1F648
FUNC0:
        TST.B $2E(A0)
        BNE NOFUNC0
        MOVE.B #0,$1E(A0)
        BCLR #2,$36(A0)
NOFUNC0:BRA B1F648
B1F604: SUBQ.B #$1,$1B(A0)
        BNE B1F654
        MOVE.B #$2F,LBL+2
        MOVE.B #0,$2E(A0)
        MOVE.B #0,(A0)
        MOVE.L $2(A0),A1
B1F612: MOVE.W #0,D0
        MOVE.B (A1)+,D0
        BMI B1F672
        BCLR #2,$36(A0)
        MOVE.B D0,$1D(A0)
        MOVE.B LBL+2,$41(A0)
        TST.B $2D(A0)
        BEQ B1F62E
        MOVE.B D0,LBL+2
B1F62E:
        MOVE.B LBL+2,$41(A0)
        MOVE.B $2F(A0),D0
        MOVE.B D0,D1
        ANDI.B #$38,D0
        MOVE.B LBL+4,D2
        EOR.B D2,D0
        AND.B D1,D0
        EOR.B D2,D0
        MOVE.B D0,LBL+4
        MOVE.B #$0,$2D(A0)
        MOVE.B $41(A0),LBL+2

        MOVE.L $20(A0),A2
        TST.B $2E(A0)
        BNE BADRESS
        MOVE.L $24(A0),A2

        MOVE.L $5C(A0),$58(A0)
        MOVE.B $57(A0),$56(A0)
        BTST #$0,$60(A0)
        BEQ NORTA
        MOVE.L $46(A0),$42(A0)
        BSET #$0,$40(A0)
NORTA:
        BTST #2,$60(A0)
        BEQ NORTA2
        BSET #$1,$60(A0)
        MOVE.L $66(A0),$62(A0)
        MOVE.B $6B(A0),$6A(A0)
NORTA2:
        MOVE.L A2,D2
        MOVE.L A2,$20(A0)
BADRESS:MOVE.B (A2),$28(A0)
        MOVE.B (A2),$1E(A0)
        MOVE.B $1A(A0),$1F(A0)
        BSET #$5,(A0)
B1F648: MOVE.B $1C(A0),$1B(A0)
        MOVE.B $32(A0),$30(A0)
        TST.B $2E(A0)
        BNE BADR2
        MOVE.B #0,$31(A0)
BADR2:


        BTST #$0,$3E(A0)
        BEQ NEINA2
        MOVE.W #0,$E(A0)
        BSET #$2,(A0)
        MOVE.B #$48,$18(A0)
        MOVE.B #$01,$19(A0)
NEINA2: BTST #$1,$3E(A0)
        BEQ NEINB2
        BSET #$1,(A0)
        move.b #$10,$1d(a0)
NEINB2:
        BTST #$2,$3E(A0)
        BEQ NEINC2
        BSET #$0,$40(A0)
        MOVE.L #FSTTAB,$46(A0)
        MOVE.L $46(A0),$42(A0)
NEINC2:
        BTST #$3,$3E(A0)
        BEQ NEIND2
        BSET #$0,$40(A0)
        MOVE.L #SNDTAB,$46(A0)
        MOVE.L $46(A0),$42(A0)
NEIND2:
        BTST #$4,$3E(A0)
        BEQ NEINE2
        BSET #$0,$40(A0)
        MOVE.L #TRDTAB,$46(A0)
        MOVE.L $46(A0),$42(A0)

NEINE2:
BADR3:


        MOVE.B $34(A0),$35(A0)
        MOVE.B $39(A0),$38(A0)
        MOVE.L A1,$2(A0)
        MOVE.B #$30,$37(A0)
        TST.B $2E(A0)
        BNE BADR4
        MOVE.L $10(A0),$14(A0)
BADR4:
        RTS
B1F654: BTST #$3,(A0)
        BNE B1F65E
        RTS
B1F65E: MOVE.B $33(A0),D5
        BTST #$7,(A0)
        BEQ B1F66C
        ADD.B D5,$1D(A0)
        RTS
B1F66C: SUB.B D5,$1D(A0)
        RTS
B1F672:

        CMPI.B #$B8,D0
        BCS B1F6E0
        ADDI.B #$20,D0
        BCS B1F6BC
        ADDI.B #$10,D0
        BCS B1F6C6
        ADDI.B #$10,D0
        BCC B1F6AE
        BRA WAVE
KLINGEL:ANDI.L #$FF,D0
        BCLR #$1,$60(A0)
        CMP.B #$80,D0
        BHI SUPTAB
        BEQ SUPTAB
        LSL.W #$2,D0
        MOVE.L #B1F92E,A2
        ADDA.L D0,A2
        MOVE.L (A2),$14(A0)
        MOVE.L (A2),$10(A0)
        MOVE.L $10(A0),A2
        MOVE.B -1(a2),$34(A0)
        MOVE.B $34(A0),$35(A0)
        RTS
SUPTAB:
        CMP.B #$90,D0
        BHI NSUPTAB
        BEQ NSUPTAB
        BCLR #$1,$50(A0)
        AND.L #$F,D0
        LSL.B #$2,D0
        MOVE.L #TABS,A2
        ADD.L D0,A2
        MOVE.L (A2),$58(A0)
        MOVE.L (A2),$5C(A0)
        MOVE.L (A2),A2
        MOVE.B -1(A2),$56(A0)
        MOVE.B $56(A0),$57(A0)
        MOVEQ #0,D0
        BRA KLINGEL
NSUPTAB:
        CMP.B #$A0,D0
        BHI RSUPTAB
        BEQ RSUPTAB
        BSET #$1,$50(A0)
        AND.L #$F,D0
        LSL.B #$2,D0
        MOVE.L #NTABS,A2
        ADD.L D0,A2
        MOVE.L (A2),$58(A0)
        MOVE.L (A2),$5C(A0)
        MOVE.L (A2),A2
        MOVE.B -1(A2),$56(A0)
        MOVE.B $56(A0),$57(A0)
        MOVEQ #0,D0
        BRA KLINGEL
RSUPTAB:
        CMP.B #$B0,D0
        BHI MSUPTAB
        BEQ MSUPTAB
        AND.L #$F,D0
        LSL.B #$2,D0
        MOVE.L #RTAB,A2
        ADD.L D0,A2
        MOVE.L (A2),$46(A0)
        MOVE.L (A2),$42(A0)
        BCLR #$7,$3E(A0)
        BSET #$0,$60(A0)
        BSET #$0,$40(A0)
        MOVEQ #0,D0
        BRA KLINGEL
MSUPTAB:
        CMP.B #$C0,D0
        BHI DRUMTAB
        BEQ DRUMTAB
        AND.L #$0F,D0
        ASL.B #2,D0
        MOVE.L #MODULA,A2
        ADD.L D0,A2
        MOVE.L (A2),A2
        MOVE.B -1(A2),$6A(A0)
        MOVE.B -1(A2),$6B(A0)
        MOVE.L  A2,$62(A0)
        MOVE.L  A2,$66(A0)
        BSET #$1,$60(A0)
        BSET #$2,$60(A0)
        MOVEQ #0,D0
        BRA KLINGEL
DRUMTAB:AND.L #$07,D0
        ADD.L #$8,D0
        MOVE.L D0,-(SP)
;RAUSCHEN SETZEN
        LSL.B #$2,D0
        MOVE.L #RTAB,A2
        ADD.L D0,A2
        MOVE.L (A2),$46(A0)
        MOVE.L (A2),$42(A0)
;       BCLR #$7,$3E(A0)
        BSET #$0,$60(A0)
        BSET #$0,$40(A0)
;FREQ SETZEN
        MOVE.L (SP)+,D0
        BSET #$1,$50(A0)
        AND.L #$F,D0
        LSL.B #$2,D0
        MOVE.L #NTABS,A2
        ADD.L D0,A2
        MOVE.L (A2),$58(A0)
        MOVE.L (A2),$5C(A0)
        MOVE.L (A2),A2
        MOVE.B -1(A2),$56(A0)
        MOVE.B $56(A0),$57(A0)
        MOVEQ #0,D0
        BRA KLINGEL

B1F6AE: ADDI.B #$9,D0
        MOVE.B D0,LBL+1
        BRA B1F612
B1F6BC: ADDQ.B #$1,D0
        MOVE.B D0,$1C(A0)
        BRA B1F612
FUNC17:
        MOVE.B (A1)+,D0
        ADDQ.B #1,D0
        MOVE.B D0,$1C(A0)
        BRA B1F612


B1F6C6: ADD.W #$10,D0
WAVE:
        LSL.W #$2,D0
        BCLR #$0,$60(A0)
        BCLR #$1,$60(A0)
        BCLR #$2,$60(A0)
        CLR.B $61(A0)
        BCLR #$0,$40(A0)
        MOVE.L SDST,A2
        TST.B $6E(A0)
        BEQ WAVE2
        MOVE.L SDST2,A2
WAVE2:
        MOVE.B #$19,LBL+2
        MOVE.L $0(A2,D0.W),A2
        MOVE.L A2,$24(A0)
        MOVE.B -2(A2),$30(A0)
        MOVE.B -2(A2),$32(A0)
        MOVE.B -3(A2),$2B(A0)
        MOVE.B -6(A2),$3E(A0)
        MOVE.B -3(A2),$29(A0)
        MOVE.B -4(A2),$2A(A0)
        MOVE.B -1(A2),$1A(A0)
        MOVE.B -5(A2),D0
        BSR KLINGEL
        BTST #$0,$3E(A0)
        BEQ NEINA
        MOVE.W #0,$E(A0)
        BSET #$2,(A0)
        MOVE.B #$48,$18(A0)
        CLR.B $6C(A0)
        MOVE.B #$01,$19(A0)
NEINA:  BTST #$1,$3E(A0)
        BEQ NEINB
    ;   MOVE.B #$19,LBL+2
        BSET #$1,(A0)
        ADDQ.L #$1,A1
        MOVE.B #$10,$1D(A0)
        BRA B1F62E
NEINB:  BTST #$2,$3E(A0)
        BEQ NEINC
        BSET #$0,$40(A0)
        MOVE.L #FSTTAB,$46(A0)
        MOVE.L $46(A0),$42(A0)
NEINC:
        BTST #$3,$3E(A0)
        BEQ NEIND
        BSET #$0,$40(A0)
        MOVE.L #SNDTAB,$46(A0)
        MOVE.L $46(A0),$42(A0)
NEIND:
        BTST #$4,$3E(A0)
        BEQ NEINE
        BSET #$0,$40(A0)
        MOVE.L #TRDTAB,$46(A0)
        MOVE.L $46(A0),$42(A0)
NEINE:
        BRA B1F612
B1F6E0: ANDI.W #$7F,D0
        LSL.W #$2,D0
        MOVE.L #B1F4CA,A2
        MOVE.L $0(A2,D0.W),A2
        JMP (A2)
SDST:   DC.L BASIS+$20,$0
FLAGS:  DC.W 0
TAB:    DC.L BASIS+$400
TAB2:   DC.L BASIS+$2A0
SDST2:  DC.L BASIS+$20
B1F6F2:

NOIN:   BTST #$0,$50(A0)
        BEQ NOIN2
        SUBQ.B #1,$52(A0)
        BEQ NOIN2
        MOVE.B $53(A0),$52(A0)
        SUBQ.B #$1,$1D(A0)
NOIN2:



        BTST #$0,$40(A0)
        BEQ NOKKK
        ADDQ.L #2,$42(A0)
NEXTW:  MOVE.L $42(A0),A2
        CMP.B #$FF,(A2)
        BNE NEINKKL
        BCLR #$0,$40(A0)
        BRA NEXTS
NEINKKL:
        CMP.B #$1,(A2)
        BNE  NEINXX
        MOVE.B $2F(A0),D0
        MOVE.B D0,D1
        ANDI.B #$7,D0
        MOVE.B LBL+4,D2
        EOR.B D2,D0
        AND.B D1,D0
        EOR.B D2,D0
        MOVE.B D0,LBL+4
        MOVE.B #$1,$2D(A0)
        MOVE.B 1(A2),LBL+2
        BRA NEXTS
NEINXX:
        CMP.B #$2,(A2)
        BNE NEINXY
        MOVE.B $2F(A0),D0
        EORI.B #$FF,D0
        MOVE.B LBL+4,D2
        AND.B D2,D0
        AND.B D0,LBL+4
        MOVE.B #$1,$2D(A0)
        MOVE.B 1(A2),LBL+2
        BRA NEXTS
NEINXY:
        CMP.B #$3,(A2)
        BNE NEXTYY
        MOVE.B $2F(A0),D0
        MOVE.B D0,D1
        ANDI.B #$38,D0
        MOVE.B LBL+4,D2
        EOR.B D2,D0
        AND.B D1,D0
        EOR.B D2,D0
        MOVE.B D0,LBL+4
        MOVE.B #$0,$2D(A0)
        MOVE.B $41(A0),LBL+2
NEXTYY:
NEXTS:
NOKKK:
        MOVE.W #0,D7
        MOVE.B (A0),D7
        BTST #$5,D7
        BEQ B1F730
        SUBQ.B #$1,$1F(A0)
        BCC B1F726
        MOVE.B $1A(A0),$1F(A0)
        MOVE.L $20(A0),A2
        CMPI.B #$FF,$1(A2)
        BEQ B1F726
        ADDQ.L #$1,$20(A0)
        MOVE.B $1(A2),$28(A0)
B1F726: MOVE.B $28(A0),$1E(A0)
B1F730: MOVE.B $1D(A0),D0
        ADD.B SDST+4,D0
        SUBQ.B #$1,$35(A0)
        BCC B1F760
        MOVE.B $34(A0),$35(A0)

        MOVE.L $14(A0),A1
        MOVE.B (A1),D1

        CMPI.B #$8F,D1
        BNE B1F74E
        MOVE.L $10(A0),A1
        MOVE.B (A1),D1
B1F74E: CMP.B #$8E,D1
        BNE B1F750
        LEA -1(A1),A1
        MOVE.B (A1),D1
B1F750: ADDQ.L #$1,A1
        MOVE.L A1,$14(A0)
        ADD.B D1,D0
B1F760: ADD.B $3F(A0),D0
        JSR HUBBARD
        TST.B D0
        BPL NOERROR
        MOVEQ #$60,D0
NOERROR:MOVE.L #B1F85E+$10,A1
        ADD.B D0,D0
        MOVE.B D0,D1
        ANDI.L #$FF,D1
        ADDA.L D1,A1
        MOVE.W (A1),D0
        MOVE.B $2C(A0),D6
        BTST #$6,D6
        BEQ B1F7E6
        CMP.B #$1,$31(A0)
        BEQ JA
        SUBQ.B #1,$30(A0)
        BCC B1F7E6
JA:     MOVE.B #$1,$31(A0)
        MOVE.B D1,D5
        MOVE.B $29(A0),D4
        LSL.B #$1,D4
        MOVE.B $2B(A0),D1
        BTST #$7,D6
        BEQ B1F792
        BTST #$0,D7
        BNE B1F7C6
B1F792: BTST #$5,D6
        BNE B1F7B0
        SUB.B $2A(A0),D1
        BCC B1F7C2
        BSET #$5,$2C(A0)
        MOVE.W #$0,D1
        BRA B1F7C2
B1F7B0: ADD.B $2A(A0),D1
        CMP.B D4,D1
        BCS B1F7C2
        BCLR #$5,$2C(A0)
        MOVE.B D4,D1
B1F7C2: MOVE.B D1,$2B(A0)
B1F7C6: LSR.B #$1,D4
        SUB.B D4,D1
        BCC B1F7D2
        SUBI.W #$100,D1
B1F7D2: ADDI.B #$A0,D5
        BCS B1F7E4
B1F7DA: LSL.W #$1,D1
        ADDI.B #$18,D5
        BCC B1F7DA
B1F7E4: ADD.W D1,D0

B1F7E6: EORI.B #$1,D7
        MOVE.B D7,(A0)
        BTST #$2,D7
        BEQ B1F81E

        MOVE.B $19(A0),D4
        SUBQ.B #$1,D4
        BNE B1F81A
        MOVE.W #0,D6
        MOVE.B $18(A0),D6
        MOVE.B D6,D3            ;MERKE ES DIR!
        BPL B1F80C
        ADDI.W #$FF00,D6
B1F80C: ADD.W $E(A0),D6
        MOVE.W D6,$E(A0)

Z:
        TST.B $6C(A0)
        BPL DOZIEH
        MOVE.B $6D(A0),D5
        MOVE.B D5,D1
        ADD.B $3F(A0),D5
        ADD.B SDST+4,D5
        ADD.B D5,D5
        AND.L #$FF,D5
        MOVE.L #B1F85E+$10,A1
        ADD.L D5,A1
        MOVE.W (A1),D5
        MOVE.W D0,D2
        ADD.W D6,D2
        TST.B D3
        BPL NACHU
        CMP.W D5,D2
        BCC DOZIEH
        CLR.W $E(A0)
        MOVE.W D5,D0
        MOVE.B D1,$1D(A0)
        BCLR #$2,(A0)
        BRA B1F81E
NACHU:  CMP.W D5,D2
        BCS DOZIEH
        CLR.W $E(A0)
        MOVE.W D5,D0
        MOVE.B D1,$1D(A0)
        BCLR #$2,(A0)
        BRA B1F81E
DOZIEH: ADD.W D6,D0
        BRA B1F81E
B1F81A: MOVE.B D4,$19(A0)


B1F81E:
        EORI.B #$FF,D7
        MOVE.B LBL+4,D3
        ANDI.B #$3,D7
        BNE B1F844
        MOVE.B LBL+2,D3
        EORI.B #$8,D3

        MOVE.B D3,LBL+3
        MOVE.B #$7,D3
B1F844:
        BTST #$1,$36(A0)
        BEQ NEIN3
        ADDQ.B #$2,$37(A0)
        CMP.B #$40,$37(a0)
        BMI PLUS
        BCLR #$1,$36(A0)
PLUS:   MOVE.B $37(A0),LBL+2
NEIN3:  MOVE.B B1F85E+$7,D2
        EOR.B D2,D3
        AND.B $2F(A0),D3
        EOR.B D2,D3
        MOVE.B D3,B1F85E+$7
        BTST #$2,$36(A0)
        BEQ NEIN4
        SUBQ.B #$1,$38(A0)
        BCC NEIN4
        MOVE.B $39(A0),$38(A0)
        MOVE.B $1E(A0),D3
        CMP.B #$0,D3
        BHI NEIN4_1
        BCLR #$2,$36(A0)
        BRA NEIN4
NEIN4_1:
        SUBQ.B #$1,$1E(A0)
NEIN4:

        MOVE.B $1E(A0),D1
        ADD.B $61(A0),D1
        BPL EYDNE
        CLR.B D1
EYDNE:  CMP.B #$0F,D1
        BCC.S EXDNE
        CMP.B #$1F,D1
        BCS.S EXDNE
        MOVE.B #$F,D1
EXDNE:
;       BSR PRINT
;       BSR PRINTV
        RTS

CLEAR:  MOVE.B #0,SDST+6
        MOVE.L D0,D6
        LSL.W #2,D0
        MOVE.L BASIS+$18,A3
        ADD.L D0,A3
        MOVE.L (A3),A3
        MOVE.L #VOICE1,A1
        MOVE.L A3,A0
        MOVE.W #$2,D7
LOOP:   MOVE.B #$1,$1B(A1)
        MOVE.B #0,(A1)
        MOVE.B #0,$2C(A1)
        CLR.B $6E(A1)
        CLR.B $3F(A1)
        MOVE.L (A0)+,A2
        MOVE.L A2,$6(A1)
        MOVE.L #$1,$A(A1)
        MOVEQ #0,D0
        MOVE.B (A2),D0
        CMP.B #$80,D0
        BNE NO80C
        MOVE.B 1(A2),$3F(A1)
        MOVE.L #$3,$A(A1)
        MOVE.B 2(A2),D0
NO80C:  ASL #2,D0
        MOVE.L BASIS+$14,A3
        MOVE.L $0(A3,D0.L),A3
        MOVE.L A3,$2(A1)
        MOVE.B #3,$53(A1)
        ADDA.L #$70,A1
        DBF D7,LOOP
        MOVE.B #$1,LBL+0
        MOVE.B #$1,SDST+6
        MOVE.B #$0,SDST+4
        MOVE.L BASIS+$10,SDST
        MOVE.L BASIS+$1C,SDST2
        MOVE.B #$2,$484
        MOVE.L #BASIS+$3F0,A0
        ADD.L D6,A0
        move.b (A0),LBL+1
        MOVE.B #$F4,SDST+4
        CLR.B YP
        RTS

HUBBARD:MOVE.B YP,D3
        BTST #$6,$3E(A0)
        BEQ NOKLI
        AND.B #$2,D3
        BEQ NOKLI
        ADD.B #$C,D0
NOKLI:
        BTST #$1,$50(A0)
        BNE NOW
        BTST #$7,$3E(A0)
        BEQ NOW
        SUBQ.B #$1,$56(A0)
        CMP.B #$0,$56(A0)
        BNE NOW
        MOVE.B $57(A0),$56(A0)
        MOVE.L $58(A0),A2
        CMP.B #$FF,1(A2)
        BEQ NOW
        ADD.B (A2)+,D0
        MOVE.L A2,$58(A0)

NOW:
        MOVE.L $58(A0),A2
        BTST #$1,$50(A0)
        BEQ READY
        BTST #$7,$3E(A0)
        BEQ READY
        SUBQ.B #$1,$56(A0)
        CMP.B #$0,$56(A0)
        BNE NOW2
        MOVE.B $57(A0),$56(A0)
        CMP.B #$FF,1(A2)
        BEQ NOW2
        MOVE.B (A2)+,D0
        BRA WAYDER

NOW2:   MOVE.B (A2),D0
WAYDER: MOVE.L A2,$58(A0)
READY:
        BTST #$5,$3E(A0)
        BEQ NOUP
        MOVE.B $1D(A0),D4
        CMP.B #$1,D4
        BEQ NOUP
        SUB.B #$1,$1D(A0)
        SUB.B #$1,D0
NOUP:
        BTST #$1,$60(A0)
        BEQ NOMOD
        SUBQ.B #1,$6A(A0)
        BNE NOMOD
        MOVE.B $6B(A0),$6A(A0)
GETNEW: MOVE.L $62(A0),A2
        CMP.B #$FE,(A2)
        BNE NOREP
        MOVE.L $66(A0),$62(A0)
        BRA.S GETNEW
NOREP:
        CMP.B #$FF,(A2)
        BNE NOEND
        BCLR #$1,$60(A0)
        BRA NOMOD
NOEND:
        MOVE.B (A2)+,D6
        CMP.B #$80,D6
        BEQ NOVIS
        MOVE.B D6,$2A(A0)
NOVIS:
        MOVE.B (A2)+,D6
        CMP.B #$80,D6
        BEQ NOVIST
        MOVE.B D6,$29(A0)
        MOVE.B D6,$2B(A0)
NOVIST: MOVE.B (A2)+,D6
        MOVE.B D6,$61(A0)
NOVOMO:
        MOVE.B (A2)+,D6
        ADD.B D6,D0
NOFRMO:
        MOVE.L A2,$62(A0)
NOMOD:  RTS

GRAB:
        LEA VOICE1,A0
        LEA VOICE2,A1
        LEA VOICE3,A2
        MOVE.L $6(A0),D0
        ADD.L $A(A0),D0
        MOVE.L D0,$F0000
        MOVE.L $6(A1),D0
        ADD.L $A(A1),D0
        MOVE.L D0,$F0004
        MOVE.L $6(A2),D0
        ADD.L $A(A2),D0
        MOVE.L D0,$F0008
        RTS

T:
        LEA VOICE2,A0
        MOVE.W  #$30,D0

PRINT:
        ADDQ.L  #1,D0
        MOVEM.L D0-D7/A0-A6,-(SP)
        CMP.L   #VOICE1,A0
        BEQ     P50
        CMP.L   #VOICE2,A0
        BEQ     P100
        MOVE.L  #90,D1
        BRA     PRINT_T
P50:    MOVEQ   #50,D1
        BRA     PRINT_T
P100:   MOVEQ   #70,D1
PRINT_T:
        LSR.L   #2,D0
        NOT.L   D0
        AND.L   #511,D0
        MOVE.L  D1,D2
        ASL.W   #2,D2
        ADD.W   D1,D2
        ASL.W   #5,D2
        ADD.L   $44E,D2
        MOVE.L  #7 ,D1
FUELL:
        MOVE.L  D0,D4
        AND.L   #$F,D4
        ADD.L   D4,D4
        MOVE.L  D0,D3
        LSR.L   #4,D3
        MOVE.L  D2,A0
        MOVEQ   #34,D5
        SUB.L  D4,D5
FILLP:
        MOVE.L  #%11111111111111101111111111111110,(A0)+
        DBF     D3,FILLP
        MOVE.W  UEB(PC,D4.W),(A0)+
        MOVE.W  UEB(PC,D4.W),(A0)+
FILLP2:
        CLR.L   (A0)+
        DBF     D5,FILLP2
        ADD.L   #$A0,D2
        DBF     D1,FUELL
        MOVEM.L (SP)+,D0-D7/A0-A6
        SUBQ.L  #1,D0
        RTS

UEB:
        DC.W    %0000000000000000
        DC.W    %1000000000000000
        DC.W    %1100000000000000
        DC.W    %1110000000000000
        DC.W    %1111000000000000
        DC.W    %1111100000000000
        DC.W    %1111110000000000
        DC.W    %1111111000000000
        DC.W    %1111111100000000
        DC.W    %1111111110000000
        DC.W    %1111111111000000
        DC.W    %1111111111100000
        DC.W    %1111111111110000
        DC.W    %1111111111111000
        DC.W    %1111111111111100
        DC.W    %1111111111111110
        DC.W    %1111111111111110

PRINTV:
        ADDQ.L  #1,D1
        MOVEM.L D0-D7/A0-A6,-(SP)
        MOVE.L  D1,D0
        CMP.L   #VOICE1,A0
        BEQ     P501
        CMP.L   #VOICE2,A0
        BEQ     P101
        MOVE.L  #100,D1
        BRA     PRINT_V
P501:   MOVEQ   #60,D1
        BRA     PRINT_V
P101:   MOVEQ   #80,D1
PRINT_V:
        AND.L   #$1F,D0
        MOVE.L  D1,D2
        ASL.W   #2,D2
        ADD.W   D1,D2
        ASL.W   #5,D2
        ADD.L   $44E,D2
        MOVE.L  #7 ,D1
        MOVE.L  D0,D7
FUELL2:
        MOVE.L  D7,D0
        MOVEQ   #20,D5
        SUB.L  D0,D5
        MOVE.L  D2,A0
FILLG2:
        MOVE.L  #%11111111111111101111111111111110,(A0)+
        DBF     D0,FILLG2
CLPP2:
        CLR.L   (A0)+
        DBF     D5,CLPP2
        ADD.L   #$A0,D2
        DBF     D1,FUELL2
        MOVEM.L (SP)+,D0-D7/A0-A6
        SUBQ.L  #1,D1
        RTS

PRINTR:
        ADDQ.L  #1,D1
        MOVEM.L D0-D7/A0-A6,-(SP)
        MOVE.L  D1,D0
        MOVE.L  #120,D1

        AND.L   #$1F,D0
        MOVE.L  D1,D2
        ASL.W   #2,D2
        ADD.W   D1,D2
        ASL.W   #5,D2
        ADD.L   $44E,D2
        MOVE.L  #7 ,D1
        MOVE.L  D0,D7
FUELL3:
        MOVE.L  D7,D0
        MOVEQ   #35,D5
        SUB.L  D0,D5
        MOVE.L  D2,A0
FILLG3:
        MOVE.L  #%11111111111111101111111111111110,(A0)+
        DBF     D0,FILLG3
CLPP3:
        CLR.L   (A0)+
        DBF     D5,CLPP3
        ADD.L   #$A0,D2
        DBF     D1,FUELL3
        MOVEM.L (SP)+,D0-D7/A0-A6
        SUBQ.L  #1,D1
        RTS
VOL1:   DC.W 0
VOL2:   DC.W 0
VOL3:   DC.W 0
FREQ1:  DC.W 0
FREQ2:  DC.W 0
FREQ3:  DC.W 0

 

chars8:
                DC.W $0018,$6666,$10c4,$3e0c,$1c70,$00,$00,$0006
                DC.W $1c08,$7c3e,$463e,$1e7e,$1e7e,$1818,$0e00,$70fe
                DC.W $001e,$f01e,$f01e,$1e1e,$0018,$66ff,$7ccc,$6618
                DC.W $3018,$6c30,$00,$000c,$3618,$0606,$c660,$3086
                DC.W $36e6,$1818,$1800,$1806,$3c36,$d830,$d830,$3030
                DC.W $0018,$6666,$6018,$6630,$600c,$3830,$00,$0018
                DC.W $6638,$0606,$c6c0,$600c,$66c6,$00,$30fe,$0c06
                DC.W $6666,$cc60,$cc60,$6060,$0008,$0066,$3830,$3c60
                DC.W $600c,$fefc,$00fe,$0030,$c618,$3c1c,$fefc,$fe18
                DC.W $fefe,$00,$6000,$067c,$6ec6,$fec0,$c6f8,$f8c0
                DC.W $00,$0066,$0c60,$7800,$600c,$3830,$0800,$0060
                DC.W $c618,$6006,$0606,$c630,$c606,$1808,$30fe,$0c60
                DC.W $6ec6,$c6c0,$c6c0,$c0ce,$0018,$00ff,$7ccc,$cc00
                DC.W $3018,$6c30,$1800,$18c0,$c618,$c0c6,$06c6,$c630
                DC.W $c606,$1818,$1800,$1800,$60fe,$c6c0,$c6c0,$c0c6
                DC.W $0018,$0066,$108c,$fe00,$1c70,$00,$3000,$1880
                DC.W $7c18,$fefe,$027c,$fe30,$fe02,$0030,$0e00,$7060
                DC.W $3ec6,$fefe,$fefe,$c0fe,$4608,$0246,$4046,$461e
                DC.W $781e,$781e,$7e46,$4646,$4646,$7e78,$003c,$3020
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $c618,$06cc,$c0c6,$c636,$cc36,$cc30,$18c6,$c6c6
                DC.W $c6c6,$0c60,$000c,$7860,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$c618,$06d8,$c0ee,$e666
                DC.W $c666,$c660,$18c6,$c6c6,$6cc6,$1860,$000c,$fcfe
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $fe18,$06f0,$c0fe,$f6c6,$c6c6,$c6c0,$18c6,$c6d6
                DC.W $386c,$3060,$000c,$30fe,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$c618,$46d8,$c0d6,$dec6
                DC.W $fed6,$fefe,$18c6,$ccd6,$6c38,$6060,$000c,$3060
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $c618,$c6cc,$c0c6,$cec6,$c0dc,$cc06,$18c6,$d8dc
                DC.W $c618,$c060,$000c,$3020,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$c618,$fec6,$fec6,$c6fe
                DC.W $c0fa,$c6fe,$10fe,$f0f8,$c618,$fe78,$003c,$3000
                DC.W $00,$00,$00,$00,$00,$00,$00,$00

smiliezunge1:
         DC.W   $EA57,$F3CF,$FC3F,$0000,$E817,$CFF3,$F00F,$0000
         DC.W   $A005,$BFFD,$C003,$0000,$4424,$FFFD,$8E73,$0000
         DC.W   $0A51,$7BDC,$8A53,$0420,$8005,$FFFC,$100B,$0000
         DC.W   $9999,$FFF8,$118F,$0000,$1429,$77E8,$981F,$0000
         DC.W   $4A52,$EBD1,$9C3F,$0000,$B7E7,$B7E1,$CFFF,$0000
         DC.W   $DA0F,$DA03,$E5FF,$0000,$E877,$F00F,$FFFF,$0000
smiliezunge2:
         DC.W   $EA57,$F3CF,$FC3F,$0000,$E817,$CFF3,$F00F,$0000
         DC.W   $A005,$BFFD,$C003,$0000,$4424,$FFFD,$8E73,$0000
         DC.W   $0A51,$7BDC,$8A53,$0420,$8005,$FFFC,$100B,$0000
         DC.W   $9999,$FFF8,$118F,$0000,$1C39,$7FF8,$981F,$0000
         DC.W   $4FF2,$EFF1,$9FFF,$0000,$B7E7,$B7E1,$CFFF,$0000
         DC.W   $DA0F,$DA03,$E5FF,$0000,$E877,$F00F,$FFFF,$0000
smiliezunge3:
         DC.W   $EA57,$F3CF,$FC3F,$0000,$E817,$CFF3,$F00F,$0000
         DC.W   $A005,$BFFD,$C003,$0000,$4424,$FFFD,$8E73,$0000
         DC.W   $0A51,$7BDC,$8A53,$0420,$8005,$FFFC,$100B,$0000
         DC.W   $9999,$FFF8,$118F,$0000,$1C39,$7FF8,$981F,$0000
         DC.W   $4FF2,$EFF1,$9FFF,$0000,$B667,$B661,$CE7F,$0180
         DC.W   $DA0F,$DA03,$E5FF,$0000,$E877,$F00F,$FFFF,$0000
smiliezunge4:
         DC.W   $EA57,$F3CF,$FC3F,$0000,$E817,$CFF3,$F00F,$0000
         DC.W   $A005,$BFFD,$C003,$0000,$4424,$FFFD,$8E73,$0000
         DC.W   $0A51,$7BDC,$8A53,$0420,$8005,$FFFC,$100B,$0000
         DC.W   $9999,$FFF8,$118F,$0000,$1C39,$7FF8,$981F,$0000
         DC.W   $4FF2,$EFF1,$9FFF,$0000,$B5A7,$B421,$CC3F,$03C0
         DC.W   $DA0F,$DA03,$E47F,$0180,$E877,$F00F,$FFFF,$0000
smiliezunge5:
         DC.W   $EA57,$F3CF,$FC3F,$0000,$E817,$CFF3,$F00F,$0000
         DC.W   $A005,$BFFD,$C003,$0000,$4424,$FFFD,$8E73,$0000
         DC.W   $0A51,$7BDC,$8A53,$0420,$8005,$FFFC,$100B,$0000
         DC.W   $9999,$FFF8,$118F,$0000,$1C39,$7FF8,$981F,$0000
         DC.W   $4FF2,$EFF1,$9FFF,$0000,$B667,$B5A1,$CC3F,$03C0
         DC.W   $D98F,$D803,$E43F,$03C0,$E877,$F00F,$FE7F,$0180


smilieoh1:
        dc.w  $0A50,$13C8,$1C38,$0000,$2814,$0FF0,$300C,$0000
        dc.w  $2004,$3FFC,$4002,$0000,$4A54,$FFFD,$8663,$0000
        dc.w  $0241,$7BDC,$8A53,$0420,$8005,$FFFC,$0003,$0000
        dc.w  $8185,$FFFC,$0183,$0000,$0009,$7FF8,$8007,$0000
        dc.w  $4242,$EBD1,$9C3F,$0000,$37E6,$37E0,$4FFE,$0000
        dc.w  $1A0C,$1A00,$25FC,$0000,$0870,$1008,$1FF8,$0000
        dc.w  $0A50,$13C8,$1C38,$0000,$2814,$0FF0,$300C,$0000
        dc.w  $2004,$3FFC,$4002,$0000,$4A54,$FFFD,$8663,$0000
        dc.w  $0421,$7DBC,$8C33,$0240,$8005,$FFFC,$0003,$0000
        dc.w  $8185,$FFFC,$0183,$0000,$0009,$7FF8,$8007,$0000
        dc.w  $4012,$FFF1,$800F,$0000,$33C6,$37E0,$4FFE,$0000
        dc.w  $1A0C,$1A00,$25FC,$0000,$0870,$1008,$1FF8,$0000
        dc.w  $0A50,$13C8,$1C38,$0000,$2814,$0FF0,$300C,$0000
        dc.w  $2004,$3FFC,$4002,$0000,$4A54,$FFFD,$8663,$0000
        dc.w  $0421,$7DBC,$8C33,$0240,$8005,$FFFC,$0003,$0000
        dc.w  $8181,$FFF8,$0187,$0000,$0009,$7FF8,$8007,$0000
        dc.w  $45B2,$FFF1,$83CF,$0000,$32C6,$3FE0,$443E,$0000
        dc.w  $1C0C,$1C00,$23FC,$0000,$0870,$1008,$1FF8,$0000
        dc.w  $0A50,$13C8,$1C38,$0000,$2814,$0FF0,$300C,$0000
        dc.w  $2004,$3FFC,$4002,$0000,$4814,$FFFD,$8663,$0000
        dc.w  $0421,$7DBC,$8C33,$0240,$8005,$FFFC,$0003,$0000
        dc.w  $8181,$FFF8,$0187,$0000,$0009,$7FF8,$8007,$0000
        dc.w  $45B2,$FFF1,$83CF,$0000,$33C6,$3FE0,$47FE,$0000
        dc.w  $1C0C,$1C00,$23FC,$0000,$0870,$1008,$1FF8,$0000
        dc.w  $0A50,$13C8,$1C38,$0000,$2814,$0FF0,$300C,$0000
        dc.w  $2004,$3FFC,$4002,$0000,$4814,$FBDD,$8663,$0000
        dc.w  $0421,$7DBC,$8C33,$0240,$8005,$FFFC,$0003,$0000
        dc.w  $8181,$FFF8,$0187,$0000,$0009,$7FF8,$8007,$0000
        dc.w  $45B2,$FFF1,$83CF,$0000,$3BC6,$3FE0,$47FE,$0000
        dc.w  $1D8C,$1FC0,$23FC,$0000,$0870,$1008,$1FF8,$0000
        dc.w  $0A50,$13C8,$1C38,$0000,$2814,$0FF0,$300C,$0000
        dc.w  $2004,$3FFC,$4002,$0000,$4814,$FBDD,$8663,$0000
        dc.w  $0241,$75AC,$8C33,$0240,$8005,$FFFC,$0003,$0000
        dc.w  $8181,$FFF8,$0187,$0000,$0249,$7E78,$8187,$0000
        dc.w  $4BD2,$FFF1,$87EF,$0000,$37E6,$3FF0,$4FFE,$0000
        dc.w  $1BCC,$1FE0,$27FC,$0000,$09F0,$1008,$1FF8,$0000
        dc.w  $0000

smilieoh2=smilieoh1+96
smilieoh3=smilieoh2+96
smilieoh4=smilieoh3+96
smilieoh5=smilieoh4+96
smilieoh6=smilieoh5+96



intropalette:   dc.w    $0000,$0577,$0377,$0067,$0047,$0027,$0007,$0004
                dc.w    $0500,$0760,$0750,$0740,$0730,$0720,$0710,$0600

hblpaletten:    dc.w    $000,$700,$600,$500,$400,$300,$200,$100
                dc.w    $500,$760,$740,$740,$730,$720,$710,$600
                
                dc.w    $000,$770,$660,$550,$440,$330,$220,$110
                dc.w    $500,$760,$740,$740,$730,$720,$710,$600
                
                dc.w    $000,$070,$060,$050,$040,$030,$020,$010
                dc.w    $500,$760,$740,$740,$730,$720,$710,$600
                
                dc.w    $000,$077,$066,$055,$044,$033,$022,$011
                dc.w    $500,$760,$740,$740,$730,$720,$710,$600
                
                dc.w    $000,$007,$006,$005,$004,$003,$002,$001
                dc.w    $500,$760,$740,$740,$730,$720,$710,$600

                dc.w    $000,$007,$006,$005,$004,$003,$002,$001;
                dc.w    $500,$760,$740,$740,$730,$720,$710,$600

                
                dc.w    $000,$707,$606,$505,$404,$303,$202,$101
                dc.w    $500,$760,$740,$740,$730,$720,$710,$600

                dc.w    $000,$765,$654,$543,$432,$321,$210,$100
                dc.w    $500,$760,$740,$740,$730,$720,$710,$600

                dc.w    $000,$567,$456,$345,$234,$123,$012,$001
                dc.w    $500,$760,$740,$740,$730,$720,$710,$600

                dc.w    $000,$675,$564,$453,$342,$231,$120,$010
                dc.w    $500,$760,$740,$740,$730,$720,$710,$600
                
                dc.w    $000,$777,$666,$555,$444,$333,$222,$111
                dc.w    $500,$760,$740,$740,$730,$720,$710,$600

                dc.w    $000,$777,$777,$777,$777,$777,$777,$777
                dc.w    $500,$777,$777,$777,$777,$777,$777,$777
                
                dc.w    $000,$777,$777,$777,$777,$777,$777,$777
                dc.w    $500,$777,$777,$777,$777,$777,$777,$777
                
hblpointer:     dc.l    hblpaletten

werte:          ; Offsets der Kugeln
                dc.w    2568,10248,16,5136,10256,24,5144,10264
                dc.w    32,7712,2608,5168,7728,56,10296,64
                dc.w    10304,2632,5192,7752,88,2648,5208,7768
                dc.w    10328,5216,2664,7784,112,10352,2688,5248
                dc.w    7808,136,10376,144,10384,2712,5272,7832
                dc.w    15376,17936,20496,23056,25616,15384,20504,25624
                dc.w    15392,20512,25632,17960,23080,17984,20544,23104
                dc.w    25664,15432,20552,15440,20560,18008,20568,23128
                dc.w    25688,15472,18032,20592,23152,25712,18040,20608
                dc.w    15496,18056,20616,23176,25736

kucheln:
                dc.w $0100,$0100,$0100,$0000,$0000,$0000,$0000,$0000
                dc.w $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
                dc.w $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
                dc.w $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
                dc.w $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
                dc.w $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
                dc.w $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
                dc.w $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
                dc.w $0000,$0100,$0100,$0000,$0000,$0000,$0000,$0000
                dc.w $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
                dc.w $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
                dc.w $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
                dc.w $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
                dc.w $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
                dc.w $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
                dc.w $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
                dc.w $0100,$0000,$0100,$0000,$0000,$0000,$0000,$0000
                dc.w $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
                dc.w $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
                dc.w $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
                dc.w $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
                dc.w $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
  dc.w $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
  dc.w $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
  dc.w $0180,$0100,$0180,$0000,$0080,$0180,$0180,$0000
  dc.w $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
  dc.w $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
  dc.w $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
  dc.w $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
  dc.w $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
  dc.w $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
  dc.w $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
  dc.w $0000,$0100,$0100,$0000,$0300,$0280,$0380,$0000
  dc.w $0100,$0100,$0100,$0000,$0000,$0000,$0000,$0000
  dc.w $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
  dc.w $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
  dc.w $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
  dc.w $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
  dc.w $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
  dc.w $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
  dc.w $0280,$0380,$0380,$0000,$0200,$0080,$0380,$0000
  dc.w $0380,$0280,$0380,$0000,$0000,$0000,$0000,$0000
  dc.w $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
  dc.w $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
  dc.w $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
  dc.w $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
  dc.w $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
  dc.w $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
  dc.w $0180,$0180,$0180,$0000,$0240,$0340,$03C0,$0000
  dc.w $03C0,$02C0,$03C0,$0000,$0180,$0180,$0180,$0000
  dc.w $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
  dc.w $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
  dc.w $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
  dc.w $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
  dc.w $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
  dc.w $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
  dc.w $0100,$0100,$0100,$0000,$0300,$0200,$0380,$0000
  dc.w $06C0,$0540,$07C0,$0000,$0380,$0280,$0380,$0000
  dc.w $0100,$0100,$0100,$0000,$0000,$0000,$0000,$0000
  dc.w $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
  dc.w $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
  dc.w $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
  dc.w $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
  dc.w $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
  dc.w $0180,$0180,$0180,$0000,$0340,$0240,$03C0,$0000
  dc.w $06E0,$0520,$07E0,$0000,$0720,$04E0,$07E0,$0000
  dc.w $03C0,$0240,$03C0,$0000,$0180,$0180,$0180,$0000
  dc.w $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
  dc.w $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
  dc.w $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
  dc.w $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
  dc.w $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
  dc.w $0380,$0380,$0380,$0000,$0540,$06C0,$07C0,$0000
  dc.w $09A0,$0F60,$0EE0,$0000,$0D20,$0A60,$0FE0,$0000
  dc.w $0A20,$0DE0,$0FE0,$0000,$05C0,$0640,$07C0,$0000
  dc.w $0380,$0380,$0380,$0000,$0000,$0000,$0000,$0000
  dc.w $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
  dc.w $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
  dc.w $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
  dc.w $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
  dc.w $0080,$0180,$0180,$0000,$05A0,$0660,$07E0,$0000
  dc.w $01C0,$06A0,$0760,$0000,$0ED0,$0930,$0FF0,$0000
  dc.w $0990,$0C30,$0FF0,$0000,$0280,$0460,$07E0,$0000
  dc.w $0520,$06E0,$07E0,$0000,$0180,$0180,$0180,$0000
  dc.w $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
  dc.w $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
  dc.w $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
  dc.w $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
  dc.w $0280,$0380,$0380,$0000,$04C0,$0640,$07C0,$0000
  dc.w $0AE0,$0CA0,$0F60,$0000,$1110,$1E30,$1FF0,$0000
  dc.w $1CD0,$1330,$1FF0,$0000,$1390,$1830,$1FF0,$0000
  dc.w $0CA0,$0860,$0FE0,$0000,$0740,$04C0,$07C0,$0000
  dc.w $0380,$0380,$0380,$0000,$0000,$0000,$0000,$0000
  dc.w $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
  dc.w $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
  dc.w $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
  dc.w $0240,$03C0,$03C0,$0000,$0560,$0620,$07E0,$0000
  dc.w $0A70,$0C50,$0FB0,$0000,$1188,$1E18,$1FF8,$0000
  dc.w $08A0,$1758,$1FF8,$0000,$1C68,$1398,$1FF8,$0000
  dc.w $13C8,$1818,$1FF8,$0000,$0C50,$0830,$0FF0,$0000
  dc.w $07A0,$0460,$07E0,$0000,$03C0,$03C0,$03C0,$0000
  dc.w $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
  dc.w $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
  dc.w $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
  dc.w $0340,$02C0,$03C0,$0000,$0D60,$0E20,$0FE0,$0000
  dc.w $1270,$1CD0,$1F30,$0000,$0680,$18D0,$1F30,$0000
  dc.w $2138,$3608,$3FF8,$0000,$3428,$23D8,$3FF8,$0000
  dc.w $02C0,$1110,$1FF0,$0000,$1930,$1010,$1FF0,$0000
  dc.w $0460,$0820,$0FE0,$0000,$0540,$06C0,$07C0,$0000
  dc.w $0380,$0380,$0380,$0000,$0000,$0000,$0000,$0000
  dc.w $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
  dc.w $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
  dc.w $0540,$06C0,$07C0,$0000,$1A60,$1C20,$1FE0,$0000
  dc.w $2570,$39D0,$3E30,$0000,$0D88,$3158,$3E38,$0000
  dc.w $4A90,$6488,$7F78,$0000,$29C0,$4638,$7FF8,$0000
  dc.w $2420,$43D8,$7FF8,$0000,$4EC8,$6918,$77F8,$0000
  dc.w $3730,$2410,$3BF0,$0000,$0860,$1020,$1FE0,$0000
  dc.w $0B40,$0CC0,$0FC0,$0000,$0500,$0700,$0700,$0000
  dc.w $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
  dc.w $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
  dc.w $02A0,$0360,$03E0,$0000,$0870,$0ED0,$0F30,$0000
  dc.w $1238,$1DE8,$1E18,$0000,$29C0,$3528,$3E18,$0000
  dc.w $1B28,$25E0,$3E18,$0000,$4934,$660C,$7FFC,$0000
  dc.w $3CC0,$533C,$6FFC,$0000,$6434,$43CC,$7FFC,$0000
  dc.w $1AD0,$2908,$37F8,$0000,$3428,$2418,$3BF8,$0000
  dc.w $1CD0,$1030,$1FF0,$0000,$0BA0,$0C60,$0FE0,$0000
  dc.w $0280,$0380,$0380,$0000,$0000,$0000,$0000,$0000
  dc.w $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
  dc.w $0350,$0230,$03F0,$0000,$08B8,$0EE8,$0F18,$0000
  dc.w $135C,$1DB4,$1E0C,$0000,$2AE0,$3514,$3E0C,$0000
  dc.w $1A54,$24B0,$3F0C,$0000,$492E,$6662,$7F9E,$0000
  dc.w $28F0,$470E,$7FFE,$0000,$3C00,$53FE,$6FFE,$0000
  dc.w $641A,$43E6,$7FFE,$0000,$0A68,$2984,$37FC,$0000
  dc.w $3594,$240C,$3BFC,$0000,$1968,$1118,$1EF8,$0000
  dc.w $0AD0,$0C30,$0FF0,$0000,$0340,$02C0,$03C0,$0000
  dc.w $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
  dc.w $0550,$0630,$07F0,$0000,$12B8,$1CE8,$1F18,$0000
  dc.w $235C,$3DB4,$3E0C,$0000,$54E0,$6914,$7E0C,$0000
  dc.w $3754,$49B0,$7E0C,$0000,$B2A6,$CCE2,$FF1E,$0000
  dc.w $520C,$8C02,$FFFE,$0000,$78F0,$A70E,$DFFE,$0000
  dc.w $7800,$A7FE,$DFFE,$0000,$CC1A,$83E6,$FFFE,$0000
  dc.w $1668,$5184,$6FFC,$0000,$6B94,$480C,$77FC,$0000
  dc.w $3368,$2318,$3CF8,$0000,$14D0,$1830,$1FF0,$0000
  dc.w $0540,$06C0,$07C0,$0000,$0000,$0000,$0000,$0000
  dc.w $05A8,$0618,$07F8,$0000,$135C,$1C74,$1F8C,$0000
  dc.w $22AE,$3CDA,$3F06,$0000,$5470,$688A,$7F06,$0000
  dc.w $36AA,$48D8,$7F06,$0000,$B253,$CC71,$FF8F,$0000
  dc.w $5306,$8C01,$FFFF,$0000,$51CC,$8E03,$FFFF,$0000
  dc.w $7878,$A787,$DFFF,$0000,$7800,$A7FF,$DFFF,$0000
  dc.w $CC0D,$83F3,$FFFF,$0000,$1634,$51C2,$6FFE,$0000
  dc.w $6BCA,$4806,$77FE,$0000,$33B4,$238C,$3C7C,$0000
  dc.w $1468,$1818,$1FF8,$0000,$05A0,$0660,$07E0,$0000

tabelle:
                dc.w    1152,1152,1280,1408,1536,1536,1664,1792
                dc.w    1792,1920,1920,2048,2048,2176,2176,2176
                dc.w    2176,2176,2304,2176,2176,2176,2176,2176
                dc.w    2048,2048,1920,1920,1792,1792,1664,1536
                dc.w    1536,1408,1280,1152,1152,1024,896,768
                dc.w    640,640,512,384,384,256,256,128
                dc.w    128,0,0,0,0,0,0,0
                dc.w    0,0,0,0,128,128,256,256
                dc.w    384,384,512,640,640,768,896,1024
                dc.w    1152,1152,1280,1280,1408,1536,1536,1664
                dc.w    1664,1792,1792,1920,1920,2048,2048,2048
                dc.w    2176,2176,2176,2176,2176,2176,2176,2176
                dc.w    2176,2176,2176,2176,2176,2176,2048,2048
                dc.w    2048,1920,1920,1792,1792,1664,1664,1536
                dc.w    1536,1408,1280,1280,1152,1152,1024,896
                dc.w    896,768,640,640,512,512,384,384
                dc.w    256,256,128,128,128,0,0,0
                dc.w    0,0,0,0,0,0,0,0
                dc.w    0,0,0,128,128,128,256,256
                dc.w    384,384,512,512,640,640,768,896
                dc.w    896,1024

                dc.w    1152,1152,1280,1408,1536,1664,1792,1920
                dc.w    1920,2048,2048,2176,2176,2176,2176,2304
                blk.w   200,2176
                dc.w    2176,2176,2176,2176,2048,2048,1920,1920
                dc.w    1792,1664,1536,1408,1280,1152,1152,1024
                dc.w    896,768,640,512,384,256,256,128
                dc.w    128,0,0,0,0,0,0,0
                dc.w    0,0,128,128,256,256,384,512
                dc.w    640,768,896,1024


endtabelle:
                dc.w    1152,1152,1280,1408,1536,1536,1664,1792
                dc.w    1792,1920,1920,2048,2048,2176,2176,2176
                dc.w    2176,2176,2304,2176,2176,2176,2176,2176
                dc.w    2048,2048,1920,1920,1792,1792,1664,1536
                dc.w    1536,1408,1280,1152,1152,1024,896,768
                dc.w    640,640,512,384,384,256,256,128
                dc.w    128,0,0,0,0,0,0,0
                dc.w    0,0,0,0,128,128,256,256
                dc.w    384,384,512,640,640,768,896,1024
                dc.w    1152,1152,1280,1408,1536,1536,1664,1792
                dc.w    1792,1920,1920,2048,2048,2176,2176,2176
                dc.w    2176,2176,2304,2176,2176,2176,2176,2176
                dc.w    2048,2048,1920,1920,1792,1792,1664,1536
                dc.w    1536,1408,1280,1152,1152,1024,896,768
                dc.w    640,640,512,384,384,256,256,128
                dc.w    128,0,0,0,0,0,0,0
                dc.w    0,0,0,0,128,128,256,256
                dc.w    384,384,512,640,640,768,896,1024

unionlogo:      ; 80,40
         DC.W   $0000,$0000,$0300,$0000,$0000,$0000,$0000,$0780
         DC.W   $0000,$0000,$0000,$0000,$0FC0,$0000,$0000,$0000
         DC.W   $0000,$1CE0,$0000,$0000,$0000,$0000,$3870,$0000
         DC.W   $0000,$0000,$0000,$7038,$0000,$0000,$0000,$0000
         DC.W   $E21C,$0000,$0000,$0000,$0001,$C50E,$0000,$0000
         DC.W   $0000,$0003,$8507,$0000,$0000,$0000,$0007,$1543
         DC.W   $8000,$0000,$0000,$000E,$2561,$C000,$0000,$0000
         DC.W   $001C,$5550,$E000,$0000,$0000,$0038,$C748,$7000
         DC.W   $0000,$7800,$F071,$5574,$3870,$0070,$7800,$F0E2
         DC.W   $4542,$1C78,$0078,$7800,$F1C5,$557D,$0E7C,$0078
         DC.W   $7800,$F38A,$AAAA,$877E,$0078,$7800,$F615,$1040
         DC.W   $037F,$0078,$7800,$F5CA,$CB2F,$F97F,$8078,$7800
         DC.W   $F5E4,$E38F,$FC7F,$C078,$7800,$F1F2,$EBAF,$FC7B
         DC.W   $E078,$7800,$F1F8,$E38E,$1C79,$F078,$7800,$F1FC
         DC.W   $EBAE,$9C78,$F878,$7800,$F5DE,$E38E,$1D7A,$7C78
         DC.W   $7802,$F1CF,$EBAF,$FC7B,$3E78,$7806,$F5D7,$E38F
         DC.W   $FD7B,$9F78,$780E,$F2C9,$E9A7,$FC79,$CFF8,$7C00
         DC.W   $F514,$1450,$0178,$E7F8,$3FFF,$F2AA,$AAAA,$AA78
         DC.W   $73F8,$3FFF,$F555,$5555,$5578,$39F8,$1FFF,$F2AA
         DC.W   $AAAA,$AA7A,$1CF8,$07FF,$F555,$5555,$5539,$0E38
         DC.W   $0000,$02AA,$AAAA,$AA82,$8700,$0715,$5555,$5555
         DC.W   $5555,$4380,$0E2A,$AAAA,$AAAA,$AAAA,$A1C0,$1C55
         DC.W   $5555,$5555,$5555,$50E0,$38AA,$AAAA,$AAAA,$AAAA
         DC.W   $A870,$7155,$5555,$5555,$5555,$5438,$FFFF,$FFFF
         DC.W   $FFFF,$FFFF,$FFFC,$7FFF,$FFFF,$FFFF,$FFFF,$FFF8
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

dpos:           dc.l    tabelle
dpos2:          dc.l    delta
dpos3:          dc.l    lissa2
dpos4:          dc.l    delta+20
dpos5:          dc.l    lissa

delta:          ; Wabbler fÅr Union-Logo
                dc.w    8,8,9,9,10,10,11,11
                dc.w    12,12,13,13,13,14,14,14
                dc.w    15,15,15,15,15,15,15,15
                dc.w    15,15,15,15,15,15,14,14
                dc.w    14,13,13,13,12,12,11,11
                dc.w    10,10,9,9,8,8,7,6
                dc.w    6,5,5,4,4,3,3,2
                dc.w    2,2,1,1,1,0,0,0
                dc.w    0,0,0,0,0,0,0,0
                dc.w    0,0,0,1,1,1,2,2
                dc.w    2,3,3,4,4,5,5,6
                dc.w    6,7

                dc.w    8,8,9,10,11,12,12,13
                dc.w    13,14,14,15,15,15,15
                dc.w    15,15,15,15,14,14,13,13
                dc.w    12,12,11,10,9,8,8,7
                dc.w    6,5,4,3,3,2,2,1
                dc.w    1,0,0,0,0,0,0,0
                dc.w    0,0,1,1,2,2,3,3
                dc.w    4,5,6,7


                dc.w    8,9,10,11,12,13,14,15
                dc.w    15,15,15,15,15,14,13
                dc.w    12,11,10,9,8,6,5,4
                dc.w    3,2,1,0,0,0,0,0
                dc.w    0,0,1,2,3,4,5,6

                dc.w    8,9,10,12,13,14,14,15
                dc.w    15,15,15,14,14,13,12
                dc.w    10,9,8,6,5,3,2,1
                dc.w    1,0,0,0,0,0,1,1
                dc.w    2,3,5,6
                
                dc.w    5,4,3,2,1,0
                blk.w   50,0
                dc.w    1,2,3,4,4,3,2,1,0
                dc.w    1,2,3,4,4,3,2,1,0
                dc.w    1,2,3,4,4,3,2,1,0
                dc.w    1,2,3,4,4,3,2,1,0
                dc.w    1,2,3,4,4,3,2,1,0
                dc.w    1,2,3,4,4,3,2,1,0
                dc.w    1,2,3,4,4,3,2,1,0
                dc.w    1,2,3,4,4,3,2,1,0
                dc.w    1,2,3,4,4,3,2,1,0
                dc.w    1,2,3,4,4,3,2,1,0
                dc.w    1,2,3,4,5,6,7

enddelta:       dc.w    8,8,9,9,10,10,11,11
                dc.w    12,12,13,13,13,14,14,14
                dc.w    15,15,15,15,15,15,15,15
                dc.w    15,15,15,15,15,15,14,14
                dc.w    14,13,13,13,12,12,11,11
                dc.w    10,10,9,9,8,8,7,6
                dc.w    6,5,5,4,4,3,3,2
                dc.w    2,2,1,1,1,0,0,0
                dc.w    0,0,0,0,0,0,0,0
                dc.w    0,0,0,1,1,1,2,2
                dc.w    2,3,3,4,4,5,5,6
                dc.w    6,7

lissa2:
; Lissajous fÅr Unionlogo
        dc.w 112,12800,111,13600,111,14240,110,15040,108,15840,106,16640
        dc.w 104,17280,101,17920,98,18400,95,19040,91,19360,88,19840
        dc.w 83,20160,79,20320,75,20480,70,20640,65,20640,61,20480
        dc.w 56,20320,51,20160,47,19840,42,19520,38,19200,33,18720
        dc.w 29,18080,26,17600,22,17120,19,16480,16,15840,14,15200
        dc.w 12,14560,10,14080,9,13440,8,12960,8,12320,8,11840
        dc.w 8,11520,9,11040,11,10880,13,10560,15,10400,18,10240
        dc.w 21,10240,24,10400,28,10400,33,10720,37,10880,42,11200
        dc.w 47,11680,52,12160,57,12640,63,13280,68,13920,74,14560
        dc.w 80,15360,85,16160,91,16800,96,17600,102,18400,107,19200
        dc.w 111,19840,116,20640,120,21280,124,21920,128,22560,131,23040
        dc.w 134,23520,137,24000,139,24320,141,24480,142,24800,143,24800
        dc.w 143,24960,143,24800,143,24800,142,24480,141,24320,139,24000
        dc.w 137,23520,134,23040,132,22560,129,22080,125,21440,122,20800
        dc.w 118,20160,114,19520,110,18720,106,18080,102,17440,98,16800
        dc.w 94,16160,90,15520,86,15040,82,14560,79,14080,75,13600
        dc.w 72,13280,69,13120,67,12800,65,12800,63,12800,62,12800
        dc.w 61,12800,60,13120,60,13280,60,13600,61,14080,62,14560
        dc.w 64,15040,66,15520,68,16160,71,16800,74,17440,78,18080
        dc.w 82,18720,86,19520,91,20160,96,20800,101,21440,106,22080
        dc.w 111,22560,117,23040,123,23520,129,24000,134,24320,140,24480
        dc.w 146,24800,152,24800,157,24960,162,24800,167,24800,172,24480
        dc.w 177,24320,181,24000,185,23520,189,23040,192,22560,194,21920
        dc.w 197,21280,199,20640,200,19840,201,19200,202,18400,202,17600
        dc.w 201,16800,201,16160,199,15360,198,14560,196,13920,193,13280
        dc.w 191,12800,188,12160,184,11680,181,11200,177,10880,173,10720
        dc.w 169,10400,164,10400,160,10240,155,10240,151,10400,147,10560
        dc.w 142,10880,138,11040,134,11520,130,11840,126,12320,123,12960
        dc.w 120,13440,117,14080,114,14560,112,15200,111,15840,109,16480
        dc.w 108,17120,108,17600,108,18080,108,18720,109,19200,110,19520
        dc.w 112,19840,114,20160,116,20320,119,20480,122,20640,125,20640
        dc.w 129,20480,133,20320,137,20160,142,19840,147,19360,152,19040
        dc.w 157,18400,162,17920,167,17280,172,16640,177,15840,182,15040
        dc.w 186,14240,191,13600,195,12800,200,11840,204,11200,207,10400
        dc.w 211,9600,213,8800,216,8160,218,7520,220,7040,221,6400
        dc.w 222,6080,223,5600,222,5280,222,5120,221,4960,220,4800
        dc.w 218,4800,216,4960,213,5120,210,5280,206,5600,203,5920
        dc.w 199,6240,194,6720,190,7360,185,7840,180,8320,174,8960
        dc.w 169,9600,164,10240,158,10880,153,11360,148,12000,143,12480
        dc.w 137,13120,133,13600,128,13920,123,14400,119,14560,115,14880
        dc.w 112,15040,108,15200,105,15200,103,15040,101,15040,99,14720
        dc.w 98,14560,97,14240,97,13760,97,13280,97,12800,98,12160
        dc.w 99,11520,101,10880,103,10080,105,9280,108,8640,111,7840
        dc.w 114,7040,118,6240,122,5600,126,4800,130,4160,134,3520
        dc.w 138,2880,142,2400,146,1920,151,1440,155,1120,159,960
        dc.w 162,640,166,640,169,480,172,640,175,640,177,960
        dc.w 179,1120,181,1440,182,1920,183,2400,184,2880,184,3360
        dc.w 183,4000,182,4640,181,5280,179,5920,177,6720,174,7360
        dc.w 171,8000,168,8640,164,9280,160,9920,155,10400,150,10880
        dc.w 145,11360,140,11840,135,12160,129,12320,123,12640,117,12640
        dc.w 112,12640,106,12640,100,12640,94,12320,88,12160,83,11840
        dc.w 78,11360,73,10880,68,10400,63,9920,59,9280,55,8640
        dc.w 52,8000,49,7360,46,6720,44,5920,42,5280,41,4640
        dc.w 40,4000,39,3360,39,2880,40,2400,41,1920,42,1440
        dc.w 44,1120,46,960,48,640,51,640,54,480,57,640
        dc.w 61,640,64,960,68,1120,72,1440,77,1920,81,2400
        dc.w 85,2880,89,3520,93,4160,97,4800,101,5600,105,6240
        dc.w 109,7040,112,7840,115,8640,118,9280,120,10080,122,10880
        dc.w 124,11520,125,12160,126,12640,126,13280,126,13760,126,14240
        dc.w 125,14560,124,14720,122,15040,120,15040,118,15200,115,15200
        dc.w 112,15040,108,14880,104,14560,100,14400,95,13920,90,13600
        dc.w 86,13120,80,12480,75,12000,70,11360,65,10880,59,10240
        dc.w 54,9600,49,8960,43,8320,38,7840,33,7360,29,6720
        dc.w 24,6240,20,5920,17,5600,13,5280,10,5120,7,4960
        dc.w 5,4800,3,4800,2,4960,1,5120,1,5280,0,5600
        dc.w 1,6080,2,6400,3,7040,5,7520,7,8160,10,8800
        dc.w 12,9600,16,10400,19,11200,23,11840,27,12640,32,13600
        dc.w 37,14240,41,15040,46,15840,51,16640,56,17280,61,17920
        dc.w 66,18400,71,19040,76,19360,81,19840,86,20160,90,20320
        dc.w 94,20480,98,20640,101,20640,104,20480,107,20320,109,20160
        dc.w 112,19840,113,19520,114,19200,115,18720,115,18080,115,17600
        dc.w 115,17120,114,16480,112,15840,111,15200,109,14560,106,14080
        dc.w 103,13440,100,12960,97,12320,93,11840,89,11520,85,11040
        dc.w 81,10880,76,10560,72,10400,68,10240,63,10240,59,10400
        dc.w 54,10400,50,10720,46,10880,42,11200,39,11680,35,12160
        dc.w 32,12640,30,13280,27,13920,25,14560,24,15360,22,16160
        dc.w 22,16800,21,17600,21,18400,22,19200,23,19840,24,20640
        dc.w 26,21280,29,21920,31,22560,34,23040,38,23520,42,24000
        dc.w 46,24320,51,24480,56,24800,61,24800,66,24960,71,24800
        dc.w 77,24800,83,24480,89,24320,94,24000,100,23520,106,23040
        dc.w 111,22560,117,22080,122,21440,127,20800,132,20160,137,19520
        dc.w 141,18720,145,18080,149,17440,152,16800,155,16160,157,15520
        dc.w 159,15040,161,14560,162,14080,163,13600,163,13280,163,13120
        dc.w 162,12800,161,12800,160,12800,158,12800,156,12800,154,13120
        dc.w 151,13280,148,13600,144,14080,141,14560,137,15040,133,15520
        dc.w 129,16160,125,16800,121,17440,117,18080,113,18720,109,19520
        dc.w 105,20160,101,20800,98,21440,94,22080,91,22560,89,23040
        dc.w 86,23520,84,24000,82,24320,81,24480,80,24800,80,24800
        dc.w 80,24960,80,24800,81,24800,82,24480,84,24320,86,24000
        dc.w 89,23520,92,23040,95,22560,99,21920,103,21280,107,20640
        dc.w 111,19840,116,19200,121,18400,127,17600,132,16800,138,16160
        dc.w 143,15360,149,14560,155,13920,160,13280,166,12800,171,12160
        dc.w 176,11680,181,11200,186,10880,190,10720,195,10400,199,10400
        dc.w 202,10240,205,10240,208,10400,210,10560,212,10880,214,11040
        dc.w 215,11520,215,11840,215,12320,215,12960,214,13440,213,14080
        dc.w 211,14560,209,15200,207,15840,204,16480,201,17120,197,17600
        dc.w 194,18080,190,18720,185,19200,181,19520,176,19840,172,20160
        dc.w 167,20320,162,20480,158,20640,153,20640,148,20480,144,20320
        dc.w 140,20160,135,19840,132,19360,128,19040,125,18400,122,17920
        dc.w 119,17280,117,16640,115,15840,113,15040,112,14240,112,13600
        dc.w 112,12800,112,11840,112,11200,113,10400,115,9600,117,8800
        dc.w 119,8160,122,7520,125,7040,128,6400,132,6080,135,5600
        dc.w 140,5280,144,5120,148,4960,153,4800,158,4800,162,4960
        dc.w 167,5120,172,5280,176,5600,181,5920,185,6240,190,6720
        dc.w 194,7360,197,7840,201,8320,204,8960,207,9600,209,10240
        dc.w 211,10880,213,11360,214,12000,215,12480,215,13120,215,13600
        dc.w 215,13920,214,14400,212,14560,210,14880,208,15040,205,15200
        dc.w 202,15200,199,15040,195,15040,190,14720,186,14560,181,14240
        dc.w 176,13760,171,13280,166,12800,160,12160,155,11520,149,10880
        dc.w 143,10080,138,9280,132,8640,127,7840,121,7040,116,6240
        dc.w 112,5600,107,4800,103,4160,99,3520,95,2880,92,2400
        dc.w 89,1920,86,1440,84,1120,82,960,81,640,80,640
        dc.w 80,480,80,640,80,640,81,960,82,1120,84,1440
        dc.w 86,1920,89,2400,91,2880,94,3360,98,4000,101,4640
        dc.w 105,5280,109,5920,113,6720,117,7360,121,8000,125,8640
        dc.w 129,9280,133,9920,137,10400,141,10880,144,11360,148,11840
        dc.w 151,12160,154,12320,156,12640,158,12640,160,12640,161,12640
        dc.w 162,12640,163,12320,163,12160,163,11840,162,11360,161,10880
        dc.w 159,10400,157,9920,155,9280,152,8640,149,8000,145,7360
        dc.w 141,6720,137,5920,132,5280,127,4640,122,4000,117,3360
        dc.w 112,2880,106,2400,100,1920,94,1440,89,1120,83,960
        dc.w 77,640,71,640,66,480,61,640,56,640,51,960
        dc.w 46,1120,42,1440,38,1920,34,2400,31,2880,29,3520
        dc.w 26,4160,24,4800,23,5600,22,6240,21,7040,21,7840
        dc.w 22,8640,22,9280,24,10080,25,10880,27,11520,30,12160
        dc.w 32,12640,35,13280,39,13760,42,14240,46,14560,50,14720
        dc.w 54,15040,59,15040,63,15200,68,15200,72,15040,76,14880
        dc.w 81,14560,85,14400,89,13920,93,13600,97,13120,100,12480
        dc.w 103,12000,106,11360,109,10880,111,10240,112,9600,114,8960
        dc.w 115,8320,115,7840,115,7360,115,6720,114,6240,113,5920
        dc.w 112,5600,109,5280,107,5120,104,4960,101,4800,98,4800
        dc.w 94,4960,90,5120,86,5280,81,5600,76,6080,71,6400
        dc.w 66,7040,61,7520,56,8160,51,8800,46,9600,41,10400
        dc.w 37,11200,32,11840,28,12640,23,13600,19,14240,16,15040
        dc.w 12,15840,10,16640,7,17280,5,17920,3,18400,2,19040
        dc.w 1,19360,0,19840,1,20160,1,20320,2,20480,3,20640
        dc.w 5,20640,7,20480,10,20320,13,20160,17,19840,20,19520
        dc.w 24,19200,29,18720,33,18080,38,17600,43,17120,49,16480
        dc.w 54,15840,59,15200,65,14560,70,14080,75,13440,80,12960
        dc.w 86,12320,90,11840,95,11520,100,11040,104,10880,108,10560
        dc.w 112,10400,115,10240,118,10240,120,10400,122,10400,124,10720
        dc.w 125,10880,126,11200,126,11680,126,12160,126,12640,125,13280
        dc.w 124,13920,122,14560,120,15360,118,16160,115,16800,112,17600
        dc.w 109,18400,105,19200,101,19840,97,20640,93,21280,89,21920
        dc.w 85,22560,81,23040,77,23520,72,24000,68,24320,64,24480
        dc.w 61,24800,57,24800,54,24960,51,24800,48,24800,46,24480
        dc.w 44,24320,42,24000,41,23520,40,23040,39,22560,39,22080
        dc.w 40,21440,41,20800,42,20160,44,19520,46,18720,49,18080
        dc.w 52,17440,55,16800,59,16160,63,15520,68,15040,73,14560
        dc.w 78,14080,83,13600,88,13280,94,13120,100,12800,106,12800
        dc.w 111,12800,117,12800,123,12800,129,13120,135,13280,140,13600
        dc.w 145,14080,150,14560,155,15040,160,15520,164,16160,168,16800
        dc.w 171,17440,174,18080,177,18720,179,19520,181,20160,182,20800
        dc.w 183,21440,184,22080,184,22560,183,23040,182,23520,181,24000
        dc.w 179,24320,177,24480,175,24800,172,24800,169,24960,166,24800
        dc.w 162,24800,159,24480,155,24320,151,24000,146,23520,142,23040
        dc.w 138,22560,134,21920,130,21280,126,20640,122,19840,118,19200
        dc.w 114,18400,111,17600,108,16800,105,16160,103,15360,101,14560
        dc.w 99,13920,98,13280,97,12800,97,12160,97,11680,97,11200
        dc.w 98,10880,99,10720,101,10400,103,10400,105,10240,108,10240
        dc.w 111,10400,115,10560,119,10880,123,11040,128,11520,133,11840
        dc.w 137,12320,143,12960,148,13440,153,14080,158,14560,164,15200
        dc.w 169,15840,174,16480,180,17120,185,17600,190,18080,194,18720
        dc.w 199,19200,203,19520,206,19840,210,20160,213,20320,216,20480
        dc.w 218,20640,220,20640,221,20480,222,20320,222,20160,223,19840
        dc.w 222,19360,221,19040,220,18400,218,17920,216,17280,213,16640
        dc.w 211,15840,207,15040,204,14240,200,13600,196,12800,191,11840
        dc.w 186,11200,182,10400,177,9600,172,8800,167,8160,162,7520
        dc.w 157,7040,152,6400,147,6080,142,5600,137,5280,133,5120
        dc.w 129,4960,125,4800,122,4800,119,4960,116,5120,114,5280
        dc.w 112,5600,110,5920,109,6240,108,6720,108,7360,108,7840
        dc.w 108,8320,109,8960,111,9600,112,10240,114,10880,117,11360
        dc.w 120,12000,123,12480,126,13120,130,13600,134,13920,138,14400
        dc.w 142,14560,147,14880,151,15040,155,15200,160,15200,164,15040
        dc.w 169,15040,173,14720,177,14560,181,14240,184,13760,188,13280
        dc.w 191,12800,193,12160,196,11520,198,10880,199,10080,201,9280
        dc.w 201,8640,202,7840,202,7040,201,6240,200,5600,199,4800
        dc.w 197,4160,194,3520,192,2880,189,2400,185,1920,181,1440
        dc.w 177,1120,172,960,167,640,162,640,157,480,152,640
        dc.w 146,640,140,960,134,1120,129,1440,123,1920,117,2400
        dc.w 112,2880,106,3360,101,4000,96,4640,91,5280,86,5920
        dc.w 82,6720,78,7360,74,8000,71,8640,68,9280,66,9920
        dc.w 64,10400,62,10880,61,11360,60,11840,60,12160,60,12320
        dc.w 61,12640,62,12640,63,12640,65,12640,67,12640,69,12320
        dc.w 72,12160,75,11840,79,11360,82,10880,86,10400,90,9920
        dc.w 94,9280,98,8640,102,8000,106,7360,110,6720,114,5920
        dc.w 118,5280,122,4640,125,4000,129,3360,132,2880,134,2400
        dc.w 137,1920,139,1440,141,1120,142,960,143,640,143,640
        dc.w 143,480,143,640,142,640,141,960,139,1120,137,1440
        dc.w 134,1920,131,2400,128,2880,124,3520,120,4160,116,4800
        dc.w 112,5600,107,6240,102,7040,96,7840,91,8640,85,9280
        dc.w 80,10080,74,10880,68,11520,63,12160,57,12640,52,13280
        dc.w 47,13760,42,14240,37,14560,33,14720,28,15040,24,15040
        dc.w 21,15200,18,15200,15,15040,13,14880,11,14560,9,14400
        dc.w 8,13920,8,13600,8,13120,8,12480,9,12000,10,11360
        dc.w 12,10880,14,10240,16,9600,19,8960,22,8320,26,7840
        dc.w 29,7360,33,6720,38,6240,42,5920,47,5600,51,5280
        dc.w 56,5120,61,4960,65,4800,70,4800,75,4960,79,5120
        dc.w 83,5280,88,5600,91,6080,95,6400,98,7040,101,7520
        dc.w 104,8160,106,8800,108,9600,110,10400,111,11200,111,11840
        dc.w -99


lissa:
        dc.w 88,11040,84,11520,80,12160,77,12800,73,13440,70,14080
        dc.w 66,14560,63,15040,60,15520,57,16000,54,16320,52,16640
        dc.w 49,16960,47,17120,45,17280,43,17280,42,17440,41,17280
        dc.w 40,17280,39,17120,39,16960,39,16640,39,16320,39,16000
        dc.w 40,15520,41,15200,42,14720,44,14240,45,13760,47,13120
        dc.w 50,12640,52,12160,54,11680,57,11200,60,10560,63,10240
        dc.w 66,9760,69,9280,72,8960,75,8640,78,8480,82,8160
        dc.w 85,8000,88,8000,91,8000,94,8000,97,8000,100,8160
        dc.w 102,8320,105,8640,107,8960,109,9280,111,9760,113,10240
        dc.w 114,10720,116,11200,117,11840,117,12320,118,12960,118,13600
        dc.w 118,14240,118,14880,117,15520,116,16000,115,16640,113,17120
        dc.w 112,17760,110,18240,108,18720,105,19040,103,19360,100,19680
        dc.w 97,20000,94,20160,91,20320,88,20320,84,20320,81,20320
        dc.w 77,20160,73,20000,70,19840,66,19520,62,19200,59,18880
        dc.w 55,18400,52,18080,48,17600,45,16960,42,16480,39,16000
        dc.w 36,15360,34,14880,32,14400,29,13760,28,13280,26,12800
        dc.w 24,12320,23,12000,22,11520,22,11200,22,11040,21,10720
        dc.w 22,10560,22,10400,23,10400,24,10400,25,10400,27,10560
        dc.w 28,10720,30,10880,32,11200,35,11520,37,12000,40,12320
        dc.w 43,12800,46,13280,49,13920,52,14400,55,15040,58,15680
        dc.w 62,16160,65,16800,68,17440,71,17920,74,18560,78,19040
        dc.w 81,19520,83,20000,86,20480,89,20800,91,21120,93,21440
        dc.w 95,21600,97,21760,98,21920,100,21920,101,21920,101,21760
        dc.w 102,21760,102,21440,102,21280,102,20960,101,20640,100,20160
        dc.w 99,19680,98,19200,96,18720,94,18240,92,17600,90,17120
        dc.w 88,16480,85,15840,82,15360,79,14720,76,14240,72,13760
        dc.w 69,13280,66,12800,62,12320,58,12000,55,11680,51,11360
        dc.w 48,11200,44,11040,41,10880,37,10880,34,10880,31,11040
        dc.w 28,11200,25,11360,22,11520,20,11840,17,12160,15,12640
        dc.w 14,13120,12,13600,11,14080,10,14560,9,15040,8,15680
        dc.w 8,16160,8,16800,8,17280,9,17920,10,18400,11,18880
        dc.w 12,19360,13,19840,15,20160,17,20480,19,20800,22,20960
        dc.w 24,21280,27,21280,30,21440,33,21440,36,21280,39,21280
        dc.w 43,21120,46,20800,49,20480,53,20160,56,19840,59,19360
        dc.w 63,18880,66,18400,69,17760,72,17280,74,16640,77,16000
        dc.w 79,15360,82,14880,84,14240,86,13600,87,13120,88,12480
        dc.w 90,12000,90,11520,91,11040,91,10560,91,10240,91,9920
        dc.w 91,9760,90,9600,89,9440,88,9280,86,9280,84,9440
        dc.w 82,9440,80,9600,78,9920,75,10080,72,10400,69,10880
        dc.w 66,11200,63,11680,60,12160,56,12640,53,13120,49,13600
        dc.w 46,14240,42,14720,39,15200,35,15840,32,16320,28,16800
        dc.w 25,17120,22,17600,19,17920,16,18240,14,18560,11,18720
        dc.w 9,18880,7,19040,6,19040,4,19040,3,18880,2,18720
        dc.w 1,18560,1,18240,0,17920,1,17600,1,17280,2,16800
        dc.w 2,16160,4,15680,5,15200,7,14560,9,13920,11,13280
        dc.w 13,12640,15,12000,18,11360,21,10720,24,10240,27,9600
        dc.w 30,9120,34,8640,37,8160,40,7680,44,7360,47,7040
        dc.w 51,6720,54,6560,57,6400,60,6240,64,6240,67,6240
        dc.w 69,6400,72,6560,75,6720,77,7040,79,7360,81,7680
        dc.w 83,8000,84,8480,85,8960,86,9440,87,9920,87,10400
        dc.w 88,10880,87,11520,87,12000,86,12480,85,12960,84,13440
        dc.w 83,13920,81,14240,79,14560,77,14880,75,15200,72,15360
        dc.w 69,15520,67,15680,64,15680,60,15680,57,15520,54,15360
        dc.w 51,15200,47,14880,44,14560,40,14240,37,13760,34,13280
        dc.w 30,12800,27,12320,24,11680,21,11200,18,10560,15,9920
        dc.w 13,9280,11,8640,9,8000,7,7360,5,6720,4,6240
        dc.w 2,5760,2,5120,1,4640,1,4320,0,4000,1,3680
        dc.w 1,3360,2,3200,3,3040,4,2880,6,2880,7,2880
        dc.w 9,3040,11,3200,14,3360,16,3680,19,4000,22,4320
        dc.w 25,4800,28,5120,32,5600,35,6080,39,6720,42,7200
        dc.w 46,7680,49,8320,53,8800,56,9280,60,9760,63,10240
        dc.w 66,10720,69,11040,72,11520,75,11840,78,12000,80,12320
        dc.w 82,12480,84,12480,86,12640,87,12640,89,12480,90,12320
        dc.w 91,12160,91,12000,91,11680,91,11360,91,10880,90,10400
        dc.w 90,9920,88,9440,87,8800,86,8320,84,7680,82,7040
        dc.w 79,6560,77,5920,74,5280,72,4640,69,4160,66,3520
        dc.w 63,3040,59,2560,56,2080,53,1760,49,1440,46,1120
        dc.w 43,800,39,640,36,640,33,480,30,480,27,640
        dc.w 24,640,22,960,19,1120,17,1440,15,1760,13,2080
        dc.w 12,2560,11,3040,10,3520,9,4000,8,4640,8,5120
        dc.w 8,5760,8,6240,9,6880,10,7360,11,7840,12,8320
        dc.w 14,8800,15,9280,17,9760,20,10080,22,10400,25,10560
        dc.w 28,10720,31,10880,34,11040,37,11040,41,11040,44,10880
        dc.w 48,10720,51,10560,55,10240,58,9920,62,9600,66,9120
        dc.w 69,8640,72,8160,76,7680,79,7200,82,6560,85,6080
        dc.w 87,5440,90,4800,92,4320,94,3680,96,3200,98,2720
        dc.w 99,2240,100,1760,101,1280,102,960,102,640,102,480
        dc.w 102,160,101,160,101,0,100,0,98,0,97,160
        dc.w 95,320,93,480,91,800,89,1120,86,1440,83,1920
        dc.w 81,2400,78,2880,74,3360,71,4000,68,4480,65,5120
        dc.w 62,5760,58,6240,55,6880,52,7520,49,8000,46,8640
        dc.w 43,9120,40,9600,37,9920,35,10400,32,10720,30,11040
        dc.w 28,11200,27,11360,25,11520,24,11520,23,11520,22,11520
        dc.w 22,11360,21,11200,22,11040,22,10720,22,10400,23,9920
        dc.w 24,9600,26,9120,28,8640,29,8160,32,7520,34,7040
        dc.w 36,6560,39,5920,42,5440,45,4960,48,4320,52,3840
        dc.w 55,3520,59,3040,62,2720,66,2400,70,2080,73,1920
        dc.w 77,1760,81,1600,84,1600,87,1600,91,1600,94,1760
        dc.w 97,1920,100,2240,103,2560,105,2880,108,3200,110,3680
        dc.w 112,4160,113,4800,115,5280,116,5920,117,6400,118,7040
        dc.w 118,7680,118,8320,118,8960,117,9600,117,10080,116,10720
        dc.w 114,11200,113,11680,111,12160,109,12640,107,12960,105,13280
        dc.w 102,13600,100,13760,97,13920,94,13920,91,13920,88,13920
        dc.w 85,13920,82,13760,78,13440,75,13280,72,12960,69,12640
        dc.w 66,12160,63,11680,60,11360,57,10720,54,10240,52,9760
        dc.w 50,9280,47,8800,45,8160,44,7680,42,7200,41,6720
        dc.w 40,6400,39,5920,39,5600,39,5280,39,4960,39,4800
        dc.w 40,4640,41,4640,42,4480,43,4640,45,4640,47,4800
        dc.w 49,4960,52,5280,54,5600,57,5920,60,6400,63,6880
        dc.w 66,7360,70,7840,73,8480,77,9120,80,9760,84,10400
        dc.w 87,10880,91,11520,95,12160,98,12800,102,13440,105,14080
        dc.w 109,14560,112,15040,115,15520,118,16000,121,16320,123,16640
        dc.w 126,16960,128,17120,130,17280,132,17280,133,17440,134,17280
        dc.w 135,17280,136,17120,136,16960,136,16640,136,16320,136,16000
        dc.w 135,15520,134,15200,133,14720,131,14240,130,13760,128,13120
        dc.w 125,12640,123,12160,121,11680,118,11200,115,10560,112,10240
        dc.w 109,9760,106,9280,103,8960,100,8640,97,8480,93,8160
        dc.w 90,8000,87,8000,84,8000,81,8000,78,8000,75,8160
        dc.w 73,8320,70,8640,68,8960,66,9280,64,9760,62,10240
        dc.w 61,10720,59,11200,58,11840,58,12320,57,12960,57,13600
        dc.w 57,14240,57,14880,58,15520,59,16000,60,16640,62,17120
        dc.w 63,17760,65,18240,67,18720,70,19040,72,19360,75,19680
        dc.w 78,20000,81,20160,84,20320,87,20320,91,20320,94,20320
        dc.w 98,20160,102,20000,105,19840,109,19520,113,19200,116,18880
        dc.w 120,18400,123,18080,127,17600,130,16960,133,16480,136,16000
        dc.w 139,15360,141,14880,143,14400,146,13760,147,13280,149,12800
        dc.w 151,12320,152,12000,153,11520,153,11200,153,11040,154,10720
        dc.w 153,10560,153,10400,152,10400,151,10400,150,10400,148,10560
        dc.w 147,10720,145,10880,143,11200,140,11520,138,12000,135,12320
        dc.w 132,12800,129,13280,126,13920,123,14400,120,15040,117,15680
        dc.w 113,16160,110,16800,107,17440,104,17920,101,18560,97,19040
        dc.w 94,19520,92,20000,89,20480,86,20800,84,21120,82,21440
        dc.w 80,21600,78,21760,77,21920,75,21920,74,21920,74,21760
        dc.w 73,21760,73,21440,73,21280,73,20960,74,20640,75,20160
        dc.w 76,19680,77,19200,79,18720,81,18240,83,17600,85,17120
        dc.w 87,16480,90,15840,93,15360,96,14720,99,14240,103,13760
        dc.w 106,13280,109,12800,113,12320,117,12000,120,11680,124,11360
        dc.w 127,11200,131,11040,134,10880,138,10880,141,10880,144,11040
        dc.w 147,11200,150,11360,153,11520,155,11840,158,12160,160,12640
        dc.w 161,13120,163,13600,164,14080,165,14560,166,15040,167,15680
        dc.w 167,16160,167,16800,167,17280,166,17920,165,18400,164,18880
        dc.w 163,19360,162,19840,160,20160,158,20480,156,20800,153,20960
        dc.w 151,21280,148,21280,145,21440,142,21440,139,21280,136,21280
        dc.w 132,21120,129,20800,126,20480,122,20160,119,19840,116,19360
        dc.w 112,18880,109,18400,106,17760,103,17280,101,16640,98,16000
        dc.w 96,15360,93,14880,91,14240,89,13600,88,13120,87,12480
        dc.w 85,12000,85,11520,84,11040,84,10560,84,10240,84,9920
        dc.w 84,9760,85,9600,86,9440,87,9280,89,9280,91,9440
        dc.w 93,9440,95,9600,97,9920,100,10080,103,10400,106,10880
        dc.w 109,11200,112,11680,115,12160,119,12640,122,13120,126,13600
        dc.w 129,14240,133,14720,136,15200,140,15840,143,16320,147,16800
        dc.w 150,17120,153,17600,156,17920,159,18240,161,18560,164,18720
        dc.w 166,18880,168,19040,169,19040,171,19040,172,18880,173,18720
        dc.w 174,18560,174,18240,175,17920,174,17600,174,17280,173,16800
        dc.w 173,16160,171,15680,170,15200,168,14560,166,13920,164,13280
        dc.w 162,12640,160,12000,157,11360,154,10720,151,10240,148,9600
        dc.w 145,9120,141,8640,138,8160,135,7680,131,7360,128,7040
        dc.w 124,6720,121,6560,118,6400,115,6240,111,6240,108,6240
        dc.w 106,6400,103,6560,100,6720,98,7040,96,7360,94,7680
        dc.w 92,8000,91,8480,90,8960,89,9440,88,9920,88,10400
        dc.w 88,10880,88,11520,88,12000,89,12480,90,12960,91,13440
        dc.w 92,13920,94,14240,96,14560,98,14880,100,15200,103,15360
        dc.w 106,15520,108,15680,111,15680,115,15680,118,15520,121,15360
        dc.w 124,15200,128,14880,131,14560,135,14240,138,13760,141,13280
        dc.w 145,12800,148,12320,151,11680,154,11200,157,10560,160,9920
        dc.w 162,9280,164,8640,166,8000,168,7360,170,6720,171,6240
        dc.w 173,5760,173,5120,174,4640,174,4320,175,4000,174,3680
        dc.w 174,3360,173,3200,172,3040,171,2880,169,2880,168,2880
        dc.w 166,3040,164,3200,161,3360,159,3680,156,4000,153,4320
        dc.w 150,4800,147,5120,143,5600,140,6080,136,6720,133,7200
        dc.w 129,7680,126,8320,122,8800,119,9280,115,9760,112,10240
        dc.w 109,10720,106,11040,103,11520,100,11840,97,12000,95,12320
        dc.w 93,12480,91,12480,89,12640,88,12640,86,12480,85,12320
        dc.w 84,12160,84,12000,84,11680,84,11360,84,10880,85,10400
        dc.w 85,9920,87,9440,88,8800,89,8320,91,7680,93,7040
        dc.w 96,6560,98,5920,101,5280,103,4640,106,4160,109,3520
        dc.w 112,3040,116,2560,119,2080,122,1760,126,1440,129,1120
        dc.w 132,800,136,640,139,640,142,480,145,480,148,640
        dc.w 151,640,153,960,156,1120,158,1440,160,1760,162,2080
        dc.w 163,2560,164,3040,165,3520,166,4000,167,4640,167,5120
        dc.w 167,5760,167,6240,166,6880,165,7360,164,7840,163,8320
        dc.w 161,8800,160,9280,158,9760,155,10080,153,10400,150,10560
        dc.w 147,10720,144,10880,141,11040,138,11040,134,11040,131,10880
        dc.w 127,10720,124,10560,120,10240,117,9920,113,9600,109,9120
        dc.w 106,8640,103,8160,99,7680,96,7200,93,6560,90,6080
        dc.w 88,5440,85,4800,83,4320,81,3680,79,3200,77,2720
        dc.w 76,2240,75,1760,74,1280,73,960,73,640,73,480
        dc.w 73,160,74,160,74,0,75,0,77,0,78,160
        dc.w 80,320,82,480,84,800,86,1120,89,1440,92,1920
        dc.w 94,2400,97,2880,101,3360,104,4000,107,4480,110,5120
        dc.w 113,5760,117,6240,120,6880,123,7520,126,8000,129,8640
        dc.w 132,9120,135,9600,138,9920,140,10400,143,10720,145,11040
        dc.w 147,11200,148,11360,150,11520,151,11520,152,11520,153,11520
        dc.w 153,11360,154,11200,154,11040,153,10720,153,10400,152,9920
        dc.w 151,9600,149,9120,147,8640,146,8160,143,7520,141,7040
        dc.w 139,6560,136,5920,133,5440,130,4960,127,4320,123,3840
        dc.w 120,3520,116,3040,113,2720,109,2400,105,2080,102,1920
        dc.w 98,1760,94,1600,91,1600,88,1600,84,1600,81,1760
        dc.w 78,1920,75,2240,72,2560,70,2880,67,3200,65,3680
        dc.w 63,4160,62,4800,60,5280,59,5920,58,6400,57,7040
        dc.w 57,7680,57,8320,57,8960,58,9600,58,10080,59,10720
        dc.w 61,11200,62,11680,64,12160,66,12640,68,12960,70,13280
        dc.w 73,13600,75,13760,78,13920,81,13920,84,13920,87,13920
        dc.w 90,13920,93,13760,97,13440,100,13280,103,12960,106,12640
        dc.w 109,12160,112,11680,115,11360,118,10720,121,10240,123,9760
        dc.w 125,9280,128,8800,130,8160,131,7680,133,7200,134,6720
        dc.w 135,6400,136,5920,136,5600,136,5280,136,4960,136,4800
        dc.w 135,4640,134,4640,133,4480,132,4640,130,4640,128,4800
        dc.w 126,4960,123,5280,121,5600,118,5920,115,6400,112,6880
        dc.w 109,7360,105,7840,102,8480,98,9120,95,9760,91,10400
        dc.w -99


smilienick1:
         DC.W   $0A50,$13C8,$1C38,$0000,$2814,$0FF0,$300C,$0000
         DC.W   $2004,$3FFC,$4002,$0000,$4004,$FFFD,$8003,$0000
         DC.W   $1FF9,$7FFC,$8E73,$0000,$8245,$FBDC,$0A53,$0420
         DC.W   $8001,$FFF8,$0007,$0000,$0189,$7FF8,$8187,$0000
         DC.W   $4812,$FFF9,$900F,$0000,$3AD6,$3BD0,$4C3E,$0000
         DC.W   $1BCC,$1FE0,$27FC,$0000,$0870,$1008,$1FF8,$0000
smilienick2:
         DC.W   $0A50,$13C8,$1C38,$0000,$2814,$0FF0,$300C,$0000
         DC.W   $2004,$3FFC,$4002,$0000,$4004,$FFFD,$8003,$0000
         DC.W   $0001,$7FFC,$8003,$0000,$8005,$FFFC,$0003,$0000
         DC.W   $8991,$EBD0,$1A5F,$0420,$0669,$7FF8,$8E77,$0000
         DC.W   $4012,$FFF1,$800F,$0000,$29E6,$3FE8,$519E,$0000
         DC.W   $181C,$1810,$2FFC,$0000,$0BD0,$17E8,$1FF8,$0000
smilienick3:
         DC.W   $0A50,$13C8,$1C38,$0000,$2814,$0FF0,$300C,$0000
         DC.W   $2004,$3FFC,$4002,$0000,$4004,$FFFD,$8003,$0000
         DC.W   $0001,$7FFC,$8003,$0000,$8005,$FFFC,$0003,$0000
         DC.W   $8001,$FFF8,$0007,$0000,$0009,$7FF8,$8007,$0000
         DC.W   $4012,$FFF1,$800F,$0000,$2EFE,$2A50,$5BDE,$0420
         DC.W   $166C,$1E70,$2FFC,$0000,$0870,$1188,$1FF8,$0000
smilienick4:
         DC.W   $0A50,$13C8,$1C38,$0000,$2814,$0FF0,$300C,$0000
         DC.W   $2004,$3FFC,$4002,$0000,$4004,$FFFD,$8003,$0000
         DC.W   $0001,$7FFC,$8003,$0000,$8005,$FFFC,$0003,$0000
         DC.W   $8001,$FFF8,$0007,$0000,$0009,$7FF8,$8007,$0000
         DC.W   $4012,$FFF1,$800F,$0000,$30E6,$3FE0,$401E,$0000
         DC.W   $1C0C,$1C00,$23FC,$0000,$0A50,$1E78,$1BD8,$0420
smilienick5:
         DC.W   $0A50,$13C8,$1C38,$0000,$2664,$0FF0,$3E7C,$0000
         DC.W   $2E74,$3BDC,$4A52,$0420,$4004,$FFFD,$8003,$0000
         DC.W   $0181,$7FFC,$8183,$0000,$8815,$FFFC,$100B,$0000
         DC.W   $9C39,$FFF8,$0817,$0000,$0BD9,$7FF8,$87E7,$0000
         DC.W   $4012,$FFF1,$800F,$0000,$30E6,$3FE0,$401E,$0000
         DC.W   $1C0C,$1C00,$23FC,$0000,$0870,$1008,$1FF8,$0000
smilienick6:
         DC.W   $0240,$1FF8,$1A58,$0420,$2814,$0FF0,$300C,$0000
         DC.W   $2184,$3FFC,$4182,$0000,$4814,$FFFD,$900B,$0000
         DC.W   $1C39,$7FFC,$8813,$0000,$8BD5,$FFFC,$07E3,$0000
         DC.W   $8001,$FFF8,$0007,$0000,$0009,$7FF8,$8007,$0000
         DC.W   $4012,$FFF1,$800F,$0000,$30E6,$3FE0,$401E,$0000
         DC.W   $1C0C,$1C00,$23FC,$0000,$0870,$1008,$1FF8,$0000
smilienick7:
         DC.W   $0A50,$13C8,$1DB8,$0000,$2814,$0FF0,$381C,$0000
         DC.W   $2BD4,$3FFC,$47E2,$0000,$4004,$FFFD,$8003,$0000
         DC.W   $0001,$7FFC,$8003,$0000,$8005,$FFFC,$0003,$0000
         DC.W   $8001,$FFF8,$0007,$0000,$0009,$7FF8,$8007,$0000
         DC.W   $4012,$FFF1,$800F,$0000,$30E6,$3FE0,$401E,$0000
         DC.W   $1C0C,$1C00,$23FC,$0000,$0870,$1008,$1FF8,$0000
smilienick8:
         DC.W   $0BD0,$17E8,$1FF8,$0000,$2814,$0FF0,$300C,$0000
         DC.W   $2004,$3FFC,$4002,$0000,$4004,$FFFD,$8003,$0000
         DC.W   $0001,$7FFC,$8003,$0000,$8005,$FFFC,$0003,$0000
         DC.W   $8001,$FFF8,$0007,$0000,$0009,$7FF8,$8007,$0000
         DC.W   $4012,$FFF1,$800F,$0000,$30E6,$3FE0,$401E,$0000
         DC.W   $1C0C,$1C00,$23FC,$0000,$0870,$1008,$1FF8,$0000

smiliezwinker1:
         DC.W   $0A50,$13C8,$1C38,$0000,$2814,$0FF0,$300C,$0000
         DC.W   $2004,$3FFC,$4002,$0000,$4454,$FFDD,$8E23,$0000
         DC.W   $0A71,$7BDC,$8A53,$0420,$8005,$FFFC,$000B,$0000
         DC.W   $8991,$FFF8,$118F,$0000,$1429,$77E8,$981F,$0000
         DC.W   $4AF2,$EBD1,$9C3F,$0000,$37E6,$37E0,$4FFE,$0000
         DC.W   $1A0C,$1A00,$25FC,$0000,$0870,$1008,$1FF8,$0000
smiliezwinker2:
         DC.W   $0A50,$13C8,$1C38,$0000,$2814,$0FF0,$300C,$0000
         DC.W   $2004,$3FFC,$4002,$0000,$4454,$FFDD,$8E23,$0000
         DC.W   $0A21,$7B8C,$8A73,$0400,$8015,$FFFC,$000B,$0000
         DC.W   $8989,$FFE8,$119F,$0000,$1439,$77E8,$981F,$0000
         DC.W   $4ABA,$EB91,$9C7F,$0000,$37E6,$37E0,$4FFE,$0000
         DC.W   $1A0C,$1A00,$25FC,$0000,$0870,$1008,$1FF8,$0000
smiliebroesel1:
	 dc.w	$0A52,$53CA,$1C18,$0000,$2814,$0DF1,$300C,$0000
	 dc.w	$A004,$BFFC,$4002,$0000,$4424,$FFFD,$8E73,$0000
	 dc.w	$0A51,$7BDC,$8A53,$0420,$0005,$7FFC,$0003,$0000
	 dc.w	$8181,$FFF8,$0187,$0000,$1428,$77E8,$981E,$0000
	 dc.w	$4FF2,$EFF1,$9FFF,$0000,$B7E6,$B7E0,$4FFE,$0000
	 dc.w	$1A0C,$9A01,$25FC,$0000,$0854,$100C,$1BD8,$0000
smiliebroesel2:
	dc.w	$0010,$1180,$B411,$0000,$2814,$0DF0,$300E,$0000
	dc.w	$2004,$3F7C,$4000,$0000,$0424,$BFFC,$8E72,$0000
	dc.w	$0A51,$7BDC,$8A53,$0420,$0004,$7FFC,$0002,$0000
	dc.w	$8181,$DFF8,$0185,$0000,$0008,$7FF8,$0006,$0000
	dc.w	$47E2,$6FF1,$1FFB,$0000,$3EF6,$3EF0,$4EFF,$0000
	dc.w	$0FE4,$0FE0,$27F4,$0000,$0854,$100C,$BB59,$0000
smiliebroesel3:
	dc.w	$4014,$1180,$5414,$0000,$A815,$0DF0,$A005,$0000
	dc.w	$2004,$3F7C,$4000,$0000,$0424,$AFF4,$8E72,$0000
	dc.w	$0E71,$7AD8,$8A53,$0420,$0004,$1BF4,$0002,$0000
	dc.w	$8181,$D7F8,$0185,$0000,$0000,$7F50,$0006,$0000
	dc.w	$4762,$4F71,$1F7B,$0000,$3CF6,$3CF0,$4CFE,$0000
	dc.w	$8FF6,$0FF0,$AFF6,$0000,$0050,$1008,$1358,$0000
smiliebroesel4:
	dc.w	$0090,$8080,$8410,$0000,$0D44,$0D42,$0006,$0000
	dc.w	$093C,$093C,$4000,$0000,$2420,$AE70,$8E72,$0000
	dc.w	$5AD9,$5EF8,$8A53,$0420,$1B64,$1B64,$0000,$0000
	dc.w	$55E8,$55E8,$0180,$0000,$2B50,$2B50,$0002,$0000
	dc.w	$4760,$4F70,$1F78,$0000,$1CF4,$1CF0,$4CF4,$0000
	dc.w	$0F74,$0F71,$0F75,$0000,$0050,$8008,$8258,$0000
smiliebroesel5:
	dc.w	$0010,$2001,$2491,$0000,$0000,$0000,$0540,$0000
	dc.w	$0000,$0000,$0824,$0000,$0420,$0C30,$2C32,$0000
	dc.w	$0460,$0460,$0468,$0000,$0000,$0000,$1A24,$0000
	dc.w	$0180,$0180,$41A8,$0000,$0000,$0000,$2112,$0000
	dc.w	$0760,$0F60,$5F60,$0000,$04F4,$04F0,$14F4,$0000
	dc.w	$0D70,$2D72,$2D72,$0000,$0000,$0000,$0200,$0000
smiliebroesel6:
	dc.w	$0000,$0000,$0000,$0000,$0100,$0000,$0100,$0000
	dc.w	$0804,$0000,$0804,$0000,$2420,$0C20,$2C20,$0000
	dc.w	$0468,$0460,$0468,$0000,$1000,$0000,$1000,$0000
	dc.w	$0100,$0100,$0100,$0000,$2010,$0000,$2010,$0000
	dc.w	$0360,$0360,$0360,$0000,$14B0,$04B0,$14B0,$0000
	dc.w	$0460,$0460,$0460,$0000,$0000,$0000,$0000,$0000
smiliebroesel7:
	dc.w	$0000,$0100,$0100,$0000,$0000,$0002,$0002,$0000
	dc.w	$0000,$0000,$0000,$0000,$0420,$0420,$0420,$0000
	dc.w	$0440,$0440,$0440,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0140,$4144,$4144,$0000,$0490,$0490,$0490,$0000
	dc.w	$0540,$0540,$0540,$0000,$0000,$0000,$0000,$0000
smiliebroesel8:
	blk.w	12*8,0

smilieschleim1:
	dc.w	$0000,$0000,$0000,$0000,$0B50,$13C8,$1C38,$0000
	dc.w	$2914,$0FF0,$300C,$0000,$200C,$3FFC,$4002,$0000
	dc.w	$4024,$FBFD,$8E73,$0000,$0A51,$7BDC,$8A53,$0420
	dc.w	$8825,$FFFC,$0003,$0000,$8189,$FFF8,$0187,$0000
	dc.w	$0421,$77E8,$981F,$0000,$CDF3,$6DF0,$9FFF,$0000
	dc.w	$17E6,$97E1,$EFFF,$0000,$2A0C,$4A02,$75FE,$0000
smilieschleim2:
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0B50,$13C8,$1C38,$0000,$2914,$0FF0,$300C,$0000
	dc.w	$211C,$3FFC,$4002,$0000,$6424,$FFFD,$8E73,$0000
	dc.w	$0A15,$7BDC,$8A53,$0420,$8865,$FFFC,$0003,$0000
	dc.w	$81A9,$FFF8,$0187,$0000,$0139,$7FF8,$8007,$0000
	dc.w	$43D3,$7FF0,$856F,$0000,$95E7,$15E0,$EFFF,$0000
smilieschleim3:
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0B50,$03C0,$0C30,$0000
	dc.w	$0B10,$2FE4,$301C,$0000,$393C,$7FFE,$4002,$0000
	dc.w	$6C66,$7FFC,$0E32,$0000,$6B14,$FBDD,$8A53,$0420
	dc.w	$AC64,$FFFD,$0003,$0000,$E5A9,$FFF8,$0187,$0000
	dc.w	$1039,$7EF8,$8107,$0000,$4B13,$7BB0,$856F,$0000
smilieschleim4:
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0760,$03C0,$0420,$0000,$1910,$0FE8,$1018,$0000
	dc.w	$2130,$1FF4,$200C,$0000,$2C60,$7FFA,$4636,$0000
	dc.w	$6B16,$F9CD,$8A53,$0420,$2864,$FBFD,$8403,$0000
	dc.w	$E5A8,$FFF9,$0107,$0000,$0039,$3EF8,$C107,$0000
smilieschleim5:
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0340,$0520,$06E0,$0000
	dc.w	$0D20,$07F0,$0810,$0000,$3538,$1FF4,$200C,$0000
	dc.w	$2C68,$7FFA,$4236,$0000,$6F1E,$FBCD,$8A53,$0420
	dc.w	$3840,$FBC9,$8437,$0000,$E5A8,$FFF9,$0107,$0000
smilieschleim6:
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0240,$03C0,$0000,$0D80,$0590,$0A70,$0000
	dc.w	$3D38,$1FF4,$200C,$0000,$2C68,$FFFB,$C237,$0000
	dc.w	$E33F,$77CC,$8A53,$0420,$3940,$FBC9,$8437,$0000
smilieschleim7:
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0400,$0810,$0FF0,$0000,$3DB8,$4FF6,$700E,$0000
	dc.w	$2EE0,$EDE3,$D21F,$0000,$E51F,$65EC,$9E53,$0020
smilieschleim8:
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0500,$0810,$0FF0,$0000
	dc.w	$7AFE,$8AF1,$F50F,$0000,$27F6,$E5A1,$DA5F,$0000
smilieschleim9:
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0D10,$1008,$1FF8,$0000,$70AE,$80A1,$FF5F,$0000
smilieschleim10:
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$2FB4,$D04B,$FFFF,$0000
smilieschleim11:
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$2D4A,$F3F7,$FFFF,$0000
smilieschleim12:
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$1050,$1050,$0000
smilieheul1:
	dc.w	$0A50,$13C8,$1C38,$0000,$2814,$0FF0,$300C,$0000
	dc.w	$2004,$3FFC,$4002,$0000,$4A54,$FFFD,$8663,$0000
	dc.w	$0241,$7BDC,$8A53,$0420,$8005,$FFFC,$0003,$0000
	dc.w	$8185,$FFFC,$0183,$0000,$0009,$7FF8,$8007,$0000
        dc.w	$4242,$EBD1,$9C3F,$0000,$37E6,$37E0,$4FFE,$0000
        dc.w	$1A0C,$1A00,$25FC,$0000,$0870,$1008,$1FF8,$0000
smilieheul2:
	dc.w	$0A50,$13C8,$1C38,$0000,$2814,$0FF0,$300C,$0000
	dc.w	$2004,$3FFC,$4002,$0000,$4A54,$FFFD,$8663,$0000
	dc.w	$0421,$7DBC,$8C33,$0240,$8005,$FFFC,$0003,$0000
	dc.w	$8185,$FFFC,$0183,$0000,$0009,$7FF8,$8007,$0000
	dc.w	$4012,$FFF1,$800F,$0000,$33C6,$37E0,$4FFE,$0000
	dc.w	$1A0C,$1A00,$25FC,$0000,$0870,$1008,$1FF8,$0000
smilieheul3:
	dc.w	$0A50,$13C8,$1C38,$0000,$2814,$0FF0,$300C,$0000
	dc.w	$2004,$3FFC,$4002,$0000,$4A54,$FFFD,$8663,$0000
	dc.w	$0421,$7DBC,$8C33,$0240,$8005,$FFFC,$0003,$0000
	dc.w	$8181,$FFF8,$0187,$0000,$0009,$7FF8,$8007,$0000
	dc.w	$45B2,$FFF1,$83CF,$0000,$32C6,$3FE0,$443E,$0000
	dc.w	$1C0C,$1C00,$23FC,$0000,$0870,$1008,$1FF8,$0000

anitab2a:
; UNDO 2

	dc.l smiliebroesel1
	dc.l smiliebroesel1
	dc.l smiliebroesel1
	dc.l smiliebroesel1
	dc.l smiliebroesel2
	dc.l smiliebroesel2
	dc.l smiliebroesel2
	dc.l smiliebroesel2
	dc.l smiliebroesel3
	dc.l smiliebroesel3
	dc.l smiliebroesel3
	dc.l smiliebroesel3
	dc.l smiliebroesel4
	dc.l smiliebroesel4
	dc.l smiliebroesel4
	dc.l smiliebroesel4
	dc.l smiliebroesel5
	dc.l smiliebroesel5
	dc.l smiliebroesel5
	dc.l smiliebroesel5
	dc.l smiliebroesel6
	dc.l smiliebroesel6
	dc.l smiliebroesel6
	dc.l smiliebroesel6
	dc.l smiliebroesel7
	dc.l smiliebroesel7
	dc.l smiliebroesel7
	dc.l smiliebroesel7
	dc.l smiliebroesel8
	dc.l smiliebroesel8
	dc.l smiliebroesel8
	dc.l smiliebroesel8
	dc.l	-1	

anitab2b:
; UNDO 3
	dc.l smilieschleim1
	dc.l smilieschleim1
	dc.l smilieschleim1
	dc.l smilieschleim1
	dc.l smilieschleim2
	dc.l smilieschleim2
	dc.l smilieschleim2
	dc.l smilieschleim2
	dc.l smilieschleim3
	dc.l smilieschleim3
	dc.l smilieschleim3
	dc.l smilieschleim3
	dc.l smilieschleim4
	dc.l smilieschleim4
	dc.l smilieschleim4
	dc.l smilieschleim4
	dc.l smilieschleim5
	dc.l smilieschleim5
	dc.l smilieschleim5
	dc.l smilieschleim5
	dc.l smilieschleim6
	dc.l smilieschleim6
	dc.l smilieschleim6
	dc.l smilieschleim6
	dc.l smilieschleim7
	dc.l smilieschleim7
	dc.l smilieschleim7
	dc.l smilieschleim7
	dc.l smilieschleim8
	dc.l smilieschleim8
	dc.l smilieschleim8
	dc.l smilieschleim8
	dc.l smilieschleim9
	dc.l smilieschleim9
	dc.l smilieschleim9
	dc.l smilieschleim9
	dc.l smilieschleim10
	dc.l smilieschleim10
	dc.l smilieschleim10
	dc.l smilieschleim10
	dc.l smilieschleim11
	dc.l smilieschleim11
	dc.l smilieschleim11
	dc.l smilieschleim11
	dc.l smilieschleim12
	dc.l smilieschleim12
	dc.l smilieschleim12
	dc.l smilieschleim12
	dc.l smiliebroesel8
	dc.l smiliebroesel8
	dc.l smiliebroesel8
	dc.l smiliebroesel8
	dc.l -1
anitab2c:
; UNDO 4
        dc.l smilieheul1
        dc.l smilieheul1
        dc.l smilieheul1
        dc.l smilieheul1
        dc.l smilieheul2
        dc.l smilieheul2
        dc.l smilieheul2
        dc.l smilieheul2
        dc.l smilieheul3
        dc.l smilieheul3
        dc.l smilieheul3
        dc.l smilieheul3
        dc.l -1


anitab:
        dc.l smiliezunge1
        dc.l smiliezunge1
        dc.l smiliezunge1
        dc.l smiliezunge1
        dc.l smiliezunge2
        dc.l smiliezunge2
        dc.l smiliezunge2
        dc.l smiliezunge2
        dc.l smiliezunge3
        dc.l smiliezunge3
        dc.l smiliezunge3
        dc.l smiliezunge3
        dc.l smiliezunge4
        dc.l smiliezunge4
        dc.l smiliezunge4
        dc.l smiliezunge4
        dc.l smiliezunge5
        dc.l smiliezunge5
        dc.l smiliezunge5
        dc.l smiliezunge5
        dc.l smiliezunge5
        dc.l smiliezunge5
        dc.l smiliezunge5
        dc.l smiliezunge5
        dc.l smiliezunge5
        dc.l smiliezunge5
        dc.l smiliezunge5
        dc.l smiliezunge5
        dc.l smiliezunge5
        dc.l smiliezunge5
        dc.l smiliezunge5
        dc.l smiliezunge5
        dc.l smiliezunge5
        dc.l smiliezunge5
        dc.l smiliezunge4
        dc.l smiliezunge4
        dc.l smiliezunge4
        dc.l smiliezunge4
        dc.l smiliezunge3
        dc.l smiliezunge3
        dc.l smiliezunge3
        dc.l smiliezunge3
        dc.l smiliezunge2
        dc.l smiliezunge2
        dc.l smiliezunge2
        dc.l smiliezunge2
        dc.l smiliezunge1
        dc.l smiliezunge1
        dc.l smiliezunge1
        dc.l smiliezunge1
        dc.l smilie
        dc.l -1

anitab2:
        dc.l smilieoh1
        dc.l smilieoh1
        dc.l smilieoh1
        dc.l smilieoh1
        dc.l smilieoh2
        dc.l smilieoh2
        dc.l smilieoh2
        dc.l smilieoh2
        dc.l smilieoh3
        dc.l smilieoh3
        dc.l smilieoh3
        dc.l smilieoh3
        dc.l smilieoh4
        dc.l smilieoh4
        dc.l smilieoh4
        dc.l smilieoh4
        dc.l smilieoh5
        dc.l smilieoh5
        dc.l smilieoh5
        dc.l smilieoh5
        dc.l smilieoh6
        dc.l smilieoh6
        dc.l smilieoh6
        dc.l smilieoh6
        dc.l smilieoh6
        dc.l smilieoh6
        dc.l smilieoh6
        dc.l smilieoh6
        dc.l smilieoh6
        dc.l smilieoh6
        dc.l -1

anitab3:
; fÅrs Nicken
        dc.l smilie
        dc.l smilie
        dc.l smilienick1
        dc.l smilienick1
        dc.l smilienick1
        dc.l smilienick1
        dc.l smilienick2
        dc.l smilienick2
        dc.l smilienick2
        dc.l smilienick2
        dc.l smilienick3
        dc.l smilienick3
        dc.l smilienick3
        dc.l smilienick3
        dc.l smilienick4
        dc.l smilienick4
        dc.l smilienick4
        dc.l smilienick4
        dc.l smilienick3
        dc.l smilienick3
        dc.l smilienick3
        dc.l smilienick3
        dc.l smilienick2
        dc.l smilienick2
        dc.l smilienick2
        dc.l smilienick2
        dc.l smilienick1
        dc.l smilienick1
        dc.l smilienick1
        dc.l smilienick1
        dc.l smilie
        dc.l smilie
        dc.l smilie
        dc.l smilie
        dc.l smilienick5
        dc.l smilienick5
        dc.l smilienick5
        dc.l smilienick5
        dc.l smilienick6
        dc.l smilienick6
        dc.l smilienick6
        dc.l smilienick6
        dc.l smilienick7
        dc.l smilienick7
        dc.l smilienick7
        dc.l smilienick7
        dc.l smilienick8
        dc.l smilienick8
        dc.l smilienick8
        dc.l smilienick8
        dc.l smilienick7
        dc.l smilienick7
        dc.l smilienick7
        dc.l smilienick7
        dc.l smilienick6
        dc.l smilienick6
        dc.l smilienick6
        dc.l smilienick6
        dc.l smilienick5
        dc.l smilienick5
        dc.l smilienick5
        dc.l smilienick5
        dc.l smilie
        dc.l smilie
        dc.l smilie
        dc.l smiliezwinker1
        dc.l smiliezwinker1
        dc.l smiliezwinker1
        dc.l smiliezwinker1
        dc.l smiliezwinker2
        dc.l smiliezwinker2
        dc.l smiliezwinker2
        dc.l smiliezwinker2
        dc.l smiliezwinker1
        dc.l smiliezwinker1
        dc.l smiliezwinker1
        dc.l smiliezwinker1
        dc.l smilie
        dc.l -1

undotab:        dc.l anitab2
                dc.l anitab2a
                dc.l anitab2b
                dc.l anitab2c

statustext:     dc.b "LEVEL: 00   MOVES: 0000  PUSHES: 0000",0
                even
gameovertxt:    dc.b "HOW IS IT POSSIBLE TO NEED 9999 (!!!)",13
                DC.B "MOVES ? YOU'RE SUCH A STUPID LAMER !",0

defaultname:    dc.b "MR. NO-NAME",0
                even

keytab:         dc.b 1,$4b,$48,$4d,$50,$4e,$4a,$61,$3b,$3c,$3d,$32
		if diskversion=0
		dc.b $44
		endif
		dc.b -1

                even

                      
menutext:       dc.b    " STARTING LEVEL 01  "
                dc.b    "  ENTER YOUR NAME   "
                dc.b    "   SEE HIGHSCORES   "
                dc.b    "     START GAME     "  

enternametext:  dc.b    "PLEASE ENTER NAME ! "

geschaffttext:  DC.B    "  CONGRATULATIONS!  "
                DC.B    " YOU HAVE COMPLETED "
                DC.B    "      LEVEL 01      "
                DC.B    "   WITH A SCORE OF  "
                DC.B    "   0000 MOVES AND   "
                DC.B    "     0000 PUSHES.   "
                DC.B    "SORRY! NO HIGHSCORE!"
                DC.B    "PRESS FIRE OR SPACE!"
newhightext:    DC.B    "GOOD! NEW HIGHSCORE!"
                EVEN            

colortab:       dc.w    $321,$543,$765
                dc.w    $123,$345,$567
                dc.w    $223,$445,$667
                dc.w    $323,$545,$767
                dc.w    $322,$544,$766
                dc.w    $230,$450,$670
                dc.w    $333,$555,$777
                dc.w    $330,$550,$770

menupalette:    dc.w    $000,$023,$045,$067,$000,$320,$540,$760
                dc.w    $000,$232,$454,$676,$000,$333,$555,$777

eingabepalette: dc.w    $000,$300,$500,$700,$000,$003,$005,$007
                blk.w   8,0


routinen:       dc.l endgame
                dc.l cursorleft
                dc.l cursorup
                dc.l cursorright
                dc.l cursordown
                dc.l newlevel
                dc.l newlevel2
                dc.l restartlevel
                dc.l newmuzak1
                dc.l newmuzak2
                dc.l newmuzak3
                dc.l muzakaus
		if   diskversion=0
		dc.l completed
		endif

scrolltext:	DC.B	"WELCOME TO THE WORLD OF SOKO BAN!   "
		DC.B	"(READ UNTIL THE END FOR INSTRUCTIONS!)      "
		DC.B	"THIS IS MY FAVOURITE GAME ON EVERY COMPUTER "
		DC.B	"SO I THOUGHT I HAVE TO CONVERT IT TO MY BELOVED"
		DC.B	" ATARI. FIRST I JUST HAD AN UGLY MS-DOS VERSION"
		DC.B	" WITH CGA-GRAPHICS (EVER SEEN THESE SHITTY"
		DC.B	" GRAPHICS ? AAARRRRGGHH WHAT FUCKING BAD "
		DC.B	"COLORS!). I PLAYED THIS GAME EVERY FREE HOUR"
		DC.B	" I HAD ON OUR MS-DOS MACHINES IN SCHOOL. BUT"
		DC.B	" AS I HAD TO LEAVE SCHOOL IN 1989 I HAD NO"
		DC.B	" POSSIBILITY TO PLAY THIS GREAT GAME. I"
		DC.B	" TRANSFERRED IT TO AN ATARI DISK AND PLAYED IT"
		DC.B	" WITH PC-DITTO. YOU CAN'T IMAGINE HOW SLOW IT"
		DC.B	" WAS (I THINK 80 VBL'S PER MOVE!). SO I THOUGHT"
		DC.B	" ABOUT OTHER POSSIBILITIES TO PLAY THIS GAME."
		DC.B	" FIRST IDEA WAS TO BUY A MS-DOS COMPUTER,"
		DC.B	" BUT I HAD NO MONEY AND I ALSO THOUGHT (AND"
		DC.B	" STILL THINK) THAT MS-DOS COMPUTERS ARE PURE"
		DC.B	" BULLSHIT. SECOND IDEA WAS TO CONVERT IT FOR"
		DC.B	" MY ST. THIS WAS CHEAP, GOOD IDEA. I ASKED"
		DC.B	" SLIME TO PAINT SOME GRAPHICS FOR THIS GAME"
		DC.B	" AND HE WAS FASCINATED TOO. AFTER THREE DAYS"
		DC.B	" OF CODING A PLAYABLE VERSION WAS READY. I"
		DC.B	" CONVERTED ALL LEVELS FROM THE ORIGINAL MS-DOS"
		DC.B	" VERSION BY SPECTRUM HOLOBYTE. WE PLAYED IT"
		DC.B	" NIGHT AND DAY. FOR ONE YEAR (!!!) THERE WAS"
		DC.B	" A PLAYABLE BUT NOT 100% READY VERSION ON MY"
		DC.B	" HARDDISK (NO HIGHSCORES, NO INTRO,...) SO I"
		DC.B	" COMPLETED THIS GAME ON 30-05-90.    OH! I"
		DC.B	" NEARLY FORGOT TO MENTION ALL POSSIBLE KEYS"
		DC.B	" YOU CAN PRESS IN THIS GAME...   IN THIS"
		DC.B	" INTRO YOU CAN PRESS 'SPACE' OR 'FIRE' TO GET"
		DC.B	" IN THE GAME-MENU WHERE YOU CAN ENTER YOUR NAME"
		DC.B	", SELECT LEVEL, SEE HIGHSCORES AND START THE"
		DC.B	" GAME.   YOU CAN LEAVE THE GAME AND GO BACK TO"
		DC.B	" SYNTAX-TERROR-MAINMENU BY PRESSING 'ESC'. WHEN"
		DC.B	" YOU ARE QUITTING THE GAME, PLEASE REMOVE WRITE"
		DC.B	"-PROTECT ON THE DISK TO SAVE HIGHSCORES."
		dc.b	" (THE SCORES WILL JUST BE SAVED IF YOU"
		DC.B	" ACHIEVED A NEW HIGHSCORE).   "
		DC.B	" IN THE MENU YOU CAN USE ARROWKEYS OR JOYSTICK"
		DC.B	" UP AND DOWN TO SELECT. CHOOSE LEVEL BY MOVING"
		DC.B	" LEFT OR RIGHT. SELECT DESIRED POINT BY PRESS"
		DC.B	"ING 'RETURN', 'SPACE' OR 'FIRE'.    WHEN YOU ARE PLAYING"
		DC.B	" THE GAME, YOU CAN PRESS THE FOLLOWING KEYS:"
		DC.B	" 'UNDO' TO RESTART LEVEL, 'F1' TO 'F3' FOR"
		DC.B	" DIFFERENT MUSICS, 'M' TO TURN SOUND OFF,"
		DC.B	" '+' AND '-' ON THE NUMERIC KEYPAD TO INCREASE"
		DC.B	" AND DECREASE LEVEL, 'ESC' TO ABANDON GAME AND"
		DC.B	" GO BACK TO THE INTRO (THIS LITTLE SCREEN HERE)"
		DC.B	"  THAT'S ALL FOR THE KEYS! AS PROMISED HERE ARE"
		DC.B	" THE INSTRUCTIONS FOR SOKO BAN: YOU CONTROL"
		DC.B	" MR.SMILEY (EITHER WITH ARROWS OR JOYSTICK"
		DC.B	" IN PORT 1). MR.SMILEY HAS TO PUSH ALL"
		DC.B	" BROWN BOXES IN HIS HOUSE ONTO THEIR BLUE"
		DC.B	" DESTINATION FIELDS. MR.SMILEY JUST CAN PUSH"
		DC.B	" ONE BOX AT THE SAME TIME, SO BE CAREFUL WHERE"
		DC.B	" YOU PUSH YOUR BOXES AT.  YOU HAVE UNLIMITED"
		DC.B	" TIME FOR EACH LEVEL BUT AFTER 9999 MOVES, THE"
		DC.B	" GAME IS OVER. THE FIRST LEVELS ARE VERY EASY"
		DC.B	" BUT AFTER SOME LEVELS THE GAME BECOMES VERY"
		DC.B	" HARD (WE NEVER FINISHED LEVEL 50!!!)."
		DC.B	" THERE'S A LEVEL YOU CAN'T SOLVE! WE DON'T"
		DC.B	" SAY WHICH LEVEL THIS IS! BUT IT WASN'T"
		DC.B	" OUR FAULT, YOU CAN'T SOLVE THIS LEVEL ON"
		DC.B	" THE PC-VERSION EITHER!        "
		DC.B	"        THAT'S ALL FOR THE INSTRUCTIONS. BY"
		DC.B	" THE WAY THE BUBBLES ABOVE ARE FROM ES (TEX)"
		DC.B	" AS ALWAYS (ALSO THE SMALL UNION-LOGO)....." 
		DC.B    "        SLIME HAS PAINTED SOME"
		DC.B	" MORE SMILEYS BUT I WAS JUST TOO LAZY TO PUT"
		DC.B	" THEM IN THIS GAME.  WE NEVER WANTED TO SELL"
		DC.B	" THIS GAME, WE JUST PROGRAMMED IT FOR THIS"
		DC.B	" DEMO, SO DON'T EXPECT A COMMERCIAL GAME. BUT"
		DC.B	" IT'S REALLY THE BEST GAME EVER APPEARED IN"
		DC.B	" ANY DEMO (NOT SUCH A SHIT GAME LIKE IN TNT-"
		DC.B	"CREW'S FNIL-DEMO WHERE YOU JUST HAVE TO SHOOT"
		DC.B	" AMIGA-LOGOS!). THIS IS A REAL PLAYABLE GAME"
		DC.B	" AND IT COSTS YOU  N O T H I N G....  "
		DC.B	" (IF YOU WANT TO DONATE THE WORK FOR THIS"
		DC.B	" GAME BE FAIR AND SEND US SOME MONEY!)  "
		DC.B	"   THERE WILL BE MORE GAMES BY DELTA FORCE"
		DC.B	" IN THE NEAR FUTURE ('MATCH IT!' IS ONE"
		DC.B	" EXAMPLE). I WILL CONTINUE CODING PD-GAMES,"
		DC.B	" BECAUSE I HATE BEING UNDER CONTRACT OF ANY"
		DC.B	" SOFTWARE-COMPANY AND BEING ALWAYS KICKED"
		DC.B	" IN MY LAZY ASS WHEN I'M TOO SLOW. I WANT"
		DC.B	" TO BE MY OWN BOSS. ANOTHER REASON FOR"
		DC.B	" WRITING SUCH PD-GAMES IS THAT I'M JUST"
		DC.B	" CODING TO HAVE FUN AND NOT TO MAKE BIG"
		DC.B	" PROFIT. I CAN CODE ON MY OWN AND NOBODY"
		DC.B	" CAN SAY WHAT I HAVE TO WRITE.  PERHAPS"
		DC.B	" I WILL WRITE A COMMERCIAL GAME, BUT FIRST"
		DC.B	" I'LL WRITE ANOTHER GAME WHEN THIS DEMO IS"
		DC.B	" READY."
		DC.B	"     ENOUGH FOR THIS"
		DC.B	" SCROLLER HERE. LAST BUT NOT LEAST ALL MY"
		DC.B	" REGARDS TO THE PROGRAMMER OF SOKO BAN:"
		DC.B	" FARAH SOEBRATA.  IF"
		DC.B	" YOU WANT TO KNOW WHAT SOKO BAN MEANS, I"
		DC.B	" CAN'T HELP YOU. I DON'T KNOW IT EITHER!"
		DC.B	" IF ANY JAPANESE GUY CAN TRANSLATE IT"
		DC.B	" PLEASE LET ME KNOW!      BYE FROM NEW MODE"
		DC.B	" OF DELTA FORCE. LET'S WRAP."
		DC.B	"                                        "
		DC.B	"                 ",0


 
highzeile0:	dc.b	"GLORIOUS GAMBLERS!"
highzeile1:	dc.b	"       SOKOBAN HIGHSCORE-TABLE          ",13
		dc.b	"  (USE ARROWS OR JOYSTICK TO SCROLL)    ",13
		dc.b	"LV PLAYERS NAME             PUSHES MOVES",13
		dc.b	"----------------------------------------",0

savemessage:	dc.b	"SAVING HIGHSCORES!"
wpmessage1:	dc.b	"CANT SAVE HIGHSCORES"
wpmessage2:	dc.b	"REMOVE WRITEPROTECT!"
wpmessage3:	dc.b	" SPACE TO TRY AGAIN "
wpmessage4:	dc.b	" ESC TO CANCEL SAVE "
                even


exitfrommenu:	blk.w	1,0
highscoremade:	blk.w	1,0
mempos:		blk.l	1,0
textpos:	blk.l	1,0
scrollzeichen:	blk.w	1,0
colortab2:      blk.w 	3*8,0
balkenpos:      blk.w   1,0
hblonoff:       blk.w 	1,0
level:          blk.b 	306,0
hblcount:       blk.w 	1,0
delay:          blk.w 	1,0
currentlevel:   blk.w 	1,0
levelpointer:   blk.l 	1,0
moves:          blk.w 	1,0
pushes:         blk.w 	1,0
restorebuff:    blk.l 	100,0
clearpos:       blk.l 	1,0
nochda:         blk.w 	1,0
hbl_buff:       blk.w 	10,0
endfeldanz:     blk.w 	1,0
endfeldtab:     blk.w 	100,0
man_x:          blk.w 	1,0
man_y:          blk.w 	1,0
leerfeld:       blk.l 	8,0
man_xs:         blk.w 	1,0
man_ys:         blk.w 	1,0
counter:        blk.w 	1,0
hblpointer3:    blk.l 	1,0
anipos:         blk.l 	1,0
anipos2:        blk.l 	1,0
anipos3:        blk.l 	1,0
namebuff:       blk.b 	22,0
;
databuff:	blk.b   28526,0
daten=databuff			; Leveldaten
music1=daten+15300
music2=music1+2928
music3=music2+3008
font=music3+4016
hblcolors=font+2880
;
highy:		blk.w	 1,0
clrpos1:        blk.l    1,0             ; dort wird Unionlogo gelîscht
clrpos2:        blk.l    1,0
clr2pos1:       blk.l    1,0             ; dort wird DFlogo gelîscht
clr2pos2:       blk.l    1,0
e:
