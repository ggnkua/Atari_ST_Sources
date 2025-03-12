; This is the source code for relocating and playing back the
; Sample/Sound chip music from Chambers of Shaolin.
;
; I've had this source lying about for months, so now that I've
; finally used it myself, I thought I'd be extremely generous and
; release this music so that other groups could use it on their
; menus !!
; 
; The sampled bits (installed on $114), take up quite a lot of
; processor time when they are played, so I don't think you'll
; have much luck trying to use this music in a very fancy menu
; with big scrollers, top border routines etc. so that's why
; the menu on this disk has only got a bouncy raster bar !!
;
; To play the four musix just change the number that you move
; into d0 before calling the set-up routines (that's the line
; that says 'moveq #1,d0'), between 1 and 4.
;
; This is just the basic relocation and calling routines,
; any other problems you will have to sort out yourself !!
; (Well, I couldn't make it too easy could I ???)
;
; Have fun...  (And remember to greet me on your menu !!)
;
; Zippy
;
	opt s-					no symbols
	move.l sp,a5				save sp
	move.l $4(a5),a5			get basepage
	move.l #$200,-(sp)			protect $200
	move.l a5,-(sp)				from basepage
	move.w #$0,-(sp)			dummy
	move.w #$4a,-(sp)			setblock
	trap #1					call dos
	add.l #$c,sp				correct stack
	clr.l -(sp)				dummy
	move.w #$20,-(sp)			super
	trap #1					call dos
	addq.l #6,sp				correct stack
	move.l d0,old				save old sp
	move.l #(music+$86e),(music+$1aa)	relocate
	move.l #(music+$86f),(music+$828)	music
	move.l #(music+$86e),(music+$83c)	to
	move.l #(music+$c4e),(music+$c3e)	play
	move.l #(music+$2cfa),(music+$c42)	at
	move.l #(music+$356a),(music+$c46)	this
	move.l #(music+$416c),(music+$c4a)	address
	clr.l d0				init
	jsr (music+8)				mfp etc
	moveq #1,d0				music #1
	jsr (music)				call music
	move.l $70.w,oldvbl			save old vbl
	move.l #zippy,$70.w			install my vbl
	move.w #7,-(sp)				wait key
	trap #1					call dos
	addq.l #2,sp				correct stack
	move.l oldvbl,$70.w			restore old vbl
	move.l #$8080000,$ff8820		clear
	move.l #$9090000,$ff8820		sound
	move.l #$a0a0000,$ff8820		chip
	move.l #$707ffff,$ff8820		registers
	jsr (music+12)				restore mfp etc.
	move.b #$f0,$fffa23			new timer c
	move.l old,-(sp)			restore old sp
	move.w #$20,-(sp)			back in user
	trap #1					call dos
	addq.l #6,sp				correct stack
	clr.w -(sp)				terminate
	trap #1					call dos
zippy	movem.l d0-a6,-(sp)			save registers
	jsr (music+4)				call music player
	movem.l (sp)+,d0-a6			restore registers
	move.l oldvbl,-(sp)			old vbl on sp
	rts					do old vbl code
oldvbl	dc.l 0
old	dc.l 0
music	incbin 'chamber.mus'
