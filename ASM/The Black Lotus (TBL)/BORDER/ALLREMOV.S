*
*  Ok, h„r har vi en lite kod som helt systemv„nligt tar bort ”vre
* och nedre bordern p† en STE.
*
* Man kan ha blittern p† samtidigt som den h„r koden „r ig†ng!!!
*
* Placera programmet i AUTO-foldern!
*
* Skriven av Christian Dahl, FidoNet 2:206/215.8
*                            FujiNet 7:100/106
*
*            Fotbollsv. 11
*            735 37  Surahammar
*            Sweden
*
*
* Kontakta mig g„rna!
*

start:
	move.l	a7,a5
	move.l	4(a5),a5
	move.l	$c(a5),d0
	add.l	$14(a5),d0
	add.l	$1c(a5),d0
	add.l	#$100,d0
	move.l	d0,-(sp)
	move.l	a5,-(sp)
	move.w	#0,-(sp)
	move.w	#$4a,-(sp)
	trap	#1			; Registrera programet s† att
	lea	12(sp),sp		; vi kan beg„ra minne...

	pea	info
	move.w	#9,-(sp)
	trap	#1		; Skriv ut infotexten
	addq.w	#6,sp

	move.w	#-1,(sp)
	move.w	#11,-(sp)
	trap	#13		; Ta reda p† shift-statusen
	addq.w	#4,sp
	and.w	#%10,d0
	bne.s	installeraej	; Om v„nster shift nertryckt installera ej!

	pea	border_kill
	move.w	#38,-(sp)
	trap	#14		; Starta ig†ng borderrutinen
	addq.w	#6,sp

	pea	maininfo
	move.w	#9,-(sp)
	trap	#1		; Skriv ut maininfotexten
	addq.w	#6,sp

	clr.w	-(sp)
	move.l	#3000+(160*273),-(sp)
	move.w	#$31,-(sp)
	trap	#1		; Exitera, men spara minnet
	illegal
installeraej:
	pea	abort
	move.w	#9,-(sp)
	trap	#1		; Skriv ut aborttexten
	addq.w	#6,sp

	clr.w	-(sp)
	trap	#1		; Avsluta och sl„pp minnet

border_kill:	; Installeringsrutinen s† att vi kan ta bort bordern
	lea	screen,a0
	move.w	#5460-1,d0
	move.l	#0,d1
rensask„rmdatan:		; Se till att sk„rmdatan „r tom
	move.l	d1,(a0)+
	move.l	d1,(a0)+
	dbra	d0,rensask„rmdatan

	dc.w	$a000
	move.l	a0,linea

	move.w	#-1,-(sp)
	pea	screen
	pea	screen
	move.w	#5,-(sp)	; S„tt upp nytt bildminne s† att vi kan
	trap	#14		; visa hela sk„rmen
	lea	12(sp),sp

	move.w	#$2700,sr	; Inga interupter vid installation

	move.l	$100.w,old0+2
	move.l	$104.w,old1+2	; Se till s† att inga andra interupter
	move.l	$108.w,old2+2	; kommer in och st”r
	move.l	$10c.w,old3+2
	move.l	$110.w,old4+2
	move.l	$11c.w,old7+2
	move.l	$124.w,old9+2
	move.l	$128.w,old10+2
	move.l	$12c.w,old11+2
	move.l	$130.w,old12+2
	move.l	$138.w,old14+2
	move.l	$13c.w,old15+2

	move.l	#level0,$100.w
	move.l	#level1,$104.w
	move.l	#level2,$108.w
	move.l	#level3,$10c.w
	move.l	#level4,$110.w
	move.l	#level7,$11c.w
	move.l	#level9,$124.w
	move.l	#level10,$128.w
	move.l	#level11,$12c.w
	move.l	#level12,$130.w
	move.l	#level14,$138.w
	move.l	#level15,$13c.w

	move.l	$70.w,oldvbl+2	; Installera min VBLrutin f”re systemets
	move.l	#vbl,$70.w	
	move.l	$118.w,oldkey+2	; Installera s† att vi s„nker priv p†
	move.l	#key,$118.w	; tangentbordshanteraren

	move.b	$fffffa1d.w,d0
	and.b	#%00001111,d0
	or.b	#%01110000,d0
	move.b	d0,timerCcontrol

	pea	lowhbl
	move.w	#8,-(sp)
	move.w	#255,-(sp)
	move.w	#1,-(sp)
	move.w	#31,-(sp)
	trap	#14		; Starta HBLen
	lea	12(sp),sp

	pea	timerA
	move.w	#7,-(sp)
	move.w	#255,-(sp)
	move.w	#0,-(sp)
	move.w	#31,-(sp)
	trap	#14		; Starta timerA
	lea	12(sp),sp

	move.w	#$2300,sr	; Ok, sl„pp p† interupterna igen
	rts

