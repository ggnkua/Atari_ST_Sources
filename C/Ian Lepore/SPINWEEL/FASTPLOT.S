
;* Copyright 1990 by Antic Publishing, Inc.

;* tab expansion/compression should be set to '10' in your editor
  
;*************************************************************************     
;*	 
;* Fastplot -   Fast plotting of single pixels in any resolution.
;*	      Bypasses all OS screen-access routines, writes directly
;*	      to screen RAM.
;*
;* Author:      Ian Lepore.
;*
;* Related Files:
;*      FASTPLOT.H	 - C language header file.
;*      FASTPLOT.SH  - ASM language header file.
;*
;* Environment:
;*      Developed using Atari MadMac assembler.
;*
;* Maintenance:
;*
;*  06/03/89 -  v1.0
;*	      First version that integrates fplotlow(), fplotmed(), and
;*	      fplothi().  Also, first version that supports clipping.
;*************************************************************************     

;-------------------------------------------------------------------------
; Entry points for any-language callers (parms passed on stack)...
;-------------------------------------------------------------------------

	globl	_fplot		; fastplot
	globl	_fpl_init 	; init routine
	globl	_fpl_sclip	; set specific clipping rectangle
	globl	_fpl_dclip	; set default clipping rectangle
	globl	_fpl_sxlate	; set color translation table
	globl	_fpl_clrscrn	; fast clearscreen
	globl	_fpl_inrect	; determine if point is in rectangle.

;-------------------------------------------------------------------------
; Entry points for assembly-language callers (parms passed in regs)...
;-------------------------------------------------------------------------

	globl	fplot		; fastplot
	globl	fpl_inrect	; determine if point is in rectangle.

;-------------------------------------------------------------------------
; Some internal working variables (in text seg for PC-relative access)...
;-------------------------------------------------------------------------
	.text	    

vdicolrs: dc.b	0,15,1,2,4,6,3,5,7,8,9,10,12,14,11,13

toscolrs: dc.b	0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15

cur_rez:	dc.w	-1		; rez (initially undefined)  
      
cliptabl: dc.w	319,199		; clipping tables for the
	dc.w	639,199		;  high-end x/y for each
	dc.w	639,399		; of the 3 standard rez's.
	
cliprect: dc.w	0,0,0,0		; current clipping rectangle
pcliprect:dc.l	0		; pointer to clipping rectangle

scrbase:	dc.l	0		; pointer to screen logbase

