	lea	premul(pc),a1
	moveq	#59,d4		*nbre iter z
	moveq	#1,d3		*val de division
boucmulz:	move.w	#319,d0		*nbre iter x
	move.w	#-160,d1	*val de depart
boucmul:	move.w	d1,d2
	muls	d2,d2
	divu	d3,d2
	move.b	d2,(a1)+
	addq.w	#1,d1
	dbf.w	d0,boucmul

	addq.w	#1,d3
	dbf.w	d4,boucmulz
	
	lea courbz(pc),a5
	
main:	
	move.l ecr1,a0
	move.l ecr2,ecr1
	move.l a0,ecr2
	move.b ecr1+1,$ffff8201.w
	move.b ecr1+2,$ffff8203.w

	lea	160*8+160+49*160+40(a0),a0	*centre la keftale
	lea	premul(pc),a1
	move.w	(a5)+,d0		*fact de zoom(0 a 59)
	lea	(a1,d0.w),a1		*table de mult centree
	lea	160(a1),a1

	cmp.l	#fcourbz,a5
	blt.s	suit1
	lea	courbz(pc),a5

suit1:	
	move.w	(a6)+,d1		*pos x
	move.w	(a6)+,d0		*pos y
	sub.w	#80,d0
	sub.w	#80,d1
	cmp.l	#fcourbxy,a6
	blt.s	suit2
	lea	courbxy(pc),a6
suit2:	lea	(a1,d0.w),a2
	moveq.l	#99,d0			*taille y
	lea	(a1,d1.w),a4
	
bouc1:	moveq.l	#9,d1			*taille x
	move.l	a4,a3
	move.b	(a2)+,d3
	
bouc2:	
	rept	16
	move.b	(a3)+,d2
	add.b	d3,d2
		
	add.b	d2,d2
	addx.w	d7,d7
	add.b	d2,d2
	addx.w	d6,d6
	add.b	d2,d2
	addx.w	d5,d5
	add.b	d2,d2
	addx.w	d4,d4
	endr
	
	movem.w	d4-d7,(a0)
	addq.l	#8,a0
	dbf	d1,bouc2
	lea	160-160/2(a0),a0
	dbf	d0,bouc1	

	;move.w #$10,$ffff8240
	
	move.l #$31415926,boucok
fn2:	bra fn2	

new_pal:
	dc.w	$012,$111,$222,$333,$444,$555,$666,$777
	dc.w	$776,$765,$654,$543,$432,$321,$210,$100

courbz:	rept 30
	dc.w 2*320
	endr
pass:	set 2
	rept 57
	dc.w pass*320
pass:	set pass+1	
	endr
	rept 50
	dc.w 59*320
	endr
	rept 57
	dc.w pass*320
pass:	set pass-1	
	endr
fcourbz:
courbxy:
	incbin	posxy.odc	
fcourbxy:

premul:	ds.b	320*60

adfin:
	

