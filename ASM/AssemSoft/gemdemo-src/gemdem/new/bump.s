; s„ter/sweden may 3, 1998
;
; hi ozk!
;
; this is the small bumpmapper I was talking about, not much code at
; all. the largest parts are actually the ones which do the least
; (eg, sinus shit..). If you have any questions, pleae email me.
;
; cya!

*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*
; Hujuj, evl. Here it is! This is the 1st attempt at making the 
; demoes "modules" for the GEM Demo shell. It currently works like 
; this;

; 1. Create a table of routines for the modules init routine. This 
;    table is called "demo_init", and at present only contains the 
;    "mem_alloc" routine used to allocated mem for the texture.
;    This is done in "startup.prj".

; 2. Search for all files with the extender "*.dmo", and create a set 
;    up a table with the filenames found. The code is in 
;    "instldmo.s", routine "get_demofnames".

; 3. Then the routine "install_demoes" is called. This routine is     
;     also found in "instldemo.s", and does the following

;   a. Starting at the beginning of the demo-filenames, it takes the 
;      1st filename (meaning the 1st .dmo file in the dir) and calls 
;      pexec() to load it.

;   b. If pexec() fails, it tries the next *.dmo file in the 
;      table. I.e, looping to 3.

;   c. Check the ID of the .dmo file found at byte 4 in the TEXT 
;      segment of the file. If it's a wrong ID, it starts over at 3. 
;      with the next filename in the table of *.dmo.

;   d. If we get here, a free "slot" in the "demoes" stack is 
;      searched for. If none found, exit. This stack contains an 
;      array of demo_paramter-blocks. Look at "demo_bss.h". If a slot 
;      is found, it sets A3 to points to the found slot and A4 
;      to point to the "demo_init" table of routs. Then a jsr into 
;      byte 24 of the TEXT segment of the loaded *.dmo file, where 
;      the init routine must be, is made. Now it's up to the init 
;      routine to correctly set up this demo paramter block. The init 
;      must set the Carry flag if success. If it fails somehow, it 
;      must clear the carry before returning, in which case the mem 
;      used to load the module is released. If a init call is 
;      unsuccessful, no attempts to load more modules are made.
;      
;   e. If the init routine returns successful, the demo name is 
;      extracted from the demo-parameter-block and installed into the 
;      menu, under "Demoes".
;      
;   f. This is repeated until all *.dmo files are processed, up to a 
;      maximum of 10 modules.
       
; I haven't tested it extensively yet, but it seems to be working with the two
; effects you've created.. so ;-) 


; Use these equates to change the resolution.. this way you don't 
; have to change all the source ;-)

	output .dmo
	opt p=68030
	
bm_xres = 144
bm_yres = 85
	include	demo_bss.h	;Containing the demo-parameter-block/demo_init stucture
	
	text

; --------------------------------------------------------------
; ------------- Bumpmapper INIT --------------------------------
; --------------------------------------------------------------

	;In case someone tries to start it standalone...
	clr.w	-(sp)
	trap	#1

	;This is the ID..
	dc.b 'GEM Demo Executable',0
	
;Called with A3 and A4 set to...
	; A3 = demoes paramter block
	; A4 = Demo init block
bump_init:	movem.l	d0-a6,-(sp)

	move.l	d_texture(a3),d0
	bne.s	.alloced

	move.l	#256*256*4,d0		;Mem for the double buffering.
	moveq	#3,d1
	move.l	di_memalloc(a4),a5
	jsr	(a5)
	beq	.no_mem

