		code

		xdef	_FalconLV_SaveVideo
		xdef	_FalconLV_RestoreVideo
		xdef	_FalconLV_SetFramebufferPointer
		xdef	_FalconLV_EnableLineDubling
		xdef	_FalconLV_SetPallette
		xdef	_FalconLV_SetPalletteRGBA
		xdef	_FalconLV_SetVideoMode
		xdef	_FalconLV_ChunkyToPlanes
		
		xdef	_dump_320x200x16bpp_vga
		xdef	_dump_320x200x8bpp_vga
		xdef	_dump_320x240x16bpp_vga
		xdef	_dump_320x240x8bpp_vga

		xdef	_dump_320x200x8bpp_tv
		xdef	_dump_320x240x8bpp_tv
 
;-----------------------------------------------------------------------	
; void FalconLV_SaveVideo()

_FalconLV_SaveVideo:
		movem.l	d0-d7/a0-a6,-(a7)

		lea.l	$ffff9800,a0		;save falcon palette
		lea.l	save_pal,a1		;
		move.w	#256-1,d7		;
.colloop:	move.l	(a0)+,(a1)+		;
		dbra	d7,.colloop		;
		movem.l	$ffff8240,d0-d7		;save st palette
		movem.l	d0-d7,(a1)		;

		lea.l	save_video,a0		;store videomode
		move.l	$ffff8200.w,(a0)+	;vidhm
		move.w	$ffff820c.w,(a0)+	;vidl
		move.l	$ffff8282.w,(a0)+	;h-regs
		move.l	$ffff8286.w,(a0)+	;
		move.l	$ffff828a.w,(a0)+	;
		move.l	$ffff82a2.w,(a0)+	;v-regs
		move.l	$ffff82a6.w,(a0)+	;
		move.l	$ffff82aa.w,(a0)+	;
		move.w	$ffff82c0.w,(a0)+	;vco
		move.w	$ffff82c2.w,(a0)+	;c_s
		move.l	$ffff820e.w,(a0)+	;offset
		move.w	$ffff820a.w,(a0)+	;sync
		move.b  $ffff8256.w,(a0)+	;p_o
		clr.b   (a0)			;test of st(e) or falcon mode
		cmp.w   #$b0,$ffff8282.w	;hht kleiner $b0?
		sle     (a0)+			;flag setzen
		move.w	$ffff8266.w,(a0)+	;f_s
		move.w	$ffff8260.w,(a0)+	;st_s

		movem.l	(sp)+,d0-d7/a0-a6

		rts
;-----------------------------------------------------------------------
; void FalconLV_RestoreVideo()
_FalconLV_RestoreVideo:
		movem.l	d0-d7/a0-a6,-(a7)
		lea.l	save_video,a0		;restore video
		clr.w   $ffff8266.w		;falcon-shift clear
		move.l	(a0)+,$ffff8200.w	;videobase_address:h&m
		move.w	(a0)+,$ffff820c.w	;l
		move.l	(a0)+,$ffff8282.w	;h-regs
		move.l	(a0)+,$ffff8286.w	;
		move.l	(a0)+,$ffff828a.w	;
		move.l	(a0)+,$ffff82a2.w	;v-regs
		move.l	(a0)+,$ffff82a6.w	;
		move.l	(a0)+,$ffff82aa.w	;
		move.w	(a0)+,$ffff82c0.w	;vco
		move.w	(a0)+,$ffff82c2.w	;c_s
		move.l	(a0)+,$ffff820e.w	;offset
		move.w	(a0)+,$ffff820a.w	;sync
	        move.b  (a0)+,$ffff8256.w	;p_o
	        tst.b   (a0)+   		;st(e) comptaible mode?
        	bne.s   .ok
		move.l	a0,-(sp)		;wait for vbl
		move.w	#37,-(sp)		;to avoid syncerrors
		trap	#14			;in falcon monomodes
		addq.l	#2,sp			;
		movea.l	(sp)+,a0		;
	       	move.w  (a0),$ffff8266.w	;falcon-shift
		bra.s	.video_restored
.ok:		move.w  2(a0),$ffff8260.w	;st-shift
		lea.l	save_video,a0
		move.w	32(a0),$ffff82c2.w	;c_s
		move.l	34(a0),$ffff820e.w	;offset		
