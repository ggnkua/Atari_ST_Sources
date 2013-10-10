* UN EXEMPLE ASSEZ GENERAL,ET COMPLEXE POUR VOUS FAIRE VOIR COMMENT MARCHE 
*                           LE BLITTER.

* IL FAUT RESET.PRG POUR SORTIR.

	include	ste.s
debut:
	clr.l	-(sp)
	move.w	#$20,-(sp)
	trap	#1			superviseur
	addq.l	#6,sp


	move.l	$4.w,d0
	move.l	d0,$8.w
	move.l	d0,$c.w
	move.l	d0,$10.w
	move.l	d0,$14.w
	move.l	d0,$18.w
	move.l	d0,$1c.w
	move.l	d0,$20.w

	
	clr.w	-(sp)
	move.l	#-1,-(sp)
	move.l	#-1,-(sp)
	move.w	#5,-(sp)
	trap	#14
	add.l	#12,sp

	lea	pal,a0
	lea	$ffff8240.w,a1
	moveq	#8-1,d0
.cop:	move.l	(a0)+,(a1)+
	dbra	d0,.cop

	move.l	#vbl,$70.w

* en noir,le temps machine...
* c'est pas genial,mais pas du tout optimise...
* par exemple j'efface un ecran 1 plan en entier...
* mais c'est pour pas trop compliquer...
* le blitter gagne du temps surtout pour les gros sprites...

DEMO:

	adrcompteur	ecrp
	adrecran	ecrp
	
	move.l	ecrl,a0
	lea	font,a1
	lea	msg+29,a2
	move.l	pointeur,a4
	moveq	#29-1,d7
.ecr:
	moveq	#0,d0
	move.l	a1,a3
	move.l	a0,a5
	move.b	-(a2),d0
	lsl.w	#4,d0
	add.w	d0,a3
	move.w	(a4)+,d0
	moveq	#-1,d1
	mask2	d1
	lsr.w	d0,d1
	mask1	d1
	not	d1
	mask3	d1
	or.w	#nfsr,d0
	skew	d0
	
	move.w	(a4)+,d0
	add.w	d0,a5
	
	op	#2
	oplog	#7
	offsetxs	#2
	offsetys	#1*2-(1*2)+2	
	offsetxd	#8
	offsetyd	#160-(2*8)+8
	longueur	#1+1
	hauteur	#8
	source	a3
	destination	a5
	startblit
	add.w	#16,a4
	cmp.l	#fincrb+16*40,a4
	blt.s	.suit
	move.l	#crb+16*40+16,a4
.suit:	dbra	d7,.ecr

	move.l	pointeur,a4
	addq.w	#4,a4
	cmp.l	#fincrb,a4
	blt.s	.ok
	move.l	#crb,a4
.ok:	
	move.l	a4,pointeur

	move.l	ecrp,d0
	move.l	ecrl,ecrp
	move.l	d0,ecrl
	move.w	hui,d0
	not	$ffff8240.w
a:	cmp.w	hui,d0
	beq.s	a


	not	$ffff8240.w
	
	mask1		#$ffff
	mask2		#$ffff
	mask3		#$ffff
	oplog		#0
	offsetxd	#8
	offsetyd	#160-(8*20)+8
	longueur	#20
	hauteur		#200
	destination	ecrl
	startblit
	bra	demo
	
vbl:	addq.w	#1,hui
	rte
hui:	dc.w	0

crb:
	include	crb.s
fincrb
	include	crb.s

ecrp:	dc.l	buffer
ecrl:	dc.l	buffer+32000

pointeur:	dc.l	crb
msg:	dc.b	"UN PETIT BONJOUR A JOK/LETHAL !"
	even
	 
pal:	dc.w	$0000,$0224,$0112,$0312,$0423,$0213,$0456,$0667
	dc.w	$0070,$0070,$0070,$0070,$0070,$0070,$0070,$0070

font:	rept	65
	dcb.w	8,0
	endr
test:	dc.w	24,56,56,76,124,140,206,0	;A
	dc.w	236,102,102,108,102,102,236,0	;B
	dc.w	46,98,224,224,224,98,46,0	;C
	dc.w	236,102,102,102,102,102,236,0	;D
	dc.w	238,98,96,108,96,98,238,0	;E
	dc.w	238,96,96,104,96,96,224,0	;F
	dc.w	46,98,224,238,230,102,44,0	;G
	dc.w	230,102,102,110,102,102,230,0	;H
	dc.w	60,24,24,24,24,24,60,0		;I
	dc.w	30,12,12,12,12,76,104,0		;J
 	dc.w	230,100,104,124,110,102,230,0	;K
	dc.w	240,96,96,96,96,98,238,0	;L
	dc.w	198,110,190,150,134,134,206,0	;M
	dc.w	198,98,178,154,140,134,194,0	;N
	dc.w	108,198,198,198,198,198,108,0	;O
	dc.w	236,102,102,108,96,96,224,0	;P
	dc.w	108,198,198,198,198,198,106,0	;Q
	dc.w	236,102,102,108,104,100,230,0	;R
	dc.w	110,194,240,60,14,134,236,0	;S
	dc.w	126,90,24,24,24,24,60,0		;T
	dc.w	246,98,98,98,98,98,28,0		;U
	dc.w	230,98,100,52,52,24,24,0	;V
	dc.w	230,194,194,210,250,236,198,0	;W
	dc.w	198,98,52,60,88,140,198,0	;X
	dc.w	230,98,52,24,24,24,60,0		;Y
	dc.w	246,142,28,56,112,226,222,0	;Z

	bss
buffer:	ds.b	32000*2	