vbl:			; VBLen
	tst	laddaivblen
	beq.s	timerBv„ntarin”vreramen
	clr.b	$fffffa19.w
	clr.b	$fffffa1b.w
	move.b	#197,$fffffa21.w; V„nta in nedre ramen
	move.b	#8,$fffffa1b.w
	move.b	lowersync3(pc),lowersync
	move.b	$ffff8205.w,bildminne+1
	move.b	$ffff8207.w,bildminne+2
	move.b	$ffff8209.w,bildminne+3
	add.l	#160*29,bildminne
	move.b	bildminne+1(pc),$ffff8205.w
	move.b	bildminne+2(pc),$ffff8207.w
	move.b	bildminne+3(pc),$ffff8209.w
timerBv„ntarin”vreramen:
	move.w	#1,laddaivblen

	and.b	#%00001111,$fffffa1d.w
	move.b	#53,$fffffa23.w	; Synca timer C
	move.b	timerCcontrol(pc),$fffffa1d.w

	movem.l	a0/d0,-(sp)

	moveq	#0,d0
	move.b	$ffff8209.w,d0
	move.b	d0,lowersync2
	move.b	d0,lowersync
	add.w	#$20,d0
	move.b	d0,lowersync3
	move.b	$ffff8207.w,middlepic

	move.l	linea(pc),a0
	move.w	#273,-4(a0)	; ny sk„rmh”jd
	move.w	#272,-690(a0)
	move.w	#$1D,-42(a0)
	movem.l	(sp)+,a0/d0

oldvbl:	jmp	$12345678

lowhbl:				; HBLrutinen som tar bort nedre ramen
	move.w	#$2700,sr
	move.b	$ffff8a3c.w,blitterstatus
	clr.b	$ffff8a3c.w	; Pausa blittern ifall den arbetar
	movem.l d0-d1/a0-a1,-(sp)
	moveq	#99,d1
	move.w	#$fa21,a1
line:	move.w	#$c3,d0
	move.w	#$8209,a0
	clr.b	$fffffa19.w	; Ladda timer A med data
	move.b	#250,$fffffa1f.w	; 250
waitforhblreturn1:		; V„nta in n„st sista raden
	cmp.b	(a1),d0
	blo.s	waitforhblreturn1

	move.b	$ffff8209.w,d0
	add.b	#160,d0
v„ntainr„ttsk„rmoffset:		; V„nta in slutet p† sista raden
	cmp.b	(a0),d0
	bne.s	v„ntainr„ttsk„rmoffset
	clr.b	$ffff820a.w		; 60 Hz
	move.w	#5,d0
v„nta2:	dbra	d0,v„nta2
	move.b	#2,$ffff820a.w		; 50 Hz
	move.b	#4,$fffffa19.w	; Starta timer A
	clr.b	$fffffa1b.w
	move.b	#255,(a1)	; Ladda timer B med ny data
	move.b	#5,$fffffa1b.w	; Starta timer B f”r ”vre bordern
	movem.l (sp)+,d0-d1/a0-a1
	clr.w	laddaivblen
	bclr	#0,$fffffa0f.w
	move.b	blitterstatus(pc),$ffff8a3c.w
	rte

timerA:	move.b	$ffff8a3c.w,blitterstatus
	clr.b	$ffff8a3c.w	; Pausa blittern ifall den arbetar
	move.w	#$2700,sr
	clr.b	$fffffa19.w
	bclr	#5,$fffffa0f.w
	movem.l	d0/a0,-(sp)
	move.w	#$fa21,a0
	move.w	#52,d0
v„ntap†r„tttimerB:
	cmp.b	(a0),d0
	blo.s	v„ntap†r„tttimerB

