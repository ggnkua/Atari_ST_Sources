
;	output	a:\toto.prg
	output	hidden2.prg

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
	move.l	(a1),a4
	cmp.l	#crb_x+21*4,a4
	bne.s	affff\@
	lea	crb_x+360*4+21*4,a4
affff\@:	subq.l	#4,a4
	move.l	a4,(a1)+

	move.l	a2,a0
	adda.w	(a4)+,a0
	move.w	(a4)+,d0	* decalage

	move.l	(a1),a4
	cmp.l	#crb_y+19*4,a4
	bne.s	affff1\@
	lea	crb_y+450*4+19*4,a4
affff1\@:	subq.l	#4,a4
	move.l	a4,(a1)+

	adda.l	(a4),a0	* adresse sur ecran
	move.l	a0,\1

	lea	\2,a3
	move.l	(a3,d0.w),a3
	jsr	(a3)
	endm

eff:	macro
	move.l	\1,a0
st	set	0
	
	rept	64
	movem.l	d0-d7/a1-a2,st(a0)
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

;	move.l	$8.w,save_8
;	move.l	$c.w,save_c
;	move.l	$10.w,save_10
;	move.l	$14.w,save_14
;	
;	move.l	#sortie,$8.w
;	move.l	#sortie,$c.w
;	move.l	#sortie,$10.w
;	move.l	#sortie,$14.w
	
	
*	moveq	#1,d0
*	jsr	zik

;	move.b	#$12,$fffffc02.w

	lea	dbss,a0
	lea	fbss,a1
	moveq	#0,d0
loopm:
	move.b	d0,(a0)+
	cmp.l	a1,a0
	blt.s	loopm


	jsr	trans_p

	jsr	musique+4

;	vsync
;	move.b	#0,$ffff8260.w
;	vsync

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
	move.w	#800,d5
.ok12:	vsync
	subq.w	#1,d5
	bne.s	.ok12

	lea	debut2,a2
	jsr	aff
	move.w	#800,d5
.ok13:	vsync
	subq.w	#1,d5
	bne.s	.ok13

	lea	debut3,a2
	jsr	aff
	move.w	#800,d5
.ok133:	vsync
	subq.w	#1,d5
	bne.s	.ok133

	lea	debut4,a2
	jsr	aff
	move.w	#800,d5
.ok14:	vsync
	subq.w	#1,d5
	bne.s	.ok14

	lea	debut5,a2
	jsr	aff

	move.w	#800,d5
.ok15:	vsync
	subq.w	#1,d5
	bne.s	.ok15

	lea	debut6,a2
	jsr	aff


wait:
	cmp.b	#$39,$fffffc02.w
	bne.s	wait

	bra	sortie


aff:
	bsr	cls

	lea	fnt,a6
	move.l	log,a4
	lea	(199-16)*160+6(a4),a4
	move.l	phy,a5
	lea	(199-16)*160+6(a5),a5
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
	lea	160*(199-16)(a1),a1
	lea	160*(199-16)(a0),a0
	move	#400-1,d1
	moveq	#0,d0
.loop:
	move.w	d0,6(a0)
	move.w	d0,6(a1)
	addq.l	#8,a0
	addq.l	#8,a1
	dbf	d1,.loop
	movem.l	(sp)+,d0-d1/a0-a1
	rts



sortie:
;	move.l	#vbl2,$70.w
;	move.w	#$2300,sr
;	move.b	#$8,$fffffc02.w

*	moveq	#0,d0
*	jsr	zik
*	jsr	zik+8

;	jsr	musique+8
	
;	move.l	save_8,$8.w
;	move.l	save_c,$c.w
;	move.l	save_10,$10.w
;	move.l	save_14,$14.w
	
	
;	vsync
;	move.b	#1,$ffff8260.w
;	vsync

;	move.l	savvbl,$70.w

	illegal

vbl:
	movem.l	d0-a6,-(sp)
	move.w	#$00,$ffff8240.w
	bsr	efface
	bsr	affiche
	bsr	clip
	jsr	musique
	cmp.b	#$38,$fffffc02.w
	bne.s	.ok1
	move.w	#$245,$ffff8240.w
.ok1:

	movem.l	(sp)+,d0-a6
	cmp.b	#$01,$fffffc02.w
	bne.s	vbl2
	move.l	#sortie,2(a7)
vbl2:
	addq.l	#1,$466.w
	rte

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
	rts

affiche:
	lea	pt_crb,a1

	move.l	log,a2

	aff_spr	old_spr11,f
	aff_spr	old_spr21,i
	aff_spr	old_spr31,f
	aff_spr	old_spr41,i
	aff_spr	old_spr51,f
	aff_spr	old_spr61,i
	aff_spr	old_spr71,f

	cmp.b	#$38,$fffffc02.w
	bne.s	.ok22
	move.w	#$70,$ffff8240.w
.ok22:

	rts

efface:
	moveq	#0,d0
	moveq	#0,d1
	moveq	#0,d2
	moveq	#0,d3
	moveq	#0,d4
	moveq	#0,d5
	moveq	#0,d6
	moveq	#0,d7
	move.l	d0,a1
	move.l	d0,a2

	eff	old_spr11
	eff	old_spr21
	eff	old_spr31
	eff	old_spr41
	eff	old_spr51
	eff	old_spr61
	eff	old_spr71
	rts

trans_p:
	lea	f,a1
	move.l	a1,d0
	rept	16
	add.l	d0,(a1)+
	endr

	lea	i,a1
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

f:	incbin	"moi.spr"
	even
i:	incbin	"sergent.spr"
	even

	
crb_x:	incbin	"crb_x2.bin"
	incbin	"crb_x2.bin"
crb_y:	incbin	"crb_y2.bin"
	incbin	"crb_y2.bin"
fcourbe:	even


pal1:
	DC.W	0,$223,$333,$110
	DC.W	$444,$445,$666,$777
	DCb.W	8,$245
 
musique:
	incbin	feardrop.dat
	even
debut:
	DC.B	"This screen is only a disk filler....",13,0
	
debut2:
	dc.b	"The FRENCHIES beat the SWEDISH ...",13
	dc.b	"We put SEVEN 64 64 3 planes sprites ",0

debut3:
	dc.b	"We beat VECTOR from two sprites !!!",13
	dc.b	"     TRY TO BEAT DIS .... ",0


debut4:
	dc.b	"FUCK to all the guys thinking that the",13
	dc.b	"main menu is lame and bugged ....",0
	even

debut5:
	dc.b	"The 2 guys above are The Sergeant and ",13
	dc.b	"                     Terence ....",0

debut6:
	dc.b	"Press Space to leave this ........",13
	dc.b	"       SEE YA SOON .....",0

fnt:	incbin	"f_8_8.1p"
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

dbss:

save_8:	ds.l	1
save_c:	ds.l	1
save_10:	ds.l	1
save_14:	ds.l	1
log:	ds.l	1
phy:	ds.l	1
savvbl:	ds.l	1


	ds.b	160*40
ecrans:	ds.b	32000+256
	ds.b	32000

fbss:
	end
