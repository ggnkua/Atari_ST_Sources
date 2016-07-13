*
* At the time this was one of the first sync scrolling source codes
* available.  Its not fast compared to sync scrolling techniques now
* but its well commented and easy enough to follow .....    
*                                                              MAT 
*
* Tony B brings you HardWare scrolling on the ST! WOW!
* Mega-thanx to Pacman for sending this down to me ....cheers matey!
*
* This code implements hardware scrolling on an Atari ST (NOT STE).
* This code is (c)1990 David Clear and is free.
* Feel free to use this code or modifications of it for whatever
* you so desire - commercial or private.
*
*	NOW LET'S HAVE SOME DAMN FAST NEW GAMES!
*
* Note:
*	A 'feature' of this code is that it displays around 208
*	scan lines instead of 200. If you want to force 200 scan lines
*	then you can:
*
*a) Re-write the top border code and extend the
*   timer D delay.
*b) Remove the palette re-load at the end of the
*   scroll code and set a raster interrupt lower
*   down to re-load the palette.
*
* Important routines:
*	myvbi- Timer D startup code & register loading.
*	topb- Top border scroll code.
*	setscrn- Screen address setup.

* Macro to create a given number of NOP instructions.
* Used for timing.
* eg:
*	nops	4
* creates:
*	nop
*	nop
*	nop
*	nop
*
* 1 nop is 8 cycles. Long numbers of nops can be replaced by dbra loops
* and the like. (Errr, actually a nop is 4 cycles....Tony -B-).
nops	macro
	dcb.w	\1,$4e71
	endm

* Picture data
SCREEN	equ	$78002		* Address of image
PICTURE	equ	SCREEN-34	* Address to load .PI1 picture
PALETTE	equ	PICTURE+2	* Address of palette

* Hardware labels
vbi_vec		equ	$70
timerd_vec	equ	$110

vid_baseh	equ	$ffff8201
vid_basem	equ	$ffff8203
vid_countl	equ	$ffff8209
vid_sync	equ	$ffff820a
vid_shift	equ	$ffff8260
vid_palette	equ	$ffff8240

ikbd_data	equ	$fffffc02

mfp_iera	equ	$fffffa07
mfp_ierb	equ	$fffffa09
mfp_isrb	equ	$fffffa11
mfp_imrb	equ	$fffffa15
mfp_tcdcr	equ	$fffffa1d
mfp_tddr	equ	$fffffa25

* This just demonstrates the routine. It is non-exitable. You have
* to reset to get out of it. Nevermind.
start	lea	vars,a6		* a6 -> variables
	clr.l	-(sp)		* Go into supervisor mode
	move.w	#$20,-(sp)
	trap	#1
	addq.w	#6,sp
	move.l	#mystack,a7	* Set my stack pointer

	clr.w	-(sp)
	move.l	#-1,-(sp)	* Set low res.
	move.l	#-1,-(sp)
	move.w	#5,-(sp)
	trap	#14
	lea	10(sp),sp

	bsr	drawscr		* Draw the screen

	move.w	#$2700,sr		* Kill interrupts
	move.l	#SCREEN,d0		* Set the screen address
	move.l	d0,screen(a6)

	bsr	setscrn

	clr.b	(mfp_iera).w		* Clear IERA
	clr.b	(mfp_ierb).w		* Clear IERB
	andi.b	#$f8,(mfp_tcdcr).w	* Stop timer D
	bset.b	#4,(mfp_ierb).w		* Enable timer D
	bset.b	#4,(mfp_imrb).w		* Mask enable timer D
	move.l	#myvbi,(vbi_vec).w	* Set VBI address

.die	stop	#$2300			* Enable VBI
	bra.s	.die			* Forever and ever...

* Load a .PI1 screen into screen memory
drawscr	clr.w	-(sp)
	pea	.fname(pc)		* Fopen()
	move.w	#$3d,-(sp)
	trap	#1
	addq.w	#8,sp

	move.w	d0,d3
	move.l	#PICTURE,-(sp)
	move.l	#32066,-(sp)
	move.w	d0,-(sp)		* Fread()
	move.w	#$3f,-(sp)
	trap	#1
	lea	12(sp),sp

	move.w	d3,-(sp)		* Fclose()
	move.w	#$3e,-(sp)
	trap	#1
	addq.w	#4,sp

	rts

* Replace this string with a suitable Degas file
.fname	dc.b	'wiz.pi1',0
	even

