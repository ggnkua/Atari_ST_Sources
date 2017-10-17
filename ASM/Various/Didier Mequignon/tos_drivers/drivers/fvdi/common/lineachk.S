/****
* fVDI device driver graphics mode check, by Johan Klockars
*
* This file is put in the public domain.
* It's not copyrighted or under any sort of license.
****/

#define doaline		0	// Do actual drawing w/ linea (clip)
#define mul			1	// Multiply rather than use table
#define shift		1

#include		"vdi.inc"
.ifne	doaline
	include		"linea.inc"
.endc

	.xdef		_check_linea
.ifeq		shift
	.xdef		dot,line,rline
.endc
.ifeq		mul
	.xdef		row
.endc
	.xdef		_font_table

	.xref		_Funcs_get_cookie

	.text

* The tables are mostly outdated
	
//colour:
//	dc.l		0x00000000,0x00000000
//	dc.l		0xffff0000,0x00000000
//	dc.l		0x0000ffff,0x00000000
//	dc.l		0xffffffff,0x00000000
//	dc.l		0x00000000,0xffff0000
//	dc.l		0xffff0000,0xffff0000
//	dc.l		0x0000ffff,0xffff0000
//	dc.l		0xffffffff,0xffff0000
//	dc.l		0x00000000,0x0000ffff
//	dc.l		0xffff0000,0x0000ffff
//	dc.l		0x0000ffff,0x0000ffff
//	dc.l		0xffffffff,0x0000ffff
//	dc.l		0x00000000,0xffffffff
//	dc.l		0xffff0000,0xffffffff
//	dc.l		0x0000ffff,0xffffffff
//	dc.l		0xffffffff,0xffffffff

  .ifeq	shift
dot:	dc.l		0x80008000,0x40004000,0x20002000,0x10001000
	dc.l		0x08000800,0x04000400,0x02000200,0x01000100
	dc.l		0x00800080,0x00400040,0x00200020,0x00100010
	dc.l		0x00080008,0x00040004,0x00020002,0x00010001

lline:	dc.l		0xffffffff,0x7fff7fff,0x3fff3fff,0x1fff1fff
	dc.l		0x0fff0fff,0x07ff07ff,0x03ff03ff,0x01ff01ff
	dc.l		0x00ff00ff,0x007f007f,0x003f003f,0x001f001f
	dc.l		0x000f000f,0x00070007,0x00030003,0x00010001

rline:	dc.l		0x80008000,0xc000c000,0xe000e000,0xf000f000
	dc.l		0xf800f800,0xfc00fc00,0xfe00fe00,0xff00ff00
	dc.l		0xff80ff80,0xffc0ffc0,0xffe0ffe0,0xfff0fff0
	dc.l		0xfff8fff8,0xfffcfffc,0xfffefffe,0xffffffff
  .endc

  .ifeq	mul
row:	ds.l		1024
  .endc

#ifdef COLDFIRE
cookie_linea:
	.asciz "A000"
	.align 2
#endif

// This used to setup clip as x,y,w,h
/* _check_linea - Initialization function
* Sets up hardware dependent workstation information
* Todo: ?
* In:	4(a7)	Pointer to workstation struct
*/
_check_linea:
#ifdef COLDFIRE
	lea		-36(a7),a7
	movem.l		d0-d3/a0-a4,(a7)
#else
	movem.l		d0-d3/a0-a4,-(a7)
#endif
	move.l		4+9*4(a7),a4
#ifdef COLDFIRE
	clr.l		-(sp)
	pea		cookie_linea(pc)
	jsr		_Funcs_get_cookie
	addq.l		#8,sp
	tst.l		d0
	ble.s		.no_cookie
	move.l		d0,a0
	jsr		(a0)
	bra.s		.get_infos_linea
.no_cookie:
	bra.s		.no_cookie
#endif
	dc.w		0xa000
.get_infos_linea:
	move.l		a1,_font_table
	move.l		a0,wk_screen_linea(a4)	// Needed?
	move.w		2(a0),d0
	move.w		d0,wk_screen_wrap(a4)
	move.w		-12(a0),d1
	move.w		d1,wk_screen_mfdb_width(a4)
	move.w		-4(a0),d1
	move.w		d1,wk_screen_mfdb_height(a4)
	move.w		(a0),wk_screen_mfdb_bitplanes(a4)

  .ifne	doaline
	move.w		#0xffff,lnmask(a0)	// solid line
	move.w		#0,wmode(a0)	// replace mode
	move.w		#0,lst_lin(a0)	// don't write last pixel
  .endc

  .ifeq	mul
	move.l		wk_screen_mfdb_address(a4),d0
	moveq		#0,d1
	move.w		wk_screen_wrap(a4),d1

#ifdef COLDFIRE
	move.l		#1024-1,d7
	lea		row(pc),a0

.row_l:
	move.l		d0,(a0)+
	add.l		d1,d0
	subq.l		#1,D7
	bpl.s		d7
.endc

	movem.l		(a7),d0-d3/a0-a4
	lea		36(a7),a7

#else
	move.w		#1024-1,d7
	lea		row(pc),a0

.row_l:
	move.l		d0,(a0)+
	add.l		d1,d0
	dbra		d7,.row_l
  .endc
  
	movem.l		(a7)+,d0-d3/a0-a4
#endif
	rts

	.lcomm _font_table,4	// Pointer to font head table (3)
	
