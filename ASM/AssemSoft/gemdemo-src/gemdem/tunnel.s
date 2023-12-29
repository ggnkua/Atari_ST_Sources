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
; File: tunnel.s
; Desc: Texturemapped tunnel (offsettable) module (demofx)
; Edit: June 8, 1998 - 02.20 CET
; Info: Tunnelcoding code by Evil/Dead Hackers Society,
;       GEM coding by Ozk/AssemSoft.
;       Tablength = 16

	comment HEAD=%100111
	output .dmo
	opt p=68030

tn_xres:	equ 144
tn_yres:	equ 85

		include	header\system\gemdos.h
		include	demo_bss.h		;Containing the demo-parameter-block/demo_init stucture
	
		section text

; --------------------------------------------------------------
; ------------- Tunnel INIT ------------------------------------
; --------------------------------------------------------------

		clr.w	-(sp)				;In case someone tries to start it standalone...
		trap	#1				;

		dc.b 'GEM Demo Executable',0		;This is the ID that the shell checks to make sure the file is of the correct format.


	; A3 = demoes data area
	; A4 = Demo init block
	
tunnel_init:	movem.l	d0-a6,-(sp)

		move.l	d_texture(a3),d0
		bne	.alloced

	;See the note for the 50Hz routine why we ask for "super" memory here..
		move.l	#256*256*4,d0			;Mem for the double buffering.
		move.l	#aloc_memprotsel|aloc_super|aloc_prefertt,d1
		move.l	di_memalloc(a4),a5
		jsr	(a5)
		beq	.no_mem

		clr.w	d_zoom(a3)			;Clear both the flag and the reserved byte
		move.l	#tunnel_init,d_init(a3)		;The initializating routine
		move.l	#tunnel,d_rout(a3)		;The routine I jsr to, to update the window
		move.l	d_rout(a3),d_rout1x(a3)
		move.l	#tunnel2,d_rout2x(a3)
		move.l	#tunnel3,d_rout4x(a3)
	
		move.l	#tunnel_50hz,d_50hz(a3)
		move.l	#(tn_xres<<16)+tn_yres,d_xres(a3);X & Y resolution of this screen (used by me to set window size)
		move.l	d0,d_texture(a3)
		move.l	#256*256*4,d_texturesize(a3)
		move.l	#sinus,d_sinus(a3)
		clr.l	d_scrnadr(a3)
		move.l	#tn_xres*2,d_mscnljmp(a3)

		move.l	#'Tunn',d_name(a3)
		move.w	#'el',d_name+4(a3)
		clr.b	d_name+6(a3)

		move.l	#sinxn,d_ctrl1_name(a3)		;Install name of value for slot #1
		move.l	#4,d_ctrl1_step(a3)		;Step value for slot #1
		move.l	#40,d_ctrl1_value(a3)		;Starting value for slot #1

		move.l	#sinyn,d_ctrl2_name(a3)
		move.l	#4,d_ctrl2_step(a3)
		move.l	#32,d_ctrl2_value(a3)

		move.l	#scrln,d_ctrl3_name(a3)
		move.l	#2,d_ctrl3_step(a3)
		move.l	#4,d_ctrl3_value(a3)
	
		move.l	#rotn,d_ctrl4_name(a3)
		move.l	#512,d_ctrl4_step(a3)
		move.l	#512,d_ctrl4_value(a3)

.alloced	move.l	d0,a0
		move.l	d0,a1
		adda.l	#256*256*2,a1
		move.w	#((256*256)/2)-1,d7
		lea	texture,a2
.copy_it	move.l	(a2),(a0)+
		move.l	(a2)+,(a1)+
		dbra	d7,.copy_it
		or.b	#1,ccr
.exit		movem.l	(sp)+,d0-a6
		rts				;
.no_mem		and.b	#-2,ccr
		bra.s	.exit

	
