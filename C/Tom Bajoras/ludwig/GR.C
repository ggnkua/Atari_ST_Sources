/******************************************************************************

                                    Ludwig

                                      by
                                  Tom Bajoras

                        Copyright 1988 Hybrid Arts, Inc.

	module:	GR -- low-level (fast!) graphics

	draw_wind, draw_dial, outchar, outcurs, outnote
	init_gr, xorchar, xortext, gr_text
	save_screen, qsave_screen, qrest_screen

******************************************************************************/

overlay "gr"

/* include header files .....................................................*/

#include <asm.h>				  /* needed for in-line assembly language */
#include "defines.h"         /* program-specific */
#include <gemdefs.h>         /* AES                  */
#include <obdefs.h>          /* more AES  */
#include <osbind.h>          /* GEMDOS, BIOS, XBIOS  */
#include "ludwig.h"          /* created by RCS       */

/* global variables .........................................................*/

#include "externs.h"

/* declare extern any asm entry points ......................................*/

int outchar(),outcurs(),outnote(),xorchar(),init_gr(),xortext();
int qsave_screen(),qrest_screen(),gr_text();

/* draw a window frame ......................................................*/ 

draw_wind(type,windnum)
int type;	/* 0 - NTYPE-1 */
int windnum;	/* 0 - NWIND-1 */
{
	draw_it(windptr[type],windleng[type],windnum);
}	/* end draw_wind() */

/* draw a fake dialog box ...................................................*/

draw_dial(type,windnum)
int type;	/* 0 - NDIAL-1 */
int windnum;	/* 0 - NWIND-1 */
{
	draw_it(dialptr[type],dialleng[type],windnum);
}	/* end draw_dial() */

draw_it(from_ptr,leng,windnum)
register char *from_ptr;
register long leng;
int windnum;
{
	register char *to_ptr;
	int build_any();
	int save_lock;

	to_ptr= (char*)( scrbase + bytesperline*wind_y[windnum]);
	save_lock= xor_lock;
	xor_lock=1;
	asm {
		movem.l	d4-d6,-(a7)
		move.l	leng,d0
		lsl.l		#5,d0
		adda.l	d0,to_ptr		;  prepare for backward copy
		divu.w	#10,leng
		subq.w	#1,leng			;  prepare for dbf
windloop:
		movem.l	(from_ptr)+,d1-d6/a0-a1		movem.l	d1-d6/a0-a1,-(to_ptr)
		movem.l	(from_ptr)+,d1-d6/a0-a1		movem.l	d1-d6/a0-a1,-(to_ptr)
		movem.l	(from_ptr)+,d1-d6/a0-a1		movem.l	d1-d6/a0-a1,-(to_ptr)
		movem.l	(from_ptr)+,d1-d6/a0-a1		movem.l	d1-d6/a0-a1,-(to_ptr)
		movem.l	(from_ptr)+,d1-d6/a0-a1		movem.l	d1-d6/a0-a1,-(to_ptr)
		movem.l	(from_ptr)+,d1-d6/a0-a1		movem.l	d1-d6/a0-a1,-(to_ptr)
		movem.l	(from_ptr)+,d1-d6/a0-a1		movem.l	d1-d6/a0-a1,-(to_ptr)
		movem.l	(from_ptr)+,d1-d6/a0-a1		movem.l	d1-d6/a0-a1,-(to_ptr)
		movem.l	(from_ptr)+,d1-d6/a0-a1		movem.l	d1-d6/a0-a1,-(to_ptr)
		movem.l	(from_ptr)+,d1-d6/a0-a1		movem.l	d1-d6/a0-a1,-(to_ptr)
		jsr		build_any
		dbf		leng,windloop
		movem.l	(a7)+,d4-d6
	}
	xor_lock=save_lock;
}	/* end draw_it() */

/* self-modify for monochrome (during init'n) ...............................*/

