* Blitter routines for WARRIORS OF LIGHT
* Put into d7 the number of the function to go to, and call.

begin:		
		lea	jumptable,a6
		add.w	d7,d7
		add.w	d7,d7
		move.l	(a6,d7.w),a6
		jmp	(a6)

jumptable	dc.l	blitpodge,blitwash,mblitpodge,stringpodge,blitwipe,rawpodge,thintext,keybread,blink,pythag
		dc.l	blitskopy,inflate,flatpack,rawwipe,makemask

* FUNCTION 0 - Routine for screen copying on the blitter.
* Asa Burrows's extension already does this, but his throws errors at x>320 or y>200.
* So we need a new one for debordered screens that allows any X or Y coordinate.
* a0=source, a1=destination.
* d0=sx1, d1=sy1, d2=sx2, d3=sy2, d4=dx, d5=dy


blitpodge:	cmpi.w	#0,d0		; Clip the dest X so we don't bomb if X<0
		bge.s	.xclips2
		asr.w	#2,d0		; Since this is negative we have to preserve the sign bit
		add.w	d0,d2		; W=W+-X, technically the same as W=W-X but W=W--X is W=W+X. Confused yet?
		move.w	#0,d0		; And now zero it for the purposes of dest address calculation

.xclips2	cmpi.w	#320,d2		; And X>320 gives X=320
		blt.s	.yclips
		move.w	#320,d2

.yclips		cmpi.w	#0,d1		; And Y<0 gives Y=0
		bge.s	.calc
		move.w	#0,d1
	
.calc		lsr.w	#1,d0		; Remember each line=160 bytes=320 pixels.
		lsr.w	#1,d2		; So we must halve the X coords
		add.w	d0,a0		; Find source start
		sub.w	d1,d3		; Determine scanlines to blit
		sub.w	d0,d2		; Determine bytes to blit per line
		lsr.w	#1,d2		; Halve it for words per line
		move.w	d1,d6
		lsl.w	#7,d1		; start address=start(bank)+160y+x/2
		lsl.w	#5,d6
		add.w	d6,d1		; This is faster than MULU
		add.w	d1,a0

		cmpi.w	#0,d4		; Clip this as well
		bge.s	.xclipd
		move.w	#0,d4

.xclipd		lsr.w	#1,d4
		add.w	d4,a1		; And the same for the destination
		move.w	d5,d6
		lsl.w	#7,d5
		lsl.w	#5,d6
		add.w	d6,d5		; This is faster than MULU
		add.w	d5,a1
		move.l	#162,d0		; Calculate bytes to skip between line
		sub.w	d2,d0		; Skipped bytes=162-width
		sub.w	d2,d0

		move.w	#2,$ff8a20	; Source X inc
		move.w	d0,$ff8a22	; Source Y inc
		move.w	#2,$ff8a2e	; Dest X inc
		move.w	d0,$ff8a30	; Dest Y inc
		move.l	a0,$ff8a24	; Load up source address
		move.l	a1,$ff8a32	; And the dest address
		move.w	d2,$ff8a36	; Move sx2-sx1 words per line
		move.w	d3,$ff8a38	; Move sy2-sy1 lines
		move.w	#$ffff,$ff8a28
		move.w	#$ffff,$ff8a2a
		move.w	#$ffff,$ff8a2c	; These are the masks, whatever that is
		move.b	#2,$ff8a3a	; Blit Hop=2
		move.b	#3,$ff8a3b	; Blit Op=3, i.e. standard screen copy
		move.b	#0,$ff8a3d	; Skew etc.

.lp		bset.b 	#7,$ff8a3c	; Bombs away!
		nop
		btst.b	#7,$ff8a3c
		bne.s	.lp		; This is almost as fast as hog mode but allows for interrupts

		rts			; And we're done!

* Now how am I going to do a similar routine but with transparency on colour 0?

* FUNCTION 1 - Use the blitter to clear a patch of screen
* a0=screen address
* d0=x1, d1=y1, d2=x2, d3=y2

blitwash:	cmpi.w 	#0,d0		; Same clipping as before
		bge.s	.xclip2
		move.w	#0,d0
