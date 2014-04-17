/******************************************************************************

                                     GenEdit
                                        by
                                   Tom Bajoras

                        Copyright 1990/1991 Tom Bajoras

	module GR :  low-level graphics

	init_gr, xortext, gr_text, gr_fill, halftext

	slide_box, rubberbox, rubberline

	draw_box, xor_frame,
	fill_rect, xor_rect
	v_gwraptext, center_text
	draw_line
	draw_tri, fill_box

	set_colors, linefade

	in_rect

******************************************************************************/

overlay "misc"

/* include header files .....................................................*/

	/* standard */
#include <osbind.h>		/* GEMDOS, BIOS, XBIOS */
#include <gemdefs.h>		/* AES */
#include <obdefs.h>		/* more AES */

	/* program-specific */
#include "defines.h"		/* miscellaneous */
#include "temdefs.h"
#include "genedit.h"		/* created by RCS */
#include "externs.h"		/* global variables */

/* extern ...................................................................*/

	/* declared in AESBIND (in syslib) */
extern int *pioff, *iioff, *pooff, *iooff;
extern int int_in[],int_out[],control[],global[];
extern long addr_in[], addr_out[];

	/* export asm entry points */
int outchar(),xorchar(),init_gr(),xortext(),gr_text(),halftext(),halfchar();
int color0(),color1(),color2(),color3(),color4(),color5(),color6(),color7();
int color8(),color9(),mono0(),mono1(),gr_fill();

/* local globals ............................................................*/

long coloraddr[10];		/* text color table */

/* self-modify during startup ...............................................*/

asm
{
init_gr:
	cmpi.w	#2,rez(a4)
	bne		init_grc
	move.l	#0x4e714e71,d0			/* 2 NOP's */
	lea		outchar,a0
	move.l	d0,(a0)
	lea		xorchar,a0
	move.l	d0,(a0)
	lea		halfchar,a0
	move.l	d0,(a0)
	lea		gr_fill,a0
	move.l	d0,(a0)

	lea		mono0(PC),a1			move.l	a1,d0
	lea		mono1(PC),a1			move.l	a1,d1
	lea		coloraddr(a4),a0
	move.l	d0,(a0)+
	move.l	d1,(a0)+
	move.l	d0,(a0)+
	move.l	d1,(a0)+
	move.l	d0,(a0)+
	move.l	d1,(a0)+
	move.l	d1,(a0)+
	move.l	d1,(a0)+
	move.l	d1,(a0)+
	move.l	d1,(a0)+
	rts
init_grc:
	lea		coloraddr(a4),a0
	lea		color0(PC),a1			move.l	a1,(a0)+
	lea		color1(PC),a1			move.l	a1,(a0)+
	lea		color2(PC),a1			move.l	a1,(a0)+
	lea		color3(PC),a1			move.l	a1,(a0)+
	lea		color4(PC),a1			move.l	a1,(a0)+
	lea		color5(PC),a1			move.l	a1,(a0)+
	lea		color6(PC),a1			move.l	a1,(a0)+
	lea		color7(PC),a1			move.l	a1,(a0)+
	lea		color8(PC),a1			move.l	a1,(a0)+
	lea		color9(PC),a1			move.l	a1,(a0)+
	rts
}	/* end init_gr() */

/* write a string ...........................................................*/

asm	/* 4(a7).l --> string, null term'd, 8(a7).w = starting column # (0-79),
			10(a7).w = y-coord of TOP of character (0-399) */
{
gr_text:
	move.l	a2,d3
	dc.w		0xA00A			; hide mouse

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

	dc.w		0xA009			; show mouse
	move.l	d3,a2

	rts
}	/* end gr_text() */

/* write a character (replace mode) .........................................*/
/* preserves a2 for gr_text() */

