font_col	equ	$00a000f0
scroll_width	equ	320
no_scan_lines	equ	100
scroller_offset	equ	2*7+320*(201-no_scan_lines)+0*16


atari_pal	equ	$ffff9800
new_mode	equ	$23

AScale_Pal
	Subq.w	#1,d7
	Move.l	d0,d1
	Move.l	d0,d2
.Loop	moveq	#0,d3
	moveq	#0,d4
	moveq	#0,d5
	Move.b	(a0)+,d3
	Move.b	(a0)+,d4
	Move.b	(a0)+,d5
	Move.b	(a0)+,d5
	Mulu	d0,d3
	Mulu	d1,d4
	Mulu	d2,d5
	Lsr.w	#8,d3
	Lsr.w	#8,d4
	Lsr.w	#8,d5
	Move.b	d3,(a1)+
	Move.b	d4,(a1)+
	Clr.b	(a1)+
	Move.b	d5,(a1)+
	Dbra	d7,.Loop
	Rts


Andys_Part
;	bsr	go_big
	bsr.s	program
;	bsr	go_small
	rts

A_Wait_Vbl
	move.l	d0,-(sp)
	move.w	clock(pc),d0
.lp	cmp.w	clock(pc),d0
	beq.s	.lp
	move.l	(sp)+,d0
	rts
program
	move.l	$70.w,-(sp)
	move.l	#new4,$70.w
;	bsr.s	hbl_on
	bsr	Amain
;	bsr	hbl_off
	move.l	(sp)+,$70.w
	rts
	
hbl_on	lea	hbl_off(pc),a0
	move.l	$120.w,oldtb-hbl_off(a0)
	move.l	$70.w,old4-hbl_off(a0)
	move.l	$118.w,oldkey-hbl_off(a0)
	move.b	$fffffa07.w,old07-hbl_off(a0)
	move.b	$fffffa09.w,old09-hbl_off(a0)
	move.b	$fffffa0f.w,old0f-hbl_off(a0)
	move.b	$fffffa11.w,old11-hbl_off(a0)
	move.b	$fffffa1b.w,old1b-hbl_off(a0)
	move.b	$fffffa13.w,old13-hbl_off(a0)
	move.b	$fffffa15.w,old15-hbl_off(a0)

	and.b	#$df,$fffffa09.w
	and.b	#$fe,$fffffa07.w
	move.l	#new4,$70.w
	move.l	#newtb,$120.w
	or.b	#$40,$fffffa09.w
	or.b	#1,$fffffa13.w
	or.b	#1,$fffffa07.w
	move.b	#1,$fffffa21.w
	bclr.b	#3,$fffffa17.w
	rts

hbl_off	move.w	sr,-(sp)
	move.w	#$2700,sr
labela	move.b	#8,$fffffa07.w
old07	equ	labela+3
labelb	move.b	#8,$fffffa09.w
old09	equ	labelb+3
labelc	move.b	#8,$fffffa0f.w
old0f	equ	labelc+3
labeld	move.b	#8,$fffffa11.w
old11	equ	labeld+3
labele	move.b	#8,$fffffa1b.w
old1b	equ	labele+3
labelf	move.b	#8,$fffffa13.w
old13	equ	labelf+3
labelg	move.b	#8,$fffffa15.w
old15	equ	labelg+3
labelh	move.l	#8,$120.w
oldtb	equ	labelh+2
labeli	move.l	#8,$70.w
old4	equ	labeli+2
labelj	move.l	#8,$118.w
oldkey	equ	labelj+2
	move.w	(sp)+,sr
	rts

go_big	lea	store,a0
	lea	(atari_pal).w,a1
	move.w	#256-1,d0
.lp	move.l	(a1),(a0)+
	clr.l	(a1)+
	dbf	d0,.lp
	move.b	$ffff8201.w,(a0)+
	move.b	$ffff8203.w,(a0)+
	move.b	$ffff820d.w,(a0)+
	move.b	$ffff8265.w,(a0)+
	move.b	$ffff820f.w,(a0)+
	rts

go_small
	lea	store,a0
	lea	(atari_pal).w,a1
	moveq	#256/2-1,d0
.lp	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	dbf	d0,.lp
	move.b	(a0)+,$ffff8201.w
	move.b	(a0)+,$ffff8203.w
	move.b	(a0)+,$ffff820d.w
	move.b	(a0)+,$ffff8265.w
	move.b	(a0)+,$ffff820f.w
	rts

old_phys	ds.l	1
old_log		ds.l	1




newtb	rte

