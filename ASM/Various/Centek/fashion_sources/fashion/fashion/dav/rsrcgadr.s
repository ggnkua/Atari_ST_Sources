****************************************************************

		****
		text
		****
		
		; renvoie l'adresse d'un ‚l‚ment du ressource
		
_rsrc_gaddr:
		move.l	([a0,a_global.w],5*2.w),-(sp)
		move.w	([a0,a_intin.w],0.w),-(sp)
		move.w	([a0,a_intin.w],2.w),-(sp)
		
		jsr	_rsc_gaddr
		
		move.w	#1,([a0,a_intout.w])
		move.l	d0,([a0,a_addrout.w])
		
		rts
		
		****
		
****************************************************************
		
		****
		
		rsset	3*4
_rsg_idx		rs.w	1
_rsg_type		rs.w	1
_rsg_ptr		rs.l	1
		
		****
_rsc_gaddr:	
		movem.l	a0-a1,-(sp)
		
		move.l	_rsg_ptr(sp),a1
		
		cmp.l	#"DLMN",(a1)
		beq	.new_format

		lea	.jshort(pc),a0
		
		cmp.w	#3,(a1)
		bne.s	.short
		
		lea	.jlong(pc),a0
.short		
		move.w	_rsg_type(sp),d0
		
		cmp.w	#7,d0
		blt.s	.okty
		illegal
.okty
		
		add.w	(a0,d0.w*2),a0
		
		move.w	_rsg_idx(sp),d0
		
		jsr	(a0)
.end		
		movem.l	(sp)+,a0-a1
		rtd	#8
		
		****
.gtre
		add.w	rsh_trindex(a1),a1
		move.l	(a1,d0.w*4),d0
		rts
.gobj
		add.w	rsh_object(a1),a1
		mulu.w	#24,d0
		add.l	a1,d0
		rts
.gted		
		add.w	rsh_tedinfo(a1),a1
		mulu.w	#28,d0
		add.l	a1,d0
		rts
.gicb		
		add.w	rsh_iconblk(a1),a1
		mulu.w	#36,d0
		add.l	a1,d0
		rts
.gbib		
		add.w	rsh_bitblk(a1),a1
		mulu.w	#14,d0
		add.l	a1,d0
		rts
.gfst		
		add.w	rsh_frstr(a1),a1
		move.l	(a1,d0.w*4),d0
		rts
.gfri
		add.w	rsh_frimg(a1),a1
		move.l	(a1,d0.w*4),d0
		rts
		
		********
.gtre_2
		add.l	rsh_trindex*2(a1),a1
		move.l	(a1,d0.w*4),d0
		rts
.gobj_2
		add.l	rsh_object*2(a1),a1
		mulu.w	#24,d0
		add.l	a1,d0
		rts
.gted_2		
		add.l	rsh_tedinfo*2(a1),a1
		mulu.w	#28,d0
		add.l	a1,d0
		rts
.gicb_2		
		add.l	rsh_iconblk*2(a1),a1
		mulu.w	#36,d0
		add.l	a1,d0
		rts
.gbib_2		
		add.l	rsh_bitblk*2(a1),a1
		mulu.w	#14,d0
		add.l	a1,d0
		rts
.gfst_2		
		add.l	rsh_frstr*2(a1),a1
		move.l	(a1,d0.w*4),d0
		rts
.gfri_2
		add.l	rsh_frimg*2(a1),a1
		move.l	(a1,d0.w*4),d0
		rts
		
		********

.jshort:
		dc.w	.gtre-.jshort
		dc.w	.gobj-.jshort
		dc.w	.gted-.jshort
		dc.w	.gicb-.jshort
		dc.w	.gbib-.jshort
		dc.w	.gfst-.jshort
		dc.w	.gfri-.jshort
		
		****

.jlong:
		dc.w	.gtre_2-.jlong
		dc.w	.gobj_2-.jlong
		dc.w	.gted_2-.jlong
		dc.w	.gicb_2-.jlong
		dc.w	.gbib_2-.jlong
		dc.w	.gfst_2-.jlong
		dc.w	.gfri_2-.jlong
		
		****
		
		; 0=tree
		; 1=object
		; 2=tedinfo
		; 3=iconblk
		; 4=bitblk
		; 5=free string
		; 6=free image
		
		********
.new_format
		move.w	_rsg_idx(sp),d0
		move.l	nrsh_treetbl(a1),a1
		lea	(a1,d0*8),a1
		move.l	4(a1),d0
		bra	.end
****************************************************************
