;--------------------------------------------------------------------------
; Full Screen Horizontal Parallax scrolling!
; Blocks have already been preshifted (Sorry about the pattern!!!).
; Programmed by Tony -B- of the Untouchables
; Try the cursor keys left & right!!!!
; Devpac v2.25, tabs =10
;--------------------------------------------------------------------------

	opt	x+,o+,ow-


height		=	16	;height of pattern in pixels



	movea.l	4(sp),a5
	pea	$200.w
	pea	(a5)
	pea	$4a0000
	trap	#1
	lea	$c(sp),sp

	pea	0.w
	move	#32,-(sp)
	trap	#1
	addq.l	#6,sp
	move.l	d0,old_stk

	move.b	#$12,$fffffc02.w
	clr.b	$484.w

	bsr	sync		;wait so no resolution errors!!
	clr.b	$ffff8260.w
	move.l	$44e.w,old44e
	
	move.l	#blox_pal,$45a.w

*---------	
	move.l	#scr_buff,d0
	add.l	#256,d0
	clr.b	d0		;ensure 256 boundary
	move.l	d0,scr_buff
	
	lea	screens(pc),a2
	rept	4
	move.l	d0,(a2)+		;store new screen positions
	add.l	#$7d00,d0
	endr

	lea	screens2(pc),a3	;now for reverse!!!
	move.l	-(a2),(a3)+
	move.l	-(a2),(a3)+
	move.l	-(a2),(a3)+
	move.l	-(a2),(a3)+
*---------

	bsr.s	gen_4_screens

*---------
scan	bsr.s	sync

	bsr	swap_screens

	cmp.b	#$39,$fffffc02.w
	bne.s	scan
*---------

	move.b	#8,$fffffc02.w
	move.l	#gempal,$45a.w
	move.b	#-1,$484.w
	
	move.l	old44e(pc),d0
	lsr	#8,d0
	move.l	d0,$ffff8200.w
	
	move.l	old_stk(pc),-(sp)
	move	#32,-(sp)
	trap	#1
	addq.l	#6,sp
	
	clr	-(sp)
	trap	#1


*---------
sync	move	d0,-(sp)
	move	$468.w,d0
.sync	cmp	$468.w,d0
	beq.s	.sync
	move	(sp)+,d0
	rts


*---------construct 4 screens: each with the bottom pattern shifted
*---------2 pixels to the right from the last one, and also the
*---------top pattern shifted 4 pixels from the previous one!!!
gen_4_screens
	lea	blocks(pc),a0	;addr of block 1
	lea	8(a0),a1		; ''  ''  ''   2
	lea	16(a0),a2		; ''  ''  ''   3
	lea	24(a0),a3		; ''  ''  ''   4

	lea	screens(pc),a4

	move.l	(a4)+,a5		;get 1st screen
	movea.l	a5,a6
	moveq	#height-1,d0

*---------i'll draw in 4 planes although this pattern uses *only*
*---------the 4th plane!!
make_row1
i	set	0
	rept	20
	move.l	(a0),i(A5)	;make a row onto screen 1
	move.l	4(a0),i+4(A5)
i	set	i+8
	endr
	lea	160(a5),a5
	lea	160(a0),a0
	dbf	d0,make_row1
	
	move	#(32000-(160*height))/4-1,d0
	lea	160*16(a6),a5
copy1
	move.l	(a6)+,(a5)+	;fill screen with block
	move.l	(a6)+,(a5)+
	dbf	d0,copy1


	move.l	(a4)+,a5		;get 2nd screen
	movea.l	a5,a6
	moveq	#height-1,d0

make_row2
i	set	0
	rept	20
	move.l	(a1),i(A5)	;and so on ....
	move.l	4(a1),i+4(A5)
i	set	i+8
	endr
	lea	160(a5),a5
	lea	160(a1),a1
	dbf	d0,make_row2
	
	move	#(32000-(160*height))/4-1,d0
	lea	160*16(a6),a5
copy2
	move.l	(a6)+,(a5)+
	move.l	(a6)+,(a5)+
	dbf	d0,copy2


	move.l	(a4)+,a5
	movea.l	a5,a6
	moveq	#height-1,d0

make_row3
i	set	0
	rept	20
	move.l	(a2),i(A5)
	move.l	4(a2),i+4(A5)
i	set	i+8
	endr
	lea	160(a5),a5
	lea	160(a2),a2
	dbf	d0,make_row3
	
	move	#(32000-(160*height))/4-1,d0
	lea	160*16(a6),a5
copy3
	move.l	(a6)+,(a5)+
	move.l	(a6)+,(a5)+
	dbf	d0,copy3


	move.l	(a4)+,a5
	movea.l	a5,a6
	moveq	#height-1,d0

make_row4
i	set	0
	rept	20
	move.l	(a3),i(A5)
	move.l	4(a3),i+4(A5)
i	set	i+8
	endr
	lea	160(a5),a5
	lea	160(a3),a3
	dbf	d0,make_row4
	
	move	#(32000-(160*height))/4-1,d0
	lea	160*16(a6),a5
copy4
	move.l	(a6)+,(a5)+
	move.l	(a6)+,(a5)+
	dbf	d0,copy4

	rts


*---------flip between the 4 screens!!!
swap_screens
	move.l	scroff(pc),a0
	tst.l	(a0)		;flip 4 screens yet??
	bpl.s	ok
direc	lea	screens,a0

*---------here we do a quick scan whether to change direction...??
	cmp.b	#$4b,$fffffc02.w	;left cursor?
	bne.s	scan1
	move.l	#screens2,direc+2
scan1	cmp.b	#$4d,$fffffc02.w	;right cursor?
	bne.s	ok
	move.l	#screens,direc+2
ok
	move.l	(a0)+,d0		;get screen addr
	move.l	a0,scroff

	lsr	#8,d0
	move.l	d0,$ffff8200.w	;set screen addr
	
	rts



*---------
	data
old44e	dc.l	0
old_stk	dc.l	0

gempal	dc.w	$777,$700,$070,$000,$007,$707,$077,$555
	dc.w	$333,$733,$373,$773,$337,$737,$377,$000

blox_pal	dc.w	$000,$000,$000,$000,$000,$000,$000,$000
	dc.w	$000,$210,$222,$333,$111,$2C0,$130,$020

scroff	dc.l	screens
screens	dc.l	0,0,0,0,-1	;left to right
screens2	dc.l	0,0,0,0,-1	;right to left

blocks	incbin	blox.dat

scr_buff