* This is the VBI code. The VERY FIRST thing to be done is to set up
* the timer D interrupt.
myvbi	move.l	#topb,(timerd_vec).w	* Set timer D interrupt vector
	move.b	#$65,(mfp_tddr).w	* Set timer D data register
	andi.b	#$f8,(mfp_tcdcr).w	* Set timer D subdivider mode
	ori.b	#4,(mfp_tcdcr).w	* Start timer
*---------------------------------------*
* This code is not time critical but should stay here
	movem.l	d0-d7/a0-a6,-(sp)	* Save all the registers
	move.b	bscan(a6),d0		* Move the overscan registers
	ext.w	d0			* into working registers
	move.w	d0,wbscan(a6)
	move.b	rscan(a6),d0
	ext.w	d0
	move.w	d0,wrscan(a6)
	move.b	nscan(a6),d0
	ext.w	d0
	move.w	d0,wnscan(a6)
*---------------------------------------*
* Now just a little keyboard control code.
* VERY poorly written, but what do you want for nothing?
	move.b	(ikbd_data).w,d0	* Get key code
	cmpi.b	#$4b,d0			* Left arrow?
	bne.s	.nl			* No
	subq.l	#8,screen(a6)		* Screen = screen - 8
	bra.s	.yes			* Set the address

.nl	cmpi.b	#$4d,d0			* Right arrow?
	bne.s	.nr			* No
	addq.l	#8,screen(a6)		* Screen = screen + 8
	bra.s	.yes			* Set the address

.nr	cmpi.b	#$48,d0			* Up arrow?
	bne.s	.nu			* No
	subi.l	#160,screen(a6)		* Screen = screen - 160
	bra.s	.yes			* Set the address

.nu	cmpi.b	#$50,d0			* Down arrow?
	bne.s	.no			* No
	addi.l	#160,screen(a6)		* Screen = screen + 160

*---------------------------------------*
* Call setscrn to set the screen address
.yes	move.l	screen(a6),d0		* Set the screen address
	bsr	setscrn

*---------------------------------------*
* What is done finally is to set the video chip's screen pointers.
* This should be done after the call to setscrn.
* NOTE:
*     The physbase register is latched on the VBI. This means that
* this change will not effect the screen about to be drawn but will
* effect the following screen. Anyone who uses double buffered screens
* will know this already.

.no	move.b	vidh(a6),(vid_baseh).w	* Set the video pointer
	move.b	vidm(a6),(vid_basem).w
*---------------------------------------*
	movem.l	(sp)+,d0-d7/a0-a6
	rte

* This function sets the screen base address. Well, it doesn't
* really load the video pointers, it just sets up variables which
* the vbi will use.
*---------------------------------------*
* IMPORTANT
* ---------
* The screen can be moved on 8 byte boundaries. There is a 'feature'
* of the top border code that means the screen is shifted two bytes.
* This means that if you call this function with #$78000 in d0, the
* REAL beginning of your screen will be $78002.
*---------------------------------------*
* Set screen address
* Input:
*	d0.l = Address to put screen.

setscrn	subi.l	#320,d0			* The magic offset
	move.b	d0,d1			* Save low byte
	lsr.l	#8,d0
	move.b	d0,vidm(a6)		* Store mid byte
	lsr.l	#8,d0
	move.b	d0,vidh(a6)		* Store high byte
	lea	normal(pc),a0
	lsr.b	#3,d1			* Multiples of 8
	ext.w	d1
	move.b	0(a0,d1.w),nscan(a6)		* Normal scan lines
	move.b	right-normal(a0,d1.w),rscan(a6)	* Right overscan
	move.b	both-normal(a0,d1.w),bscan(a6)	* R & L overscan
	move.b	offset-normal(a0,d1.w),d0	* Video base offset
	sub.b	d0,vidm(a6)			* Subtract from video base
	bcc.s	.ok
	subq.b	#1,vidh(a6)
.ok	rts

screen	rs.l	1

* Variables used by the code
vidh	rs.b	1				* Video address
vidm	rs.b	1
rscan	rs.b	1				* Number of lines of overscan
bscan	rs.b	1
nscan	rs.b	1
wrscan	rs.w	1				* Working variables
wbscan	rs.w	1
wnscan	rs.w	1

* This is the scroll code. It uses overscan to allign the screen.
* The overscan takes 20 scan lines but 22 are required to make things
* look nice. So that the 22 scan lines aren't eaten from the play area
* the top border is removed and the overscan done in there.
* IMPORTANT:
* The top border removal shifts the screen by 2 bytes.

zeroes	dc.l	0,0,0,0,0,0,0,0		* Zeroes for palette
topb	andi.b	#$f8,(mfp_tcdcr).w	* Stop timer D
	movem.l	d0-d7/a0-a3,-(sp)	* Save some registers
	movem.l	zeroes(pc),d0-d7	* Clear the palette
	movem.l	d0-d7,(vid_palette).w

*---------------------------------------*
* Load some important registers

	lea	(vid_sync).w,a0		* a0 -> video sync
	lea	(vid_shift).w,a1	* a1 -> video mode
	lea	(vid_countl).w,a2	* a2 -> video low byte counter
	moveq	#0,d0			* 60Hz/Low res
	moveq	#2,d1			* 50Hz/High res

*---------------------------------------*
* Pick up the number of respective overscan lines needed
	move.w	wbscan(a6),d3		* Left & right overscan
	move.w	wrscan(a6),d4		* Right overscan
	move.w	wnscan(a6),d5		* No overscan

*---------------------------------------*
* Remove top border

	lea	.skip(pc),a3		* a3 -> Sync buffer
	move.b	d0,(a0)			* 60Hz
	nops	81			* Wait for next line
	move.b	d1,(a0)			* 50Hz

*---------------------------------------*
* Sync on raster
.loop	tst.b	(a2)			* Screen running?
	beq.s	.loop			* No
	move.b	(a2),d2			* Get low byte
	adda.l	d2,a3			* Add to sync buffer
	jmp	(a3)			* Jump into sync buffer
.skip	nops	100			* Sync buffer

*---------------------------------------*
* This code performs left and right overscan
	bra	btest			* Branch to overscan test
lboth	nop
	move.b	d1,(a1)			* You really think I can
	move.b	d0,(a1)			* be bothered to comment
	nops	89			* all these nops and
	move.b	d0,(a0)			* loads? You must be out
	move.b	d1,(a0)			* of your mind.
	nops	13
	move.b	d1,(a1)
	nop
	move.b	d0,(a1)
	nops	9
btest	dbra	d3,lboth		* Do next line

*---------------------------------------*
* This code performs right overscan
	bra	rtest			* Branch to overscan test
lright	nops	87
	move.b	d0,(a0)
	move.b	d1,(a0)
	nops	13
	move.b	d1,(a1)
	nop
	move.b	d0,(a1)
	nops	16
rtest	dbra	d4,lright

*---------------------------------------*
* This code does nothing but is used for timing the palette re-load.
* If you only want 200 raster lines then just remove this code and
* set up a raster interrupt for a few lines down.
* DON'T remove the d5 loading code at the beginning as this may throw out
* the top border removal code. If it does then increment the number of
* nops in the top border code.
	bra	ntest
lnorm	nops	125
ntest	dbra	d5,lnorm

*---------------------------------------*
* Reload the palette
	nops	75			* Wait for end of line
	movem.l	PALETTE,d0-d7
	movem.l	d0-d7,(vid_palette).w
end	movem.l	(sp)+,d0-d7/a0-a3	* Restore registers
	bclr.b	#4,(mfp_isrb).w		* Clear MFP ISR bit
rte

* This is the magic table which makes it all possible.
* DON'T MESS WITH IT!
normal	dc.b	9,10,4,5,6,0,16,10,11,12,13,0,1,2,3,4
	dc.b	20,14,0,1,10,11,12,6,0,1,2,3,12,13,0,0
right	dc.b	5,2,8,5,2,8,4,10,7,4,1,16,13,10,7,4,0
	dc.b	6,4,1,6,3,0,6,12,9,6,3,8,5,20,0
both	dc.b	6,8,8,10,12,12,0,0,2,4,6,4,6,8,10,12
	dc.b	0,0,16,18,4,6,8,8,8,10,12,14,0,2,0,20
offset	dc.b	$f,$f,$10,$10,$10,$11,$d,$e
	dc.b	$e,$e,$e,$10,$10,$10,$10,$10
	dc.b	$c,$d,$11,$11,$e,$e,$e,$f
	dc.b	$10,$10,$10,$10,$d,$d,$f,$11

	even
vars	ds.b	__RS

	even
	ds.l	100
mystack
