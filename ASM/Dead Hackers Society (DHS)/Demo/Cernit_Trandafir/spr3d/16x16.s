; Blitter sprite routine
; 16x16 sprites including shift, mask and clear

		section	text

spr3d_genmask16:
		lea.l	spr3d_sprites+0,a0	;spr16_4pl,a0
		lea.l	spr3d_masks+0,a1	;mask16_4pl,a1
		lea.l	spr3d_sprites+5120,a2	;spr16_2pl,a2
		lea.l	spr3d_masks+5120,a3	;mask16_2pl,a3
		move.w	#32*16/16-1,d7
.mask:		moveq.l	#0,d0
		or.w	(a0)+,d0
		or.w	(a0)+,d0
		or.w	(a0)+,d0
		or.w	(a0)+,d0
		not.w	d0
		move.w	d0,(a1)+
		move.w	d0,(a1)+
		move.w	d0,(a1)+
		move.w	d0,(a1)+

		moveq.l	#0,d0
		or.w	(a2)+,d0
		or.w	(a2)+,d0
		not.w	d0
		move.w	d0,(a3)+
		move.w	d0,(a3)+

		dbra	d7,.mask
		rts

spr3d_blit16_4pl:
;16x16 blitter sprite with mask and shift
;d0.w	xpos signed
;d1.w	ypos signed

		cmp.w	#168,d0
		bgt.w	.no
		cmp.w	#-168,d0
		blt.w	.no

		cmp.w	#108,d1
		bgt.w	.no
		cmp.w	#-108,d1
		blt.w	.no
		
		subq.w	#8,d0							;center sprite
		move.l	screen_adr,a0
		lea.l	192*65+192*(100-8)+160/2(a0),a0				;center screen
		lea.l	spr3d_multab192+170*2,a1				;multab192
		asl.w	#1,d1							;
		add.w	(a1,d1.w),a0						;Y-position
		
		move.l	d0,d2
		and.w	#$000f,d0						;x-shift
		and.w	#$fff0,d2
		asr.w	#1,d2							;x-position
		add.w	d2,a0							;
		move.b	d0,$ffff8a3d.w						;Shift

		lea.l	spr3d_endmask1,a6					;leftmost endmask to erase trash graphics after shift
		lsl.w	#1,d0							;
		move.w	(a6,d0.w),d0						;
		move.w	d0,$ffff8a28.w						;Endmask 1, applied to every first word in a row
		move.w	#-1,$ffff8a2a.w						;Endmask 2, applied to every word between this and next
		move.w	#-1,$ffff8a2c.w						;Endmask 3, applited to every last word in a row

		move.w	#2,$ffff8a36.w						;Number of words to copy per row
		move.w	#8,$ffff8a20.w						;Source X-inc, bytes to skip after each read word
		move.w	#8,$ffff8a22.w						;Source Y-inc, bytes to skip after each read row
		move.w	#8,$ffff8a2e.w						;Destination X-inc, bytes to skip after each written word
		move.w	#192-8,$ffff8a30.w					;Destination Y-inc, bytes to skip after each written row
		move.b	#%00000010,$ffff8a3a.w					;Halftone operation
		;and mask
		;move.l	#spr3d_mask16_4pl,d0
		move.l	#spr3d_masks+0,d0
		move.l	a0,d1
		move.b	#%00000001,$ffff8a3b.w					;Logic operation (AND)
		rept	4
		move.l	d0,$ffff8a24.w						;Source address
		move.l	d1,$ffff8a32.w						;Destination address
		move.w	#16,$ffff8a38.w						;Number of rows to copy
		move.b	#%11000000,$ffff8a3c.w					;Start blitter
		addq.l	#2,d0
		addq.l	#2,d1
		endr
		;or graphics
		;move.l	#spr3d_spr16_4pl,d0
		move.l	#spr3d_sprites+0,d0
		move.l	a0,d1
		move.b	#%00000111,$ffff8a3b.w					;Logic operation (OR)
		rept	4
		move.l	d0,$ffff8a24.w						;Source address
		move.l	d1,$ffff8a32.w						;Destination address
		move.w	#16,$ffff8a38.w						;Number of rows to copy
		move.b	#%11000000,$ffff8a3c.w					;Start blitter
		addq.l	#2,d0
		addq.l	#2,d1
		endr

.no:		rts


