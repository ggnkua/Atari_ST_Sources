***ceci fabrique une table pour l'incrustateur
***(c) Captain Bug from hysteria
***structure de la table
***1 octet par instruction _premier quartet:temps machine en nops
***			   _deuxieme quartet:taille en mots
***il y a des codes d'erreur:	$FF--->instruction illegale
***				$FE--->une erreur c'est produite(ca arrive normalement jamais mais bon...)
***				$00--->incalculable:
***				_touche la pile ou le sr
***				_reset,rts,jmp,bcc,dbcc,trapv,chk....

	clr.l	-(a7)
	move.w	#$20,-(a7)
	trap	#1
	addq.l	#6,a7
	
	move.w	#$2700,sr
	move.l	a7,sav_a7
	movem.l	$8,d0-d7
	movem.l	d0-d7,sav_bomb
	move.l	$70.w,sav_vbl
	move.l	$68.w,sav_hbl
	move.l	#rte,$68.w
	move.l	#rte,$70.w
	move.l	$fffffa12.w,sav_vec
	clr.l	$fffffa12.w
	move.l	$2000,sav_1000
	
	move.l	#table,poi
	move.w	#-1,cpt
	MOVE.W	#$2300,SR
	STOP	#$2300
nul2	tst.b	$ffff8209.w
	beq	nul2
recom	addq.w	#1,cpt
	move.w	cpt,d0
	cmp.w	#%1111000000000000,d0
	beq	fin
	
	move.w	d0,d1
	and.w	#$FF00,d1
	cmp.w	#$2E00,d1
	beq	execute_pas		*move.w source,a7
	
	move.w	d0,d1
	and.w	#$FF00,d1
	cmp.w	#$3E00,d1
	beq	execute_pas		*move.l source,a7
	
	move.w	d0,d1
	and.w	#%1111000011111000,d1
	cmp.w	#%0101000011001000,d1
	beq	execute_pas		*DBcc
	
			
	move.w	d0,d1
	and.w	#$F000,d1
	cmp.w	#$6000,d1
	beq	execute_pas		*Bcc
	
	move.w	d0,d1
	and.w	#%1111111111000000,d1
	cmp.w	#%0100010011000000,d1	*move source,ccr
	beq	execute_pas
	
	move.w	d0,d1
	and.w	#%1111111111000000,d1
	cmp.w	#%0100011011000000,d1	*move source,sr
	beq	execute_pas
	
	and.w	#%1111111110000000,d1
	cmp.w	#%0100110010000000,d1	*movem source,dn-an
	beq	execute_pas
	
	move.w	d0,d1
	and.w	#%1111111111110000,d1
	cmp.w	#%0100111001000000,d1	*trap
	beq	execute_pas
	
	move.w	d0,d1
	and.w	#%1111111111111000,d1
	cmp.w	#%0100111001010000,d1	*link
	beq	execute_pas
	
	move.w	d0,d1
	and.w	#%1111111111111000,d1
	cmp.w	#%0100111001011000,d1	*unlk
	beq	execute_pas
	
	move.w	d0,d1
	and.w	#%1111111111111000,d1
	cmp.w	#%0100111001100000,d1	*move vers USP
	beq	execute_pas
	
	move.w	d0,d1
	and.w	#%1111111111111111,d1
	cmp.w	#%0100111001110000,d1	*RESET
	beq	execute_pas
	
	move.w	d0,d1
	and.w	#%1111111111111111,d1
	cmp.w	#%0100111001110010,d1	*RESET
	beq	execute_pas
	
	move.w	d0,d1
	and.w	#%1111111111111111,d1
	cmp.w	#%0100111001110011,d1	*RTE
	beq	execute_pas
	
	move.w	d0,d1
	and.w	#%1111111111111111,d1
	cmp.w	#%0100111001110101,d1	*RTS
	beq	execute_pas
	
	move.w	d0,d1
	and.w	#%1111111111111111,d1
	cmp.w	#%0100111001110110,d1	*TRAPV
	beq	execute_pas
	
	move.w	d0,d1
	and.w	#%1111111111111111,d1
	cmp.w	#%0100111001110111,d1	*RTR
	beq	execute_pas
	
	move.w	d0,d1
	and.w	#%1111111111000000,d1
	cmp.w	#%0100111010000000,d1	*JSR
	beq	execute_pas
	
	move.w	d0,d1
	and.w	#%1111111111000000,d1
	cmp.w	#%0100111011000000,d1	*JMP
	beq	execute_pas
	
	move.w	d0,d1
	and.w	#%1111111111000000,d1
	cmp.w	#%0100111111000000,d1	lea AE,a7
	beq	execute_pas
	
	
	move.w	d0,d1
	and.w	#%1111000000111111,d1
	cmp.w	#%0101000000001111,d1	*addq ou subq  #,a7
	beq	execute_pas
	
	move.w	d0,d1
	and.w	#%1111111011000000,d1
	cmp.w	#%1001111011000000,d1	*suba ou subx AE,a7
	beq	execute_pas
	
	move.w	d0,d1
	and.w	#$F000,d1
	cmp.w	#$A000,d1		*line A
	beq	execute_pas
			
	move.w	d0,d1
	and.w	#%1111111111111000,d1
	cmp.w	#%1100111101001000,d1	*EXGA a7,an
	beq	execute_pas
	
	move.w	d0,d1
	and.w	#%1111000111111111,d1
	cmp.w	#%1100000101001111,d1	*EXGA an,a7
	beq	execute_pas
	
	move.w	d0,d1
	and.w	#%1111000111111111,d1