;*************************************************************************     
;*
;* fpl_inrect - C-language entry point.
;*	      Return 0/1, indicating a point is IN/OUT of a rectangle.    
;*
;*	This routine compares an x/y point against a VRECT-type rectangle
;*	and returns a 0 if the points lies within the rectangle, or a 1
;*	if the point lies outside of it.  A point on the boundry of a 
;*	rectangle lies within it (EG, the point 1,1 lies within the
;*	rectangle 1,1,20,20).
;*
;*	If the caller provides a NULL pointer for the rectangle to be
;*	checked against, the internal rectangle (set by the last call
;*	to fpl_sclip() or fpl_dclip()) is used.
;*
;*	Note that this routine can be used for 'negative' clipping (to
;*	draw anywhere except inside a box), as follows:
;*
;*	VRECT inside_box = {20,20,80,80};
;*
;*	fpl_dclip();
;*
;*	if (FPL_NOTINRECT == fpl_inrect(&inside_box, x, y)
;*	      fplot(x,y,color);
;*
;*	This example will plot a point only if it lies within the screen
;*	boundries (due to the dclip call), but only if it is not within
;*	the box defined by the 'inside_box' VRECT;
;*
;*  Entry:						         
;*	10(sp) = Y-coordinate to be checked.
;*	 8(sp) = X-coordinate to be checked.
;*	 4(sp) = Pointer to rectangle to be checked against.
;*	         (NULL implies internal clipping rectangle is to be used).
;*
;*  Exit: 						         
;*	d0-d2/a0 Trashed. 
;*	         d0 indicates IN/OUT of rectangle:
;*		  d0 == 0, point is IN rectangle      (FPL_ISINRECT).
;*		  d0 == 1, point is OUT of rectangle  (FPL_NOTINRECT).
;*	         
;*  C:	boolean fpl_inrect( int *(cliprect[4]), int x, int y );
;*************************************************************************     

_fpl_inrect:
	move.l	4(sp),d0		; Get pointer to rectangle.
	bne.s	.user_rect	; If not NULL, go use supplied
	lea	cliprect(pc),a0	; rectangle, else load pointer to
	bra.s	.intl_rect	; our internal clipping rectangle.
.user_rect:	
	move.l	d0,a0		; Move user pointer to pointer reg.
.intl_rect:
	move.w	8(sp),d0		; Get  X from stack.
	move.w	10(sp),d1 	; Get  Y from stack. 
	bsr.s	fpl_inrect	; Go check against clipping rect.
	beq.s	.isinrect 	; If EQ return, point is in rect,
	moveq.l	#1,d0		; else point is out, indicate such.
	bra.s	.return
.isinrect:		
	moveq.l	#0,d0		; Point is in rect, indicate such.
.return:
	rts			; Return IN/OUT (0/1) to caller.
	
;*************************************************************************     
;*
;* fpl_inrect - ASM-language entry point.
;*	      Return EQ/NE, indicating a point is IN/OUT of a rectangle.    
;*
;*	See comments under the C-language entry above.
;*
;*  Entry:						         
;*     a0 -> VRECT-type rectangle				         
;*     d0  = x						         
;*     d1  = y						         
;*
;*  Exit: 						         
;*     a0 trashed						         
;*     everything else preserved except CCR which indicates TRUE/FALSE.        
;*
;*  C:  N/A  
;*************************************************************************     

fpl_inrect:							   
	cmp.w	(a0)+,d0	 
	blt.s	.notinrect 
	cmp.w	(a0)+,d1	 
	blt.s	.notinrect 
	cmp.w	(a0)+,d0	 
	bgt.s	.notinrect 
	cmp.w	(a0),d1	 
	bgt.s	.notinrect 
	move.w	#$04,CCR		; Set EQ flag in CCR.
.notinrect:		 
	rts		 
 
;*************************************************************************     
;* 
;* fplot - Do a fastplot.
;*
;*	Plot a point of a given color at a given x/y location.  This
;*	routine is resolution-independant (unless the calling program
;*	changes rez or screen location between fplot calls, see below...)  
;*
;*	This routine has 2 entry points; one for C language callers (in
;*	which the x/y/color info is passed on the stack), and one for
;*	assembly-language callers (in which the parms are passed in
;*	registers).  
;*
;*	For the C-language entry point:
;*
;*	  The plot will be clipped (optional) if the caller has previously 
;*	  set a clipping rectangle via an '_fpl_?clip' routine.  It is
;*	  a bit faster to disable clipping (about 8-10%), but be SURE 
;*	  the calling program does not exceed the x/y coordinates of the
;*	  current screen resolution.	Attempts to plot 'off the screen'
;*	  when clipping is disabled will generally lock up the machine.
;*  
;*	  On the first call to this routine, an automatic internal call
;*	  will be made to the initializer routine, unless the init routine
;*	  has previously been invoked explicitly by the calling program.
;*	  If the calling application changes the TOS screen resolution
;*	  or the logical screen location (Logbase) 'on the fly', it 
;*	  should make a call to '_fpl_init' after each rez change.	
;*	  If the caller never changes the screen rez or location, it is 
;*	  not necessary to call the init routine explicitly.
;* 
;*	For the assembly-language entry point:
;*
;*	  The auto-init and clipping features are not available on the
;*	  assembly-language entry point; it is the assembly-caller's
;*	  responsibility to call the clipping routine ('fpl_inrect')
;*	  separately before each plot call, and to call the init routine
;*	  before the first plot call.
;*
;*  Entry: (C / ASM)
;*	8(sp) / d2 = Plot color.
;*	6(sp) / d1 = Plot Y.
;*	4(sp) / d0 = Plot X.
;*
;*  Exit:
;*	d0-d2/a0-a1  Trashed.
;*		   d0 indicates whether a plotted point was clipped:
;*		     d0 == 0, point was clipped.
;*		     d0 != 0, point was plotted.
;*
;*  C:	boolean fplot( int x, int y, int color);
;*************************************************************************     

_fplot:				; C entry point		      

	move.w	4(sp),d0		; Get x from stack.
	move.w	6(sp),d1		; Get y from stack.

	move.l	pcliprect(pc),d2	; Load ptr to clipping rectangle,
	beq.s	.noclip		; if pointer is NULL, no clipping.

	move.l	d2,a0		; Move pointer to parm-passing
	bsr.s	fpl_inrect	; register and call clip checker.
	beq.s	.noclip		; If inside the clip area, continue,
	moveq.l	#0,d0		; else return a 0 (indicating that
	rts			; point was clipped), and return.
.noclip:
	move.w	8(sp),d2		; Load color from stack.
	
fplot:				; ASM entry point	        
	
	and.w	#$000F,d2 	; Insure requested color is legal,
	move.b	colrtabl(pc,d2.w),d2; then translate via color table.
.replot:
	lsl.w	#2,d1		; Make row # into an index to a long.	     
	move.l	scrnaddr(pc,d1.w),a0; Calculate screenline start addr.	    

	move.w	cur_rez(pc),d1	; Load current resolution. If neg,
	bpl.s	.initdone 	; we have to call the init routine
	bsr	_fpl_init 	; before trying to plot.
	move.w	6(sp),d1		; Refresh row number from entrytime
	bra.s	.replot		; value and try again.
.initdone:
	move.l	plotjmp(pc,d1.w),a1 ; Load pointer to the plot routine
	jmp	(a1)		; for this resolution and call it.

;-------------------------------------------------------------------------
; color translation table...
;  Must remain near ' move  colrtabl' instruction for pc-relative access. 
;
; plot-routine jump table...
;  Must remain near ' move  plotjmp' instruction for pc-relative access.
;
; screen address table...
;  Must remain near ' move  scrnaddr' instruction for pc-relative access.
;-------------------------------------------------------------------------

colrtabl: dc.b	0,1,2,3,4,5,6,7,8
	dc.b	9,10,11,12,13,14,15

plotjmp:				; Jump table for resolution-
	dc.l	plot_lo		; dependant plot routines.
	dc.l	plot_med
	dc.l	plot_hi
	
scrnaddr: dcb.l	400,0		; Table for storing screenline ptrs.

;-------------------------------------------------------------------------
; Special-case routines to quickly blank-out a pixel (plot color 0).
;-------------------------------------------------------------------------	    beq	    blank_med	     ; we can blank the pixel fast.

maskclr:	dc.l	$7fff7fff,$bfffbfff,$dfffdfff,$efffefff
	dc.l	$f7fff7ff,$fbfffbff,$fdfffdff,$fefffeff
	dc.l	$ff7fff7f,$ffbfffbf,$ffdfffdf,$ffefffef
	dc.l	$fff7fff7,$fffbfffb,$fffdfffd,$fffefffe

blank_lo:
	
	lsl.w	#2,d0		; 4 * bitnum
	move.l	maskclr(PC,d0.w),d0 ; Get mask
	and.l	d0,(a0)+
	and.l	d0,(a0)
	rts

blank_med:
	
	lsl.w	#2,d0		; 4 * bitnum
	move.l	maskclr(PC,d0.w),d0 ; Get mask
	and.l	d0,(a0)
	rts

;-------------------------------------------------------------------------
; low-rez plot routine...
;-------------------------------------------------------------------------

plot_lo:

	move.w	d0,d1		 ; Colnum in d1
	and.w	#$F,d0		 ; Bit num in dO		         
	and.w	#$FFF0,d1 	 ; Byte num in d1		         
	lsr.w	#1,d1		 ; div by 2		         
	add.w	d1,a0		 ; Got screen offset in a0	         

	tst.w	d2		 ; Special case:  if color is zero,
	beq	blank_lo		 ; we can blank the pixel fast.

	add.w	d0,d0		 ; double bitnum		         
	move.w	masktabl(pc,d0.w),d0 ; Get mask		         
	move.w	d0,d1		 ; Put in d1 also		         
	not.w	d1		 ; And inverse it		         
     
	btst	#0,d2		; test color bit 0...
	beq.s	.clear0		; if clear, we clear it on screen,
	or.w	d0,(A0)+		; else we set it on screen,	        
	bra.s	.check1		; then continue with next color bit.
.clear0:	and.w	d1,(A0)+		
.check1:	btst	#1,d2		; do color bit 1...
	beq.s	.clear1	      
	or.w	d0,(a0)+	       
	bra.s	.check2	      
.clear1:	and.w	d1,(a0)+	       
.check2:	btst	#2,d2		; do color bit 2...
	beq.s	.clear2	      
	or.w	d0,(a0)+	       
	bra.s	.check3	      
.clear2:	and.w	d1,(a0)+	       
.check3:	btst	#3,d2		; do color bit 3...
	beq.s	.clear3	      
	or.w	d0,(a0)
	bra.s	.return	      
.clear3:	and.w	d1,(a0)	        

.return:	moveq.l	#1,d0
	rts			; all done, return

;-------------------------------------------------------------------------
; mask table for low and medium rez plot routines.
;  Must remain between low & med rez routines for pc-relative access.
;-------------------------------------------------------------------------

masktabl: dc.w	$8000,$4000,$2000,$1000	  
	dc.w	$0800,$0400,$0200,$0100	  
	dc.w	$0080,$0040,$0020,$0010	  
	dc.w	$0008,$0004,$0002,$0001	  
     
;-------------------------------------------------------------------------
; med-rez plot routine...
;-------------------------------------------------------------------------

plot_med:

	move.w	d0,d1		 ; Colnum in d1
	and.w	#$F,d0		 ; Bit num in dO		         
	and.w	#$FFF0,d1 	 ; Byte num in d1		         
	lsr.w	#2,d1		 ; div by 4		         
	add.w	d1,a0		 ; Got screen offset in a0	         
         
	tst.w	d2		 ; Special case:  if color is zero,
	beq	blank_med 	 ; we can blank it quickly.

	add.w	d0,d0		 ; double bitnum		         
	move.w	masktabl(pc,d0.w),d0 ; Get mask		         
	move.w	d0,d1		 ; Put in d1 also		         
	not.w	d1		 ; And inverse it		         
     
	btst	#0,d2		; test color bit 0...
	beq.s	.clear0		; if clear, we clear it on screen,
	or.w	d0,(A0)+		; else we set it on screen,	        
	bra.s	.check1		; then continue with next color bit.
.clear0:	and.w	d1,(A0)+		
.check1:	btst	#1,d2		; do color bit 1...
	beq.s	.clear1	      
	or.w	d0,(a0)	      
	bra.s	.return
.clear1:	and.w	d1,(a0)	      

.return:	moveq.l	#1,d0		; indicate plot was not clipped,
	rts			; and return.

;-------------------------------------------------------------------------
; high-rez plot routine...
;-------------------------------------------------------------------------

plot_hi:

	move.w	d0,d1		; Colnum in d1
	and.w	#$7,d0		; Bit num in dO	       
	eor.w	#$7,d0		; inverse bitnum	       
	lsr.w	#3,d1		; div colnum by 8			     
	add.w	d1,a0		; Got screen offset in a0	        
         
	tst.b	d2		; should we clear or set bit?
	beq.s	.clear		; color == 0, clear bit.
	bset.b	d0,(a0)		; color == 1, set bit...
	bra.s	.return		; ...and return
.clear:	bclr.b	d0,(a0)		; clear bit...
.return:	moveq.l	#1,d0		; ...indicate plot was not clipped,
	rts			; return to caller.
	
;*************************************************************************     
;* 
;* fastplot init - Setup internal values & tables for the fastplot system.
;*
;*	This routine does the following:
;*	- Saves all registers used.
;*	- Finds the current logical screen location via XBIOS Logbase().
;*	- Finds the current screen resolution via XBIOS Getrez(). (Our
;*	  internal representation of resolution is Getrez() * 4, since
;*	  we always use it as an index into longword tables).
;*	- Build a table of pre-calculated addresses for the first pixel
;*	  on each line of the screen.
;*	- Restore all regs and return.
;*
;*	The pre-calc'd screen addresses are the heart of the fastplot
;*	system.  At plotime, the 'y' coordinate is converted to a screen
;*	address via a quick table lookup (2 instructions), instead of 
;*	a slow multiply (or sequence of instructions to do a so-called
;*	'fast' multiply).
;*
;*	The one drawback to this is that the init routine must be called
;*	every time the screen resolution or location is changed.  This
;*	routine executes pretty quickly, however, and the overhead of
;*	calling it should be minimal.
;*
;*  Entry: nothing.
;*  Exit:  all regs preserved.
;*  C:	 void fpl_init();
;*
;*************************************************************************     
         
_fpl_init:         

	movem.l	d0-d2/a0-a2,-(sp)	; We must save regs for fplot.

	move.w	#3,-(sp)		; XBIOS Logbase() call	         
	trap	#14	  
	addq.l	#2,sp
	lea	scrbase(pc),a0	; Load pointer to screen addr var.
	move.l	d0,(a0)		; Save screen address.

	move.w	#4,-(sp)		; XBIOS Getrez() call
	trap	#14
	addq.l	#2,sp
	lsl.w	#2,d0		; Save rez*4, a longword index.
	lea	cur_rez(pc),a0	; Load pointer to resolution var.
	move.w	d0,(a0)		; Save current resolution.

	lea	scrnaddr(pc),a1	; Make ptr to our addr table. 	   
	move.l	scrbase(pc),a2	; Prime screen address counter.   
	     
	moveq.l	#0,d2		; Clean out linesize reg.
	move.w	#160,d2		; Prime linesize constant.	         
	move.w	#199,d1		; Prime loop counter.	         
	cmp.w	#8,d0		; Is this high rez?
	bne.s	.addrloop 	; Nope, all set to fly.
	move.w	#80,d2		; Yep, set linesize and line
	move.w	#399,d1		; counter  for high rez.