.xclip2		cmpi.w	#320,d2
		blt.s	.yclip
		move.w	#320,d2
.yclip		cmpi.w	#0,d1
		bge.s	.calc
		move.w	#0,d1

.calc		lsr.w	#1,d0		; Remember each line=160 bytes=320 pixels.
		lsr.w	#1,d2		; So we must halve the X coords
		add.w	d0,a0		; Find source start
		sub.w	d1,d3		; Determine scanlines to wipe
		sub.w	d0,d2		; Determine bytes to wipe per line
		lsr.w	#1,d2		; Halve it for words per line
		move.w	d1,d6
		lsl.w	#7,d1		; start address=start(bank)+160y+x/2
		lsl.w	#5,d6
		add.w	d6,d1		; This is faster than MULU
		add.w	d1,a0
		move.l	#162,d0		; Calculate bytes to skip between line
		sub.w	d2,d0		; Skipped bytes=162-width
		sub.w	d2,d0

		move.w	#2,$ff8a20	; Source X inc
		move.w	d0,$ff8a22	; Source Y inc
		move.w	#2,$ff8a2e	; Dest X inc
		move.w	d0,$ff8a30	; Dest Y inc
		move.l	a0,$ff8a32	; This is also put here
		move.w	d2,$ff8a36	; Move sx2-sx1 words per line
		move.w	d3,$ff8a38	; Move sy2-sy1 lines
		move.w	#$ffff,$ff8a28
		move.w	#$ffff,$ff8a2a
		move.w	#$ffff,$ff8a2c	; These are the masks, whatever that is
		move.b	#2,$ff8a3a	; Blit Hop=2
		move.b	#0,$ff8a3b	; Blit Op=0, i.e. all bits to 0
		move.b	#0,$ff8a3d	; Skew etc.

.lp0		bset.b 	#7,$ff8a3c	; Bombs away!
		nop
		btst.b	#7,$ff8a3c
		bne.s	.lp0		; This is almost as fast as hog mode but allows for interrupts

		rts			; And we're done!

* FUNCTION 2 - Screen copy with colour 0 transparent.
* This is akin to the M BLIT function in Missing Link.
* The answer is to have pre-masks stored on disk. This also means I can use colour 0 as either opaque or transparent.
* The mask MUST be at the same coordinates on a2 as the source on a0.
* a0=sauce, a1=destination, a2=mask
* d0=sx1, d1=sy1, d2=sx2, d3=sy2, d4=dx, d5=dy

mblitpodge:	cmpi.w	#0,d0		; Clip so X<0 results in X=0
		bge.s	.xclips2	; This stops it bombing
		move.w	#0,d0
.xclips2	cmpi.w	#320,d2		; And X>320 gives X=320
		blt.s	.yclips
		move.w	#320,d2
.yclips		cmpi.w	#0,d1		; And Y<0 gives Y=0
		bge.s	.calc
		move.w	#0,d1

.calc		lsr.w	#1,d0		; Remember each line=160 bytes=320 pixels.
		lsr.w	#1,d2		; So we must halve the X coords
		add.w	d0,a0		; Find sauce start
		add.w 	d0,a2
		sub.w	d1,d3		; Determine scanlines to blit
		sub.w	d0,d2		; Determine bytes to blit per line
		lsr.w	#1,d2		; Halve it for words per line
		move.w	d1,d6
		lsl.w	#7,d1		; start address=start(bank)+160y+x/2
		lsl.w	#5,d6
		add.w	d6,d1
		add.w	d1,a0
		add.w	d1,a2		; Get the mask in the same place

.clip3		cmpi.w	#0,d4		; Clip this as well
		bge.s	.yclipd
		moveq.w	#0,d4

.yclipd		lsr.w	#1,d4
		add.w	d4,a1		; And the same for the destination
		move.w	d5,d6
		lsl.w	#7,d5
		lsl.w	#5,d6
		add.w	d6,d5		; This is faster than MULU
		add.w	d5,a1		
		move.w	#162,d0		; Calculate bytes to skip between line
		sub.w	d2,d0		; Skipped bytes=162-width
		sub.w	d2,d0		; Since I am pre-masking we can reuse the normal blit calcs

