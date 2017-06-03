 ; #[ Equ/Macros:<

	move.l	4(sp),a5


	opt	o+
	
DEC	equ	204

nnop	macro
	dcb.w	\1,$4e71
	endm
	
Vsync_no_interrupt	MACRO
.waitvbl\@:
	move.b	$ffff8205.w,d0
	cmp.b	$ffff8201.w,d0
	bne.s	.waitvbl\@
	
	move.b	$ffff8207.w,d0
	cmp.b	$ffff8203.w,d0
	bne.s	.waitvbl\@
	
	tst.b	$ffff8209.w
	bne.s	.waitvbl\@

		ENDM
		
Vsync	MACRO

	move	#$25,-(a7)
	trap	#14
	addq	#2,a7

	ENDM

 ; #] Equ/Macros:

 ; #[ Start:
	
	clr.w	-(a7)
	move.w	#$20,-(a7)
	trap	#1
	addq.l	#4,a7
	
	movem.l	$ffff8240.w,d0-d7
	movem.l	d0-d7,oldpal
	movem.l	null,d0-d7
	movem.l	d0-d7,$ffff8240.w
	
	Vsync
	move.b	#18,$fffffc02.w
	
	move.b	$ffff8260.w,d0
	ext.w	d0
	move.w	d0,oldrez
	move.l	$44e.w,oldec
	
	Vsync
	lea	256(a5),a5
	move.l	a5,d0
	andi.l	#$ffff00,d0
	move.l	d0,ec1
	addi.l	#64000,d0
	move.l	d0,ec2

	movem.l	$8.w,d0-d7
	movem.l	d0-d7,oldbomb
	
	lea	$8.w,a0		; Redirection des bombes
	move.l	#fin,d0
	rept	8
	move.l	d0,(a0)+
	endr
	
	Vsync
	move.b	ec2+1,$ffff8201.w
	move.b	ec2+2,$ffff8203.w
	bsr	initmfp
	
 ; #] Start:
 ; #[ Mainloop:
	
mainloop:
	tst.w	tvbl
	beq.s	mainloop
	
	clr.w	tvbl
	
	move.b	$fffffc02.w,d0
	cmpi.b	#$39,d0
	beq.s	fin
	
	bra.s	mainloop
	
 ; #] Mainloop:
 ; #[ End:
	
fin:
	movem.l	null,d0-d7
	movem.l	d0-d7,$ffff8240.w

	movem.l	oldbomb,d0-d7
	movem.l	d0-d7,$8.w
	
	move	#$2700,sr
	Vsync_no_interrupt
	clr.b	$ffff820a.w
	Vsync_no_interrupt
	move.b	#2,$ffff820a.w
	move.b	oldrez+1,$ffff8260.w

	bsr	finmfp
	bsr	error_clavier

	move	#$2300,sr
	
	move.w	#-1,-(a7)
	move.l	oldec,-(a7)
	move.l	oldec,-(a7)
	move.w	#5,-(a7)
	trap	#14
	adda.l	#12,a7
	
	move.b	#8,$fffffc02.w
	
	Vsync
	movem.l	oldpal,d0-d7
	movem.l	d0-d7,$ffff8240.w
	
	clr.w	-(a7)
	trap	#1

 ; #] End:
 ; #[ Init/reinstall interupt:
		
initmfp:
	move	sr,-(a7)
	move	#$2700,sr
	
	lea	$fffffa01.w,a0
	lea	oldmfp,a1
	move	#16,d0
	
savemfp:
	move.b	(a0),(a1)+
	addq.l	#2,a0

	dbra	d0,savemfp
	
	movem.l	$100.w,d0-d7		; On sauvegarde les vecteur MFP
	movem.l	d0-d7,oldvec
	movem.l	$120.w,d0-d7
	movem.l	d0-d7,oldvec+$20
	movem.l	$58.w,d0-d7		; Et 68000...
	movem.l	d0-d7,oldvec+$40
	
	bsr.s	finmfp
	
	bclr	#3,$fffffa17.w
	
	move.b	#%00100000,$fffffa07.w
	move.b	#%00100000,$fffffa13.w
	
	move.b	#%00000000,$fffffa09.w
	move.b	#%00000000,$fffffa15.w
	
	move.l	#vbl,$70.w
	move.l	#hbl,$68.w
	move.l	#timera,$134.w
	
	move	(a7)+,sr
	rts
	
finmfp:
	move	sr,-(a7)
	move	#$2700,sr

	lea	oldmfp,a0
	lea	$fffffa01.w,a1
	move	#16,d0
	
restmfp:

	move.b	(a0)+,(a1)
	addq.l	#2,a1

	dbra	d0,restmfp
	
	movem.l	oldvec,d0-d7
	movem.l	d0-d7,$100.w
	movem.l	oldvec+$20,d0-d7
	movem.l	d0-d7,$120.w
	movem.l	oldvec+$40,d0-d7
	movem.l	d0-d7,$58.w
	
	move	(a7)+,sr
	rts
	
error_clavier:
	btst	#5,$fffffc00.w
	beq.s	.noerror
	
	tst.b	$fffffc02.w
	bra.s	error_clavier
