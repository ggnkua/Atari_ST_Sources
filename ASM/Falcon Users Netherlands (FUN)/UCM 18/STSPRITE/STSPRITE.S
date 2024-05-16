* realtime shifted sprites.
* A little demonstration by earx/fun.
* Thanx to Tinker/TNH for the picture.
* Please run in ST-LOW.

* Change to supervisor-mode.
	clr.l	-(sp)
	move.w	#32,-(sp)
	trap	#1
	addq.l	#6,sp

* Save old screenaddress.
	move	#2,-(sp)
	trap	#14
	addq	#2,sp
	move.l	d0,old_screenaddress

* Save old palette.
	lea	$ffff8240.w,a1
	lea	old_palette_table,a0
	moveq	#16-1,d7
save_palette_loop:
	move.w	(a1)+,(a0)+
	dbra	d7,save_palette_loop

* Initialize sprite.
	lea	degas_data,a3
	lea	sprite_pal_table,a2
	lea	mask_buffer,a1
	lea	bitplane_buffer,a0
	move.w	#4,d0
	move.w	#0,d1
	move.w	#2,d2
	move.w	#16,d3
	bsr	INIT_SPRITE

* Set new palette.
	lea	$ffff8240.w,a0
	lea	sprite_pal_table,a1
	moveq	#16-1,d7
new_palette_loop:
	move.w	(a1)+,(a0)+
	dbra	d7,new_palette_loop

* Initialize screenaddresses.
	move.l	#screen_buffer+255,d0		* Get bufferaddress+255 in d0.
	sub.b	d0,d0				* Make it 256 byte aligned.
	move.l	d0,physical_screen		* Store first address.
	addi.l	#160*200,d0			* Move to next screenaddress.
	move.l	d0,logical_screen		* Store second address.

* Execute the main loop.
main_loop:
* Draw graphics onto the logical screen.
	move.w	#0,d0
	move.w	#0,d1
	movea.l	logical_screen,a2
	lea	bitplane_buffer,a1
	lea	mask_buffer,a0
	move.w	#2,d6
	move.w	#16,d7
	bsr	DRAW_4BPLSPRITE

	move.w	#5,d0
	move.w	#5,d1
	movea.l	logical_screen,a2
	lea	bitplane_buffer,a1
	lea	mask_buffer,a0
	move.w	#2,d6
	move.w	#16,d7
	bsr	DRAW_4BPLSPRITE

	move.w	#9,d0
	move.w	#9,d1
	movea.l	logical_screen,a2
	lea	bitplane_buffer,a1
	lea	mask_buffer,a0
	move.w	#2,d6
	move.w	#16,d7
	bsr	DRAW_4BPLSPRITE

	move.w	#12,d0
	move.w	#12,d1
	movea.l	logical_screen,a2
	lea	bitplane_buffer,a1
	lea	mask_buffer,a0
	move.w	#2,d6
	move.w	#16,d7
	bsr	DRAW_4BPLSPRITE

	move.w	#14,d0
	move.w	#14,d1
	movea.l	logical_screen,a2
	lea	bitplane_buffer,a1
	lea	mask_buffer,a0
	move.w	#2,d6
	move.w	#16,d7
	bsr	DRAW_4BPLSPRITE

	move.w	#15,d0
	move.w	#15,d1
	movea.l	logical_screen,a2
	lea	bitplane_buffer,a1
	lea	mask_buffer,a0
	move.w	#2,d6
	move.w	#16,d7
	bsr	DRAW_4BPLSPRITE

* Swap screenbuffers.
	move.l	logical_screen,d0
	move.l	physical_screen,logical_screen
	move.l	d0,physical_screen

* Set new screenaddress.
	lsr.w	#8,d0
	move.l	d0,$ffff8200.w

* Wait for the VBL...
	move.w	#37,-(sp)
	trap	#14
	addq	#2,sp

	cmpi.b	#$39,$fffffc02.w		* Spacebar pressed?
	bne	main_loop			* If not, keep looping.

* Restore old palette.
	lea	$ffff8240.w,a0
	lea	old_palette_table,a1
	moveq	#16-1,d7
restore_palette_loop:
	move.w	(a1)+,(a0)+
	dbra	d7,restore_palette_loop

* Restore old screenaddress.	
	move.l	old_screenaddress,d0
	lsr.w	#8,d0
	move.l	d0,$ffff8200.w

* Terminate program.
	clr.w	-(sp)
	trap	#1

* Gets a sprite from a Degas PI1.
* INPUT: d0.w: X chunk (0...19)
*        d1.w: Y line (0...199)
*        d2.w: chunks to fetch (1...20)
*        d3.w: lines to fetch (1...200)
*        a0: bitplanes output
*        a1: mask output
*        a2: palette output
*        a3: degas PI1
INIT_SPRITE:
* Extract palette.
	addq	#2,a3
	moveq	#16-1,d7
