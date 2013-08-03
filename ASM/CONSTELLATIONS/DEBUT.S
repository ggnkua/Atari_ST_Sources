
	opt		d+

	clr.l		-(sp)
	move.w 	#$20,-(a7)
	trap 		#1
	addq.l 	#6,a7
	
	move.l 	$70,fin_vbl+2
	
save_ints:
	move.l	$118,oldkey
	move.l	$120,mfpb
	move.l	$70,old4
	lea		$fffa00,a0
	move.b	7(a0),mfp+7
	move.b	9(a0),mfp+9
	move.b	11(a0),mfp+11
	move.b	13(a0),mfp+13
	move.b	15(a0),mfp+15
	move.b	17(a0),mfp+17
	move.b	19(a0),mfp+19
	move.b	21(a0),mfp+21
	move.b	27(a0),mfp+27
	move.b	33(a0),mfp+33
	
	bra.s		deb

	even
	
;back	rte
okey	ds.l	6
oldkey	ds.l	1
mfpb	ds.l	1
mfp	ds.l	18
old4	ds.l	1

	
	even

deb:

	clr.b 	$fffa1b

	move.b 	#200,$fffa21
	move.b 	#1,flag
	move.l 	#rout,$70
	move.w 	#7,-(a7)
	trap 		#1
	addq.l 	#2,a7
	clr 		-(a7)
	trap 		#1
rout    
	
	move.b 	#8,$fffa1b

	movem.l	a0-a1,-(sp)

	cmpi.b 	#1,flag
	beq.s		lee
color	move.w 	(a0)+,$fff8240
	cmp.l 	a0,a1
	bge.s		return
	move.b 	#1,flag
	jmp 		return	
lee	lea 		pal,a0
	lea 		finpal,a1
	move.b 	#0,flag
	bclr.b 	#0,$fffa1b	
return:
	movem.l	(sp)+,a0-a1

fin_vbl:
	jmp 		$0.L

flag:
	dc.b		1
	
	even
	
pal:
	incbin a:\intros\c1x.bin

finpal:

     