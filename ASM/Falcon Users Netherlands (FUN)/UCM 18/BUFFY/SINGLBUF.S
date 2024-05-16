* flickerling animation (without doublebuffer).
* A little demonstration by earx/fun.
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

* Initialize screenaddresses.
	move.l	#screen_buffer+255,d0		* Get bufferaddress+255 in d0.
	sub.b	d0,d0				* Make it 256 byte aligned.
	move.l	d0,physical_screen		* Store first address.

* Execute the main loop.
main_loop:
* Draw graphics onto the logical screen.
	move.l	physical_screen,a0
	move.w	plot_word,d0			* Get piece-of-graphics.
	rol.w	#2,d0				* Rotate it round a bit.
	move.w	d0,plot_word			* Store modified piece-of-graphics.

	move.w	d0,d1
	swap	d0
	move.w	d1,d0
	move.w	#200-1,d7
plot_loop:
	REPT	40
	move.l	d0,(a0)+
	ENDR
	dbra	d7,plot_loop

	move.l	physical_screen,d0
	lsr.w	#8,d0
	move.l	d0,$ffff8200.w

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

	DATA

plot_word:
	DC.W	%1000000000000000		* Piece of graphics to be reproduced.

	BSS

old_screenaddress:
	DS.L	1				* Here we store the old GEM screenaddress.
old_palette_table:
	DS.W	16				* Here we store the old GEM palette.
physical_screen:
	DS.L	1				* Address of physical (visible) screen.
screen_buffer:
	DS.B	256				* This for alignment on 256-byte boundary.
	DS.B	32000				* Memory to hold one ST-LOW screen.
