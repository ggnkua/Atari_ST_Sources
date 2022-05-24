'Pseudo C' and 680x0 versions included...

/*

A routine(s!) to clip a line within a rectangular region.  It does so using the ordinary, garden similar triangles method, but how it determines when to clip it is when things get fast!  It is very simple, and that is why it is faster than any other method in existence.  We've seen the lot: normalised vector clipping, region clipping, the well-worn bit signal plus a host of others.
	Realised by Martin Griffiths and Jose Commins
	This implementation V1.0 By Jose Commins
	. Part of a computer programming/research team:
	. Ben Griffin / Martin Griffiths / Jose Commins.
	(in no particular order!)
We specialise in programming way different from others, and way faster!
As chip designers bust their bacon to give us optimum speed, so do we, as not to make their work worthless.
This code/technique is entirely and wholly in the public domain.

'C' code written 'universal' for clarity and speed where possible, so other languages can benefit as well.

How it works:
  Simple really!  It sorts the input line coordinates according to the axis to clip to - e.g. before clipping to Y, we sort the line according to its Y components.  Then, very fast boundary checks can be performed, resulting in 'instant' determination of an invisible line (outside the Y axis), fully visible (inside the Y axis) or one that needs to be clipped.  This is due to the fact that, after sorting, we know that if the bottom coordinate of the line is above the clip window, then it is totally invisible.  If it is below the bottom of the clip widow, it needs clipping.  If neither of these, therefore, it is totally visible!  We also do the 'opposite' checks using the topmost line coordinate (if below clip window, then invisible...  etc).
The same applies for X.
There's an added advantage - the clipper has built-in roundoff since it always takes the major extent of the line when clipping (bonus of sorting!).  This means that it can be applied to polygon clipping without need of a math adjust (in fact, I have already applied this technique to my Z-clipper).  I will post up the Z-clipper and (as yet incomplete) polygon clipper as soon as we sort out our texture mapping ;-).
	Still, if you think you have/know of a faster method, or simply to express a view or two, you can contact us via the following Internet address:
oranges@cosmos-uk.org

And now, for your discerning pleasure, both the C and 680x0 assembler versions!

*/

/* The 'substitute' for a processor EXG instruction (ugh)...   Swaps two values, a and b*/
#define swap_c(a,b) a^=b; b^=a; a^=b;

/* The line clipper itself.  Takes in the lines' coordinates in x1,y1,x2,y2 and returns the <clipped> coordinates in nx1,ny1,nx2,ny2 : this is so you can compare the results.  The clipper uses variables CLIPTOP, CLIPBOTTOM, CLIPLEFT and CLIPRIGHT as the view window's extents.  Returns FALSE if line is invisible, or TRUE if visible.
You can gain more accuracy by using the old coordinates as the clipping scalers; that's if you have registers to throw away (as in RISC chips) - this version compiles entirely register-based on the 680x0 series of processors, in other words, quick!
*WARNING*  I have found a 'hiccup' in most 68000 C compilers (may apply to others too): where the variables are WORD (16-bit) the compiler forgets that we have a 32-bit value after the mutiply, and performs a 16-to-32 bit extend, thus erasing our needed top 16 bits (arggh!).  This would happen on something like '(a*b)/c' - a,b,c being shorts (16-bit).  An example...
The proper way...
	MULS	D0,D1	- Mutliply D1 by D0, and store 32 bit result in D1.
	DIVS	D2,D1	- Divide 32 bits in D1 by D2.
What it compiles to with word variables...
	MULS	D0,D1
	EXT.L	D1		- Extend the sign of D1 over top 16 bits of D1.
	DIVS	D2,D1
That's why in this version, for safety's sake, it uses ints (LONG 32 bits), although a bit slower, free of the problem.  If you compile to another processor and the above happens, you could always remove the offending line in disassembly, otherwise, if you want the speed with 680x0's, use the assembly version, although it is different in its parameter passing.

Remember to declare it as a function prototype if you need one.  Also, if you're thinking of commenting about lack of structures/etc, then can it.  This has been optimised for a 68000 compiler, avoiding the use of temporary memory/stack for the variables.  If you want, you can trim the start and end assignments; the ones in use, as I said, are for comparison purposes before & after clipping.
*/

/* Global declarations.  Note these are SHORT 16-BIT variables.  Heck, the code's free for alteration, so declare it any way you want!  I have these as global; they compile faster, but season it as you wish! */
short clipleft=110;
short clipright=150;
short clipbottom=120;
short cliptop=80;

short x1;
short y1;
short x2;
short y2;
short nx1;
short ny1;
short nx2;
short ny2;

