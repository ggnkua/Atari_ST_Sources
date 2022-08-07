
#include "..\\include\\lists.h"
#include "..\\include\\poly.h"
#include "asm.i"
#include "poly.i"


extern int *cscreen;

/*
* Colour version of linedraw, using 4 bitplanes.

* Line drawn from (d4,d5) -> (d6,d7).  No clipping done.

* - For up to 4 bitplanes -
*/

extern cymajor0();
extern cymajor1(), cymajor2(), cymajor3(), cymajor4(), cymajor5();
extern cymajor6(), cymajor7(), cymajor8(), cymajor9(), cymajora();
extern cymajorb(), cymajorc(), cymajord(), cymajore(), cymajorf();

extern cxmajor0();
extern cxmajor1(), cxmajor2(), cxmajor3(), cxmajor4(), cxmajor5();
extern cxmajor6(), cxmajor7(), cxmajor8(), cxmajor9(), cxmajora();
extern cxmajorb(), cxmajorc(), cxmajord(), cxmajore(), cxmajorf();

(*ymajtab[])() = {
	cymajor0,
        cymajor1,cymajor2,cymajor3,cymajor4,cymajor5,
        cymajor6,cymajor7,cymajor8,cymajor9,cymajora,
        cymajorb,cymajorc,cymajord,cymajore,cymajorf,
};

(*xmajtab[])() = {
	cxmajor0,
        cxmajor1,cxmajor2,cxmajor3,cxmajor4,cxmajor5,
        cxmajor6,cxmajor7,cxmajor8,cxmajor9,cxmajora,
        cxmajorb,cxmajorc,cxmajord,cxmajore,cxmajorf,
};


#define first_param 5*4
#define color first_param
#define x1 first_param+2
#define y1 first_param+4
#define x2 first_param+6
#define y2 first_param+8

        
extern line();


