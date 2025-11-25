start
real_time
	move.l	4(sp),a5
	move.l	$C(a5),a0
	add.l	$14(a5),a0
	add.l	$1c(a5),a0
	move.l	a0,-(sp)
	move.l	a5,-(sp)
	clr.w	-(sp)
	move.w	#$4a,-(sp)
	trap	#1
	lea	$c(sp),sp
init_appl
	moveq	#0,d0
	bsr	aes
	Jmp	My_Start(pc)
aes_save_type
	lea	aes_save_text(pc),a0
	bra	aes_alert

hide_mouse
	move.w	#256,d0
	bra.s	graf_mouse
show_mouse
	move.w	#257,d0
graf_mouse
	move.w	d0,pts_in
	moveq	#1,d0
	bsr.s	aes
	rts


aes_alert
	moveq	#1,d0
	move.w	d0,pts_in
	moveq	#2,d0
	move.l	a0,addr_in
	bsr.s	aes
	move.w	pts_out(pc),d0
	rts


aes_data
	dc.l	$0a000100
	dc.l	$4e010101
	dc.l	$34010101
	dc.l	$5a000202

aes	lea	aes_data(pc),a0
	asl.b	#2,d0
	move.l	(a0,d0.w),d0
	move.l	a5,-(sp)
	lea	aes_block(pc),a0
	move.l	(a0),a1
	clr.l	(a1)+
	clr.l	(a1)+
	clr.w	(a1)
	movep.l	d0,-7(a1)
	move.l	a0,d1
	move.w	#$c8,d0
	trap	#2
	move.l	(sp)+,a5
	rts
	
	

file_select
	lea	2+dir_str(pc),a0
	clr.l	-2(a0)
	clr.w	-(sp)
	move.l	a0,-(sp)
	move.w	#71,-(sp)
	trap	#1
	addq.l	#8,sp
	move.w	#25,-(sp)
	trap	#1
	addq.l	#2,sp
	add.b	#"A",d0
	lea	dir_str(pc),a0
	move.b	d0,(a0)+
	move.b	#":",(a0)+
	tst.b	(a0)
	bne.s	.dir_ok
	lea	dir_str+2(pc),a0
	bra.s	f_mask
	move.w	#"\*",(a0)+
.dir_ok	lea	dir_str(pc),a0
.d_lp1	move.b	(a0)+,d0
	bne.s	.d_lp1
	subq.l	#1,a0
f_mask	lea	extension(pc),a1
	move.b	#"\",(a0)+
	move.b	#"*",(a0)+
	move.b	(a1)+,(a0)+
	move.b	(a1)+,(a0)+
	move.b	(a1)+,(a0)+
	move.b	(a1)+,(a0)+
	clr.b	(a0)+
	lea	sel_str(pc),a0
	lea	addr_in(pc),a4
	move.l	#dir_str,(a4)+
	move.l	a0,(a4)+
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	moveq	#3,d0
	bsr	aes
	moveq	#0,d1			def not FILE NOT FOUND -33
	moveq	#-1,d0
	lea	pts_out(pc),a0
	tst.w	(a0)+
	beq.s	.no_fsel
	tst.w	(a0)
	beq.s	.no_fsel
	lea	full_file_name(pc),a2
	lea	dir_str(pc),a0
.f_star	move.b	(a0)+,d0
	move.b	d0,(a2)+
	cmp.b	#"*",d0
	bne.s	.f_star
	subq.l	#1,a2
	lea	sel_str(pc),a1
.f_copy	move.b	(a1)+,d0
	move.b	d0,(a2)+
	bne.s	.f_copy
	tst.b	check_exists
	beq.s	.not_found		 really no need to check
	move.w	#-1,-(sp)
	pea	full_file_name(pc)
	move.w	#78,-(sp)
	trap	#1
	addq.l	#8,sp
	move.w	d0,d1
	moveq	#0,d0
	cmp.w	#-33,d1
	bne.s	.not_found
.no_fsel
	moveq	#-1,d0
	rts
.not_found
	moveq	#0,d0
	rts


finish	clr.w	-(sp)
	trap	#1

	
extension	dc.b	".LBM"
aes_save_text
	dc.b	"[1][ Save data in which format  |][ SPR | PAL | PI0 ]",0
aes_block
	dc.l	control,global,pts_in
	dc.l	pts_out,addr_in,addr_out

new_palette	dcb.l	256,$ffff00ff



check_exists	ds.b	1
dir_str		ds.b	256		aes information
sel_str		ds.b	12
control		ds.w	$f
global		ds.w	$f
pts_in		ds.w	$f
pts_out		ds.w	$f
addr_in		ds.l	$f
addr_out	ds.l	$f


full_file_name	ds.b	200	filenames etc.