asm	/* 4(a7).w = ascii code, 6(a7).w = column (0-79), 8(a7).w= y of
			TOP of character (0-399) */
{
outchar:
	bra.w		outcharc					; self-mod'd to NOP if rez==2
	move.l   fontptr(A4),A0
	adda.w   4(A7),A0					; a0 --> source
	move.l   scrbase(A4),d2			; base of screen memory
	move.w	8(a7),d0
	cmpi.w	#399,d0
	bgt		char_rts
	lsl.w		#4,d0						; 16*y
	move.w	d0,d1						; 16*y
	lsl.w		#2,d0						; 64*y
	add.w		d1,d0						; 80*y
	ext.l		d0
	add.l		d0,d2						; start of scan line
	move.w	6(a7),d0					; 1 byte per column
	blt		char_rts
	cmpi.w	#79,d0
	bgt		char_rts
	ext.l		d0
	add.l		d0,d2						; --> destination

	/* select color */
	lea		coloraddr(a4),a1
	move.w	gr_color(a4),d0
	movea.l	0(a1,d0),a1
	jmp		(a1)

mono0:
	movea.l	d2,a1
	move.w	8(a7),d0
	subi.w	#384,d0
	ble		mono0jmp
	move.w	d0,d2
	lsl.w		#2,d0
	lsl.w		#1,d2
	add.w		d2,d0					; 6 * (y-384)
	addq.w	#2,d0					; adjust for PC jump
	jmp		0(PC,d0)

; each line is 6 bytes
mono0jmp:
	move.b	3840(a0),1200(a1)
	move.b	3584(a0),1120(a1)
	move.b	3328(a0),1040(a1)
	move.b	3072(a0),960(a1)
	move.b	2816(a0),880(a1)
	move.b	2560(a0),800(a1)
	move.b	2304(a0),720(a1)
	move.b	2048(a0),640(a1)
	move.b	1792(a0),560(a1)
	move.b	1536(a0),480(a1)
	move.b	1280(a0),400(a1)
	move.b	1024(a0),320(a1)
	move.b	768(a0),240(a1)
	move.b	512(a0),160(a1)
	move.b	256(a0),80(a1)
	move.b	(a0),(a1)

char_rts:
	rts

mono1:
	movea.l	d2,a1
	move.w	8(a7),d0
	subi.w	#384,d0
	ble		mono1jmp
	move.w	d0,d2
	lsl.w		#3,d0
	lsl.w		#1,d2
	add.w		d2,d0					; 10 * (y-384)
	addq.w	#2,d0					; adjust for PC jump
	jmp		0(PC,d0)

; each line is 10 bytes
mono1jmp:
	move.b	3840(a0),d0		not.b d0			move.b d0,1200(a1)
	move.b	3584(a0),d0		not.b d0			move.b d0,1120(a1)
	move.b	3328(a0),d0		not.b d0			move.b d0,1040(a1)
	move.b	3072(a0),d0		not.b d0			move.b d0,960(a1)
	move.b	2816(a0),d0		not.b d0			move.b d0,880(a1)
	move.b	2560(a0),d0		not.b d0			move.b d0,800(a1)
	move.b	2304(a0),d0		not.b d0			move.b d0,720(a1)
	move.b	2048(a0),d0		not.b d0			move.b d0,640(a1)
	move.b	1792(a0),d0		not.b d0			move.b d0,560(a1)
	move.b	1536(a0),d0		not.b d0			move.b d0,480(a1)
	move.b	1280(a0),d0		not.b d0			move.b d0,400(a1)
	move.b	1024(a0),d0		not.b d0			move.b d0,320(a1)
	move.b	768(a0),d0		not.b d0			move.b d0,240(a1)
	move.b	512(a0),d0		not.b d0			move.b d0,160(a1)
	move.b	256(a0),d0		not.b d0			move.b d0,80(a1)
	move.b	(a0),d0			not.b d0			move.b d0,(a1)
	rts

outcharc:
	move.l   fontptr(a4),a0
	adda.w   4(a7),a0					; --> source
	move.l   scrbase(a4),d2			; base of screen memory
	move.w   8(a7),d0
	cmpi.w	#199,d0
	bgt		char_rts
	lsl.w		#5,d0						;  32*y
	move.w	d0,d1						;  32*y
	lsl.w		#2,d0						; 128*y
	add.w		d1,d0						; 160*y
	ext.l		d0
	add.l		d0,d2						; start of scan line
	move.w	6(a7),d0
	blt		char_rts
	cmpi.w	#79,d0
	bgt		char_rts
	move.w	d0,d1
	andi.w	#1,d1						; x%2
	andi.w	#0xFFFE,d0
	lsl.w		#1,d0
	add.w		d1,d0
	ext.l		d0
	add.l		d0,d2						; --> destination

	/* select color */
	lea		coloraddr(a4),a1
	move.w	gr_color(a4),d0
	movea.l	0(a1,d0),a1
	jmp		(a1)

color0:
	move.l	d2,a1

	move.w	8(a7),d0
	subi.w	#192,d0
	ble		color0jmp
	move.w	d0,d2
	lsl.w		#3,d0
	lsl.w		#2,d2
	add.w		d2,d0					; 12 * (y-192)
	addq.w	#2,d0					; adjust for PC jump
	jmp		0(PC,d0)

; each line is 12 bytes
color0jmp:
	move.b	1792(a0),d0		move.b	d0,1120(a1)		move.b	d0,1122(a1)
	move.b	1536(a0),d0		move.b	d0,960(a1)		move.b	d0,962(a1)
	move.b	1280(a0),d0		move.b	d0,800(a1)		move.b	d0,802(a1)
	move.b	1024(a0),d0		move.b	d0,640(a1)		move.b	d0,642(a1)
	move.b	768(a0),d0		move.b	d0,480(a1)		move.b	d0,482(a1)
	move.b	512(a0),d0		move.b	d0,320(a1)		move.b	d0,322(a1)
	move.b	256(a0),d0		move.b	d0,160(a1)		move.b	d0,162(a1)
	move.b	(a0),d0			move.b	d0,(a1)			move.b	d0,2(a1)
	rts

color1:
	move.l	d2,a1

	move.w	8(a7),d0
	subi.w	#192,d0
	ble		color1jmp
	move.w	d0,d2
	lsl.w		#4,d0
	lsl.w		#1,d2
	sub.w		d2,d0					; 14 * (y-192)
	addq.w	#2,d0					; adjust for PC jump
	jmp		0(PC,d0)

; each line is 14 bytes
color1jmp:
	move.b	1792(a0),d0		not.b		d0
									move.b	d0,1120(a1)		move.b	d0,1122(a1)
	move.b	1536(a0),d0		not.b		d0
									move.b	d0,960(a1)		move.b	d0,962(a1)
	move.b	1280(a0),d0		not.b		d0
									move.b	d0,800(a1)		move.b	d0,802(a1)
	move.b	1024(a0),d0		not.b		d0
									move.b	d0,640(a1)		move.b	d0,642(a1)
	move.b	768(a0),d0		not.b		d0
									move.b	d0,480(a1)		move.b	d0,482(a1)
	move.b	512(a0),d0		not.b		d0
									move.b	d0,320(a1)		move.b	d0,322(a1)
	move.b	256(a0),d0		not.b		d0
									move.b	d0,160(a1)		move.b	d0,162(a1)
	move.b	(a0),d0			not.b		d0
									move.b	d0,(a1)			move.b	d0,2(a1)
	rts

color2:
	move.l	d2,a1
	moveq		#0,d1

	move.w	8(a7),d0
	subi.w	#192,d0
	ble		color2jmp
	move.w	d0,d2
	lsl.w		#3,d0
	lsl.w		#2,d2
	add.w		d2,d0					; 12 * (y-192)
	addq.w	#2,d0					; adjust for PC jump
	jmp		0(PC,d0)

; each line is 12 bytes
color2jmp:
	move.b	1792(a0),d0		move.b	d0,1120(a1)		move.b	d1,1122(a1)
	move.b	1536(a0),d0		move.b	d0,960(a1)		move.b	d1,962(a1)
	move.b	1280(a0),d0		move.b	d0,800(a1)		move.b	d1,802(a1)
	move.b	1024(a0),d0		move.b	d0,640(a1)		move.b	d1,642(a1)
	move.b	768(a0),d0		move.b	d0,480(a1)		move.b	d1,482(a1)
	move.b	512(a0),d0		move.b	d0,320(a1)		move.b	d1,322(a1)
	move.b	256(a0),d0		move.b	d0,160(a1)		move.b	d1,162(a1)
	move.b	(a0),d0			move.b	d0,(a1)			move.b	d1,2(a1)
	rts

color3:
	move.l	d2,a1
	moveq		#0,d1

	move.w	8(a7),d0
	subi.w	#192,d0
	ble		color3jmp
	move.w	d0,d2
	lsl.w		#4,d0
	lsl.w		#1,d2
	sub.w		d2,d0					; 14 * (y-192)
	addq.w	#2,d0					; adjust for PC jump
	jmp		0(PC,d0)

; each line is 14 bytes
color3jmp:
	move.b	1792(a0),d0		not.b		d0
									move.b	d0,1120(a1)		move.b	d1,1122(a1)
	move.b	1536(a0),d0		not.b		d0
									move.b	d0,960(a1)		move.b	d1,962(a1)
	move.b	1280(a0),d0		not.b		d0
									move.b	d0,800(a1)		move.b	d1,802(a1)
	move.b	1024(a0),d0		not.b		d0
									move.b	d0,640(a1)		move.b	d1,642(a1)
	move.b	768(a0),d0		not.b		d0
									move.b	d0,480(a1)		move.b	d1,482(a1)
	move.b	512(a0),d0		not.b		d0
									move.b	d0,320(a1)		move.b	d1,322(a1)
	move.b	256(a0),d0		not.b		d0
									move.b	d0,160(a1)		move.b	d1,162(a1)
	move.b	(a0),d0			not.b		d0
									move.b	d0,(a1)			move.b	d1,2(a1)
	rts

color4:
	move.l	d2,a1
	moveq		#0,d1

	move.w	8(a7),d0
	subi.w	#192,d0
	ble		color4jmp
	move.w	d0,d2
	lsl.w		#3,d0
	lsl.w		#2,d2
	add.w		d2,d0					; 12 * (y-192)
	addq.w	#2,d0					; adjust for PC jump
	jmp		0(PC,d0)

; each line is 12 bytes
color4jmp:
	move.b	1792(a0),d0		move.b	d1,1120(a1)		move.b	d0,1122(a1)
	move.b	1536(a0),d0		move.b	d1,960(a1)		move.b	d0,962(a1)
	move.b	1280(a0),d0		move.b	d1,800(a1)		move.b	d0,802(a1)
	move.b	1024(a0),d0		move.b	d1,640(a1)		move.b	d0,642(a1)
	move.b	768(a0),d0		move.b	d1,480(a1)		move.b	d0,482(a1)
	move.b	512(a0),d0		move.b	d1,320(a1)		move.b	d0,322(a1)
	move.b	256(a0),d0		move.b	d1,160(a1)		move.b	d0,162(a1)
	move.b	(a0),d0			move.b	d1,(a1)			move.b	d0,2(a1)
	rts

color5:
	move.l	d2,a1
	moveq		#0,d1

	move.w	8(a7),d0
	subi.w	#192,d0
	ble		color5jmp
	move.w	d0,d2
	lsl.w		#4,d0
	lsl.w		#1,d2
	sub.w		d2,d0					; 14 * (y-192)
	addq.w	#2,d0					; adjust for PC jump
	jmp		0(PC,d0)

; each line is 14 bytes
color5jmp:

	move.b	1792(a0),d0		not.b		d0
									move.b	d1,1120(a1)		move.b	d0,1122(a1)
	move.b	1536(a0),d0		not.b		d0
									move.b	d1,960(a1)		move.b	d0,962(a1)
	move.b	1280(a0),d0		not.b		d0
									move.b	d1,800(a1)		move.b	d0,802(a1)
	move.b	1024(a0),d0		not.b		d0
									move.b	d1,640(a1)		move.b	d0,642(a1)
	move.b	768(a0),d0		not.b		d0
									move.b	d1,480(a1)		move.b	d0,482(a1)
	move.b	512(a0),d0		not.b		d0
									move.b	d1,320(a1)		move.b	d0,322(a1)
	move.b	256(a0),d0		not.b		d0
									move.b	d1,160(a1)		move.b	d0,162(a1)
	move.b	(a0),d0			not.b		d0
									move.b	d1,(a1)			move.b	d0,2(a1)
	rts

color6:
	move.l	d2,a1
	moveq		#-1,d1

	move.w	8(a7),d0
	subi.w	#192,d0
	ble		color6jmp
	move.w	d0,d2
	lsl.w		#3,d0
	lsl.w		#2,d2
	add.w		d2,d0					; 12 * (y-192)
	addq.w	#2,d0					; adjust for PC jump
	jmp		0(PC,d0)

; each line is 12 bytes
color6jmp:
	move.b	1792(a0),d0		move.b	d1,1120(a1)		move.b	d0,1122(a1)
	move.b	1536(a0),d0		move.b	d1,960(a1)		move.b	d0,962(a1)
	move.b	1280(a0),d0		move.b	d1,800(a1)		move.b	d0,802(a1)
	move.b	1024(a0),d0		move.b	d1,640(a1)		move.b	d0,642(a1)
	move.b	768(a0),d0		move.b	d1,480(a1)		move.b	d0,482(a1)
	move.b	512(a0),d0		move.b	d1,320(a1)		move.b	d0,322(a1)
	move.b	256(a0),d0		move.b	d1,160(a1)		move.b	d0,162(a1)
	move.b	(a0),d0			move.b	d1,(a1)			move.b	d0,2(a1)
	rts

color7:
	move.l	d2,a1
	moveq		#-1,d1

	move.w	8(a7),d0
	subi.w	#192,d0
	ble		color7jmp
	move.w	d0,d2
	lsl.w		#4,d0
	lsl.w		#1,d2
	sub.w		d2,d0					; 14 * (y-192)
	addq.w	#2,d0					; adjust for PC jump
	jmp		0(PC,d0)

; each line is 14 bytes
color7jmp:
	move.b	1792(a0),d0		move.b	d1,1120(a1)		not.b		d0
																	move.b	d0,1122(a1)
	move.b	1536(a0),d0		move.b	d1,960(a1)		not.b		d0
																	move.b	d0,962(a1)
	move.b	1280(a0),d0		move.b	d1,800(a1)		not.b		d0
																	move.b	d0,802(a1)
	move.b	1024(a0),d0		move.b	d1,640(a1)		not.b		d0
																	move.b	d0,642(a1)
	move.b	768(a0),d0		move.b	d1,480(a1)		not.b		d0
																	move.b	d0,482(a1)
	move.b	512(a0),d0		move.b	d1,320(a1)		not.b		d0
																	move.b	d0,322(a1)
	move.b	256(a0),d0		move.b	d1,160(a1)		not.b		d0
																	move.b	d0,162(a1)
	move.b	(a0),d0			move.b	d1,(a1)			not.b		d0
																	move.b	d0,2(a1)
	rts

color8:
	move.l	d2,a1
	moveq		#-1,d1

	move.w	8(a7),d0
	subi.w	#192,d0
	ble		color8jmp
	move.w	d0,d2
	lsl.w		#3,d0
	lsl.w		#2,d2
	add.w		d2,d0					; 12 * (y-192)
	addq.w	#2,d0					; adjust for PC jump
	jmp		0(PC,d0)

; each line is 12 bytes
color8jmp:
	move.b	1792(a0),d0		move.b	d0,1120(a1)		move.b	d1,1122(a1)
	move.b	1536(a0),d0		move.b	d0,960(a1)		move.b	d1,962(a1)
	move.b	1280(a0),d0		move.b	d0,800(a1)		move.b	d1,802(a1)
	move.b	1024(a0),d0		move.b	d0,640(a1)		move.b	d1,642(a1)
	move.b	768(a0),d0		move.b	d0,480(a1)		move.b	d1,482(a1)
	move.b	512(a0),d0		move.b	d0,320(a1)		move.b	d1,322(a1)
	move.b	256(a0),d0		move.b	d0,160(a1)		move.b	d1,162(a1)
	move.b	(a0),d0			move.b	d0,(a1)			move.b	d1,2(a1)
	rts

color9:
	move.l	d2,a1
	moveq		#-1,d1

	move.w	8(a7),d0
	subi.w	#192,d0
	ble		color9jmp
	move.w	d0,d2
	lsl.w		#4,d0
	lsl.w		#1,d2
	sub.w		d2,d0					; 14 * (y-192)
	addq.w	#2,d0					; adjust for PC jump
	jmp		0(PC,d0)

; each line is 14 bytes
color9jmp:
	move.b	1792(a0),d0		not.b		d0
									move.b	d0,1120(a1)		move.b	d1,1122(a1)
	move.b	1536(a0),d0		not.b		d0
									move.b	d0,960(a1)		move.b	d1,962(a1)
	move.b	1280(a0),d0		not.b		d0
									move.b	d0,800(a1)		move.b	d1,802(a1)
	move.b	1024(a0),d0		not.b		d0
									move.b	d0,640(a1)		move.b	d1,642(a1)
	move.b	768(a0),d0		not.b		d0
									move.b	d0,480(a1)		move.b	d1,482(a1)
	move.b	512(a0),d0		not.b		d0
									move.b	d0,320(a1)		move.b	d1,322(a1)
	move.b	256(a0),d0		not.b		d0
									move.b	d0,160(a1)		move.b	d1,162(a1)
	move.b	(a0),d0			not.b		d0
									move.b	d0,(a1)			move.b	d1,2(a1)
	rts

}  /* end outchar() */

