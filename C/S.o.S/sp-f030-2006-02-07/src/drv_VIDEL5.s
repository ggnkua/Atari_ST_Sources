/*
    Copyright (c) 2006 Peter Persson
    This code uses a C2P-routine originally written by Mikael Kalms
    
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
    2006-01-15	Created			(Peter Persson)
              	C2P rout by Mikael Kalms
    2006-02-04	Misc. updates		(Peter Persson)		
    2006-02-07	Major update		(Peter Persson)
    		Added PAL support (VGA only)
    		Video init/exit routs taken from DHS demosystem
    		Added initial support for GG-specific screenmodes
    		... which unfortunately can't be used yet due to some bug in SMS...
*/


	.text
	.globl	_OpenVIDEL5
	.globl	_CloseVIDEL5
	.globl	_UpdateVIDEL5
	.globl	_PaletteVIDEL5
	
/*****************************************************************
*
* void OpenDRIVER(bitmap_ptr);
*
*/

_OpenVIDEL5:
	movel	4(sp),gamegear_flag
	movel	8(sp),bitmap_ptr
	moveml	d1-d7/a0-a6,sp@-

	/* reserve chunky buffer in TT-RAM */	
	movew	#1,-(sp)		| TT-ram only
	movel	#50000,-(sp)	| Size of 1 * 256*192*8 + some extra bytes for alignment
	movew	#0x44,-(sp)
	trap	#1
	addql	#8,sp

	addl	#256,d0
	andl	#0xffffff00,d0	/* align the data */
	movel	d0,c2p_source

	/* reserve physical video memory in ST-RAM */	
	movew	#0,-(sp)		| ST-ram only
	movel	#100000,-(sp)	| Size of 2 * 256*192*8 + some extra bytes for alignment
	movew	#0x44,-(sp)
	trap	#1
	addql	#8,sp
	
	addl	#256,d0
	andl	#0xffffff00,d0	/* align the data */

	movel	d0,screen_1	| store screen1 ptr
	addl	#49152,d0		|
	movel	d0,screen_2	| store screen2 ptr

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
	movel	c2p_source,(a1)+	/* chunky screen for emulator */

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

	/* clear screens */
	movel	#24576,d0		/* clear 2 * 192*256*8 */
	movel	screen_1,a0
clear_lp:	movel	#0,(a0)+
	dbra d0,clear_lp

	/* set palette pointer to a sane value */
	movel	#save_pal,pal_ptr
	
	/* clear frameskip counter */
	movel	#0,flipcntr

	/* clear flip flag */
	movew	#0,flipflag

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
	dc.l	256,192,256,8,1,49152
	dc.l	0xC7009F, 0x1F0010, 0x6800AB, 0x20D0201, 0x17004B, 0x1CB0207
	dc.w	0x200, 0x187, 0x10, 0x0, 0x80

	/* 256x192x8bpp, 60hz, VGA */
	/* uses 25Mhz clock */
sms_vga_ntsc_mode:
	dc.l	256,192,256,8,1,49152
	dc.l	0xC6008D, 0x1502B9, 0x5A0097, 0x41903FF, 0x3F00A1, 0x3A10415
	dc.w	0x200, 0x186, 0x10, 0x5, 0x80
	
	/* 256x192x8bpp, 60hz, RGB */
	/* uses 25Mhz clock */
sms_rgb_pal_mode:
	dc.l	256,192,256,8,1,49152
	dc.l	0xC7009F, 0x1F0010, 0x6800AB, 0x20D0201, 0x17004B, 0x1CB0207
	dc.w	0x200, 0x187, 0x10, 0x0, 0x80

	/* 256x192x8bpp, 50hz, VGA */
	/* uses 25Mhz clock */
sms_vga_pal_mode:
	dc.l	256,192,256,8,1,49152
	dc.l	0xC6008D, 0x1502BA, 0x5B0097, 0x4EB04D1, 0x3F0105, 0x40504E7
	dc.w	0x200, 0x186, 0x10, 0x5, 0x80

	/* 256x192x8bpp, 60hz, RGB */
	/* uses 25Mhz clock */
gg_rgb_mode:
	dc.l	256,192,256,8,1,49152
	dc.l	0xC7009F, 0x1F0010, 0x6800AB, 0x20D0201, 0x17004B, 0x1CB0207
	dc.w	0x200, 0x187, 0x10, 0x0, 0x80

	/* 256x192x8bpp, 60hz, VGA */
	/* uses 25Mhz bitclock */
