***************************************************************************
* This screen is called : Putain merde j'vais encore me faire engueuler !!*
* cod‚ par terence des Pan ! Dragons . c'est nul mais personne n'est      *
* parfait alors shut up ! (oui oui meme toi jean charles tu n'es pas      *
* parfait , souviens toi de mission en rafale !!!!)		        *
***************************************************************************


 	opt	o+,w-

vsync:	macro
	move.l	$466.w,d6
.\@1:	cmp.l	$466.w,d6
	beq.s	.\@1
	endm

ech:	macro
	move.l	\1,d0
	move.l	\2,\1
	move.l	d0,\2
	endm

aff_spr:	macro

	cmp.l	#crb_x+21*4,(a1)
	bne	affff\@
	move.l	#crb_x+480*4+21*4,(a1)
affff\@:	sub.l	#4,(a1)
	cmp.l	#crb_y+19*4,4(a1)
	bne	affff1\@
	move.l	#crb_y+180*4+19*4,4(a1)
affff1\@:	sub.l	#4,4(a1)
	move.l	a2,a0
	move.l	(a1)+,a4
	adda.w	(a4)+,a0
	moveq	#0,d0
	move.w	(a4)+,d0	* decalage
	move.l	(a1)+,a4
	adda.l	(a4),a0	* adresse sur ecran
	move.l	a0,\1
	lea	\2,a3
	move.l	(a3,d0.w),a3
	jsr	(a3)
	endm

eff:	macro
	move.l	\1,a0
st	set	0
	moveq	#0,d1
	moveq	#0,d2
	
	rept	29
	movem.w	d0-d2,st(a0)
	movem.w	d0-d2,st+8(a0)
	movem.w	d0-d2,st+8*2(a0)
st	set	st+160
	endr
	endm

fuck_you_jean_charles_espece_de_lamer_toki_est_pour_quand?:

	move.w	sr,d0
	btst	#13,d0
	bne	.ok

	clr.l	-(sp)
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp
.ok:
	move.l	$70.w,savvbl
	move.l	#vbl2,$70.w

	IFEQ	1
	move.l	$8.w,save_8
	move.l	$c.w,save_c
	move.l	$10.w,save_10
	move.l	$14.w,save_14
	
	move.l	#sortie,$8.w
	move.l	#sortie,$c.w
	move.l	#sortie,$10.w
	move.l	#sortie,$14.w
	ENDC
	
	moveq	#1,d0
	jsr	zik

;	move.b	#$12,$fffffc02.w

	jsr	trans_p

	vsync
	move.b	#0,$ffff8260.w
	vsync

	move.l	#ecrans,d0
	move.b	#0,d0
	add.l	#256,d0
	move.l	d0,phy
	add.l	#32000,d0
	move.l	d0,log


	movem.l	pal1,d0-d7
	movem.l	d0-d7,$ffff8240.w

	move.l	#vbl,$70.w

	lea	debut,a2
	jsr	aff

un:
	cmp.b	#$39,$fffffc02.w
	bne.s	un

wait:
;	cmp.b	#$39,$fffffc02.w
;	bne.s	wait

sortie:
	ILLEGAL

;	bra	sortie


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


	IFEQ	1
sortie:
	move.l	#vbl2,$70.w
	move.w	#$2300,sr
	move.b	#$8,$fffffc02.w

	moveq	#0,d0
	jsr	zik
	jsr	zik+8
	
	move.l	save_8,$8.w
	move.l	save_c,$c.w
	move.l	save_10,$10.w
	move.l	save_14,$14.w
	
	
	vsync
	move.b	#1,$ffff8260.w
	vsync

	move.l	savvbl,$70.w
	illegal
	ENDC

vbl:
	movem.l	d0-a6,-(sp)
*	move.w	#$700,$ffff8240.w
	bsr	efface
	bsr	affiche
	bsr	clip
	jsr	zik+8
*	move.w	#$00,$ffff8240.w
	cmp.b	#$44,$fffffc02.w
	beq	sortie
	cmp.b	#$3b,$fffffc02.w
	blt.s	.ok
	cmp.b	#$41,$fffffc02.w
	bgt.s	.ok
	moveq	#0,d0
	move.b	$ffffffc02.w,d0
	sub.b	#$3b,d0
	add.w	d0,d0
	add.w	d0,d0
	move.l	tabcol(pc,d0.w),a1
	movem.l	(a1),d0-d3
	movem.l	d0-d3,$ffff8240.w
.ok:
	movem.l	(sp)+,d0-a6
vbl2:
	addq.l	#1,$466.w
	rte

tabcol:
	dc.l	pal1,pal2,pal3,pal4,pal5,pal6,pal7
clip:
	move.l	log,d0
	move.l	phy,log
	move.l	d0,phy

	lsr.l	#8,d0
	move.b	d0,$ffff8203.w
	lsr.l	#8,d0
	move.b	d0,$ffff8201.w

	ech	old_spr11,old_spr12
	ech	old_spr21,old_spr22
	ech	old_spr31,old_spr32
	ech	old_spr41,old_spr42
	ech	old_spr51,old_spr52
	ech	old_spr61,old_spr62
	ech	old_spr71,old_spr72
	ech	old_spr81,old_spr82
	ech	old_spr91,old_spr92
	ech	old_spr101,old_spr102
	ech	old_spr111,old_spr112
	ech	old_spr121,old_spr122
	ech	old_spr131,old_spr132
	ech	old_spr141,old_spr142
	ech	old_spr151,old_spr152
	ech	old_spr161,old_spr162
	ech	old_spr171,old_spr172
	ech	old_spr181,old_spr182
	ech	old_spr191,old_spr192
	ech	old_spr201,old_spr202
	ech	old_spr211,old_spr212
	rts