/* xor a row of characters ..................................................*/

asm	/* 4(a7).w = # of characters, 6(a7).w= start column (0-79), 
			8(a7).w = y of TOP of character (0-399) */
{
xortext:
	move.l	a2,d3
	dc.w		0xA00A			; hide mouse

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

	dc.w		0xA009			; show mouse
	move.l	d3,a2

	rts
}	/* end xortext() */

/* xor a character ..........................................................*/
/* preserves d2 for xortext */

asm	/* 4(a7).w = column (0-79), 6(a7).w= y of	TOP of character (0-399) */
{
xorchar:
	bra.w		xorcharc					; self-mod'd to NOP if rez==2
	move.l   scrbase(A4),A1			; base of screen memory
	move.w	6(a7),d0
	cmpi.w	#399,d0
	bgt		xor_rts
	lsl.w		#4,d0						; 16*y
	move.w	d0,d1						; 16*y
	lsl.w		#2,d0						; 64*y
	add.w		d1,d0						; 80*y
	adda.w	d0,a1						; start of scan line
	move.w	4(a7),d0					; 1 byte per column
	blt		xor_rts
	cmpi.w	#79,d0
	bgt		xor_rts
	adda.w	d0,a1						; --> destination

	move.w	6(a7),d0
	subi.w	#384,d0
	ble		xor_jmp
	lsl.w		#2,d0					; 4 * (y-384)
	addq.w	#2,d0					; adjust for PC jump
	jmp		0(PC,d0)

xor_jmp:
	not.b	1200(a1)
	not.b	1120(a1)
	not.b	1040(a1)
	not.b	960(a1)
	not.b	880(a1)
	not.b	800(a1)
	not.b	720(a1)
	not.b	640(a1)
	not.b	560(a1)
	not.b	480(a1)
	not.b	400(a1)
	not.b	320(a1)
	not.b	240(a1)
	not.b	160(a1)
	not.b	80(a1)
	not.b	 0(a1)

xor_rts:
	rts

xorcharc:
	move.l   scrbase(A4),A1			; base of screen memory
	move.w   6(A7),d0
	cmpi.w	#199,d0
	bgt		xor_rts
	lsl.w		#5,d0						;  32*y
	move.w	d0,d1						;  32*y
	lsl.w		#2,d0						; 128*y
	add.w		d1,d0						; 160*y
	adda.w	d0,a1						; start of scan line
	move.w	4(a7),d0
	blt		xor_rts
	cmpi.w	#79,d0
	bgt		xor_rts
	move.w	d0,d1
	andi.w	#1,d1						; x%2
	andi.w	#0xFFFE,d0
	lsl.w		#1,d0
	add.w		d1,d0
	adda.w	d0,a1						; --> destination

	move.w	6(a7),d0
	subi.w	#192,d0
	ble		xorc_jmp
	lsl.w		#3,d0					; 8 * (y-192)
	addq.w	#2,d0					; adjust for PC jump
	jmp		0(PC,d0)

xorc_jmp:
	not.b 1120(a1)			not.b 1122(a1)
	not.b 960(a1)			not.b 962(a1)
	not.b 800(a1)			not.b 802(a1)
	not.b 640(a1)			not.b 642(a1)
	not.b 480(a1)			not.b 482(a1)
	not.b 320(a1)			not.b 322(a1)
	not.b 160(a1)			not.b 162(a1)
	not.b 0(a1)				not.b 2(a1)

	rts
}  /* end xorchar() */

