
		section	text

voxzoom_timer:
		cmp.l	#1,vbl_param
		beq.s	.stop
		
		subq.w	#1,.count
		bgt.s	.scale
		move.w	#389,.count	;391
		move.l	#10500,voxzoom_level		
		not.w	.noteach
		bne.s	.scale
		move.w	#1,voxtwist_invertpal
.scale:		cmp.l	#25000,voxzoom_level
		bge.s	.stop
		add.l	#16,voxzoom_level		
.stop:
		
		rts
.count:		dc.w	220
.noteach:	dc.w	0


voxzoom_main:

		fmove.l	voxzoom_level,fp0
		fmul.s	#0.01,fp0
		
		;fmove.s	#200,fp0	;200 = ung. normal storlek
		fmove.s	#-2.35,fp7	;-2.35 r„ttv„nd
		fsin	fp7,fp1			
		fmul	fp0,fp1
   		fcos	fp7,fp2
		fmul	fp0,fp2
   		fadd.s	#1.57,fp7
		fsin	fp7,fp3
		fmul	fp0,fp3
		fcos	fp7,fp4	
		fmul	fp0,fp4
		fadd.s	#3.14,fp7
		fsin	fp7,fp5
		fmul	fp0,fp5
	   	fcos	fp7,fp6	
		fmul	fp0,fp6
		fscale.x	#16,fp1
		fscale.x	#16,fp2
		fscale.x	#16,fp3
		fscale.x	#16,fp4
		fscale.x	#16,fp5
		fscale.x	#16,fp6
		fmove.l	fp1,d1	
		fmove.l	fp2,d2	
		fsub	fp1,fp3	
		fdiv.s	#164,fp3
		fmove.l	fp3,d3	
		fsub	fp2,fp4	
		fdiv.s	#123,fp4
		fmove.l	fp4,d4	
		fsub	fp1,fp5	
		fdiv.s	#164,fp5
		fmove.l	fp5,d5	
		fsub	fp2,fp6	
		fdiv.s	#123,fp6
		fmove.l	fp6,d6	


		;lea.l	voxtwist_chunky+320*30+8,a0
		lea.l	voxzoom_chunky,a0
		lea.l	voxzoom_texture+788,a1	 ;-124

		move.l	#123-1,d7	
.y:		add.l	d3,d1	
		add.l	d4,d2		
		movem.l	d1-d6,-(sp)
		moveq.l	#0,d4
		swap	d1	
		swap	d5	
		ror.l	#8,d2
		ror.l	#8,d6
		move.w	d1,d0	
		move.w	d2,d1
		move.w	d0,d2
		move.w	d5,d0	
		move.w	d6,d5
		move.w	d0,d6	

		clr.l	d0
		
		swap	d7
		move.w	#164-1,d7
.x:

		addx.l	d5,d1
		addx.l	d6,d2
		move.w	d1,d4
		move.b	d2,d4

		move.b	(a1,d4.l),(a0)+

;		move.b	(a1,d4.l),d0
;		beq.s	.skip
;		move.b	d0,(a0)
;.skip:		tst.b	(a0)+
		

		dbra	d7,.x
		
		;lea.l	320-192(a0),a0
		movem.l	(sp)+,d1-d6
		swap	d7
		dbra	d7,.y
		rts

		section	data

voxzoom_texture:
		incbin	'voxtwist\zoom04c.apx'
		even

voxzoom_rotconst:	dc.l	0
voxzoom_zoomconst:	dc.l	0
voxzoom_level:		dc.l	15000

		section	bss

voxzoom_chunky:		ds.b	160*120


		section	text
		