.noerror:

	btst	#0,$fffffc00.w
	beq.s	.vidbuff
	
	tst.b	$fffffc02.w
	bra.s	error_clavier
.vidbuff:

	rts
	
	section	bss
	
oldvec	ds.l	24
oldmfp	ds.b	24

	section	text
	
 ; #] Init/reinstall interupt:

 ; #[ Fullscreen:
hbl:
	rte
	
timera:
	move.w	#$2100,sr
	stop	#$2100		; Synchro HBL
	move.w	#$2700,sr

	lea	$ffff820a.w,a0	; Overscan haut
	lea	$ffff8260.w,a1
	moveq	#0,d0
	moveq	#2,d1
	nnop	82
	move.b	#0,(a0)
	nnop	15
	move.b	#2,(a0)

	nnop	20		; Synchro SHIFTER
	moveq	#0,d2
	move.b	$ffff8209.w,d2
	neg.w	d2
	lsl.w	d2,d2
	
				; 1ere ligne de fullscreen
	nnop	41
	
	move.b	d0,(a0)
	move.b	d1,(a0)
	
	nnop	13
	
	move.b	d1,(a1)
	nop
	move.b	d0,(a1)
	
	nnop	12
	
	move.b	d1,(a1)
	nop
	move.b	d0,(a1)

	nop	
	move.w	#211-1,d7
full1:
	nnop	86
	
	move.b	d0,(a0)
	move.b	d1,(a0)
	
	nnop	13
	
	move.b	d1,(a1)
	nop
	move.b	d0,(a1)
	
	nnop	12
	
	move.b	d1,(a1)
	nop
	move.b	d0,(a1)
	
	dbra	d7,full1
	
****************** Overscan bas pour tres anciens ST

	nnop	85
	
	move.b	d0,(a0)
	move.b	d1,(a0)
	
	nnop	13
	
	move.b	d1,(a1)
	nop
	move.b	d0,(a1)
	move.b	d0,(a0)	
	
	nnop	8
	
	nop
	move.b	d1,(a1)
	move.b	d1,(a0)	
	move.b	d0,(a1)
	
	move.w	#16-1-1,d7
	nop
	
full2:
	nnop	86
	
	move.b	d0,(a0)
	move.b	d1,(a0)
	
	nnop	13
	
	move.b	d1,(a1)
	nop
	move.b	d0,(a1)
	
	nnop	12
	
	move.b	d1,(a1)
	nop
	move.b	d0,(a1)
	
	dbra	d7,full2
	
****************** Overscan bas pour les autres STF/STE

	nnop	85
	
	move.b	d0,(a0)
	move.b	d1,(a0)
	
	nnop	13
	
	move.b	d1,(a1)
	nop
	move.b	d0,(a1)
	move.b	d0,(a0)	
	
	nnop	8
	
	nop
	move.b	d1,(a1)
	move.b	d1,(a0)	
	move.b	d0,(a1)
	
	move.w	#43-1,d7
	nop
	
full3:
	nnop	86
	
	move.b	d0,(a0)
	move.b	d1,(a0)
	
	nnop	13
	
	move.b	d1,(a1)
	nop
	move.b	d0,(a1)
	
	nnop	12
	
	move.b	d1,(a1)
	nop
	move.b	d0,(a1)
	
	dbra	d7,full3
	
	nnop	85		; Derniere ligne fullscreen
	
	move.b	d0,(a0)
	move.b	d1,(a0)
	
	nnop	13
	
	move.b	d1,(a1)
	nop
	move.b	d0,(a1)
	
	clr.b	$fffffa07.w
	rte

 ; #] Fullscreen:
 ; #[ Vbl:
	
vbl:
	clr.b	$fffffa19.w
	move.b	#$65,$fffffa1f.w
	move.b	#4,$fffffa19.w
	move.b	#%00100000,$fffffa07.w

	move.w	#0,$ffff8240.w
	movem.l	d0-d7/a0-a6,-(a7)
	
	movem.l	pal,d0-d7
	movem.l	d0-d7,$ffff8240.w
	
	move.w	#1,tvbl
	
	move.l	ec1,d0
	move.l	ec2,ec1
	move.l	d0,ec2
	
	move.b	ec2+1,$ffff8201.w
	move.b	ec2+2,$ffff8203.w
 
	movem.l	(a7)+,d0-d7/a0-a6
*	move.w	#$555,$ffff8240.w
	rte

 ; #] Vbl:
	
 ; #[ Datas/Bss:
	
	section	data
	
pal:
	DC.W	$abcd,$abcd,$0700,$0304,$0425,$0536,$0320,$0530
	DC.W	$0640,$0760,$0747,$0223,$0334,$0445,$0556,$0777
	
null	ds.w	16
	
	section	bss
	
	ds.b	256
oldec	ds.l	1
oldrez	ds.w	1
ec1	ds.l	1
ec2	ds.l	1
clav	ds.b	128
tvbl	ds.w	1
oldbomb	ds.l	8
oldpal	ds.w	16

 ; #] Datas/Bss:

