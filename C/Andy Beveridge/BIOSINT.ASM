**********************************************************
* an attempt to intercept bios calls through trap13	 *
* ...if this works I'll try the keyboard macro routines. *
* Should also be interesting to try out that Ptermres(). *
*	 written 13/1/86 by Andy Beveridge.		 *
**********************************************************

ptermres	equ	$31		;GEMDOS code for ptermres()
bconin		equ	$2		;BIOS code for device input()
setexc		equ	$5		;BIOS code for setexc()
dosound		equ	32		;XBIOS code for dosound()
*
* Should really ask TOS where the screen is but I'm
* feeling lazy. If, like me, you're on a 1 meg ST then
* this should be changed to $f8000.
*
screen		equ	$78000		;address of start of screen.


illegal		macro
		dc.w	$4afc		;illegal opcode
		endm
*
* This first bit of code changes the 68000 trap vector used
* for BIOS calls to point to our intercept routine.
* We save the old vector so we can pass control back to
* the BIOS if we're not interested in the call being made.
*
first
installvec	pea	intercept	;push address of our handler
		move.w	#45,-(sp)	;push vector # for trap #13
		move.w	#setexc,-(sp)	;push BIOS code for setexc()
		trap	#13		; go set that vector!
		addq.l	#8,sp		;tidy the stack
		move.l	d0,savedvec	;and save the old vector.
*
* This next bit returns us to the desktop (or wherever we came from.)
* but instructs GEMDOS to mark this 1k of RAM as used.
* This allows the code to remain in memory, protected by TOS.
* Other programs will be loaded after this protected area.
* This code will thus remain functional after exiting.
* This is a good way to install your own interrupt handlers
* or intercept TOS calls (e.g. for RAM-DISK or PRINT-SPOOLER)
*
terminate
		clr.w	-(sp)		;push process return value
		move.l	#1024,-(sp)	;push No of bytes to save
		move.w	#ptermres,-(sp) ;push GEMDOS code for ptermres()
		trap	#1		;o.k. GEMDOS, do it!

		illegal			;...it shouldn't get this far
*
*	The actual TRAP handler starts here...
* This bit of code gets control every time a BIOS
*      (trap #13) call is made by anybody.
* Watch what registers You use or things can get upset!
*
intercept	move.l	sp,a0		;get stack pointer as parm pointer
*
* Note this could be called from Supervisor or User mode.
* If you don't know what the difference is then
* look it up in a 68000 assembler book. It's something
* every 68000 programmer should know about!
*
		move.w	(sp),d0		;copy status word from stack top
		btst	#13,d0		;in supervisor mode ?
		bne.s	insuper		;branch if necessary
inuser	;if in user mode must get parm stack & adjust it
		move.l	usp,a0		;need a copy of the user stack
		addq.l	#6,a0		;add 6 bytes so same as for super call

* can now get all parms starting at 6(a0)

insuper		move.w	6(a0),d0	;copy function # from stack
		cmp.w	#bconin,d0	;is it the code for input?
		bne.s	notours		;not conin so just pass it on to BIOS
*
* O.K. we've intercepted a Bconin (console input) request.
* just to show that we got it o.k. let's put something on
* on the screen and make a noise. You'll only get the noise
* if you've got keyclicks turned off.
*
		not.l	screen		;invert first longword of screen ram
*
* Note that contrary to spec. the bios CAN be called recursively
* although only to about 4 levels in current version (0.19).
*
		pea	clickit		;push pointer to dosound data
		move.w	#dosound,-(sp)	;push code for dosound()
		trap	#14		;call XBIOS to make noise.
		addq.l	#6,sp		;tidy up the stack
*
* Now pass the call on to the BIOS.
*
notours
		move.l	savedvec,a0	;get original vector
		jmp(a0)			;and go to it

last		;last byte of text section

		data
*
* REGISTER #, DATA	program for sound daemon.
*
clickit		dc.b	0,50	;a sort of chime noise
		dc.b	1,0
		dc.b	2,100
		dc.b	3,0
		dc.b	4,200
		dc.b	5,0
		dc.b	6,0
		dc.b	7,%111000
		dc.b	8,$10
		dc.b	9,$10
		dc.b	10,$10
		dc.b	11,$80
		dc.b	12,4
		dc.b	13,0
		dc.b	255,0	;This code terminates the sound data.

		bss

savedvec	ds.l	1	;will save TRAP #13 vector here

		end