*** This routine will only execute once, since I above check if the pointer is null or not	
;=============================================================
;==== This is the new stuff.. it creates a paramter block ====
;==== for this demo at "slot" #1. Look at the Tunnel too, ====
;==== to see that I use "lea demoes+dpb_ssize,a0" to get  ====
;==== to the next slot. This makes it easer for me to code ===
;==== as I don't have to redo all the stuff.. and it open ====
;==== up possibilities like loading demo "modules" so that ===
;==== we don't have to assemble the shell everytime when it ==
;==== is finished.. Tell me how you like the idea..       ====
;=============================================================
	;Set up the info block..
	clr.w	d_winh(a3)		;Must be zero on startup. (telling my routines this demo is inactive, and set when the window is opened)
	clr.w	d_zoom(a3)		;Clear both the flag and the reserved byte
	move.l	#bump_init,d_init(a3)	;The initializating routine
	move.l	#bumpmapper,d_rout(a3)	;The routine I jsr to, to update the window
	**********
	move.l	#bumpmapper_50hz,d_50hz(a3)	;*** This is the only new thing I did in this source ;-))
	**********
	move.l	#(bm_xres<<16)+bm_yres,d_xres(a3) ;X & Y resolution of this screen (used by me to set window size)
	move.l	d0,d_texture(a3)	;Address of texture
	move.l	#256*256*4,d_texturesize(a3)	;Size of texture
	move.l	#sinus,d_sinus(a3)	;Address of sinus table
	clr.l	d_scrnadr(a3)		;Clr the screen addr
	move.l	#bm_xres*2,d_mscnljmp(a3)	;Scanline jump correction ( 288 in this case)

	;The name found here is used in the windows title line...
	;I want to put this name under a menu called "Demoes.." or something too...
	move.l	#'Bump',d_name(a3)
	move.l	#' Map',d_name+4(a3)
	clr.b	d_name+8(a3)

.alloced	move.l	d0,a0
	move.l	d0,a1
	adda.l	#256*256*2,a1
	move.w	#((256*256)/2)-1,d7
	lea	flare,a2
.copy_it	move.l	(a2),(a0)+
	move.l	(a2)+,(a1)+
	dbra	d7,.copy_it

	;Set carry to indicate success
	or.b	#1,ccr
.exit	movem.l	(sp)+,d0-a6
	rts				;

	;Clear carry to indicate failure.
.no_mem	and.b	#-2,ccr
	bra.s	.exit

; --------------------------------------------------------------
; ------------- Bumpmapper PLOT --------------------------------
; --------------------------------------------------------------

;ATTENTION:	I call your plot routine with A4 pointing to the correct demo_block!!
;	This means that you must get the screen_addr/scanline_jump/flair_buff(in this case)
;	from this block.

bumpmapper_50hz:
	add.l	#80,sinus_x		;Sinuscurve - X move
	andi.l	#$00001fff,sinus_x	;
	add.l	#48,sinus_y		;Sinuscurve - Y move
	andi.l	#$00001fff,sinus_y	;
	rts

bumpmapper:	tst.b	d_zoom(a4)
	bne	bumpmapper2
	
                ** Changed **
                ;lea	sinus,a0		;
                move.l	d_sinus(a4),a0
                move.l	sinus_x,d0		;
                move.l	(a0,d0.w),d1		;
                muls	#88,d1		;
                asr.l	#8,d1		;
                asr.l	#7,d1		;
                add.l	d1,d1		;d1 = X add


	** Changed ** ( Why do you load the address of it again here? )
                ;lea	sinus,a0		;
	move.l	d_sinus(a4),a0
                move.l	sinus_y,d0		;
                move.l	(a0,d0.w),d2		;
                muls	#64,d2		;
                asr.l	#8,d2		;
                asr.l	#7,d2		;
                mulu.l	#512,d2		;d2 = Y add

	** Changed **
	;move.l	screen_adr,a0		;destination
	move.l	d_scrnadr(a4),a0
	
	** Changed **
	;move.l	flare_buff,a1
	move.l	d_texture(a4),a1
	
	;If this is resolution dependant, use the mb_x/yres labels
	adda.l	#512*64+96,a1 ;flare+512*64+96,a1	;source "flare" graphics
	add.l	d1,a1		;add sinus X to flare
	add.l	d2,a1		;add sinus Y to flare

	;Should we put this into the demo_block too?
	lea.l	bumpmap,a2		;this is the bumpmap surface

	clr.l	d0		;clear for later use in mainloop

	move.w	#bm_yres-1,d7 ;84,d7		;y-loop (100 lines)
