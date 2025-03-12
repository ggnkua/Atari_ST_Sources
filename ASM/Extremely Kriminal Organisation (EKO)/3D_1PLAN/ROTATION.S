 	opt	d+
	jmp	main			
save_ints:
	move.b	$fffffa07.w,mfpa07	
	move.b	$fffffa09.w,mfpa09
	move.b	$fffffa13.w,mfpa13
	move.b	$fffffa15.w,mfpa15
	move.b	$fffffa19.w,mfpa19
	move.b	$fffffa1f.w,mfpa1f
	move.l	$134,old134
	move.l	$70.w,oldvbl
	move.b	$ff8201,save81
	move.b	$ff8203,save82

	move.w	#-1,-(sp)	
	move.w	#88,-(sp)	
	trap	#14
	addq.l	#4,sp
	move.w	d0,oldmode
	rts
init_ints:	
	move.w	#3,-(sp)	
	move.w	#%011100010,-(sp)
	move.l	physique,-(sp)	
	move.l	physique,-(sp)	
	move.w	#5,-(sp)
	trap	#14
	add.l	#14,sp

	move.w	#%001100010,-(sp)
	move.w	#88,-(sp)	
	trap	#14
	addq.l	#4,sp

	move.l	#div_0,$14.w
	clr.b	$fffffa09.w		
	clr.b	$fffffa15.w
	move.b	#0,$fffffa1f.w
	move.b	#0,$fffffa19.w
	move.b	#1,$fffffa07.w
	move.b	#34,$fffffa21.w
	move.b	#1,$fffffa13.w
	bclr	#3,$fffffa17.w
	move.b	#0,$fffffa1b.w
	move.l	#vbi,$70.w
	rts
ret_ints:	
	move.b	mfpa07,$fffffa07.w	
	move.b	mfpa09,$fffffa09.w
	move.b	mfpa13,$fffffa13.w
	move.b	mfpa15,$fffffa15.w
	move.b	mfpa19,$fffffa19.w
	move.b	mfpa1f,$fffffa1f.w
	move.l	old134,$134
	move.l	oldvbl,$70.w
	move.b	save81,$ff8201
	move.b	save82,$ff8203
	rts
save81:	dc.b	0
save82:	dc.b	0
mfpa07:	dc.b	0			
mfpa09:	dc.b	0
mfpa13:	dc.b	0
mfpa15:	dc.b	0
mfpa19:	dc.b	0
mfpa1f:	dc.b	0
old134:	dc.l	0
oldvbl:	dc.l	0
oldmode	dc.w	0
main:	pea	0			
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp
	move.l	d0,save_stk
	move.l	usp,a0			
	move.l	a0,save_usp

	jsr	clr_screen
	jsr	save_ints		
	jsr	init_ints		
	movec	cacr,d0
	bset	#0,d0
	bclr	#1,d0
	bset	#8,d0
	bset	#4,d0
	bset	#12,d0
	movec	d0,cacr
	move.l	#0,$ffff9800.w
	move.l	#$e0e0e0e0,$ffff9804.w


demo_loop:
*****************************************************

	bsr	INCREM
	lea	coor_dep(pc),a5
	bsr	calkul

*******************************************************
fin	
	jsr	ret_ints		
	move.l	save_usp,a0
	move.l	a0,usp
	move.l	save_stk,-(sp)		
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp

	move.w	oldmode,-(sp)	
	move.w	#88,-(sp)	
	trap	#14
	addq.l	#4,sp


	clr.w	(sp)			
	trap	#1

vbi:	
	add.w	#1,wfnc
	rte
coor_dep

	dc.w	-20,-100,0

	dc.w	-60,-60,0
	dc.w	-40,-60,14
	dc.w	-40,-60,-14

	dc.w	-80,-20,0
	dc.w	-50,-20,21
	dc.w	-50,-20,-21

	dc.w	-90,20,0
	dc.w	-60,20,21
	dc.w	-60,20,-21

	dc.w	-80,60,0
	dc.w	-40,60,22
	dc.w	-40,60,-22


	dc.w	$abcd

new_p	ds.l	100

