
;-----------------------------------------------------------------------:
;									:
;	Silly Bugs Demo							:
;									:
;----									:
; 30-Nov-1986 lmd	Hacked it up.					:
;									:
;-----------------------------------------------------------------------:

	.include "atari.s"	; get ST equates and macros


;----------------
;
;  Imports
;
	.globl	_images		; -> table of images (->)
	.globl	_masks		; -> table of masks (->)
	.globl	mksh		; construct shifted images


;----------------
;
;  Exports
;
	.globl	draw		; draw an image
	.globl	undraw		; undraw (erase) an image
	.globl	upd_gravity	; update an image, with gravity


;----------------
;
;  Bug structure
;
    .abs
BGcritno:	ds.b	1	; critter number (0=dead)
BGstate:	ds.b	1	; critter state
BGxpos:		ds.l	1	; int+frac X and Y positions
BGypos:		ds.l	1
BGxvel:		ds.l	1	; int+frac Y and Y velocities
BGyvel:		ds.l	1
BGtimer:	ds.w	1	; timer
BGimage:	ds.w	1	; image number
BGscraddr:	ds.l	1	; starting address on screen
BGimgaddr:	ds.l	1	; -> image
BGmskaddr:	ds.l	1	; -> mask
BGimgsize:	ds.l	1	; = image size (0, 4, 8 ...)
BGSIZE:		ds.l	1	; (size of bug structure)


;----------------
;
;  Global variables
;
NBUGS	equ	16		; number of bugs
    .bss
screen:		ds.l	1	; -> screen memory
mode:		ds.w	1	; screen resolution (0, 2, 4)
modex4:		ds.w	1	; screen resolution (0, 4, 8)
width:		ds.w	1	; = screen width
maxx:		ds.w	1	; max X position for 16-wide sprite
maxy:		ds.w	1	; max Y position for 16-high sprite
linshft:	ds.w	1	; shift amount for X index computation
linmask:	ds.w	1	; mask for X index computation
gravity:	ds.l	1	; int+frac gravity
oldrez:		ds.w	1	; old screen resolution
savedColors:	ds.w	16	; saved pallette
freemem:	ds.b	$8000	; space for shifted images ["enough" space]
bugs:		ds.b	BGSIZE*NBUGS		; bugs database



    .data
ourColors:	dc.w	$000,$700,$070,$770	; our pallette
		dc.w	$007,$707,$077,$555
		dc.w	$333,$733,$373,$773
		dc.w	$337,$737,$377,$654



    .text
;----------------
;
;  Top level
;
	move.l	#$00004000,gravity	; set force of gravity

	bsr	inivideo		; initialize video parameters
	lea	freemem,a1		; a1 -> free memory
	bsr	mksh			; make shifted fonts

;---- setup initial positions and velocities from
;	a list of initial values.
;
	lea	bugs,a5
	lea	i_xpos,a0
	lea	i_ypos,a1
	lea	i_xvel,a2
	lea	i_img,a3
	moveq	#NBUGS-1,d0
ilp1:	clr.l	BGxpos(a5)
	clr.l	BGypos(a5)
	move.w	(a0)+,BGxpos(a5)
	move.w	(a1)+,BGypos(a5)
	move.l	(a2)+,BGxvel(a5)
	move.w	(a3)+,BGimage(a5)
	clr.l	BGscraddr(a5)		; clobber screen addr (never drawn)
	lea	BGSIZE(a5),a5
	dbra	d0,ilp1

;--- Bugs loop:
;	o refresh all bugs
;	o sync with vblank
;	o test for a keypress, punt on any keystroke
;

loop:	moveq	#NBUGS-1,d6		; d6 = #bugs-1
	lea	bugs,a5
loop1:	bsr	upd_gravity		; update a bug
	lea	BGSIZE(a5),a5		; advance to next one
	dbra	d6,loop1		; (loop for more)

	move.w	#$25,-(sp)		; Vsync()
	trap	#14
	addq	#2,sp

	Bconstat #CON			; key ready?
	tst.w	d0
	beq	loop			; (no --- loop)

	Bconin #CON			; eat the keypress
	bsr	restore_video		; restore video
	Pterm0				; and terminate


