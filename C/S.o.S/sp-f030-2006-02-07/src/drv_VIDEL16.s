/*
    Copyright (c) 2006 Peter Persson
    Video init/exit code from DHS demosystem

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
    2006-02-04	Created			(Peter Persson)
    2006-02-07	Fixed various bugs		(Peter Persson)
    		Added PAL support (VGA only)	(Peter Persson)
*/


	.text
	.globl	_OpenVIDEL16
	.globl	_CloseVIDEL16
	.globl	_UpdateVIDEL16
	.globl	_PaletteVIDEL16
	
/*****************************************************************
*
* long OpenDRIVER(bitmap_ptr);
*
*/

_OpenVIDEL16:
	movel	4(sp),gamegear_flag
	movel	8(sp),bitmap_ptr
	moveml	d1-d7/a0-a6,sp@-

	/* reserve video memory in ST-RAM */	
	movew	#0,-(sp)		| ST-ram only
	movel	#100000,-(sp)	| Size of 1 * 256*192*16bpp + some extra bytes for alignment
	movew	#0x44,-(sp)
	trap	#1
	addql	#8,sp
	
	addl	#256,d0
	andl	#0xffffff00,d0	/* align the data */
	movel	d0,screen

	/* initialise hardware etc */
	movel	#init,-(sp)
	movew	#0x26,-(sp)
	trap	#14
	addl	#6,sp

	moveml	sp@+,d1-d7/a0-a6
	rts


/* Initialisation stuff, supervisor mode */

init:	/* save video settings (stolen from DHS demosys) */
	leal	0xffff9800.w,a0			/* save falcon palette */
	leal	save_pal,a1			
	movew	#256-1,d7				
colloop:	movel	(a0)+,(a1)+			
	dbra	d7,colloop			

	moveml	0xffff8240.w,d0-d7			/* save st palette */
	moveml	d0-d7,(a1)			

	leal	save_video,a0			/* store videomode */
	movel	0xffff8200.w,(a0)+			/* vidhm */
	movew	0xffff820c.w,(a0)+			/* vidl */
	movel	0xffff8282.w,(a0)+			/* h-regs */
	movel	0xffff8286.w,(a0)+			
	movel	0xffff828a.w,(a0)+			
	movel	0xffff82a2.w,(a0)+			/* v-regs */
	movel	0xffff82a6.w,(a0)+			
	movel	0xffff82aa.w,(a0)+			
	movew	0xffff82c0.w,(a0)+			/* vco */
	movew	0xffff82c2.w,(a0)+			/* c_s */
	movel	0xffff820e.w,(a0)+			/* offset */
	movew	0xffff820a.w,(a0)+			/* sync */
	moveb	0xffff8256.w,(a0)+			/* p_o */
	clrb	(a0)				/* test of st(e) or falcon mode */
	cmpw	#0xb0,0xffff8282.w			/* hht kleiner 0xb0? */
	sle	(a0)+				/* flag setzen */
	movew	0xffff8266.w,(a0)+			/* f_s */
	movew	0xffff8260.w,(a0)+			/* st_s */

	/* set screen structure and resolution based on console type */
	movel	(bitmap_ptr),a1
	movel	screen,(a1)+	/* screen memory for emulator */
	
	movel	gamegear_flag,d0
	btst	#0,0xff8006
	sne	d1
	andl	#4,d1
	orl	d1,d0
	
	movel	#mode_lookup,a0
	movel	(a0,d0*4),a0

	/* force new VIDEL settings */