.video_restored:

		lea.l	$ffff9800,a0		;restore falcon palette
		lea.l	save_pal,a1		;
		move.w	#256-1,d7		;
.loop2:		move.l	(a1)+,(a0)+		;
		dbra	d7,.loop2		;
		movem.l	(a1),d0-d7		;restore st palette
		movem.l	d0-d7,$ffff8240		;


		movem.l	(sp)+,d0-d7/a0-a6
		rts
;-----------------------------------------------------------------------
; void FalconLV_SetVideoMode(void* p_VidelRegsDump)
slide1	=	15*4+4
_FalconLV_SetVideoMode:
		movem.l	d0-d7/a0-a6,-(a7)

		move.l	slide1(sp),a0

		;move.b	(a0)+,$ffff8201.w		; Vid‚o (poids fort)
		;move.b	(a0)+,$ffff8203.w		; Vid‚o (poids moyen)
		;move.b	(a0)+,$ffff820d.w		; Vid‚o (poids faible)
		addq.l	#4,a0
		
;		move.b	(a0)+,$ffff820a.w		; Synchronisation vid‚o
		move.w	(a0)+,$ffff820e.w		; Offset pour prochaine ligne
		move.w	(a0)+,$ffff8210.w		; Largeur d'une ligne en mots
		move.b	(a0)+,d0				; R‚solution ST
		move.b	(a0)+,$ffff8265.w		; D‚calage Pixel
		move.w	(a0)+,d1				; R‚solution Falcon

		move.w	d1,$ffff8266.w			; Fixe R‚solution Falcon

No_STRez2:	move.w	(a0)+,$ffff8282.w		; HHT-Synchro
		move.w	(a0)+,$ffff8284.w		; Fin Bordure Droite
		move.w	(a0)+,$ffff8286.w		; D‚but Bordure Gauche
		move.w	(a0)+,$ffff8288.w		; D‚but Ligne
		move.w	(a0)+,$ffff828a.w		; Fin Ligne
		move.w	(a0)+,$ffff828c.w		; HSS-Synchro
		move.w	(a0)+,$ffff828e.w		; HFS ???
		move.w	(a0)+,$ffff8290.w		; HEE ???
		move.w	(a0)+,$ffff82a2.w		; VFT-Synchro
		move.w	(a0)+,$ffff82a4.w		; Fin Bordure Basse
		move.w	(a0)+,$ffff82a6.w		; D‚but Bordure Haute
		move.w	(a0)+,$ffff82a8.w		; D‚but Image
		move.w	(a0)+,$ffff82aa.w		; Fin Image
		move.w	(a0)+,$ffff82ac.w		; VSS-Synchro
		move.w	(a0)+,$ffff82c0.w		; Reconnaissance ST/Falcon
		move.w	(a0)+,$ffff82c2.w		; Informations r‚solution
		movem.l	(sp)+,d0-d7/a0-a6

		rts

;-----------------------------------------------------------------------
; void FalconLV_SetFramebufferPointer(void* p_FalconScreenBuffer)

_FalconLV_SetFramebufferPointer:
	    move.l	4(sp),d0
		move.l	d0,d1
	    lsr.w 	#8,d0
		move.w	sr,-(sp)
		ori		#$700,sr
        move.l 	d0,$ffff8200.w
        move.b	d1,$ffff820d.w
		move.w	(sp)+,sr
		rts	

;-----------------------------------------------------------------------
; void FalconLV_EnableLineDubling()

_FalconLV_EnableLineDubling:
		or.w	#1,$ffff82c2.w
		rts	
;-----------------------------------------------------------------------
; void FalconLV_SetPallette(unsigned int* p_FalconPalette, unsigned long numEntries )

			rsreset
			rs.l	3		// registers
			rs.l	1		// return address
_pPalette	rs.l	1		// palette pointer
_numEntries	rs.l	1		// number of colors

			align 4
_FalconLV_SetPallette:
			movem.l	d0/a0-a1,-(sp)
			move.l	_pPalette(sp),a0
			move.l	_numEntries(sp),d0
			lea.l	$ffff9800.w,a1	
			subq.w	#1,d0