asm
{
init_gr:
	lea		outchar,a0
	move.w	#0x4e71,(a0)			; NOP
	lea		outcurs,a0
	move.w	#0x4e71,(a0)			; NOP
	lea		outnote,a0
	move.w	#0x4e71,(a0)			; NOP
	lea		xorchar,a0
	move.w	#0x4e71,(a0)			; NOP
	rts
}	/* end init_gr() */

/* write a string ...........................................................*/

asm	/* 4(a7).l --> string, null term'd, 8(a7).w = starting column # (0-79),
			10(a7).w = y-coord of TOP of character (0-399) */
{
gr_text:
	move.l	a2,-(a7)			; save a2
	movea.l	8(a7),a2			; --> null term'd string
	move.w	12(a7),d0		; start column #
	move.w	14(a7),-(a7)	; y-coord
	move.w	d0,-(a7)
	clr.w		-(a7)				; clear out high byte of ascii code
textloop:
	move.b	(a2)+,1(a7)		; next character
	beq		end_text			; break out of loop when null
	bsr		outchar
	addq.w	#1,2(a7)			; increment column
	bra		textloop
end_text:
	addq.w	#6,a7				; pop arguments
	move.l	(a7)+,a2			; restore a2
	rts
}	/* end gr_text() */

/* write a character (replace mode) .........................................*/
/* preserves a2 for gr_text() */

asm	/* 4(a7).w = ascii code, 6(a7).w = column (0-79), 8(a7).w= y of
			TOP of character (0-399) */
{
outchar:
	bra.s		outcharc					; self-mod'd to NOP if rez==2
	move.l   fontptr(A4),A0
	adda.w   4(A7),A0					; a0 --> source
	move.l   scrbase(A4),A1			; base of screen memory
	move.w	8(a7),d0
	lsl.w		#4,d0						; 16*y
	move.w	d0,d1						; 16*y
	lsl.w		#2,d0						; 64*y
	add.w		d1,d0						; 80*y
	adda.w	d0,a1						; start of scan line
	move.w	6(a7),d0					; 1 byte per column
	adda.w	d0,a1						; --> destination

	move.b	(a0),(a1)				; copy line by line
	move.b	256(a0),80(a1)			; 256 bytes per font line
	move.b	512(a0),160(a1)		; 80 bytes per screen line
	move.b	768(a0),240(a1)
	move.b	1024(a0),320(a1)
	move.b	1280(a0),400(a1)
	move.b	1536(a0),480(a1)
	move.b	1792(a0),560(a1)
	move.b	2048(a0),640(a1)
	move.b	2304(a0),720(a1)
	move.b	2560(a0),800(a1)
	move.b	2816(a0),880(a1)
	move.b	3072(a0),960(a1)
	move.b	3328(a0),1040(a1)
	move.b	3584(a0),1120(a1)
	move.b	3840(a0),1200(a1)

	rts

outcharc:
	move.l   fontptr(A4),A0
	adda.w   4(A7),A0					; --> source
	move.l   scrbase(A4),A1			; base of screen memory
	move.w   8(A7),d0
	lsl.w		#5,d0						;  32*y
	move.w	d0,d1						;  32*y
	lsl.w		#2,d0						; 128*y
	add.w		d1,d0						; 160*y
	adda.w	d0,a1						; start of scan line
	move.w	6(a7),d0
	move.w	d0,d1
	andi.w	#1,d1						; x%2
	andi.w	#0xFFFE,d0
	lsl.w		#1,d0
	add.w		d1,d0
	adda.w	d0,a1						; --> destination

	move.b	(a0),(a1)				; copy 8 scan lines
	move.b	(a0),2(a1)				; to 2 color planes (word-interleaved)
	move.b	256(a0),160(a1)
	move.b	256(a0),162(a1)
	move.b	512(a0),320(a1)
	move.b	512(a0),322(a1)
	move.b	768(a0),480(a1)
	move.b	768(a0),482(a1)
	move.b	1024(a0),640(a1)
	move.b	1024(a0),642(a1)
	move.b	1280(a0),800(a1)
	move.b	1280(a0),802(a1)
	move.b	1536(a0),960(a1)
	move.b	1536(a0),962(a1)
	move.b	1792(a0),1120(a1)
	move.b	1792(a0),1122(a1)

	rts
}  /* end outchar() */

