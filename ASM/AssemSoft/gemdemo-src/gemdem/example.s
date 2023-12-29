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
; File: example.s
; Desc: Example of using the demosys.
; Edit: June 8, 1998 - 02.20 CET
; Info: Demoblock etc. by Ozk/Assemsoft.
;       Tablength = 16

	output .dmo
	opt p=68030
	
bm_xres:	equ 144
bm_yres:	equ 85

	include	demo_bss.h	;Containing the demo-parameter-block/demo_init stucture
	
	section text

; --------------------------------------------------------------
; ------------- INIT -------------------------------------------
; --------------------------------------------------------------

	clr.w	-(sp)	;In case someone tries to start it standalone...
	trap	#1	;

	dc.b 'GEM Demo Executable',0	;This is the ID that the shell checks to make sure the file is of the correct format.
	
; When the shell installs the demo module, it calls this routine, bump_init. Well,
; the shell actually do a jsr to the 24th byte of the TEXT segment of the module
; and this is where the init routine should start. This routine is called with the
; address of the demoes assigned demo-parameter-block (assigned by the shell) in A3
; and the address of the "demo_init" block in A4. The demo_init block is just a table
; of routines that is usable by the modules init routine. At this point there's only one
; routine in this block, namely the mem_alloc routine that init calls to alloc mem for
; the texture.

; IMPORTANT: 	If the init routine of the module is encountering an error, like no memory could
;	be allocated, it MUST clear the carry upon returning.
;	To tell the shell that all went fine, it MUST set the carry flag before returning.

	; A3 = demoes paramter block
	; A4 = Demo init block
bump_init:	movem.l	d0-a6,-(sp)


	;When installing itself, the module allocates memory for the texture (or anyting)
	;and stores the address of the allocated memory in the "d_texture" element of 
	;the parameter-block. BUT!! the init routine is also called to reinstall the texture
	;into the allocated buffer when converting the gfx format between different hardware
	;like videl, CDots and Nova.  So, the 1st thing the init routine should do is
	;to check if memory already have been allocated by checking the "d_texture" element.
	;If this is a NULL pointer, the routine knows it's the 1st time it's called, and can
	;safely assume that this is the "init module" call, and install the whole
	;demo paramter block. Otherwise, at this stage, it should only recopy the original
	;texture from it's DATA segment to the allocated buffer.

	move.l	d_texture(a3),d0	;Get address of texture
	bne.s	.alloced		;Not NULL = already installed



	;This is the 1st time around, it's the "init module" call. 1st get memory for the texture
	;The routine installed at di_memalloc takes the number of bytes to allocate in D0
	;and the type of memory to install in D1. It does a "tst.l d0" before returning,
	;so that if the Z (beq error) flag is set upon return, the call failed.

	move.l	#256*256*4,d0		;Mem for the double buffering.
	moveq	#3,d1		;Preferably TT, but any mem OK
	move.l	di_memalloc(a4),a5	;Address of mem alloc routine
	jsr	(a5)		;Get the memory
	beq	.no_mem		;Error if equal


	;Now set up the parameter block for the shell to use.


	clr.w	d_zoom(a3)		;Clear both the flag and the reserved byte
	move.l	#bump_init,d_init(a3)	;The initializating routine
	move.l	#bumpmapper,d_rout(a3)	;The plot routine
	move.l	#bumpmapper_50hz,d_50hz(a3)	;The 50Hz routine
	move.l	#(bm_xres<<16)+bm_yres,d_xres(a3) ;X & Y resolution of this screen
	move.l	d0,d_texture(a3)	;Address of texture, D0 contains the address of allocated mem
	move.l	#256*256*4,d_texturesize(a3)	;Size of texture
	move.l	#sinus,d_sinus(a3)	;Address of sinus table
	clr.l	d_scrnadr(a3)		;Clr the screen addr
	move.l	#bm_xres*2,d_mscnljmp(a3)	;Scanline jump correction ( 288 in this case)

	move.l	#'Bump',d_name(a3)	;The name found here is used in the windows title line and menu
	move.l	#' Map',d_name+4(a3)	;
	clr.b	d_name+8(a3)		;