.copy:		move.l	(a0)+,(a1)+			
			dbra		d0,.copy	

			movem.l	(sp)+,d0/a0-a1
			rts
			
;-----------------------------------------------------------------------
; void FalconLV_SetPalletteRGBA(unsigned int* p_FalconPalette, unsigned long numEntries )

			rsreset
			rs.l	4		// registers
			rs.l	1		// return address
_pPalette2	rs.l	1		// palette pointer
_numEntries2	rs.l	1		// number of colors

			align 4
_FalconLV_SetPalletteRGBA:
			movem.l	d0-d1/a0-a1,-(sp)		
			move.l	_pPalette2(sp),a0
			move.l	_numEntries2(sp),d1
			lea.l	$ffff9800.w,a1	
			subq.w	#1,d1
.copy2:		
			move.l	(a0)+,d0
			rol.w	#8,d0
			and.l	#$ffff00ff,d0
			move.l	d0,(a1)+			
			dbf		d1,.copy2	

			movem.l	(sp)+,d0-d1/a0-a1
			rts			
			
;-----------------------------------------------------------------------

	; in	a0	chunky
	;	a1	screen

				rsreset
				rs.l	15		// registers
				rs.l	1		// return address
_pSource		rs.l	1		// source buffer
_pDestination	rs.l	1		// dest buffer
_numPixels		rs.l	1		// num pixels
	
_FalconLV_ChunkyToPlanes:
	movem.l	d0-d7/a0-a6,-(sp)
	move.l	_pSource(sp),a0
	move.l	_pDestination(sp),a1
	move.l	a0,a2
	add.l	_numPixels(sp),a2
	move.l	#$0f0f0f0f,d4
	move.l	#$00ff00ff,d5
	move.l	#$55555555,d6

	move.l	(a0)+,d0
	move.l	(a0)+,d1
	move.l	(a0)+,d2
	move.l	(a0)+,d3

	; a7a6a5a4a3a2a1a0 b7b6b5b4b3b2b1b0 c7c6c5c4c3c2c1c0 d7d6d5d4d3d2d1d0
	; e7e6e5e4e3e2e1e0 f7f6f5f4f3f2f1f0 g7g6g5g4g3g2g1g0 h7h6h5h4h3h2h1h0
	; i7i6i5i4i3i2i1i0 j7j6j5j4j3j2j1j0 k7k6k5k4k3k2k1k0 l7l6l5l4l3l2l1l0
	; m7m6m5m4m3m2m1m0 n7n6n5n4n3n2n1n0 o7o6o5o4o3o2o1o0 p7p6p5p4p3p2p1p0

	move.l	d1,d7
	lsr.l	#4,d7
	eor.l	d0,d7
	and.l	d4,d7
	eor.l	d7,d0
	lsl.l	#4,d7
	eor.l	d7,d1
	move.l	d3,d7
	lsr.l	#4,d7
	eor.l	d2,d7
	and.l	d4,d7
	eor.l	d7,d2
	lsl.l	#4,d7
	eor.l	d7,d3

	; a7a6a5a4e7e6e5e4 b7b6b5b4f7f6f5f4 c7c6c5c4g7g6g5g4 d7d6d5d4h7h6h5h4
	; a3a2a1a0e3e2e1e0 b3b2b1b0f3f2f1f0 c3c2c1c0g3g2g1g0 d3d2d1d0h3h2h1h0
	; i7i6i5i4m7m6m5m4 j7j6j5j4n7n6n5n4 k7k6k5k4o7o6o5o4 l7l6l5l4p7p6p5p4
	; i3i2i1i0m3m2m1m0 j3j2j1j0n3n2n1n0 k3k2k1k0o3o2o1o0 l3l2l1l0p3p2p1p0

	move.l	d2,d7
	lsr.l	#8,d7
	eor.l	d0,d7
	and.l	d5,d7
	eor.l	d7,d0
	lsl.l	#8,d7
	eor.l	d7,d2
	move.l	d3,d7
	lsr.l	#8,d7
	eor.l	d1,d7
	and.l	d5,d7
	eor.l	d7,d1
	lsl.l	#8,d7
	eor.l	d7,d3
	
	; a7a6a5a4e7e6e5e4 i7i6i5i4m7m6m5m4 c7c6c5c4g7g6g5g4 k7k6k5k4o7o6o5o4
	; a3a2a1a0e3e2e1e0 i3i2i1i0m3m2m1m0 c3c2c1c0g3g2g1g0 k3k2k1k0o3o2o1o0
	; b7b6b5b4f7f6f5f4 j7j6j5j4n7n6n5n4 d7d6d5d4h7h6h5h4 l7l6l5l4p7p6p5p4
	; b3b2b1b0f3f2f1f0 j3j2j1j0n3n2n1n0 d3d2d1d0h3h2h1h0 l3l2l1l0p3p2p1p0

	bra.s	.start
