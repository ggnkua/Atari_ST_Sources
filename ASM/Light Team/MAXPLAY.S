; This is the source code for calling 'Mad Max' type musix
; It will also work with any other music that uses the same playback
; routines eg. An Cool musix used in TCB Demos !!!
;
; This is just a simple routine that sets up a new vbl handler
; to play back the music, and then exits with a 'Keep Process'
; call, so that the music will continue to play when you exit back
; to the desktop or load another GEM type program.
;
; Although all the music files ('.mus') on this disk have only got
; one tune in them, some others can have a lot more (Sometimes even
; as many as 10 in one file !!).
; To call the different tunes available from each music file, just
; change the '1' in the line 'moveq #1,d0' to whatever music number
; you want !!!
;
; If you want to use a different music, then just change the filename
; in the last line of this program to the name of any other music
; data file on this disk. 
;
; I'll probably continue to release the music files as space fillers
; on later menus, so make sure you keep this routine safe !!!
;
; Now that the rest of the menu is finished, I can tell you exactly
; which music files I managed to fit onto this disk....
;
; atomix.mus		Music from loader of atomix
; shaolin1.mus		Music from Chambers of Shaolin intro
; shaolin2.mus		Music from Chambers of Shaolin loader
; shaolin3.mus		Music from Chambers of Shaolin
; shaolin4.mus		Music from Chambers of Shaolin
; rings1.mus		Music from Rings of Medusa
; rings2.mus		Music from Rings of Medusa
;
; Zippy
;
	opt s-					no symbols
	clr.l -(sp)				dummy
	move.w #$20,-(sp)			super mode
	trap #1					call dos
	addq.l #6,sp				correct stack
	move.l d0,oldstk			save old sp
	move.l $70.w,oldint			save old vbl
	bclr #0,$484.w				no keyclick
	moveq #1,d0				music #1
	bsr music				call init
	move.l #zippy,$70.w			install new vbl
	move.w #7,-(sp)				wait key
	trap #1					call dos
	addq.l #2,sp				correct stack
	move.l oldstk,-(sp)			back into
	move.w #$20,-(sp)			user mode
	trap #1					call dos
	addq.l #6,sp  				correct stack
	clr.w -(sp)				terminate
	pea $5000				and
	move.w #$31,-(sp)			stay
	trap #1					resident
zippy	movem.l d0-a6,-(sp)			save registers
	bsr (music+8)				call playback
	movem.l (sp)+,d0-a6			restore registers
	move.l oldint,-(sp)			old vbl on sp
	rts					call old vbl
oldstk	dc.l 0
oldint	dc.l 0
music	incbin "rings1.mus"			change this filename !!

