;  ___________     ______   ______    ____________
; !           \   !      ! !      !  /           /
; ! !    _     \  ! !    !_!      ! / /  _______/
; ! !   ! \     \ ! !             ! \ \         \
; !     !_/   / / !       _     ! !  \_______  \ \
; !          / /  !      ! !    ! !  /         / /
; !___________/   !______! !______! /___________/
;                  /|     &   /\
;                 /_|        /__
;                /  |ssem   ___/oft
;
; GemDemo - Atari and compatibles.
;
; File: bump.s
; Desc: Bumpmapping module (demofx)
; Edit: June 8, 1998 - 02.20 CET
; Info: Bumpmapping code by Evil/Dead Hackers Society,
;       GEM coding by Ozk/AssemSoft.
;       Tablength = 16

	output .dmo
	opt p=68030
	
bm_xres:	equ 144
bm_yres:	equ 85

	include	demo_bss.h	;Containing the demo-parameter-block/demo_init stucture
	
	section text

; --------------------------------------------------------------
; ------------- Bumpmapper INIT --------------------------------
; --------------------------------------------------------------

		clr.w	-(sp)		;In case someone tries to start it standalone...
		trap	#1		;

		dc.b 'GEM Demo Executable',0		;This is the ID that the shell checks to make sure the file is of the correct format.
	

	; A3 = demoes paramter block
	; A4 = Demo init block
bump_init:	movem.l	d0-a6,-(sp)

		move.l	d_texture(a3),d0			;Get address of texture
		bne	.alloced				;Not NULL = already installed

		move.l	#256*256*4,d0				;Mem for the double buffering.
		moveq	#3,d1					;Preferably TT, but any mem OK
		move.l	di_memalloc(a4),a5			;Address of mem alloc routine
		jsr	(a5)					;Get the memory
		beq	.no_mem					;Error if equal

		clr.w	d_zoom(a3)				;Clear both the flag and the reserved byte
		move.l	#bump_init,d_init(a3)			;The initializating routine
		move.l	#bumpmapper,d_rout(a3)			;The plot routine
		move.l	d_rout(a3),d_rout1x(a3)
		move.l	#bumpmapper2,d_rout2x(a3)
		move.l	#bumpmapper3,d_rout4x(a3)
	
		move.l	#bumpmapper_50hz,d_50hz(a3)		;The 50Hz routine
		move.l	#(bm_xres<<16)+bm_yres,d_xres(a3)	;X & Y resolution of this screen
		move.l	d0,d_texture(a3)			;Address of texture, D0 contains the address of allocated mem
		move.l	#256*256*4,d_texturesize(a3)		;Size of texture
		move.l	#sinus,d_sinus(a3)			;Address of sinus table
		clr.l	d_scrnadr(a3)				;Clr the screen addr
		move.l	#bm_xres*2,d_mscnljmp(a3)		;Scanline jump correction ( 288 in this case)

		move.l	#'Bump',d_name(a3)			;The name found here is used in the windows title line and menu
		move.l	#' Map',d_name+4(a3)			;
		clr.b	d_name+8(a3)				;
	
		move.l	#sinxn,d_ctrl1_name(a3)			;Install the name of the value for slot #1
		move.l	#4,d_ctrl1_step(a3)			;Step value for slot #1
		move.l	#40,d_ctrl1_value(a3)			;Starting value for slot #1

		move.l	#sinyn,d_ctrl2_name(a3)			;Install the name of the value for slot #2
		move.l	d_ctrl1_step(a3),d_ctrl2_step(a3)	;Copy step value from slot #1
		move.l	#32,d_ctrl2_value(a3)			;Starting value for slot #2
	

.alloced:	move.l	d0,a0			;Dest1
		move.l	d0,a1			;Dest2
		adda.l	#256*256*2,a1		;Dest2 correct position
		move.w	#((256*256)/2)-1,d7	;256*256 pixels to copy
		lea	flare,a2		;Source
.copy_it:	move.l	(a2),(a0)+		;
		move.l	(a2)+,(a1)+		;
		dbra	d7,.copy_it		;

		or.b	#1,ccr			;Set carry to indicate success
.exit:		movem.l	(sp)+,d0-a6		;
		rts				;

.no_mem:	and.b	#-2,ccr			;Clear carry to indicate failure.
		bra.s	.exit			;
	