/* write a character from the note font .....................................*/

asm	/* 4(a7).w = code 0-9, 6(a7).w = column (0-79), 8(a7).w= y of
			TOP of character (0-399) */
{
outnote:
	bra.s		outnotec					; self-mod'd to NOP if rez==2
	lea		notefont,a0
	adda.w   4(A7),A0					; a0 --> source
	move.l   scrbase(A4),A1			; base of screen memory
	move.w	8(a7),d0
	lsl.w		#4,d0						; 16*y
	move.w	d0,d1						; 16*y
	lsl.w		#2,d0						; 64*y
	add.w		d1,d0						; 80*y
	adda.w	d0,a1						; start of scan line
	move.w	6(a7),d0					; 1 byte per column
	adda.w	d0,a1						; --> destination

	move.b	(a0),(a1)				; copy line by line
	move.b	12(a0),80(a1)			; 10 bytes per font line
	move.b	24(a0),160(a1)			; 80 bytes per screen line
	move.b	36(a0),240(a1)
	move.b	48(a0),320(a1)
	move.b	60(a0),400(a1)
	move.b	72(a0),480(a1)
	move.b	84(a0),560(a1)
	move.b	96(a0),640(a1)
	move.b	108(a0),720(a1)
	move.b	120(a0),800(a1)
	move.b	132(a0),880(a1)
	move.b	144(a0),960(a1)
	move.b	156(a0),1040(a1)
	move.b	168(a0),1120(a1)
	move.b	180(a0),1200(a1)

	rts

outnotec:
	lea		notefont,a0
	adda.w   4(A7),A0					; --> source
	move.l   scrbase(A4),A1			; base of screen memory
	move.w   8(A7),d0
	lsl.w		#5,d0						;  32*y
	move.w	d0,d1						;  32*y
	lsl.w		#2,d0						; 128*y
	add.w		d1,d0						; 160*y
	adda.w	d0,a1						; start of scan line
	move.w	6(a7),d0
	move.w	d0,d1
	andi.w	#1,d1						; x%2
	andi.w	#0xFFFE,d0
	lsl.w		#1,d0
	add.w		d1,d0
	adda.w	d0,a1						; --> destination

	move.b	(a0),(a1)			move.b	(a0),2(a1)
	move.b	12(a0),160(a1)		move.b	12(a0),162(a1)
	move.b	24(a0),320(a1)		move.b	24(a0),322(a1)
	move.b	36(a0),480(a1)		move.b	36(a0),482(a1)
	move.b	48(a0),640(a1)		move.b	48(a0),642(a1)
	move.b	60(a0),800(a1)		move.b	60(a0),802(a1)
	move.b	72(a0),960(a1)		move.b	72(a0),962(a1)
	move.b	84(a0),1120(a1)	move.b	84(a0),1122(a1)
	move.b	96(a0),1280(a1)	move.b	96(a0),1282(a1)
	move.b	108(a0),1440(a1)	move.b	108(a0),1442(a1)
	move.b	120(a0),1600(a1)	move.b	120(a0),1602(a1)
	move.b	132(a0),1760(a1)	move.b	132(a0),1762(a1)
	move.b	144(a0),1920(a1)	move.b	144(a0),1922(a1)
	move.b	156(a0),2080(a1)	move.b	156(a0),2082(a1)
	move.b	168(a0),2240(a1)	move.b	168(a0),2242(a1)
	move.b	180(a0),2400(a1)	move.b	180(a0),2402(a1)

	rts

notefont:
	dc.w  0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0C0C, 0x0C0C
	dc.w  0x0C08, 0x0808, 0x0800, 0x0000, 0x0A0A, 0x0A0A, 0x0A08, 0x0808
	dc.w  0x0800, 0x0000, 0x0909, 0x0909, 0x0908, 0x0808, 0x0800, 0x0000
	dc.w  0x0C0C, 0x0C08, 0x0808, 0x0808, 0x0800, 0x0000, 0x0A0A, 0x0A08
	dc.w  0x0808, 0x0808, 0x0800, 0x0000, 0x0909, 0x0908, 0x0808, 0x0808
	dc.w  0x0800, 0x0000, 0x0C08, 0x0808, 0x0808, 0x0808, 0x0800, 0x0000
	dc.w  0x0A08, 0x0808, 0x0808, 0x0808, 0x0800, 0x0000, 0x0908, 0x0808
	dc.w  0x0808, 0x0808, 0x0800, 0x0000, 0x0808, 0x0808, 0x0808, 0x0808
	dc.w  0x0800, 0x0000, 0x3838, 0x3838, 0x3838, 0x3838, 0x3830, 0x0000
	dc.w  0x7878, 0x7B78, 0x7B78, 0x7B48, 0x4B48, 0x0000, 0x7878, 0x7B78
	dc.w  0x7B78, 0x7B48, 0x4B48, 0x0000, 0x3030, 0x3030, 0x3030, 0x3030
	dc.w  0x3030, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000

}  /* end outnote() */