affiche:
	lea	pt_crb,a1

	move.l	log,a2

	aff_spr	old_spr11,b
	aff_spr	old_spr21,b
	aff_spr	old_spr31,b
	aff_spr	old_spr41,b
	aff_spr	old_spr51,b
	aff_spr	old_spr61,b
	aff_spr	old_spr71,b
	aff_spr	old_spr81,b
	aff_spr	old_spr91,b
	aff_spr	old_spr101,b
	aff_spr	old_spr111,b
	aff_spr	old_spr121,b
	aff_spr	old_spr131,b
	aff_spr	old_spr141,b
	aff_spr	old_spr151,b
	aff_spr	old_spr161,b
	aff_spr	old_spr171,b
	aff_spr	old_spr181,b
	aff_spr	old_spr191,b
	aff_spr	old_spr201,b
	aff_spr	old_spr211,b

	rts

efface:
	moveq	#0,d0

	eff	old_spr11
	eff	old_spr21
	eff	old_spr31
	eff	old_spr41
	eff	old_spr51
	eff	old_spr61
	eff	old_spr71
	eff	old_spr81
	eff	old_spr91
	eff	old_spr101
	eff	old_spr111
	eff	old_spr121
	eff	old_spr131
	eff	old_spr141
	eff	old_spr151
	eff	old_spr161
	eff	old_spr171
	eff	old_spr181
	eff	old_spr191
	eff	old_spr201
	eff	old_spr211
	rts


trans_p:
	lea	b,a1
	move.l	a1,d0
	rept	16
	add.l	d0,(a1)+
	endr
	rts

	section	data

pt_crb:
n:	set	180+21
m:	set	480+21
	rept	21
	dc.l	crb_x+m*4
	dc.l	crb_y+n*4
n:	set	n-4
m:	set	m-10
	endr

old_spr11:	dc.l	ecrans
old_spr12:	dc.l	ecrans
old_spr21:	dc.l	ecrans
old_spr22:	dc.l	ecrans
old_spr31:	dc.l	ecrans
old_spr32:	dc.l	ecrans
old_spr41:	dc.l	ecrans
old_spr42:	dc.l	ecrans
old_spr51:	dc.l	ecrans
old_spr52:	dc.l	ecrans
old_spr61:	dc.l	ecrans
old_spr62:	dc.l	ecrans
old_spr71:	dc.l	ecrans
old_spr72:	dc.l	ecrans
old_spr81:	dc.l	ecrans
old_spr82:	dc.l	ecrans
old_spr91:	dc.l	ecrans
old_spr92:	dc.l	ecrans
old_spr101:	dc.l	ecrans
old_spr102:	dc.l	ecrans
old_spr111:	dc.l	ecrans
old_spr112:	dc.l	ecrans
old_spr121:	dc.l	ecrans
old_spr122:	dc.l	ecrans
old_spr131:	dc.l	ecrans
old_spr132:	dc.l	ecrans
old_spr141:	dc.l	ecrans
old_spr142:	dc.l	ecrans
old_spr151:	dc.l	ecrans
old_spr152:	dc.l	ecrans
old_spr161:	dc.l	ecrans
old_spr162:	dc.l	ecrans
old_spr171:	dc.l	ecrans
old_spr172:	dc.l	ecrans
old_spr181:	dc.l	ecrans
old_spr182:	dc.l	ecrans
old_spr191:	dc.l	ecrans
old_spr192:	dc.l	ecrans
old_spr201:	dc.l	ecrans
old_spr202:	dc.l	ecrans
old_spr211:	dc.l	ecrans
old_spr212:	dc.l	ecrans

b:	incbin	"b.spr"
	even

crb_x:	incbin	"crb_x.bin"
	incbin	"crb_x.bin"
crb_y:	incbin	"crb_y.bin"
	incbin	"crb_y.bin"
fcourbe:	even


pal1:
	dc.w	$000,$002,$004,$005
	dc.w	$007,$227,$337,$557
	dc.w	$220,$440,$550,$770
	dc.w	$772,$774,$775,$777

pal2:
	dc.w	$000,$200,$400,$500
	dc.w	$700,$722,$733,$755
pal3:
	dc.w	$000,$020,$040,$050
	dc.w	$070,$272,$373,$575
pal4:
	dc.w	$000,$220,$440,$550
	dc.w	$770,$772,$773,$775
pal5:
	dc.w	$000,$022,$044,$055
	dc.w	$077,$277,$377,$577
pal6:
	dc.w	$000,$202,$404,$505
	dc.w	$707,$727,$737,$757
pal7:
	dc.w	$000,$111,$222,$333
	dc.w	$444,$555,$666,$777

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
	dc.b	"PROTECTION:................ZARATHOUSTRA",13
	dc.b	13
	dc.b	"THIS INTRO:..........TERENCE/PENDRAGONS",13
	dc.B	"GFX:................MEGADETH/PENDRAGONS",13
	dc.b	"MUSIC:......................MAD MAX/TEX",13
	dc.b	"     PRESS SPACE FOR A GOOD LAUGH...",0
	

	even
fnt:	incbin	"f_8_8.1p"
	even
*trans:
*	dc.b	"azertyuiop^$  qsdfghjklm—` #wxcvbn,;:=      "
*	even
nbcar:
	ds.w	1
zik:
	incbin	"tlb1.mus"
	even

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

save_8:	ds.l	1
save_c:	ds.l	1
save_10:	ds.l	1
save_14:	ds.l	1
log:	ds.l	1
phy:	ds.l	1
savvbl:	ds.l	1

	ds.b	1
texte:
	ds.b	100
	even
	ds.b	160+8
ecrans:	ds.b	32000+256
	ds.b	32000

	end