*1st operation - AND the mask onto the destination

.1stop		move.w	#2,$ff8a20	; Sauce X inc
		move.w	d0,$ff8a22	; Sauce Y inc
		move.w	#2,$ff8a2e	; Dest X inc
		move.w	d0,$ff8a30	; Dest Y inc
		move.l	a2,$ff8a24	; Load up mask address
		move.l	a1,$ff8a32	; And the dest address
		move.w	d2,$ff8a36	; Move sx2-sx1 words per line
		move.w	d3,$ff8a38	; Move sy2-sy1 lines
		move.w	#$ffff,$ff8a28
		move.w	#$ffff,$ff8a2a
		move.w	#$ffff,$ff8a2c	; These are the masks, whatever that is
		move.b	#2,$ff8a3a	; Blit Hop=2
		move.b	#1,$ff8a3b	; Blit Op=1, i.e. AND
		move.b	#0,$ff8a3d	; Skew etc.

.lp1		bset.b 	#7,$ff8a3c	; Bombs away!
		nop
		btst.b	#7,$ff8a3c
		bne.s	.lp1		; This is almost as fast as hog mode but allows for interrupts

*2nd operation - OR the source onto the dest which has now been masked.

.2ndop		move.w	#2,$ff8a20	; Sauce X inc
		move.w	d0,$ff8a22	; Sauce Y inc
		move.w	#2,$ff8a2e	; Dest X inc
		move.w	d0,$ff8a30	; Dest Y inc
		move.l	a0,$ff8a24	; Load up sauce address
		move.l	a1,$ff8a32	; And the dest address
		move.w	d2,$ff8a36	; Move sx2-sx1 words per line
		move.w	d3,$ff8a38	; Move sy2-sy1 lines
		move.w	#$ffff,$ff8a28
		move.w	#$ffff,$ff8a2a
		move.w	#$ffff,$ff8a2c	; These are the masks, whatever that is
		move.b	#2,$ff8a3a	; Blit Hop=2
		move.b	#7,$ff8a3b	; Blit Op=1, i.e. OR
		move.b	#0,$ff8a3d	; Skew etc.

.lp2		bset.b 	#7,$ff8a3c	; Bombs away!
		nop
		btst.b	#7,$ff8a3c
		bne.s	.lp2		; This is almost as fast as hog mode but allows for interrupts

		rts			; I hope this works. Otherwise I'm sunk.

* FUNCTION 3 - Drop a SCREEN$ block with the blitter.
* Oh boy, this is gonna be tricky.
* Of course we could simply pre-mask all blocks at the outset then it's faster at the expense of double memory use.
* Second option chosen. I'll reuse my makemask function from Dead of Night and podge it into a spare bank.
* a0=varptr(block$), a1=destination screen, a2=varptr(mask$)
* d0=dx, d1=dy, d2=0 for replace, 1 for transparent.

stringpodge:	cmp.l 	#$44553528,(a0)+
          	bne 	.itsover	; If it isn't a block, FRO

		move.w	d2,.backflag	; Back up the replace flag.
					; That I can't stay entirely in the registers for this upsets me.

		move.w	(a0)+,d2
		move.w	(a0)+,d3	; Extract the dimensions of the block (d2=W, d3=H, in px)


.clip1		move.w	d0,d6		; Backup dx
		add.w	d2,d6		; Add W to X
		cmpi.w	#320,d6		; Is it above 320?
		ble.s	.clip2		; If not, go ahead
		move.w	#320,d5		
		sub.w	d0,d5		; W=320-X where W+X>320
		move.w	d5,d2		; This should prevent overdraw and not bomb. I hope.

