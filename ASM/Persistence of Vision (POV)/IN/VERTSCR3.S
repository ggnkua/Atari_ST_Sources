;
;
;
	include	macros.s
;
;
linelen	equ	160
ll	equ	linelen
scrhi	equ	200

charwi	equ	32
charwiw	equ	charwi/16
charwib	equ	charwi/8
charhi	equ	32

buflen	equ	charwib*scrhi
;
;
mir1	macro
	roxr.w	d2		shift bit uit data
	roxl.w	d3		naar gespiegelde data
	endm
;
mir4	macro
	mir1
	mir1
	mir1
	mir1
	endm
;
mir16	macro
	mir4
	mir4
	mir4
	mir4
	endm
;
YEAH	macro
	not.w	col0
	endm
;
;
	startup
	super	ssp
	move.l	#mystack,sp
	getpal	oldpal
	getrez
	move.w	d0,oldrez
	setrez	#0
	getphys
	addi.l	#5*8,d0
	move.l	d0,phys1
;
;
;
;
dotext	move.l	txtptr,a0	haal pointer in scroll text
	move.b	(a0)+,d0	haal letter
	bne.s	norescr		als letter<>0 niet opnieuw aan scroll beginnen
	lea	scrtxt,a0	haal pointer naar BEGIN scrolltext
	move.b	(a0)+,d0	haal EERSTE letter

norescr	move.l	a0,txtptr	zet hem in pointer naar text
	ext.w	d0		maak word van d0
	asl.w	#2,d0		vermenigvuldig d0 met 4 voor juiste pointer naar sprite
	lea	scrtabl,a0	haal pointer naar tabel met spritepointers
	move.l	0(a0,d0.w),a1	haal pointer naar sprite
	move.l	a1,charptr	zet pointer naar sprite in var
	move.w	#charhi,charpos	zet charpos op hoogte, om af te tellen
;
;
dochar
	YEAH
	move.w	#scrhi-2,d0		we moeten hoogte buffer-1 regels scrollen
	lea	vertbuf,a0		haal adres vertikale buffer
upscrlp	move.l	charwib(a0),(a0)+	verplaats een long word: is hier net de breedte
	dbra	d0,upscrlp		volgende regel scrollen

	move.l	charptr,a1		haal pointer in letter
	move.l	(a1)+,(a0)		zet nieuwe regel in buffer
	move.l	a1,charptr		sla pointer in letter weer op
***
*** buffer gescrolld: nu op het scherm zetten
***
	move.l	phys1,a0	haal adres physisch schermadres
	lea	vertbuf,a1	haal adres scroll-buffer
	move.l	#linelen,a2	voor snel optellen
	lea	shiftab,a3	haal adres shift tabel
	move.w	#scrhi-1,d0	haal hoogte scherm voor dbra lus
	moveq	#0,d1		wis register met shift#

*tophys	move.l	(a1)+,d2	haal long (1 regel) uit buffer
*	move.b	(a3)+,d1	haal shift#
*	bmi.s	mirror		als shift# negatief is omdraaien
*	lsl.w	d1,d2		shift bits uit rechter word naar links
*	move.w	d2,8(a0)	zet op scherm
*	swap	d2
*	lsr.w	d1,d2		shift bits uit linker word naar rechts
*	move.w	d2,(a0)		zet op scherm
tophys	move.w	(a1)+,(a0)	*****
	move.w	(a1)+,8(a0)

end_mr	adda.l	a2,a0		naar volgende regel op scherm
	dbra	d0,tophys	zo door tot alle regels op het scherm staan
	bra	endput
***
***
mirror	not.w	d1		maak shift# positief
	mir16			spiegel data (rechter word) van d2 naar d3
	lsr.w	d1,d3		en verschuif
	move.w	d3,(a0)		zet data op scherm

	swap	d2		bewerk linker word
	mir16
	lsl.w	d1,d3		verschuif
	move.w	d3,8(a0)	zet data op scherm

	bra	end_mr
***
***
***
endput	YEAH
	key			kijk of er een toets gedrukt wordt
	tst.w	d0
	bne	einde		zo ja -> einde scroll
	
*	move.w	#-1,-(sp)	resolutie hetzelfde
*	move.l	log,-(sp)	logisch scherm -> physisch scherm
*	move.l	#-1,-(sp)	Logbase hetzelfde (heeft geen functie)
*	move.w	#5,-(sp)	functie #5 (Setscreen)
*	trap	#14		Xbios
*	lea	12(sp),sp
	
	vsyncm			wacht op VBL

	subq.w	#1,charpos	trek 1 af van positie in letter
	bne	dochar		als we nog niet bij nul zijn, gaan we door met volgende regel
;
	bra	dotext		volgende letter pakken
;
einde	waitkey
	setpal	oldpal
	setrez	oldrez
	user	ssp
	term
;
;
	section	DATA

scrtxt	dc.b	2,1,2,1,1,2,0
txtptr	dc.l	scrtxt

scrtabl	dc.l	0,chara,charb,chara,charb

shiftab
; 0 = normaal
; 1...16 = geshift
; -1 = gespiegeld normaal
; -2...-17 = gespiegeld geshift
;
	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
; 100
	dc.b	1,1,1,1,2,2,2,3,3,3,4,4,5,5,6,7,9,12,14,16
	dc.b	-14,-12,-9,-7,-6,-5,-5,-4,-4,-3,-3,-3,-2,-2,-2,-1,-1,-1,-1
;
	dc.b	-1,-1,-1,-1,-1,-1,-1,-1
	dc.b	-1,-1,-1,-1,-1,-1,-1,-1
	dc.b	-1,-1,-1,-1,-1,-1,-1,-1
	dc.b	-1,-1,-1,-1,-1,-1,-1,-1
	dc.b	-1,-1,-1,-1,-1,-1,-1,-1
	dc.b	-1,-1,-1,-1,-1,-1,-1,-1
	dc.b	-1,-1,-1,-1,-1,-1,-1,-1
	dc.b	-1,-1,-1,-1,-1,-1,-1,-1
	dc.b	-1,-1,-1,-1,-1,-1,-1,-1
;
	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
; 200+x
	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
; 300+x
	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
; 400+x

	even
chara	incbin	A_32_32.MON
charb	incbin	B_32_32.MON
;
;
	section	BSS

charptr	ds.l	1
charpos	ds.w	1

phys1	ds.l	1
oldpal	ds.w	32
oldrez	ds.w	1
ssp	ds.l	1
	ds.b	4096
mystack	ds.b	32

vertbuf	ds.b	buflen

;
;
	end
;
	


