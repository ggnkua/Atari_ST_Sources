
	lea	debut,a2
	jsr	aff

un:
	cmp.b	#$39,$fffffc02.w
	bne.s	un

	lea	debut2,a2
	jsr	aff

un2:
	cmp.b	#$39,$fffffc02.w
	bne.s	un2


wait:
	cmp.b	#$39,$fffffc02.w
	bne.s	wait

	bra	sortie


aff:
	bsr	cls

	lea	fnt,a6
	move.l	log,a4
	move.l	phy,a5
	lea	6(a4),a4
	lea	6(a5),a5
	moveq	#0,d7
loop:
	lea	(a4,d7.w),a1
	lea	(a5,d7.w),a3
	move.w	#$ffff,d0
st	set	0
	rept	8
	move.b	d0,st(a1)
	move.b	d0,st(a3)
st	set	st+160
	endr

	vsync
	vsync

	moveq	#0,d0
	move.b	(a2)+,d0
	beq	fin
backspace:
	cmp.b	#8,d0
	bne.s	enter

	lea	(a4,d7.w),a1
	lea	(a5,d7.w),a3
	moveq	#0,d0
st	set	0
	rept	8
	move.b	d0,st(a1)
	move.b	d0,st(a3)
st	set	st+160
	endr

	move.w	d7,d0
	and.w	#%111,d0
	beq.s	moins1

	subq.w	#1,d7
	bra	cont2
moins1:
	subq.w	#7,d7
cont2:
	bra	loop

enter:	
	cmp.b	#13,d0
	bne.s	lettre
	lea	(a4,d7.w),a1
	lea	(a5,d7.w),a3
	moveq	#0,d0
st	set	0
	rept	8
	move.b	d0,st(a1)
	move.b	d0,st(a3)
st	set	st+160
	endr
	divu	#160,d7
	add.l	#8,d7
	mulu	#160,d7
	bra	loop
lettre:
	lea	tab_lettre,a0
	lsl.w	#2,d0
	move.l	(a0,d0.w),a0
	lea	(a4,d7.w),a1
	lea	(a5,d7.w),a3
st	set	0
n:	set	0
	rept	8
	move.b	n(a0),d0
	move.b	d0,st(a1)
	move.b	d0,st(a3)
st	set	st+160
n:	set	n+40
	endr
	move.w	d7,d0
	and.w	#%111,d0
	beq.s	plus1
	addq.w	#7,d7
	bra	cont
plus1:
	addq.w	#1,d7
cont:	
	bra	loop
fin
	rts

cls:
	movem.l	d0-d1/a0-a1,-(sp)
	move.l	log,a0
	move.l	phy,a1
	move	#7999,d1
	moveq	#0,d0
.loop:
	move.w	d0,6(a0)
	move.w	d0,6(a1)
	addq.l	#8,a0
	addq.l	#8,a1
	dbf	d1,.loop
	movem.l	(sp)+,d0-d1/a0-a1
	rts



	section	data




debut:
	dc.b	'  --- THE TRANSBEAUCE PARTY DEMO 2 ---     ',13
	dc.b	'              "DISK 1"',13
	dc.b	13
	dc.b	'ISSUED BY SOME FROGS IN THE BEGINNING ',13
	dc.b	'OF MAY 1991 AFTER A PARTY TO WHICH OVER',13
	dc.b	'250 PEOPLE GATHERED.',13
	dc.b	13
	dc.b	"THANKS TO BUSHWACKERS (LE SERGENT,POPOL",13
	dc.b	",MORODER) FOR THE HEAVY ORGANISATION !",13
	dc.b	13
	dc.b	"FDC ROUTINES ,LOADER DEMO  AND  PUTTING",13
	dc.b	"EVERYTHING TOGETHER:.............MCODER",13
	dc.b	"LOADER DEMO IDEA:...........SPREADPOINT",13
	dc.b	"LOADER GFX:......LE SERGENT/BUSHWACKERS",13
	dc.b	"LOADER MUSIC:...............MAD MAX/TEX",13
	dc.b	13
	dc.b	"BOOT CODE:........BELZEBUB/ST CONNEXION",13
	dc.b	"BOOT GFX:........KRAZY REX/ST CONNEXION",13
	dc.b	13
	dc.b	"THIS INTRO:..........TERENCE/PENDRAGONS",13
	dc.B	"GFX:................MEGADETH/PENDRAGONS",13
	dc.b	"MUSIC:......................MAD MAX/TEX",13
	dc.b	"     PRESS SPACE FOR A GOOD LAUGH...",0
	
debut2:
	dc.b	"I had the opportunity to watch many ",13
	dc.b	"pretty things at the Transbeauce Demo",13
	dc.b	" like Naos screen for the Ventura Demo",13
	dc.b	"or a very cool screen made by Dogue de",13
	dc.b	"Mauve. This screen was featuring a ",13
	dc.b	"picture of VIRGINIE who is, I suppose,",13
	dc.b	"DOGUE's girlfriend and this girl was ",13
	dc.b	"rather ugly , completely would i say",13
	dc.b	"if I was not a good friend of DOGUE.",13
	dc.b	"But of course, this dowdy girl could",13
	dc.b	"not be used in a OVR screen so DOGUE",13
	dc.b	"had it really improve by TANIS from TCB",13
	dc.b	"but i'm really sad to tell you this ",13
	dc.b	"DOGUE but your VIRGINIE is really ugly",13
	dc.b	"hope you will find another girlfriend",13
	dc.b	"soon, you are a too much cool boy to",13
	dc.b	"stay with such a BEURK! girl.",13
	dc.b	"So all together let's shout :",13,13,13
	dc.b	"    GIVE UP UGLY VIRGINIE, DOGUE !",13,0

	even
fnt:	incbin	"a:f_8_8.1p"
	even

nbcar:
	ds.w	1

tab_lettre:
n:	set	0
	rept	40
	dc.l	fnt+n
n:	set	n+1
	endr
n:	set	40*8
	rept	40
	dc.l	fnt+n
n:	set	n+1
	endr
n:	set	40*8*2
	rept	40
	dc.l	fnt+n
n:	set	n+1
	endr
n:	set	40*8*3
	rept	40
	dc.l	fnt+n
n:	set	n+1
	endr
	

	section	bss

texte:
	ds.b	100
	even