;--- initial image numbers
i_img:	dc.w	0,1,2,0
	dc.w	0,1,2,0
	dc.w	0,1,2,0
	dc.w	0,1,2,0


;--- initial X and Y posititions
i_xpos:	dc.w	$00,$10,$20,$30
	dc.w	$40,$50,$60,$70
	dc.w	$80,$90,$a0,$b0
	dc.w	$c0,$d0,$e0,$f0

i_ypos:	dc.w	$00,$08,$10,$18
	dc.w	$20,$28,$30,$38
	dc.w	$40,$48,$30,$38
	dc.w	$20,$28,$10,$18

;--- Initial X velocities
i_xvel:	dc.l	$00008000
	dc.l	$0000c000
	dc.l	$00010000
	dc.l	$00014000
	dc.l	$00008000
	dc.l	$0000c000
	dc.l	$00010000
	dc.l	$00008000
	dc.l	$00014000
	dc.l	$0000c000
	dc.l	$00010000
	dc.l	$00008000
	dc.l	$0000c000
	dc.l	$00014000
	dc.l	$00010000
	dc.l	$00014000


;----------------
;
;  Video parameter setup
;
inivideo:
	Physbase			; screen = Physbase()
	move.l	d0,screen
	Supexec #saveColors		; save pallette
	Supexec	#setColors		; initialize pallette with our colors
	Getrez				; mode = Getrez() << 1
	move.w	d0,oldrez		; save old resolution
	cmp.w	#1,d0			; medium rez?
	bne.s	.1			; (no)
	moveq	#0,d0
	bsr	setRez			; set rez to low
	moveq	#0,d0

.1:	add.w	d0,d0
	move.w	d0,mode
	move.w	d0,modex4		; mode4 = Getrez() << 2
	add.w	d0,modex4

	move.w	xwidth(pc,d0.w),width
	move.w	xmaxx(pc,d0.w),maxx
	move.w	xmaxy(pc,d0.w),maxy
	move.w	xlinshft(pc,d0.w),linshft
	move.w	xlinmask(pc,d0.w),linmask
	rts

saveColors:
	lea	color0,a0
	lea	savedColors,a1
	move.w	#16-1,d0
.1:	move.w	(a0)+,(a1)+
	dbra	d0,.1
	rts

setColors:
	lea	ourColors,a0
	lea	color0,a1
	move.w	#16-1,d0
.1:	move.w	(a0)+,(a1)+
	dbra	d0,.1
	rts


;+
;  Resolution-dependent parameter tables
;
;-
xwidth:	dc.w	160,160,80		; screen width (bytes)
xmaxx:	dc.w	303,623,623		; max X position for 16-wide sprite
xmaxy:	dc.w	183,183,383		; max Y position for 16-high sprite
xlinshft: dc.w	1,2,3			; shifts for X index computation
xlinmask: dc.w	$ffff-7,$ffff-3,$ffff-1	; masks for X index computation


;----------------
;
;  Restore original screen resolution
;
restore_video:
	Supexec	#restoreColors		; restore pallette
	cmp.w	#1,oldrez		; was in medium?
	bne.s	.ret			; (no --- leave it alone)
	move.w	oldrez,d0		; set rez back to medium
	bsr	setRez
.ret:	rts


setRez:
	move.b	d0,.temp
	Supexec #.1
	rts
.1:	move.b	.temp,shiftmd
	rts
    bss
.temp:	ds.w	1
    .text


restoreColors:
	lea	savedColors,a0
	lea	color0,a1
	move.w	#16-1,d0
.1:	move.w	(a0)+,(a1)+
	dbra	d0,.1
	rts



;---- general-purpose return instruction
return:	rts