/* halftone a row of characters .............................................*/

asm	/* 4(a7).w = # of characters, 6(a7).w= start column (0-79), 
			8(a7).w = y of TOP of character (0-399) */
{
halftext:
	move.l	a2,d3
	dc.w		0xA00A			; hide mouse

	move.w	4(a7),d2			; # of columns
	move.w	6(a7),d1			; start column
	move.w	8(a7),-(a7)		; y-coord
	move.w	d1,-(a7)			; x-column
	subq.w	#1,d2				; prepare for dbf
halfloop:
	bsr		halfchar
	addq.w	#1,(a7)			; increment column
	dbf		d2,halfloop
	addq.w	#4,a7				; pop x-column and y-coord

	dc.w		0xA009			; show mouse
	move.l	d3,a2

	rts
}	/* end halftext() */

/* halftone a character .....................................................*/
/* preserves d2 for halftext */

asm	/* 4(a7).w = column (0-79), 6(a7).w= y of	TOP of character (0-399) */
{
halfchar:
	bra.w		halfchrc					; self-mod'd to NOP if rez==2
	move.l   scrbase(A4),A1			; base of screen memory
	move.w	6(a7),d0
	cmpi.w	#399,d0
	bgt		half_rts
	lsl.w		#4,d0						; 16*y
	move.w	d0,d1						; 16*y
	lsl.w		#2,d0						; 64*y
	add.w		d1,d0						; 80*y
	adda.w	d0,a1						; start of scan line
	move.w	4(a7),d0					; 1 byte per column
	blt		half_rts
	cmpi.w	#79,d0
	bgt		half_rts
	adda.w	d0,a1						; --> destination

	move.w	6(a7),d0
	subi.w	#384,d0
	ble		half_jmp
	move.w	d0,d1
	lsl.w		#2,d0
	lsl.w		#1,d1
	add.w		d1,d0					; 6 * (y-384)
	addq.w	#2,d0					; adjust for PC jump
	jmp		0(PC,d0)

half_jmp:
	andi.b	#0xAA,1200(a1)
	andi.b	#0x55,1120(a1)
	andi.b	#0xAA,1040(a1)
	andi.b	#0x55, 960(a1)
	andi.b	#0xAA, 880(a1)
	andi.b	#0x55, 800(a1)
	andi.b	#0xAA, 720(a1)
	andi.b	#0x55, 640(a1)
	andi.b	#0xAA, 560(a1)
	andi.b	#0x55, 480(a1)
	andi.b	#0xAA, 400(a1)
	andi.b	#0x55, 320(a1)
	andi.b	#0xAA, 240(a1)
	andi.b	#0x55, 160(a1)
	andi.b	#0xAA,  80(a1)
	andi.b	#0x55,    (a1)

half_rts:
	rts

halfchrc:
	move.l   scrbase(A4),A1			; base of screen memory
	move.w   6(A7),d0
	cmpi.w	#199,d0
	bgt		half_rts
	lsl.w		#5,d0						;  32*y
	move.w	d0,d1						;  32*y
	lsl.w		#2,d0						; 128*y
	add.w		d1,d0						; 160*y
	adda.w	d0,a1						; start of scan line
	move.w	4(a7),d0
	blt		half_rts
	cmpi.w	#79,d0
	bgt		half_rts
	move.w	d0,d1
	andi.w	#1,d1						; x%2
	andi.w	#0xFFFE,d0
	lsl.w		#1,d0
	add.w		d1,d0
	adda.w	d0,a1						; --> destination

	move.w	6(a7),d0
	subi.w	#192,d0
	ble		halfc_jmp
	move.w	d0,d1
	lsl.w		#2,d1
	lsl.w		#3,d0
	add.w		d1,d0					; 12 * (y-192)
	addq.w	#2,d0					; adjust for PC jump
	jmp		0(PC,d0)

halfc_jmp:
	andi.b	#0xAA,1120(a1)			andi.b	#0xAA,1122(a1)
	andi.b	#0x55, 960(a1)			andi.b	#0x55, 962(a1)
	andi.b	#0xAA, 800(a1)			andi.b	#0xAA, 802(a1)
	andi.b	#0x55, 640(a1)			andi.b	#0x55, 642(a1)
	andi.b	#0xAA, 480(a1)			andi.b	#0xAA, 482(a1)
	andi.b	#0x55, 320(a1)			andi.b	#0x55, 322(a1)
	andi.b	#0xAA, 160(a1)			andi.b	#0xAA, 162(a1)
	andi.b	#0x55,   0(a1)			andi.b	#0x55,   2(a1)

	rts
}  /* end halfchar() */