.clip2		lsr.w	#2,d2		; Quarter X for words per line
		moveq.w	#2,d7		; Bytes skip in between line for sauce is by default 2.
		cmpi.w	#0,d0		; Clip the dest X so we don't bomb if X<0
		bge.s	.calc
		asr.w	#2,d0		; Since this is negative we have to preserve the sign bit
		add.w	d0,d2		; W=W+-X, technically the same as W=W-X but W=W--X is W=W+X. Confused yet?
		sub.w	d0,d7		; Subtracting a negative number is the same as adding a positive one.
					; (D&D 3e players on suicide watch)
		sub.w	d0,a0		; Must do this so in this instance we start by skipping words at the outset.
		move.w	#0,d0		; And now zero it for the purposes of dest address calculation


.calc		lsr.w	#1,d0
		add.w	d0,a1		; Find the dest address - x/2+160y
		move.w	d1,d5
		move.w	d5,d6
		lsl.w	#7,d5
		lsl.w	#5,d6
		add.w	d6,d5		; This is faster than MULU
		add.w	d5,a1		
		move.w	#162,d4		; Calculate bytes to skip between line 
		sub.w	d2,d4		; Skipped bytes=162-width
		sub.w	d2,d4

		tst.b	.backflag
		beq.s	.replace
		bra.s	.transp		; 0=replace mode, 1=transparent mode

.replace:	move.w	#2,$ff8a20	; Sauce X inc
		move.w	d7,$ff8a22	; Sauce Y inc - it's always 1 word a go here, unless dx<0.
		move.w	#2,$ff8a2e	; Dest X inc
		move.w	d4,$ff8a30	; Dest Y inc
		move.l	a0,$ff8a24	; Load up sauce address
		move.l	a1,$ff8a32	; And the dest address
		move.w	d2,$ff8a36	; Move dx2-dx1 words per line
		move.w	d3,$ff8a38	; Move dy2-dy1 lines
		move.w	#$ffff,$ff8a28
		move.w	#$ffff,$ff8a2a
		move.w	#$ffff,$ff8a2c	; These are the masks, whatever that is
		move.b	#2,$ff8a3a	; Blit Hop=2
		move.b	#3,$ff8a3b	; Blit Op=3, i.e. standard screen copy
		move.b	#0,$ff8a3d	; Skew etc.

.lp1		bset.b 	#7,$ff8a3c	; Bombs away!
		nop
		btst.b	#7,$ff8a3c
		bne.s	.lp1		; This is almost as fast as hog mode but allows for interrupts

.itsover	rts			; And we're done!

.transp:				; This is gonna suck.

* Step 1: AND the mask onto the destination

.1stop		move.w	#2,$ff8a20	; Sauce X inc
		move.w	d7,$ff8a22	; Sauce Y inc - it's always 1 word a go here, unless dx<0.
		move.w	#2,$ff8a2e	; Dest X inc
		move.w	d4,$ff8a30	; Dest Y inc
		move.l	a2,$ff8a24	; Load up mask address
		move.l	a1,$ff8a32	; And the dest address
		move.w	d2,$ff8a36	; Move dx2-dx1 words per line
		move.w	d3,$ff8a38	; Move dy2-dy1 lines
		move.w	#$ffff,$ff8a28
		move.w	#$ffff,$ff8a2a
		move.w	#$ffff,$ff8a2c	; These are the masks, whatever that is
		move.b	#2,$ff8a3a	; Blit Hop=2
		move.b	#1,$ff8a3b	; Blit Op=1, i.e. AND
		move.b	#0,$ff8a3d	; Skew etc.
		
.lp10		bset.b 	#7,$ff8a3c	; Bombs away!
		nop
		btst.b	#7,$ff8a3c
		bne.s	.lp10		; This is almost as fast as hog mode but allows for interrupts

.backflag	dc.w	0		; Somewhere to save the replace / transp flag.

* Step 6: OR the sauce on the now masked dest

.2ndop		move.l	a0,$ff8a24	; Load up sauce address
		move.l	a1,$ff8a32	; And the dest address
		move.b	#2,$ff8a3a	; Blit Hop=2
		move.b	#7,$ff8a3b	: Blit Op=7, i.e. OR

.lp11		bset.b 	#7,$ff8a3c	; Bombs away!
		nop
		btst.b	#7,$ff8a3c
		bne.s	.lp11		; This is almost as fast as hog mode but allows for interrupts

.itsover2	rts			; And that's your lot.