.pix16:	
	move.l	(a0)+,d0
	move.l	(a0)+,d1
	move.l	(a0)+,d2
	move.l	(a0)+,d3

	; a7a6a5a4a3a2a1a0 b7b6b5b4b3b2b1b0 c7c6c5c4c3c2c1c0 d7d6d5d4d3d2d1d0
	; e7e6e5e4e3e2e1e0 f7f6f5f4f3f2f1f0 g7g6g5g4g3g2g1g0 h7h6h5h4h3h2h1h0
	; i7i6i5i4i3i2i1i0 j7j6j5j4j3j2j1j0 k7k6k5k4k3k2k1k0 l7l6l5l4l3l2l1l0
	; m7m6m5m4m3m2m1m0 n7n6n5n4n3n2n1n0 o7o6o5o4o3o2o1o0 p7p6p5p4p3p2p1p0

	move.l	d1,d7
	lsr.l	#4,d7
	move.l	a3,(a1)+
	eor.l	d0,d7
	and.l	d4,d7
	eor.l	d7,d0
	lsl.l	#4,d7
	eor.l	d7,d1
	move.l	d3,d7
	lsr.l	#4,d7
	eor.l	d2,d7
	and.l	d4,d7
	eor.l	d7,d2
	move.l	a4,(a1)+
	lsl.l	#4,d7
	eor.l	d7,d3

	; a7a6a5a4e7e6e5e4 b7b6b5b4f7f6f5f4 c7c6c5c4g7g6g5g4 d7d6d5d4h7h6h5h4
	; a3a2a1a0e3e2e1e0 b3b2b1b0f3f2f1f0 c3c2c1c0g3g2g1g0 d3d2d1d0h3h2h1h0
	; i7i6i5i4m7m6m5m4 j7j6j5j4n7n6n5n4 k7k6k5k4o7o6o5o4 l7l6l5l4p7p6p5p4
	; i3i2i1i0m3m2m1m0 j3j2j1j0n3n2n1n0 k3k2k1k0o3o2o1o0 l3l2l1l0p3p2p1p0

	move.l	d2,d7
	lsr.l	#8,d7
	eor.l	d0,d7
	and.l	d5,d7
	eor.l	d7,d0
	move.l	a5,(a1)+
	lsl.l	#8,d7
	eor.l	d7,d2
	move.l	d3,d7
	lsr.l	#8,d7
	eor.l	d1,d7
	and.l	d5,d7
	eor.l	d7,d1
	move.l	a6,(a1)+
	lsl.l	#8,d7
	eor.l	d7,d3
	
	; a7a6a5a4e7e6e5e4 i7i6i5i4m7m6m5m4 c7c6c5c4g7g6g5g4 k7k6k5k4o7o6o5o4
	; a3a2a1a0e3e2e1e0 i3i2i1i0m3m2m1m0 c3c2c1c0g3g2g1g0 k3k2k1k0o3o2o1o0
	; b7b6b5b4f7f6f5f4 j7j6j5j4n7n6n5n4 d7d6d5d4h7h6h5h4 l7l6l5l4p7p6p5p4
	; b3b2b1b0f3f2f1f0 j3j2j1j0n3n2n1n0 d3d2d1d0h3h2h1h0 l3l2l1l0p3p2p1p0