/* filled rectangle (using gr_fcolor) .......................................*/

asm {	/* 4(a7).w= x1, 6(a7).w= x2, 8(a7).w= y1, 10(a7).w= y2, 12(a7).w= mode */
		/* x1 and x2 are character columns, y1 and y2 are screen coords,
			mode= 0 fill, =1 xor */
gr_fill:
	bra		gr_fillc					; self-mod'd to NOP if rez==2

	movem.l  d4-d7/a2-a3,-(a7)
	dc.w		0xA00A					; hide mouse

	move.w   36(a7),d0				; mode
	lsl.w    #1,d0						; index into selfm table
	lea      selfm(PC),a0			; self-modify
	lea      hloopm(PC),a1
	move.w   0(a0,d0),(a1)

	move.l   scrbase(a4),a2			; a2 --> base of screen memory
	move.w   32(a7),d1				; y1
	muls		#80,d1
	add.w		28(a7),d1				; x1
	adda.l   d1,a2						; a2 --> left edge of screen area

	move.w	30(a7),d3
	sub.w		28(a7),d3
	subq.w	#1,d3						; loop counter for horizontal dbf
	move.w   34(a7),d0
	sub.w    32(a7),d0
	subq.w	#1,d0						; loop counter for vertical dbf

	move.w	gr_fcolor(a4),d2		; what to fill with
	sne		d2							; any color > 0 becomes 0xff in mono

vloopm:
	move.w   d3,d1						; reset horizontal counter
	movea.l	a2,a1						; left edge of area
hloopm:
	nop
	dbf		d1,hloopm
	adda.l   #80,a2					; left edge of next scan line
	dbf      d0,vloopm

	dc.w		0xA009					; show mouse
	movem.l  (a7)+,d4-d7/a2-a3
	rts

selfm:
	move.b   d2,(a1)+					; table of code for self mod'ing mono
	eor.b    d2,(a1)+

gr_fillc:
	movem.l	d4-d7/a2-a3,-(a7)
	dc.w		0xA00A					; hide mouse

	move.w   36(a7),d0				; mode
	lsl.w    #1,d0						; index into selfc table
	lea      selfc(PC),a0			; self-modify
	lea      hloopc(PC),a1
	adda.w	d0,a0
	move.w	(a0)+,(a1)+
	move.l	(a0)+,(a1)+

	movea.l  scrbase(a4),a2			; base of screen memory
	move.w   32(a7),d0				; y1
	muls		#160,d0
	adda.w	d0,a2						; start of scan line
	move.w	28(a7),d0				; x1
	move.l	#0x00030001,d5			; set up interleaving
	btst.b	#0,d0
	beq		on_even
	swap		d5
on_even:
	move.w	d0,d1
	andi.w	#1,d1						; x1%2
	andi.w	#0xFFFE,d0
	lsl.w		#1,d0
	add.w		d1,d0
	adda.w	d0,a2						; --> left edge of area

	move.w	30(a7),d3
	sub.w		28(a7),d3
	subq.w	#1,d3						; loop counter for horizontal dbf
	move.w   34(a7),d0
	sub.w    32(a7),d0
	subq.w	#1,d0						; loop counter for vertical dbf

	move.w	gr_fcolor(a4),d1		; what to fill with
	btst.b	#1,d1
	sne		d2							; upper color plane
	btst.b	#0,d1
	sne		d4							; lower color plane

vloopc:
	move.w   d3,d1						; reset horizontal counter
	movea.l	a2,a1						; left edge of area
	move.l	d5,d6						; reset interleaving
hloopc:
	nop nop nop
	adda.w	d6,a1
	swap		d6
	dbf		d1,hloopc
	adda.l   #160,a2					; left edge of next scan line
	dbf      d0,vloopc

	dc.w		0xA009					; show mouse
	movem.l	(a7)+,d4-d7/a2-a3
	rts

selfc:
	move.b	d2,(a1)					; table of code for self mod'ing color
	move.b	d4,2(a1)
	eor.b		d2,(a1)
	eor.b		d4,2(a1)

}	/* end gr_fill() */