* FUNCTION 4 - wipe an entire screen (assumes 320*200) with the blitter.
* This is marginally faster than blitwashing with x,y,w,h set to 0,0,320,200 because it doesn't need to calculate the parameters for the blitter.
* a0=address (not bank no.) of screen to wipe.

blitwipe:	move.w	#2,$ff8a20	; Source X inc
		move.w	#2,$ff8a22	; Source Y inc
		move.w	#2,$ff8a2e	; Dest X inc
		move.w	#2,$ff8a30	; Dest Y inc
		move.l	a0,$ff8a32	; This is also put here
		move.w	#80,$ff8a36	; Move 80 words per line
		move.w	#200,$ff8a38	; Move 200 lines
		move.w	#$ffff,$ff8a28
		move.w	#$ffff,$ff8a2a
		move.w	#$ffff,$ff8a2c	; These are the masks, whatever that is
		move.b	#2,$ff8a3a	; Blit Hop=2
		move.b	#0,$ff8a3b	; Blit Op=0, i.e. all bits to 0
		move.b	#0,$ff8a3d	; Skew etc.

.lpx		bset.b 	#7,$ff8a3c	; Bombs away!
		nop
		btst.b	#7,$ff8a3c
		bne.s	.lpx		; This is almost as fast as hog mode but allows for interrupts

		rts			; And we're done!

* FUNCTION 5 - copy an entire wodge of raw data from one memory location to another.
* This can be used to speed up load times, for instance podging the entire level data from the bank into memory in one go.
* a0=address of sauce data (i.e. M10), a1=address of dest data (i.e. varptr(DPOS(0,0))), d0=number of bytes to podge (MUST BE EVEN)

rawpodge:	btst	#0,d0		; Check that it is even - if not, abort
		bne	.alldone
		lsr.w	#1,d0		; Bytes/2 to move
		
		move.w	#2,$ff8a20	; Source X inc
		move.w	#2,$ff8a22	; Source Y inc
		move.w	#2,$ff8a2e	; Dest X inc
		move.w	#2,$ff8a30	; Dest Y inc
		move.l	a0,$ff8a24	; Load up sauce address
		move.l	a1,$ff8a32	; And the dest address
		move.w	d0,$ff8a36	; Move length in words of data
		move.w	#1,$ff8a38	; Move 1 line
		move.w	#$ffff,$ff8a28
		move.w	#$ffff,$ff8a2a
		move.w	#$ffff,$ff8a2c	; These are the masks, whatever that is
		move.b	#2,$ff8a3a	; Blit Hop=2
		move.b	#3,$ff8a3b	; Blit Op=3, i.e. standard copy
		move.b	#0,$ff8a3d	; Skew etc.

.lpz		bset.b 	#7,$ff8a3c	; Bombs away!
		nop
		btst.b	#7,$ff8a3c
		bne.s	.lpz		; This is almost as fast as hog mode but allows for interrupts

.alldone	rts			; And we're done!

