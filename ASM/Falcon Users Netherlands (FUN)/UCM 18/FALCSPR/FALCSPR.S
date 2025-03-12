* Falcon highcolor sprites.
* A little demonstration by earx/fun.
* Please run in 320*200 highcolor.

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

* Initialize screenaddresses.
	move.l	#screen_buffer+255,d0		* Get bufferaddress+3 in d0.
	andi.b	#%11111100,d0			* Make it longword aligned.
	move.l	d0,physical_screen		* Store first address.
	addi.l	#320*200*2,d0			* Move to next screenaddress.
	move.l	d0,logical_screen		* Store second address.

* Execute the main loop.
main_loop:
* Draw graphics onto the logical screen.
	move.l	logical_screen,a0
	bsr	PLOT_SPRITE

* Swap screenbuffers.
	move.l	logical_screen,d0
	move.l	physical_screen,logical_screen
	move.l	d0,physical_screen

* Set new screenaddress.
	move.b	d0,d1
	lsr.w	#8,d0
	move.l	d0,$ffff8200.w
	move.b	d1,$ffff820d.w

* Wait for the VBL...
	move.w	#37,-(sp)
	trap	#14
	addq	#2,sp

	cmpi.b	#$39,$fffffc02.w		* Spacebar pressed?
	bne	main_loop			* If not, keep looping.

* Restore old screenaddress.	
	move.l	old_screenaddress,d0
	move.b	d0,d1
	lsr.w	#8,d0
	move.l	d0,$ffff8200.w
	move.b	d1,$ffff820d.w

* Terminate program.
	clr.w	-(sp)
	trap	#1

* Plots a highcolor sprite (complete with mask) onscreen.
* INPUT: a0: screenaddress
PLOT_SPRITE:
	lea	sprite_mask,a1
	lea	sprite_data,a2
	movea.l	a0,a6
	moveq	#9-1,d7

yloop:	move.w	(a1)+,d0
	moveq	#16-1,d6

pixelloop:
	add.w	d0,d0
	addq	#2,a6
	dbcs	d6,pixelloop
	bcc.s	end_pixelloop
	move.w	(a2)+,(a6)
	dbra	d6,pixelloop
end_pixelloop:

	lea	640(a0),a0
	movea.l	a0,a6
	dbra	d7,yloop
	rts

	DATA

sprite_mask:
	DC.W	%0000010110100000
	DC.W	%0000010110100000
	DC.W	%0000010110100000
	DC.W	%0000100110010000
	DC.W	%0000100110010000
	DC.W	%0000100110010000
	DC.W	%0001000110001000
	DC.W	%0010000110000100
	DC.W	%1100000110000011

sprite_data:
	DC.W	$ffff,$ffff,$ffff,$ffff,$ffff
	DC.W	$ffff,$ffff,$ffff,$ffff,$ffff
	DC.W	$ffff,$ffff,$ffff,$ffff,$ffff
	DC.W	$ffff,$ffff,$ffff,$ffff,$ffff
	DC.W	$ffff,$ffff,$ffff,$ffff,$ffff
	DC.W	$ffff,$ffff,$ffff,$ffff,$ffff
	DC.W	$ffff,$ffff,$ffff,$ffff,$ffff
	DC.W	$ffff,$ffff,$ffff,$ffff,$ffff

	BSS

old_screenaddress:
	DS.L	1				* Here we store the old GEM screenaddress.
logical_screen:
	DS.L	1				* Address of logical (invisible) screen.
physical_screen:
	DS.L	1				* Address of physical (visible) screen.
screen_buffer:
	DS.L	1				* This for alignment on longword boundary.
	DS.W	320*200				* Memory to hold one 320*200 highcolor screen.
	DS.W	320*200				* Memory to hold one 320*200 highcolor screen.