/* custom slide box .........................................................*/
/* returns final mstate */

slide_box(x1,y1,w1,h1,   x2,y2,w2,h2,   nhot,hotx,hoty,hotw,hoth,
showx,showy,showw,showh)
int *x1,*y1;			/* initial position of slider */
int w1,h1;				/* size of slider */
int x2,y2,w2,h2;		/* position and size of boundaries */
int nhot;				/* # of hot spots */
int *hotx,*hoty,*hotw,*hoth;	/* hot spot positions/sizes */
int *showx,*showy,*showw,*showh;	/* xor'd box positions/sizes */
{
	int old_x,old_y,new_x,new_y,mx,my;
	int xlo,xhi,ylo,yhi;
	int xdel,ydel,mstate,oldmstate;
	register int style1,style2;

	style1= style2= chase_disabled ? 0xFFFF : 0xF0F0 ;

	set_clip(0,0,640,200*rez);

	xlo=x2;		xhi= x2+w2-w1;
	ylo=y2;		yhi= y2+h2-h1;
	getmouse(&xdel,&ydel);
	xdel -= *x1;
	ydel -= *y1;
	new_x= old_x= *x1;
	new_y= old_y= *y1;
	vswr_mode(gl_hand,3);
	draw_box(style1,style2,old_x,old_y,old_x+w1-1,old_y+h1-1);

	/* loop until mstate changes */
	oldmstate= getmouse(&dummy,&dummy);
	while ( mstate=getmouse(&mx,&my) )
	{
		if (mstate==3) break;
		if (mstate!=oldmstate) break;
		chasedelay();
		new_x= mx-xdel;
		new_y= my-ydel;
		if (new_x<xlo) new_x=xlo;		if (new_x>xhi) new_x=xhi;
		if (new_y<ylo) new_y=ylo;		if (new_y>yhi) new_y=yhi;
		if (!chase_disabled || (old_x!=new_x) || (old_y!=new_y) )
		{
			draw_box(style1,style2,old_x,old_y,old_x+w1-1,old_y+h1-1);
			asm {
				ror.w #1,style1
				rol.w #1,style2
			}
			old_x=new_x;	old_y=new_y;
			draw_box(style1,style2,old_x,old_y,old_x+w1-1,old_y+h1-1);
		}
		hndl_hot(mx,my,nhot,hotx,hoty,hotw,hoth,showx,showy,showw,showh);
	}
	draw_box(style1,style2,old_x,old_y,old_x+w1-1,old_y+h1-1);
	hndl_hot(-1,-1,nhot,hotx,hoty,hotw,hoth,showx,showy,showw,showh);
	vswr_mode(gl_hand,1);

	*x1= new_x;		*y1= new_y;

	return mstate;

}	/* end slide_box() */

/* custom rubber box ........................................................*/
/* returns final mstate */