/* write the cursor (xor mode) ..............................................*/

asm	/* 4(a7).w = column (0-79), 6(a7).w= y of TOP of character (0-399) */
{
outcurs:
	bra.s		outcursc					; self-mod'd to NOP if rez==2

	move.l	a2,d3
	dc.w		0xA00A			; hide mouse
	move.l	d3,a2

	move.l   scrbase(A4),A1			; base of screen memory
	move.w	6(a7),d0
	lsl.w		#4,d0						; 16*y
	move.w	d0,d1						; 16*y
	lsl.w		#2,d0						; 64*y
	add.w		d1,d0						; 80*y
	adda.w	d0,a1						; start of scan line
	move.w	4(a7),d0					; 1 byte per column
	adda.w	d0,a1						; --> destination

	eori.b	#0x40,160(a1)
	eori.b	#0x60,240(a1)
	eori.b	#0x70,320(a1)
	eori.b	#0x78,400(a1)
	eori.b	#0x7c,480(a1)
	eori.b	#0x7e,560(a1)
	eori.b	#0x7e,640(a1)
	eori.b	#0x7c,720(a1)
	eori.b	#0x78,800(a1)
	eori.b	#0x70,880(a1)
	eori.b	#0x60,960(a1)
	eori.b	#0x40,1040(a1)

	move.l	a2,d3
	dc.w		0xA009			; show mouse
	move.l	d3,a2

	rts

outcursc:

	move.l	a2,d3
	dc.w		0xA00A			; hide mouse
	move.l	d3,a2

	move.l   scrbase(A4),A1			; base of screen memory
	move.w   6(A7),d0
	lsl.w		#5,d0						;  32*y
	move.w	d0,d1						;  32*y
	lsl.w		#2,d0						; 128*y
	add.w		d1,d0						; 160*y
	adda.w	d0,a1						; start of scan line
	move.w	4(a7),d0
	move.w	d0,d1
	andi.w	#1,d1						; x%2
	andi.w	#0xFFFE,d0
	lsl.w		#1,d0
	add.w		d1,d0
	adda.w	d0,a1						; --> destination

	eori.b	#0x60,160(a1)		eori.b	#0x60,162(a1)
	eori.b	#0x78,320(a1)		eori.b	#0x78,322(a1)
	eori.b	#0x7e,480(a1)		eori.b	#0x7e,482(a1)
	eori.b	#0x7e,640(a1)		eori.b	#0x7e,642(a1)
	eori.b	#0x78,800(a1)		eori.b	#0x78,802(a1)
	eori.b	#0x60,960(a1)		eori.b	#0x60,962(a1)

	move.l	a2,d3
	dc.w		0xA009			; show mouse
	move.l	d3,a2

	rts
}  /* end outcurs() */