cont:	movel	(a0)+,(a1)+	/* width */
	movel	(a0)+,(a1)+	/* height */
	movel	(a0)+,(a1)+	/* pitch */
	movel	(a0)+,(a1)+	/* depth */
	movel	(a0)+,(a1)+	/* granularity */
	movel	(a0)+,screen_size	/* used internally */
	
	movel	(a0)+,0xFFFF8282
	movel	(a0)+,0xFFFF8286
	movel	(a0)+,0xFFFF828A
	movel	(a0)+,0xFFFF82A2
	movel	(a0)+,0xFFFF82A6
	movel	(a0)+,0xFFFF82AA
	movew	(a0)+,0xFFFF820A
	movew	(a0)+,0xFFFF82C0
	clrw	0xFFFF8266
	movew	(a0)+,0xFFFF8266
	movew	(a0)+,0xFFFF82C2
	movew	(a0)+,0xFFFF8210

	/* set border colour to black */
	movel	#0,0xffff9800

	/* clear frameskip counter */
	movel	#0,flipcntr

	/* set screen address */
	movel	screen,d0
	movel	d0,0xff8200	/* msb */
	movew	d0,0xff8203	/* middle byte */
	moveb	d0,0xff820D	/* lsb */ 

	/* install VBI */
	movew	#0x2700,sr
	movel	0x70,old_vbi
	movel	#vbi,0x70
	movew	#0x2300,sr

	rts


mode_lookup:	dc.l sms_vga_pal_mode	/* 000 */
		dc.l gg_vga_mode		/* 001 */
		dc.l sms_vga_ntsc_mode	/* 010 */
		dc.l gg_vga_mode		/* 011 */
		dc.l sms_rgb_pal_mode	/* 100 */
		dc.l gg_rgb_mode		/* 101 */
		dc.l sms_rgb_ntsc_mode	/* 110 */
		dc.l gg_rgb_mode		/* 111 */

	/* 256x192x8bpp, 60hz, RGB */
	/* uses 25Mhz clock */
sms_rgb_ntsc_mode:
	dc.l	256,192,512,16,2,98304
	dc.l	0xC7009F, 0x1F0022, 0x7A00AB, 0x20D0201, 0x17004B, 0x1CB0207
	dc.w	0x200, 0x187, 0x100, 0x0, 0x100

	/* 256x192x8bpp, 60hz, VGA */
	/* uses 25Mhz clock */
sms_vga_ntsc_mode:
	dc.l	256,192,512,16,2,98304
	dc.l	0xC6008D, 0x150004, 0x6D0097, 0x41903FF, 0x3F009D, 0x39D0415
	dc.w	0x200, 0x186, 0x100, 0x5, 0x100


	/* 256x192x8bpp, 60hz, RGB */
	/* uses 25Mhz clock */
sms_rgb_pal_mode:
	dc.l	256,192,512,16,2,98304
	dc.l	0xC7009F, 0x1F0022, 0x7A00AB, 0x20D0201, 0x17004B, 0x1CB0207
	dc.w	0x200, 0x187, 0x100, 0x0, 0x100

	/* 256x192x8bpp, 50Hz, VGA */
	/* uses 25Mhz clock */
sms_vga_pal_mode:
	dc.l	256,192,512,16,2,98304
	dc.l	0xC6008D, 0x150004, 0x6D0097, 0x4EB04D1, 0x3F0105, 0x40504E7
	dc.w	0x200, 0x186, 0x100, 0x5,0x100

  	/* 256x192x8bpp, 60hz, RGB */
	/* uses 25Mhz clock */
gg_rgb_mode:
	dc.l	256,192,512,16,2,98304
	dc.l	0xC7009F, 0x1F0022, 0x7A00AB, 0x20D0201, 0x17004B, 0x1CB0207
	dc.w	0x200, 0x187, 0x100, 0x0, 0x100

	/* 256x192x8bpp, 60hz, VGA */
	/* uses 25Mhz bitclock */
gg_vga_mode:
	dc.l	256,192,512,16,2,98304
	dc.l	0xC6008D, 0x1502B9, 0x5A0097, 0x41903FF, 0x3F00A1, 0x3A10415
	dc.w	0x200, 0x186, 0x100, 0x5, 0x100