.addrloop:         
	move.l	a2,(a1)+		; Store linestart addr into table,     
	add.l	d2,a2		; add offset to next line,	         
	dbra	d1,.addrloop	; loop until all addrs calulated.      

	movem.l	(sp)+,d0-d2/a0-a2	; Init done, restore regs,
	rts			; and return to caller.

;*************************************************************************     
;* 
;* fpl_sclip - Set specific clipping rectangle for fastplot.
;*
;*	Accepts a pointer to a clipping rectangle. (A VRECT-type
;*	rectangle if you are using the GEMFAST bindings.)  The
;*	rectangle should contain the x/y coordinates of the upper left
;*	and lower right corners of the area to be clipped.  Points on
;*	the clipping boundry are considered to be within the area. 
;*
;*	The values are copied from the clipping rectangle provided to
;*	an internal array, so the caller's array/structure need not be
;*	permenant in the calling program. (EG, can be stack-allocated). 
;*
;*	A NULL pointer disables clipping.  Clipping is initially disabled
;*	by default.
;*
;*	Use the fpl_dclip routine to set a 'default' clipping rectangle
;*	which is the same size as the screen.
;*
;*  Entry:
;*	4(sp) =  Pointer to clipping rectangle.
;*	         If pointer is NULL (0L), clipping is disabled.
;*  Exit:
;*	d0/a0-a1 Trashed.
;*
;*  C:
;*      void fpl_sclip( int *(cliprect[4]) ); 
;*
;* Example:
;*	int pxy[4] = {0,0,319,199};
;*		or
;*	VRECT myclip = {20,20,90,90};
;*
;*	fpl_sclip(pxy);
;*		or
;*	fpl_sclip(&myclip);
;*************************************************************************     

_fpl_sclip:
	move.w	cur_rez(pc),d0	; Check the current rez, just to
	bpl.s	.initdone 	; see if an init has been done.
	bsr	_fpl_init 	; Go do an init if cur_rez is -1.
.initdone:
	move.l	4(sp),d0		; Get pointer to caller's clipping
	beq.s	.noclip		; rectangle.  If NULL, disable
	move.l	d0,a0		; clipping, else move pointer to
	lea	cliprect(pc),a1	; addr reg and get pointer to our
	move.l	a1,d0		; internal clipping rectangle. Save
	move.l	(a0)+,(a1)+	; our internal pointer, and copy
	move.l	(a0),(a1) 	; the caller's rectangle to ours.
.noclip:	
	lea	pcliprect(pc),a0	; Store pointer to clipping
	move.l	d0,(a0)		; rectangle.
	rts

;*************************************************************************
;*
;* fpl_dclip - Set a default clipping rectangle for fastplot.
;*
;*	This routine sets a default clipping rectangle which is the
;*	size of the screen dimensions for the current resolution.  If
;*	clipping was previously disabled, this routine will enable it.
;*
;*  Entry:  nothing
;*  Exit:   d0-d2/a0-a1 trashed.
;*  C:	  void fpl_dclip();
;*
;*************************************************************************


_fpl_dclip:
	move.w	cur_rez(pc),d0	; Get the current screen rez, if
	bpl.s	.initdone 	; undefined (-1), call the init
	bsr	_fpl_init 	; routine first, then go back and
	bra.s	_fpl_dclip	; get the (now valid) rez again.
.initdone:
	
	lea	cliprect(pc),a1	; Load a pointer to our clipping
	lea	pcliprect(pc),a0	; rectangle, and save the pointer
	move.l	a1,(a0)		; into our pointer variable.
	
	lea	cliptabl(pc),a0	; Build the pointer to this rez's
	add.w	d0,a0		; clipping values.
	
	clr.l	(a1)+		; The low x/y clip is always zero,
	move.l	(a0),(a1) 	; the high x/y comes from the table.

	rts			; All done, return.