spr3d_blit16_2pl:
;16x16 blitter sprite with mask and shift
;d0.w	xpos signed
;d1.w	ypos signed

		cmp.w	#168,d0
		bgt.w	.no
		cmp.w	#-168,d0
		blt.w	.no

		cmp.w	#108,d1
		bgt.w	.no
		cmp.w	#-108,d1
		blt.w	.no
		
		subq.w	#8,d0							;center sprite
		move.l	screen_adr,a0
		lea.l	192*65+192*(100-8)+160/2+4(a0),a0			;center screen
		lea.l	spr3d_multab192+170*2,a1				;multab192
		asl.w	#1,d1							;
		add.w	(a1,d1.w),a0						;Y-position
		
		move.l	d0,d2
		and.w	#$000f,d0						;x-shift
		and.w	#$fff0,d2
		asr.w	#1,d2							;x-position
		add.w	d2,a0							;
		move.b	d0,$ffff8a3d.w						;Shift

		lea.l	spr3d_endmask1,a6					;leftmost endmask to erase trash graphics after shift
		lsl.w	#1,d0							;
		move.w	(a6,d0.w),d0						;
		move.w	d0,$ffff8a28.w						;Endmask 1, applied to every first word in a row
		move.w	#-1,$ffff8a2a.w						;Endmask 2, applied to every word between this and next
		move.w	#-1,$ffff8a2c.w						;Endmask 3, applited to every last word in a row

		move.w	#2,$ffff8a36.w						;Number of words to copy per row
		move.w	#4,$ffff8a20.w						;Source X-inc, bytes to skip after each read word
		move.w	#4,$ffff8a22.w						;Source Y-inc, bytes to skip after each read row
		move.w	#8,$ffff8a2e.w						;Destination X-inc, bytes to skip after each written word
		move.w	#192-8,$ffff8a30.w					;Destination Y-inc, bytes to skip after each written row
		move.b	#%00000010,$ffff8a3a.w					;Halftone operation
		;and mask
		;move.l	#spr3d_mask16_2pl,d0
		move.l	#spr3d_masks+5120,d0
		move.l	a0,d1
		move.b	#%00000001,$ffff8a3b.w					;Logic operation (AND)
		rept	2
		move.l	d0,$ffff8a24.w						;Source address
		move.l	d1,$ffff8a32.w						;Destination address
		move.w	#16,$ffff8a38.w						;Number of rows to copy
		move.b	#%11000000,$ffff8a3c.w					;Start blitter
		addq.l	#2,d0
		addq.l	#2,d1
		endr
		;or graphics
		;move.l	#spr3d_spr16_2pl,d0
		move.l	#spr3d_sprites+5120,d0
		move.l	a0,d1
		move.b	#%00000111,$ffff8a3b.w					;Logic operation (OR)
		rept	2
		move.l	d0,$ffff8a24.w						;Source address
		move.l	d1,$ffff8a32.w						;Destination address
		move.w	#16,$ffff8a38.w						;Number of rows to copy
		move.b	#%11000000,$ffff8a3c.w					;Start blitter
		addq.l	#2,d0
		addq.l	#2,d1
		endr

.no:		rts


spr3d_clr16_4pl:
;16x16 blitter sprite clear
;d0.w	xpos signed
;d1.w	ypos signed

		cmp.w	#168,d0
		bgt.w	.no
		cmp.w	#-168,d0
		blt.w	.no

		cmp.w	#108,d1
		bgt.w	.no
		cmp.w	#-108,d1
		blt.w	.no
		
		subq.w	#8,d0							;center clr
		move.l	screen_adr,a0
		lea.l	192*65+192*(100-8)+160/2(a0),a0				;center screen
		lea.l	spr3d_multab192+170*2,a1				;multab192
		asl.w	#1,d1							;
		add.w	(a1,d1.w),a0						;Y-position
		and.w	#$fff0,d0
		asr.w	#1,d0							;x-position
		add.w	d0,a0							;
		clr.b	$ffff8a3d.w						;Shift
		move.w	#8,$ffff8a36.w						;Number of words to copy per row
		move.w	#2,$ffff8a2e.w						;Destination X-inc, bytes to skip after each written word
		move.w	#192-14,$ffff8a30.w					;Destination Y-inc, bytes to skip after each written row
		move.b	#%00000001,$ffff8a3a.w					;Halftone operation
		move.w	#-1,$ffff8a28.w						;Endmask 1, applied to every first word in a row
		move.w	#-1,$ffff8a2a.w						;Endmask 2, applied to every word between this and next
		move.w	#-1,$ffff8a2c.w						;Endmask 3, applited to every last word in a row
		;clear
		move.b	#%00000000,$ffff8a3b.w					;Logic operation (clear)
		move.l	a0,$ffff8a32.w						;Destination address
		move.w	#16,$ffff8a38.w						;Number of rows to copy
		move.b	#%11000000,$ffff8a3c.w					;Start blitter
.no:		rts


spr3d_clr16_2pl:
;16x16 blitter sprite clear
;d0.w	xpos signed
;d1.w	ypos signed

		cmp.w	#168,d0
		bgt.w	.no
		cmp.w	#-168,d0
		blt.w	.no

		cmp.w	#108,d1
		bgt.w	.no
		cmp.w	#-108,d1
		blt.w	.no
		
		subq.w	#8,d0							;center clr
		move.l	screen_adr,a0
		lea.l	192*65+192*(100-8)+160/2+4(a0),a0			;center screen
		lea.l	spr3d_multab192+170*2,a1				;multab192
		asl.w	#1,d1							;
		add.w	(a1,d1.w),a0						;Y-position
		and.w	#$fff0,d0
		asr.w	#1,d0							;x-position
		add.w	d0,a0							;
		clr.b	$ffff8a3d.w						;Shift
		move.w	#2,$ffff8a36.w						;Number of words to copy per row
		move.w	#8,$ffff8a2e.w						;Destination X-inc, bytes to skip after each written word
		move.w	#192-8,$ffff8a30.w					;Destination Y-inc, bytes to skip after each written row
		move.b	#%00000001,$ffff8a3a.w					;Halftone operation
		move.w	#-1,$ffff8a28.w						;Endmask 1, applied to every first word in a row
		move.w	#-1,$ffff8a2a.w						;Endmask 2, applied to every word between this and next
		move.w	#-1,$ffff8a2c.w						;Endmask 3, applited to every last word in a row
		;clear
		move.b	#%00000000,$ffff8a3b.w					;Logic operation (clear)
		rept	2
		move.l	a0,$ffff8a32.w						;Destination address
		move.w	#16,$ffff8a38.w						;Number of rows to copy
		move.b	#%11000000,$ffff8a3c.w					;Start blitter
		addq.l	#2,a0
		endr
		
.no:		rts

		ifne	0
		section	data

spr3d_spr16_4pl:	incbin	'spr3d/spr16.4pl'
			even

spr3d_spr16_2pl:	incbin	'spr3d/spr16.2pl'
			even
		endc

		section	text