gg_vga_mode:
	dc.l	256,192,256,8,1,49152
	dc.l	0xC6008D, 0x1502B9, 0x5A0097, 0x41903FF, 0x3F00A1, 0x3A10415
	dc.w	0x200, 0x186, 0x10, 0x5, 0x80

	/* 160x144x8bpp, 60hz, VGA */
	/* uses 25Mhz bitclock */
	/* unfortunately this won't work yet due to some bug in SMS... */
	dc.l	160,144,160,8,1,23040
	dc.l	0xC6008D, 0x150022, 0x2B0097, 0x41903FF, 0x3F00FD, 0x33D0415
	dc.w	0x200, 0x186, 0x10, 0x5, 0x50

	
	
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
	
vbi:	moveml	d0-d7/a0-a6,vbi_saveregs

	/* handle frameskip counter */
	tstl	flipcntr
	beq	vbi_done

	subl	#1,flipcntr

	/* check if there is a new screen ready */

	tstw	flipflag
	beq	vbi_done
	movew	#0,flipflag

	/* swap screens and set new screen address */

	movel	screen_1,d0
	movel	screen_2,d1
	movel	d1,screen_1
	movel	d0,screen_2
	
	movel	d0,0xff8200	/* msb */
	movew	d0,0xff8203	/* middle byte */
	moveb	d0,0xff820D	/* lsb */ 

	/* set the new palette */

	moveq	#31,d0		/* we are using 32 palette entries */
	movel	#0xffff9800,a1
	movel	pal_ptr,a0

	moveq	#0,d3
ploop:	moveq	#0,d1
	moveq	#0,d2

	move.b	(a0)+,d1
	move.b	(a0)+,d2
	move.b	(a0)+,d3
	
	swap	d1		/* this code may look funny */
	lsl.l	#8,d1		/* I know that... */
	swap	d2
	
	orl	d1,d2
	orl	d3,d2	
	movel	d2,(a1)+

	dbra	d0,ploop


vbi_done:	moveml	vbi_saveregs,d0-d7/a0-a6

	movel	old_vbi,-(sp)	/* jump through old vector */
	rts

	
	.comm	vbi_saveregs,64

/*****************************************************************
*
* void CloseDRIVER();
*
*/

	.text
_CloseVIDEL5:
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

	/* release memory (physical screen) */
	movel	screen_1,-(sp)
	movew	#0x49,-(sp)
	trap	#1
	addql	#6,sp

	/* release memory (chunky buffer) */
	movel	c2p_source,-(sp)
	movew	#0x49,-(sp)
	trap	#1
	addql	#6,sp
	
	rts

/*****************************************************************
*
* UpdateDRIVER(frameskip);
*
*/

/* C2P routine by Kalms */

	.text
	