#define dccolor	4
extern outline_poly();
asm	{
outline_poly:
	movem.l	A2/A3/A5/D4/D5/D6/D7,-(A7)
	
	move.l	8*4(A7),A2			;fetch poly parameter
	move.l	poly_clipped_list(A2),A3	
	move.l	llpoint_next(A3),A5
	move.w	poly_pt_count(A2),-(A7)		;make counter on stack
	move.w	poly_color(A2),-(A7)		;push color parameter to line
	move.w	poly_type(A2),D0
	cmpi.w	#JUST_LINE,D0			;just_lines have 1 less points
	bne	zloop_outline
	subq.w	#1,2(A7)
	bra	zloop_outline

loop_outline:
	tst.w	llpoint_level(A3)
	bne.s	outl_nodraw
	move.w	llpoint_x(A3),D4
	move.w	llpoint_y(A3),D5
	move.w	llpoint_x(A5),D6
	move.w	llpoint_y(A5),D7
	bsr	drawcolr
outl_nodraw:
	move.l	A5,A3
	move.l	llpoint_next(A5),A5
zloop_outline:	subq.w #1,2(A7)
	bge	loop_outline
	
	addq #4,A7
	movem.l	(A7)+,A2/A3/A5/D4/D5/D6/D7
	rts

	;entry point to drawcolr for a single line
line:	
	movem.l d4/d5/d6/d7,-(sp)
	move.w	color(sp),d0
	move.w x1(sp),d4
	move.w y1(sp),d5
	move.w x2(sp),d6
	move.w y2(sp),d7
	move.w	d0,-(sp)	;put color parameter right place on stack
	jsr drawcolr
	addq	#2,sp
	movem.l	(sp)+,d4/d5/d6/d7
	rts

drawcolr:        cmp.w   d6,d4   ; Swap axes if x2>x1
        bls.s   cswapx21
        exg     d4,d6
        exg     d5,d7

cswapx21:        move.w  d6,d2   ; Find absolute diff of x2-x1 and y2-y1
        sub.w   d4,d2
        move.w  d7,d3
        sub.w   d5,d3
        move.w  #160,d6    ; Vertical byte offset to next scanline
        cmp.w   d7,d5   ; Gradient up or down?
        bls.s   cgodown
        neg.w   d6      ; If up, negate values and Y abs
        neg.w   d3
        

/* Find the address, and sub-bit of the first pixel in line*/
cgodown: lsl.w   #5,d5   ; Multiply Y by 32
        move.l  cscreen(a4),a0
        lea   0(a0,d5.W),a0
        lsl.w   #2,d5   ; Multiply Y by 4, to give y*128
        lea   0(a0,d5.W),a0   ; Now Y*160 has been added
        move.w  d4,d0   ; x div 8*4
        lsr.w   #1,d0
        and.w   #255-7,d0       ; Lose lsb and msb
/* Now a0 has x offset added to give true byte position on screen*/
        lea   0(a0,d0.W),a0   ; plane 0 address

        moveq   #0,d0   ; Set the first pixel in d0
        not.b   d4
        and.b   #15,d4
        bset    d4,d0


/*       tst.w   d3
*       beq     colrhori
*       tst.w   d2
*       beq     colrvert
*/


        move.w  dccolor(a7),d4   ; Colour
        asl.w   #2,d4           ; LongWord indexing


        cmp.w   d3,d2   ; Which axis is major?
/*       beq     colrdiag        ; Special Case DIAGONAL LINE*/
        bhi.s   cxmajor


/* Consult jump-table to work out which LineDraw routine to access.*/
/* There are 15 in all.. one for each Colour available!*/

cymajor: lea ymajtab(a4),a1
	 move.l 0(a1,d4.W),a1
        jmp     (a1)


cxmajor: lea xmajtab(a4),a1
	move.l 0(a1,d4.W),a1
        jmp     (a1)


cymajor0:
	not.w d0
        move.w  d3,d1   ; The Y axis is major
	asr.w	#1,d1
        move.w  d3,d7
cyline0: and.w    d0,(a0)
	and.w	d0,2(a0)
	and.w   d0,4(a0)
	and.w	d0,6(a0)
        sub.w   d2,d1
        bls.s   cxstepn0
cdoystp0:        lea   0(a0,d6.w),a0   ; y=y+1
        dbf    d7,cyline0
retdraw: rts

cxstepn0:        add.w   d3,d1   ; add to the error term.
        ror.w   #1,d0   ; x=x+1
        bcs.s   cdoystp0
        addq.l  #8,a0   ; Optimise this, to lose some add instructions (ie: combine!)
        lea   0(a0,d6.w),a0   ; Repeat a bit of code here stead of branch
        dbf    d7,cyline0
        rts

        

cxmajor0:
	not.w	d0        
	move.w  d2,d1   ; Step along the X axis...
	asr.w	#1,d1
        move.w  d2,d7
cxline0: and.w    d0,(a0) ; set pixel
	and.w	d0,2(a0)
	and.w	d0,4(a0)
	and.w	d0,6(a0)
        sub.w   d3,d1
        bls.s   cystpn0
        ror.w   #1,d0   ; x=x+1
        bcs.s   cror2fr0
        addq.l  #8,a0
cror2fr0:        dbf    d7,cxline0 
        rts
cystpn0: add.w   d2,d1   ; time to alter the y coord
        lea   0(a0,d6.w),a0
        ror.w   #1,d0   ; stead of rpt, here is xstep1 onwards
        bcs.s   cror2fr0
        addq.l  #8,a0
        dbf    d7,cxline0
        rts
       


cymajor1:        move.w  d3,d1   ; The Y axis is major
	asr.w	#1,d1
        move.w  d3,d7

cyline1:
	not.w	d0
	and.w	d0,2(a0)
	and.w	d0,4(a0)
	and.w	d0,6(a0)
	not.w   d0
	or.w    d0,0(a0)
        sub.w   d2,d1
        bls.s   cxstepn1
cdoystp1:        lea 0(a0,d6),a0   ; y=y+1
        dbf    d7,cyline1
        rts

cxstepn1:        add.w   d3,d1   ; add to the error term.
        ror.w   #1,d0   ; x=x+1
        bcc.s   cdoystp1
        addq.l  #8,a0   ; Optimise this, to lose some add instructions (ie: combine!)
        lea 0(a0,d6),a0   ; Repeat a bit of code here stead of branch
        dbf    d7,cyline1
        rts

        

cxmajor1:        move.w  d2,d1   ; Step along the X axis...
	asr.w	#1,d1
        move.w  d2,d7

cxline1:
	not.w	d0
	and.w	d0,2(a0)
	and.w	d0,4(a0)
	and.w	d0,6(a0)
	not.w	d0
	or.w    d0,0(a0)
        sub.w   d3,d1
        bls.s   cystpn1
        ror.w   #1,d0   ; x=x+1
        bcc.s   cror2fr1
        addq.l  #8,a0
cror2fr1:        dbf    d7,cxline1
        rts

cystpn1: add.w   d2,d1   ; time to alter the y coord
        lea 	0(a0,d6.w),a0
        ror.w   #1,d0   ; stead of rpt, here is xstep1 onwards
        bcc.s   cror2fr1
        addq.l  #8,a0
        dbf    d7,cxline1
        rts



        

cymajor2:        move.w  d3,d1   ; The Y axis is major
	asr.w	#1,d1
        move.w  d3,d7

cyline2:
	not.w	d0
	and.w	d0,(a0)
	and.w	d0,4(a0)
	and.w	d0,6(a0)
	not.w   d0
	or.w    d0,2(a0)
        sub.w   d2,d1
        bls.s   cxstepn2
cdoystp2:        lea 0(a0,d6),a0   ; y=y+1
        dbf    d7,cyline2
        rts

cxstepn2:        add.w   d3,d1   ; add to the error term.
        ror.w   #1,d0   ; x=x+1
        bcc.s   cdoystp2
        addq.l  #8,a0   ; Optimise this, to lose some add instructions (ie: combine!)
        lea 0(a0,d6),a0   ; Repeat a bit of code here stead of branch
        dbf    d7,cyline2
        rts

        

cxmajor2:        move.w  d2,d1   ; Step along the X axis...
	asr.w	#1,d1
        move.w  d2,d7

cxline2:
	not.w	d0
	and.w	d0,(a0)
	and.w	d0,4(a0)
	and.w	d0,6(a0)
	not.w	d0
	or.w    d0,2(a0)
        sub.w   d3,d1
        bls.s   cystpn2
        ror.w   #1,d0   ; x=x+1
        bcc.s   cror2fr2
        addq.l  #8,a0
cror2fr2:        dbf    d7,cxline2
        rts

cystpn2: add.w   d2,d1   ; time to alter the y coord
        lea 	0(a0,d6.w),a0
        ror.w   #1,d0   ; stead of rpt, here is xstep1 onwards
        bcc.s   cror2fr2
        addq.l  #8,a0
        dbf    d7,cxline2
        rts



        

cymajor3:        move.w  d3,d1   ; The Y axis is major
	asr.w	#1,d1
        move.w  d3,d7
cyline3: or.w    d0,(a0)
        or.w    d0,2(a0)
	not.w	d0
	and.w	d0,4(a0)
	and.w   d0,6(a0)
	not.w	d0
        sub.w   d2,d1
        bls.s   cxstepn3
cdoystp3:        lea 	0(a0,d6.w),a0   ; y=y+1
        dbf    d7,cyline3
        rts

cxstepn3:        add.w   d3,d1   ; add to the error term.
        ror.w   #1,d0   ; x=x+1
        bcc.s   cdoystp3
        addq.l  #8,a0   ; Optimise this, to lose some add instructions (ie: combine!)
        lea 	0(a0,d6.w),a0   ; Repeat a bit of code here stead of branch
        dbf    d7,cyline3
        rts
        
cxmajor3:        move.w  d2,d1   ; Step along the X axis...
	asr.w	#1,d1
        move.w  d2,d7
cxline3: or.w    d0,(a0) ; set pixel
        or.w    d0,2(a0)
	not.w	d0
	and.w	d0,4(a0)
	and.w   d0,6(a0)
	not.w	d0
        sub.w   d3,d1
        bls.s   cystpn3
        ror.w   #1,d0   ; x=x+1
        bcc.s   cror2fr3
        addq.l  #8,a0
cror2fr3:        dbf    d7,cxline3
        rts
cystpn3: add.w   d2,d1   ; time to alter the y coord
        lea 	0(a0,d6.w),a0
        ror.w   #1,d0   ; stead of rpt, here is xstep1 onwards
        bcc.s   cror2fr3
        addq.l  #8,a0
        dbf    d7,cxline3
        rts

        
cymajor4:        move.w  d3,d1   ; The Y axis is major
	asr.w	#1,d1
        move.w  d3,d7

cyline4: or.w    d0,4(a0)
	not.w	d0
	and.w	d0,(a0)
	and.w	d0,2(a0)
	and.w	d0,6(a0)
	not.w	d0
        sub.w   d2,d1
        bls.s   cxstepn4
cdoystp4:        lea 	0(a0,d6.w),a0   ; y=y+1
        dbf    d7,cyline4
        rts

cxstepn4:        add.w   d3,d1   ; add to the error term.
        ror.w   #1,d0   ; x=x+1
        bcc.s   cdoystp4
        addq.l  #8,a0   ; Optimise this, to lose some add instructions (ie: combine!)
        lea 	0(a0,d6.w),a0   ; Repeat a bit of code here stead of branch
        dbf    d7,cyline4
        rts
        
cxmajor4:        move.w  d2,d1   ; Step along the X axis...
	asr.w	#1,d1
        move.w  d2,d7

cxline4: or.w    d0,4(a0) ; set pixel
	not.w	d0
	and.w	d0,(a0)
	and.w	d0,2(a0)
	and.w	d0,6(a0)
	not.w	d0
        sub.w   d3,d1
        bls.s   cystpn4
        ror.w   #1,d0   ; x=x+1
        bcc.s   cror2fr4
        addq.l  #8,a0
cror2fr4:        dbf    d7,cxline4
        rts
cystpn4: add.w   d2,d1   ; time to alter the y coord
        lea 	0(a0,d6.w),a0
        ror.w   #1,d0   ; stead of rpt, here is xstep1 onwards
        bcc.s   cror2fr4
        addq.l  #8,a0
        dbf    d7,cxline4
        rts

        
cymajor5:        move.w  d3,d1   ; The Y axis is major
	asr.w	#1,d1
        move.w  d3,d7
cyline5: or.w    d0,(a0)
        or.w    d0,4(a0)
	not.w	d0
	and.w	d0,2(a0)
	and.w	d0,6(a0)
	not.w	d0
        sub.w   d2,d1
        bls.s   cxstepn5
cdoystp5:        lea 	0(a0,d6.w),a0   ; y=y+1
        dbf    d7,cyline5
        rts

cxstepn5:        add.w   d3,d1   ; add to the error term.
        ror.w   #1,d0   ; x=x+1
        bcc.s   cdoystp5
        addq.l  #8,a0   ; Optimise this, to lose some add instructions (ie: combine!)
        lea 	0(a0,d6.w),a0   ; Repeat a bit of code here stead of branch
        dbf    d7,cyline5
        rts
        
cxmajor5:        move.w  d2,d1   ; Step along the X axis...
	asr.w	#1,d1
        move.w  d2,d7
cxline5: or.w    d0,(a0) ; set pixel
        or.w    d0,4(a0)
	not.w	d0
	and.w	d0,2(a0)
	and.w	d0,6(a0)
	not.w	d0
        sub.w   d3,d1
        bls.s   cystpn5
        ror.w   #1,d0   ; x=x+1
        bcc.s   cror2fr5
        addq.l  #8,a0
cror2fr5:        dbf    d7,cxline5
        rts
cystpn5: add.w   d2,d1   ; time to alter the y coord
        lea 	0(a0,d6.w),a0
        ror.w   #1,d0   ; stead of rpt, here is xstep1 onwards
        bcc.s   cror2fr5
        addq.l  #8,a0
        dbf    d7,cxline5
        rts

        
cymajor6:        move.w  d3,d1   ; The Y axis is major
	asr.w	#1,d1
        move.w  d3,d7

cyline6: or.w    d0,2(a0)
        or.w    d0,4(a0)
	not.w	d0
	and.w	d0,(a0)
	and.w	d0,6(a0)
	not.w	d0
        sub.w   d2,d1
        bls.s   cxstepn6
cdoystp6:        lea 	0(a0,d6.w),a0   ; y=y+1
        dbf    d7,cyline6
        rts

cxstepn6:        add.w   d3,d1   ; add to the error term.
        ror.w   #1,d0   ; x=x+1
        bcc.s   cdoystp6
        addq.l  #8,a0   ; Optimise this, to lose some add instructions (ie: combine!)
        lea 	0(a0,d6.w),a0   ; Repeat a bit of code here stead of branch
        dbf    d7,cyline6
        rts
        
cxmajor6:        move.w  d2,d1   ; Step along the X axis...
	asr.w	#1,d1
        move.w  d2,d7

cxline6: or.w    d0,2(a0) ; set pixel
        or.w    d0,4(a0)
	not.w	d0
	and.w	d0,(a0)
	and.w	d0,6(a0)
	not.w	d0
        sub.w   d3,d1
        bls.s   cystpn6
        ror.w   #1,d0   ; x=x+1
        bcc.s   cror2fr6
        addq.l  #8,a0
cror2fr6:        dbf    d7,cxline6
        rts
cystpn6: add.w   d2,d1   ; time to alter the y coord
        lea 	0(a0,d6.w),a0
        ror.w   #1,d0   ; stead of rpt, here is xstep1 onwards
        bcc.s   cror2fr6
        addq.l  #8,a0
        dbf    d7,cxline6
        rts

        
cymajor7:        move.w  d3,d1   ; The Y axis is major
	asr.w	#1,d1
        move.w  d3,d7
cyline7: or.w    d0,(a0)
        or.w    d0,2(a0)
        or.w    d0,4(a0)
	not.w	d0
	and.w	d0,6(a0)
	not.w	d0
        sub.w   d2,d1
        bls.s   cxstepn7
cdoystp7:        lea 	0(a0,d6.w),a0   ; y=y+1
        dbf    d7,cyline7
        rts

cxstepn7:        add.w   d3,d1   ; add to the error term.
        ror.w   #1,d0   ; x=x+1
        bcc.s   cdoystp7
        addq.l  #8,a0   ; Optimise this, to lose some add instructions (ie: combine!)
        lea	0(a0,d6.w),a0   ; Repeat a bit of code here stead of branch
        dbf    d7,cyline7
        rts
        
cxmajor7:        move.w  d2,d1   ; Step along the X axis...
	asr.w	#1,d1
        move.w  d2,d7
cxline7: or.w    d0,(a0) ; set pixel
        or.w    d0,2(a0)
        or.w    d0,4(a0)
	not.w	d0
	and.w	d0,6(a0)
	not.w	d0
        sub.w   d3,d1
        bls.s   cystpn7
        ror.w   #1,d0   ; x=x+1
        bcc.s   cror2fr7
        addq.l  #8,a0
cror2fr7:        dbf    d7,cxline7
        rts
cystpn7: add.w   d2,d1   ; time to alter the y coord
        lea	0(a0,d6.w),a0
        ror.w   #1,d0   ; stead of rpt, here is xstep1 onwards
        bcc.s   cror2fr7
        addq.l  #8,a0
        dbf    d7,cxline7
        rts

        
cymajor8:        move.w  d3,d1   ; The Y axis is major
	asr.w	#1,d1
        move.w  d3,d7

cyline8: or.w    d0,6(a0)
	not.w	d0
	and.w	d0,(a0)
	and.w	d0,2(a0)
	and.w	d0,4(a0)
	not.w	d0
        sub.w   d2,d1
        bls.s   cxstepn8
cdoystp8:        lea	0(a0,d6.w),a0   ; y=y+1
        dbf    d7,cyline8
        rts

cxstepn8:        add.w   d3,d1   ; add to the error term.
        ror.w   #1,d0   ; x=x+1
        bcc.s   cdoystp8
        addq.l  #8,a0   ; Optimise this, to lose some add instructions (ie: combine!)
        lea	0(a0,d6.w),a0   ; Repeat a bit of code here stead of branch
        dbf    d7,cyline8
        rts
        
cxmajor8:        move.w  d2,d1   ; Step along the X axis...
	asr.w	#1,d1
        move.w  d2,d7

cxline8: or.w    d0,6(a0) ; set pixel
	not.w	d0
	and.w	d0,(a0)
	and.w	d0,2(a0)
	and.w	d0,4(a0)
	not.w	d0
        sub.w   d3,d1
        bls.s   cystpn8
        ror.w   #1,d0   ; x=x+1
        bcc.s   cror2fr8
        addq.l  #8,a0
cror2fr8:        dbf    d7,cxline8
        rts
cystpn8: add.w   d2,d1   ; time to alter the y coord
        lea	0(a0,d6.w),a0
        ror.w   #1,d0   ; stead of rpt, here is xstep1 onwards
        bcc.s   cror2fr8
        addq.l  #8,a0
        dbf    d7,cxline8
        rts

cymajor9:        move.w  d3,d1   ; The Y axis is major
	asr.w	#1,d1
        move.w  d3,d7
cyline9: or.w    d0,(a0)
        or.w    d0,6(a0)
	not.w	d0
	and.w	d0,2(a0)
	and.w	d0,4(a0)
	not.w	d0
        sub.w   d2,d1
        bls.s   cxstepn9
cdoystp9:        lea	0(a0,d6.w),a0   ; y=y+1
        dbf    d7,cyline9
        rts

cxstepn9:        add.w   d3,d1   ; add to the error term.
        ror.w   #1,d0   ; x=x+1
        bcc.s   cdoystp9
        addq.l  #8,a0   ; Optimise this, to lose some add instructions (ie: combine!)
        lea	0(a0,d6.w),a0   ; Repeat a bit of code here stead of branch
        dbf    d7,cyline9
        rts
        
cxmajor9:        move.w  d2,d1   ; Step along the X axis...
	asr.w	#1,d1
        move.w  d2,d7
cxline9: or.w    d0,(a0) ; set pixel
        or.w    d0,6(a0)
	not.w	d0
	and.w	d0,2(a0)
	and.w	d0,4(a0)
	not.w	d0
        sub.w   d3,d1
        bls.s   cystpn9
        ror.w   #1,d0   ; x=x+1
        bcc.s   cror2fr9
        addq.l  #8,a0
cror2fr9:        dbf    d7,cxline9
        rts
cystpn9: add.w   d2,d1   ; time to alter the y coord
        lea	0(a0,d6.w),a0
        ror.w   #1,d0   ; stead of rpt, here is xstep1 onwards
        bcc.s   cror2fr9
        addq.l  #8,a0
        dbf    d7,cxline9
        rts

cymajora:        move.w  d3,d1   ; The Y axis is major
	asr.w	#1,d1
        move.w  d3,d7

cylinea: or.w    d0,2(a0)
        or.w    d0,6(a0)
	not.w	d0
	and.w	d0,(a0)
	and.w	d0,4(a0)
	not.w	d0
        sub.w   d2,d1
        bls.s   cxstepna
cdoystpa:        lea	0(a0,d6.w),a0   ; y=y+1
        dbf    d7,cylinea
        rts

cxstepna:        add.w   d3,d1   ; add to the error term.
        ror.w   #1,d0   ; x=x+1
        bcc.s   cdoystpa
        addq.l  #8,a0   ; Optimise this, to lose some add instructions (ie: combine!)
        lea	0(a0,d6.w),a0   ; Repeat a bit of code here stead of branch
        dbf    d7,cylinea
        rts
        
cxmajora:        move.w  d2,d1   ; Step along the X axis...
	asr.w	#1,d1
        move.w  d2,d7

cxlinea: or.w    d0,2(a0) ; set pixel
        or.w    d0,6(a0)
	not.w	d0
	and.w	d0,(a0)
	and.w	d0,4(a0)
	not.w	d0
        sub.w   d3,d1
        bls.s   cystpna
        ror.w   #1,d0   ; x=x+1
        bcc.s   cror2fra
        addq.l  #8,a0
cror2fra:        dbf    d7,cxlinea
        rts
cystpna: add.w   d2,d1   ; time to alter the y coord
        lea	0(a0,d6.w),a0
        ror.w   #1,d0   ; stead of rpt, here is xstep1 onwards
        bcc.s   cror2fra
        addq.l  #8,a0
        dbf    d7,cxlinea
        rts
 
cymajorb:        move.w  d3,d1   ; The Y axis is major
	asr.w	#1,d1
        move.w  d3,d7
cylineb: or.w    d0,(a0)
        or.w    d0,2(a0)
        or.w    d0,6(a0)
	not.w	d0
	and.w	d0,4(a0)
	not.w	d0
        sub.w   d2,d1
        bls.s   cxstepnb
cdoystpb:        lea	0(a0,d6.w),a0   ; y=y+1
        dbf    d7,cylineb
        rts

cxstepnb:        add.w   d3,d1   ; add to the error term.
        ror.w   #1,d0   ; x=x+1
        bcc.s   cdoystpb
        addq.l  #8,a0   ; Optimise this, to lose some add instructions (ie: combine!)
        lea	0(a0,d6.w),a0   ; Repeat a bit of code here stead of branch
        dbf    d7,cylineb
        rts
        
cxmajorb:        move.w  d2,d1   ; Step along the X axis...
	asr.w	#1,d1
        move.w  d2,d7
cxlineb: or.w    d0,(a0) ; set pixel
        or.w    d0,2(a0)
        or.w    d0,6(a0)
	not.w	d0
	and.w	d0,4(a0)
	not.w	d0
        sub.w   d3,d1
        bls.s   cystpnb
        ror.w   #1,d0   ; x=x+1
        bcc.s   cror2frb
        addq.l  #8,a0
cror2frb:        dbf    d7,cxlineb
        rts
cystpnb: add.w   d2,d1   ; time to alter the y coord
        lea	0(a0,d6.w),a0
        ror.w   #1,d0   ; stead of rpt, here is xstep1 onwards
        bcc.s   cror2frb
        addq.l  #8,a0
        dbf    d7,cxlineb
        rts

cymajorc:        move.w  d3,d1   ; The Y axis is major
	asr.w	#1,d1
        move.w  d3,d7

cylinec: or.w    d0,4(a0)
        or.w    d0,6(a0)
	not.w	d0
	and.w	d0,(a0)
	and.w	d0,2(a0)
	not.w	d0
        sub.w   d2,d1
        bls.s   cxstepnc
cdoystpc:        lea	0(a0,d6.w),a0   ; y=y+1
        dbf    d7,cylinec
        rts

cxstepnc:        add.w   d3,d1   ; add to the error term.
        ror.w   #1,d0   ; x=x+1
        bcc.s   cdoystpc
        addq.l  #8,a0   ; Optimise this, to lose some add instructions (ie: combine!)
        lea	0(a0,d6.w),a0   ; Repeat a bit of code here stead of branch
        dbf    d7,cylinec
        rts
        
cxmajorc:        move.w  d2,d1   ; Step along the X axis...
	asr.w	#1,d1
        move.w  d2,d7

cxlinec: or.w    d0,4(a0) ; set pixel
        or.w    d0,6(a0)
	not.w	d0
	and.w	d0,(a0)
	and.w	d0,2(a0)
	not.w	d0
        sub.w   d3,d1
        bls.s   cystpnc
        ror.w   #1,d0   ; x=x+1
        bcc.s   cror2frc
        addq.l  #8,a0
cror2frc:        dbf    d7,cxlinec
        rts
cystpnc: add.w   d2,d1   ; time to alter the y coord
        lea	0(a0,d6.w),a0
        ror.w   #1,d0   ; stead of rpt, here is xstep1 onwards
        bcc.s   cror2frc
        addq.l  #8,a0
        dbf    d7,cxlinec
        rts

cymajord:        move.w  d3,d1   ; The Y axis is major
	asr.w	#1,d1
        move.w  d3,d7
cylined: or.w    d0,(a0)
        or.w    d0,4(a0)
        or.w    d0,6(a0)
	not.w	d0
	and.w	d0,2(a0)
	not.w	d0
        sub.w   d2,d1
        bls.s   cxstepnd
cdoystpd:        lea	0(a0,d6.w),a0   ; y=y+1
        dbf    d7,cylined
        rts

cxstepnd:        add.w   d3,d1   ; add to the error term.
        ror.w   #1,d0   ; x=x+1
        bcc.s   cdoystpd
        addq.l  #8,a0   ; Optimise this, to lose some add instructions (ie: combine!)
        lea	0(a0,d6.w),a0   ; Repeat a bit of code here stead of branch
        dbf    d7,cylined
        rts
        
cxmajord:        move.w  d2,d1   ; Step along the X axis...
	asr.w	#1,d1
        move.w  d2,d7
cxlined: or.w    d0,(a0) ; set pixel
        or.w    d0,4(a0)
        or.w    d0,6(a0)
	not.w	d0
	and.w	d0,2(a0)
	not.w	d0
        sub.w   d3,d1
        bls.s   cystpnd
        ror.w   #1,d0   ; x=x+1
        bcc.s   cror2frd
        addq.l  #8,a0
cror2frd:        dbf    d7,cxlined
        rts
cystpnd: add.w   d2,d1   ; time to alter the y coord
        lea	0(a0,d6.w),a0
        ror.w   #1,d0   ; stead of rpt, here is xstep1 onwards
        bcc.s   cror2frd
        addq.l  #8,a0
        dbf    d7,cxlined
        rts

cymajore:        move.w  d3,d1   ; The Y axis is major
	asr.w	#1,d1
        move.w  d3,d7

cylinee: or.w    d0,2(a0)
        or.w    d0,4(a0)
        or.w    d0,6(a0)
	not.w	d0
	and.w	d0,(a0)
	not.w	d0
        sub.w   d2,d1
        bls.s   cxstepne
cdoystpe:        lea	0(a0,d6.w),a0   ; y=y+1
        dbf    d7,cylinee
        rts

cxstepne:        add.w   d3,d1   ; add to the error term.
        ror.w   #1,d0   ; x=x+1
        bcc.s   cdoystpe
        addq.l  #8,a0   ; Optimise this, to lose some add instructions (ie: combine!)
        lea	0(a0,d6.w),a0   ; Repeat a bit of code here stead of branch
        dbf    d7,cylinee
        rts
        
cxmajore:        move.w  d2,d1   ; Step along the X axis...
	asr.w	#1,d1
        move.w  d2,d7

cxlinee: or.w    d0,2(a0) ; set pixel
        or.w    d0,4(a0)
        or.w    d0,6(a0)
	not.w	d0
	and.w	d0,(a0)
	not.w	d0
        sub.w   d3,d1
        bls.s   cystpne
        ror.w   #1,d0   ; x=x+1
        bcc.s   cror2fre
        addq.l  #8,a0
cror2fre:        dbf    d7,cxlinee
        rts
cystpne: add.w   d2,d1   ; time to alter the y coord
        lea	0(a0,d6.w),a0
        ror.w   #1,d0   ; stead of rpt, here is xstep1 onwards
        bcc.s   cror2fre
        addq.l  #8,a0
        dbf    d7,cxlinee
        rts

cymajorf:        move.w  d3,d1   ; The Y axis is major
	asr.w	#1,d1
        move.w  d3,d7
cylinef: or.w    d0,(a0)
        or.w    d0,2(a0)
        or.w    d0,4(a0)
        or.w    d0,6(a0)
        sub.w   d2,d1
        bls.s   cxstepnf
cdoystpf:        lea	0(a0,d6.w),a0   ; y=y+1
        dbf    d7,cylinef
        rts

cxstepnf:        add.w   d3,d1   ; add to the error term.
        ror.w   #1,d0   ; x=x+1
        bcc.s   cdoystpf
        addq.l  #8,a0   ; Optimise this, to lose some add instructions (ie: combine!)
        lea	0(a0,d6.w),a0   ; Repeat a bit of code here stead of branch
        dbf    d7,cylinef
        rts
        
cxmajorf:        move.w  d2,d1   ; Step along the X axis...
	asr.w	#1,d1
        move.w  d2,d7
cxlinef: or.w    d0,(a0) ; set pixel
        or.w    d0,2(a0)
        or.w    d0,4(a0)
        or.w    d0,6(a0)
        sub.w   d3,d1
        bls.s   cystpnf
        ror.w   #1,d0   ; x=x+1
        bcc.s   cror2frf
        addq.l  #8,a0
cror2frf:        dbf    d7,cxlinef
        rts
cystpnf: add.w   d2,d1   ; time to alter the y coord
        lea	0(a0,d6.w),a0
        ror.w   #1,d0   ; stead of rpt, here is xstep1 onwards
        bcc.s   cror2frf
        addq.l  #8,a0
        dbf    d7,cxlinef
        rts
}




