*------------------------8<-------------------------------------------------
* Double your screen size on an STe (Low=320*400, Med=640*400, Hi=640*800)
* By Paul Grenfell 1995 - Idea taken from Double2.Prg by Lars-Eric osterud

* Here is a very short and simple routine to double the vertical screen
* resolution on an STe. This is done by interlacing using the new video
* shifter registers.

* First we tell the video-shifter to make the screen twice as long, so
* instead of being 160 bytes long it is 320. The shifter can still only fit
* 160 bytes on screen per line so what we see is only half the screen - All
* the even lines are shown and the odd lines are skipped.
* Because the screen is now twice as big, the screen size in bytes must
* also grow from 32000 to 64000.

* We now have a screen that is twice as high (320*400 in low-res) , takes
* up twice as much memory and only the even lines are visible, great!

* Next we must install the VBI routine that actually does the interlacing.
* This works by telling the shifter to draw the even lines for 1/50th of a
* second (1 VBI) then the odd lines for 1/50th of a second (The next VBI).

* To use the routine just call 'init_double' to install and 'exit_double'
* to remove. Both calls must be made in supervisor mode because they
* change protected memory.

* To draw anything on the screen just access it exactly as you would
* normally - Just remember that you can now fit twice as much on  =)

* I hope that makes sense! Anyway, if you still want to know how it works
* (And the above doesnt help) or for any other reason then contact me at
* the email below. Oh, and make sure you play+register Pothole2...



***************************************************************************
* Install the routine and set up screen mode
init_double
	move.b	$ffff820f,old_overline	Save old 'over-line' count
	move.b	#160/2,$ffff820f	Set to 160 extra bytes per line
	move.l	$70,old_vbi		Back up the old vbi
	move.l	#double_vbi,$70		Patch in the new one
	rts


***************************************************************************
* Remove the routine and restore screen modes
exit_double
	move.b	old_overline,$ffff820f	Restore old 'over-line'
	move.l	old_vbi,$70		Restore old VBI
	rts


***************************************************************************
* The actual VBI routine - Works on one screen only, to create double-
* buffering you'll need to edit it slightly and reserve two sections of
* memory for the screens (128000 bytes!!!)
double_vbi
	move.l	a0,-(sp)		Save reggie
	lea	screen,a0		Point to screen base

	eor.w	#160,offset+2		These two two lines alternatively
offset	add.w	#$160,a0		add 160 then 0 to the screen base
	move.l	a0,temp_store		Temporarily store the screen base
	move.b	temp_store+1,$ffff8201	Screen base - Hi byte
	move.b	temp_store+2,$ffff8203	Screen base - Med byte
	move.b	temp_store+3,$ffff820d	Screen base - Lo byte
	movem.l	(sp)+,a0		Restore reggie

**
** Include your normal VBI routines here
**

	rte



***************************************************************************
* Variables
temp_store	dc.l	0

old_vbi		ds.l	1		Old VBI routines address
old_overline	ds.l	1		Old 'over-line' value



***************************************************************************
* Screen memory
screen	ds.b	64000			The actual screen area