; --------------------------------------------------------------
; ------------- Tunnel 50Hz routine ----------------------------
; --------------------------------------------------------------
; IMPORTANT: This routine can NOT!!! access anything that is not
; "super" flagged memory/context areas. If this is to work under
; MP, make sure everything accessed from this routine is perpared
; accordingly. This also means that the 50Hz routine CAN NOT make
; any callbacks to any of the shell utility routines!. This is
; also the reason why we set "super" flag for *.DMO modules in
; in the "comment HEAD=" assembler statement above.
tunnel_50hz:	move.l	sinus_x(pc),d0
		add.l	d_ctrl1_value(a4),d0
		andi.l	#$1fff,d0
		move.l	d0,sinus_x
	
		move.l	sinus_y(pc),d0
		add.l	d_ctrl2_value(a4),d0
		andi.l	#$1fff,d0
		move.l	d0,sinus_y
	
	;add.l	#40,sinus_x			;Sinuscurve - X move
	;andi.l	#$00001fff,sinus_x		;
	;add.l	#32,sinus_y			;Sinuscurve - Y move
	;andi.l	#$00001fff,sinus_y		;

	;8 = scroll speed towards.. divisible by 2
	;1024 = rotation speed .. divisible by 512
		move.l	tunnel_scroll(pc),d0
		add.l	d_ctrl3_value(a4),d0
		add.l	d_ctrl4_value(a4),d0
		andi.l	#$1ffff,d0
		move.l	d0,tunnel_scroll

		;add.l	#4+512,tunnel_scroll	;inc scroll
		;and.l	#$1ffff,tunnel_scroll	;loop scroll
		rts


; --------------------------------------------------------------
; ------------- Tunnel PLOT  1*1 pixelsize (144*85) ------------
; --------------------------------------------------------------

tunnel:
		move.l	d_sinus(a4),a0		;get adr of sinuslist
		move.l	sinus_x,d0		;
		move.l	(a0,d0.w),d1		;
		muls	#104,d1			;
		asr.l	#8,d1			;
		asr.l	#7,d1			;
		add.l	d1,d1			;d1 = X add

		move.l	d_sinus(a4),a0		;get adr of sinuslist
		move.l	sinus_y,d0		;
		move.l	(a0,d0.w),d2		;
		muls	#64,d2			;
		asr.l	#8,d2			;
		asr.l	#7,d2			;
		mulu.l	#576,d2			;d2 = Y add

		move.l	d_scrnadr(a4),a0	;destination
	
		lea.l	tunnel_lut+50*576+144,a1;tunnel offset table

		add.l	d1,a1			;add sinus X to flare
		add.l	d2,a1			;add sinus Y to flare
	
		move.l	d_texture(a4),a2	;texture (source)
		add.l	tunnel_scroll,a2	;scroll texture

		clr.l	d0			;clear for later use in mainloop

		move.w	#tn_yres-1,d7		;y-loop (85 lines)
.loop:		move.w	#tn_xres-1,d6		;x-loop (144 pixels)
.loop2:		move.w	(a1)+,d0		;tunnel offset
		move.w	(a2,d0.l*2),(a0)+	;tunnel plot

		dbra	d6,.loop2
		add.l	d_scnl_jump(a4),a0	;scanline offset (dest)
		add.l	#576-288,a1		;scanline offset (source)
		dbra	d7,.loop

		rts


; --------------------------------------------------------------
; ------------- Tunnel PLOT  2*2 pixelsize (288*170) -----------
; --------------------------------------------------------------

tunnel2:
		move.l	d_sinus(a4),a0		;get adr of sinuslist
		move.l	sinus_x,d0		;
		move.l	(a0,d0.w),d1		;
		muls	#104,d1			;
		asr.l	#8,d1			;
		asr.l	#7,d1			;
		add.l	d1,d1			;d1 = X add
               
		move.l	d_sinus(a4),a0		;get adr of sinuslist
		move.l	sinus_y,d0		;
		move.l	(a0,d0.w),d2		;
		muls	#64,d2			;
		asr.l	#8,d2			;
		asr.l	#7,d2			;
		mulu.l	#576,d2			;d2 = Y add

		move.l	d_scrnadr(a4),a0	;destination
	
		move.l	a0,a3			;dest2
		add.l	#576,a3			;nextline
		add.l	d_scnl_jump(a4),a3	;nextline full

		lea.l	tunnel_lut+50*576+144,a1;tunnel offset table

		add.l	d1,a1			;add sinus X to flare
		add.l	d2,a1			;add sinus Y to flare

		move.l	d_texture(a4),a2	;source
		add.l	tunnel_scroll,a2	;scroll texture

		clr.l	d0			;clear for later use in mainloop

		move.w	#tn_yres-1,d7		;y-loop (85 lines)