_UpdateVIDEL5:
	tstl	flipcntr
	bne	_UpdateVIDEL5
	
	moveml	d0-d7/a0-a6,sp@-

	movel	c2p_source,a0	/* chunky source */
	movel	screen_1,a1	/* destination */

	movel	a0,a2
	addl	screen_size,a2		/* size of SMS screen */
	
	moveq #14,d4

	movel (a0)+,d0
	movel (a0)+,d1
	movel (a0)+,d2
	movel (a0)+,d3

	and.l	#0x1f1f1f1f,d0
	and.l	#0x1f1f1f1f,d1
	and.l	#0x1f1f1f1f,d2
	and.l	#0x1f1f1f1f,d3


	/*; ------a4a3a2a1a0 ------b4b3b2b1b0 ------c4c3c2c1c0 ------d4d3d2d1d0
	  ; ------e4e3e2e1e0 ------f4f3f2f1f0 ------g4g3g2g1g0 ------h4h3h2h1h0
	  ; ------i4i3i2i1i0 ------j4j3j2j1j0 ------k4k3k2k1k0 ------l4l3l2l1l0
	  ; ------m4m3m2m1m0 ------n4n3n2n1n0 ------o4o3o2o1o0 ------p4p3p2p1p0
	*/
	
	movel d1,d6
	movel d3,d7
	lsrl #4,d6
	lsrl #4,d7
	eorl d0,d6
	eorl d2,d7
	andl #0x0f0f0f0f,d6
	andl #0x0f0f0f0f,d7
	eorl d6,d0
	eorl d7,d2
	lsll #4,d6
	lsll #4,d7
	eorl d6,d1
	eorl d7,d3

	/*; ------a4------e4 ------b4------f4 ------c4------g4 ------d4------h4
	  ; a3a2a1a0e3e2e1e0 b3b2b1b0f3f2f1f0 c3c2c1c0g3g2g1g0 d3d2d1d0h3h2h1h0
	  ; ------i4------m4 ------j4------n4 ------k4------o4 ------l4------p4
	  ; i3i2i1i0m3m2m1m0 j3j2j1j0n3n2n1n0 k3k2k1k0o3o2o1o0 l3l2l1l0p3p2p1p0
	*/
	
	movel d3,d5
	movel d0,d6
	lsrl #8,d5
	movel d2,d7
	eorl d1,d5
	lsrl d4,d0
	
	andl #0x00ff00ff,d5
	lsrl d4,d2
	eorl d5,d1
	orw d6,d0
	lsll #8,d5
	orw d7,d2
	eorl d5,d3

	
	/*; ---------------- ---------------- --a4--c4--e4--g4 --b4--d4--f4--h4
	  ; a3a2a1a0e3e2e1e0 i3i2i1i0m3m2m1m0 c3c2c1c0g3g2g1g0 k3k2k1k0o3o2o1o0
	  ; ---------------- ---------------- --i4--k4--m4--o4 --j4--l4--n4--p4
	  ; b3b2b1b0f3f2f1f0 j3j2j1j0n3n2n1n0 d3d2d1d0h3h2h1h0 l3l2l1l0p3p2p1p0
	*/

	move.b d0,d6
	movel d3,d7
	lslw #8,d6
	lsrl #1,d7
	move.b d2,d6
	eorl d1,d7
	lsrw #8,d2
	andl #0x55555555,d7
	move.b d2,d0
	eorl d7,d1
	addw d0,d0
	addl d7,d7
	orw d6,d0
	eorl d7,d3
	
	bra start

pix16:
	movel (a0)+,d0
	movel (a0)+,d1
	movel (a0)+,d2
	movel (a0)+,d3

	and.l	#0x1f1f1f1f,d0
	and.l	#0x1f1f1f1f,d1
	and.l	#0x1f1f1f1f,d2
	and.l	#0x1f1f1f1f,d3

	/*; ------a4a3a2a1a0 ------b4b3b2b1b0 ------c4c3c2c1c0 ------d4d3d2d1d0
	  ; ------e4e3e2e1e0 ------f4f3f2f1f0 ------g4g3g2g1g0 ------h4h3h2h1h0
	  ; ------i4i3i2i1i0 ------j4j3j2j1j0 ------k4k3k2k1k0 ------l4l3l2l1l0
	  ; ------m4m3m2m1m0 ------n4n3n2n1n0 ------o4o3o2o1o0 ------p4p3p2p1p0
	*/
	
	movel a4,(a1)+

	movel d1,d6
	movel d3,d7
	lsrl #4,d6
	lsrl #4,d7
	eorl d0,d6
	eorl d2,d7
	andl #0x0f0f0f0f,d6
	andl #0x0f0f0f0f,d7
	eorl d6,d0
	eorl d7,d2
	lsll #4,d6
	lsll #4,d7
	eorl d6,d1
	eorl d7,d3

	/*; ------a4------e4 ------b4------f4 ------c4------g4 ------d4------h4
	  ; a3a2a1a0e3e2e1e0 b3b2b1b0f3f2f1f0 c3c2c1c0g3g2g1g0 d3d2d1d0h3h2h1h0
	  ; ------i4------m4 ------j4------n4 ------k4------o4 ------l4------p4
	  ; i3i2i1i0m3m2m1m0 j3j2j1j0n3n2n1n0 k3k2k1k0o3o2o1o0 l3l2l1l0p3p2p1p0
	*/
	
	movel d3,d5
	movel d0,d6
	lsrl #8,d5
	movel d2,d7
	eorl d1,d5
	lsrl d4,d0
	
	movel a5,(a1)+

	andl #0x00ff00ff,d5
	lsrl d4,d2
	eorl d5,d1
	orw d6,d0
	lsll #8,d5
	orw d7,d2
	eorl d5,d3

	
	/*; ---------------- ---------------- --a4--c4--e4--g4 --b4--d4--f4--h4
	  ; a3a2a1a0e3e2e1e0 i3i2i1i0m3m2m1m0 c3c2c1c0g3g2g1g0 k3k2k1k0o3o2o1o0
	  ; ---------------- ---------------- --i4--k4--m4--o4 --j4--l4--n4--p4
	  ; b3b2b1b0f3f2f1f0 j3j2j1j0n3n2n1n0 d3d2d1d0h3h2h1h0 l3l2l1l0p3p2p1p0
	*/

	move.b d0,d6
	movel d3,d7
	lslw #8,d6
	lsrl #1,d7
	move.b d2,d6
	eorl d1,d7
	lsrw #8,d2
	andl #0x55555555,d7
	move.b d2,d0
	eorl d7,d1
	addw d0,d0
	addl d7,d7
	orw d6,d0
	eorl d7,d3

	movew a6,(a1)+
	addql #6,a1

	
	/*; ---------------- ---------------- a4b4c4d4e4f4g4h4 i4j4k4l4m4n4o4p4
	  ; a3b3a1b1e3f3e1f1 i3j3i1j1m3n3m1n1 c3d3c1d1g3h3g1h1 k3l3k1l1o3p3o1p1
	  ; ---------------- ---------------- ---------------- ----------------
	  ; a2b2a0b0e2f2e0f0 i2j2i0j0m2n2m0n0 c2d2c0d0g2h2g0h0 k2l2k0l0o2p2o0p0
	*/