.loop:	move.w	#bm_xres-1,d6 ;143,d6		;x-loop (144 pixels)
.loop2:	move.w	(a2)+,d0		;get offset from bumpsurface
	move.w	(a1,d0.l*2),(a0)+		;plus flare via bumpsurfaceo ffset
	addq.l	#2,a1		;increase flare

	dbra	d6,.loop2

	** Changed **
	;add.l	scanline_jump,a0	;scanline offset (dest)
	add.l	d_scnl_jump(a4),a0
	
	add.l	#512-288,a1		;scanline offset (source)
	dbra	d7,.loop

	rts

bumpmapper2:
	** Changed **
                ;lea	sinus,a0		;
                move.l	d_sinus(a4),a0
                move.l	sinus_x,d0		;
                move.l	(a0,d0.w),d1		;
                muls	#88,d1		;
                asr.l	#8,d1		;
                asr.l	#7,d1		;
                add.l	d1,d1		;d1 = X add
                
                ** Changed **
                ;lea	sinus,a0		;
                move.l	d_sinus(a4),a0
                move.l	sinus_y,d0		;
                move.l	(a0,d0.w),d2		;
                muls	#64,d2		;
                asr.l	#8,d2		;
                asr.l	#7,d2		;
                mulu.l	#512,d2		;d2 = Y add

	** Changed **
	;move.l	screen_adr,a0		;destination
	move.l	d_scrnadr(a4),a0
	

	move.l	a0,a3		;dest 2
	add.l	#576,a3		;nextline
	
	** Changed **
	;add.l	scanline_jump,a3	;real next line if not vdi
	add.l	d_scnl_jump(a4),a3
	
	** Changed **
	;move.l	flare_buff,a1
	move.l	d_texture(a4),a1
	
	adda.l	#512*64+96,a1 ;flare+512*64+96,a1	;source "flare" graphics
	add.l	d1,a1		;add sinus X to flare
	add.l	d2,a1		;add sinus Y to flare

	;And this again..into the demo block?
	lea.l	bumpmap,a2		;this is the bumpmap surface
	clr.l	d0		;clear for later use in mainloop

	move.w	#bm_yres-1,d7 ;84,d7		;y-loop (100 lines)
.loop:	move.w	#bm_xres-1,d6 ;143,d6		;x-loop (144 pixels)
.loop2:
	move.w	(a2)+,d0		;get offset from bumpsurface
	move.l	(a1,d0.l*2),d1		;plus flare via bumpsurfaceo ffset
	addq.l	#2,a1		;increase flare
	move.l	d1,(a0)+
	move.l	d1,(a3)+

	dbra	d6,.loop2

	;** Changed **
	;add.l	scanline_jump,a0	;scanline offset (dest)
	;add.l	scanline_jump,a3
	;add.l	#576,a0
	;add.l	#576,a3
	;add.l	scanline_jump,a0
	;add.l	scanline_jump,a3
	;add.l	#512-288,a1		;scanline offset (source)
	
	add.l	d_scnl_jump(a4),a0
	add.l	d_scnl_jump(a4),a3
	add.l	#576,a0
	add.l	#576,a3
	add.l	d_scnl_jump(a4),a0
	add.l	d_scnl_jump(a4),a3
	add.l	#512-288,a1
	
	dbra	d7,.loop

	rts



	data
flare_buff	dc.l	0
tunnel_buff	dc.l	0
scanline_jump:	ds.l	1		;bytes to skip each scanline


; --------------------------------------------------------------
; ------------- Section data -----------------------------------
; --------------------------------------------------------------

	data

	even
	
flare:	incbin	'gfx\flare.16b'
;	ds.w	356*356
sinus:	incbin	'data\sinus.dat'

	even
bumpmap:	incbin	'gfx\bump.dat'
	even 			;always have "even" there!



; --------------------------------------------------------------
; ------------- Section BSS ------------------------------------
; --------------------------------------------------------------

	section	bss

sinus_x:	ds.l	0		;sinus constant X
sinus_y:	ds.l	0		;sinus constant Y