.loop:		move.w	#tn_xres-1,d6		;x-loop (144 pixels)
.loop2:
		move.w	(a1)+,d0		;tunnel offset
		move.l	(a2,d0.l*2),d1		;tunnel plot
		move.l	d1,(a0)+
		move.l	d1,(a3)+

		dbra	d6,.loop2
		add.l	d_scnl_jump(a4),a0	;scanline offset (dest)
		add.l	d_scnl_jump(a4),a3	;
		add.l	#576,a0			;
		add.l	#576,a3			;
		add.l	d_scnl_jump(a4),a0	;
		add.l	d_scnl_jump(a4),a3	;
		add.l	#576-288,a1		;scanline offset (source)
		dbra	d7,.loop
		rts


; --------------------------------------------------------------
; ------------- Tunnel PLOT  4*4 pixelsize (576*340) -----------
; --------------------------------------------------------------

tunnel3:
		move.l	d_sinus(a4),a0		;get adr of sinuslist
		move.l	sinus_x,d0		;
		move.l	(a0,d0.w),d1		;
		muls	#104,d1			;
		asr.l	#8,d1			;
		asr.l	#7,d1			;
		add.l	d1,d1			;d1 = X add
               
		move.l	d_sinus(a4),a0		;get adr of sinuslist
		move.l	sinus_y,d0		;
		move.l	(a0,d0.w),d2		;
		muls	#64,d2			;
		asr.l	#8,d2			;
		asr.l	#7,d2			;
		mulu.l	#576,d2			;d2 = Y add

		move.l	d_scrnadr(a4),a0	;destination

		move.l	#1152,d3		;bytes to write each line
		add.l	d_scnl_jump(a4),d3	;remaining bytes of the scan = full scanline width in d3

		move.l	d3,d4			;
		add.l	d4,d4			;2 lines length in d4
	
		move.l	a0,a3			;dest2
		add.l	d4,a3			;dest2 two lines down

		lea.l	tunnel_lut+50*576+144,a1;tunnel offset table

		add.l	d1,a1			;add sinus X to flare
		add.l	d2,a1			;add sinus Y to flare

		move.l	d_texture(a4),a2	;source
		add.l	tunnel_scroll,a2	;scroll texture

		clr.l	d0			;clear for later use in mainloop

		move.w	#tn_yres-1,d7		;y-loop (85 lines)
.loop:		move.w	#tn_xres-1,d6		;x-loop (144 pixels)
.loop2:
		move.w	(a1)+,d0		;tunnel offset
		move.l	(a2,d0.l*2),d1		;tunnel plot

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
		add.l	#576-288,a1		;scanline offset (source)
		dbra	d7,.loop
		rts




; --------------------------------------------------------------
; ------------- Section data -----------------------------------
; --------------------------------------------------------------

		section	data

sinxn		dc.b "Sinus X Adjustment",0
sinyn		dc.b "Sinux Y Adjustment",0
scrln		dc.b "Scroll Speed Adjustment",0
rotn		dc.b "Rotation Speed Adjustment",0	

*** Moved here cause then it can be accessed using xx(pc) modes (fater addressing)
		even
sinus_x:	ds.l	1
sinus_y:	ds.l	1
tunnel_scroll:	ds.l	1
	even
	
tunnel_lut:	incbin	'data\tunnel.dat'
		even 				;always have "even" there!

texture:	incbin	'gfx\texture.16b'
		;ds.w	256*256

sinus:		incbin	'data\sinus.dat'

; --------------------------------------------------------------
; ------------- Section BSS ------------------------------------
; --------------------------------------------------------------

;		section bss

;scanline_jump:	ds.l	1			;bytes to skip each scanline