.alloced:	move.l	d0,a0		;Dest1
	move.l	d0,a1		;Dest2
	adda.l	#256*256*2,a1		;Dest2 correct position
	move.w	#((256*256)/2)-1,d7	;256*256 pixels to copy
	lea	flare,a2		;Source
.copy_it:	move.l	(a2),(a0)+		;
	move.l	(a2)+,(a1)+		;
	dbra	d7,.copy_it		;

	or.b	#1,ccr		;Set carry to indicate success
.exit:	movem.l	(sp)+,d0-a6		;
	rts			;

.no_mem:	and.b	#-2,ccr		;Clear carry to indicate failure.
	bra.s	.exit		;
	

; --------------------------------------------------------------
; ------------- Bumpmapper PLOT 1*1 pixelsize (144*85) ---------
; --------------------------------------------------------------

;ATTENTION:	I call your plot routine with A4 pointing to the correct demo_block!!
;	This means that you must get the screen_addr/scanline_jump/flair_buff(in this case)
;	from this block.
	;80
	;48

bumpmapper_50hz:
	add.l	#40,sinus_x		;Sinuscurve - X move
	andi.l	#$00001fff,sinus_x	;
	add.l	#32,sinus_y		;Sinuscurve - Y move
	andi.l	#$00001fff,sinus_y	;
	rts

bumpmapper:	tst.b	d_zoom(a4)
	bne	bumpmapper2
	
                move.l	d_sinus(a4),a0		;get adr of sinuslist
                move.l	sinus_x,d0		;
                move.l	(a0,d0.w),d1		;
                muls	#88,d1		;
                asr.l	#8,d1		;
                asr.l	#7,d1		;
                add.l	d1,d1		;d1 = X add

	move.l	d_sinus(a4),a0		;get adr of sinuslist
                move.l	sinus_y,d0		;
                move.l	(a0,d0.w),d2		;
                muls	#64,d2		;
                asr.l	#8,d2		;
                asr.l	#7,d2		;
                mulu.l	#512,d2		;d2 = Y add

	move.l	d_scrnadr(a4),a0	;destination

	move.l	d_texture(a4),a1	;flare (source)
	adda.l	#512*64+96,a1		;flare position
	add.l	d1,a1		;add sinus X to flare
	add.l	d2,a1		;add sinus Y to flare

	lea.l	bumpmap,a2		;this is the bumpmap surface
	clr.l	d0		;clear for later use in mainloop

	move.w	#bm_yres-1,d7		;y-loop (100 lines)
.loop:	move.w	#bm_xres-1,d6		;x-loop (144 pixels)
.loop2:	move.w	(a2)+,d0		;get offset from bumpsurface
	move.w	(a1,d0.l*2),(a0)+	;plus flare via bumpsurfaceo ffset
	addq.l	#2,a1		;increase flare

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
                muls	#88,d1		;
                asr.l	#8,d1		;
                asr.l	#7,d1		;
                add.l	d1,d1		;d1 = X add
                
                move.l	d_sinus(a4),a0		;get adr of sinuslist
                move.l	sinus_y,d0		;
                move.l	(a0,d0.w),d2		;
                muls	#64,d2		;
                asr.l	#8,d2		;
                asr.l	#7,d2		;
                mulu.l	#512,d2		;d2 = Y add

	move.l	d_scrnadr(a4),a0	;destination
	move.l	a0,a3		;dest 2
	add.l	#576,a3		;nextline
	add.l	d_scnl_jump(a4),a3	;nextline full
	
	move.l	d_texture(a4),a1	;flare (source)
	adda.l	#512*64+96,a1		;flare position
	add.l	d1,a1		;add sinus X to flare
	add.l	d2,a1		;add sinus Y to flare

	lea.l	bumpmap,a2		;this is the bumpmap surface
	clr.l	d0		;clear for later use in mainloop

	move.w	#bm_yres-1,d7 		;y-loop (100 lines)