start:
	movew	d3,d7
	movew	d1,d3
	swap	d3
	movew	d3,d1
	movew	d7,d3

	
	/*; ---------------- ---------------- a4b4c4d4e4f4g4h4 i4j4k4l4m4n4o4p4
	  ; a3b3a1b1e3f3e1f1 i3j3i1j1m3n3m1n1 a2b2a0b0e2f2e0f0 i2j2i0j0m2n2m0n0
	  ; ---------------- ---------------- ---------------- ----------------
	  ; c3d3c1d1g3h3g1h1 k3l3k1l1o3p3o1p1 c2d2c0d0g2h2g0h0 k2l2k0l0o2p2o0p0
	*/
	
	movel	d3,d7
	lsrl	#2,d7
	eorl	d1,d7
	andl	#0x33333333,d7
	eorl	d7,d1
	lsll	#2,d7
	eorl	d7,d3
	
	/*; ---------------- ---------------- a4b4c4d4e4f4g4h4 i4j4k4l4m4n4o4p4
	  ; a3b3c3d3e3f3g3h3 i3j3k3l3m3n3o3p3 a2b2c2d2e2f2g2h2 i2j2k2l2m2n2o2p2
	  ; ---------------- ---------------- ---------------- ----------------
	  ; a1b1c1d1e1f1g1h1 i1j1k1l1m1n1o1p1 a0b0c0d0e0f0g0h0 i0j0k0l0m0n0o0p0
	*/
	
	swap	d1
	swap	d3
	
	movew	d0,a6
	movel	d1,a5
	movel	d3,a4
	
	cmpl	a0,a2
	bne	pix16
	
	movel	a4,(a1)+
	movel	a5,(a1)+
	movew	a6,(a1)+

	moveml	sp@+,d0-d7/a0-a6

	movel	4(sp),flipcntr	/* reset to frameskip value */
	movew	#1,flipflag

	rts
	
/*****************************************************************
*
* PaletteDRIVER(source_pal);
*
*/

_PaletteVIDEL5:
	movel	4(sp),pal_ptr	/* just save pointer to palette & update it next VBL */
	rts




/*****************************************************************
*
* Misc. variables
*
*/
	
	.data
	.even
	.comm	flipcntr,4
	.comm	flipflag,2
	.comm	pal_ptr,4
	.comm	c2p_source,4
	.comm	screen_1,4
	.comm	screen_2,4
	.comm	gamegear_flag,4
	.comm	bitmap_ptr,4
	.comm	screen_size,4

	.comm	save_pal,1056	/* saved Falcon + ST palette */
	.comm	save_video,46	/* saved videl & shifter settings */


