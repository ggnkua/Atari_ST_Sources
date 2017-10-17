/****
* fVDI miscellaneous functions
*
* Copyright 1997-2000, Johan Klockars 
* This software is licensed under the GNU General Public License.
* Please, see LICENSE.TXT for further information.
****/

#include "config.h"
#include "vdi.inc"
#include "macros.inc"

	.xdef	setup_plot
	.xref	__background

	.data
	
/* setup_plot - Internal function
*
* Sets up pointers to pixel draw functions
* In:	a0	VDI struct
*	4(a7)	drawing mode
* Out:	a1	draw function
*	a3	set pixel function
*	a4	get pixel function
*/
setup_plot:
	move.l	d0,-(a7)
	move.l	vwk_real_address(a0),a1
	move.l	wk_r_set_pixel(a1),a3
	move.l	wk_r_get_pixel(a1),a4
	moveq	#0,d0
	move.w	wk_screen_mfdb_bitplanes(a1),d0
	lea	mode_routines,a1
	cmp.l	#32,d0
	bne.s	.not_tc32
	lea	mode_routines32,a1
.not_tc32:
	move.w	8(a7),d0
	lsl.l	#2,d0; *4
	add.l	d0,a1
	move.l	(a7)+,d0
	move.l	-4(a1),a1
	rts

/* p_replace - Internal function
*
* Draws in replace mode
* In:	a0	-> VDI struct, destination MFDB
*	d0	background.w and foreground.w colour
*	d1	x
*	d2	y
*	a3	set pixel function
*	a4	get pixel function
*	carry	current mask bit
*/
p_replace:
	bcc	.background
	jsr	(a3)
	rts
.background:
	swap	d0
	jsr	(a3)
	swap	d0
	rts
	
p_replace32:
	bcc	.background32
	jsr	(a3)
	rts
.background32:
	move.l	d0,-(a7)
	move.l	__background,d0  // for TC32
	jsr	(a3)
	move.l	(a7)+,d0
	rts

/*  - Internal function
*
* Draws in transparent mode
*/
p_transp:
	bcc	.nothing
	jsr	(a3)
.nothing:
	rts

/* p_xor - Internal function
*
* Draws in xor mode
* I don't think this does the right thing!
*/
p_xor:
	lbcc	.nothing1
	move.l	d0,-(a7)
	jsr	(a4)
	not.l	d0		// Is this right instead perhaps?
	jsr	(a3)
	move.l	(a7)+,d0
.nothing1:
	rts

/* p_revtransp - Internal function
*
* Draws in reverse transparent mode
*/
p_revtransp:
	lbcs	.nothing_1
	jsr	(a3)
.nothing_1:
	rts

	.data

mode_routines:
	dc.l	p_replace,p_transp,p_xor,p_revtransp

mode_routines32:
	dc.l	p_replace32,p_transp,p_xor,p_revtransp