.loop:	move.w	#bm_xres-1,d6 		;x-loop (144 pixels)
.loop2:
	move.w	(a2)+,d0		;get offset from bumpsurface
	move.l	(a1,d0.l*2),d1		;plus flare via bumpsurfaceo ffset
	addq.l	#2,a1		;increase flare
	move.l	d1,(a0)+
	move.l	d1,(a3)+

	dbra	d6,.loop2
	add.l	d_scnl_jump(a4),a0	;scanline offset (dest)
	add.l	d_scnl_jump(a4),a3	;
	add.l	#576,a0		;
	add.l	#576,a3		;
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
                muls	#88,d1		;
                asr.l	#8,d1		;
                asr.l	#7,d1		;
                add.l	d1,d1		;d1 = X add
                
                move.l	d_sinus(a4),a0		;get adr of sinuslist
                move.l	sinus_y,d0		;
                move.l	(a0,d0.w),d2		;
                muls	#64,d2		;
                asr.l	#8,d2		;
                asr.l	#7,d2		;
                mulu.l	#512,d2		;d2 = Y add

	move.l	d_scrnadr(a4),a0	;destination

	move.l	#1152,d3		;bytes to write each line
	add.l	d_scnl_jump(a4),d3	;remaining bytes of the scan = full scanline width in d3

	move.l	d3,d4		;
	add.l	d4,d4		;2 lines length in d4

	move.l	a0,a3		;dest2
	add.l	d4,a3		;dest2 two lines down

	move.l	d_texture(a4),a1	;flare (source)
	adda.l	#512*64+96,a1		;flare position
	add.l	d1,a1		;add sinus X to flare
	add.l	d2,a1		;add sinus Y to flare

	lea.l	bumpmap,a2		;this is the bumpmap surface
	clr.l	d0		;clear for later use in mainloop

	move.w	#bm_yres-1,d7 		;y-loop (100 lines)
.loop:	move.w	#bm_xres-1,d6 		;x-loop (144 pixels)
.loop2:
	move.w	(a2)+,d0		;get offset from bumpsurface
	move.l	(a1,d0.l*2),d1		;plus flare via bumpsurfaceo ffset
	addq.l	#2,a1		;increase flare

	move.l	d1,(a0,d3)		;dest x1-2,y2
	move.l	d1,(a0)+		;dest x1-2,y1
	move.l	d1,(a0,d3)		;dest x3-4,y2
	move.l	d1,(a0)+		;dest x3-4,y1

	move.l	d1,(a3,d3)		;dest x1-2,y4
	move.l	d1,(a3)+		;dest x1-2,y3
	move.l	d1,(a3,d3)		;dest x3-4,y4
	move.l	d1,(a3)+		;dest x3-4,y3

	dbra	d6,.loop2
	add.l	d_scnl_jump(a4),a0	;scanline offset (dest)
	add.l	d_scnl_jump(a4),a3	;
	add.l	d4,a0		;2 lines down dest1
	add.l	d4,a3		;2 lines down dest2
	add.l	d3,a0		;1 line down dest1
	add.l	d3,a3		;1 line down dest2

	add.l	#512-288,a1		;scanline offset (source)
	dbra	d7,.loop
	rts



; --------------------------------------------------------------
; ------------- Section data -----------------------------------
; --------------------------------------------------------------

	section data

	even
flare:	incbin	'gfx\flare.16b'		;lightsource for bump
	even
sinus:	incbin	'data\sinus.dat'	;movement
	even
bumpmap:	incbin	'gfx\bump.dat'
	even 			;always have "even" there!

flare_buff:	dc.l	0
tunnel_buff:	dc.l	0


; --------------------------------------------------------------
; ------------- Section BSS ------------------------------------
; --------------------------------------------------------------

	section bss

sinus_x:	ds.l	1		;sinus constant X
sinus_y:	ds.l	1		;sinus constant Y
scanline_jump:	ds.l	1		;bytes to skip each scanline