;*************************************************************************
;*
;* fpl_clrscrn - Clear the screen, fairly quickly.
;*
;*	This brute force fastclear simply unrolls the clear loop to the
;*	point where 64 bytes are cleared per loop iteration.
;*
;*  Entry:  nothing.
;*  Exit:   d0-d1/a0 trashed.
;*  C:	  void fpl_clrscrn();
;*************************************************************************
	
_fpl_clrscrn:
	move.l	scrbase(pc),a0
	moveq.l	#0,d0
	move.w	#499,d1
.clearloop:
	move.l	d0,(a0)+
	move.l	d0,(a0)+
	move.l	d0,(a0)+
	move.l	d0,(a0)+
	move.l	d0,(a0)+
	move.l	d0,(a0)+
	move.l	d0,(a0)+
	move.l	d0,(a0)+
	move.l	d0,(a0)+
	move.l	d0,(a0)+
	move.l	d0,(a0)+
	move.l	d0,(a0)+
	move.l	d0,(a0)+
	move.l	d0,(a0)+
	move.l	d0,(a0)+
	move.l	d0,(a0)+
	dbra	d1,.clearloop
	rts

;*************************************************************************
;*
;* _fpl_sxlate - Set color translation table.
;*
;*	This routine allows the caller to set the color translation
;*	table used by the fplot routine.  There are two built-in color
;*	translations, TOS mode (effectively no translation) and VDI 
;*	mode, in which VDI colors are remapped to TOS colors.
;*
;*	For some odd reason, Atari made TOS and VDI intrepret color
;*	index numbers differently.  For VDI, foreground/background
;*	are always colors 0 and 1.  For TOS, the background color 
;*	is always the highest color number: 15 for low rez, 3 for
;*	medium rez, 1 for high rez.  When VDI color translation is
;*	requested, the fplot routine will translate a request to plot
;*	color # 1 (background) to color 15 (if in low rez), and so on.
;*	(There are other VDI/TOS color differences, VDI mode will 
;*	handle all the translations, not just foreground/background).
;*	This allows mixed usage of VDI and fplot in the same program.
;*
;*	The caller may also request custom color translation, by 
;*	providing a pointer to a translation table.  The translation
;*	table must be 16 bytes long, and each byte in the table 
;*	represents the new color index that will be output.  For example,
;*	if the 5th byte in the table is a 7, then a request to plot
;*	color number 5 results in color 7 being plotted.
;*
;* Entry:
;*	4(sp) - Translation mode or pointer to translation table.
;*	        -1L = FPL_VDIXLATE - Set VDI translation mode.
;*	         0L = FPL_TOSXLATE - Set TOS translation mode.
;*	        >0L = Pointer to custom translation table.
;*
;* Exit:
;*	d0/a0-a1 - Trashed.    
;*
;* C:	void fpl_sxlate( char *pxlatetab );
;*	void fpl_sxlate( FPL_VDIXLATE );
;*	void fpl_sxlate( FPL_TOSXLATE );
;*
;*************************************************************************

_fpl_sxlate:
	move.l	4(sp),d0		; Get pointer/mode.
	beq.s	.tostab		; If NULL, go set TOS mode,
	bmi.s	.vditab		; If NEG, go set VDI mode,
	move.l	d0,a0		; else we have a pointer to a 
	bra.s	.moveit		; custom table, go copy it.
.tostab:
	lea	toscolrs(pc),a0	; Set pointer to TOS translation
	bra.s	.moveit		; table (no translation, basically).
.vditab:				
	lea	vdicolrs(pc),a0	; Set pointer to VDI xlate table.
.moveit:
	lea	colrtabl(pc),a1	; Set pointer to internal
	move.l	(a0)+,(a1)+	; translation table used by fplot,
	move.l	(a0)+,(a1)+	; copy 16 bytes from the caller's
	move.l	(a0)+,(a1)+	; table (or a default table).
	move.l	(a0)+,(a1)+

	lea	colrtabl+1(pc),a0	; Now we have to fixup the background
	moveq.l	#1,d1		; color mapping based on resolution.
	move.w	cur_rez(pc),d0
	beq.s	.fixlowrez	; Go do low rez.
	cmp.w	#4,d0
	beq.s	.fixmedrez	; Go do med rez.
	bra.s	.done		; Do nothing for high rez.
.fixlowrez:
	move.b	#15,(a0)		; Set BG = color 15 for low rez.
	bra.s	.done
.fixmedrez:	
	move.b	#3,(a0)		; Set BG = color 3 for med rez.
.done:
	rts			; Return to caller.
	
	end
	