rubberbox(x,y,x2,y2,xmin,ymin,xmax,ymax)
int x,y;				/* anchor corner */
int *x2,*y2;		/* mouse position */
int xmin,ymin;		/* minimum upper left corner */
int xmax,ymax;		/* maximum lower right corner */
{
	int old_x,old_y,new_x,new_y,mstate,oldmstate;
	int mx,my;
	register int style1,style2;

	style1= style2= chase_disabled ? 0xFFFF : 0xF0F0 ;

	set_clip(0,0,640,200*rez);

	new_x= old_x= *x2;
	new_y= old_y= *y2;
	vswr_mode(gl_hand,3);
	draw_box(style1,style2,x,y,old_x,old_y);

	/* loop until mstate changes */
	oldmstate= getmouse(&dummy,&dummy);
	while ( mstate=getmouse(&mx,&my) )
	{
		if (mstate==3) break;	/* !!! */
		if (mstate!=oldmstate) break;
		chasedelay();
		new_x=mx;
		new_y=my;
		if (new_x>xmax) new_x=xmax;
		if (new_y>ymax) new_y=ymax;
		if (new_x<xmin) new_x=xmin;
		if (new_y<ymin) new_y=ymin;
		if (!chase_disabled || (old_x!=new_x) || (old_y!=new_y) )
		{
			draw_box(style1,style2,x,y,old_x,old_y);
			asm {
				ror.w #1,style1
				rol.w #1,style2
			}
			old_x=new_x;
			old_y=new_y;
			draw_box(style1,style2,x,y,old_x,old_y);
		}
	}
	draw_box(style1,style2,x,y,old_x,old_y);
	vswr_mode(gl_hand,1);

	*x2= new_x;		*y2= new_y;

	return mstate;

}	/* end rubberbox() */

/* rubber line ..............................................................*/
/* returns final mstate */

rubberline(x,y,x2,y2,xmin,ymin,xmax,ymax)
int x,y;				/* initial mouse position (stationary) */
int *x2,*y2;		/* final mouse position */
int xmin,ymin;		/* minimum upper left corner */
int xmax,ymax;		/* maximum lower right corner */
{
	int old_x,old_y,new_x,new_y,oldmstate,mstate;
	int mx,my;

	set_clip(0,0,640,200*rez);

	old_x= x;
	old_y= y;
	new_x= *x2;
	new_y= *y2;
	vswr_mode(gl_hand,3);
	draw_line(0xFFFF,x,y,1,1);

	/* loop until mstate changes */
	oldmstate= getmouse(&dummy,&dummy);
	while ( mstate=getmouse(&mx,&my) )
	{
		if (mstate==3) break;	/* !!! */
		if (mstate!=oldmstate) break;
		chasedelay();
		new_x=mx;
		new_y=my;
		if (new_x>xmax) new_x=xmax;
		if (new_y>ymax) new_y=ymax;
		if (new_x<xmin) new_x=xmin;
		if (new_y<ymin) new_y=ymin;
		if ((old_x!=new_x)||(old_y!=new_y))
		{
			draw_line(0xFFFF,x,y,old_x-x+1,old_y-y+1);
			old_x=new_x;
			old_y=new_y;
			draw_line(0xFFFF,x,y,old_x-x+1,old_y-y+1);
		}
	}
	draw_line(0xFFFF,x,y,old_x-x+1,old_y-y+1);
	vswr_mode(gl_hand,1);

	*x2= new_x;		*y2= new_y;

	return mstate;

}	/* end rubberline() */

/* draw a hollow rectangle in a specified line style ........................*/
/* change name to draw_frame() !!! */

draw_box(style1,style2,x1,y1,x2,y2)
int style1,style2,x1,y1,x2,y2;
{
   int xy[10];
	register int i;

	vsl_type(gl_hand,7);

	if (x2<x1)
	{
		i=x2;
		x2=x1;
		x1=i;
	}
	if (y2<y1)
	{
		i=y2;
		y2=y1;
		y1=i;
	}

	xy[8]= xy[6]= xy[0]= x1;
	xy[9]= xy[3]= xy[1]= y1;
	xy[4]= xy[2]= x2;
	xy[7]= xy[5]= y2;

	HIDEMOUSE;
	for (i=0; i<4; i++)
	{
		vsl_udsty( gl_hand , i==2 ? style2 : style1 );
		v_pline(gl_hand,2,&xy[2*i]);
	}
	SHOWMOUSE;

	vsl_type(gl_hand,1);

}	/* end draw_box() */

/* draw a line in a specified line style ....................................*/
/* also write an xor_line() !!! */

draw_line(style,x,y,w,h)
int style,x,y,w,h;
{
   int xy[4];

	vsl_type(gl_hand,7);

	xy[0]= x;
	xy[1]= y;
	xy[2]= x+w-1;
	xy[3]= y+h-1;

	HIDEMOUSE;
	vsl_udsty(gl_hand,style);
	v_pline(gl_hand,2,xy);
	SHOWMOUSE;

	vsl_type(gl_hand,1);

}	/* end draw_line() */

hndl_hot(x,y,nhot,hotx,hoty,hotw,hoth,showx,showy,showw,showh)
int x,y,nhot,*hotx,*hoty,*hotw,*hoth,*showx,*showy,*showw,*showh;
{
	static int currhot= -1;
	register int i;

	for (i=0; i<nhot; i++)
		if (in_rect(x,y,hotx[i],hoty[i],hotw[i],hoth[i])) break;
	if ( i!=currhot )
	{
		if (currhot>=0)
			fill_rect(showx[currhot],showy[currhot],
						 showw[currhot],showh[currhot],1);
		currhot= i==nhot ? -1 : i ;
		if (currhot>=0)
			fill_rect(showx[currhot],showy[currhot],
						 showw[currhot],showh[currhot],1);
	}
}	/* end hndl_hot() */

/* draw an xor frame ........................................................*/

xor_frame(x1,x2,y1,y2)
int x1,x2,y1,y2;
{
	vswr_mode(gl_hand,3);
	draw_box(0xFFFF,0xFFFF,x1,y1,x2,y2);
	vswr_mode(gl_hand,1);
}	/* end xor_frame() */

/* fill a given rectangle ...................................................*/
/* change name to draw_rect() !!! */