.start
	move.l	d2,d7
	lsr.l	#1,d7
	eor.l	d0,d7
	and.l	d6,d7
	eor.l	d7,d0
	add.l	d7,d7
	eor.l	d7,d2
	move.l	d3,d7
	lsr.l	#1,d7
	eor.l	d1,d7
	and.l	d6,d7
	eor.l	d7,d1
	add.l	d7,d7
	eor.l	d7,d3

	; a7b7a5b5e7f7e5f5 i7j7i5j5m7n7m5n5 c7d7c5d5g7h7g5h5 k7l7k5l5o7p7o5p5
	; a3b3a1b1e3f3e1f1 i3j3i1j1m3n3m1n1 c3d3c1d1g3h3g1h1 k3l3k1l1o3p3o1p1
	; a6b6a4b4e6f6e4f4 i6j6i4j4m6n6m4n4 c6d6c4d4g6h6g4h4 k6l6k4l4o6p6o4p4
	; a2b2a0b0e2f2e0f0 i2j2i0j0m2n2m0n0 c2d2c0d0g2h2g0h0 k2l2k0l0o2p2o0p0

	move.w	d2,d7
	move.w	d0,d2
	swap	d2
	move.w	d2,d0
	move.w	d7,d2
	move.w	d3,d7
	move.w	d1,d3
	swap	d3
	move.w	d3,d1
	move.w	d7,d3

	; a7b7a5b5e7f7e5f5 i7j7i5j5m7n7m5n5 a6b6a4b4e6f6e4f4 i6j6i4j4m6n6m4n4
	; a3b3a1b1e3f3e1f1 i3j3i1j1m3n3m1n1 a2b2a0b0e2f2e0f0 i2j2i0j0m2n2m0n0
	; c7d7c5d5g7h7g5h5 k7l7k5l5o7p7o5p5 c6d6c4d4g6h6g4h4 k6l6k4l4o6p6o4p4
	; c3d3c1d1g3h3g1h1 k3l3k1l1o3p3o1p1 c2d2c0d0g2h2g0h0 k2l2k0l0o2p2o0p0

	move.l	d2,d7
	lsr.l	#2,d7
	eor.l	d0,d7
	and.l	#$33333333,d7
	eor.l	d7,d0
	lsl.l	#2,d7
	eor.l	d7,d2
	move.l	d3,d7
	lsr.l	#2,d7
	eor.l	d1,d7
	and.l	#$33333333,d7
	eor.l	d7,d1
	lsl.l	#2,d7
	eor.l	d7,d3

	; a7b7c7d7e7f7g7h7 i7j7k7l7m7n7o7p7 a6b6c6d6e6f6g6h6 i6j6k6l6m6n6o6p6
	; a3b3c3d3e3f3g3h3 i3j3k3l3m3n3o3p3 a2b2c2d2e2f2g2h2 i2j2k2l2m2n2o2p2
	; a5b5c5d5e5f5g5h5 i5j5k5l5m5n5o5p5 a4b4c4d4e4f4g4h4 i4j4k4l4m4n4o4p4
	; a1b1c1d1e1f1g1h1 i1j1k1l1m1n1o1p1 a0b0c0d0e0f0g0h0 i0j0k0l0m0n0o0p0

	swap	d0
	swap	d1
	swap	d2
	swap	d3

	move.l	d0,a6
	move.l	d2,a5
	move.l	d1,a4
	move.l	d3,a3

	cmp.l	a0,a2
	bne		.pix16

	move.l	a3,(a1)+
	move.l	a4,(a1)+
	move.l	a5,(a1)+
	move.l	a6,(a1)+
	
	movem.l	(sp)+,d0-d7/a0-a6
	rts


;-----------------------------------------------------------------------
	section data
_dump_320x200x16bpp_vga: 	incbin "320x200x16bpp_vga.videl"
_dump_320x200x8bpp_vga:		incbin "320x200x8bpp_vga.videl"
_dump_320x240x16bpp_vga:	incbin "320x240x16bpp_vga.videl"
_dump_320x240x8bpp_vga:		incbin "320x240x8bpp_vga.videl"

_dump_320x200x8bpp_tv:		incbin "320x200x8bpp_tv.videl"
_dump_320x240x8bpp_tv:		incbin "320x240x8bpp_tv.videl"

			bss
save_video:	ds.b	32+12+2			;videl save
save_pal:	ds.l	256+8			;palette save
		

			end