; --------------------------------------------------------------
; ------------- Bumpmapper 50Hz routine ------------------------
; --------------------------------------------------------------

bumpmapper_50hz:
		;add.l	#40,sinus_x		;Sinuscurve - X move
		;andi.l	#$00001fff,sinus_x	;

		move.l	sinus_x(pc),d0
		add.l	d_ctrl1_value(a4),d0
		andi.l	#$1fff,d0
		move.l	d0,sinus_x
	
		;add.l	#32,sinus_y		;Sinuscurve - Y move
		;andi.l	#$00001fff,sinus_y	;
		move.l	sinus_y(pc),d0
		add.l	d_ctrl2_value(a4),d0
		andi.l	#$1fff,d0
		move.l	d0,sinus_y
		rts


; --------------------------------------------------------------
; ------------- Bumpmapper PLOT 1*1 pixelsize (144*85) ---------
; --------------------------------------------------------------

bumpmapper:	move.l	d_sinus(a4),a0		;get adr of sinuslist
		move.l	sinus_x,d0		;
		move.l	(a0,d0.w),d1		;
		muls	#88,d1			;
		asr.l	#8,d1			;
		asr.l	#7,d1			;
		add.l	d1,d1			;d1 = X add

		move.l	d_sinus(a4),a0		;get adr of sinuslist
		move.l	sinus_y,d0		;
		move.l	(a0,d0.w),d2		;
		muls	#64,d2			;
		asr.l	#8,d2			;
		asr.l	#7,d2			;
		mulu.l	#512,d2			;d2 = Y add

		move.l	d_scrnadr(a4),a0	;destination

		move.l	d_texture(a4),a1	;flare (source)
		adda.l	#512*64+96,a1		;flare position
		add.l	d1,a1			;add sinus X to flare
		add.l	d2,a1			;add sinus Y to flare

		lea.l	bumpmap,a2		;this is the bumpmap surface
		clr.l	d0			;clear for later use in mainloop

		move.w	#bm_yres-1,d7		;y-loop (85 lines)
.loop:		move.w	#bm_xres-1,d6		;x-loop (144 pixels)

.loop2:		move.w	(a2)+,d0		;get offset from bumpsurface
		move.w	(a1,d0.l*2),(a0)+	;plus flare via bumpsurfaceo ffset
		addq.l	#2,a1			;increase flare
		dbra	d6,.loop2

		add.l	d_scnl_jump(a4),a0	;scanline offset (dest)
		add.l	#512-288,a1		;scanline offset (source)
		dbra	d7,.loop
		rts



; --------------------------------------------------------------
; ------------- Bumpmapper PLOT 2*2 pixelsize (288*170) --------
; --------------------------------------------------------------

bumpmapper2:
		move.l	d_sinus(a4),a0		;get adr of sinuslist
		move.l	sinus_x,d0		;
		move.l	(a0,d0.w),d1		;
		muls	#88,d1			;
		asr.l	#8,d1			;
		asr.l	#7,d1			;
		add.l	d1,d1			;d1 = X add
		
		move.l	d_sinus(a4),a0		;get adr of sinuslist
		move.l	sinus_y,d0		;
		move.l	(a0,d0.w),d2		;
		muls	#64,d2			;
		asr.l	#8,d2			;
		asr.l	#7,d2			;
		mulu.l	#512,d2			;d2 = Y add

		move.l	d_scrnadr(a4),a0	;destination
		move.l	a0,a3			;dest 2
		add.l	#576,a3			;nextline
		add.l	d_scnl_jump(a4),a3	;nextline full
	
		move.l	d_texture(a4),a1	;flare (source)
		adda.l	#512*64+96,a1		;flare position
		add.l	d1,a1			;add sinus X to flare
		add.l	d2,a1			;add sinus Y to flare

		lea.l	bumpmap,a2		;this is the bumpmap surface
		clr.l	d0			;clear for later use in mainloop

		move.w	#bm_yres-1,d7 		;y-loop (85 lines)