new4	addq.w	#1,clock
	movem.l	d0-a6,-(sp)
	move.l	tv_addr1(pc),-(sp)
	move.b	1(sp),$ffff8201.w		tv set up
	move.b	2(sp),$ffff8203.w		tv set up
	move.b	3(sp),$ffff820d.w
	addq.l	#4,sp
	lea	(atari_pal),a1
	lea	Ffade_pal,a0
	move.w	#256-1,d0
.lp	move.l	(a0)+,(a1)+
	dbf	d0,.lp
	Jsr	Nt_Vbl
	movem.l	(sp)+,d0-a6
	rte
	



Amain	move.l	#tv_pic,d0
	and.b	#%11111100,d0
	move.l	d0,tv_addr1
	move.l	d0,a0
	lea	star_piccy,a2
	move.w	#64000/4-1,d0
.lp	move.l	(a2)+,(a0)+
	dbf	d0,.lp		clear screens
	bsr	A_Wait_Vbl
	lea	Afade_pal,a1
	move.w	#256/2-1,d0
.ll	move.l	(a2)+,(a1)+
	dbf	d0,.ll
	move.l	#font_col,d0
	move.w	#256/2-1,d0
.ll1	move.l	d0,(a1)+
	dbf	d0,.ll1
	bsr	Afade_in
.loop	bsr	A_Wait_Vbl
	bsr	A_Wait_Vbl
	bsr	A_Wait_Vbl
	bsr	A_Wait_Vbl
	bsr	draw_image
	bsr	update_scroller
	cmp.w	#420,scroll_line
	bne.s	.loop
	bsr	Afade_out
	rts

Afade_out
	Move.w	#256,-(sp)
.Loop	Bsr	A_wait_Vbl
	lea	Afade_pal,a0
	lea	Ffade_pal,a1
	Move.w	#256,d7
	Move.w	(sp),d0
	Bsr	AScale_Pal
	Subq.w	#4,(sp)
	Bne.s	.Loop
	Addq.l	#2,sp
	Moveq	#0,d0
	lea	Afade_pal,a0
	lea	Ffade_pal,a1
	Move.w	#256,d7
	Bsr	AScale_Pal
	Rts	

Afade_In
	Move.w	#0,d0
.Loop	Bsr	A_wait_Vbl
	lea	Afade_pal,a0
	lea	Ffade_pal,a1
	Move.w	#256,d7
	Bsr	AScale_Pal
	Addq.w	#4,d0
	Cmp.w	#260,d0
	Bne.s	.Loop
	Rts	

update_scroller
	addq.w	#1,scroll_line
	rts



draw_image
	move.l	tv_addr1(pc),a0
	lea	scroller_offset(a0),a0
	move.w	scroll_line(pc),d1
	lea	load_font,a3
	lea	y_tab,a4
	move.w	#no_scan_lines-1,d0
.lp	bsr	a_scan_line
	add.w	(a4)+,d1
	dbf	d0,.lp
	rts

a_scan_line
	cmp.w	#200,d1
	blt.s	.no_show
	cmp.w	#400,d1
	bge.s	.no_show
	bra	.shrink_line
.no_show
	moveq	#0,d4
acid	set	0
	rept	20
	move.w	d4,acid(a0)
acid	set	acid+16
	endr
	lea	320(a0),a0
	rts

.shrink_line
	movem.l	d0-d1/a0-a3,-(sp)
	moveq	#0,d2
	moveq	#0,d3
	move.w	#no_scan_lines-1,d3
	sub.w	d0,d3
	mulu	#8000,d3
	move.w	d1,d2
	mulu	#40,d2
	add.l	d3,d2
	lea	(a3,d2.l),a3
acid	set	0
	rept	20
	move.w	(a3)+,acid(a0)
acid	set	acid+16
	endr
	movem.l	(sp)+,d0-d1/a0-a3
	lea	320(a0),a0
	rts

y_tab	
	rept	5
	dc.w	3
	endr
	rept	10
	dc.w	2,3
	endr
	rept	10
	dc.w	2
	endr
	rept	10
	dc.w	2,1,2
	endr
	rept	10
	dc.w	1,2
	endr
	rept	10
	dc.w	1,2,1
	endr
	rept	no_scan_lines
	dc.w	1
	endr
	rept	no_scan_lines
	dc.w	1,2
	endr

scroll_line	dc.w	0

tv_addr1	ds.l	1
clock		ds.w	1
key_code	ds.b	1
left_to_read	ds.b	1
ikbd_buffer	ds.b	7
store		ds.l	300
Afade_Pal	Ds.l	256
FFade_Pal	Ds.l	256