* FUNCTION 6 - thin text! 
* 4 pixels wide, 8 pixels high. Single bitplane. Bottom word will be blank (it's a spacer).
* It has to paint all 8 lines because the bottom one might have tails on lower-case letters. 
* That I can't do this all in the registers in one movem instruction offends my sensibilities.
* a0=address of string ending in chr$(0), a1=address of screen
* d0=dy, d1=dx, d2=bitplane to write to (in effect, paint in colours 1, 2, 4, or 8)

thintext:	add.w	d2,d2		; Double this
		add.w	d2,a1		; Shift to appropriate bitplane
		lea	.font,a5	; Load up font
		move.w	d0,d3
		move.w	d0,d4
		lsl.w	#5,d3
		lsl.w	#7,d4
		add.w	d3,d4		
		lsr.w	#1,d1
		add.w	d1,d4		; Calculate offset of coords (160y+x/2)
		add.w	d4,a1		; And apply to screen address
		moveq.l	#0,d7		; Counter for 4px rt shifts
		moveq.l	#0,d0
		moveq.l	#0,d1		; Clear registers
		moveq.l	#0,d6

.charloop:	move.b	(a0),d6
		cmpi.b	#0,d6		; chr$(0) is the end of the string
		beq.s	.finito

.fillblock:				; Since each character is 4px wide, 4 chars per block.
		moveq.w	#0,d0		; Clear out registers used for character identification
		moveq.w	#0,d6
		move.b	(a0)+,d0	; Insert char into registers
		subi.w	#32,d0		; Skip control characters
		lsl.w	#4,d0		; Find offset (each char is 16 bytes long)
		move.l	a5,a6		; Each character is 8 words and one bitplane
		add.l	d0,a6		; Get to character in font
		
		movem.w	(a6)+,d0-d6	; Get 7 lines of character 
		lsr.w	d7,d0
		lsr.w	d7,d1
		lsr.w	d7,d2
		lsr.w	d7,d3
		lsr.w	d7,d4
		lsr.w	d7,d5
		lsr.w	d7,d6		; Shift it into place
		or.w	d0,(a1)
		or.w	d1,160(a1)
		or.w	d2,320(a1)
		or.w	d3,480(a1)
		or.w	d4,640(a1)
		or.w	d5,800(a1)
		or.w	d6,960(a1)	; Paste onto screen
		move.w	(a6)+,d0	; Get last line
		lsr.w	d7,d0
		or.w	d0,1120(a1)	; Paste onto screen

		cmpi.w	#12,d7		; 4th char in block?
		bne.s	.advance	; If not, carry on. Otherwise...
		lea	8(a1),a1	; ...move to next block
		moveq.l	#0,d7		; reset counter
		bra.s	.endloop

.advance	addq.w	#4,d7		; Increase in-word offset by 4

.endloop	bra.s	.charloop

.finito		rts			; And we're done!

.font					; Representations of the typeface.
					; Eight words per character, starting with ASCII 32.

		incbin	"thintext.tfw"	; Probably easier to write a program to arrange it into order and then incbin it here

* FUNCTION 7 - more efficient keyboard read.
* This uses two BIOS traps (Bconstat and Bconin) to read the keyboard without recourse to any STOS.
* No parameters, but returns the key pressed, both ASCII and scancode, (if any) to d0. Which is kept in settings.cfg.

keybread:	move.w	#2,-(SP)	; Offset 2
		move.w	#1,-(SP)     	; Offset 0
		trap	#13          	; Call BIOS
		addq.l	#4,SP        	; Correct stack

		cmpi.b	#-1,d0
		bne.s	.done		; If no key in buffer, quit
		
		move.w	#2,-(SP)	; Offset 2
		move.w	#2,-(SP)	; Offset 0
		trap	#13     	; Call BIOS
		addq.l	#4,SP		; Correct stack

.done		rts			; It's over

* FUNCTION 8 - Blink an icon. This is done by applying NOT to the word covering bitplane 0.
* Of course, don't forget to call this again after a VBL to unblink it.
* This uses the CPU because it is more cycles to set up the blitter to do this for something small.
* a0=screen address.
* d0=icon x, d1=icon y, d2=icon height. This only does one word so that's all that's needed.

blink:		
		cmpi.w	#0,d2		; If height=0 then don't bother
		beq.s	.bye

		lsr.w	#1,d0		
		move.w	d1,d6
		move.w	d1,d5
		lsl.w	#5,d6
		lsl.w	#7,d5
		add.w	d5,d6		; Offset=160y+x/2, as always
		add.w	d6,a0
		add.w	d0,a0		; Get to start address

		subq.w	#1,d2		; Repeat loop, so must subtract 1 from counter first
.lp		not.w	(a0)		; Invert first bitplane only!
		lea	160(a0),a0	; Advance to next line
		dbra	d2,.lp		; Loop back

.bye		rts			; And we're done!
		
* FUNCTION 9 - Determine the absolute distance between two entities. 
* This is useful for determining whether the player is "in range" of a monster or effect, as well as in the stereo sound.
* It returns the SQUARE of the value because a sqrt would be unnecessary in the grand scheme of things.
* "if DIST<n^2 then DoSomething()" is just fine. Or have a table of square roots.
* d0=x1, d1=y1, d2=x2, d3=y2, and d0 contains the result.

pythag:		sub.w	d2,d0
		sub.w	d3,d1
		mulu.w	d0,d0
		mulu.w	d1,d1		; Unsigned multiplication gives absolute value
		add.w	d1,d0		; Yeah, this is basically Pythagoras' theorem.
		rts

* FUNCTION 10 - Single bitplane screen copy on the blitter.
* I'm sure this will have its uses at some point.
* a0=address of sauce, a1=address of dest
* d0=sx1, d1=sy1, d2=sx2, d3=sy2, d4=dx, d5=dy, d6=bitplane (0 to 3)

blitskopy:	add.w	d6,d6		; Double to get to correct bitplane
		add.l	d6,a0
		add.l	d6,a1		; Shift into correct bitplane on both sauce and dest

		cmpi.w	#0,d0		; Clip the dest X so we don't bomb if X<0
		bge.s	.xclips2
		asr.w	#2,d0		; Since this is negative we have to preserve the sign bit
		add.w	d0,d2		; W=W+-X, technically the same as W=W-X but W=W--X is W=W+X. Confused yet?
		move.w	#0,d0		; And now zero it for the purposes of dest address calculation

.xclips2	cmpi.w	#320,d2		; And X>320 gives X=320
		blt.s	.yclips
		move.w	#320,d2

.yclips		cmpi.w	#0,d1		; And Y<0 gives Y=0
		bge.s	.calc
		move.w	#0,d1
	
.calc		lsr.w	#1,d0		; Remember each line=160 bytes=320 pixels.
		lsr.w	#1,d2		; So we must halve the X coords
		add.w	d0,a0		; Find source start
		sub.w	d1,d3		; Determine scanlines to blit
		sub.w	d0,d2		; Determine bytes to blit per line
		lsr.w	#3,d2		; Divide by 8 because we only move every 4th word
		move.w	d1,d6
		lsl.w	#7,d1		; start address=start(bank)+160y+x/2
		lsl.w	#5,d6
		add.w	d6,d1		; This is faster than MULU
		add.w	d1,a0

		cmpi.w	#0,d4		; Clip this as well
		bge.s	.xclipd
		move.w	#0,d4

.xclipd		lsr.w	#1,d4
		add.w	d4,a1		; And the same for the destination
		move.w	d5,d6
		lsl.w	#7,d5
		lsl.w	#5,d6
		add.w	d6,d5		; This is faster than MULU
		add.w	d5,a1
		move.l	#162,d0		; Calculate bytes to skip between line
		sub.w	d2,d0		; Skipped bytes=162-width
		sub.w	d2,d0
		lsr.w	#3,d2		; Divide by 8 because only every 4th word moved

		move.w	#8,$ff8a20	; Source X inc
		move.w	d0,$ff8a22	; Source Y inc
		move.w	#8,$ff8a2e	; Dest X inc
		move.w	d0,$ff8a30	; Dest Y inc
		move.l	a0,$ff8a24	; Load up source address
		move.l	a1,$ff8a32	; And the dest address
		move.w	d2,$ff8a36	; Move sx2-sx1/4 words per line
		move.w	d3,$ff8a38	; Move sy2-sy1 lines
		move.w	#$ffff,$ff8a28
		move.w	#$ffff,$ff8a2a
		move.w	#$ffff,$ff8a2c	; These are the masks, whatever that is
		move.b	#2,$ff8a3a	; Blit Hop=2
		move.b	#3,$ff8a3b	; Blit Op=3, i.e. standard screen copy
		move.b	#0,$ff8a3d	; Skew etc.

.lp		bset.b 	#7,$ff8a3c	; Bombs away!
		nop
		btst.b	#7,$ff8a3c
		bne.s	.lp		; This is almost as fast as hog mode but allows for interrupts

		rts			; And we're done!

* FUNCTION 11 - Inflate the byte grid into a STOS array.
* The grid coords are to be stored as a wodge of bytes rather than just dumping the arrays in to save on disk space.
* This will make loading faster if it's from floppy disk as the processor time to expand these is less than the drive time loading from floppy.
* a0=address of byte grid, a1=pointer to 0,0 of array.
* d0=total number of items of array (this is all dimensions multiplied together).

inflate:	cmpi.w	#0,d0
		beq.s	.done		; Quit if length=0 to avoid rogue bombing or scribbles.
		moveq.l	#0,d2		
		subq.w	#1,d0		; Repeat loop, so n-1 iterations.

.col		move.b	(a0)+,d2	
		move.l	d2,(a1)+	
		dbra	d0,.col		; Trivial FOR loop

.done		rts			; And we're done!

* FUNCTION 12 - Flatpack the STOS array into a byte grid.
* This will be used in saving and loading games as well as keeping a memory efficient storage of all levels the player's been on.
* Basically we need to keep a bank of about 128 kilobytes vacant at all times so we can stash, in theory, every level in it.
* Plus, of course, a few longs for the player's name and stats and current/max HP, spells known, game statistics, time in game.
* This limits us to 16 levels, as it happens. 
* a0=address of 0,0 in array, a1=pointer to start of byte grid, d0=length of byte grid.

flatpack:	cmpi.w	#0,d0
		beq.s	.done		; Quit if length=0 to avoid rogue bombing or scribbles.
		moveq.l	#2,d2
		subq.w	#1,d0		; Repeat loop, so n-1 iterations.

.col		move.l	(a0)+,d2
		move.b	d2,(a1)+
		dbra	d0,.col		; Another trivial FOR loop.

.done		rts			; This is the same as the last function but in reverse.

* FUNCTION 13 - Using the blitter, clear a raw wodge of memory.
* This can be used to speed up load times, for instance podging the entire level data from the bank into memory in one go.
* a0=address of array's first item (i.e. varptr(DPOS(0,0)), d0=length of array (MUST BE EVEN)

rawwipe:	btst	#0,d0		; Check that it is even - if not, abort
		bne.s	.alldone
		lsr.w	#1,d0		; Bytes/2 to move
		
		move.w	#2,$ff8a20	; Source X inc
		move.w	#2,$ff8a22	; Source Y inc
		move.w	#2,$ff8a2e	; Dest X inc
		move.w	#2,$ff8a30	; Dest Y inc
		move.l	a0,$ff8a32	; Set dest address (no sauce needded)
		move.w	d0,$ff8a36	; Move length in words of data
		move.w	#1,$ff8a38	; Move 1 line
		move.w	#$ffff,$ff8a28
		move.w	#$ffff,$ff8a2a
		move.w	#$ffff,$ff8a2c	; These are the masks, whatever that is
		move.b	#2,$ff8a3a	; Blit Hop=2
		move.b	#3,$ff8a3b	; Blit Op=0, i.e. all bits to 0
		move.b	#0,$ff8a3d	; Skew etc.

.lpz		bset.b 	#7,$ff8a3c	; Bombs away!
		nop
		btst.b	#7,$ff8a3c
		bne.s	.lpz		; This is almost as fast as hog mode but allows for interrupts

.alldone	rts			; And we're done!

* FUNCTION 14 - Pre-mask a screen of graphics.
* This is done at loading time to make a masked version of a screen of wallset, which can then be grabbed into an array of screen$ blocks.
* Could be called something like WALLMASK$(n). This will double memory requirements but is faster than masking on the fly.
* a0=address of screen to mask, a1=address of screen bank to put the masked screen into. 

makemask:				; Who cares, it's not speed critical.
		move.w	#8000,d6	; This is our loop counter
		move.l	#0,d0		; Clear d0
		
.loop		move.w	(a0)+,d0	; OR all the bitplanes together
		or.w	(a0)+,d0
		or.w	(a0)+,d0
		or.w	(a0)+,d0
		not.w	d0		; Invert 
		move.w	d0,(a1)+
		move.w	d0,(a1)+	
		move.w	d0,(a1)+
		move.w	d0,(a1)+	; Silly me, need to do it on all bitplanes!
		dbra	d6,.loop	; Let's do it again!

		rts			; And we're done!

* FUNCTION 15 - thinput!
* This is thin text but as an input function. 