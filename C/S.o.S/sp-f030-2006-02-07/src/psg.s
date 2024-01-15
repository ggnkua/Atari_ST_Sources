/*
    Copyright (c) 2006 Peter Persson

    This program is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program; if not, write to the Free Software
    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
*/

/*
    Changelog
    2005-11-20  Created                                   (Peter Persson)
    2005-11-29  Added smarter noise channel handling      (Peter Persson)
    2005-12-03  Implemented noise pitch emulation         (Peter Persson)
    2006-01-15  Rewrote everything in assembler           (Peter Persson)
                Corrected initial noise setting           (Peter Persson)
                Adjusted noise threshold                  (Peter Persson)
	      Implemented periodic noise handling       (Peter Persson)
    2006-01-25  Rewrote YM access routines (nasty bug)    (Peter Persson)

*/

	.text
	
	.globl	_psg_write
	.globl	_psg_open
	.globl	_psg_close
	.globl	_psg_reset

/************************************************
*
* Main chip write function, router
*
* Input: D0 = data + registeraddress
*
*/

	
_psg_write:
	movel	4(sp),d0	| data

	btst	#7,d0
	beq	no_latch

	moveb	d0,d1
	andi.w	#0x0f,d0		| D0 = data portion

	andi	#0x70,d1		| D1 = Register address portion
	lsr	#2,d1		| Adjust D1 for jump table
	moveb	d1,cur_register	| Store register address
	
	movel	jt_latch(pc,d1),a0	|
	jmp	(a0)		| Jump to register handler

no_latch:
	moveb	cur_register,d1	| Retrieve current register address (see above)
	andi.w	#0x3f,d0		| D0 = data portion

	movel	jt_nolatch(pc,d1),a0|
	jmp	(a0)		| Jump to register handler
		

/*--- Jump tables ---*/

jt_latch:	/* latch bit set */
	dcl	frq_t1_lo,vol_t1,frq_t2_lo,vol_t2,frq_t3_lo,vol_t3,mod_ns,vol_ns

jt_nolatch:	/* latch bit not set */
	dcl	frq_t1_hi,vol_t1,frq_t2_hi,vol_t2,frq_t3_hi,vol_t3,mod_ns,vol_ns


/************************************************
*
* Register handlers
*
* Input: D0 = pure data
*
*/

frq_t1_lo:moveb	YM_per1l,d1
	andib	#0xf0,d1
	orw	d0,d1
	moveb	d1,YM_per1l
	movel	YM_setp1l,0xff8800
	rts
	
frq_t2_lo:moveb	YM_per2l,d1
	andib	#0xf0,d1
	orw	d0,d1
	moveb	d1,YM_per2l
	movel	YM_setp2l,0xff8800
	rts
	
frq_t3_lo:moveb	YM_per3l,d1
	andib	#0xf0,d1
	orw	d0,d1
	moveb	d1,YM_per3l
	movel	YM_setp3l,0xff8800
	rts
	
frq_t1_hi:moveb	YM_per1l,d1
	andib	#0x0f,d1
	lslw	#4,d0
	orb	d0,d1
	moveb	d1,YM_per1l
	movel	YM_setp1l,0xff8800
	lsr.w	#8,d0
	moveb	d0,YM_per1h
	movel	YM_setp1h,0xff8800
	rts
			
frq_t2_hi:moveb	YM_per2l,d1
	andib	#0x0f,d1
	lslw	#4,d0
	orb	d0,d1
	moveb	d1,YM_per2l
	movel	YM_setp2l,0xff8800
	lsr.w	#8,d0
	moveb	d0,YM_per2h
	movel	YM_setp2h,0xff8800
	rts

frq_t3_hi:moveb	d0,d1
	lsrb	#1,d1
	eorb	#0x1f,d1
	moveb	d0,NS_ptch
	
	moveb	YM_per3l,d1
	andib	#0x0f,d1
	lslw	#4,d0
	orb	d0,d1
	moveb	d1,YM_per3l
	movel	YM_setp3l,0xff8800
	lsr.w	#8,d0
	moveb	d0,YM_per3h
	movel	YM_setp3h,0xff8800

	tstb	noise_mod_flag
	beq	no_mod

	movel	YM_setpN,0xff8800	| set noise pitch

no_mod:	rts


mod_ns:	andb	#0x03,d0

	cmpb	#0x03,d0
	seq	noise_mod_flag

	eorb	#0x03,d0
	lslb	#3,d0
	moveb	d0,NS_ptch
	
	movel	YM_setpN,0xff8800	| set noise pitch
	rts

	
vol_ns:	eorb	#0x0f,d0
	moveb	d0,NS_vol
	bra EmulateNoiseChannel

vol_t1:	eorb	#0x0f,d0
	moveb	d0,YM_vol1
	move.l	YM_setv1,0xff8800

	bset	#3,YM_flags
	bclr	#0,YM_flags
	bsr	set_flags

	bra EmulateNoiseChannel