short line_clipper(void)
{

register int	rx1,ry1,rx2,ry2,temp;

	rx1=x1;
	ry1=y1;
	rx2=x2;
	ry2=y2;

/* Check greater Y extent and sort accordingly... */	
	if (ry1>ry2) {
		swap_c(ry1,ry2)
		swap_c(rx1,rx2)
		}

/* See if lowest point in line is off top, reject if so (invisible) */
	if (ry2<cliptop)
		return(FALSE);
/* See if highest point in line is off bottom, reject if so (invisible) */
	if (ry1>clipbottom)
		return(FALSE);
		
/* See if lowest point of line off bottom, if so, clip it */
	if (ry2>clipbottom) {
		rx2+=((rx1-rx2)*(clipbottom-ry2))/(ry1-ry2);	
		ry2=clipbottom;
		}
/* See if highest point of line is off top, if so, clip it */
	if (ry1<cliptop) {
		rx1+=((rx2-rx1)*(cliptop-ry1))/(ry2-ry1);
		ry1=cliptop;
		}
/* -> Else line is totally visible on the Y */

/* Now do the same for X... */
	if (rx1>rx2) {
		swap_c(rx1,rx2)
		swap_c(ry1,ry2)
		}

	if (rx2<clipleft)
		return(FALSE);
	if (rx1>clipright)
		return(FALSE);
		
	if (rx1<clipleft) {
		ry1+=((ry2-ry1)*(clipleft-rx1))/(rx2-rx1);
		rx1=clipleft;
		}	
	if (rx2>clipright) {
		ry2+=((ry1-ry2)*(clipright-rx2))/(rx1-rx2);
		rx2=clipright;
		}

	nx1=rx1;
	nx2=rx2;
	ny1=ry1;
	ny2=ry2;

		return(TRUE);
}


;
; Now the 680x0 assembler version.  A BSR to CLIPLINE to do the clipping.
;
; Entered with X1,Y1,X2,Y2 as WORDS (16-bit) in D0-D3.
; Clipped line returned in same registers.
; Returns with a flag in D4.  If D4 is negative, line is totally invisible.
; Trashes D4-D7 and A1.
;
; Clip window is defined as WORDS in this sequence:
; CLIP LEFT,CLIP RIGHT,CLIP BOTTOM,CLIP TOP.
; Don't organise them any other way or it will use the wrong values!
;

; A second LINEOUT for speed (short branches).
lineout2:	moveq	#-1,D4		; Line invisible.
		rts
clipline:
		lea		clipleft(PC),A1

		cmp.w	D0,D2		; Sort 'em according to X.
		bge.s		lineok1
		exg		D0,D2
		exg		D1,D3
lineok1:
		cmp.w	2(A1),D0		; Left edge off clip right?
		bgt.s		lineout2
		cmp.w	(A1),D2
		blt.s		lineout2		; Right edge off clip left?

		cmp.w	(A1),D0		; Left edge off left?
		bge.s		noutl1
		move.w	D3,D4
		sub.w	D1,D4		; Y2-Y1
		move.w	(A1),D5		; Left side.
		sub.w	D0,D5		; Xt-X1
		muls		D5,D4		; (Y2-Y1)*(Xt-X1)
		move.w	D2,D5
		sub.w	D0,D5		; X2-X1
		divs		D5,D4		; DY
		add.w	D4,D1		; New Y1.
		move.w	(A1),D0		; X1=Left edge.

noutl1: 	cmp.w	2(A1),D2		; Right edge off right?
		ble.s		noutr1

		move.w	D1,D4
		sub.w	D3,D4		; Y1-Y2
		move.w	2(A1),D5		; Right side.
		sub.w	D2,D5		; Xt-X2
		muls		D5,D4		; (Y1-Y2)*(Xt-X2)
		move.w	D0,D5
		sub.w	D2,D5		; X1-X2
		divs		D5,D4		; DY
		add.w	D4,D3		; New Y2.
		move.w	2(A1),D2		; X2=Right edge.

noutr1: 	cmp.w	D1,D3		; Sort 'em according to Y.
		bge.s		lineok2
		exg		D1,D3
		exg		D0,D2
lineok2:
		cmp.w	4(A1),D1		; Top of line off bottom?
		bgt.s		lineout
		cmp.w	6(A1),D3
		blt.s		lineout		; Bottom of line off top?

		cmp.w	4(A1),D3		; Bottom of line off bottom?
		ble.s		noutb1

		move.w	D0,D4
		sub.w	D2,D4		; X1-X2
		move.w	4(A1),D5		; Bottom side.
		sub.w	D3,D5		; Yt-Y2
		muls		D5,D4		; (X1-X2)*(Yt-Y2)
		move.w	D1,D5
		sub.w	D3,D5		; Y1-Y2
		divs		D5,D4		; Dx
		add.w	D4,D2		; New X2.
		move.w	4(A1),D3		; Y2=Bottom edge.

noutb1: 	cmp.w	6(A1),D1		; Top of line off top?
		bge.s		noutt1

		move.w	D2,D4
		sub.w	D0,D4		; X2-X1
		move.w	6(A1),D5		; Top side.
		sub.w	D1,D5		; Yt-Y1
		muls		D5,D4		; (X2-X1)*(Yt-Y1)
		move.w	D3,D5
		sub.w	D1,D5		; Y2-Y1
		divs		D5,D4		; Dx
		add.w	D4,D0		; New X1.
		move.w	6(A1),D1		; Y1=Top edge.


noutt1: 	moveq	#0,D4		; Line is visible.
		rts

lineout:	moveq	#-1,D4		; Line invisible.
		rts

; Clip window...
clipleft:
		DC.W 110
clipright:
		DC.W 150
clipbottom:
		DC.W 120
cliptop:
		DC.W 80


; Is Bresenham line drawing the fastest?   Not any more...  ;-D
; Watch this space...
