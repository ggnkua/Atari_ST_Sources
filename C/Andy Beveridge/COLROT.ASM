***************************
* Colour palette rotation *
* bindings for Lattice C  *
*   by Andy Beveridge.    *
***************************

* This little routine spins the colour palette between
* the specified inclusive range. Note that this uses
* the GEM colour order (GEM re-orders the colour indices
* really wierdly for some strange reason.) If you want
* to spin the palette used by line-A you can whip out
* the translation table and use the colour number * 2
* to index the palette directly.
*    This routine is of course pretty useless if you
* don't have Lattice-C or if you don't have a colour monitor.
* I've included it mainly as an example of writing assembler
* modules for linking to C programs, and also as an
* example of the easy way to get into supervisor mode.
*
* for the curious...
*  GEM COLOUR INDEX  --->  REAL COLOUR INDEX
* -------------------------------------------
*        0            |           0
*        1            |          15
*        2            |           1
*        3            |           2
*        4            |           4
*        5            |           6
*        6            |           3
*        7            |           5
*        8            |           7
*        9            |           8
*       10            |           9
*       11            |          10
*       12            |          12
*       13            |          14
*       14            |          11
*       15            |          13
* -------------------------------------------
* ...Does anyone out there know why they do that ?

*
* Syntax...
* VOID	palrot(start, end)
* int	start,end	rotate palette start through to end inclusive
*
	text

	xdef	palrot		;XDEF it so the linker will see it

pal0	equ	$ff8240		;location of palette colour 0
pal15	equ	$ff825e		;location of palette colour 15
*
* Note: we only change the palette during vertical blanking
* so we don't get glitches on the screen.
*
palrot	move.w	#37,-(sp)	;push code for vsync()
	trap	#14		;XBIOS
	addq.l	#2,sp		;restore stack pointer
*
* must get args off stack before we go into supervisor mode
*
	move.w	6(sp),d1	;get start palette
	move.w	10(sp),d2	;and end palette
*
* Note: we must be in supervisor mode to access
* the hardware locations. Also note that the BIOS
* trashes d0 and a0, so don't pass things in them.
*
	pea	suprot		;push pointer to our code
	move.w	#38,-(sp)	;push code for supexec()
	trap	#14		;GO SUPERUSER!
	addq.l	#6,sp		;back in user mode. Tidy up the stack.
	rts
*
* The above will cause this routine (ends with RTS, not RTE)
* to be executed in SUPERVISOR MODE.
*
suprot	asl	#1,d1		;start * 2
	asl	#1,d2		;end * 2
	lea	pal0,a0		;set base pointer to palette
	lea	paltab,a1	;point a1 at trans table
	move.w	0(a1,d2),d3	;d3 <-- palette offset for color n
	move.w	0(a0,d3),d0	;d0 as temp store for top end
loop	subq.w	#2,d2		;decrement to next palette posn.

	move.w	0(a1,d2),d3	;get palette offset for color n
	move.w	0(a0,d3),-(sp)	;save pal value on stack

	move.w	2(a1,d2),d3	;get palette offset for color n+1
	move.w	(sp)+,0(a0,d3)	;put color n into it

	cmp.w	d1,d2		;see if gotten start of range yet
	bgt	loop		;loop while palette n > start palette 

	move.w	0(a1,d2),d3
	move.w	d0,0(a0,d3)	;set start from temp
	rts

	data
*
* Here is the table to translate GEM colour number
* into a palette offset to access the hardware with.
*
paltab
	dc.w	$0,$1e,$2,$4,$8,$c,$6,$a,$e
	dc.w	$10,$12,$14,$18,$1c,$16,$1a	

	end
