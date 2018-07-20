
; c2p development code by spkr
; based on input/talks/mails from
; - earx
; - evl
; - ultra
; 
; code exit is borked; deal with it or fix it

FRAMECOUNT					equ 0
PLAYMUSIC					equ 1
playmusicinvbl				equ 1
useblitter					equ 1

tridi						equ 0

    section	TEXT
	include lib/macro.s
		allocateStackAndShrink								; stack + superexec
	; INIT SETUP CODE ---------------------------------------
	jsr	saveAndKillTimers									; kill timers and save them
;	jsr	disableMouse										; turn off mouse
	jsr	backupPalAndScrMemAndResolutionAndSetLowRes			; save screen address and other display properties
	jsr	checkMachineTypeAndSetStuff							; check machine type, disable cache
	jsr	setScreen64kAligned									; set 2 screens at 64k aligned


	lea		music,a0
	move.l	a0,sndh_pointer
	moveq	#1,d0
	jsr		(a0)

;	jsr		planarToChunky					; can be used to get chunky from planar pic

	jsr		opt_calcTab2					; optimized table 
	jsr		opt_calcTexture					; 4 tabs
	jsr		opt_calcTexture_lowmem			; 2 tabs
	jsr		chunkymul						; this does value*4 on the chunky picture, since the source is 1 byte (0..15), end value still remains in 1 byte
	jsr		init_atabs						; this aligns the 4 tables TAB1..TAB4 to 64k boundary addresses
	jsr 	prepareChunkyTextureBPL1to4		; this is incorporating the mapping with the texture, which means; instead of doing each lookup, we have a
											;	precalced table that contains: for each TAB (2 or 4, depending if we do 1:4 or 1:2 c2p), each combination of 
											;	source pixel mask, with the c2p mapping mask
											;	basically it means, that we can `skip' the move.b from the source picture, because we do this with offsets
											;		in the code
											;	this means the following:
											;		move.b	(a0)+,d0			->		
											;		move.l	(a1,d0.w),d1					move.l	off(a1),d1
											;		move.b	(a0)+,d0						
											;		or.l	(a2,d0.w),d1					or.l	off(a2),d1
											;		move.b	(a0)+,d0
											;		or.l	(a3,d0.w),d1					or.l	off(a3),d1
											;		move.b	(a0)+,d0
											;		or.l	(a4,d0.w),d1					or.l	off(a4),d1
											;		movep.l	d1,(a5)							movep.l	d1,(a5)
											;
											;	for the case where I display the picture, it just means that `off' needs to increased by 4 each time its used
											;	(see example code)
											;
											;	for other effects, this means that you would unroll the complete code, and write your `effect' to instructions in
											;	the `off'
											;	this way you incorporate the `offset-mapping' from your texture directly into your instructions
											; 	this could then in turn be modified by smc to further enhance the effect
	jsr		prepareChunkyTextureBPL1to2		;
	jsr		generate2pxTabs					; this generates the 2 px tabs, this way the tabs are set up that the source picture can be read
											; 2 bytes from chunkysource at a time, 4 pixels in screen
;	jsr		generate1pxTabs
	jsr		calcTabLowMem

	; set tutti paletti
	lea		tunnelpallette,a0			
	movem.l (a0),d0-d7
	movem.l	d0-d7,$ffff8240.w


mainloop:
		wait_for_vbl
		jsr	swapscreens

		move.w	#$070,$ffff8240
;		jsr		c2p_1to2_classic			; 1 to 2 chunky pic
;		jsr		c2p_1to2_classic_aligned	; 1 to 2 chunky pic, aligned addresses; fits in 1 vbl

;		jsr		c2p_1to2_offset				; 1 to 2 chunky picture, with offset mapping
;		jsr		c2p_1to2_offset_new			; new opt, no longer move.l and 3x or.l but move.l and 3x or.w
;		jsr		c2p_1to2_offset_new_lowmem	; new opt, no longer move.l and 3x or.l but move.l, 2x or.w, 1x or.b; also uses 2 buffers

;		jsr		c2p_2to4					; 2 to 4 chunky picture, unopt, as described above, but 2 pixels source -> 4 dest in 1 go
		jsr		c2p_2to4_aligned			; 2 to 4 chunky picture, aligned addresses
;		jsr		c2p_2to4_lowerMemory		; 2 to 4 chunky picture, stuff in lower, requires calcTabLowMem in low

;		jsr		c2p_1to1					; 1 to 1 chucnky picture, half in lower, half in aligned; requires generate1pxTabs in low
		

		move.w	#$777,$ffff8240
		move.l	sndh_pointer,a0
		jsr		8(a0)
		move.w	#$0,$fff8240


	; ---- END ----
		
	;---- BEGIN SPACEBAR PRESS FOR EXIT ----
	cmp.b 	#$39,$fffffc02.w
	bne		mainloop
	;----- END --------------------------------------------


	move.w	#$2700,sr
	move.l	#dummyvbl,$70.w				;Install our own VBL
	move.l	#dummy,$68.w				;Install our own HBL (dummy)
	move.l	#dummy,$134.w				;Install our own Timer A (dummy)
	move.l	#dummy,$120.w				;Install our own Timer B
	move.l	#dummy,$114.w				;Install our own Timer C (dummy)
	move.l	#dummy,$110.w				;Install our own Timer D (dummy)
	move.l	#dummy,$118.w				;Install our own ACIA (dummy)
	clr.b	$fffffa07.w					;Interrupt enable A (Timer-A & B)
	clr.b	$fffffa13.w					;Interrupt mask A (Timer-A & B)
	clr.b	$fffffa09.w					;Interrupt enable B (Timer-C & D)
	clr.b	$fffffa15.w					;Interrupt mask B (Timer-C & D)
	move.w	#$2300,sr

	jsr restoresForMachineTypes
	jsr	restorePalAndScreenMemAndResolution
	jsr	restoreTimers
	jsr	stopMusic
	jsr	enableMouse
	rts


c2p_2to4_lowerMemory
	lea		chunkypic2,a0
	move.l	screenpointer2,a6
off set 0
	rept 64
		rept 8
			move.w	(a0)+,a1
			move.l	(a1),d2

			move.w	(a0)+,a1
			or.l	$4000(a1),d2

			movep.l	d2,off+0(a6)

			move.w	(a0)+,a1
			move.l	(a1),d2

			move.w	(a0)+,a1
			or.l	$4000(a1),d2

			movep.l	d2,off+1(a6)
off set off+8

		endr
off set off+96+160
	endr

	move.l	a6,a0
	jsr		copyLines
	rts

	
c2p_2to4_aligned
	lea		chunkypic,a0
	move.l	tab2px_1p,d0
	move.l	tab2px_2p,d1
	move.l	screenpointer2,a6

off	SET 0
	REPT 64
		REPT 8
			move.w	(a0)+,d0						;8							movem.w	(a0)+,a1-a3		;28/2 = 14
			move.l	d0,a1							;4							move.l	(a1),d2			;12
			move.l	(a1),d2							;12							or.l	(a2),d2			;16
													;							movep.l	d2,off(a6)		;24			-> 
			move.w	(a0)+,d1						;8
			move.l	d1,a2							;4
			or.l	(a2),d2							;16

			movep.l	d2,off+0(a6)					;24		--> 	76			
		
			move.w	(a0)+,d0					
			move.l	d0,a1
			move.l	(a1),d2

			move.w	(a0)+,d1
			move.l	d1,a2
			or.l	(a2),d2

			movep.l	d2,off+1(a6)
off			SET		off+8
		ENDR
off		SET	off+96+160
	ENDR

	move.l	a6,a0
	jsr		copyLines

	rts

c2p_2to4
	lea		chunkypic,a0
	move.l	tab2px_1p,a1
	move.l	tab2px_2p,a2
	move.l	screenpointer2,a6

off	SET 0
	REPT 64
		REPT 8
			move.w	(a0)+,d0
			move.l	(a1,d0.w),d1
			move.w	(a0)+,d0
			or.l	(a2,d0.w),d1
			movep.l	d1,off+0(a6)
		
			move.w	(a0)+,d0
			move.l	(a1,d0.w),d1
			move.w	(a0)+,d0
			or.l	(a2,d0.w),d1
			movep.l	d1,off+1(a6)
off			SET		off+8
		ENDR
off		SET	off+96+160
	ENDR

	move.l	a6,a0
	jsr		copyLines

	rts


c2p_1to2_offset_new
	move.l	screenpointer2,a0
	lea		opt_tab1,a1
	lea		opt_tab2,a2
	lea		opt_tab3,a3
	lea		opt_tab4,a4
o	SET 0
p	SET 0
	REPT 64
		REPT 	8	
			move.l	p(a1),d0			
			add.w	p+2+4(a2),d0
			add.w	p+2+8(a3),d0
			add.w	p+2+12(a4),d0
			move.l	d0,a5
			move.l	(a5),d0
			movep.l	d0,o(a0)
	

			move.l	p+16(a1),d0			
			add.w	p+2+20(a2),d0
			add.w	p+2+24(a3),d0
			add.w	p+2+28(a4),d0
			move.l	d0,a5
			move.l	(a5),d0
			movep.l	d0,o+1(a0)
p			set		p+32
o			SET 	o+8
		ENDR
o		SET	o+96+160
	ENDR
	jsr		copyLines
	rts

c2p_1to2_offset_new_lowmem
	move.l	screenpointer2,a0
	lea		opt_tab1_lowmem,a1
	lea		opt_tab2_lowmem,a2
o	SET 0
p	SET 0
	REPT 64
		REPT 	8	
			move.l	p(a1),d0			
			add.w	p+4(a2),d0
			add.w	p+2+8(a2),d0
			add.b	p+12(a2),d0
			move.l	d0,a5
			move.l	(a5),d0
			movep.l	d0,o(a0)
	

			move.l	p+16(a1),d0			
			add.w	p+20(a2),d0
			add.w	p+2+24(a2),d0
			add.b	p+28(a2),d0
			move.l	d0,a5
			move.l	(a5),d0
			movep.l	d0,o+1(a0)
p			set		p+32
o			SET 	o+8
		ENDR
o		SET	o+96+160
	ENDR
	jsr		copyLines
	rts



c2p_1to2_offset
	move.l	screenpointer2,a0
	lea		chunkybuffer4_1,a1
	lea		chunkybuffer4_2,a2
	lea		chunkybuffer4_3,a3
	lea		chunkybuffer4_4,a4

o	SET 0
p	SET 0
	REPT 64
		REPT 	8
			move.l	p(a1),d0					;16							;16		move.l	p(a1),d0
p			SET		p+4
			or.l	p(a2),d0					;20							;12		or.w	p(a2),d0	
p			SET		p+4
			or.l	p(a3),d0					;20							;12		or.w	p(a3),d0
p			SET		p+4
			or.l	p(a4),d0					;20							;12		or.w	p(a4),d0
p			SET		p+4														;4		move.l	d0,a5
																			;12		move.l	(a5),d0
			movep.l	d0,o(a0)					;24			->	100			;24		movep.l	d0,o(a0)		92
	
	
			move.l	p(a1),d0
p			SET		p+4
			or.l	p(a2),d0
p			SET		p+4
			or.l	p(a3),d0
p			SET		p+4
			or.l	p(a4),d0
p			SET		p+4
			movep.l	d0,o+1(a0)
o			SET 	o+8
		ENDR
o		SET	o+96+160
	ENDR

	jsr		copyLines

	rts

copyLines
	move.w	#$007,$ffff8240
o	set 0
	REPT 64
		movem.l	o(a0),d0-d7	
		movem.l	d0-d7,o+160(a0)
		movem.l	o+32(a0),d0-d7/a1/a2/a3/a4
		movem.l	d0-d7/a1/a2/a3/a4,o+160+32(a0)
o	set o+320
	ENDR
	rts

c2p_1to2_classic_aligned
	lea		chunkypic,a0
	lea		chunkypic,a5
	add.w	#80*20+10,a5
	lea		chunkypic,a2
	add.w	#80*30-10,a2

	move.l	a_tab1pointer,d0
	move.l	a_tab2pointer,d1
	move.l	a_tab3pointer,d2
	move.l	a_tab4pointer,d3

	move.l	screenpointer2,a6

o	set 0
	REPT 64
		REPT 8
			move.b	(a0)+,d0			
			move.l	d0,a1				
			move.l	(a1),d5				
			move.b	(a0)+,d1			
			move.l	d1,a1				
			or.l	(a1),d5				
			move.b	(a0)+,d2			
			move.l	d2,a1				
			or.l	(a1),d5				
			move.b	(a0)+,d3			
			move.l	d3,a1				
			or.l	(a1),d5				
			movep.l	d5,o(a6)			

o			SET o+1
			move.b	(a0)+,d0			
			move.l	d0,a1				
			move.l	(a1),d5				
			move.b	(a0)+,d1			
			move.l	d1,a1				
			or.l	(a1),d5				
			move.b	(a0)+,d2			
			move.l	d2,a1				
			or.l	(a1),d5				
			move.b	(a0)+,d3			
			move.l	d3,a1				
			or.l	(a1),d5				
			movep.l	d5,o(a6)			
o			SET o+7
		ENDR
o		SET	o+96+160
	ENDR

	move.l	a6,a0
	jsr copyLines

	rts


c2p_1to2_classic
	lea		chunkypic,a0
	lea		TAB1,a1
	lea		TAB2,a2
	lea		TAB3,a3
	lea		TAB4,a4

	move.l	screenpointer2,a6

o	set 0
	moveq	#0,d0
	REPT 64
		REPT 8
		move.b	(a0)+,d0
		move.l	(a1,d0.w),d5
		move.b	(a0)+,d0
		or.l	(a2,d0.w),d5
		move.b	(a0)+,d0
		or.l	(a3,d0.w),d5
		move.b	(a0)+,d0
		or.l	(a4,d0.w),d5
		movep.l	d5,o(a6)

o	SET o+1
		move.b	(a0)+,d0
		move.l	(a1,d0.w),d5
		move.b	(a0)+,d0
		or.l	(a2,d0.w),d5
		move.b	(a0)+,d0
		or.l	(a3,d0.w),d5
		move.b	(a0)+,d0
		or.l	(a4,d0.w),d5
		movep.l	d5,o(a6)
o		SET o+7
		ENDR
o 	SET o+96+160
	ENDR

	jsr		copyLines
	rts



; swaps screens
; TRASHES:	d0
swapscreens:
		move.l	screenpointer,d0
		move.l	screenpointer2,screenpointer
		move.l	d0,screenpointer2
		
		move.l	screenpointershifter,d0
		move.l	screenpointer2shifter,screenpointershifter
		move.l	d0,screenpointer2shifter

		rts

; *************** CHUNKY CODE *****************
prepareChunkyTextureBPL1to4:
	lea cshift1,a0
	lea cshift2,a1
	lea	chunkybuffer2_1,a2
	lea chunkybuffer2_2,a3
	lea chunkypic,a5
	move.l	#4096-1,d7
.loop
		; first get the value from the buffer
		moveq	#0,d0
		move.b	(a5)+,d0
		move.l	(a0,d0.w),(a2)+
		move.l	(a1,d0.w),(a3)+
	dbra	d7,.loop


	lea chunkypic,a5
	move.l	#4096-1,d7
.loop2
		; first get the value from the buffer
		moveq	#0,d0
		move.b	(a5)+,d0
		move.l	(a0,d0.w),(a2)+
		move.l	(a1,d0.w),(a3)+
	dbra	d7,.loop2

	rts

prepareChunkyTextureBPL1to2
	lea	chunkypic,a0
	lea	TAB1,a1
	lea	chunkybuffer4_1,a2
	jsr	copyStuff

	lea	chunkypic,a0
	lea	TAB2,a1
	lea	chunkybuffer4_2,a2
	jsr	copyStuff

	lea	chunkypic,a0
	lea	TAB3,a1
	lea	chunkybuffer4_3,a2
	jsr	copyStuff

	lea	chunkypic,a0
	lea	TAB4,a1
	lea	chunkybuffer4_4,a2
	jsr	copyStuff

	rts

copyStuff
	move.l	#4096-1,d7
	move.l	a0,a3

.loop
	move.b	(a0)+,d0
	move.l	(a1,d0.w),(a2)+
	dbra	d7,.loop

	move.l	#4096-1,d7
	move.l	a3,a0

.loop2
	move.b	(a0)+,d0
	move.l	(a1,d0.w),(a2)+
	dbra	d7,.loop2


	rts


; thnx to ultra
c2p_1to1:
	lea		chunkypic2,a4
	move.l	screenpointer2,a2
    move.l 	tab1px_1p,d0					; c2p_1px_tab_aligned1
    move.l 	tab1px_2p,d1					; c2p_1px_tab_aligned2

y set 0
	REPT 64
a               set y
    	REPT    64/16
    		move.w  (a4)+,d0				;8
    		move.w  (a4)+,d1				;8
    		move.w  (a4)+,a0				;8
    		move.w	(a4)+,a1				;8
   		
    		move.l	d0,a3					;4
    		move.l  (a3),d7					;12
		
    		move.l	d1,a5					;4
    		or.l    (a5),d7					;16
		
    		or.l    (a0),d7					;16
    		or.l    $4000(a1),d7			;20
    		movep.l d7,a(a2) 				;24
	;-----------
   			move.w  (a4)+,d0				;8
    		move.w  (a4)+,d1				;8
    		move.w  (a4)+,a0				;8
    		move.w	(a4)+,a1				;8
   		
    		move.l	d0,a3					;4
    		move.l  (a3),d7					;12
		
    		move.l	d1,a5					;4
    		or.l    (a5),d7					;16
		
    		or.l    (a0),d7					;16
    		or.l    $4000(a1),d7			;20
    		movep.l d7,a+1(a2) 				;24 		32+16+20+60 = 48+80 = 128 => 256 for 16 px => 16 cycles per

a           set a+8
    endr
y set y+160
	endr
    rts


;64x32

chunkymul:
	lea		chunkypic,a0
	move.l	#2048*4-1,d7
.loop
		move.w (a0),d0

		add.w	d0,d0
		add.w	d0,d0
		move.w	d0,(a0)+
	dbra	d7,.loop

	lea		chunkypic2,a0
	move.l	#2048*4-1,d7
.loop2
		move.w (a0),d0

		add.w	d0,d0
		add.w	d0,d0
		move.w	d0,(a0)+
	dbra	d7,.loop2
	rts





;;;;;;;;;;;;;;;;;;;; RESTORE ALL REGISTERS CODE ;;;;;;;;;;;;;;;;;;;;;	

dosub	equ 0

init_atabs
	move.l	screenpointer2,d0
	add.l	#$10000,d0
	move.l	d0,a_tab1pointer
	move.l	d0,a1
	lea		TAB1,a0
	move.w	#16-1,d7
.loop1
		move.l	(a0)+,(a1)+
	dbra	d7,.loop1

	lea		TAB1,a0
	move.w	#16-1,d7
.loop1a
		move.l	(a0)+,(a1)+
	dbra	d7,.loop1a

	IFNE dosub
	move.l	screenpointer2,d1
	add.l	#$10000,d1
	add.l	#$10000,d1
	move.l	d1,a1
	lea		TAB1,a0
	move.w	#16-1,d7
.loop1b
		move.l	(a0)+,-(a1)
	dbra	d7,.loop1b
	ENDC

	add.l	#$10000,d0
	move.l	d0,a_tab2pointer
	move.l	d0,a1
	lea		TAB2,a0
	move.w	#16-1,d7
.loop2
		move.l	(a0)+,(a1)+
	dbra	d7,.loop2


	lea		TAB2,a0
	move.w	#16-1,d7
.loop2a
		move.l	(a0)+,(a1)+
	dbra	d7,.loop2a

	move.l	screenpointer2,d1
	add.l	#$10000,d1
	add.l	#$10000,d1
	add.l	#$10000,d1
	move.l	d1,a1
	lea		TAB2,a0
	move.w	#16-1,d7
.loop2b
		move.l	(a0)+,-(a1)
	dbra	d7,.loop2b


	add.l	#$10000,d0
	move.l	d0,a_tab3pointer
	move.l	d0,a1
	lea		TAB3,a0

	move.w	#16-1,d7
.loop3
		move.l	(a0)+,(a1)+
	dbra	d7,.loop3

	lea		TAB3,a0
	move.w	#16-1,d7
.loop3a
		move.l	(a0)+,(a1)+
	dbra	d7,.loop3a

	move.l	screenpointer2,d1
	add.l	#$10000,d1
	add.l	#$10000,d1
	add.l	#$10000,d1
	add.l	#$10000,d1
	move.l	d1,a1
	lea		TAB3,a0
	move.w	#16-1,d7
.loop3b
		move.l	(a0)+,-(a1)
	dbra	d7,.loop3b


	
	add.l	#$10000,d0
	move.l	d0,a_tab4pointer
	move.l	d0,a1
	lea		TAB4,a0

	move.w	#16-1,d7
.loop4
		move.l	(a0)+,(a1)+
	dbra	d7,.loop4

	lea		TAB4,a0
	move.w	#16-1,d7
.loop4a
		move.l	(a0)+,(a1)+
	dbra	d7,.loop4a

	move.l	screenpointer2,d1
	add.l	#$10000,d1
	add.l	#$10000,d1
	add.l	#$10000,d1
	add.l	#$10000,d1
	add.l	#$10000,d1
	move.l	d1,a1
	lea		TAB4,a0
	move.w	#16-1,d7
.loop4b
		move.l	(a0)+,-(a1)
	dbra	d7,.loop4b

	rts

generate1pxTabs
	move.l	#tab1px_1+65536,d0
	sub.w	d0,d0
	move.l	d0,tab1px_1p
	add.l	#$10000,d0
	move.l	d0,tab1px_2p

	jsr		calc1pxTab_lower
	rts

generate2pxTabs
	move.l	#tab2px_1+65536,d0
	move.w	#0,d0
	move.l	d0,tab2px_1p
	add.l	#$10000,d0
	move.l	d0,tab2px_2p

	move.l	tab2px_1p,a0
	lea		TAB1,a1
	lea		TAB2,a2
	jsr		calcTab

	move.l	tab2px_2p,a0
	lea		TAB3,a1
	lea		TAB4,a2
	jsr		calcTab
	rts

calc1pxTab_lower
	move.l 	tab1px_1p,a5
	lea     TAB1,a0
	move.w	#16-1,d7
	moveq   #0,d3
.oloop1
	moveq   #0,d4
	move.l	a5,a6
	move.w	#16-1,d6
.iloop1
			move.l  (a0,d3.w),d2
			and.l   #$80808080,d2
	
			move.l  (a0,d4.w),d5
			and.l   #$40404040,d5
			or.l    d5,d2
	
			move.l  d2,(a6)+
			addq.w  #4,d4
		dbra	d6,.iloop1

		lea     $0400(a5),a5
		addq.w  #4,d3
	dbra	d7,.oloop1
 

	move.l	tab1px_2p,a5
	lea     TAB2,a0
	moveq   #0,d3
	move.w	#16-1,d7
.oloop2
        moveq   #0,d4
        move.w	#16-1,d6
        move.l	a5,a6
.iloop2
        	move.l  0(a0,d3.w),d2
        	and.l   #$20202020,d2
 
        	move.l  0(a0,d4.w),d5
        	and.l   #$10101010,d5
        	or.l    d5,d2
 
        	move.l  d2,(a6)+
        	addq.w  #4,d4
        	dbra	d6,.iloop2
        lea     $0400(a5),a5
        addq.w  #4,d3
    dbra	d7,.oloop2

 
	movea.l #0,a5
	lea     TAB3,a0
	moveq   #0,d3
	move.w	#16-1,d7
.oloop3
		moveq   #0,d4
		move.l	a5,a6
		move.w	#16-1,d6
.iloop3
			move.l  0(a0,d3.w),d2
			and.l   #$08080808,d2
			
			move.l  0(a0,d4.w),d5
			and.l   #$04040404,d5
			or.l    d5,d2

			cmpa.l  #$00000400,a6
			blt     .nolsdo22
				move.l  d2,(a6)+
.nolsdo22:
	        addq.w  #4,d4
	    dbra	d6,.iloop3

        lea     $0400(a5),a5
        addq.w  #4,d3
      	dbra	d7,.oloop3
 


	lea     $00004000,a5
	lea     TAB4,a0
	moveq   #0,d3
	move.w	#16-1,d7
.oloop4
		moveq   #0,d4
		move.l	a5,a6
		move.w	#16-1,d6
.iloop4
			move.l  0(a0,d3.w),d2
			and.l   #$02020202,d2
			
			move.l  0(a0,d4.w),d5
			and.l   #$01010101,d5
			or.l    d5,d2
			
			move.l  d2,(a6)+
			addq.w  #4,d4
		dbra	d6,.iloop4
		lea     $0400(a5),a5
		addq.w  #4,d3
	dbra	d7,.oloop4
 	rts


calcTab
	moveq	#16-1,d7
	moveq	#0,d1
.outer
	moveq	#16-1,d6
	moveq	#0,d0
	move.l	a0,d3
.inner
			move.l	(a1,d1.w),d2
			or.l	(a2,d0.w),d2
			move.l	d2,(a0)+
			addq.w	#4,d0
		dbra	d6,.inner

		add.l	#%0000010000000000,d3
		move.l	d3,a0
		addq.w	#4,d1
	dbra	d7,.outer
	rts

calcTabLowMem
	move.l	#0,a0
	lea		TAB1,a1
	lea		TAB2,a2
	moveq	#16-1,d7
	moveq	#0,d1
.outer
	moveq	#16-1,d6
	moveq	#0,d0
	move.l	a0,d3
.inner
			move.l	(a1,d1.w),d2
			or.l	(a2,d0.w),d2


			cmpa.l  #$00000400,a0
			blt     .skip
				move.l  d2,(a0)+
.skip
			addq.w	#4,d0
		dbra	d6,.inner
		add.l	#%0000010000000000,d3
		move.l	d3,a0
		addq.w	#4,d1
	dbra	d7,.outer



	lea		TAB3,a1
	lea		TAB4,a2
	move.l	#$4000,a0
	moveq	#16-1,d7
	moveq	#0,d1
.outer1
	moveq	#16-1,d6
	moveq	#0,d0
	move.l	a0,d3
.inner1
			move.l	(a1,d1.w),d2
			or.l	(a2,d0.w),d2


			cmpa.l  #$00000400,a0
			blt     .skip
				move.l  d2,(a0)+
.skip
			addq.w	#4,d0
		dbra	d6,.inner1
		add.l	#%0000010000000000,d3
		move.l	d3,a0
		addq.w	#4,d1
	dbra	d7,.outer1





	rts


opt_calcTexture
	lea		chunkypic,a0
	lea		opt_tab1,a1
	lea		opt_tab2,a2
	lea		opt_tab3,a3
	lea		opt_tab4,a4
	move.w	#2048-1,d7
.loop
		moveq	#0,d0
		move.b	(a0)+,d0
		lsl.l	#2,d0
		move.l	d0,(a4)+
		lsl.l	#4,d0
		move.l	d0,(a3)+
		lsl.l	#4,d0
		move.l	d0,(a2)+
		lsl.l	#4,d0
		add.l	opt_c2ptable_pointer,d0				; 160000
		move.l	d0,(a1)+
	dbra	d7,.loop

	lea		chunkypic,a0
	move.w	#2048-1,d7
.loop2
		moveq	#0,d0
		move.b	(a0)+,d0
		lsl.l	#2,d0
		move.l	d0,(a4)+
		lsl.l	#4,d0
		move.l	d0,(a3)+
		lsl.l	#4,d0
		move.l	d0,(a2)+
		lsl.l	#4,d0
		add.l	opt_c2ptable_pointer,d0				; 160000
		move.l	d0,(a1)+
	dbra	d7,.loop2
	rts


opt_calcTexture_lowmem
	lea		chunkypic,a0
	lea		opt_tab1_lowmem,a1
	lea		opt_tab2_lowmem,a2

	move.l	opt_c2ptable_pointer,d1

	move.w	#2048-1,d7
.loop
		moveq	#0,d0
		move.b	(a0)+,d0		
		lsl.w	#2,d0			
		lsl.w	#4,d0			
		move.w	d0,2(a2)
		lsl.w	#4,d0			
		move.w	d0,(a2)
		add.w	#4,a2
		lsl.l	#4,d0			
		add.l	d1,d0			
		move.l	d0,(a1)+
	dbra	d7,.loop

	lea		chunkypic,a0
	move.w	#2048-1,d7
.loop2	
		moveq	#0,d0
		move.b	(a0)+,d0		
		lsl.w	#2,d0			
		lsl.w	#4,d0			
		move.w	d0,2(a2)
		lsl.w	#4,d0			
		move.w	d0,(a2)
		add.w	#4,a2
		lsl.l	#4,d0			
		add.l	d1,d0			
		move.l	d0,(a1)+
	dbra	d7,.loop2

	rts

opt_calcTab2
	lea		opt_c2ptable,a0
	move.l	a0,d1
	add.l	#$10000,d1
	move.w	#0,d1
	move.l	d1,opt_c2ptable_pointer
	move.l	d1,a4

	lea		TAB1,a3
	move.l	#16-1,d7
.l4
		lea		TAB2,a2
		move.l	#16-1,d6
		move.l	(a3)+,d3
.l3
			lea		TAB3,a1
			move.l	#16-1,d5
			move.l	(a2)+,d2
.l2
				lea		TAB4,a0
				move.l	#16-1,d4
				move.l	(a1)+,d1
.l1
					move.l	(a0)+,d0
					add.l	d1,d0
					add.l	d2,d0
					add.l	d3,d0
					move.l	d0,(a4)+
				dbra	d4,.l1
			dbra	d5,.l2
		dbra	d6,.l3
	dbra	d7,.l4

	rts

planarToChunky
	lea		planarpic+128,a0
	move.l	a0,a2
	lea		chunkypic,a1
	move.l	a1,a5
	move.l	#128-1,d6
.height
	move.l	#8-1,d7
.width
	movem.w	(a0)+,d0-d3		; 4 words
	REPT 16
		moveq	#0,d4
		moveq	#0,d5
		roxl.w	d5
		roxl.w	d3
		roxl.w	d4
		roxl.w	d2
		roxl.w	d4
		roxl.w	d1
		roxl.w	d4
		roxl.w	d0
		roxl.w	d4
		move.b	d4,(a1)+
	ENDR
	dbra	d7,.width

	; 320 width is 160 bytes
	; 128 width is 64 bytes
	; 160-64 added
	add.w	#160-64,a0
	dbra	d6,.height

	sub.l	a5,a1
	move.b	#0,$ffffc123
	rts




	SECTION DATA
	include		lib/lib.s


TAB1:
	dc.b	$00,$00,$00,$00		;0
	dc.b	$C0,$00,$00,$00		;4
	dc.b	$00,$C0,$00,$00		;8
	dc.b	$C0,$C0,$00,$00		;12
	dc.b	$00,$00,$C0,$00		;16
	dc.b	$C0,$00,$C0,$00		;20
	dc.b	$00,$C0,$C0,$00		;24
	dc.b	$C0,$C0,$C0,$00		;28
	dc.b	$00,$00,$00,$C0		;32
	dc.b	$C0,$00,$00,$C0		;36
	dc.b	$00,$C0,$00,$C0		;40
	dc.b	$C0,$C0,$00,$C0		;44
	dc.b	$00,$00,$C0,$C0		;48
	dc.b	$C0,$00,$C0,$C0		;52
	dc.b	$00,$C0,$C0,$C0		;56
	dc.b	$C0,$C0,$C0,$C0		;60
TAB2:
	dc.b	$00,$00,$00,$00		;0
	dc.b	$30,$00,$00,$00		;4
	dc.b	$00,$30,$00,$00		;8
	dc.b	$30,$30,$00,$00		;12
	dc.b	$00,$00,$30,$00		;16
	dc.b	$30,$00,$30,$00		;20
	dc.b	$00,$30,$30,$00		;24
	dc.b	$30,$30,$30,$00		;28
	dc.b	$00,$00,$00,$30		;32
	dc.b	$30,$00,$00,$30		;36
	dc.b	$00,$30,$00,$30		;40
	dc.b	$30,$30,$00,$30		;44
	dc.b	$00,$00,$30,$30		;48
	dc.b	$30,$00,$30,$30		;52
	dc.b	$00,$30,$30,$30		;56
	dc.b	$30,$30,$30,$30		;60
TAB3:
	DC.B	$00,$00,$00,$00		;0
	dc.b	$0C,$00,$00,$00		;4
	dc.b	$00,$0C,$00,$00		;8
	dc.b	$0C,$0C,$00,$00		;12
	dc.b	$00,$00,$0C,$00		;16
	dc.b	$0C,$00,$0C,$00		;20
	dc.b	$00,$0C,$0C,$00		;24
	dc.b	$0C,$0C,$0C,$00		;28
	dc.b	$00,$00,$00,$0C		;32
	dc.b	$0C,$00,$00,$0C		;36
	dc.b	$00,$0C,$00,$0C		;40
	dc.b	$0C,$0C,$00,$0C		;44
	dc.b	$00,$00,$0C,$0C		;48
	dc.b	$0C,$00,$0C,$0C		;52
	dc.b	$00,$0C,$0C,$0C		;56
	dc.b	$0C,$0C,$0C,$0C		;60
TAB4:
	dc.b	$00,$00,$00,$00		;0
	dc.b	$03,$00,$00,$00		;4
	dc.b	$00,$03,$00,$00		;8
	dc.b	$03,$03,$00,$00		;12
	dc.b	$00,$00,$03,$00		;16
	dc.b	$03,$00,$03,$00		;20
	dc.b	$00,$03,$03,$00		;24
	dc.b	$03,$03,$03,$00		;28
	dc.b	$00,$00,$00,$03		;32
	dc.b	$03,$00,$00,$03		;36
	dc.b	$00,$03,$00,$03		;40
	dc.b	$03,$03,$00,$03		;44
	dc.b	$00,$00,$03,$03		;48
	dc.b	$03,$00,$03,$03		;52
	dc.b	$00,$03,$03,$03		;56
	dc.b	$03,$03,$03,$03		;60

cshift1:
	dc.l	$00000000	;0
	dc.l	$f0000000	;1
	dc.l	$00f00000	;2
	dc.l	$f0f00000	;3
	dc.l	$0000f000	;4
	dc.l	$f000f000	;5
	dc.l	$00f0f000	;6
	dc.l	$f0f0f000	;7
	dc.l	$000000f0	;8
	dc.l	$f00000f0	;9
	dc.l	$00f000f0	;10
	dc.l	$f0f000f0	;11
	dc.l	$0000f0f0	;12
	dc.l	$f000f0f0	;13
	dc.l	$00f0f0f0	;14
	dc.l	$f0f0f0f0	;15

cshift2:
	dc.l	$00000000	;0
	dc.l	$0f000000	;1
	dc.l	$000f0000	;2
	dc.l	$0f0f0000	;3
	dc.l	$00000f00	;4
	dc.l	$0f000f00	;5
	dc.l	$000f0f00	;6
	dc.l	$0f0f0f00	;7
	dc.l	$0000000f	;8
	dc.l	$0f00000f	;9
	dc.l	$000f000f	;10
	dc.l	$0f0f000f	;11
	dc.l	$00000f0f	;12
	dc.l	$0f000f0f	;13
	dc.l	$000f0f0f	;14
	dc.l	$0f0f0f0f	;15


planarpic
;	incbin	gfx/wood.neo

chunkypic2

	REPT 4
	dc.b	1,1,2,3,4,5,6,7,8,9,11,11,12,13,14,15,1,1,2,3,4,5,6,7,8,9,11,11,12,13,14,15,1,1,2,3,4,5,6,7,8,9,11,11,12,13,14,15,1,1,2,3,4,5,6,7,8,9,11,11,12,13,14,15
	dc.b	1,1,3,2,5,4,7,6,9,8,11,11,13,12,15,14,1,1,3,2,5,4,7,6,9,8,11,11,13,12,15,14,1,1,3,2,5,4,7,6,9,8,11,11,13,12,15,14,1,1,3,2,5,4,7,6,9,8,11,11,13,12,15,14
	dc.b	2,3,1,1,6,7,4,5,11,11,8,9,14,15,12,13,2,3,1,1,6,7,4,5,11,11,8,9,14,15,12,13,2,3,1,1,6,7,4,5,11,11,8,9,14,15,12,13,2,3,1,1,6,7,4,5,11,11,8,9,14,15,12,13
	dc.b	3,2,1,1,7,6,5,4,11,11,9,8,15,14,13,12,3,2,1,1,7,6,5,4,11,11,9,8,15,14,13,12,3,2,1,1,7,6,5,4,11,11,9,8,15,14,13,12,3,2,1,1,7,6,5,4,11,11,9,8,15,14,13,12
	dc.b	4,5,6,7,1,1,2,3,12,13,14,15,8,9,11,11,4,5,6,7,1,1,2,3,12,13,14,15,8,9,11,11,4,5,6,7,1,1,2,3,12,13,14,15,8,9,11,11,4,5,6,7,1,1,2,3,12,13,14,15,8,9,11,11
	dc.b	5,4,7,6,1,1,3,2,13,12,15,14,9,8,11,11,5,4,7,6,1,1,3,2,13,12,15,14,9,8,11,11,5,4,7,6,1,1,3,2,13,12,15,14,9,8,11,11,5,4,7,6,1,1,3,2,13,12,15,14,9,8,11,11
	dc.b	6,7,4,5,2,3,1,1,14,15,12,13,11,11,8,9,6,7,4,5,2,3,1,1,14,15,12,13,11,11,8,9,6,7,4,5,2,3,1,1,14,15,12,13,11,11,8,9,6,7,4,5,2,3,1,1,14,15,12,13,11,11,8,9
	dc.b	7,6,5,4,3,2,1,1,15,14,13,12,11,11,9,8,7,6,5,4,3,2,1,1,15,14,13,12,11,11,9,8,7,6,5,4,3,2,1,1,15,14,13,12,11,11,9,8,7,6,5,4,3,2,1,1,15,14,13,12,11,11,9,8
	dc.b	8,9,11,11,12,13,14,15,1,1,2,3,4,5,6,7,8,9,11,11,12,13,14,15,1,1,2,3,4,5,6,7,8,9,11,11,12,13,14,15,1,1,2,3,4,5,6,7,8,9,11,11,12,13,14,15,1,1,2,3,4,5,6,7
	dc.b	9,8,11,11,13,12,15,14,1,1,3,2,5,4,7,6,9,8,11,11,13,12,15,14,1,1,3,2,5,4,7,6,9,8,11,11,13,12,15,14,1,1,3,2,5,4,7,6,9,8,11,11,13,12,15,14,1,1,3,2,5,4,7,6
	dc.b	11,11,8,9,14,15,12,13,2,3,1,1,6,7,4,5,11,11,8,9,14,15,12,13,2,3,1,1,6,7,4,5,11,11,8,9,14,15,12,13,2,3,1,1,6,7,4,5,11,11,8,9,14,15,12,13,2,3,1,1,6,7,4,5
	dc.b	11,11,9,8,15,14,13,12,3,2,1,1,7,6,5,4,11,11,9,8,15,14,13,12,3,2,1,1,7,6,5,4,11,11,9,8,15,14,13,12,3,2,1,1,7,6,5,4,11,11,9,8,15,14,13,12,3,2,1,1,7,6,5,4
	dc.b	12,13,14,15,8,9,11,11,4,5,6,7,1,1,2,3,12,13,14,15,8,9,11,11,4,5,6,7,1,1,2,3,12,13,14,15,8,9,11,11,4,5,6,7,1,1,2,3,12,13,14,15,8,9,11,11,4,5,6,7,1,1,2,3
	dc.b	13,12,15,14,9,8,11,11,5,4,7,6,1,1,3,2,13,12,15,14,9,8,11,11,5,4,7,6,1,1,3,2,13,12,15,14,9,8,11,11,5,4,7,6,1,1,3,2,13,12,15,14,9,8,11,11,5,4,7,6,1,1,3,2
	dc.b	14,15,12,13,11,11,8,9,6,7,4,5,2,3,1,1,14,15,12,13,11,11,8,9,6,7,4,5,2,3,1,1,14,15,12,13,11,11,8,9,6,7,4,5,2,3,1,1,14,15,12,13,11,11,8,9,6,7,4,5,2,3,1,1
	dc.b	15,14,13,12,11,11,9,8,7,6,5,4,3,2,1,1,15,14,13,12,11,11,9,8,7,6,5,4,3,2,1,1,15,14,13,12,11,11,9,8,7,6,5,4,3,2,1,1,15,14,13,12,11,11,9,8,7,6,5,4,3,2,1,1
	dc.b	1,1,2,3,4,5,6,7,8,9,11,11,12,13,14,15,1,1,2,3,4,5,6,7,8,9,11,11,12,13,14,15,1,1,2,3,4,5,6,7,8,9,11,11,12,13,14,15,1,1,2,3,4,5,6,7,8,9,11,11,12,13,14,15
	dc.b	1,1,3,2,5,4,7,6,9,8,11,11,13,12,15,14,1,1,3,2,5,4,7,6,9,8,11,11,13,12,15,14,1,1,3,2,5,4,7,6,9,8,11,11,13,12,15,14,1,1,3,2,5,4,7,6,9,8,11,11,13,12,15,14
	dc.b	2,3,1,1,6,7,4,5,11,11,8,9,14,15,12,13,2,3,1,1,6,7,4,5,11,11,8,9,14,15,12,13,2,3,1,1,6,7,4,5,11,11,8,9,14,15,12,13,2,3,1,1,6,7,4,5,11,11,8,9,14,15,12,13
	dc.b	3,2,1,1,7,6,5,4,11,11,9,8,15,14,13,12,3,2,1,1,7,6,5,4,11,11,9,8,15,14,13,12,3,2,1,1,7,6,5,4,11,11,9,8,15,14,13,12,3,2,1,1,7,6,5,4,11,11,9,8,15,14,13,12
	dc.b	4,5,6,7,1,1,2,3,12,13,14,15,8,9,11,11,4,5,6,7,1,1,2,3,12,13,14,15,8,9,11,11,4,5,6,7,1,1,2,3,12,13,14,15,8,9,11,11,4,5,6,7,1,1,2,3,12,13,14,15,8,9,11,11
	dc.b	5,4,7,6,1,1,3,2,13,12,15,14,9,8,11,11,5,4,7,6,1,1,3,2,13,12,15,14,9,8,11,11,5,4,7,6,1,1,3,2,13,12,15,14,9,8,11,11,5,4,7,6,1,1,3,2,13,12,15,14,9,8,11,11
	dc.b	6,7,4,5,2,3,1,1,14,15,12,13,11,11,8,9,6,7,4,5,2,3,1,1,14,15,12,13,11,11,8,9,6,7,4,5,2,3,1,1,14,15,12,13,11,11,8,9,6,7,4,5,2,3,1,1,14,15,12,13,11,11,8,9
	dc.b	7,6,5,4,3,2,1,1,15,14,13,12,11,11,9,8,7,6,5,4,3,2,1,1,15,14,13,12,11,11,9,8,7,6,5,4,3,2,1,1,15,14,13,12,11,11,9,8,7,6,5,4,3,2,1,1,15,14,13,12,11,11,9,8
	dc.b	8,9,11,11,12,13,14,15,1,1,2,3,4,5,6,7,8,9,11,11,12,13,14,15,1,1,2,3,4,5,6,7,8,9,11,11,12,13,14,15,1,1,2,3,4,5,6,7,8,9,11,11,12,13,14,15,1,1,2,3,4,5,6,7
	dc.b	9,8,11,11,13,12,15,14,1,1,3,2,5,4,7,6,9,8,11,11,13,12,15,14,1,1,3,2,5,4,7,6,9,8,11,11,13,12,15,14,1,1,3,2,5,4,7,6,9,8,11,11,13,12,15,14,1,1,3,2,5,4,7,6
	dc.b	11,11,8,9,14,15,12,13,2,3,1,1,6,7,4,5,11,11,8,9,14,15,12,13,2,3,1,1,6,7,4,5,11,11,8,9,14,15,12,13,2,3,1,1,6,7,4,5,11,11,8,9,14,15,12,13,2,3,1,1,6,7,4,5
	dc.b	11,11,9,8,15,14,13,12,3,2,1,1,7,6,5,4,11,11,9,8,15,14,13,12,3,2,1,1,7,6,5,4,11,11,9,8,15,14,13,12,3,2,1,1,7,6,5,4,11,11,9,8,15,14,13,12,3,2,1,1,7,6,5,4
	dc.b	12,13,14,15,8,9,11,11,4,5,6,7,1,1,2,3,12,13,14,15,8,9,11,11,4,5,6,7,1,1,2,3,12,13,14,15,8,9,11,11,4,5,6,7,1,1,2,3,12,13,14,15,8,9,11,11,4,5,6,7,1,1,2,3
	dc.b	13,12,15,14,9,8,11,11,5,4,7,6,1,1,3,2,13,12,15,14,9,8,11,11,5,4,7,6,1,1,3,2,13,12,15,14,9,8,11,11,5,4,7,6,1,1,3,2,13,12,15,14,9,8,11,11,5,4,7,6,1,1,3,2
	dc.b	14,15,12,13,11,11,8,9,6,7,4,5,2,3,1,1,14,15,12,13,11,11,8,9,6,7,4,5,2,3,1,1,14,15,12,13,11,11,8,9,6,7,4,5,2,3,1,1,14,15,12,13,11,11,8,9,6,7,4,5,2,3,1,1
	dc.b	15,14,13,12,11,11,9,8,7,6,5,4,3,2,1,1,15,14,13,12,11,11,9,8,7,6,5,4,3,2,1,1,15,14,13,12,11,11,9,8,7,6,5,4,3,2,1,1,15,14,13,12,11,11,9,8,7,6,5,4,3,2,1,1
	dc.b	1,1,2,3,4,5,6,7,8,9,11,11,12,13,14,15,1,1,2,3,4,5,6,7,8,9,11,11,12,13,14,15,1,1,2,3,4,5,6,7,8,9,11,11,12,13,14,15,1,1,2,3,4,5,6,7,8,9,11,11,12,13,14,15
	dc.b	1,1,3,2,5,4,7,6,9,8,11,11,13,12,15,14,1,1,3,2,5,4,7,6,9,8,11,11,13,12,15,14,1,1,3,2,5,4,7,6,9,8,11,11,13,12,15,14,1,1,3,2,5,4,7,6,9,8,11,11,13,12,15,14
	dc.b	2,3,1,1,6,7,4,5,11,11,8,9,14,15,12,13,2,3,1,1,6,7,4,5,11,11,8,9,14,15,12,13,2,3,1,1,6,7,4,5,11,11,8,9,14,15,12,13,2,3,1,1,6,7,4,5,11,11,8,9,14,15,12,13
	dc.b	3,2,1,1,7,6,5,4,11,11,9,8,15,14,13,12,3,2,1,1,7,6,5,4,11,11,9,8,15,14,13,12,3,2,1,1,7,6,5,4,11,11,9,8,15,14,13,12,3,2,1,1,7,6,5,4,11,11,9,8,15,14,13,12
	dc.b	4,5,6,7,1,1,2,3,12,13,14,15,8,9,11,11,4,5,6,7,1,1,2,3,12,13,14,15,8,9,11,11,4,5,6,7,1,1,2,3,12,13,14,15,8,9,11,11,4,5,6,7,1,1,2,3,12,13,14,15,8,9,11,11
	dc.b	5,4,7,6,1,1,3,2,13,12,15,14,9,8,11,11,5,4,7,6,1,1,3,2,13,12,15,14,9,8,11,11,5,4,7,6,1,1,3,2,13,12,15,14,9,8,11,11,5,4,7,6,1,1,3,2,13,12,15,14,9,8,11,11
	dc.b	6,7,4,5,2,3,1,1,14,15,12,13,11,11,8,9,6,7,4,5,2,3,1,1,14,15,12,13,11,11,8,9,6,7,4,5,2,3,1,1,14,15,12,13,11,11,8,9,6,7,4,5,2,3,1,1,14,15,12,13,11,11,8,9
	dc.b	7,6,5,4,3,2,1,1,15,14,13,12,11,11,9,8,7,6,5,4,3,2,1,1,15,14,13,12,11,11,9,8,7,6,5,4,3,2,1,1,15,14,13,12,11,11,9,8,7,6,5,4,3,2,1,1,15,14,13,12,11,11,9,8
	dc.b	8,9,11,11,12,13,14,15,1,1,2,3,4,5,6,7,8,9,11,11,12,13,14,15,1,1,2,3,4,5,6,7,8,9,11,11,12,13,14,15,1,1,2,3,4,5,6,7,8,9,11,11,12,13,14,15,1,1,2,3,4,5,6,7
	dc.b	9,8,11,11,13,12,15,14,1,1,3,2,5,4,7,6,9,8,11,11,13,12,15,14,1,1,3,2,5,4,7,6,9,8,11,11,13,12,15,14,1,1,3,2,5,4,7,6,9,8,11,11,13,12,15,14,1,1,3,2,5,4,7,6
	dc.b	11,11,8,9,14,15,12,13,2,3,1,1,6,7,4,5,11,11,8,9,14,15,12,13,2,3,1,1,6,7,4,5,11,11,8,9,14,15,12,13,2,3,1,1,6,7,4,5,11,11,8,9,14,15,12,13,2,3,1,1,6,7,4,5
	dc.b	11,11,9,8,15,14,13,12,3,2,1,1,7,6,5,4,11,11,9,8,15,14,13,12,3,2,1,1,7,6,5,4,11,11,9,8,15,14,13,12,3,2,1,1,7,6,5,4,11,11,9,8,15,14,13,12,3,2,1,1,7,6,5,4
	dc.b	12,13,14,15,8,9,11,11,4,5,6,7,1,1,2,3,12,13,14,15,8,9,11,11,4,5,6,7,1,1,2,3,12,13,14,15,8,9,11,11,4,5,6,7,1,1,2,3,12,13,14,15,8,9,11,11,4,5,6,7,1,1,2,3
	dc.b	13,12,15,14,9,8,11,11,5,4,7,6,1,1,3,2,13,12,15,14,9,8,11,11,5,4,7,6,1,1,3,2,13,12,15,14,9,8,11,11,5,4,7,6,1,1,3,2,13,12,15,14,9,8,11,11,5,4,7,6,1,1,3,2
	dc.b	14,15,12,13,11,11,8,9,6,7,4,5,2,3,1,1,14,15,12,13,11,11,8,9,6,7,4,5,2,3,1,1,14,15,12,13,11,11,8,9,6,7,4,5,2,3,1,1,14,15,12,13,11,11,8,9,6,7,4,5,2,3,1,1
	dc.b	15,14,13,12,11,11,9,8,7,6,5,4,3,2,1,1,15,14,13,12,11,11,9,8,7,6,5,4,3,2,1,1,15,14,13,12,11,11,9,8,7,6,5,4,3,2,1,1,15,14,13,12,11,11,9,8,7,6,5,4,3,2,1,1
	dc.b	1,1,2,3,4,5,6,7,8,9,11,11,12,13,14,15,1,1,2,3,4,5,6,7,8,9,11,11,12,13,14,15,1,1,2,3,4,5,6,7,8,9,11,11,12,13,14,15,1,1,2,3,4,5,6,7,8,9,11,11,12,13,14,15
	dc.b	1,1,3,2,5,4,7,6,9,8,11,11,13,12,15,14,1,1,3,2,5,4,7,6,9,8,11,11,13,12,15,14,1,1,3,2,5,4,7,6,9,8,11,11,13,12,15,14,1,1,3,2,5,4,7,6,9,8,11,11,13,12,15,14
	dc.b	2,3,1,1,6,7,4,5,11,11,8,9,14,15,12,13,2,3,1,1,6,7,4,5,11,11,8,9,14,15,12,13,2,3,1,1,6,7,4,5,11,11,8,9,14,15,12,13,2,3,1,1,6,7,4,5,11,11,8,9,14,15,12,13
	dc.b	3,2,1,1,7,6,5,4,11,11,9,8,15,14,13,12,3,2,1,1,7,6,5,4,11,11,9,8,15,14,13,12,3,2,1,1,7,6,5,4,11,11,9,8,15,14,13,12,3,2,1,1,7,6,5,4,11,11,9,8,15,14,13,12
	dc.b	4,5,6,7,1,1,2,3,12,13,14,15,8,9,11,11,4,5,6,7,1,1,2,3,12,13,14,15,8,9,11,11,4,5,6,7,1,1,2,3,12,13,14,15,8,9,11,11,4,5,6,7,1,1,2,3,12,13,14,15,8,9,11,11
	dc.b	5,4,7,6,1,1,3,2,13,12,15,14,9,8,11,11,5,4,7,6,1,1,3,2,13,12,15,14,9,8,11,11,5,4,7,6,1,1,3,2,13,12,15,14,9,8,11,11,5,4,7,6,1,1,3,2,13,12,15,14,9,8,11,11
	dc.b	6,7,4,5,2,3,1,1,14,15,12,13,11,11,8,9,6,7,4,5,2,3,1,1,14,15,12,13,11,11,8,9,6,7,4,5,2,3,1,1,14,15,12,13,11,11,8,9,6,7,4,5,2,3,1,1,14,15,12,13,11,11,8,9
	dc.b	7,6,5,4,3,2,1,1,15,14,13,12,11,11,9,8,7,6,5,4,3,2,1,1,15,14,13,12,11,11,9,8,7,6,5,4,3,2,1,1,15,14,13,12,11,11,9,8,7,6,5,4,3,2,1,1,15,14,13,12,11,11,9,8
	dc.b	8,9,11,11,12,13,14,15,1,1,2,3,4,5,6,7,8,9,11,11,12,13,14,15,1,1,2,3,4,5,6,7,8,9,11,11,12,13,14,15,1,1,2,3,4,5,6,7,8,9,11,11,12,13,14,15,1,1,2,3,4,5,6,7
	dc.b	9,8,11,11,13,12,15,14,1,1,3,2,5,4,7,6,9,8,11,11,13,12,15,14,1,1,3,2,5,4,7,6,9,8,11,11,13,12,15,14,1,1,3,2,5,4,7,6,9,8,11,11,13,12,15,14,1,1,3,2,5,4,7,6
	dc.b	11,11,8,9,14,15,12,13,2,3,1,1,6,7,4,5,11,11,8,9,14,15,12,13,2,3,1,1,6,7,4,5,11,11,8,9,14,15,12,13,2,3,1,1,6,7,4,5,11,11,8,9,14,15,12,13,2,3,1,1,6,7,4,5
	dc.b	11,11,9,8,15,14,13,12,3,2,1,1,7,6,5,4,11,11,9,8,15,14,13,12,3,2,1,1,7,6,5,4,11,11,9,8,15,14,13,12,3,2,1,1,7,6,5,4,11,11,9,8,15,14,13,12,3,2,1,1,7,6,5,4
	dc.b	12,13,14,15,8,9,11,11,4,5,6,7,1,1,2,3,12,13,14,15,8,9,11,11,4,5,6,7,1,1,2,3,12,13,14,15,8,9,11,11,4,5,6,7,1,1,2,3,12,13,14,15,8,9,11,11,4,5,6,7,1,1,2,3
	dc.b	13,12,15,14,9,8,11,11,5,4,7,6,1,1,3,2,13,12,15,14,9,8,11,11,5,4,7,6,1,1,3,2,13,12,15,14,9,8,11,11,5,4,7,6,1,1,3,2,13,12,15,14,9,8,11,11,5,4,7,6,1,1,3,2
	dc.b	14,15,12,13,11,11,8,9,6,7,4,5,2,3,1,1,14,15,12,13,11,11,8,9,6,7,4,5,2,3,1,1,14,15,12,13,11,11,8,9,6,7,4,5,2,3,1,1,14,15,12,13,11,11,8,9,6,7,4,5,2,3,1,1
	dc.b	15,14,13,12,11,11,9,8,7,6,5,4,3,2,1,1,15,14,13,12,11,11,9,8,7,6,5,4,3,2,1,1,15,14,13,12,11,11,9,8,7,6,5,4,3,2,1,1,15,14,13,12,11,11,9,8,7,6,5,4,3,2,1,1
	ENDR

chunkypic
	REPT 4
	dc.b	0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15
	dc.b	1,0,3,2,5,4,7,6,9,8,11,10,13,12,15,14,1,0,3,2,5,4,7,6,9,8,11,10,13,12,15,14,1,0,3,2,5,4,7,6,9,8,11,10,13,12,15,14,1,0,3,2,5,4,7,6,9,8,11,10,13,12,15,14
	dc.b	2,3,0,1,6,7,4,5,10,11,8,9,14,15,12,13,2,3,0,1,6,7,4,5,10,11,8,9,14,15,12,13,2,3,0,1,6,7,4,5,10,11,8,9,14,15,12,13,2,3,0,1,6,7,4,5,10,11,8,9,14,15,12,13
	dc.b	3,2,1,0,7,6,5,4,11,10,9,8,15,14,13,12,3,2,1,0,7,6,5,4,11,10,9,8,15,14,13,12,3,2,1,0,7,6,5,4,11,10,9,8,15,14,13,12,3,2,1,0,7,6,5,4,11,10,9,8,15,14,13,12
	dc.b	4,5,6,7,0,1,2,3,12,13,14,15,8,9,10,11,4,5,6,7,0,1,2,3,12,13,14,15,8,9,10,11,4,5,6,7,0,1,2,3,12,13,14,15,8,9,10,11,4,5,6,7,0,1,2,3,12,13,14,15,8,9,10,11
	dc.b	5,4,7,6,1,0,3,2,13,12,15,14,9,8,11,10,5,4,7,6,1,0,3,2,13,12,15,14,9,8,11,10,5,4,7,6,1,0,3,2,13,12,15,14,9,8,11,10,5,4,7,6,1,0,3,2,13,12,15,14,9,8,11,10
	dc.b	6,7,4,5,2,3,0,1,14,15,12,13,10,11,8,9,6,7,4,5,2,3,0,1,14,15,12,13,10,11,8,9,6,7,4,5,2,3,0,1,14,15,12,13,10,11,8,9,6,7,4,5,2,3,0,1,14,15,12,13,10,11,8,9
	dc.b	7,6,5,4,3,2,1,0,15,14,13,12,11,10,9,8,7,6,5,4,3,2,1,0,15,14,13,12,11,10,9,8,7,6,5,4,3,2,1,0,15,14,13,12,11,10,9,8,7,6,5,4,3,2,1,0,15,14,13,12,11,10,9,8
	dc.b	8,9,10,11,12,13,14,15,0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,0,1,2,3,4,5,6,7
	dc.b	9,8,11,10,13,12,15,14,1,0,3,2,5,4,7,6,9,8,11,10,13,12,15,14,1,0,3,2,5,4,7,6,9,8,11,10,13,12,15,14,1,0,3,2,5,4,7,6,9,8,11,10,13,12,15,14,1,0,3,2,5,4,7,6
	dc.b	10,11,8,9,14,15,12,13,2,3,0,1,6,7,4,5,10,11,8,9,14,15,12,13,2,3,0,1,6,7,4,5,10,11,8,9,14,15,12,13,2,3,0,1,6,7,4,5,10,11,8,9,14,15,12,13,2,3,0,1,6,7,4,5
	dc.b	11,10,9,8,15,14,13,12,3,2,1,0,7,6,5,4,11,10,9,8,15,14,13,12,3,2,1,0,7,6,5,4,11,10,9,8,15,14,13,12,3,2,1,0,7,6,5,4,11,10,9,8,15,14,13,12,3,2,1,0,7,6,5,4
	dc.b	12,13,14,15,8,9,10,11,4,5,6,7,0,1,2,3,12,13,14,15,8,9,10,11,4,5,6,7,0,1,2,3,12,13,14,15,8,9,10,11,4,5,6,7,0,1,2,3,12,13,14,15,8,9,10,11,4,5,6,7,0,1,2,3
	dc.b	13,12,15,14,9,8,11,10,5,4,7,6,1,0,3,2,13,12,15,14,9,8,11,10,5,4,7,6,1,0,3,2,13,12,15,14,9,8,11,10,5,4,7,6,1,0,3,2,13,12,15,14,9,8,11,10,5,4,7,6,1,0,3,2
	dc.b	14,15,12,13,10,11,8,9,6,7,4,5,2,3,0,1,14,15,12,13,10,11,8,9,6,7,4,5,2,3,0,1,14,15,12,13,10,11,8,9,6,7,4,5,2,3,0,1,14,15,12,13,10,11,8,9,6,7,4,5,2,3,0,1
	dc.b	15,14,13,12,11,10,9,8,7,6,5,4,3,2,1,0,15,14,13,12,11,10,9,8,7,6,5,4,3,2,1,0,15,14,13,12,11,10,9,8,7,6,5,4,3,2,1,0,15,14,13,12,11,10,9,8,7,6,5,4,3,2,1,0
	dc.b	0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15
	dc.b	1,0,3,2,5,4,7,6,9,8,11,10,13,12,15,14,1,0,3,2,5,4,7,6,9,8,11,10,13,12,15,14,1,0,3,2,5,4,7,6,9,8,11,10,13,12,15,14,1,0,3,2,5,4,7,6,9,8,11,10,13,12,15,14
	dc.b	2,3,0,1,6,7,4,5,10,11,8,9,14,15,12,13,2,3,0,1,6,7,4,5,10,11,8,9,14,15,12,13,2,3,0,1,6,7,4,5,10,11,8,9,14,15,12,13,2,3,0,1,6,7,4,5,10,11,8,9,14,15,12,13
	dc.b	3,2,1,0,7,6,5,4,11,10,9,8,15,14,13,12,3,2,1,0,7,6,5,4,11,10,9,8,15,14,13,12,3,2,1,0,7,6,5,4,11,10,9,8,15,14,13,12,3,2,1,0,7,6,5,4,11,10,9,8,15,14,13,12
	dc.b	4,5,6,7,0,1,2,3,12,13,14,15,8,9,10,11,4,5,6,7,0,1,2,3,12,13,14,15,8,9,10,11,4,5,6,7,0,1,2,3,12,13,14,15,8,9,10,11,4,5,6,7,0,1,2,3,12,13,14,15,8,9,10,11
	dc.b	5,4,7,6,1,0,3,2,13,12,15,14,9,8,11,10,5,4,7,6,1,0,3,2,13,12,15,14,9,8,11,10,5,4,7,6,1,0,3,2,13,12,15,14,9,8,11,10,5,4,7,6,1,0,3,2,13,12,15,14,9,8,11,10
	dc.b	6,7,4,5,2,3,0,1,14,15,12,13,10,11,8,9,6,7,4,5,2,3,0,1,14,15,12,13,10,11,8,9,6,7,4,5,2,3,0,1,14,15,12,13,10,11,8,9,6,7,4,5,2,3,0,1,14,15,12,13,10,11,8,9
	dc.b	7,6,5,4,3,2,1,0,15,14,13,12,11,10,9,8,7,6,5,4,3,2,1,0,15,14,13,12,11,10,9,8,7,6,5,4,3,2,1,0,15,14,13,12,11,10,9,8,7,6,5,4,3,2,1,0,15,14,13,12,11,10,9,8
	dc.b	8,9,10,11,12,13,14,15,0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,0,1,2,3,4,5,6,7
	dc.b	9,8,11,10,13,12,15,14,1,0,3,2,5,4,7,6,9,8,11,10,13,12,15,14,1,0,3,2,5,4,7,6,9,8,11,10,13,12,15,14,1,0,3,2,5,4,7,6,9,8,11,10,13,12,15,14,1,0,3,2,5,4,7,6
	dc.b	10,11,8,9,14,15,12,13,2,3,0,1,6,7,4,5,10,11,8,9,14,15,12,13,2,3,0,1,6,7,4,5,10,11,8,9,14,15,12,13,2,3,0,1,6,7,4,5,10,11,8,9,14,15,12,13,2,3,0,1,6,7,4,5
	dc.b	11,10,9,8,15,14,13,12,3,2,1,0,7,6,5,4,11,10,9,8,15,14,13,12,3,2,1,0,7,6,5,4,11,10,9,8,15,14,13,12,3,2,1,0,7,6,5,4,11,10,9,8,15,14,13,12,3,2,1,0,7,6,5,4
	dc.b	12,13,14,15,8,9,10,11,4,5,6,7,0,1,2,3,12,13,14,15,8,9,10,11,4,5,6,7,0,1,2,3,12,13,14,15,8,9,10,11,4,5,6,7,0,1,2,3,12,13,14,15,8,9,10,11,4,5,6,7,0,1,2,3
	dc.b	13,12,15,14,9,8,11,10,5,4,7,6,1,0,3,2,13,12,15,14,9,8,11,10,5,4,7,6,1,0,3,2,13,12,15,14,9,8,11,10,5,4,7,6,1,0,3,2,13,12,15,14,9,8,11,10,5,4,7,6,1,0,3,2
	dc.b	14,15,12,13,10,11,8,9,6,7,4,5,2,3,0,1,14,15,12,13,10,11,8,9,6,7,4,5,2,3,0,1,14,15,12,13,10,11,8,9,6,7,4,5,2,3,0,1,14,15,12,13,10,11,8,9,6,7,4,5,2,3,0,1
	dc.b	15,14,13,12,11,10,9,8,7,6,5,4,3,2,1,0,15,14,13,12,11,10,9,8,7,6,5,4,3,2,1,0,15,14,13,12,11,10,9,8,7,6,5,4,3,2,1,0,15,14,13,12,11,10,9,8,7,6,5,4,3,2,1,0
	dc.b	0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15
	dc.b	1,0,3,2,5,4,7,6,9,8,11,10,13,12,15,14,1,0,3,2,5,4,7,6,9,8,11,10,13,12,15,14,1,0,3,2,5,4,7,6,9,8,11,10,13,12,15,14,1,0,3,2,5,4,7,6,9,8,11,10,13,12,15,14
	dc.b	2,3,0,1,6,7,4,5,10,11,8,9,14,15,12,13,2,3,0,1,6,7,4,5,10,11,8,9,14,15,12,13,2,3,0,1,6,7,4,5,10,11,8,9,14,15,12,13,2,3,0,1,6,7,4,5,10,11,8,9,14,15,12,13
	dc.b	3,2,1,0,7,6,5,4,11,10,9,8,15,14,13,12,3,2,1,0,7,6,5,4,11,10,9,8,15,14,13,12,3,2,1,0,7,6,5,4,11,10,9,8,15,14,13,12,3,2,1,0,7,6,5,4,11,10,9,8,15,14,13,12
	dc.b	4,5,6,7,0,1,2,3,12,13,14,15,8,9,10,11,4,5,6,7,0,1,2,3,12,13,14,15,8,9,10,11,4,5,6,7,0,1,2,3,12,13,14,15,8,9,10,11,4,5,6,7,0,1,2,3,12,13,14,15,8,9,10,11
	dc.b	5,4,7,6,1,0,3,2,13,12,15,14,9,8,11,10,5,4,7,6,1,0,3,2,13,12,15,14,9,8,11,10,5,4,7,6,1,0,3,2,13,12,15,14,9,8,11,10,5,4,7,6,1,0,3,2,13,12,15,14,9,8,11,10
	dc.b	6,7,4,5,2,3,0,1,14,15,12,13,10,11,8,9,6,7,4,5,2,3,0,1,14,15,12,13,10,11,8,9,6,7,4,5,2,3,0,1,14,15,12,13,10,11,8,9,6,7,4,5,2,3,0,1,14,15,12,13,10,11,8,9
	dc.b	7,6,5,4,3,2,1,0,15,14,13,12,11,10,9,8,7,6,5,4,3,2,1,0,15,14,13,12,11,10,9,8,7,6,5,4,3,2,1,0,15,14,13,12,11,10,9,8,7,6,5,4,3,2,1,0,15,14,13,12,11,10,9,8
	dc.b	8,9,10,11,12,13,14,15,0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,0,1,2,3,4,5,6,7
	dc.b	9,8,11,10,13,12,15,14,1,0,3,2,5,4,7,6,9,8,11,10,13,12,15,14,1,0,3,2,5,4,7,6,9,8,11,10,13,12,15,14,1,0,3,2,5,4,7,6,9,8,11,10,13,12,15,14,1,0,3,2,5,4,7,6
	dc.b	10,11,8,9,14,15,12,13,2,3,0,1,6,7,4,5,10,11,8,9,14,15,12,13,2,3,0,1,6,7,4,5,10,11,8,9,14,15,12,13,2,3,0,1,6,7,4,5,10,11,8,9,14,15,12,13,2,3,0,1,6,7,4,5
	dc.b	11,10,9,8,15,14,13,12,3,2,1,0,7,6,5,4,11,10,9,8,15,14,13,12,3,2,1,0,7,6,5,4,11,10,9,8,15,14,13,12,3,2,1,0,7,6,5,4,11,10,9,8,15,14,13,12,3,2,1,0,7,6,5,4
	dc.b	12,13,14,15,8,9,10,11,4,5,6,7,0,1,2,3,12,13,14,15,8,9,10,11,4,5,6,7,0,1,2,3,12,13,14,15,8,9,10,11,4,5,6,7,0,1,2,3,12,13,14,15,8,9,10,11,4,5,6,7,0,1,2,3
	dc.b	13,12,15,14,9,8,11,10,5,4,7,6,1,0,3,2,13,12,15,14,9,8,11,10,5,4,7,6,1,0,3,2,13,12,15,14,9,8,11,10,5,4,7,6,1,0,3,2,13,12,15,14,9,8,11,10,5,4,7,6,1,0,3,2
	dc.b	14,15,12,13,10,11,8,9,6,7,4,5,2,3,0,1,14,15,12,13,10,11,8,9,6,7,4,5,2,3,0,1,14,15,12,13,10,11,8,9,6,7,4,5,2,3,0,1,14,15,12,13,10,11,8,9,6,7,4,5,2,3,0,1
	dc.b	15,14,13,12,11,10,9,8,7,6,5,4,3,2,1,0,15,14,13,12,11,10,9,8,7,6,5,4,3,2,1,0,15,14,13,12,11,10,9,8,7,6,5,4,3,2,1,0,15,14,13,12,11,10,9,8,7,6,5,4,3,2,1,0
	dc.b	0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15
	dc.b	1,0,3,2,5,4,7,6,9,8,11,10,13,12,15,14,1,0,3,2,5,4,7,6,9,8,11,10,13,12,15,14,1,0,3,2,5,4,7,6,9,8,11,10,13,12,15,14,1,0,3,2,5,4,7,6,9,8,11,10,13,12,15,14
	dc.b	2,3,0,1,6,7,4,5,10,11,8,9,14,15,12,13,2,3,0,1,6,7,4,5,10,11,8,9,14,15,12,13,2,3,0,1,6,7,4,5,10,11,8,9,14,15,12,13,2,3,0,1,6,7,4,5,10,11,8,9,14,15,12,13
	dc.b	3,2,1,0,7,6,5,4,11,10,9,8,15,14,13,12,3,2,1,0,7,6,5,4,11,10,9,8,15,14,13,12,3,2,1,0,7,6,5,4,11,10,9,8,15,14,13,12,3,2,1,0,7,6,5,4,11,10,9,8,15,14,13,12
	dc.b	4,5,6,7,0,1,2,3,12,13,14,15,8,9,10,11,4,5,6,7,0,1,2,3,12,13,14,15,8,9,10,11,4,5,6,7,0,1,2,3,12,13,14,15,8,9,10,11,4,5,6,7,0,1,2,3,12,13,14,15,8,9,10,11
	dc.b	5,4,7,6,1,0,3,2,13,12,15,14,9,8,11,10,5,4,7,6,1,0,3,2,13,12,15,14,9,8,11,10,5,4,7,6,1,0,3,2,13,12,15,14,9,8,11,10,5,4,7,6,1,0,3,2,13,12,15,14,9,8,11,10
	dc.b	6,7,4,5,2,3,0,1,14,15,12,13,10,11,8,9,6,7,4,5,2,3,0,1,14,15,12,13,10,11,8,9,6,7,4,5,2,3,0,1,14,15,12,13,10,11,8,9,6,7,4,5,2,3,0,1,14,15,12,13,10,11,8,9
	dc.b	7,6,5,4,3,2,1,0,15,14,13,12,11,10,9,8,7,6,5,4,3,2,1,0,15,14,13,12,11,10,9,8,7,6,5,4,3,2,1,0,15,14,13,12,11,10,9,8,7,6,5,4,3,2,1,0,15,14,13,12,11,10,9,8
	dc.b	8,9,10,11,12,13,14,15,0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,0,1,2,3,4,5,6,7
	dc.b	9,8,11,10,13,12,15,14,1,0,3,2,5,4,7,6,9,8,11,10,13,12,15,14,1,0,3,2,5,4,7,6,9,8,11,10,13,12,15,14,1,0,3,2,5,4,7,6,9,8,11,10,13,12,15,14,1,0,3,2,5,4,7,6
	dc.b	10,11,8,9,14,15,12,13,2,3,0,1,6,7,4,5,10,11,8,9,14,15,12,13,2,3,0,1,6,7,4,5,10,11,8,9,14,15,12,13,2,3,0,1,6,7,4,5,10,11,8,9,14,15,12,13,2,3,0,1,6,7,4,5
	dc.b	11,10,9,8,15,14,13,12,3,2,1,0,7,6,5,4,11,10,9,8,15,14,13,12,3,2,1,0,7,6,5,4,11,10,9,8,15,14,13,12,3,2,1,0,7,6,5,4,11,10,9,8,15,14,13,12,3,2,1,0,7,6,5,4
	dc.b	12,13,14,15,8,9,10,11,4,5,6,7,0,1,2,3,12,13,14,15,8,9,10,11,4,5,6,7,0,1,2,3,12,13,14,15,8,9,10,11,4,5,6,7,0,1,2,3,12,13,14,15,8,9,10,11,4,5,6,7,0,1,2,3
	dc.b	13,12,15,14,9,8,11,10,5,4,7,6,1,0,3,2,13,12,15,14,9,8,11,10,5,4,7,6,1,0,3,2,13,12,15,14,9,8,11,10,5,4,7,6,1,0,3,2,13,12,15,14,9,8,11,10,5,4,7,6,1,0,3,2
	dc.b	14,15,12,13,10,11,8,9,6,7,4,5,2,3,0,1,14,15,12,13,10,11,8,9,6,7,4,5,2,3,0,1,14,15,12,13,10,11,8,9,6,7,4,5,2,3,0,1,14,15,12,13,10,11,8,9,6,7,4,5,2,3,0,1
	dc.b	15,14,13,12,11,10,9,8,7,6,5,4,3,2,1,0,15,14,13,12,11,10,9,8,7,6,5,4,3,2,1,0,15,14,13,12,11,10,9,8,7,6,5,4,3,2,1,0,15,14,13,12,11,10,9,8,7,6,5,4,3,2,1,0
	ENDR

	even
tunnelpallette:
	dc.w	$000,$776,$766,$765,$763,$763,$752,$741,$731,$722,$512,$501,$401,$301,$201,$100	;0


music
	incbin		msx/stnews.snd

	SECTION BSS
; general stuff
screenpointer				ds.l	1
screenpointer2				ds.l	1
screenpointershifter		ds.l	1
screenpointer2shifter		ds.l	1
screen1:					ds.b	65536+65536
screen2:					ds.b	65536

a_tab1						ds.b	65536
a_tab2						ds.b	65536
a_tab3						ds.b	65536
a_tab4						ds.b	65536
	
a_tab1pointer				ds.l	1
a_tab2pointer				ds.l	1
a_tab3pointer				ds.l	1
a_tab4pointer				ds.l	1
	
chunkycounterx				ds.w	1
chunkycountery				ds.w	1
chunkybuffer2_1				ds.b	8192*4		; 32768 b
chunkybuffer2_2				ds.b	8192*4		; 32768 b
	
chunkybuffer4_1				ds.b	8192*4		; 32768 b
chunkybuffer4_2				ds.b	8192*4		; 32768 b
chunkybuffer4_3				ds.b	8192*4
chunkybuffer4_4				ds.b	8192*4
	
tab2px_1					ds.b	65536+65536
tab2px_2					ds.b	65536
tab2px_1p					ds.l	1
tab2px_2p					ds.l	1
	
opt_tab1					ds.b	65536
opt_tab2					ds.b	65536
opt_tab3					ds.b	65536
opt_tab4					ds.b	65536
	
opt_tab1_lowmem				ds.b	65536
opt_tab2_lowmem				ds.b	65536
	
opt_c2ptable				ds.b	65536*4+65536
opt_c2ptable_pointer		ds.l	1

tab1px_1					ds.b	65536+65536
tab1px_2					ds.b	65536
tab1px_1p					ds.l	1
tab1px_2p					ds.l	1

	IFNE FRAMECOUNT
framecounter				ds.w	1
	ENDC