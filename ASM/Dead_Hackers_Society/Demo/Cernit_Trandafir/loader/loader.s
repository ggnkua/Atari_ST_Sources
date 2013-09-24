; loader for music sample file
; floppy version does force media change and should autodetect when the user changes disk
; 

		section	text

loader:

		;syncfix
		bsr.w	xbios_vsync
		ifeq	hatari
		move.b	#1,$ffff8260.w			;medres
		endc
		bsr.w	xbios_vsync
		bsr.w	xbios_vsync
		ifeq	hatari
		move.b	#0,$ffff8260.w			;lowres
		endc

		
		lea.l	loader_gfx_ice,a0
		lea.l	loader_gfx,a1
		jsr	ice

		;bsr.w	loader_loading
		bsr.w	loader_fadein

		
.load:		clr.w	-(sp)					;fsfirst() get fileinfo
		pea	music_filename				;
		move.w	#$4e,-(sp)				;
		trap	#1					;
		addq.l	#8,sp					;

		tst.l	d0					;
		beq.s	.ok					;ok

		ifne	floppy
		bsr.w	loader_insert_disk_2			;

		move.w	#25-1,.count				;wait 0.5 sec between each try
.vsync:		bsr.w	xbios_vsync
		subq.w	#1,.count
		bpl.s	.vsync
		bsr.w	mediach
		
		bra.s	.load
		else
		bra.w	exit
		endc

.ok:

		bsr.w	loader_loading

		move.w	#25-1,.count				;wait 1.0 sec
.vsync2:	bsr.w	xbios_vsync
		subq.w	#1,.count
		bpl.s	.vsync2

		clr.w	-(sp)					;open file read only
		pea	music_filename				;address to filename
		move.w	#$3d,-(sp)				;
		trap	#1					;
		addq.l	#8,sp					;
		move.w	d0,.filenumber				;store filenumber
 
		pea	music_sample				;buffer address
		move.l	#music_size,-(sp)			;length of file
		move.w	.filenumber,-(sp)			;filenumber
		move.w	#$3f,-(sp)				;
		trap	#1					;
		lea.l	12(sp),sp				;

		move.w	.filenumber,-(sp)			;filenumber for closing
		move.w	#$3e,-(sp)				;
		trap	#1					;
		addq.l	#4,sp					;

		bsr.w	loader_fadeout

		rts
.filenumber:	dc.w	0
.count:		dc.w	0

loader_loading:
		move.l	screen_adr,a0
		lea.l	160*85(a0),a0
		lea.l	loader_gfx+320*30/4,a1
		move.w	#320*30/16-1,d7
.copy:		move.l	(a1)+,(a0)
		addq.l	#8,a0
		dbra	d7,.copy
		rts

loader_insert_disk_2:
		move.l	screen_adr,a0
		lea.l	160*85(a0),a0
		lea.l	loader_gfx,a1
		move.w	#320*30/16-1,d7
.copy:		move.l	(a1)+,(a0)
		addq.l	#8,a0
		dbra	d7,.copy
		rts
		
		
		include	'loader/mediach.s'


loader_fadein:	bsr.w	xbios_vsync
		movem.l	loader_black,d0-d7
		movem.l	d0-d7,$ffff8240.w
		lea.l	loader_black,a0
		lea.l	loader_pal,a1
		jsr	component_fade
		subq.w	#1,.steps
		bpl.s	loader_fadein
		rts
.steps:		dc.w	50

loader_fadeout:	bsr.w	xbios_vsync
		movem.l	loader_black,d0-d7
		movem.l	d0-d7,$ffff8240.w
		lea.l	loader_black,a0
		lea.l	loader_black2,a1
		jsr	component_fade
		subq.w	#1,.steps
		bpl.s	loader_fadeout
		rts
.steps:		dc.w	50

		section	data

loader_black:	dcb.w	16,$0000
loader_black2:	dcb.w	16,$0000
loader_pal:	dc.w	$0fff,$0555,$0333,$0222
		dcb.w	12,$0000

loader_gfx_ice:	incbin	'loader/text.ice'
		even

		section	text