************* routine d incremention *************
******** routine de transformation 3D autour des 3 axes **********
X1	dc.w	0
Y1	DC.W	0
Z1	DC.W	0
ANGLEX	DC.W	0                                             
ANGLEY	DC.W	0
ANGLEZ	DC.W	0
SINX	DC.W	0
COSX	DC.W	0
SINY	DC.W	0
COSY	DC.W	0
SINZ	DC.W	0
COSZ	DC.W	0
angle_rot	dc.w	0,0,0
CALCUL	
	MOVEM.W	X1,D0-D5	
	ADD.W	D3,D3
	ADD.W	D4,D4
	ADD.W	D5,D5
	LEA	SINUS,A0
	LEA	SINX(PC),A1
	LEA	SINY(PC),A3
	LEA	SINZ(PC),A4
	MOVE.W	(A0,D3.W),(A1)
	MOVE.W	(A0,D4.W),$4(A1)
	MOVE.W	(A0,D5.W),$8(A1)
	LEA	COSINUS,A0
	LEA	COSX(PC),A2
	MOVE.W	(A0,D3.W),(A2)
	MOVE.W	(A0,D4.W),$4(A2)
	MOVE.W	(A0,D5.W),$8(A2)
	MOVEM.W	(A1),D3-D4	
       	MULS	D0,D4		
	NEG	D3	
	MULS	D1,D3
	ADD.L	D3,D4
	ADD.L	D4,D4
	SWAP	D4		* cos a*x-sin a*y= X=d4
	MOVEM.W	(A1),D5-D6	
       	MULS	D0,D5
	MULS	D1,D6
	ADD.L	D6,D5
	ADD.L	D5,D5
	SWAP	D5		* sin a*x+cos a*y= Y=d5
	MOVEM.W	(A3),D0-D1	* z= Z=d2
	MULS	D4,D1
	MULS	D2,D0
	ADD.L	D1,D0
	ADD.L	D0,D0
	SWAP	D0
	MOVEM.W	(A3),D6-D7	* cos b*X+sin b*Z=X' =d0 
	NEG	D6		
	MULS	D4,D6		
	MULS	D2,D7		
	ADD.L	D6,D7		
	ADD.L	D7,D7		
	SWAP 	D7		
	MOVEM.W	(A4),D1-D2	* cos b*Z-sin b*X=Z' =d7  
	MULS	D5,D2 		* Y= Y'=D5
	NEG	D1
	MULS	D7,D1
	ADD.L	D2,D1
	ADD.L	D1,D1
	SWAP 	D1		* cos c*Y'-sin c*Z'= YY''=D1
**********
	MOVEM.W	(A4),D2-D3	
	MULS	D5,D2 		
	MULS	D7,D3
	ADD.L	D3,D2
	ADD.L	D2,D2		 
	SWAP 	D2		*	XX''=D0    ZZ''=D2
**********	
	RTS	
*****************************************
calkul	
	move.w	#399,d7
	lea	stars_buff,a0
.re
	movem.l	d0-a6,-(sp)
	move.w	#17,-(sp)
	trap	#14
	addq	#2,sp
	and.w	#$1ff,d0
	move.w	d0,ANGLEX

	move.w	#17,-(sp)
	trap	#14
	addq	#2,sp
	and.w	#$1ff,d0
	move.w	d0,ANGLEY

	move.w	#17,-(sp)
	trap	#14
	addq	#2,sp
	and.w	#$1ff,d0
	move.w	d0,ANGLEZ

	move.w	#300,X1
	move.w	#0,Y1
	move.w	#0,Z1
	bsr	CALCUL
	move.w	d0,X1
	move.w	d1,Y1
	move.w	d2,Z1
	movem.l	d0-a6,-(sp)
	move.w	X1,(a0)+		
	move.w	Y1,(a0)+		
	move.w	Z1,(a0)+		

	dbf	d7,.re
	rts
*********************************
clr_screen
	move.l	logique,a0
	move.l	physique,a1
	move.w	#11519,d0
re	clr.l	(a0)+
	clr.l	(a1)+
	dbf	d0,re
	rts
*********************************
div_0	rte
																																
SINUS		incbin	f:\PURE_C\new_sin.tab
		EVEN
COSINUS		EQU	SINUS+256



work		dc.l	$3b0000
logique		dc.l	$3b0000
physique	dc.l	$3d0000
save_usp:	dc.l	0
wfnc:		dc.w	0
save_stk:	dc.l	0
	section bss
	end