init_sprite_pal_loop:
	move.w	(a3)+,(a2)+
	dbra	d7,init_sprite_pal_loop
* Extract bitplanes and mask.
	lsl.w	#3,d0
	adda.w	d0,a3
	mulu.w	#160,d1
	adda.l	d1,a3
	subq.w	#1,d2
	subq.w	#1,d3
init_sprite_y_loop:
	movea.l	a3,a4
	move.w	d2,d7
init_sprite_x_loop:
	movem.w	(a4)+,d0/d1/d5/d6
	move.w	d0,(a0)+
	move.w	d1,(a0)+
	move.w	d5,(a0)+
	move.w	d6,(a0)+
	or.w	d6,d0
	or.w	d5,d0
	or.w	d1,d0
	not.w	d0
	move.w	d0,(a1)+
	dbra	d7,init_sprite_x_loop
	lea	160(a3),a3
	dbra	d3,init_sprite_y_loop
	rts

* Draws a 4 bitplane sprite at any position on screen. This routine is for
* 320*200 ST-LOW.
* INPUT: d0.w: x position of sprite on screen (left side)
*        d1.w: y position of sprite on screen (top side)
*        d6.w: number of 16pixel X blocks to do
*        d7.w: number of Y lines to to
*        a0: address of maskdata
*        a1: address of bitmapdata
*        a2: screen start address
DRAW_4BPLSPRITE:
	move.w	d0,d2				* / Calculate the
	andi.w	#%111111110000,d0		* | number of bits
	sub.w	d0,d2				* \ to shift right.
	lsr.w	#1,d0				* / Add x-position to
	adda.w	d0,a2				* \ screenaddress.
	mulu.w	#160,d1				* / Add y-position to
	adda.l	d1,a2				* \ screenaddress.
	move.w	d6,d1				* / Prepare
	lsl.w	#3,d1				* | offset
	move.l	#160,d4				* | to next
	sub.w	d1,d4				* \ screenline.
	subq.w	#1,d7				* Adjust for dbra.
	subq.w	#1,d6				* Adjust for dbra.
	move.w	d6,d5				* Backup xloopcount in d5.w.
	moveq	#16,d1				* Size of two chunks.

yloop:

xloop:	moveq	#$ffffffff,d0			* Prepare for maskshifting.
	move.w	(a0)+,d0			* Get 16pixel mask in d0.w.
	ror.l	d2,d0				* Shift it!
	and.w	d0,(a2)+			* Mask bitplane 0.
	and.w	d0,(a2)+			* Mask bitplane 1.
	and.w	d0,(a2)+			* Mask bitplane 2.
	and.w	d0,(a2)+			* Mask bitplane 3.
	swap	d0				* Get overspill in loword.
	and.w	d0,(a2)+			* Mask overspill bitplane 0.
	and.w	d0,(a2)+			* Mask overspill bitplane 1.
	and.w	d0,(a2)+			* Mask overspill bitplane 2.
	and.w	d0,(a2)+			* Mask overspill bitplane 3.
	suba.l	d1,a2				* Return to blockstart.
	REPT	4				* Asm directive: repeat code
	moveq	#0,d0				* Prepare for bitmapshifting.
	move.w	(a1)+,d0			* Get bitplaneword in d0.w.
	ror.l	d2,d0				* Shift it.
	or.w	d0,(a2)+			* Paint bitplane 0.
	swap	d0				* Get overspill in loword.
	or.w	d0,6(a2)			* Paint overspillbitplane 0.
	ENDR
	dbra	d6,xloop			* Loop until blocks done.

	adda.l	d4,a2				* Goto next screenline.
	move.w	d5,d6				* Restore xloop counter.
	dbra	d7,yloop			* Loop until lines done.
	rts

	DATA

degas_data:
	INCBIN	PUNGFONT.PI1

	BSS

old_screenaddress:
	DS.L	1				* Here we store the old GEM screenaddress.
logical_screen:
	DS.L	1				* Address of logical (invisible) screen.
physical_screen:
	DS.L	1				* Address of physical (visible) screen.
sprite_pal_table:
	DS.W	16				* Here we store the sprite palette.
old_palette_table:
	DS.W	16				* Here we store the old GEM palette.
bitplane_buffer:
	DS.W	1000				* Here we store the sprite bitplanes.
mask_buffer:
	DS.W	100				* Here we store the sprite mask.
screen_buffer:
	DS.B	256				* This for alignment on 256-byte boundary.
	DS.B	32000				* Memory to hold one ST-LOW screen.
	DS.B	32000				* Memory to hold one ST-LOW screen.