.loop:		move.w	#bm_xres-1,d6 		;x-loop (144 pixels)
.loop2:
		move.w	(a2)+,d0		;get offset from bumpsurface
		move.l	(a1,d0.l*2),d1		;plus flare via bumpsurfaceo ffset
		addq.l	#2,a1			;increase flare
		move.l	d1,(a0)+
		move.l	d1,(a3)+

		dbra	d6,.loop2
		add.l	d_scnl_jump(a4),a0	;scanline offset (dest)
		add.l	d_scnl_jump(a4),a3	;
		add.l	#576,a0			;
		add.l	#576,a3			;
		add.l	d_scnl_jump(a4),a0	;
		add.l	d_scnl_jump(a4),a3	;
		add.l	#512-288,a1		;scanline offset (source)
		dbra	d7,.loop
		rts




; --------------------------------------------------------------
; ------------- Bumpmapper PLOT 4*4 pixelsize (576*340) --------
; --------------------------------------------------------------

bumpmapper3:
		move.l	d_sinus(a4),a0		;get adr of sinuslist
		move.l	sinus_x,d0		;
		move.l	(a0,d0.w),d1		;
		muls	#88,d1			;
		asr.l	#8,d1			;
		asr.l	#7,d1			;
		add.l	d1,d1			;d1 = X add

		move.l	d_sinus(a4),a0		;get adr of sinuslist
		move.l	sinus_y,d0		;
		move.l	(a0,d0.w),d2		;
		muls	#64,d2			;
		asr.l	#8,d2			;
		asr.l	#7,d2			;
		mulu.l	#512,d2			;d2 = Y add

		move.l	d_scrnadr(a4),a0	;destination

		move.l	#1152,d3		;bytes to write each line
		add.l	d_scnl_jump(a4),d3	;remaining bytes of the scan = full scanline width in d3

		move.l	d3,d4			;
		add.l	d4,d4			;2 lines length in d4

		move.l	a0,a3			;dest2
		add.l	d4,a3			;dest2 two lines down

		move.l	d_texture(a4),a1	;flare (source)
		adda.l	#512*64+96,a1		;flare position
		add.l	d1,a1			;add sinus X to flare
		add.l	d2,a1			;add sinus Y to flare

		lea.l	bumpmap,a2		;this is the bumpmap surface
		clr.l	d0			;clear for later use in mainloop

		move.w	#bm_yres-1,d7 		;y-loop (85 lines)
.loop:		move.w	#bm_xres-1,d6 		;x-loop (144 pixels)
.loop2:
		move.w	(a2)+,d0		;get offset from bumpsurface
		move.l	(a1,d0.l*2),d1		;plus flare via bumpsurfaceo ffset
		addq.l	#2,a1			;increase flare

		move.l	d1,(a0,d3)		;dest x1&2,y2
		move.l	d1,(a0)+		;dest x1&2,y1
		move.l	d1,(a0,d3)		;dest x3&4,y2
		move.l	d1,(a0)+		;dest x3&4,y1

		move.l	d1,(a3,d3)		;dest x1&2,y4
		move.l	d1,(a3)+		;dest x1&2,y3
		move.l	d1,(a3,d3)		;dest x3&4,y4
		move.l	d1,(a3)+		;dest x3&4,y3

		dbra	d6,.loop2
		add.l	d_scnl_jump(a4),a0	;scanline offset (dest)
		add.l	d_scnl_jump(a4),a3	;
		add.l	d4,a0			;2 lines down dest1
		add.l	d4,a3			;2 lines down dest2
		add.l	d3,a0			;1 line down dest1
		add.l	d3,a3			;1 line down dest2
		add.l	#512-288,a1		;scanline offset (source)
		dbra	d7,.loop
		rts



; --------------------------------------------------------------
; ------------- Section data -----------------------------------
; --------------------------------------------------------------

	section data

sinxn		dc.b "Sinus X adjustment",0
sinyn		dc.b "Sinux Y adjustment",0

*** Moved here cause then it can be accessed using xx(pc) modes (fater addressing)
		even
sinus_x:	ds.l	1			;sinus constant X
sinus_y:	ds.l	1			;sinus constant Y
scanline_jump:	ds.l	1			;bytes to skip each scanline

		even
flare:		incbin	'gfx\flare.16b'		;lightsource for bump
		even
sinus:		incbin	'data\sinus.dat'	;movement
		even
bumpmap:	incbin	'gfx\bump.dat'

		even 				;always have "even" there!
flare_buff:	dc.l	0
tunnel_buff:	dc.l	0


; --------------------------------------------------------------
; ------------- Section BSS ------------------------------------
; --------------------------------------------------------------

	section bss