fill_rect(x,y,w,h,pattern)
int x,y,w,h;
int pattern;	/* 1= solid, 0= hollow, > 1 pattern */
{
	int xy[8];
	int x2,y2;

	/* something's wrong with GEM (no kidding) */
	y--; h+=2;

	xy[6]= xy[0]= x;
	xy[3]= xy[1]= y;
	xy[4]= xy[2]= x2= x+w-1;
	xy[7]= xy[5]= y2= y+h-1;

	HIDEMOUSE;

/* note: these next 2 lines must be done in this order */
   vsf_interior(gl_hand,min(pattern,2));	/* hollow/solid/pattern */
	vsf_style(gl_hand,pattern);

/* vsf_perimeter(gl_hand,0); workaround for Turbo ST v1.6 bug !!! */
   vsf_perimeter(gl_hand,h<3);

   v_fillarea(gl_hand,4,xy);
	SHOWMOUSE;
}	/* end fill_rect() */

/* draw a filled rectangle in xor mode ......................................*/

xor_rect(x,y,w,h)
int x,y,w,h;
{
	vswr_mode(gl_hand,3);
	fill_rect(x,y,w,h,1);
	vswr_mode(gl_hand,1);
}	/* end xor_rect() */

/* is a given (x,y) within a given x,y,w,h ? ................................*/
/* returns 1 yes, 0 no */

in_rect(xx,yy,x,y,w,h)
int xx,yy,x,y,w,h;
{
	if (w<0) { x+=w; w=-w; }
	if (h<0) { y+=h; h=-h; }
	return (	(xx>=x) && (xx<=x+w-1) && (yy>=y) && (yy<=y+h-1) ) ;
}	/* end in_rect() */

/* install color pallette ...................................................*/

set_colors(colors)
register int *colors;
{
	register int i;
	for (i=0; i<16; i++) Setcolor(i,*colors++);
}	/* end set_colors() */

/* line-by-line screen fade in ..............................................*/

linefade(ptr)
register long *ptr;	/* --> screen-sized buffer to be blitted to screen */
{
	register int i,j,maxlines;
	register long *scrptr;
	int linemask[400];
	int interleave;

	scrptr= (long*)(scrbase);
	interleave= rez==2 ? 20 : 40 ;

	HIDEMOUSE;
	maxlines= (SCRLENG/4)/interleave;
	for (i=0; i<maxlines; i++) linemask[i]=i;
	while (maxlines)
	{
		i= ( Random() % maxlines );
		j= linemask[i];
		linemask[i]=linemask[--maxlines];
		j*=interleave;
		for (i=0; i<interleave; i++) scrptr[j+i]=ptr[j+i];
	}
	SHOWMOUSE;
}	/* linefade() */

/* text with word-wrap ......................................................*/
/* assumes top aligned text */

v_gwraptext(x,y,w,h,str)
int x,y,w,h;
register char *str;
{
	register int i,n;
	int savech,y2,len;

	w /= charw;			/* width in characters */
	y2= y+h-1;			/* bottom edge of box */

	HIDEMOUSE;
	n=strlen(str);
	while (n)
	{
		if (y>=y2) break;
		if (n<=w)
		{
			v_gtext(gl_hand,x,y,str);
			n=0;
		}
		else
		{
			for (i=w; i>=0; i--) if (str[i]==' ') break;
			if (i<0) i=w;
			savech= str[i];
			str[i]=0;
			v_gtext(gl_hand,x,y,str);
			len= strlen(str);
			str[i]=savech;
			if (savech==' ') len++;
			n -= len;
			str += len;
			y += (charh+1) ;
		}
	}
	SHOWMOUSE;
}	/* end v_gwraptext() */

/* text centered in a box ...................................................*/
/* assumes top aligned text */

center_text(str,x,y,w,h)
char *str;			/* --> null term'd string */
int x,y,w,h;
{
	int wstr;

	wstr= min( w, charw * strlen(str) ) ;
	x= x + w/2 - wstr/2 ;
	y= y + h/2 - charh/2;
	if (h%2) y++;						/* sacrifice descender */
	if (gl_font) x++;					/* I'm not sure why */
	HIDEMOUSE;
	v_gtext(gl_hand,x,y,str);		/* not clipped if string won't fit */
	SHOWMOUSE;
}	/* end center_text() */

/* filled triangle ..........................................................*/

draw_tri(x,y,w,h,dir)
int x,y,w,h,dir;	/* dir= 0 down, 1 up, 2 left, 3 right */
{
	int xy[6];
	int pattern=1;	/* always solid (for now) */

	/* something's wrong with GEM */
	y--; h+=2;

	if (dir<2)		/* up/down */
	{
		xy[0]= x;
		xy[2]= x + w/2 ;
		xy[4]= x + w - 1 ;
	}
	else
	{
		xy[1]= y;
		xy[3]= y + h/2 ;
		xy[5]= y + h - 1 ;
	}
	switch (dir)
	{
		case 0:	/* down */
		xy[1]= xy[5]= y;
		xy[3]= y+h-1;
		break;

		case 1:	/* up */
		xy[1]= xy[5]= y+h-1;
		xy[3]= y;
		break;
	
		case 2:	/* left */
		xy[0]= xy[4]= x+w-1;
		xy[2]= x;
		break;
		
		case 3:	/* right */
		xy[0]= xy[4]= x;
		xy[2]= x+w-1;
	}

	HIDEMOUSE;
	vsf_style(gl_hand,pattern);
	if (pattern>1) pattern=2;
   vsf_interior(gl_hand,pattern);
   vsf_perimeter(gl_hand,0);
   v_fillarea(gl_hand,3,xy);
	SHOWMOUSE;
}	/* end draw_tri() */

/* filled box ...............................................................*/
/* get rid of this, instead a perimeter arg passed to fill_rect() !!! */

fill_box(x,y,w,h,pattern)
int x,y,w,h,pattern;
{
	draw_box(0xFFFF,0xFFFF,x,y,x+w-1,y+h-1);
	fill_rect(x+1,y+1,w-2,h-2,pattern);
}	/* end fill_box() */

extern chasedelay();
asm {
chasedelay:
	move.l #0x1fff,d0
loop:
	subi.l #1,d0
	bne	 loop
	rts
}

/* EOF */