/*****************************************************************
*
* Interrupt routine (internal);
*
*/

	.text
	.even
	.ascii	"XBRA"
	.ascii	"SMSP"
	.comm	old_vbi,4

vbi:	/* handle frameskip counter */
	tstl	flipcntr
	beq	vbi_done

	subl	#1,flipcntr


vbi_done:	movel	old_vbi,-(sp)	/* jump through old vector */
	rts

/*****************************************************************
*
* void CloseDRIVER();
*
*/


_CloseVIDEL16:
	moveml	d0-d7/a0-a6,sp@-

	movel	#exit,-(sp)
	movew	#0x26,-(sp)
	trap	#14
	addl	#6,sp

	moveml	sp@+,d0-d7/a0-a6
	moveq	#0,d0		/* alles OK */
	rts

exit:	/* restore VBI */
	movew	#0x2700,sr
	movel	old_vbi,0x70
	movew	#0x2300,sr
	
	/* restore old videomode (stolen from DHS demosystem) */
	leal	save_video,a0			/* restore video */
	clrw	0xffff8266.w			/* falcon-shift clear */
	movel	(a0)+,0xffff8200.w			/* videobase_address:h&m */
	movew	(a0)+,0xffff820c.w			/* l */
	movel	(a0)+,0xffff8282.w			/* h-regs */
	movel	(a0)+,0xffff8286.w			
	movel	(a0)+,0xffff828a.w			
	movel	(a0)+,0xffff82a2.w			/* v-regs */
	movel	(a0)+,0xffff82a6.w			 
	movel	(a0)+,0xffff82aa.w			
	movew	(a0)+,0xffff82c0.w			/* vco */
	movew	(a0)+,0xffff82c2.w			/* c_s */
	movel	(a0)+,0xffff820e.w			/* offset */
	movew	(a0)+,0xffff820a.w			/* sync */
	moveb	(a0)+,0xffff8256.w			/* p_o */
	tstb	(a0)+   				/* st(e) comptaible mode? */
        	bnes	r_ok
	movel	a0,-(sp)				/* wait for vbl */
	movew	#37,-(sp)				/* to avoid syncerrors */
	trap	#14				/* in falcon monomodes */
	addql	#2,sp				
	moveal	(sp)+,a0				
	movew	(a0),0xffff8266.w			/* falcon-shift */
	bras	video_restored
r_ok:	movew	2(a0),0xffff8260.w			/* st-shift */
	leal	save_video,a0
	movew	32(a0),0xffff82c2.w			/* c_s */
	movel	34(a0),0xffff820e.w			/* offset	*/	
video_restored:
	leal	0xffff9800.w,a0			/* restore falcon palette */
	leal	save_pal,a1			
	movew	#256-1,d7				
rcloop:	movel	(a1)+,(a0)+			
	dbra	d7,rcloop			
	moveml	(a1),d0-d7			/* restore st palette */
	moveml	d0-d7,0xffff8240.w			

	/* release memory */

	movel	screen,-(sp)
	movew	#0x49,-(sp)
	trap	#1
	addql	#6,sp
	
	rts

/*****************************************************************
*
* UpdateDRIVER(frameskip);
*
*/

_UpdateVIDEL16:
	tstl	flipcntr
	bne	_UpdateVIDEL16

	movel	4(sp),flipcntr	/* reset to frameskip value */
	rts
	
/*****************************************************************
*
* PaletteDRIVER(source_pal);
*
*/

_PaletteVIDEL16:
	/* do nothing, no palette handling needed */
	rts


/*****************************************************************
*
* Misc. variables
*
*/
	
	.data
	.even
	.comm	flipcntr,4
	.comm	screen,4
	.comm	gamegear_flag,4
	.comm	bitmap_ptr,4
	.comm	screen_size,4

	.comm	save_pal,1056	/* saved Falcon + ST palette */
	.comm	save_video,46	/* saved videl & shifter settings */