/* xor a row of characters ..................................................*/

asm	/* 4(a7).w = # of characters, 6(a7).w= start column (0-79), 
			8(a7).w = y of TOP of character (0-399) */
{
xortext:
	move.l	a2,d3
	dc.w		0xA00A			; hide mouse
	move.l	d3,a2

	move.w	4(a7),d2			; # of columns
	move.w	6(a7),d1			; start column
	move.w	8(a7),-(a7)		; y-coord
	move.w	d1,-(a7)			; x-column
	subq.w	#1,d2				; prepare for dbf
xorloop:
	bsr		xorchar
	addq.w	#1,(a7)			; increment column
	dbf		d2,xorloop
	addq.w	#4,a7				; pop x-column and y-coord

	move.l	a2,d3
	dc.w		0xA009			; show mouse
	move.l	d3,a2
	rts
}	/* end xortext() */

/* xor a character ..........................................................*/
/* preserves d2 for xortext */

asm	/* 4(a7).w = column (0-79), 6(a7).w= y of	TOP of character (0-399) */
{
xorchar:
	bra.s		xorcharc					; self-mod'd to NOP if rez==2
	move.l   scrbase(A4),A1			; base of screen memory
	move.w	6(a7),d0
	lsl.w		#4,d0						; 16*y
	move.w	d0,d1						; 16*y
	lsl.w		#2,d0						; 64*y
	add.w		d1,d0						; 80*y
	adda.w	d0,a1						; start of scan line
	move.w	4(a7),d0					; 1 byte per column
	adda.w	d0,a1						; --> destination

	moveq		#-1,d0

	eor.b	d0,(a1)
	eor.b	d0,80(a1)
	eor.b	d0,160(a1)
	eor.b	d0,240(a1)
	eor.b	d0,320(a1)
	eor.b	d0,400(a1)
	eor.b	d0,480(a1)
	eor.b	d0,560(a1)
	eor.b	d0,640(a1)
	eor.b	d0,720(a1)
	eor.b	d0,800(a1)
	eor.b	d0,880(a1)
	eor.b	d0,960(a1)
	eor.b	d0,1040(a1)
	eor.b	d0,1120(a1)
	eor.b	d0,1200(a1)

	rts

xorcharc:
	move.l   scrbase(A4),A1			; base of screen memory
	move.w   6(A7),d0
	lsl.w		#5,d0						;  32*y
	move.w	d0,d1						;  32*y
	lsl.w		#2,d0						; 128*y
	add.w		d1,d0						; 160*y
	adda.w	d0,a1						; start of scan line
	move.w	4(a7),d0
	move.w	d0,d1
	andi.w	#1,d1						; x%2
	andi.w	#0xFFFE,d0
	lsl.w		#1,d0
	add.w		d1,d0
	adda.w	d0,a1						; --> destination

	moveq		#-1,d0

	eor.b	d0,(a1)
	eor.b	d0,2(a1)
	eor.b	d0,160(a1)
	eor.b	d0,162(a1)
	eor.b	d0,320(a1)
	eor.b	d0,322(a1)
	eor.b	d0,480(a1)
	eor.b	d0,482(a1)
	eor.b	d0,640(a1)
	eor.b	d0,642(a1)
	eor.b	d0,800(a1)
	eor.b	d0,802(a1)
	eor.b	d0,960(a1)
	eor.b	d0,962(a1)
	eor.b	d0,1120(a1)
	eor.b	d0,1122(a1)

	rts
}  /* end xorchar() */

/* save/restore screen to/from scrsave ("stack" style -- faster) ............*/