;----------------
;
;  Draw bug;
;    - compute addresses of things and fill-in bug structure
;    - setup registers for drawing
;    - do drawing
;
;    Passed:	a5 -> bug
;    Returns:	nothing
;    Fills-in:	BGscraddr(a5)
;		BGimgaddr(a5)
;		BGmskaddr(a5)
;		BGimgsize(a5)
;    Uses:	a0-a4/d0-d4
;
draw::
	move.w	BGypos(a5),d0		; d0 = ypos * width
	mulu	width,d0
	move.w	BGxpos(a5),d1		; d1 = (xpos >> linshft) & linmask
	move.w	d1,d2			; (save xpos for later)
	move.w	linshft,d3
	lsr.w	d3,d1
	and.w	linmask,d1
	add.w	d1,d0			; d0 += d1
	move.l	screen,a0		; a0 = screen + (ypos * width) +
	add.w	d0,a0			;      (xpos >> linshft) & linmask
	move.l	a0,BGscraddr(a5)	; save screen addr for cmp and undraw

	moveq	#0,d3			; assume 1x
	and.w	#$000f,d2		; see if on 16-pixel boundary
	beq.s	.1			; (yes --- it's 1x)
	moveq	#4,d3			; no --- it's 2x
.1:	move.w	d3,BGimgsize(a5)	; set image size, keep d3=image size

	move.w	BGimage(a5),d0		; d0 = image number to draw
	lsl.w	#2,d0			; turn into longword index
	move.w	BGxpos(a5),d1		; d1 = (x_position & 15) << 2
	and.w	#15,d1
	lsl.w	#2,d1

	lea	_images,a1
	move.l	(a1,d0.w),a1		; a1 -> image base
	move.l	(a1,d1.w),a1		; a1 -> image
	move.l	a1,BGimgaddr(a5)	; save image addr for cmp and undraw

	lea	_masks,a2
	move.l	(a2,d0.w),a2		; a2 -> image's mask base
	move.l	(a2,d1.w),a2		; a2 -> image's mask
	move.l	a2,BGmskaddr(a5)	; save mask addr for cmp and undraw

	move.w	width,d1		; d1 = screen width

	move.w	modex4,d0		; d0 = longword rez index
	move.l	axdraw(pc,d0.w),a4	; a4 -> vector of drawing routines
	move.l	(a4,d3.w),a4		; a4 -> drawing routine
	jmp	(a4)


;+
;  Table of ptrs to drawing routines
;
;-
axdraw:	dc.l	lxdraw,hxdraw,mxdraw
lxdraw:	dc.l	ld1x16,ld2x16
hxdraw:	dc.l	return,return
mxdraw:	dc.l	md1x16,md2x16


;+
;  Draw a 1x16 image in low-rez
;
;    a0 -> screen base
;    a1 -> image base
;    a2 -> mask base
;    d1 = screen width
;
;-
ld1x16:
	moveq	#16-1,d2	; d2 = scanline count

.1:	move.w	(a2)+,d4	; d4 = mask

;--- plane 0
	move.w	(a0),d0		; d0 = screen
	and.w	d4,d0		; clobber bits in mask
	or.w	(a1)+,d0	; or-in bits from image
	move.w	d0,(a0)		; stuff result onto screen

;--- plane 1
	move.w	2(a0),d0	; d0 = screen
	and.w	d4,d0		; clobber bits in mask
	or.w	(a1)+,d0	; or-in bits from image
	move.w	d0,2(a0)	; stuff result onto screen

;--- plane 2
	move.w	4(a0),d0	; d0 = screen
	and.w	d4,d0		; clobber bits in mask
	or.w	(a1)+,d0	; or-in bits from image
	move.w	d0,4(a0)	; stuff result onto screen

;--- plane 3
	move.w	6(a0),d0	; d0 = screen
	and.w	d4,d0		; clobber bits in mask
	or.w	(a1)+,d0	; or-in bits from image
	move.w	d0,6(a0)	; stuff result onto screen

	add.w	d1,a0		; bump screen ptr to next scanline
	dbra	d2,.1		; loop for more lines
	rts


;+
;  Draw a 2x16 image in low-rez
;
;    a0 -> screen base
;    a1 -> image base
;    a2 -> mask base
;    d1 = screen width
;
;-
ld2x16:
	sub.w	#16,d1		; adjust screen width for image stride
	moveq	#16-1,d2	; d2 = scanline count

ld2_1:	move.w	(a2)+,d4	; d4 = mask

;--- plane 0 part 0
	move.w	(a0),d0		; d0 = screen
	and.w	d4,d0		; clobber bits in mask
	or.w	(a1)+,d0	; or-in bits from image
	move.w	d0,(a0)+	; stuff result onto screen

;--- plane 1 part 0
	move.w	(a0),d0		; d0 = screen
	and.w	d4,d0		; clobber bits in mask
	or.w	(a1)+,d0	; or-in bits from image
	move.w	d0,(a0)+	; stuff result onto screen

;--- plane 2 part 0
	move.w	(a0),d0		; d0 = screen
	and.w	d4,d0		; clobber bits in mask
	or.w	(a1)+,d0	; or-in bits from image
	move.w	d0,(a0)+	; stuff result onto screen

;--- plane 3 part 0
	move.w	(a0),d0		; d0 = screen
	and.w	d4,d0		; clobber bits in mask
	or.w	(a1)+,d0	; or-in bits from image
	move.w	d0,(a0)+	; stuff result onto screen

	move.w	(a2)+,d4	; d4 = mask

;--- plane 0 part 1
	move.w	(a0),d0		; d0 = screen
	and.w	d4,d0		; clobber bits in mask
	or.w	(a1)+,d0	; or-in bits from image
	move.w	d0,(a0)+	; stuff result onto screen

;--- plane 1 part 1
	move.w	(a0),d0		; d0 = screen
	and.w	d4,d0		; clobber bits in mask
	or.w	(a1)+,d0	; or-in bits from image
	move.w	d0,(a0)+	; stuff result onto screen

;--- plane 2 part 1
	move.w	(a0),d0		; d0 = screen
	and.w	d4,d0		; clobber bits in mask
	or.w	(a1)+,d0	; or-in bits from image
	move.w	d0,(a0)+	; stuff result onto screen

;--- plane 3 part 1
	move.w	(a0),d0		; d0 = screen
	and.w	d4,d0		; clobber bits in mask
	or.w	(a1)+,d0	; or-in bits from image
	move.w	d0,(a0)+	; stuff result onto screen

	add.w	d1,a0		; bump screen ptr to next scanline
	dbra	d2,ld2_1	; loop for more lines
	rts


;+
;  Draw a 1x16 image in monochrome
;
;    a0 -> screen base
;    a1 -> image base
;    a2 -> mask base
;    d1 = screen width
;
;-
md1x16:
	moveq	#16-1,d2	; d2 = scanline count

md1_1:	move.w	(a0),d0		; d0 = screen
	and.w	(a2)+,d0	; clobber bits in mask
	or.w	(a1)+,d0	; or-in bits from image
	move.w	d0,(a0)		; stuff result onto screen
	addq.w	#6,a1		; bump past color planes

	add.w	d1,a0		; bump screen ptr to next scanline
	dbra	d2,md1_1	; loop for more lines
	rts


;+
;  Draw a 2x16 image in monochrome
;
;    a0 -> screen base
;    a1 -> image base
;    a2 -> mask base
;    d1 = screen width
;
;-
md2x16:
	moveq	#16-1,d2	; d2 = scanline count

md2_1:	move.w	(a0),d0		; d0 = screen
	and.w	(a2)+,d0	; clobber bits in mask
	or.w	(a1)+,d0	; or-in bits from image
	move.w	d0,(a0)		; stuff result onto screen
	addq.w	#6,a1		; bump past color planes

	move.w	2(a0),d0	; d0 = screen
	and.w	(a2)+,d0	; clobber bits in mask
	or.w	(a1)+,d0	; or-in bits from image
	move.w	d0,2(a0)	; stuff result onto screen
	addq.w	#6,a1		; bump past color planes

	add.w	d1,a0		; bump screen ptr to next scanline
	dbra	d2,md2_1	; loop for more lines
	rts


;----------------
;
;  Undraw bug
;
;    Passed:	a5 -> bug
;    Returns:	nothing
;    Uses:	a0-a4/d0-d4
;
undraw::
	move.l	BGscraddr(a5),d0	; if BGscraddr == NULL
	beq.s	.ret			;	then return;
	move.l	d0,a0
	move.l	BGmskaddr(a5),a2
	move.w	width,d1
	move.w	BGimgsize(a5),d0
	move.w	modex4,d2
	move.l	axundraw(pc,d2.w),a4
	move.l	(a4,d0.w),a4
	jmp	(a4)
.ret:	rts


;+
;  Table of ptrs to undraw routines
;
;-
axundraw: dc.l	lxundraw,hxundraw,mxundraw
lxundraw: dc.l	lu1x16,lu2x16
hxundraw: dc.l	return,return
mxundraw: dc.l	mu1x16,mu2x16


;+
;  Undraw a 1x16 image in low rez
;
;    a0 -> screen base
;    a2 -> mask base
;    d1 = screen width
;
;-
lu1x16:
	sub.w	#8,d1		; adjust screen width for image stride
	moveq	#16-1,d2	; d2 = scanline count

.1:	move.w	(a2)+,d0	; d0 = mask
	and.w	d0,(a0)+
	and.w	d0,(a0)+
	and.w	d0,(a0)+
	and.w	d0,(a0)+

	add.w	d1,a0		; bump to next screen location
	dbra	d2,.1		; loop for more scanlines
	rts


;+
;  Undraw a 2x16 image in low rez
;
;    a0 -> screen base
;    a2 -> mask base
;    d1 = screen width
;
;    Uses:
;    d4 = ~mask
;    d5 = mask
;    
;    
;
;-
lu2x16:
	sub.w	#16,d1		; adjust screen width for image stride
	moveq	#16-1,d2	; d2 = scanline count
.1:
    .rept 2
	move.w	(a2)+,d0	; d5 = mask
	and.w	d0,(a0)+
	and.w	d0,(a0)+
	and.w	d0,(a0)+
	and.w	d0,(a0)+
    .endr

	add.w	d1,a0		; bump to next screen location
	dbra	d2,.1		; loop for more scanlines
	rts


;+
;  Undraw a 1x16 image in monochrome
;
;    a0 -> screen base
;    a2 -> mask base
;    d1 = screen width
;
;-
mu1x16:
    .rept 16
	move.w	(a2)+,d0
	and.w	d0,(a0)
	add.w	d1,a0
     .endr
	rts


;+
;  Undraw a 2x16 image in monochrome
;
;    a0 -> screen base
;    a2 -> mask base
;    d1 = screen width
;
;-
mu2x16:
    .rept 16
	move.l	(a2)+,d0
	and.l	d0,(a0)
	add.w	d1,a0
    .endr
	rts


;----------------
;
;  Update position (with gravity)
;
;    Passed:	a5 -> bug
;    Returns:	nothing
;    Uses:	d0-d4/a0-a4
;
upd_gravity:
	moveq	#0,d2			; MovedFlag := FALSE

;--- update Y position (with gravity)
	move.w	BGypos(a5),d3		; save old position (for comparison)
	move.l	BGyvel(a5),d0		; bump velocity with gravity
	add.l	gravity,d0
.y:	move.l	d0,BGyvel(a5)
	add.l	d0,BGypos(a5)		; bump position with new velocity
	move.w	BGypos(a5),d0		; get significant part of position
	bpl.s	.1			; if (pos < 0)
	bra.s	.2			;	reverse velocity (bounce)
.1:	cmp.w	maxy,d0			; if (pos > maxy)
	blt.s	.3
.2:	move.l	BGyvel(a5),d0		; reverse velocity
	neg.l	d0
	bra	.y			; recompute position
.3:	cmp.w	BGypos(a5),d3		; if (newpos != oldpos)
	beq.s	.4
	st	d2			;	MovedFlag := TRUE

.4:	move.w	BGxpos(a5),d3		; save old position (for comparison)
	move.l	BGxvel(a5),d0		; d0 = velocity
.7:	add.l	BGxpos(a5),d0		; d0 = position + velocity
	move.l	d0,BGxpos(a5)
	bmi.s	.5			; if (position < 0) then bounce
	swap	d0
	cmp.w	maxx,d0			; if (position <= maxx) then OK
	blt.s	.6
.5:	move.l	BGxvel(a5),d0		; d0 = -velocity
	neg.l	d0
	move.l	d0,BGxvel(a5)		; velocity = -velocity
	bra.s	.7			; move again (other direction)

.6:	cmp.w	BGxpos(a5),d3		; if (newpos != oldpos)
	bne.s	.8			;	then redraw
	tst.b	d2			; if (MovedFlag == TRUE)
	beq.s	.r			; (no, so exit)
.8:	bsr	undraw			; undraw old image (in old position)
	bsr	draw			; draw new image in new position
.r:	rts