yeah	cmp.w	#%1100000110001111,d1	*EXGA dn,a7
	beq	execute_pas
	

	
	move.w	d0,d1
	and.w	#%1111111011000000,d1
	cmp.w	#%1101111011000000,d1	*adda ou addx AE,a7
	beq	execute_pas
	
	move.w	cpt,$140.w
	lea	pile,a7
	move.l	#illegal,$10.w
	move.l	#bombe,$8.w
	move.l	#bombe,$c.w
	move.l	#trace,$24.w
	move.w	cpt,instruc
	move.l	#vide2+32768,a0
	move.l	a0,a1
	move.l	a0,a2
	move.l	a0,a3
	move.l	a0,a4
	move.l	a0,a5
	move.l	a0,a6
	movem.l vide,d0-d7
	move.l	sav_a7,a7
ENCORE	MOVE.W	#$2100,SR
	STOP	#$2100
	
	MOVE.B	$FFFF8209.W,D0
	nop
	nop
	nop
	nop
	CMp.B	$FFFF8209.W,D0
	Bne	cont

V5	MOVE.W	#$2300,SR
	STOP	#$2300
nul	tst.b	$ffff8209.w
	beq	nul
 	BRA	ENCORE
	
execute_pas
	move.l	poi,a0 
	move.b	#$00,(a0)
	addq.l	#1,poi
	bra	recom
	
cont	NOT.W	$FFFF8240.W
	NOT.W	$FFFF8240.W
	MOVE.W	#$2700,SR
	MOVE.L	A7,SAV_A7
	MOVE.B	$FFFF8209.W,SAV_VIDEO
	bra	instruc-4
	
fin
	move.l	sav_1000,$2000
	move.l	sav_vbl,$70.w
	move.l	sav_hbl,$68.w
	move.l	sav_vec,$fffffa12.w
	move.l	sav_a7,a7
	move.w	#$2300,sr
	movem.l	sav_bomb,d0-d7
	movem.l	d0-d7,$8
	illegal
yo	move.l	d1,a7
	move.w	a2,a7
	move.l	a1,a7
	move.l	a2,a7
	
poi	ds.l	1
cpt	ds.w	1
	ds.b	256	*pour les d(pc)
	move.w	#$a700,sr
instruc	dc.w	0,$2000,$2000,$2000,$2000
	ds.b	256	*pour les d(pc)

trace	move.b	$ffff8209.w,d1
	sub.b	sav_video,d1
	SUB.B	#$2C,D1
	LSR.B	#1,D1
	move.w	#$2700,sr
	move.l	2(a7),d0
	sub.l	#instruc,d0
	move.l	poi,a0
	lsr.w	#1,d0
	move.b	d0,(a0)
	lsl.b	#4,d1
	or.b	d1,(a0)
	addq.l	#1,poi	
	bra	recom
	
illegal	move.l	poi,a0
	move.b	#$FF,(a0)
	addq.l	#1,poi
	bra	recom
	
bombe	move.l	poi,a0
	move.b	#$FE,(a0)
	addq.l	#1,poi
	bra	recom
	
rte	rte

	section	bss

sav_1000 ds.l	1
sav_hbl	ds.l	1
sav_vbl	ds.l	1
sav_vec	ds.l	1
sav_video ds.w	1
vide	ds.l	15
sav_bomb	ds.l	8
sav_a7	ds.l	1
table	ds.b	$F000	*pas de line F	
	even

	ds.l	512
pile	ds.l	1
vide2	ds.l	65536/4	*pour y faire pointer les registres d'adresse
 