save_screen(save,y1,y2)
int save;		/* 0 to restore screen (y1,y2 not needed) , 1 to save */
int y1,y2;		/* y-coord of top and bottom scan lines to be saved */
{
	static long ptr1,ptr2;
	static int n;
	int build_any();
	int save_lock;

	/* save/restore all registers */
	register long leng,d6,d5,d4;
	register long *from,*to;

	HIDEMOUSE;
	save_lock= xor_lock;
	xor_lock=1;
	if (save)
	{
		ptr1= scrbase + y1*bytesperline;		/* --> start of source */
		n= bytesperline*(y2-y1+1);				/* # bytes to save */
		while (n%320) n+=bytesperline;		/* must be div by 320 */
		n/=320;
		ptr2= scrsave + SCRLENG;				/* --> end of dest */
	}
	else
	{
		asm {
			move.l	ptr1(a4),d0
			move.l	ptr2(a4),ptr1(a4)
			move.l	d0,ptr2(a4)
		}
	}
	asm {
		movea.l		ptr1(a4),from			/* --> source */
		movea.l		ptr2(a4),to				/* --> dest end */
		move.w		n(a4),leng
		subq.w		#1,leng					/* prepare for dbf */
	saveloop:
		movem.l		(from)+,d0-d6/a0		movem.l		d0-d6/a0,-(to)
		movem.l		(from)+,d0-d6/a0		movem.l		d0-d6/a0,-(to)
		movem.l		(from)+,d0-d6/a0		movem.l		d0-d6/a0,-(to)
		movem.l		(from)+,d0-d6/a0		movem.l		d0-d6/a0,-(to)
		movem.l		(from)+,d0-d6/a0		movem.l		d0-d6/a0,-(to)
		movem.l		(from)+,d0-d6/a0		movem.l		d0-d6/a0,-(to)
		movem.l		(from)+,d0-d6/a0		movem.l		d0-d6/a0,-(to)
		movem.l		(from)+,d0-d6/a0		movem.l		d0-d6/a0,-(to)
		movem.l		(from)+,d0-d6/a0		movem.l		d0-d6/a0,-(to)
		movem.l		(from)+,d0-d6/a0		movem.l		d0-d6/a0,-(to)
		jsr			build_any
		dbf			leng,saveloop
		move.l		from,ptr1(a4)
		move.l		to,ptr2(a4)
	}
	xor_lock= save_lock;
	SHOWMOUSE;
}  /* end save_screen() */

/* save/restore screen to/from scrsave ("queue" style -- needed for VDI) ....*/ 

asm {				/* 4(a7).w = y1 , 6(a7).w = y2 */
qsave_screen:
	move.w	#0x22d8,d0		;	= move.l (a0)+,(a1)+
	bra		sv_or_rst
qrest_screen:
	move.w	#0x20d9,d0		;	= move.l (a1)+,(a0)+
sv_or_rst:
	lea		selfmod,a0
	move.w	d0,(a0)

	move.l	a2,d3
	dc.w		0xA00A				;	hide mouse
	move.l	d3,a2

	movea.l	scrbase(a4),a0
	moveq		#3,d1
	sub.w		rez(a4),d1
	move.w	4(a7),d0
	mulu		#80,d0
	mulu		d1,d0
	adda.w	d0,a0					; a0 --> source area
	mulu		#20,d1
	subq.w	#1,d1 	         ; d1.w= horizontal counter = 19 mono,39 color
	move.w	d1,d3    			; d3.w= initial d1
	move.w	6(a7),d0
	sub.w		4(a7),d0				; d0.w= vertical counter
	movea.l	scrsave(a4),a1		; a1= target area
selfmod:
	nop
	dbf		d1,selfmod
	move.w	d3,d1
	dbf		d0,selfmod

	move.l	a2,d3
	dc.w		0xA009				; show mouse
	move.l	d3,a2
	rts
}  /* end save/rest_screen() */

/* EOF gr.c */