magic	move.w	#32,d0
v„nta:	dbra	d0,v„nta

	clr.b	$ffff820a.w	; 60 Hz
	rept	15
	nop
	endr
	move.b	#2,$ffff820a.w	; 50 Hz
	clr.b	$fffffa1b.w
	clr.b	$fffffa19.w
	rept	8
	nop
	endr
	move.b	middlepic(pc),d0
	cmp.b	$ffff8207.w,d0
	bne.s	vilyckadestabort”vrebordern
	move.b	lowersync2(pc),d0
	cmp.b	$ffff8209.w,d0
	bne.s	vilyckadestabort”vrebordern
	move.b	#197,$fffffa21.w	; V„nta in nedre ramen, fast„n
	move.b	#8,$fffffa1b.w		; vi misslyckades med ”vre
	move.w	#$C3,line+2
	move.b	lowersync3(pc),lowersync
	move.b	$ffff8205.w,bildminne+1
	move.b	$ffff8207.w,bildminne+2
	move.b	$ffff8209.w,bildminne+3
	add.l	#160*29,bildminne
	move.b	bildminne+1(pc),$ffff8205.w
	move.b	bildminne+2(pc),$ffff8207.w
	move.b	bildminne+3(pc),$ffff8209.w
	bra.s	fanf”rs”kn„stag†ng
vilyckadestabort”vrebordern:
	move.b	lowersync3(pc),lowersync
	move.b	#197+29,$fffffa21.w	; V„nta in nedre ramen
	move.b	#8,$fffffa1b.w		; Vi lyckades med ”vre ramen!
	move.w	#$C3+29,line+2
fanf”rs”kn„stag†ng:
	movem.l	(sp)+,d0/a0
	move.b	blitterstatus(pc),$ffff8a3c.w
	rte

key:	move.w	#$2500,sr	; Tangentbordsinterupten
oldkey:	jmp	$12345678

level0:	move.w	#$2500,sr	; level 0
old0:	jmp	$12345678

level1:	move.w	#$2500,sr	; level 1
old1:	jmp	$12345678

level2:	move.w	#$2500,sr	; level 2
old2:	jmp	$12345678

level3:	move.w	#$2500,sr	; level 3
old3:	jmp	$12345678

level4:	move.w	#$2500,sr	; level 4
old4:	jmp	$12345678

level7:	move.w	#$2500,sr	; level 7
old7:	jmp	$12345678

level9:	move.w	#$2500,sr	; level 9
old9:	jmp	$12345678

level10:move.w	#$2500,sr	; level 10
old10:	jmp	$12345678

level11:move.w	#$2500,sr	; level 11
old11:	jmp	$12345678

level12:move.w	#$2500,sr	; level 12
old12:	jmp	$12345678

level14:move.w	#$2500,sr	; level 14
old14:	jmp	$12345678

level15:move.w	#$2500,sr	; level 15
old15:	jmp	$12345678

laddaivblen:
	dc.w	1
bildminne:
	dc.l	0
linea:	dc.l	0
middlepic:
	dc.b	0
lowersync:
	dc.b	0
lowersync2:
	dc.b	0
lowersync3:
	dc.b	0
blitterstatus:
	dc.b	0
timerCcontrol:
	dc.b	0
info:	dc.b	10,13,10,13
	dc.b	'This program removes the two borders.',10,13
	dc.b	'Works on any STE, written by ',10,13
	dc.b	'Christian Dahl FidoNet 2:206/215.8',13,10
	dc.b	'Press LEFTSHIFT to NOT install!',10,13
	dc.b	0
abort:	dc.b	10,13,'pInstallation ABORTED!!!q',10,13
	dc.b	0
maininfo:
	dc.b	10,13
	dc.b	'This program removes the two borders.',10,13
	dc.b	'Works on any STE, written by Christian',10,13
	dc.b	'Dahl at FidoNet 2:206/215.8',13,10
	dc.b	'Press LEFTSHIFT to NOT install!',10,13
	dc.b	'Feel free to write to me!',10,13
	dc.b	'--------------------------',10,13
	dc.b	'Version 0.71. Should work on any STE',10,13
	dc.b	'but hasn''t been tested yet...',10,13
	dc.b	'This program uses 41360 bytes',10,13
	dc.b	'and gives you 320x273 or 640x273....',10,13
	dc.b	'Works with blitter ON!!!',10,13
	dc.b	0


	even

	BSS

screen:	ds.b	160*273

