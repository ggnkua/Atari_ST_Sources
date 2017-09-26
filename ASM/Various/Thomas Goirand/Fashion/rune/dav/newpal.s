*-------------------------------------------------------------------------*

		****
new_palette:
		rts
		
		lea	_sys_dac,a0
		lea	.scale_1,a1
		lea	.scale_2,a2
		
		move.l	#$00ffffff,(a0)+
		move.l	#$00000000,(a0)+
		
		moveq	#5,d0
.red		
		moveq	#6,d1
.green		
		moveq	#5,d2
.blue		
		clr.b	(a0)+
		move.b	(a1,d0.w),(a0)+
		move.b	(a2,d1.w),(a0)+
		move.b	(a1,d2.w),(a0)+
		
		dbf	d2,.blue
		dbf	d1,.green
		dbf	d0,.red
		
		clr.l	(a0)+
		clr.l	(a0)+
		
		pea	_sys_dac
		bsr	_install_lut
		lea	4(sp),sp
		
		rts

		****
		
.scale_1		dc.b	24,64,108,152,196,236
.scale_2		dc.b	20,56,92,128,164,204,240
		even
		
		****
		****

		; super niveaux de gris
		
		lea	_sys_dac,a0
		
		move.l	#$00ffffff,(a0)+
		move.l	#$00000000,(a0)+
		
		moveq	#(256/4)-2,d0
		moveq	#0,d1
.hop		
		move.l	d1,d2
		addq.l	#4,d2
		
		clr.b	(a0)+
		move.b	d1,(a0)+
		move.b	d1,(a0)+
		move.b	d1,(a0)+
		
		;clr.b	(a0)+
		;move.b	d2,(a0)+
		;move.b	d1,(a0)+
		;move.b	d1,(a0)+
		;
		;clr.b	(a0)+
		;move.b	d1,(a0)+
		;move.b	d2,(a0)+
		;move.b	d1,(a0)+
		;
		;clr.b	(a0)+
		;move.b	d1,(a0)+
		;move.b	d1,(a0)+
		;move.b	d2,(a0)+
		
		clr.l	(a0)+
		clr.l	(a0)+
		clr.l	(a0)+
		
		addq.l	#4,d1
		dbf	d0,.hop
		
		
		clr.l	(a0)+
		clr.l	(a0)+
		
		pea	_sys_dac
		bsr	_install_lut
		lea	4(sp),sp
		
		rts
		
		****
		****
		