vol_t2:	eorb	#0x0f,d0
	moveb	d0,YM_vol2
	move.l	YM_setv2,0xff8800

	bset	#4,YM_flags
	bclr	#1,YM_flags
	bsr	set_flags

	bra EmulateNoiseChannel


vol_t3:	eorb	#0x0f,d0
	moveb	d0,YM_vol3
	move.l	YM_setv3,0xff8800

	bset	#5,YM_flags
	bclr	#2,YM_flags
	bsr	set_flags

	bra EmulateNoiseChannel


/************************************************
*
* Handle YM flags
*
*/

set_flags:movew	#0x2700,sr	| disable interrupts

	moveb	#0x07,0xff8800
	moveb	0xff8800,d0
	andb	#0xC0,d0
	orb	YM_flags,d0	
	moveb	d0,0xff8802

	movew	#0x2300,sr	| enable interrupts
	rts



/************************************************
*
* Noise Channel emulator
*
*/


EmulateNoiseChannel:

	/* first, check if noise is enabled */
	
	moveb	NS_vol,d0
	tstb	d0	
	beq	no_noise	/* if not, exit */

	/* find a free channel */

	tstb	YM_vol1
	beq	use_ch1
	tstb	YM_vol2
	beq	use_ch2
	tstb	YM_vol3
	beq	use_ch3

	/* no free channel... */

	cmpb	#11,d0	/* check if noise volume exceeds 11 */
	blt	no_noise	/* nope, turn noise off on all channels */
	
	andb	#0xC7,YM_flags	/* yep, enable noise on all channels */
	bra	set_flags


	/* use a channel only for noise
	set volume, disable tone, enable noise */
use_ch1:	bclr	#3,YM_flags
	bset	#0,YM_flags
	bsr	set_flags

	moveb	#8,YM_setvN	| select channel 1
	movel	YM_setvN,0xff8800
	rts

use_ch2:	bclr	#4,YM_flags
	bset	#1,YM_flags
	bsr	set_flags

	moveb	#9,YM_setvN	| select channel 1
	movel	YM_setvN,0xff8800
	rts

use_ch3:	bclr	#5,YM_flags
	bset	#2,YM_flags
	bsr	set_flags

	moveb	#10,YM_setvN	| select channel 1
	movel	YM_setvN,0xff8800
	rts

	/* no noise, disable noise on all channels */
no_noise:	orb	#0x38,YM_flags
	bra	set_flags

/************************************************
*
* Sound chip initialisation routine
*
* Initialise virtual soundchip and YM
*
*/


_psg_open:
	bra	_psg_reset


/************************************************
*
* De-initialisation stuff
*
* Currently only resets the soundchip.
*
*/
	

_psg_close:
	bra	_psg_reset


/************************************************
*
* Reset YM and virtual soundchip
*
*
*/


_psg_reset:
	movem	d0-d7/a0-a6,-(sp)

	/* reset internal variables */
	
	moveb	#0,cur_register
	moveb	#0,YM_per1l
	moveb	#0,YM_per1h
	moveb	#0,YM_per2l
	moveb	#0,YM_per2h
	moveb	#0,YM_per3l
	moveb	#0,YM_per3h

	/* disable noise & tone channels */

	moveb	#0x3F,YM_flags
	bsr	set_flags

	/* zero volume on all channels */

	movel	YM_setv1,0xff8800
	movel	YM_setv2,0xff8800
	movel	YM_setv3,0xff8800

	/* reset pitch on all channels */

	movel	YM_setp1l,0xff8800
	movel	YM_setp2l,0xff8800
	movel	YM_setp3l,0xff8800
	movel	YM_setp1h,0xff8800
	movel	YM_setp2h,0xff8800
	movel	YM_setp3h,0xff8800

	
	movem	(sp)+,d0-d7/a0-a6
	rts

/************************************************
*
* Variables
*
*
*/
	.data
	.even
YM_setv1:	dc.b	0x08,0x00
YM_vol1:	dc.b	0x00,0x00

YM_setv2:	dc.b	0x09,0x00
YM_vol2:	dc.b	0x00,0x00

YM_setv3:	dc.b	0x0A,0x00
YM_vol3:	dc.b	0x00,0x00

YM_setvN:	dc.b	0x00,0x00
NS_vol:	dc.b	0x00,0x00

YM_setpN:	dc.b	0x06,0x00
NS_ptch:	dc.b	0x00,0x00

YM_setp1l:dc.b	0x00,0x00
YM_per1l:	dc.b	0x00,0x00

YM_setp1h:dc.b	0x01,0x00
YM_per1h:	dc.b	0x00,0x00

YM_setp2l:dc.b	0x02,0x00
YM_per2l:	dc.b	0x00,0x00

YM_setp2h:dc.b	0x03,0x00
YM_per2h:	dc.b	0x00,0x00

YM_setp3l:dc.b	0x04,0x00
YM_per3l:	dc.b	0x00,0x00

YM_setp3h:dc.b	0x05,0x00
YM_per3h:	dc.b	0x00,0x00

	.comm	YM_flags,1
	.comm	noise_mod_flag,1
	.comm	cur_register,1
