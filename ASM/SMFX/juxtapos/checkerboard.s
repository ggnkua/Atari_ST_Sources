; todo:
;	v make order of the changeMask from right to left
;	v optimize the jump table by evenly spacing the stuff
;	v fix the loading of the offsets in the drawstuff, so it uses the right flips
;	- optimize/flexible the increase of frames
;
; to increase the flexibility, I want to have multiple buffers
;
;	target: - scanline generation and determinaation int he mainloop, support multiple buffers
;			- copy stuff in the vbl
;
;	how does it work now?:
;	- drawlistStruct1, data structure for 64*64 = 4096 bytes of data; core data,
;			- resetDrawListStructNew
;			- written by populateDrawListStruct			$2000
;			- read by drawUniqueLinesNew
;			- read by copyUniqueScanlines
;	- drawListPointers
;
;	so question:
;	- who will determine which scanaline buffer address to use
;	- how to keep track of it?
;
;
;	todo:
;		v create space in lower memory for additional drawlistStruct memory
;		v create pointers for drawliststruct memory usages and use them
;			v drawlist struct for generation
;					`currentDrawListPointer_producer'
;			v drawlist struct for display
;					`currentDrawListPointer_producer'
;		- find a way to have pointers for scnaline generation and also for usage
;			- add switch for `on screen' and `in buffer' generation
;		- have multiple drawListPointers areas, so I can cycle them for reuse, is high emory, 100 bytes each
;		- have multiple drawlistStruct1 areas, so I can cycle the for reuse, is low memory, is 4kb each
;			- pointing into this data is the scanline bit encoding, that gets or.ed in a hard address, so we can SMC this
;
;	0;	$2000	screenpointer2
;	1;	$3000	screenpointer
;	2;	$4000	screenpointer2
;	3;	$5000	screenpointer
;
;
;
;
DEBUG						equ 1

LAYERS						equ 6
LINESIZE					equ 80
STRUCTSIZE					equ 64
NUMBER_OF_LINES				equ 214

genlower					equ 0

savedA7						equ	$2000-18
checker_size4				equ $2000-14
checker_size3				equ $2000-12
checker_size5				equ $2000-10
checker_size2				equ $2000-8
checker_size1				equ $2000-6
checker_size0				equ $2000-4

scanLineLeft				equ $2000-2	

drawlistStruct1				equ $2000				; size 4096		$2000 - $2fff	; next up: $3000
drawlistStruct2				equ $3000				
drawlistStruct3				equ $4000				
drawlistStruct4				equ $5000				
determineSmallestNumber6	equ $6800				; 000016FE		$3000 - $46ff	; next up: $4700
scanLineCode				equ $4700+$3800			; 00001AB0		$4700 - $66ff	; next up: $6700	size = 00001890 7f00 = a000 free


GENERATE_SCANLINE_OFFSET 	equ $2fa8+$3800-8-4-2-10
	IFEQ genlower
generateScanLine			equ	$4700+$30+$3800-8-4-2-10
	ENDC

STEPS						equ 40

GENERATEINSCREEN			equ 0

USEBUFFERS					equ 0

USEA7						equ 1

rasters						equ 1

STATISTICS					equ 1

checker_yoff0_start	equ	80*8
checker_yoff1_start	equ	70*8
checker_yoff2_start	equ	60*8
checker_yoff5_start	equ	50*8
checker_yoff3_start	equ	40*8
checker_yoff4_start	equ	15*8

sizeoffset			equ 0*8

CHECKER_GROW_SIZE	equ 60

checker_size0_start	equ 30*8+sizeoffset				; 22/40		20/60 = 1/3					
checker_size1_start	equ	52*8+sizeoffset				; 31/40		28/60 = 0.466666666666
checker_size2_start	equ 83*8+sizeoffset				; 43/40		39/60 = 0.65
checker_size5_start	equ 126*8+sizeoffset			; 46/40		55/60 = 0.9166666666
checker_size3_start	equ 186*8+sizeoffset			; 60/40		77/60 = 1.283333333
checker_size4_start	equ 270*8+sizeoffset			; 84/40		107/60 = 1.783333333

pl1	equ $211
pl2	equ $322
pl3	equ $433
pl4	equ $544
pl5	equ $655
pl6	equ $766


; memoruy map layout:
; $2000-$2fff drawlistStruct
; $3000+ 	$17EA = determineSmallestNumber6			6122 size

	IFD DEMOSYSTEM
		IFD	STANDALONE
		ELSE
STANDALONE 					equ 1
		ENDC
	ELSE
STANDALONE					equ 0
	ENDC

	IFEQ STANDALONE
TRUE	equ	0
FALSE	equ 1
true	equ 0
false	equ 1

FRAMECOUNT					equ 0
loadmusic					equ FALSE
PLAYMUSIC					equ true
playmusicinvbl				equ true
useblitter					equ 1


GENERATEFONT				equ 1

	ENDC

	incdir	gfx
	incdir	lib
	incdir	msx
	incdir	res/smfx

										;3360	336000
    section	TEXT


	include macro.s
		allocateStackAndShrink								; stack + superexec
		jmp		skipFiller

initDrawListStruct
	lea		drawlistStruct1,a0
	lea		drawlistStruct2,a1
	lea		drawlistStruct3,a2
	lea		drawlistStruct4,a3
	move.w	#0,d0
	move.w	#64-1,d7
.loop
		move.w	d0,(a0)
		move.w	d0,(a1)
		move.w	d0,(a2)
		move.w	d0,(a3)
		lea		STRUCTSIZE(a0),a0
		lea		STRUCTSIZE(a1),a1
		lea		STRUCTSIZE(a2),a2
		lea		STRUCTSIZE(a3),a3
		dbra	d7,.loop
	rts

resetDrawListStructNew
	move.l	currentDrawListPointer_producer,a1
	move.w	#0,d0
	REPT 50
		move.w	(a1)+,d1						; get a value from the list
		beq		quitResetting					; is it 0? then end of list
			move.w	d1,a2
			move.w	d0,(a2)				; set used pointer to 0
	ENDR
quitResetting
	rts


nr_of_unique	dc.w	0
top_unique		dc.w	0
nr_of_switches	dc.w	0
top_switches	dc.w	0
; 	usp
;	a0
;	a4
;	a5
;	a6
markScanLineChange macro
	; first we load the appropriate table thing, which basically means:
	;	- before changing mask, use mask to lookup t
	move.l	\1,a0						;4		use lower word value of changed register as pointer to haxlist (adding y offset and shit)
	move.w	d7,a4						;4		use the bitencoding of the checkermask as a pointer into data structure
	move.w	(a4),a5						;8		get termination address of current checkermask list
	move.w	a5,\1						;4		check if termination address has sane value (first item in the list?)
	bne		.notFirstTime\@
		lea		2(a4),a5				;8		make sure the value is not shit
		move.w	d7,(a6)+				;8		mark this checkermask as a `visible' value in the pointer list, for drawing
		IFEQ	STATISTICS
			addq.w	#1,nr_of_unique
		ENDC
												; HERE WE SHOULD MARK THE STORED DATA ADDERSS FOR THE GENERATED LINE
;		move.l	scanLineAddress,(a6)+
;		add.l	#160,scanLineAddress
.notFirstTime\@
	IFEQ	USEA7
		move.l	a7,(a5)+				;12		mark `start of copy'
		move.w	(a0)+,(a5)+				;12		mark `number of lines'
		move.w	a5,(a4)					;8		update termination address (since we occupy one more)
		add.w	(a0)+,a7				;8		increase the screenpointer
	ELSE
		move.l	a2,(a5)+				;12	
		move.w	(a0)+,(a5)+				;12
		move.w	a5,(a4)					;8
		add.w	(a0)+,a2				;8		--> 72
	ENDC

	IFEQ	STATISTICS
		addq.w	#1,nr_of_switches
	ENDC
	endm

	
treestart
;determineSmallestNumber6
	cmp.w	d0,d1												
	bgt.w	.d0_smallest_d1_done								
	beq.w	.d0_d1_equal										
.d1_smallest_d0_done											;done
		cmp.w	d1,d2											
		bgt.w	.d1_smallest_d0_d2_done							;done			
		beq.s	.d1_d2_smallest_d0_done							;done				
.d2_smallest_d0_d1_done											;done					
			cmp.w	d2,d3											 
			bgt.w	.d2_smallest_d0_d1_d3_done					;done		
			beq.w	.d2_d3_smallest_d0_d1_done					;done				
.d3_smallest_d0_d1_d2_done										;done				
				cmp.w	d3,d4	 
				bgt		.d3_smallest_d0_d1_d2_d4_done			;done				
				beq		.d3_d4_smallest_d0_d1_d2_done			;done		
.d4_smallest_d0_d1_d2_d3_done		
					cmp.w	d4,d5
					bgt		.d4_smallest_d0_d1_d2_d3_d5_done	;done
					beq		.d4_d5_smallest_d0_d1_d2_d3_done	;done
.d5_smallest_d0_d1_d2_d3_d4_done								;done
	sub.w	d5,d6		; 12 loss
	ble		.maherp
		sub.w	d5,d0
		sub.w	d5,d1
		sub.w	d5,d2
		sub.w	d5,d3
		sub.w	d5,d4
				markScanLineChange d5
		IFEQ 	USEA7
			move.l	usp,a0
			move.w	a0,d5
		ELSE
			move.w	checker_size5,d5
		ENDC
		eor.w	#%100000*STRUCTSIZE,d7
		jmp		determineSmallestNumber6
.maherp
	add.w	d6,d5
			markScanLineChange d5
		IFEQ	 USEA7
			move.l	savedA7,a7
		ENDC
	rts
;------------------------------------------------------------
.d4_d5_smallest_d0_d1_d2_d3_done								; done
	sub.w	d4,d6
	ble		.end1
		sub.w	d4,d0
		sub.w	d4,d1
		sub.w	d4,d2
		sub.w	d4,d3
				markScanLineChange d4
		move.w	checker_size4,d4
		IFEQ 	USEA7
			move.l	usp,a0
			move.w	a0,d5
		ELSE
			move.w	checker_size5,d5
		ENDC
		eor.w	#%110000*STRUCTSIZE,d7
		jmp		determineSmallestNumber6
.end1
	add.w	d6,d4
			markScanLineChange d4
		IFEQ	 USEA7
			move.l	savedA7,a7
		ENDC
	rts
;------------------------------------------------------------
.d4_smallest_d0_d1_d2_d3_d5_done								; done
	sub.w	d4,d6
	ble		.end13
		sub.w	d4,d0
		sub.w	d4,d1
		sub.w	d4,d2
		sub.w	d4,d3
		sub.w	d4,d5
				markScanLineChange d4
		move.w	checker_size4,d4
		eor.w	#%010000*STRUCTSIZE,d7
		jmp		determineSmallestNumber6
.end13
	add.w	d6,d4
			markScanLineChange d4
		IFEQ	 USEA7
			move.l	savedA7,a7
		ENDC
	rts
;------------------------------------------------------------
.d3_smallest_d0_d1_d2_d4_done									; done
	cmp.w	d3,d5
	bgt		.d3_smallest_d0_d1_d2_d4_d5_done					; done
	beq		.d3_d5_smallest_d0_d1_d2_d4_done					; done
	bra		.d5_smallest_d0_d1_d2_d3_d4_done					; done
;------------------------------------------------------------
.d3_d5_smallest_d0_d1_d2_d4_done								; done
	sub.w	d3,d6
	ble		.end2
		sub.w	d3,d0
		sub.w	d3,d1
		sub.w	d3,d2
		sub.w	d3,d4
				markScanLineChange d3
		move.w	checker_size3,d3
		IFEQ 	USEA7
			move.l	usp,a0
			move.w	a0,d5
		ELSE
			move.w	checker_size5,d5
		ENDC
		eor.w	#%101000*STRUCTSIZE,d7
		jmp		determineSmallestNumber6
.end2
	add.w	d6,d3
			markScanLineChange d3
		IFEQ	 USEA7
			move.l	savedA7,a7
		ENDC
	rts
;------------------------------------------------------------
.d3_smallest_d0_d1_d2_d4_d5_done								; done
	sub.w	d3,d6
	ble		.end233
		sub.w	d3,d0
		sub.w	d3,d1
		sub.w	d3,d2
		sub.w	d3,d4
		sub.w	d3,d5
				markScanLineChange d3
		move.w	checker_size3,d3
		eor.w	#%001000*STRUCTSIZE,d7
		jmp		determineSmallestNumber6
.end233
	add.w	d6,d3
			markScanLineChange d3
		IFEQ	 USEA7
			move.l	savedA7,a7
		ENDC
	rts
;------------------------------------------------------------
.d3_d4_smallest_d0_d1_d2_done									; done
	cmp.w	d3,d5
	bgt		.d3_d4_smallest_d0_d1_d2_d5_done					; done
	beq		.d3_d4_d5_smallest_d0_d1_d2_done					; done
	bra		.d5_smallest_d0_d1_d2_d3_d4_done					; done
;------------------------------------------------------------
.d3_d4_smallest_d0_d1_d2_d5_done								; done	
	sub.w	d3,d6
	ble		.end3
		sub.w	d3,d0
		sub.w	d3,d1
		sub.w	d3,d2
		sub.w	d3,d5
				markScanLineChange d3
		move.w	checker_size3,d3
		move.w	checker_size4,d4
		eor.w	#%011000*STRUCTSIZE,d7
		jmp		determineSmallestNumber6
.end3
	add.w	d6,d3
			markScanLineChange d3
		IFEQ	 USEA7
			move.l	savedA7,a7
		ENDC
	rts
;------------------------------------------------------------
.d3_d4_d5_smallest_d0_d1_d2_done								; done									
	sub.w	d3,d6
	ble		.end3a
		sub.w	d3,d0
		sub.w	d3,d1
		sub.w	d3,d2
				markScanLineChange d3
		move.w	checker_size3,d3
		move.w	checker_size4,d4
		IFEQ 	USEA7
			move.l	usp,a0
			move.w	a0,d5
		ELSE
			move.w	checker_size5,d5
		ENDC
		eor.w	#%111000*STRUCTSIZE,d7
		jmp		determineSmallestNumber6
.end3a
	add.w	d6,d3
			markScanLineChange d3
		IFEQ	 USEA7
			move.l	savedA7,a7
		ENDC
	rts
;------------------------------------------------------------
.d1_d2_smallest_d0_done											; done		
	cmp.w	d1,d3
	bgt.s	.d1_d2_smallest_d0_d3_done							; done												
	blt.s	.d3_smallest_d0_d1_d2_done							; done		
;	bra		.d1_d2_d3_smallest_d0_done							; done		
.d1_d2_d3_smallest_d0_done										; done			
		cmp.w	d1,d4		
		bgt		.d1_d2_d3_smallest_d0_d4_done						; done								
		beq		.d1_d2_d3_d4_smallest_d0_done						; done	
		bra		.d4_smallest_d0_d1_d2_d3_done						; done	
;------------------------------------------------------------
.d1_d2_smallest_d0_d3_done										; done											
	cmp.w	d1,d4
	bgt		.d1_d2_smallest_d0_d3_d4_done						; done									
	beq		.d1_d2_d4_smallest_d0_d3_done						; done						
	bra		.d4_smallest_d0_d1_d2_d3_done						; done											
;------------------------------------------------------------
.d1_d2_smallest_d0_d3_d4_done									; done
	cmp.w	d1,d5
	bgt		.d1_d2_smallest_d0_d3_d4_d5_done					; done
	beq		.d1_d2_d5_smallest_d0_d3_d4_done					; done
	bra		.d5_smallest_d0_d1_d2_d3_d4_done					; done
;------------------------------------------------------------		
.d1_d2_d5_smallest_d0_d3_d4_done
	sub.w	d1,d6
	ble		.ok7z
		sub.w	d1,d0
		sub.w	d1,d3
		sub.w	d1,d4
				markScanLineChange d1
		move.w	a1,d1
		IFEQ	USEA7
			move.w	a2,d2
		ELSE
			move.l	usp,a0
			move.w	a0,d2
		ENDC

		IFEQ 	USEA7
			move.l	usp,a0
			move.w	a0,d5
		ELSE
			move.w	checker_size5,d5
		ENDC
		eor.w	#%100110*STRUCTSIZE,d7
		jmp		determineSmallestNumber6
.ok7z
	add.w	d6,d1
			markScanLineChange d1
		IFEQ	 USEA7
			move.l	savedA7,a7
		ENDC
	rts
;------------------------------------------------------------									
.d1_d2_smallest_d0_d3_d4_d5_done								; done
	sub.w	d1,d6
	ble		.ok7y
		sub.w	d1,d0
		sub.w	d1,d3
		sub.w	d1,d4
		sub.w	d1,d5
				markScanLineChange d1
		move.w	a1,d1
		IFEQ	USEA7
			move.w	a2,d2
		ELSE
			move.l	usp,a0
			move.w	a0,d2
		ENDC
		eor.w	#%000110*STRUCTSIZE,d7
		jmp		determineSmallestNumber6
.ok7y
	add.w	d6,d1
			markScanLineChange d1
		IFEQ	 USEA7
			move.l	savedA7,a7
		ENDC
	rts
;------------------------------------------------------------
.d1_d2_d4_smallest_d0_d3_done									; done
	cmp.w	d1,d5
	bgt		.d1_d2_d4_smallest_d0_d3_d5_done					; done
	beq		.d1_d2_d4_d5_smallest_d0_d3_done					; done
	bra		.d5_smallest_d0_d1_d2_d3_d4_done					; done
;------------------------------------------------------------
.d1_d2_d4_d5_smallest_d0_d3_done								; done
	sub.w	d1,d6
	ble		.ok777z
		sub.w	d1,d0
		sub.w	d1,d3
				markScanLineChange d1
		move.w	a1,d1
		IFEQ	USEA7
			move.w	a2,d2
		ELSE
			move.l	usp,a0
			move.w	a0,d2
		ENDC
		move.w	checker_size4,d4
		IFEQ 	USEA7
			move.l	usp,a0
			move.w	a0,d5
		ELSE
			move.w	checker_size5,d5
		ENDC
		eor.w	#%110110*STRUCTSIZE,d7
		jmp		determineSmallestNumber6
.ok777z
	add.w	d6,d1
			markScanLineChange d1
		IFEQ	 USEA7
			move.l	savedA7,a7
		ENDC
	rts
;------------------------------------------------------------
.d1_d2_d4_smallest_d0_d3_d5_done								; done
	sub.w	d1,d6
	ble		.ok777
		sub.w	d1,d0
		sub.w	d1,d3
		sub.w	d1,d5
				markScanLineChange d1
		move.w	a1,d1
		IFEQ	USEA7
			move.w	a2,d2
		ELSE
			move.l	usp,a0
			move.w	a0,d2
		ENDC
		move.w	checker_size4,d4
		eor.w	#%010110*STRUCTSIZE,d7
		jmp		determineSmallestNumber6
.ok777
	add.w	d6,d1
			markScanLineChange d1
		IFEQ	 USEA7
			move.l	savedA7,a7
		ENDC
	rts						
;------------------------------------------------------------		
.d1_d2_d3_smallest_d0_d4_done									; done
	cmp.w	d1,d5
	bgt		.d1_d2_d3_smallest_d0_d4_d5_done					; done
	beq		.d1_d2_d3_d5_smallest_d0_d4_done					; done
	bra		.d5_smallest_d0_d1_d2_d3_d4_done					; done
;------------------------------------------------------------	
.d1_d2_d3_d5_smallest_d0_d4_done								; done								
	sub.w	d1,d6
	ble.s	.ok2z
		sub.w	d1,d0							
		sub.w	d1,d4							
				markScanLineChange d1
		move.w	a1,d1							
		IFEQ	USEA7
			move.w	a2,d2
		ELSE
			move.l	usp,a0
			move.w	a0,d2
		ENDC
		move.w	checker_size3,d3
		IFEQ 	USEA7
			move.l	usp,a0
			move.w	a0,d5
		ELSE
			move.w	checker_size5,d5
		ENDC
		eor.w	#%101110*STRUCTSIZE,d7
		jmp		determineSmallestNumber6
.ok2z
	add.w	d6,d1
			markScanLineChange d1
		IFEQ	 USEA7
			move.l	savedA7,a7
		ENDC
	rts
;------------------------------------------------------------
.d1_d2_d3_smallest_d0_d4_d5_done								; done								
	sub.w	d1,d6
	ble.s	.ok2
		sub.w	d1,d0							
		sub.w	d1,d4							
		sub.w	d1,d5				
				markScanLineChange d1
		move.w	a1,d1							
		IFEQ	USEA7
			move.w	a2,d2
		ELSE
			move.l	usp,a0
			move.w	a0,d2
		ENDC
		move.w	checker_size3,d3
		eor.w	#%001110*STRUCTSIZE,d7
		jmp		determineSmallestNumber6
.ok2
	add.w	d6,d1
			markScanLineChange d1
		IFEQ	 USEA7
			move.l	savedA7,a7
		ENDC
	rts
;------------------------------------------------------------
.d1_d2_d3_d4_smallest_d0_done									; done
	cmp.w	d1,d5
	bgt		.d1_d2_d3_d4_smallest_d0_d5_done					; done
	beq		.d1_d2_d3_d4_d5_smallest_d0_done					; done
	bra		.d5_smallest_d0_d1_d2_d3_d4_done					; done
;------------------------------------------------------------	
.d1_d2_d3_d4_d5_smallest_d0_done								; done
	sub.w	d1,d6
	ble		.ok222z
		sub.w	d1,d0
				markScanLineChange d1
		move.w	a1,d1
		IFEQ	USEA7
			move.w	a2,d2
		ELSE
			move.l	usp,a0
			move.w	a0,d2
		ENDC
		move.w	checker_size3,d3
		move.w	checker_size4,d4
		IFEQ 	USEA7
			move.l	usp,a0
			move.w	a0,d5
		ELSE
			move.w	checker_size5,d5
		ENDC
		eor.w	#%111110*STRUCTSIZE,d7
		jmp		determineSmallestNumber6
.ok222z
	add.w	d6,d1
			markScanLineChange d1
		IFEQ	 USEA7
			move.l	savedA7,a7
		ENDC
	rts
;------------------------------------------------------------
.d1_d2_d3_d4_smallest_d0_d5_done								; done
	sub.w	d1,d6
	ble		.ok222
		sub.w	d1,d0
		sub.w	d1,d5
				markScanLineChange d1
		move.w	a1,d1
		IFEQ	USEA7
			move.w	a2,d2
		ELSE
			move.l	usp,a0
			move.w	a0,d2
		ENDC
		move.w	checker_size3,d3
		move.w	checker_size4,d4
		eor.w	#%011110*STRUCTSIZE,d7
		jmp		determineSmallestNumber6
.ok222
	add.w	d6,d1
			markScanLineChange d1
		IFEQ	 USEA7
			move.l	savedA7,a7
		ENDC
	rts
;------------------------------------------------------------
.d1_smallest_d0_d2_d3_done										; done				
	cmp.w	d1,d4	
	bgt		.d1_smallest_d0_d2_d3_d4_done						; done			
	blt		.d4_smallest_d0_d1_d2_d3_done						; done
;	bra		.d1_d4_smallest_d0_d2_d3_done
.d1_d4_smallest_d0_d2_d3_done													
	cmp.w	d1,d5
	bgt		.d1_d4_smallest_d0_d2_d3_d5_done					; done
	beq		.d1_d4_d5_smallest_d0_d2_d3_done					; done
	bra		.d5_smallest_d0_d1_d2_d3_d4_done					; done
;------------------------------------------------------------
.d1_d4_d5_smallest_d0_d2_d3_done								; done
	sub.w	d1,d6
	ble.s	.zok3
		sub.w	d1,d0							
		sub.w	d1,d2
		sub.w	d1,d3
				markScanLineChange d1
		move.w	a1,d1
		move.w	checker_size4,d4
		IFEQ 	USEA7
			move.l	usp,a0
			move.w	a0,d5
		ELSE
			move.w	checker_size5,d5
		ENDC
		eor.w	#%110010*STRUCTSIZE,d7			
		jmp		determineSmallestNumber6
.zok3
	add.w	d6,d1
			markScanLineChange d1
		IFEQ	 USEA7
			move.l	savedA7,a7
		ENDC
	rts
;------------------------------------------------------------
.d1_d4_smallest_d0_d2_d3_d5_done								; done
	sub.w	d1,d6
	ble.s	.ok3
		sub.w	d1,d0							
		sub.w	d1,d2
		sub.w	d1,d3
		sub.w	d1,d5
				markScanLineChange d1
		move.w	a1,d1
		move.w	checker_size4,d4
		eor.w	#%010010*STRUCTSIZE,d7			
		jmp		determineSmallestNumber6
.ok3
	add.w	d6,d1
			markScanLineChange d1
		IFEQ	 USEA7
			move.l	savedA7,a7
		ENDC
	rts
;------------------------------------------------------------
.d1_smallest_d0_d2_d3_d4_done									; done
	cmp.w	d1,d5
	bgt		.d1_smallest_d0_d2_d3_d4_d5_done					; done
	beq		.d1_d5_smallest_d0_d2_d3_d4_done					; done	
	bra		.d5_smallest_d0_d1_d2_d3_d4_done					; done
;-----------------------------------------------------------
.d1_d5_smallest_d0_d2_d3_d4_done								; done
	sub.w	d1,d6
	ble.s	.zok444
		sub.w	d1,d0
		sub.w	d1,d2
		sub.w	d1,d3
		sub.w	d1,d4
				markScanLineChange d1
		move.w	a1,d1
		IFEQ 	USEA7
			move.l	usp,a0
			move.w	a0,d5
		ELSE
			move.w	checker_size5,d5
		ENDC
		eor.w	#%100010*STRUCTSIZE,d7
		jmp		determineSmallestNumber6
.zok444
	add.w	d6,d1
			markScanLineChange d1
		IFEQ	 USEA7
			move.l	savedA7,a7
		ENDC
	rts
;-----------------------------------------------------------
.d1_smallest_d0_d2_d3_d4_d5_done								; done
	sub.w	d1,d6
	ble.s	.ok444
		sub.w	d1,d0
		sub.w	d1,d2
		sub.w	d1,d3
		sub.w	d1,d4
		sub.w	d1,d5
				markScanLineChange d1
		move.w	a1,d1
		eor.w	#%000010*STRUCTSIZE,d7
		jmp		determineSmallestNumber6
.ok444
	add.w	d6,d1
			markScanLineChange d1
		IFEQ	 USEA7
			move.l	savedA7,a7
		ENDC
	rts
;------------------------------------------------------------
.d1_smallest_d0_d2_done											; done					
	cmp.w	d1,d3
	bgt.s	.d1_smallest_d0_d2_d3_done							; done				
	blt.w	.d3_smallest_d0_d1_d2_done							; done						
;------------------------------------------------------------
.d1_d3_smallest_d0_d2_done										; done										
	cmp.w	d1,d4
	bgt		.d1_d3_smallest_d0_d1_d4_done						; done	
	beq		.d1_d3_d4_smallest_d0_d2_done						; done					
	bra		.d4_smallest_d0_d1_d2_d3_done						; done						
;------------------------------------------------------------
.d1_d3_d4_smallest_d0_d2_done									; done
	cmp.w	d1,d5
	bgt		.d1_d3_d4_smallest_d0_d2_d5_done					; done
	beq		.d1_d3_d4_d5_smallest_d0_d2_done					; done
	bra		.d5_smallest_d0_d1_d2_d3_d4_done					; done
;------------------------------------------------------------												
.d1_d3_d4_d5_smallest_d0_d2_done								; done
	sub.w	d1,d6
	ble.s	.ok4aab
		sub.w	d1,d0
		sub.w	d1,d2	
				markScanLineChange d1
		move.w	a1,d1
		move.w	checker_size3,d3
		move.w	checker_size4,d4
		IFEQ 	USEA7
			move.l	usp,a0
			move.w	a0,d5
		ELSE
			move.w	checker_size5,d5
		ENDC
		eor.w	#%111010*STRUCTSIZE,d7
		jmp		determineSmallestNumber6
.ok4aab
	add.w	d6,d1
			markScanLineChange d1
		IFEQ	 USEA7
			move.l	savedA7,a7
		ENDC
	rts
;------------------------------------------------------------
.d1_d3_d4_smallest_d0_d2_d5_done								; done
	sub.w	d1,d6
	ble.s	.ok4
		sub.w	d1,d0
		sub.w	d1,d2	
		sub.w	d1,d5
				markScanLineChange d1
		move.w	a1,d1
		move.w	checker_size3,d3
		move.w	checker_size4,d4
		eor.w	#%011010*STRUCTSIZE,d7
		jmp		determineSmallestNumber6
.ok4
	add.w	d6,d1
			markScanLineChange d1
		IFEQ	 USEA7
			move.l	savedA7,a7
		ENDC
	rts
;------------------------------------------------------------
.d1_d3_smallest_d0_d1_d4_done									; done
	cmp.w	d1,d5
	bgt		.d1_d3_smallest_d0_d2_d4_d5_done					; done
	beq		.d1_d3_d5_smallest_d0_d2_d4_done					; done
	bra		.d5_smallest_d0_d1_d2_d3_d4_done					; done
;------------------------------------------------------------
.d1_d3_d5_smallest_d0_d2_d4_done								; done
	sub.w	d1,d6
	ble.s	.ok4aaac
		sub.w	d1,d0
		sub.w	d1,d2	
		sub.w	d1,d4
				markScanLineChange d1
		move.w	a1,d1
		move.w	checker_size3,d3
		IFEQ 	USEA7
			move.l	usp,a0
			move.w	a0,d5
		ELSE
			move.w	checker_size5,d5
		ENDC
		eor.w	#%101010*STRUCTSIZE,d7
		jmp		determineSmallestNumber6
.ok4aaac
	add.w	d6,d1
			markScanLineChange d1
		IFEQ	 USEA7
			move.l	savedA7,a7
		ENDC
	rts	
;------------------------------------------------------------
.d1_d3_smallest_d0_d2_d4_d5_done								; done
	sub.w	d1,d6
	ble.s	.ok4a
		sub.w	d1,d0
		sub.w	d1,d2	
		sub.w	d1,d4
		sub.w	d1,d5
				markScanLineChange d1
		move.w	a1,d1
		move.w	checker_size3,d3
		eor.w	#%001010*STRUCTSIZE,d7
		jmp		determineSmallestNumber6
.ok4a
	add.w	d6,d1
			markScanLineChange d1
		IFEQ	 USEA7
			move.l	savedA7,a7
		ENDC
	rts	
;------------------------------------------------------------
.d2_smallest_d0_d1_d3_done										; done				
	cmp.w	d2,d4						
	bgt		.d2_smallest_d0_d1_d3_d4_done						; done				
	beq		.d2_d4_smallest_d0_d1_d3_done						; done									
	bra.s	.d4_smallest_d0_d1_d2_d3_done						; done							
;------------------------------------------------------------
.d2_d4_smallest_d0_d1_d3_done									; done
	cmp.w	d2,d5
	bgt		.d2_d4_smallest_d0_d1_d3_d5_done					; done
	beq		.d2_d4_d5_smallest_d0_d1_d3_done					; done
	bra		.d5_smallest_d0_d1_d2_d3_d4_done					; done
;------------------------------------------------------------
.d2_d4_d5_smallest_d0_d1_d3_done								; done
	sub.w	d2,d6
	ble		.ok55a
		sub.w	d2,d0
		sub.w	d2,d1
		sub.w	d2,d3
		sub.w	d2,d5
				markScanLineChange d2
		IFEQ	USEA7
			move.w	a2,d2
		ELSE
			move.l	usp,a0
			move.w	a0,d2
		ENDC
		move.w	checker_size4,d4
		IFEQ 	USEA7
			move.l	usp,a0
			move.w	a0,d5
		ELSE
			move.w	checker_size5,d5
		ENDC
		eor.w	#%110100*STRUCTSIZE,d7
		jmp		determineSmallestNumber6
.ok55a
	add.w	d6,d2
			markScanLineChange d2
		IFEQ	 USEA7
			move.l	savedA7,a7
		ENDC
	rts
;------------------------------------------------------------
.d2_d4_smallest_d0_d1_d3_d5_done								; done
	sub.w	d2,d6
	ble		.ok55
		sub.w	d2,d0
		sub.w	d2,d1
		sub.w	d2,d3
		sub.w	d2,d5
				markScanLineChange d2
		IFEQ	USEA7
			move.w	a2,d2
		ELSE
			move.l	usp,a0
			move.w	a0,d2
		ENDC
		move.w	checker_size4,d4
		eor.w	#%010100*STRUCTSIZE,d7
		jmp		determineSmallestNumber6
.ok55
	add.w	d6,d2
			markScanLineChange d2
		IFEQ	 USEA7
			move.l	savedA7,a7
		ENDC
	rts
;------------------------------------------------------------
.d2_smallest_d0_d1_d3_d4_done									; done
	cmp.w	d2,d5
	bgt		.d2_smallest_d0_d1_d3_d4_d5_done					; done
	beq		.d2_d5_smallest_d0_d1_d3_d4_done					; done
	bra		.d5_smallest_d0_d1_d2_d3_d4_done					; done
;------------------------------------------------------------
.d2_d5_smallest_d0_d1_d3_d4_done								; done
	sub.w	d2,d6
	ble.s	.ok5x
		sub.w	d2,d0
		sub.w	d2,d1
		sub.w	d2,d3
		sub.w	d2,d4
				markScanLineChange d2
		IFEQ	USEA7
			move.w	a2,d2
		ELSE
			move.l	usp,a0
			move.w	a0,d2
		ENDC
		IFEQ 	USEA7
			move.l	usp,a0
			move.w	a0,d5
		ELSE
			move.w	checker_size5,d5
		ENDC
		eor.w	#%100100*STRUCTSIZE,d7
		jmp		determineSmallestNumber6
.ok5x
	add.w	d6,d2
			markScanLineChange d2
		IFEQ	 USEA7
			move.l	savedA7,a7
		ENDC
	rts
;------------------------------------------------------------
.d2_smallest_d0_d1_d3_d4_d5_done								; done
	sub.w	d2,d6
	ble.s	.ok5
		sub.w	d2,d0
		sub.w	d2,d1
		sub.w	d2,d3
		sub.w	d2,d4
		sub.w	d2,d5
				markScanLineChange d2
		IFEQ	USEA7
			move.w	a2,d2
		ELSE
			move.l	usp,a0
			move.w	a0,d2
		ENDC
		eor.w	#%000100*STRUCTSIZE,d7
		jmp		determineSmallestNumber6
.ok5
	add.w	d6,d2
			markScanLineChange d2
		IFEQ	 USEA7
			move.l	savedA7,a7
		ENDC
	rts
;------------------------------------------------------------
.d0_smallest_d1_done											; done				
	cmp.w	d0,d2												
	bgt.s	.d0_smallest_d1_d2_done								; done						
	blt.w	.d2_smallest_d0_d1_done								; done						
;	bra.s	.d0_d2_smallest_d1_done								; done	
		cmp.w	d0,d3
		bgt.s	.d0_d2_smallest_d1_d3_done							; done	
		blt.w	.d3_smallest_d0_d1_d2_done							; done
		bra.w	.d0_d2_d3_smallest_d1_done							; done						
;------------------------------------------------------------
.d0_d1_equal													; done
	cmp.w	d1,d2
	bgt.w	.d0_d1_smallest_d2_done								; done				
	blt.w	.d2_smallest_d0_d1_done								; done			
;	bra.w	.d0_d1_d2_equal										; done				
		cmp.w	d2,d3
		bgt.w	.d0_d1_d2_smallest_d3_done							; done
		blt.w	.d3_smallest_d0_d1_d2_done							; done						
		bra.w	.d0_d1_d2_d3_equal									; done	
;------------------------------------------------------------
.d0_smallest_d1_d2_done											; done
	cmp.w	d0,d3												
	bgt.s	.d0_smallest_d1_d2_d3_done							; done	
	blt.w	.d3_smallest_d0_d1_d2_done							; done	
;	bra.w	.d0_d3_smallest_d1_d2_done							; done		
;.d0_d3_smallest_d1_d2_done										; done			
		cmp.w	d0,d4
		bgt		.d0_d3_smallest_d1_d2_d4_done						; done			
		blt		.d4_smallest_d0_d1_d2_d3_done						; done
;.d0_d3_d4_smallest_d1_d2_done
	cmp.w	d0,d5
			bgt		.d0_d3_d4_smallest_d1_d2_d5_done					; done
			beq		.d0_d3_d4_d5_smallest_d1_d2_done					; done
			bra		.d5_smallest_d0_d1_d2_d3_d4_done					; done
;------------------------------------------------------------
.d2_d3_smallest_d0_d1_done										; done												
	cmp.w	d2,d4
	bgt		.d2_d3_smallest_d0_d1_d4_done						; done									
	beq		.d2_d3_d4_smallest_d0_d1_done						; done							
;	bra		.d4_smallest_d0_d1_d2_d3_done						; done	
		cmp.w	d4,d5
		bgt		.d4_smallest_d0_d1_d2_d3_d5_done				; done
		beq		.d4_d5_smallest_d0_d1_d2_d3_done				; done
		bra		.d5_smallest_d0_d1_d2_d3_d4_done				; done
;------------------------------------------------------------
.d2_d3_smallest_d0_d1_d4_done									; done
	cmp.w	d2,d5
	bgt		.d2_d3_smallest_d0_d1_d4_d5_done					; done
	beq		.d2_d3_d5_smallest_d0_d1_d4_done					; done
	bra		.d5_smallest_d0_d1_d2_d3_d4_done					; done
;------------------------------------------------------------
.d2_d3_d5_smallest_d0_d1_d4_done								; done			
	sub.w	d2,d6
	ble.s	.ok777a
		sub.w	d2,d0
		sub.w	d2,d1
		sub.w	d2,d4
				markScanLineChange d2
		IFEQ	USEA7
			move.w	a2,d2
		ELSE
			move.l	usp,a0
			move.w	a0,d2
		ENDC
		move.w	checker_size3,d3
		IFEQ 	USEA7
			move.l	usp,a0
			move.w	a0,d5
		ELSE
			move.w	checker_size5,d5
		ENDC
		eor.w	#%101100*STRUCTSIZE,d7
		jmp		determineSmallestNumber6
.ok777a
	add.w	d6,d2
			markScanLineChange d2
		IFEQ	 USEA7
			move.l	savedA7,a7
		ENDC
	rts
;------------------------------------------------------------
.d2_d3_smallest_d0_d1_d4_d5_done								; done		
	sub.w	d2,d6
	ble.s	.ok77
		sub.w	d2,d0
		sub.w	d2,d1
		sub.w	d2,d4
		sub.w	d2,d5
				markScanLineChange d2
		IFEQ	USEA7
			move.w	a2,d2
		ELSE
			move.l	usp,a0
			move.w	a0,d2
		ENDC
		move.w	checker_size3,d3
		eor.w	#%001100*STRUCTSIZE,d7
		jmp		determineSmallestNumber6
.ok77
	add.w	d6,d2
			markScanLineChange d2
		IFEQ	 USEA7
			move.l	savedA7,a7
		ENDC
	rts
;------------------------------------------------------------
.d2_d3_d4_smallest_d0_d1_done									; done
	cmp.w	d2,d5
	bgt		.d2_d3_d4_smallest_d0_d1_d5_done					; done
	beq		.d2_d3_d4_d5_smallest_d0_d1_done					; done
	bra		.d5_smallest_d0_d1_d2_d3_d4_done					; done
;------------------------------------------------------------
.d2_d3_d4_d5_smallest_d0_d1_done								; done
	sub.w	d2,d6
	ble.s	.ok888
		sub.w	d2,d0
		sub.w	d2,d1
				markScanLineChange d2
		IFEQ	USEA7
			move.w	a2,d2
		ELSE
			move.l	usp,a0
			move.w	a0,d2
		ENDC
		move.w	checker_size3,d3
		move.w	checker_size4,d4
		IFEQ 	USEA7
			move.l	usp,a0
			move.w	a0,d5
		ELSE
			move.w	checker_size5,d5
		ENDC
		eor.w	#%111100*STRUCTSIZE,d7
		jmp		determineSmallestNumber6
.ok888
	add.w	d6,d2
			markScanLineChange d2
		IFEQ	 USEA7
			move.l	savedA7,a7
		ENDC
	rts
;------------------------------------------------------------
.d2_d3_d4_smallest_d0_d1_d5_done								; done
	sub.w	d2,d6
	ble.s	.ok88
		sub.w	d2,d0
		sub.w	d2,d1
		sub.w	d2,d5
				markScanLineChange d2
		IFEQ	USEA7
			move.w	a2,d2
		ELSE
			move.l	usp,a0
			move.w	a0,d2
		ENDC
		move.w	checker_size3,d3
		move.w	checker_size4,d4
		eor.w	#%011100*STRUCTSIZE,d7
		jmp		determineSmallestNumber6
.ok88
	add.w	d6,d2
			markScanLineChange d2
		IFEQ	 USEA7
			move.l	savedA7,a7
		ENDC
	rts
;------------------------------------------------------------
.d0_d2_smallest_d1_done											; done
	cmp.w	d0,d3
	bgt.s	.d0_d2_smallest_d1_d3_done							; done	
	blt.w	.d3_smallest_d0_d1_d2_done							; done
	bra.w	.d0_d2_d3_smallest_d1_done							; done						
;------------------------------------------------------------
.d0_smallest_d1_d2_d3_done										; done	
	cmp.w	d0,d4
	bgt		.d0_smallest_d1_d2_d3_d4_done						; done	
	beq		.d0_d4_smallest_d1_d2_d3_done						; done
	bra		.d4_smallest_d0_d1_d2_d3_done						; done
;------------------------------------------------------------
.d0_d4_smallest_d1_d2_d3_done									; done	
	cmp.w	d0,d5
	bgt		.d0_d4_smallest_d1_d2_d3_d5_done					; done
	beq		.d0_d4_d5_smallest_d1_d2_d3_done					; done
	bra		.d5_smallest_d0_d1_d2_d3_d4_done					; done
;------------------------------------------------------------
.d0_d4_d5_smallest_d1_d2_d3_done								; done
	sub.w	d0,d6
	ble.s	.ok100
		sub.w	d0,d1
		sub.w	d0,d2
		sub.w	d0,d3
				markScanLineChange d0
		move.w	a3,d0
		move.w	checker_size4,d4
		IFEQ 	USEA7
			move.l	usp,a0
			move.w	a0,d5
		ELSE
			move.w	checker_size5,d5
		ENDC
		eor.w	#%110001*STRUCTSIZE,d7
		jmp		determineSmallestNumber6
.ok100
	add.w	d6,d0
			markScanLineChange d0
		IFEQ	 USEA7
			move.l	savedA7,a7
		ENDC
	rts
;------------------------------------------------------------
.d0_d4_smallest_d1_d2_d3_d5_done								; done
	sub.w	d0,d6
	ble.s	.zok100
		sub.w	d0,d1
		sub.w	d0,d2
		sub.w	d0,d3
		sub.w	d0,d5
				markScanLineChange d0
		move.w	a3,d0
		move.w	checker_size4,d4
		eor.w	#%010001*STRUCTSIZE,d7
		jmp		determineSmallestNumber6
.zok100
	add.w	d6,d0
			markScanLineChange d0
		IFEQ	 USEA7
			move.l	savedA7,a7
		ENDC
	rts
;------------------------------------------------------------
.d0_smallest_d1_d2_d3_d4_done									; done
	cmp.w	d0,d5
	bgt		.d0_smallest_d1_d2_d3_d4_d5_done					; done
	beq		.d0_d5_smallest_d1_d2_d3_d4_done					; done
	bra		.d5_smallest_d0_d1_d2_d3_d4_done					; done
;------------------------------------------------------------
.d0_d5_smallest_d1_d2_d3_d4_done								; done
	sub.w	d0,d6
	ble.s	.zok10
		sub.w	d0,d1
		sub.w	d0,d2
		sub.w	d0,d3
		sub.w	d0,d4
				markScanLineChange d0
		move.w	a3,d0
		IFEQ 	USEA7
			move.l	usp,a0
			move.w	a0,d5
		ELSE
			move.w	checker_size5,d5
		ENDC
		eor.w	#%100001*STRUCTSIZE,d7
		jmp		determineSmallestNumber6
.zok10
	add.w	d6,d0
			markScanLineChange d0
		IFEQ	 USEA7
			move.l	savedA7,a7
		ENDC
	rts
;------------------------------------------------------------
.d0_smallest_d1_d2_d3_d4_d5_done								; done
	sub.w	d0,d6
	ble.s	.ok10
		sub.w	d0,d1
		sub.w	d0,d2
		sub.w	d0,d3
		sub.w	d0,d4
		sub.w	d0,d5
				markScanLineChange d0
		move.w	a3,d0
		eor.w	#%000001*STRUCTSIZE,d7
		jmp		determineSmallestNumber6
.ok10
	add.w	d6,d0
			markScanLineChange d0
		IFEQ	 USEA7
			move.l	savedA7,a7
		ENDC
	rts
;------------------------------------------------------------
.d0_d1_smallest_d2_done											; done
	cmp.w	d0,d3
	bgt.w	.d0_d1_smallest_d2_d3_done							; done
	blt.w	.d3_smallest_d0_d1_d2_done							; done
	bra.w	.d0_d1_d3_smallest_d2_done							; done
;------------------------------------------------------------
.d0_d1_d2_equal													; done
	cmp.w	d2,d3
	bgt.w	.d0_d1_d2_smallest_d3_done							; done
	blt.w	.d3_smallest_d0_d1_d2_done							; done						
	bra.w	.d0_d1_d2_d3_equal									; done	
;------------------------------------------------------------
.d0_d2_smallest_d1_d3_done										; done				
	cmp.w	d0,d4
	bgt		.d0_d2_smallest_d1_d3_d4_done						; done						
	blt		.d4_smallest_d0_d1_d2_d3_done						; done
;------------------------------------------------------------
.d0_d2_d4_smallest_d1_d3_done									; done
	cmp.w	d0,d5
	bgt		.d0_d2_d4_smallest_d1_d3_d5_done					; done
	beq		.d0_d2_d4_d5_smallest_d1_d3_done					; done
	blt		.d5_smallest_d0_d1_d2_d3_d4_done					; done
;------------------------------------------------------------	
.d0_d2_d4_d5_smallest_d1_d3_done
	sub.w	d0,d6
	ble.s	.ok82
		sub.w	d0,d1
		sub.w	d0,d3
				markScanLineChange d0
		move.w	a3,d0
		IFEQ	USEA7
			move.w	a2,d2
		ELSE
			move.l	usp,a0
			move.w	a0,d2
		ENDC
		move.w	checker_size4,d4
		IFEQ 	USEA7
			move.l	usp,a0
			move.w	a0,d5
		ELSE
			move.w	checker_size5,d5
		ENDC
		eor.w	#%110101*STRUCTSIZE,d7
		jmp		determineSmallestNumber6
.ok82
	add.w	d6,d0
			markScanLineChange d0
		IFEQ	 USEA7
			move.l	savedA7,a7
		ENDC
	rts
;------------------------------------------------------------	
.d0_d2_d4_smallest_d1_d3_d5_done
	sub.w	d0,d6
	ble.s	.aok82
		sub.w	d0,d1
		sub.w	d0,d3
		sub.w	d0,d5
				markScanLineChange d0
		move.w	a3,d0
		IFEQ	USEA7
			move.w	a2,d2
		ELSE
			move.l	usp,a0
			move.w	a0,d2
		ENDC
		move.w	checker_size4,d4
		eor.w	#%010101*STRUCTSIZE,d7
		jmp		determineSmallestNumber6
.aok82
	add.w	d6,d0
			markScanLineChange d0
		IFEQ	 USEA7
			move.l	savedA7,a7
		ENDC
	rts
;------------------------------------------------------------
.d0_d2_smallest_d1_d3_d4_done									; done
	cmp.w	d0,d5
	bgt		.d0_d2_smallest_d1_d3_d4_d5_done					; done
	beq		.d0_d2_d5_smallest_d1_d3_d4_done					; done
	bra		.d5_smallest_d0_d1_d2_d3_d4_done					; done
;------------------------------------------------------------	
.d0_d2_d5_smallest_d1_d3_d4_done								; done
	sub.w	d0,d6
	ble.s	.zok8
		sub.w	d0,d1
		sub.w	d0,d3
		sub.w	d0,d4
				markScanLineChange d0
		move.w	a3,d0
		IFEQ	USEA7
			move.w	a2,d2
		ELSE
			move.l	usp,a0
			move.w	a0,d2
		ENDC
		IFEQ 	USEA7
			move.l	usp,a0
			move.w	a0,d5
		ELSE
			move.w	checker_size5,d5
		ENDC
		eor.w	#%100101*STRUCTSIZE,d7
		jmp		determineSmallestNumber6
.zok8
	add.w	d6,d0
			markScanLineChange d0
		IFEQ	 USEA7
			move.l	savedA7,a7
		ENDC
	rts
;------------------------------------------------------------	
.d0_d2_smallest_d1_d3_d4_d5_done								; done
	sub.w	d0,d6
	ble.s	.ok8
		sub.w	d0,d1
		sub.w	d0,d3
		sub.w	d0,d4
		sub.w	d0,d5
				markScanLineChange d0
		move.w	a3,d0
		IFEQ	USEA7
			move.w	a2,d2
		ELSE
			move.l	usp,a0
			move.w	a0,d2
		ENDC
		eor.w	#%000101*STRUCTSIZE,d7
		jmp		determineSmallestNumber6
.ok8
	add.w	d6,d0
			markScanLineChange d0
		IFEQ	 USEA7
			move.l	savedA7,a7
		ENDC
	rts
;------------------------------------------------------------
.d0_d3_smallest_d1_d2_done										; done			
	cmp.w	d0,d4
	bgt		.d0_d3_smallest_d1_d2_d4_done						; done			
	blt		.d4_smallest_d0_d1_d2_d3_done						; done				
;------------------------------------------------------------
.d0_d3_d4_smallest_d1_d2_done									; done
	cmp.w	d0,d5
	bgt		.d0_d3_d4_smallest_d1_d2_d5_done					; done
	beq		.d0_d3_d4_d5_smallest_d1_d2_done					; done
	bra		.d5_smallest_d0_d1_d2_d3_d4_done					; done
;------------------------------------------------------------
.d0_d3_d4_d5_smallest_d1_d2_done								; done
	sub.w	d0,d6
	ble.s	.zzok11
		sub.w	d0,d1
		sub.w	d0,d2
				markScanLineChange d0
		move.w	a3,d0
		move.w	checker_size3,d3
		move.w	checker_size4,d4
		IFEQ 	USEA7
			move.l	usp,a0
			move.w	a0,d5
		ELSE
			move.w	checker_size5,d5
		ENDC
		eor.w	#%111001*STRUCTSIZE,d7
		jmp		determineSmallestNumber6
.zzok11
	add.w	d6,d0
			markScanLineChange d0
		IFEQ	 USEA7
			move.l	savedA7,a7
		ENDC
	rts
;------------------------------------------------------------
.d0_d3_d4_smallest_d1_d2_d5_done								; done
	sub.w	d0,d6
	ble.s	.ok11
		sub.w	d0,d1
		sub.w	d0,d2
		sub.w	d0,d5
				markScanLineChange d0
		move.w	a3,d0
		move.w	checker_size3,d3
		move.w	checker_size4,d4
		eor.w	#%011001*STRUCTSIZE,d7
		jmp		determineSmallestNumber6
.ok11
	add.w	d6,d0
			markScanLineChange d0
		IFEQ	 USEA7
			move.l	savedA7,a7
		ENDC
	rts
;------------------------------------------------------------
.d0_d3_smallest_d1_d2_d4_done									; done
	cmp.w	d0,d5
	bgt		.d0_d3_smallest_d1_d2_d4_d5_done					; done
	beq		.d0_d3_d5_smallest_d1_d2_d4_done					; done
	bra		.d5_smallest_d0_d1_d2_d3_d4_done					; done
;------------------------------------------------------------
.d0_d3_d5_smallest_d1_d2_d4_done								; done
	sub.w	d0,d6
	ble.s	.zok111
		sub.w	d0,d1
		sub.w	d0,d2
		sub.w	d0,d4
				markScanLineChange d0
		move.w	a3,d0
		IFEQ 	USEA7
			move.l	usp,a0
			move.w	a0,d5
		ELSE
			move.w	checker_size5,d5
		ENDC
		move.w	checker_size3,d3
		eor.w	#%101001*STRUCTSIZE,d7
		jmp		determineSmallestNumber6
.zok111
	add.w	d6,d0
			markScanLineChange d0
		IFEQ	 USEA7
			move.l	savedA7,a7
		ENDC
	rts	
;------------------------------------------------------------
.d0_d3_smallest_d1_d2_d4_d5_done								; done
	sub.w	d0,d6
	ble.s	.ok111
		sub.w	d0,d1
		sub.w	d0,d2
		sub.w	d0,d4
		sub.w	d0,d5

				markScanLineChange d0
		move.w	a3,d0
		move.w	checker_size3,d3
		eor.w	#%001001*STRUCTSIZE,d7
		jmp		determineSmallestNumber6
.ok111
	add.w	d6,d0
			markScanLineChange d0
		IFEQ	 USEA7
			move.l	savedA7,a7
		ENDC
	rts	
;------------------------------------------------------------
.d0_d1_smallest_d2_d3_done										; done						
	cmp.w	d0,d4
	bgt		.d0_d1_smallest_d2_d3_d4_done						; done	
	blt		.d4_smallest_d0_d1_d2_d3_done						; done						
;------------------------------------------------------------
.d0_d1_d4_smallest_d2_d3_done
	cmp.w	d0,d5
	bgt		.d0_d1_d4_smallest_d2_d3_d5_done					; done
	beq		.d0_d1_d4_d5_smallest_d2_d3_done					; done
	bra		.d5_smallest_d0_d1_d2_d3_d4_done					; done
;------------------------------------------------------------
.d0_d1_d4_d5_smallest_d2_d3_done
	sub.w	d0,d6
	ble.s	.zok12a
		sub.w	d0,d2
		sub.w	d0,d3
				markScanLineChange d0
		move.w	a3,d0
		move.w	a1,d1
		move.w	checker_size4,d4
		IFEQ 	USEA7
			move.l	usp,a0
			move.w	a0,d5
		ELSE
			move.w	checker_size5,d5
		ENDC
		eor.w	#%110011*STRUCTSIZE,d7
		jmp		determineSmallestNumber6
.zok12a
	add.w	d6,d0
			markScanLineChange d0
		IFEQ	 USEA7
			move.l	savedA7,a7
		ENDC
	rts
;------------------------------------------------------------
.d0_d1_d4_smallest_d2_d3_d5_done								; done
	sub.w	d0,d6
	ble.s	.ok12a
		sub.w	d0,d2
		sub.w	d0,d3
		sub.w	d0,d5
				markScanLineChange d0
		move.w	a3,d0
		move.w	a1,d1
		move.w	checker_size4,d4
		eor.w	#%010011*STRUCTSIZE,d7
		jmp		determineSmallestNumber6
.ok12a
	add.w	d6,d0
			markScanLineChange d0
		IFEQ	 USEA7
			move.l	savedA7,a7
		ENDC
	rts
;------------------------------------------------------------
.d0_d1_smallest_d2_d3_d4_done									; done
	cmp.w	d0,d5
	bgt		.d0_d1_smallest_d2_d3_d4_d5_done					; done
	beq		.d0_d1_d5_smallest_d2_d3_d4_done					; done
	bra		.d5_smallest_d0_d1_d2_d3_d4_done					; done
;------------------------------------------------------------
.d0_d1_d5_smallest_d2_d3_d4_done								; done
	sub.w	d0,d6
	ble.s	.ok12
		sub.w	d0,d2
		sub.w	d0,d3
		sub.w	d0,d4
				markScanLineChange d0
		move.w	a3,d0
		move.w	a1,d1
		IFEQ 	USEA7
			move.l	usp,a0
			move.w	a0,d5
		ELSE
			move.w	checker_size5,d5
		ENDC
		eor.w	#%100011*STRUCTSIZE,d7
		jmp		determineSmallestNumber6
.ok12
	add.w	d6,d0
			markScanLineChange d0
		IFEQ	 USEA7
			move.l	savedA7,a7
		ENDC
	rts
;------------------------------------------------------------
.d0_d1_smallest_d2_d3_d4_d5_done								; done
	sub.w	d0,d6
	ble.s	.zok12
		sub.w	d0,d2
		sub.w	d0,d3
		sub.w	d0,d4
		sub.w	d0,d5
				markScanLineChange d0
		move.w	a3,d0
		move.w	a1,d1
		eor.w	#%000011*STRUCTSIZE,d7
		jmp		determineSmallestNumber6
.zok12
	add.w	d6,d0
			markScanLineChange d0
		IFEQ	 USEA7
			move.l	savedA7,a7
		ENDC
	rts
;------------------------------------------------------------
.d0_d1_d3_smallest_d2_done										; done							
	cmp.w	d0,d4
	bgt		.d0_d1_d3_smallest_d2_d4_done						; done
	blt		.d4_smallest_d0_d1_d2_d3_done						; done
;------------------------------------------------------------	
.d0_d1_d3_d4_smallest_d2_done									; done
	cmp.w	d0,d5
	bgt		.d0_d1_d3_d4_smallest_d2_d5_done					; done
	beq		.d0_d1_d3_d4_d5_smallest_d2_done					; done
	bra		.d5_smallest_d0_d1_d2_d3_d4_done					; done
;------------------------------------------------------------	
.d0_d1_d3_d4_d5_smallest_d2_done								; done
	sub.w	d0,d6
	ble.s	.ok133z
		sub.w	d0,d2
				markScanLineChange d0
		move.w	a3,d0
		move.w	a1,d1
		move.w	checker_size3,d3
		move.w	checker_size4,d4
		IFEQ 	USEA7
			move.l	usp,a0
			move.w	a0,d5
		ELSE
			move.w	checker_size5,d5
		ENDC
		eor.w	#%111011*STRUCTSIZE,d7
		jmp		determineSmallestNumber6
.ok133z
	add.w	d6,d0
			markScanLineChange d0
		IFEQ	 USEA7
			move.l	savedA7,a7
		ENDC
	rts
;------------------------------------------------------------
.d0_d1_d3_d4_smallest_d2_d5_done								; done
	sub.w	d0,d6
	ble.s	.ok133
		sub.w	d0,d2
		sub.w	d0,d5
				markScanLineChange d0
		move.w	a3,d0
		move.w	a1,d1
		move.w	checker_size3,d3
		move.w	checker_size4,d4
		eor.w	#%011011*STRUCTSIZE,d7
		jmp		determineSmallestNumber6
.ok133
	add.w	d6,d0
			markScanLineChange d0
		IFEQ	 USEA7
			move.l	savedA7,a7
		ENDC
	rts
;------------------------------------------------------------
.d0_d1_d3_smallest_d2_d4_done									; done
	cmp.w	d0,d5
	bgt		.d0_d1_d3_smallest_d2_d4_d5_done					; done
	beq		.d0_d1_d3_d5_smallest_d2_d4_done					; done
	bra		.d5_smallest_d0_d1_d2_d3_d4_done					; done
;------------------------------------------------------------
.d0_d1_d3_d5_smallest_d2_d4_done								; done					
	sub.w	d0,d6
	ble.s	.aok13
		sub.w	d0,d2
		sub.w	d0,d4
				markScanLineChange d0
		move.w	a3,d0
		IFEQ 	USEA7
			move.l	usp,a0
			move.w	a0,d5
		ELSE
			move.w	checker_size5,d5
		ENDC
		move.w	a1,d1
		move.w	checker_size3,d3
		eor.w	#%101011*STRUCTSIZE,d7
		jmp		determineSmallestNumber6
.aok13
	add.w	d6,d0
			markScanLineChange d0
		IFEQ	 USEA7
			move.l	savedA7,a7
		ENDC
	rts
;------------------------------------------------------------
.d0_d1_d3_smallest_d2_d4_d5_done								; done					
	sub.w	d0,d6
	ble.s	.ok13
		sub.w	d0,d2
		sub.w	d0,d4
		sub.w	d0,d5
				markScanLineChange d0
		move.w	a3,d0
		move.w	a1,d1
		move.w	checker_size3,d3
		eor.w	#%001011*STRUCTSIZE,d7
		jmp		determineSmallestNumber6
.ok13
	add.w	d6,d0
			markScanLineChange d0
		IFEQ	 USEA7
			move.l	savedA7,a7
		ENDC
	rts
;------------------------------------------------------------
.d0_d1_d2_smallest_d3_done										; done
	cmp.w	d0,d4			
	bgt		.d0_d1_d2_smallest_d3_d4_done						; done
	blt		.d4_smallest_d0_d1_d2_d3_done						; done		
;------------------------------------------------------------
.d0_d1_d2_d4_smallest_d3_done
	cmp.w	d0,d5
	bgt		.d0_d1_d2_d4_smallest_d3_d5_done					; done
	beq		.d0_d1_d2_d4_d5_smallest_d3_done					; done
	bra		.d5_smallest_d0_d1_d2_d3_d4_done					; done
;------------------------------------------------------------
.d0_d1_d2_d4_d5_smallest_d3_done								; done					
	sub.w	d0,d6
	ble.s	.zokkkk
		sub.w	d0,d3
				markScanLineChange d0
		move.w	a3,d0
		IFEQ 	USEA7
			move.l	usp,a0
			move.w	a0,d5
		ELSE
			move.w	checker_size5,d5
		ENDC
		move.w	a1,d1
		IFEQ	USEA7
			move.w	a2,d2
		ELSE
			move.l	usp,a0
			move.w	a0,d2
		ENDC
		move.w	checker_size4,d4
		eor.w	#%110111*STRUCTSIZE,d7
		jmp		determineSmallestNumber6
.zokkkk
	add.w	d6,d0
			markScanLineChange d0
		IFEQ	 USEA7
			move.l	savedA7,a7
		ENDC
	rts
;------------------------------------------------------------
.d0_d1_d2_d4_smallest_d3_d5_done								; done
	sub.w	d0,d6
	ble.s	.okkkk
		sub.w	d0,d3
		sub.w	d0,d5
				markScanLineChange d0
		move.w	a3,d0
		move.w	a1,d1
		IFEQ	USEA7
			move.w	a2,d2
		ELSE
			move.l	usp,a0
			move.w	a0,d2
		ENDC
		move.w	checker_size4,d4
		eor.w	#%010111*STRUCTSIZE,d7
		jmp		determineSmallestNumber6
.okkkk
	add.w	d6,d0
			markScanLineChange d0
		IFEQ	 USEA7
			move.l	savedA7,a7
		ENDC
	rts
;------------------------------------------------------------
.d0_d1_d2_smallest_d3_d4_done									; done
	cmp.w	d0,d5
	bgt		.d0_d1_d2_smallest_d3_d4_d5_done					; done
	beq		.d0_d1_d2_d5_smallest_d3_d4_done					; done
	bra		.d5_smallest_d0_d1_d2_d3_d4_done					; done
;------------------------------------------------------------
.d0_d1_d2_d5_smallest_d3_d4_done								; done
	sub.w	d0,d6
	ble.s	.zok14
		sub.w	d0,d3
		sub.w	d0,d4
				markScanLineChange d0
		move.w	a3,d0
		IFEQ 	USEA7
			move.l	usp,a0
			move.w	a0,d5
		ELSE
			move.w	checker_size5,d5
		ENDC
		move.w	a1,d1
		IFEQ	USEA7
			move.w	a2,d2
		ELSE
			move.l	usp,a0
			move.w	a0,d2
		ENDC
		eor.w	#%100111*STRUCTSIZE,d7
		jmp		determineSmallestNumber6
.zok14
	add.w	d6,d0
			markScanLineChange d0
		IFEQ	 USEA7
			move.l	savedA7,a7
		ENDC
	rts
;------------------------------------------------------------
.d0_d1_d2_smallest_d3_d4_d5_done								; done
	sub.w	d0,d6
	ble.s	.ok14
		sub.w	d0,d3
		sub.w	d0,d4
		sub.w	d0,d5
				markScanLineChange d0
		move.w	a3,d0
		move.w	a1,d1
		IFEQ	USEA7
			move.w	a2,d2
		ELSE
			move.l	usp,a0
			move.w	a0,d2
		ENDC
		eor.w	#%000111*STRUCTSIZE,d7
		jmp		determineSmallestNumber6
.ok14
	add.w	d6,d0
			markScanLineChange d0
		IFEQ	 USEA7
			move.l	savedA7,a7
		ENDC
	rts
;------------------------------------------------------------
.d0_d2_d3_smallest_d1_done										; done
	cmp.w	d0,d4
	bgt		.d0_d2_d3_smallest_d1_d4_done						; done
	blt		.d4_smallest_d0_d1_d2_d3_done						; done			
;------------------------------------------------------------
.d0_d2_d3_d4_smallest_d1_done									; done
	cmp.w	d0,d5
	bgt		.d0_d2_d3_d4_smallest_d1_d5_done					; done
	beq		.d0_d2_d3_d4_d5_smallest_d1_done					; done
	bra		.d5_smallest_d0_d1_d2_d3_d4_done					; done
;------------------------------------------------------------		
.d0_d2_d3_d4_d5_smallest_d1_done								; done
	sub.w	d0,d6
	ble.s	.zok9zz
		sub.w	d0,d1
				markScanLineChange d0
		move.w	a3,d0
		IFEQ	USEA7
			move.w	a2,d2
		ELSE
			move.l	usp,a0
			move.w	a0,d2
		ENDC
		move.w	checker_size3,d3
		move.w	checker_size4,d4
		IFEQ 	USEA7
			move.l	usp,a0
			move.w	a0,d5
		ELSE
			move.w	checker_size5,d5
		ENDC
		move.w	a0,d5
		eor.w	#%111101*STRUCTSIZE,d7
		jmp		determineSmallestNumber6
.zok9zz
	add.w	d6,d0
			markScanLineChange d0
		IFEQ	 USEA7
			move.l	savedA7,a7
		ENDC
	rts
;------------------------------------------------------------		
.d0_d2_d3_d4_smallest_d1_d5_done								; done
	sub.w	d0,d6
	ble.s	.ok9zz
		sub.w	d0,d1
		sub.w	d0,d5
				markScanLineChange d0
		move.w	a3,d0
		IFEQ	USEA7
			move.w	a2,d2
		ELSE
			move.l	usp,a0
			move.w	a0,d2
		ENDC
		move.w	checker_size3,d3
		move.w	checker_size4,d4
		eor.w	#%011101*STRUCTSIZE,d7
		jmp		determineSmallestNumber6
.ok9zz
	add.w	d6,d0
			markScanLineChange d0
		IFEQ	 USEA7
			move.l	savedA7,a7
		ENDC
	rts
;------------------------------------------------------------
.d0_d2_d3_smallest_d1_d4_done									; done
	cmp.w	d0,d5
	bgt		.d0_d2_d3_smallest_d1_d4_d5_done					; done
	beq		.d0_d2_d3_d5_smallest_d1_d4_done					; done
	blt		.d5_smallest_d0_d1_d2_d3_d4_done					; done
;------------------------------------------------------------	
.d0_d2_d3_d5_smallest_d1_d4_done								; done	
	sub.w	d0,d6
	ble.s	.ok99
		sub.w	d0,d1
		sub.w	d0,d4
				markScanLineChange d0
		move.w	a3,d0
		IFEQ	USEA7
			move.w	a2,d2
		ELSE
			move.l	usp,a0
			move.w	a0,d2
		ENDC
		move.w	checker_size3,d3
		IFEQ 	USEA7
			move.l	usp,a0
			move.w	a0,d5
		ELSE
			move.w	checker_size5,d5
		ENDC
		eor.w	#%101101*STRUCTSIZE,d7
		jmp		determineSmallestNumber6
.ok99
	add.w	d6,d0
			markScanLineChange d0
		IFEQ	 USEA7
			move.l	savedA7,a7
		ENDC
	rts
;------------------------------------------------------------
.d0_d2_d3_smallest_d1_d4_d5_done								; done				
	sub.w	d0,d6
	ble.s	.ok99z
		sub.w	d0,d1
		sub.w	d0,d4
		sub.w	d0,d5
				markScanLineChange d0
		move.w	a3,d0
		IFEQ	USEA7
			move.w	a2,d2
		ELSE
			move.l	usp,a0
			move.w	a0,d2
		ENDC
		move.w	checker_size3,d3
		eor.w	#%001101*STRUCTSIZE,d7
		jmp		determineSmallestNumber6
.ok99z
	add.w	d6,d0
			markScanLineChange d0
		IFEQ	 USEA7
			move.l	savedA7,a7
		ENDC
	rts
;------------------------------------------------------------
.d0_d1_d2_d3_equal												; done								
	cmp.w	d0,d4
	bgt		.d0_d1_d2_d3_smallest_d4_done						; done
	blt		.d4_smallest_d0_d1_d2_d3_done						; done		
;------------------------------------------------------------
.d0_d1_d2_d3_d4_equal			
	cmp.w	d0,d5
	bgt		.d0_d1_d2_d3_d4_smallest_d5_done					; done
	beq		.d0_d1_d2_d3_d4_d5_equal							; done
	bra		.d5_smallest_d0_d1_d2_d3_d4_done					; done
;------------------------------------------------------------			
.d0_d1_d2_d3_d4_d5_equal										; done
	sub.w	d0,d6
	ble.s	.zok15z
				markScanLineChange d0
		move.w	a3,d0
		move.w	a1,d1
		IFEQ	USEA7
			move.w	a2,d2
		ELSE
			move.l	usp,a0
			move.w	a0,d2
		ENDC
		move.w	checker_size3,d3
		move.w	checker_size4,d4
		IFEQ 	USEA7
			move.l	usp,a0
			move.w	a0,d5
		ELSE
			move.w	checker_size5,d5
		ENDC
		eor.w	#%111111*STRUCTSIZE,d7
		jmp		determineSmallestNumber6
.zok15z
	add.w	d6,d0
			markScanLineChange d0
		IFEQ	 USEA7
			move.l	savedA7,a7
		ENDC
	rts
;------------------------------------------------------------
.d0_d1_d2_d3_d4_smallest_d5_done								; done
	sub.w	d0,d6
	ble.s	.ok15z
		sub.w	d0,d5
				markScanLineChange d0
		move.w	a3,d0
		move.w	a1,d1
		IFEQ	USEA7
			move.w	a2,d2
		ELSE
			move.l	usp,a0
			move.w	a0,d2
		ENDC
		move.w	checker_size3,d3
		move.w	checker_size4,d4
		eor.w	#%011111*STRUCTSIZE,d7
		jmp		determineSmallestNumber6
.ok15z
	add.w	d6,d0
			markScanLineChange d0
		IFEQ	 USEA7
			move.l	savedA7,a7
		ENDC
	rts
;------------------------------------------------------------
.d0_d1_d2_d3_smallest_d4_done									; done
	cmp.w	d0,d5
	bgt		.d0_d1_d2_d3_smallest_d4_d5_done					; done
	beq		.d0_d1_d2_d3_d5_smallest_d4_done					; done
	bra		.d5_smallest_d0_d1_d2_d3_d4_done					; done
;------------------------------------------------------------
.d0_d1_d2_d3_d5_smallest_d4_done								; done
	sub.w	d0,d6
	ble.s	.zok15a
		sub.w	d0,d4
				markScanLineChange d0
		move.w	a3,d0
		move.w	a1,d1
		IFEQ	USEA7
			move.w	a2,d2
		ELSE
			move.l	usp,a0
			move.w	a0,d2
		ENDC
		move.w	checker_size3,d3
		IFEQ 	USEA7
			move.l	usp,a0
			move.w	a0,d5
		ELSE
			move.w	checker_size5,d5
		ENDC
		eor.w	#%101111*STRUCTSIZE,d7
		jmp		determineSmallestNumber6
.zok15a
	add.w	d6,d0
			markScanLineChange d0
		IFEQ	 USEA7
			move.l	savedA7,a7
		ENDC
	rts
;------------------------------------------------------------
.d0_d1_d2_d3_smallest_d4_d5_done								; done
	sub.w	d0,d6
	ble.s	.ok15a
		sub.w	d0,d4
		sub.w	d0,d5
				markScanLineChange d0
		move.w	a3,d0
		move.w	a1,d1
		IFEQ	USEA7
			move.w	a2,d2
		ELSE
			move.l	usp,a0
			move.w	a0,d2
		ENDC
		move.w	checker_size3,d3
		eor.w	#%001111*STRUCTSIZE,d7
		jmp		determineSmallestNumber6
.ok15a
	add.w	d6,d0
			markScanLineChange d0
		IFEQ	 USEA7
			move.l	savedA7,a7
		ENDC
	rts
;------------------------------------------------------------
treeend


doScanLineNew	macro
	move.l	(a3)+,d3			;12				32 pixels layer 3 = plane 3, inverse
	bne		.normal\@

	; when we get here, we know that plane 4, is 32 px, so we only wnat to have layer 4 and layer 5 done
	; a0 is advanced
	moveq	#-1,d3			;4
	moveq	#-1,d7			;4
	move.w	(a5)+,d0		;8				move.l	(a5)+,d0		;12
	move.w	(a5)+,d4		;8				move.w	d0,d4			;4
	lea		4(a0),a0		;8
	lea		4(a1),a1		;8
	lea		4(a2),a2		;8
	lea		4(a6),a6		;8		7*8 = 56	
	jmp		.end\@

.normal\@
	move.l	(a0)+,d0			;12				32 pixels layer 0 = plane 0
	and.l	d3,d0				;8				NOT 4 on plane 0
	move.l	(a5)+,d7			;12				32 pixels of layer 5
	or.l	d7,d0				;8		52		OR layer 5 to plane 0		(layer 5 =  plane 0 + plane 4, so I dont want overlap, hence NOT layer 4)

	move.l	(a1)+,d1			;12				32 pixels layer 1 = plane 1
	move.l	(a2)+,d2			;12				32 pixels layer 2 = plane 2, inverse
	and.l	d2,d1				;8				NOT 3 on plane 1
	move.l	(a6)+,d6			;12				32 pixels of laayer 6
	or.l	d6,d1				;8		52		OR laayer 6 to plane 3		(layer 6 = plane 2 + plane 3, so I dont want overlap)

	not.l	d2					;8				inverse the inverse pixels of layer 2 to fit plane 2
	or.l	d6,d2				;8		16		OR layer 6 into plane 2

	not.l	d3					;8				invserse the inverse of pixels of laayer 4 to fit plane 4
	or.l	d7,d3				;8	16-->136	OR laayer 5 into plane 4
	
	move.w	d0,d4				;4				because of movem, I want to reorder the words
	move.w	d1,d5				;4
	move.w	d2,d6				;4
	move.w	d3,d7				;4		16

	swap	d0					;4				because of movem I want to reorder the words
	swap	d1					;4
	swap	d2					;4
	swap	d3					;4		16																;
.end\@
	movem.w	d0-d7,x(a4)			;28				60		--> 196... 10* 196 = 1960

	endm





getNextScanLine	macro

	move.l	usp,a4								;2
	move.w	(a4)+,a6							;2
	move.l	a4,usp								;2
	jmp		GENERATE_SCANLINE_OFFSET(a6)		;2

	endm



drawStart
drawUniqueLinesNew
;	nop

;	move.l	a0,d0		;	d0=a0
;	move.l	a1,d1		;	d1=a1
;	move.l	a2,d2		;	d2=a2
;	move.l	a3,d3		;	d3=a3
	move.l	a4,d4		;	d4=a4
;;	move.l	a5,d6		;	d6=a5

	lea		save0,a6
	movem.l	a0-a5,(a6)		; store 6

;	move.l	d0,a0
;	nop
;	nop

	move.l	d4,a5				; herp

	move.l	currentDrawListPointer_consumer,a4
	move.l	a4,usp
	jmp		getNextScanLine1
;---------------------------------------------------
	IFEQ	genlower
	ELSE
generateScanLine
	ENDC
x set 0
		REPT 10
			doScanLineNew	0,0
x set x+16
		ENDR

		movem.l	save0,a0-a3/a5
getNextScanLine1
				getNextScanLine
;---------------------------------------------------
	IFEQ	genlower
	ELSE
generateScanLineMinus
	ENDC
x set 0
		REPT 10
			doScanLineNew	1,0
x set x+16
		ENDR

		movem.l	save0,a0-a3/a5
getNextScanLine2
				getNextScanLine	
;---------------------------------------------------
	IFEQ	genlower
	ELSE
generateScanLine
	ENDC
x set 0
		REPT 10
			doScanLineNew	0,1
x set x+16
		ENDR

		movem.l	save0,a0-a3/a5
getNextScanLine3
				getNextScanLine
;---------------------------------------------------
	IFEQ	genlower
	ELSE
generateScanLine
	ENDC
x set 0
		REPT 10
;			doScanLineNew	1,1
x set x+16
		ENDR

;		movem.l	save0,a0-a3/a5
getNextScanLine4
;				getNextScanLine	
;---------------------------------------------------
doEnd
	rts	
						;	4				;	5
;	0001	=	1			1					1		-4+5, preventing 4 on 1, but is 5
;	0010	=	2			2					2		
;	0011	=	3			2 	on 1			2 on 1
;	0100	=	4			3					3
;	0101	=	5			3 	on 1			3 on 1
;	0110	=	6			3 	on 2			3 on 2
;	0111	=	7			3 	on 2+1			3 on 2+1
;	1000	=	8			4					4 		+5, so that 
;	1001	=	9			4 	on 1			5
;	1010	=	10			4 	on 2			4 on 2
;	1011	=	11			4 	on 1+2			5 on 2
;	1100	=	12			4 	on 3			4 on 3
;	1101	=	13			4 	on 1+3			5 on 3
;	1110	=	14			4 	on 2+3			4 on 2+3
;	1111	=	15			4 	on 1+2+3		5 on 2+3


;----- for each scanline mask in the table do
; TODO: if we scrounge cycles; we can evenly space the cases, and do a direct jump into the code, instead of indirect; would save 12*16 cycles total (or 12*32 5 layer)

;	move.l	#drawStart,d0
;	sub.l	#doEnd,d0			; delta
;	move.l	#scanLineCode,d1
;	add.l	d0,d1				; save0 address
;	move.l	d1,save0Pointer

save0	ds.l	1
save1	ds.l	1
save2	ds.l	1
save3	ds.l	1
save4	ds.l	1
save5	ds.l	1


spaceUp	macro
	ds.b	32*2-4*(3+\1)
	endm


directJumpTable	 
.bm00000x
	move.l	2(a6),a4			; yoff				;2
	move.l	save5,a6
	lea		LINESIZE(a2),a2
	lea		LINESIZE(a3),a3
	jmp		generateScanLine						;4		
			spaceUp 2
.bm00001x
	move.l	2(a6),a4			; yoff				;2
	move.l	save5,a6
 	lea		LINESIZE(a0),a0
	lea		LINESIZE(a2),a2
	lea		LINESIZE(a3),a3
	jmp		generateScanLine
			spaceUp 3
.bm00010x
	move.l	2(a6),a4			; yoff				;2
	move.l	save5,a6
	lea		LINESIZE(a1),a1
	lea		LINESIZE(a2),a2
	lea		LINESIZE(a3),a3
	jmp		generateScanLine
			spaceUp 3
.bm00011x
	move.l	2(a6),a4			; yoff				;2
	move.l	save5,a6
	lea		LINESIZE(a0),a0
	lea		LINESIZE(a1),a1
	lea		LINESIZE(a2),a2
	lea		LINESIZE(a3),a3
	jmp		generateScanLine
			spaceUp 4
.bm00100x
	move.l	2(a6),a4			; yoff				;2
	move.l	save5,a6
	lea		LINESIZE(a3),a3
	jmp		generateScanLine
			spaceUp 1
.bm00101x
	move.l	2(a6),a4			; yoff				;2
	move.l	save5,a6
	lea		LINESIZE(a0),a0
	lea		LINESIZE(a3),a3
	jmp		generateScanLine
			spaceUp 2
.bm00110x
	move.l	2(a6),a4			; yoff				;2
	move.l	save5,a6
	lea		LINESIZE(a1),a1
	lea		LINESIZE(a3),a3
	jmp		generateScanLine
			spaceUp 2
.bm00111x
	move.l	2(a6),a4			; yoff				;2
	move.l	save5,a6
	lea		LINESIZE(a0),a0
	lea		LINESIZE(a1),a1
	lea		LINESIZE(a3),a3
	jmp		generateScanLine
			spaceUp 3
.bm01000x
	move.l	2(a6),a4			; yoff										
	move.l	save5,a6
	lea		LINESIZE(a2),a2
	jmp		generateScanLine
			spaceUp 1
.bm01001x
	move.l	2(a6),a4			; yoff										
	move.l	save5,a6
	lea		LINESIZE(a0),a0
	lea		LINESIZE(a2),a2
	jmp		generateScanLine
			spaceUp 2
.bm01010x
	move.l	2(a6),a4			; yoff										
	move.l	save5,a6
	lea		LINESIZE(a1),a1
	lea		LINESIZE(a2),a2
	jmp		generateScanLine
			spaceUp 2
.bm01011x
	move.l	2(a6),a4			; yoff										
	move.l	save5,a6
	lea		LINESIZE(a0),a0
	lea		LINESIZE(a1),a1
	lea		LINESIZE(a2),a2
	jmp		generateScanLine
			spaceUp 3
.bm01100x
	move.l	2(a6),a4			; yoff										
	move.l	save5,a6
	jmp		generateScanLine
			spaceUp 0
.bm01101x
	move.l	2(a6),a4			; yoff										
	move.l	save5,a6
	lea		LINESIZE(a0),a0
	jmp		generateScanLine
			spaceUp 1
.bm01110x
	move.l	2(a6),a4			; yoff										
	move.l	save5,a6
	lea		LINESIZE(a1),a1
	jmp		generateScanLine
			spaceUp 1
.bm01111x
	move.l	2(a6),a4			; yoff										
	move.l	save5,a6
	lea		LINESIZE(a0),a0
	lea		LINESIZE(a1),a1
	jmp		generateScanLine
			spaceUp 2
.bm10000x
	move.l	2(a6),a4			; yoff										
	move.l	save5,a6
	lea		LINESIZE(a5),a5
	lea		LINESIZE(a2),a2
	lea		LINESIZE(a3),a3
	jmp		generateScanLine
			spaceUp 3
.bm10001x
	move.l	2(a6),a4			; yoff										
	move.l	save5,a6
 	lea		LINESIZE(a0),a0
	lea		LINESIZE(a2),a2
	lea		LINESIZE(a3),a3
	lea		LINESIZE(a5),a5
	jmp		generateScanLine
			spaceUp 4
.bm10010x
	move.l	2(a6),a4			; yoff										
	move.l	save5,a6
 	lea		LINESIZE(a1),a1
	lea		LINESIZE(a2),a2
	lea		LINESIZE(a3),a3
	lea		LINESIZE(a5),a5
	jmp		generateScanLine
			spaceUp 4
.bm10011x
	move.l	2(a6),a4			; yoff										
	move.l	save5,a6
	lea		LINESIZE(a0),a0
	lea		LINESIZE(a1),a1
	lea		LINESIZE(a2),a2
	lea		LINESIZE(a3),a3
	lea		LINESIZE(a5),a5
	jmp		generateScanLine
			spaceUp 5
.bm10100x
	move.l	2(a6),a4			; yoff										
	move.l	save5,a6
	lea		LINESIZE(a3),a3
	lea		LINESIZE(a5),a5
	jmp		generateScanLine
			spaceUp 2
.bm10101x
	move.l	2(a6),a4			; yoff										
	move.l	save5,a6
	lea		LINESIZE(a0),a0
	lea		LINESIZE(a3),a3
	lea		LINESIZE(a5),a5
	jmp		generateScanLine
			spaceUp 3
.bm10110x
	move.l	2(a6),a4			; yoff										
	move.l	save5,a6
	lea		LINESIZE(a1),a1
	lea		LINESIZE(a3),a3
	lea		LINESIZE(a5),a5
	jmp		generateScanLine
			spaceUp 3
.bm10111x
	move.l	2(a6),a4			; yoff										
	move.l	save5,a6
	lea		LINESIZE(a0),a0
	lea		LINESIZE(a1),a1
	lea		LINESIZE(a3),a3
	lea		LINESIZE(a5),a5
	jmp		generateScanLine
			spaceUp 4
.bm11000x
	move.l	2(a6),a4			; yoff										
	move.l	save5,a6
	lea		LINESIZE(a2),a2
	lea		LINESIZE(a5),a5
	jmp		generateScanLine
			spaceUp 2
.bm11001x
	move.l	2(a6),a4			; yoff										
	move.l	save5,a6
	lea		LINESIZE(a0),a0
	lea		LINESIZE(a2),a2
	lea		LINESIZE(a5),a5
	jmp		generateScanLine
			spaceUp 3
.bm11010x
	move.l	2(a6),a4			; yoff										
	move.l	save5,a6
	lea		LINESIZE(a1),a1
	lea		LINESIZE(a2),a2
	lea		LINESIZE(a5),a5
	jmp		generateScanLine
			spaceUp 3
.bm11011x
	move.l	2(a6),a4			; yoff										
	move.l	save5,a6
	lea		LINESIZE(a0),a0
	lea		LINESIZE(a1),a1
	lea		LINESIZE(a2),a2
	lea		LINESIZE(a5),a5
	jmp		generateScanLine
			spaceUp 4
.bm11100x
	move.l	2(a6),a4			; yoff										
	move.l	save5,a6
	lea		LINESIZE(a5),a5
	jmp		generateScanLine
			spaceUp 1
.bm11101x
	move.l	2(a6),a4			; yoff										
	move.l	save5,a6
	lea		LINESIZE(a0),a0
	lea		LINESIZE(a5),a5
	jmp		generateScanLine
			spaceUp 2
.bm11110x
	move.l	2(a6),a4			; yoff										
	move.l	save5,a6
	lea		LINESIZE(a1),a1
	lea		LINESIZE(a5),a5
	jmp		generateScanLine
			spaceUp 2
.bm11111x
	move.l	2(a6),a4			; yoff										
	move.l	save5,a6
	lea		LINESIZE(a0),a0
	lea		LINESIZE(a1),a1
	lea		LINESIZE(a5),a5
	jmp		generateScanLine
			spaceUp 3
.bm100000x
	move.l	2(a6),a4			; yoff	
	move.l	save5,a6
	lea		LINESIZE(a2),a2
	lea		LINESIZE(a3),a3
	lea		LINESIZE(a6),a6
	jmp		generateScanLine
			spaceUp 3
.bm100001x
	move.l	2(a6),a4			; yoff										
	move.l	save5,a6
 	lea		LINESIZE(a0),a0
	lea		LINESIZE(a2),a2
	lea		LINESIZE(a3),a3
	lea		LINESIZE(a6),a6
	jmp		generateScanLine
			spaceUp 4
.bm100010x
	move.l	2(a6),a4			; yoff										
	move.l	save5,a6
	lea		LINESIZE(a1),a1
	lea		LINESIZE(a2),a2
	lea		LINESIZE(a3),a3
	lea		LINESIZE(a6),a6
	jmp		generateScanLine
			spaceUp 4
.bm100011x
	move.l	2(a6),a4			; yoff										
	move.l	save5,a6
	lea		LINESIZE(a0),a0
	lea		LINESIZE(a1),a1
	lea		LINESIZE(a2),a2
	lea		LINESIZE(a3),a3
	lea		LINESIZE(a6),a6
	jmp		generateScanLine
			spaceUp 5
.bm100100x
	move.l	2(a6),a4			; yoff										
	move.l	save5,a6
	lea		LINESIZE(a3),a3
	lea		LINESIZE(a6),a6
	jmp		generateScanLine
			spaceUp 2
.bm100101x
	move.l	2(a6),a4			; yoff										
	move.l	save5,a6
	lea		LINESIZE(a0),a0
	lea		LINESIZE(a3),a3
	lea		LINESIZE(a6),a6
	jmp		generateScanLine
			spaceUp 3
.bm100110x
	move.l	2(a6),a4			; yoff										
	move.l	save5,a6
	lea		LINESIZE(a1),a1
	lea		LINESIZE(a3),a3
	lea		LINESIZE(a6),a6
	jmp		generateScanLine
			spaceUp 3
.bm100111x
	move.l	2(a6),a4			; yoff										
	move.l	save5,a6
	lea		LINESIZE(a0),a0
	lea		LINESIZE(a1),a1
	lea		LINESIZE(a3),a3
	lea		LINESIZE(a6),a6
	jmp		generateScanLine
			spaceUp 4
.bm101000x
	move.l	2(a6),a4			; yoff										
	move.l	save5,a6
	lea		LINESIZE(a2),a2
	lea		LINESIZE(a6),a6
	jmp		generateScanLine
			spaceUp 2
.bm101001x
	move.l	2(a6),a4			; yoff										
	move.l	save5,a6
	lea		LINESIZE(a0),a0
	lea		LINESIZE(a2),a2
	lea		LINESIZE(a6),a6
	jmp		generateScanLine
			spaceUp 3
.bm101010x
	move.l	2(a6),a4			; yoff										
	move.l	save5,a6
	lea		LINESIZE(a1),a1
	lea		LINESIZE(a2),a2
	lea		LINESIZE(a6),a6
	jmp		generateScanLine
			spaceUp 3
.bm101011x
	move.l	2(a6),a4			; yoff										
	move.l	save5,a6
	lea		LINESIZE(a0),a0
	lea		LINESIZE(a1),a1
	lea		LINESIZE(a2),a2
	lea		LINESIZE(a6),a6
	jmp		generateScanLine
			spaceUp 4
.bm101100x
	move.l	2(a6),a4			; yoff										
	move.l	save5,a6
	lea		LINESIZE(a6),a6
	jmp		generateScanLine
			spaceUp 1
.bm101101x
	move.l	2(a6),a4			; yoff										
	move.l	save5,a6
	lea		LINESIZE(a0),a0
	lea		LINESIZE(a6),a6
	jmp		generateScanLine
			spaceUp 2
.bm101110x
	move.l	2(a6),a4			; yoff										
	move.l	save5,a6
	lea		LINESIZE(a1),a1
	lea		LINESIZE(a6),a6
	jmp		generateScanLine
			spaceUp 2
.bm101111x
	move.l	2(a6),a4			; yoff										
	move.l	save5,a6
	lea		LINESIZE(a0),a0
	lea		LINESIZE(a1),a1
	lea		LINESIZE(a6),a6
	jmp		generateScanLine
			spaceUp 3
.bm110000x
	move.l	2(a6),a4			; yoff										
	move.l	save5,a6
	lea		LINESIZE(a2),a2
	lea		LINESIZE(a3),a3
	lea		LINESIZE(a5),a5
	lea		LINESIZE(a6),a6
	jmp		generateScanLine
			spaceUp 4
.bm110001x
	move.l	2(a6),a4			; yoff										
	move.l	save5,a6
 	lea		LINESIZE(a0),a0
	lea		LINESIZE(a2),a2
	lea		LINESIZE(a3),a3
	lea		LINESIZE(a5),a5
	lea		LINESIZE(a6),a6
	jmp		generateScanLine
			spaceUp 5
.bm110010x
	move.l	2(a6),a4			; yoff										
	move.l	save5,a6
	lea		LINESIZE(a1),a1
	lea		LINESIZE(a2),a2
	lea		LINESIZE(a3),a3
	lea		LINESIZE(a5),a5
	lea		LINESIZE(a6),a6
	jmp		generateScanLine
			spaceUp 5
.bm110011x
	move.l	2(a6),a4			; yoff										
	move.l	save5,a6
	lea		LINESIZE(a0),a0
	lea		LINESIZE(a1),a1
	lea		LINESIZE(a2),a2
	lea		LINESIZE(a3),a3
	lea		LINESIZE(a5),a5
	lea		LINESIZE(a6),a6
	jmp		generateScanLine
			spaceUp 6
.bm110100x
	move.l	2(a6),a4			; yoff										
	move.l	save5,a6
	lea		LINESIZE(a3),a3
	lea		LINESIZE(a5),a5
	lea		LINESIZE(a6),a6
	jmp		generateScanLine
			spaceUp 3
.bm110101x
	move.l	2(a6),a4			; yoff										
	move.l	save5,a6
	lea		LINESIZE(a0),a0
	lea		LINESIZE(a3),a3
	lea		LINESIZE(a5),a5
	lea		LINESIZE(a6),a6
	jmp		generateScanLine
			spaceUp 4
.bm110110x
	move.l	2(a6),a4			; yoff										
	move.l	save5,a6
	lea		LINESIZE(a1),a1
	lea		LINESIZE(a3),a3
	lea		LINESIZE(a5),a5
	lea		LINESIZE(a6),a6
	jmp		generateScanLine
			spaceUp 4
.bm110111x
	move.l	2(a6),a4			; yoff										
	move.l	save5,a6
	lea		LINESIZE(a0),a0
	lea		LINESIZE(a1),a1
	lea		LINESIZE(a3),a3
	lea		LINESIZE(a5),a5
	lea		LINESIZE(a6),a6
	jmp		generateScanLine
			spaceUp 5
.bm111000x
	move.l	2(a6),a4			; yoff										
	move.l	save5,a6
	lea		LINESIZE(a2),a2
	lea		LINESIZE(a5),a5
	lea		LINESIZE(a6),a6
	jmp		generateScanLine
			spaceUp 3
.bm111001x
	move.l	2(a6),a4			; yoff										
	move.l	save5,a6
	lea		LINESIZE(a0),a0
	lea		LINESIZE(a2),a2
	lea		LINESIZE(a5),a5
	lea		LINESIZE(a6),a6
	jmp		generateScanLine
			spaceUp 4
.bm111010x
	move.l	2(a6),a4			; yoff										
	move.l	save5,a6
	lea		LINESIZE(a1),a1
	lea		LINESIZE(a2),a2
	lea		LINESIZE(a5),a5
	lea		LINESIZE(a6),a6
	jmp		generateScanLine
			spaceUp 4
.bm111011x
	move.l	2(a6),a4			; yoff										
	move.l	save5,a6
	lea		LINESIZE(a0),a0
	lea		LINESIZE(a1),a1
	lea		LINESIZE(a2),a2
	lea		LINESIZE(a5),a5
	lea		LINESIZE(a6),a6
	jmp		generateScanLine
			spaceUp 5
.bm111100x
	move.l	2(a6),a4			; yoff										
	move.l	save5,a6
	lea		LINESIZE(a5),a5
	lea		LINESIZE(a6),a6
	jmp		generateScanLine
			spaceUp 2
.bm111101x
	move.l	2(a6),a4			; yoff										
	move.l	save5,a6
	lea		LINESIZE(a0),a0
	lea		LINESIZE(a5),a5
	lea		LINESIZE(a6),a6
	jmp		generateScanLine
			spaceUp 3
.bm111110x
	move.l	2(a6),a4			; yoff										
	move.l	save5,a6
	lea		LINESIZE(a1),a1
	lea		LINESIZE(a5),a5
	lea		LINESIZE(a6),a6
	jmp		generateScanLine
			spaceUp 3
.bm111111x
	move.l	2(a6),a4			; yoff						;2						
	move.l	save5,a6
	lea		LINESIZE(a0),a0									;4
	lea		LINESIZE(a1),a1									;4
	lea		LINESIZE(a5),a5									;4
	lea		LINESIZE(a6),a6									;4
	jmp		generateScanLine							;4	thus: (x+2)*4 where x is number of bit = 1
			spaceUp 4

drawEnd


skipFiller
	IFEQ	GENERATEFONT
		jsr		prepFont
	ENDC
	jsr		generatePaletteColors
;	jsr		precalcFades
	; INIT SETUP CODE ---------------------------------------
	jsr	saveAndKillTimers									; kill timers and save them
	jsr	disableMouse										; turn off mouse
	jsr	backupPalAndScrMemAndResolutionAndSetLowRes			; save screen address and other display properties
	jsr	checkMachineTypeAndSetStuff							; check machine type, disable cache

; incase we want tp preserve lower memory...
;	lea		$2000,a0
;	lea		storedLower,a1
;	move.w	#148-1,d7
;.t
;.x set 0
;	REPT 10
;		movem.l	(a0)+,d0-d6/a2-a6
;		movem.l	d0-d6/a2-a6,.x(a1)
;.x set .x+44
;	ENDR
;	lea		440(a1),a1
;	dbra	d7,.t
;.x set 0
;	REPT 9
;		movem.l	(a0)+,d0-d6/a2-a6
;		movem.l	d0-d6/a2-a6,.x(a1)
;.x set .x+44
;	ENDR
;	movem.l	(a0)+,d0-d4
;	movem.l	d0-d4,.x(a1)

	move.l	#screen1+256,d0
	sub.b	d0,d0
	move.l	d0,screenpointer
	add.l	#276*160+256,d0
;	move.l	#screen2+256,d0
	sub.b	d0,d0
	move.l	d0,screenpointer2

	move.l	screenpointer,d0
	lsr.w	#8,d0
	move.l	d0,$ffff8200

	IFEQ	genlower
	ELSE
	lea		generateScanLine,a6
	sub.l	#drawStart,a6
	move.b	#0,$ffffc123
	lea 	drawEnd,a6
	sub.l	#drawStart,a6
	move.b	#0,$ffffc123

	ENDC

		IFEQ	DEBUG
	jsr		init_checkerBoard
	jsr		fillBuffer
	jsr		fillBuffer
	jsr		fillBuffer
	jsr		fillBuffer
			move.w	#235*8,smchax+2

	jsr		startCheckerBoard
.x
		jsr		fillBuffer
	jmp	.x
	ENDC



	jsr		init_effect

	jsr		init_effect_fade	
	nop
	nop
	nop

	jsr		init_effect2

;	jsr		prepTextShit

	move.l	screenpointer,a0
	move.l	screenpointer2,a1
	add.l	#276*160,a0
	add.l	#276*160,a1
	move.w	#37-1,d7
	moveq	#0,d0					;20*2*20 = 800
	move.l	d0,d1
	move.l	d0,d2
	move.l	d0,d3
	move.l	d0,d4
	move.l	d0,d5
	move.l	d0,d6	;7
	move.l	d0,a2	
	move.l	d0,a3	
	move.l	d0,a4	
	move.l	d0,a5	
	move.l	d0,a6	
.l
		REPT 2
			movem.l	d0-d6/a3-a6,-(a0)
			movem.l	d0-d6/a3-a6,-(a1)
		ENDR
	dbra	d7,.l




	move.w	#0,$466
		jsr		fillBuffer
		jsr		fillBuffer
		jsr		fillBuffer
		jsr		fillBuffer
		move.w	#256*8,smchax+2
.wait
	tst.w	$466
	beq		.wait


	jsr		startCheckerBoard



; d1 is *2
; d0 is *2
; data in a6 is *2
; xoff is *2
; checker_xoff is *1
; checker_yoff is *1


; what this does,
; 	-

increaseAndCheckBoundNormal	macro
	move.w	checker_xoff\1,d0			; current pos
	move.w	checker_size\1,d1			; max pos
	add.w	d2,d0						; increase current pos with step
	blt		.negoff\@
		cmp.w	d0,d1
		bgt		.end\@
			sub.w	d1,d0
			IF \1==0
				eor.w	#%000001*STRUCTSIZE,d7
			ENDC
			IF \1==1
				eor.w	#%000010*STRUCTSIZE,d7
			ENDC
			IF \1==2
				eor.w	#%000100*STRUCTSIZE,d7
			ENDC
			IF \1==3
				eor.w	#%001000*STRUCTSIZE,d7
			ENDC
			IF \1==4
				eor.w	#%010000*STRUCTSIZE,d7
			ENDC
			IF \1==5
				eor.w	#%100000*STRUCTSIZE,d7
			ENDC
			jmp		.end\@
.negoff\@
		add.w	d1,d0
		IF \1==0
			eor.w	#%000001*STRUCTSIZE,d7
		ENDC
		IF \1==1
			eor.w	#%000010*STRUCTSIZE,d7
		ENDC
		IF \1==2
			eor.w	#%000100*STRUCTSIZE,d7
		ENDC
		IF \1==3
			eor.w	#%001000*STRUCTSIZE,d7
		ENDC
		IF \1==4
			eor.w	#%010000*STRUCTSIZE,d7
		ENDC
		IF \1==5
			eor.w	#%100000*STRUCTSIZE,d7
		ENDC	
.end\@
	move.w	d0,checker_xoff\1
	endm


increaseAndCheckBound macro
	move.w	xoff\1,d0									; current position
	move.w	(a6,d0.w),d2								; delta, change
											
	add.w	d1,d0										; increase position
	cmp.w	d6,d0										; check bounds of position for array
	blt		.noreset\@
		sub.w	d6,d0
.noreset\@
	move.w	d0,xoff\1						

	move.w	checker_xoff\1,d0				
	add.w	d2,d0
	blt		.negoff\@
	move.w	checker_size\1,d2
	cmp.w	d0,d2
	bgt		.ok\@
		sub.w	d2,d0
		IF \1==0
			eor.w	#%000001*STRUCTSIZE,d7
		ENDC
		IF \1==1
			eor.w	#%000010*STRUCTSIZE,d7
		ENDC
		IF \1==2
			eor.w	#%000100*STRUCTSIZE,d7
		ENDC
		IF \1==3
			eor.w	#%001000*STRUCTSIZE,d7
		ENDC
		IF \1==4
			eor.w	#%010000*STRUCTSIZE,d7
		ENDC
		IF \1==5
			eor.w	#%100000*STRUCTSIZE,d7
		ENDC
.ok\@
	jmp		.end\@

.negoff\@
	add.w	checker_size\1,d0
		IF \1==0
			eor.w	#%000001*STRUCTSIZE,d7
		ENDC
		IF \1==1
			eor.w	#%000010*STRUCTSIZE,d7
		ENDC
		IF \1==2
			eor.w	#%000100*STRUCTSIZE,d7
		ENDC
		IF \1==3
			eor.w	#%001000*STRUCTSIZE,d7
		ENDC
		IF \1==4
			eor.w	#%010000*STRUCTSIZE,d7
		ENDC
		IF \1==5
			eor.w	#%100000*STRUCTSIZE,d7
		ENDC
.ok2\@	
.end\@
	move.w	d0,checker_xoff\1
	endm

increase_YOff_and_CheckBound_Offset	macro
	add.w	checker_ymovement\1,d1
	cmp.w	d1,d6
	bgt		.ok3\@
		sub.w	d6,d1
.ok3\@
	move.w	d1,checker_ymovement\1
	move.w	checker_yoff\1,d0
	add.w	(a6,d1.w),d0
	ble		.negativeyoff\@
	cmp.w	checker_size\1,d0
	ble		.oksize\@
		sub.w	checker_size\1,d0
		IF \1==0
			eor.w	#%000001*STRUCTSIZE,d7
		ENDC
		IF \1==1
			eor.w	#%000010*STRUCTSIZE,d7
		ENDC
		IF \1==2
			eor.w	#%000100*STRUCTSIZE,d7
		ENDC
		IF \1==3
			eor.w	#%001000*STRUCTSIZE,d7
		ENDC
		IF \1==4
			eor.w	#%010000*STRUCTSIZE,d7
		ENDC
		IF \1==5
			eor.w	#%100000*STRUCTSIZE,d7
		ENDC
		jmp		.oksize\@
.negativeyoff\@
	add.w	checker_size\1,d0
	IF \1==0
		eor.w	#%000001*STRUCTSIZE,d7
	ENDC
	IF \1==1
		eor.w	#%000010*STRUCTSIZE,d7
	ENDC
	IF \1==2
		eor.w	#%000100*STRUCTSIZE,d7
	ENDC
	IF \1==3
		eor.w	#%001000*STRUCTSIZE,d7
	ENDC
	IF \1==4
		eor.w	#%010000*STRUCTSIZE,d7
	ENDC
	IF \1==5
		eor.w	#%100000*STRUCTSIZE,d7
	ENDC
.oksize\@
	move.w	d0,checker_yoff\1
	endm


; argument: layer
;	and having the 
apply_XOff_to_ScanlineSource	macro
	move.w	checker_size\1,d\1
	neg.w	d\1						
	add.l	(a6,d\1.w),a\1
	move.w	checker_xoff\1,d\1
	add.l	(a6,d\1.w),a\1
	;y off stuff

	endm

increase_YOff_and_CheckBound	macro
	move.w	checker_yoff\1,d0
	add.w	d1,d0
	ble		.negativeyoff\@
	cmp.w	checker_size\1,d0
	ble		.oksize\@
		sub.w	checker_size\1,d0
		IF \1==0
			eor.w	#%000001*STRUCTSIZE,d7
		ENDC
		IF \1==1
			eor.w	#%000010*STRUCTSIZE,d7
		ENDC
		IF \1==2
			eor.w	#%000100*STRUCTSIZE,d7
		ENDC
		IF \1==3
			eor.w	#%001000*STRUCTSIZE,d7
		ENDC
		IF \1==4
			eor.w	#%010000*STRUCTSIZE,d7
		ENDC
		IF \1==5
			eor.w	#%100000*STRUCTSIZE,d7
		ENDC
		jmp		.oksize\@
.negativeyoff\@
	add.w	checker_size\1,d0
	IF \1==0
		eor.w	#%000001*STRUCTSIZE,d7
	ENDC
	IF \1==1
		eor.w	#%000010*STRUCTSIZE,d7
	ENDC
	IF \1==2
		eor.w	#%000100*STRUCTSIZE,d7
	ENDC
	IF \1==3
		eor.w	#%001000*STRUCTSIZE,d7
	ENDC
	IF \1==4
		eor.w	#%010000*STRUCTSIZE,d7
	ENDC
	IF \1==5
		eor.w	#%100000*STRUCTSIZE,d7
	ENDC
.oksize\@
	move.w	d0,checker_yoff\1
	endm

cycleBuffersProducer	macro

	lea		currentDrawListPointer_producer,a0		;12
	move.l	a0,a1									;4
	move.l	(a0)+,d0			;d0					;12
	move.l	(a0)+,(a1)+	;d1							;20
	move.l	(a0)+,(a1)+	;d2							;20
	move.l	(a0)+,(a1)+	;d3							;20	
	move.l	d0,(a1)+	;d0							;12
	move.l	(a0)+,d4								;12
	move.l	(a0)+,(a1)+								;12
	move.l	d4,(a1)+								;12
	
;	movem.l	currentDrawListPointer_producer,d0-d5									;68		, desired order: d1,d2,d3,d0,d5,d4
;	move.l	d4,d6																	;4
;	move.l	d0,d4																	;4
;	movem.l	d1-d6,currentDrawListPointer_producer									;64	 --> 140



	lea		maskList,a0
	add.w	maskListOff,a0
	move.w	(a0),currentMaskAddresValue
	add.w	#2,maskListOff
	cmp.w	#8,maskListOff
	bne		.ok
		move.w	#0,maskListOff
.ok	
	endm

.mainloop

	IFEQ	USEBUFFERS
		jsr		fillBuffer


;	code to check for writing into valuable data; because wietze is dirty smc boy
;	move.w	#$4e75,d0
;	cmp.w	GENERATE_SCANLINE_OFFSET,d0
;	beq		.ok
;		move.b	#0,$ffffc123
;.ok
;	cmp.w	GENERATE_SCANLINE_OFFSET-$1000,d0
;	beq		.ok2
;		move.b	#0,$ffffc123
;.ok2
;	cmp.w	GENERATE_SCANLINE_OFFSET-$2000,d0
;	beq		.ok3
;		move.b	#0,$ffffc123
;.ok3
;	cmp.w	GENERATE_SCANLINE_OFFSET-$3000,d0
;	beq		.ok4
;		move.b	#0,$ffffc123
;.ok4		
	ENDC

	cmp.b 	#$39,$fffffc02.w								; spacebar to exit
	bne		.mainloop										;

	
.exit
			move.w	#$2700,sr
			move.l	$4,a0			
			jmp		(a0)

; oh yeah, no time for a nice exit...
;	move.w	#$2700,sr
;	move.l	#dummyvbl,$70.w				;Install our own VBL
;	move.l	#dummy,$68.w				;Install our own HBL (dummy)
;	move.l	#dummy,$134.w				;Install our own Timer A (dummy)
;	move.l	#dummy,$120.w				;Install our own Timer B
;	move.l	#dummy,$114.w				;Install our own Timer C (dummy)
;	move.l	#dummy,$110.w				;Install our own Timer D (dummy)
;	move.l	#dummy,$118.w				;Install our own ACIA (dummy)
;	clr.b	$fffffa07.w					;Interrupt enable A (Timer-A & B)
;	clr.b	$fffffa13.w					;Interrupt mask A (Timer-A & B)
;	clr.b	$fffffa09.w					;Interrupt enable B (Timer-C & D)
;	clr.b	$fffffa15.w					;Interrupt mask B (Timer-C & D)
;	move.w	#$2300,sr
;
;	lea		storedLower,a0
;	lea		$2000,a1
;;	d0-d6 	; 6 *4 = 24
;;	a2-a6	; 5 *4 = 20 => 44			1489 times 44+ 20 bytes
;	move.w	#148-1,d7
;.ttt
;.x set 0
;	REPT 10
;		movem.l	(a0)+,d0-d6/a2-a6
;		movem.l	d0-d6/a2-a6,.x(a1)
;.x set .x+44
;	ENDR
;	lea		440(a1),a1
;	dbra	d7,.ttt
;.x set 0
;	REPT 9
;		movem.l	(a0)+,d0-d6/a2-a6
;		movem.l	d0-d6/a2-a6,.x(a1)
;.x set .x+44
;	ENDR
;	movem.l	(a0)+,d0-d4
;	movem.l	d0-d4,.x(a1)
;
;	move.b	#0,$ffffc123
;
;	jsr restoresForMachineTypes
;	move.b	#0,$ffffc123
;	jsr	restorePalAndScreenMemAndResolution
;	move.b	#0,$ffffc123
;	jsr	restoreTimers
;	move.b	#0,$ffffc123
;	IFEQ	PLAYMUSIC
;;		jsr		music+4
;	ENDC
;	move.b	#0,$ffffc123
;	jsr	enableMouse
;	move.b	#0,$ffffc123
;	rts



init_effect
	jsr		music
;	jsr		prepSmfx
	rts



fillBuffer
	tst.w	bufferLeft
	beq		.end
		subq.w	#1,bufferLeft
		raster $070
		jsr		resetDrawListStructNew
		jsr		populateDrawListStruct
		move.w	#0,(a6)+
		jsr		doMovement
			 	cycleBuffersProducer
		raster $700
.end
	rts





init_checkerBoard	
	; set up pointers for both producers and consumer, so they can be detached
	move.l	screenpointer2,currentScreenPointer_producer
	move.l	screenpointer,backupsScreenPointer_producer

	move.l	#drawListPointers,currentDrawListPointer_producer
	move.l	#drawListPointers,currentDrawListPointer_consumer

	move.l	#drawListPointers1,backupDrawListPointer1_producer
	move.l	#drawListPointers1,backupDrawListPointer1_consumer

	move.l	#drawListPointers2,backupDrawListPointer2_producer
	move.l	#drawListPointers2,backupDrawListPointer2_consumer

	move.l	#drawListPointers3,backupDrawListPointer3_producer
	move.l	#drawListPointers3,backupDrawListPointer3_consumer


	jsr		copySmallestNumber
	jsr		copyDrawCode
	jsr		copyXoffAndXPosList


	move.l	#$10000,myHaxListPointer
	lea		myHaxList,a0
	move.l	myHaxListPointer,a1
	REPT	8*256/4
		move.l	(a0)+,(a1)+
	ENDR

	move.w	#checker_size0_start,checker_size0		
	move.w	#checker_size1_start,checker_size1
	move.w	#checker_size2_start,checker_size2
	move.w	#checker_size5_start,checker_size5
	move.w	#checker_size3_start,checker_size3
	move.w	#checker_size4_start,checker_size4

	move.w	#$4e75,GENERATE_SCANLINE_OFFSET				; hax
	move.w	#$4e75,GENERATE_SCANLINE_OFFSET-$1000				; hax
	move.w	#$4e75,GENERATE_SCANLINE_OFFSET-$2000				; hax
	move.w	#$4e75,GENERATE_SCANLINE_OFFSET-$3000				; hax


	jsr		initDrawListStruct
	jsr		shiftChecker16Places
	move.w	#$4e75,init_checkerBoard
	rts


startCheckerBoard
	move.w	#$2700,sr
	move.l	#timer_a_opentop_checker,$134.w			;Install our own Timer A
	move.l	#effect_vbl_checker,$70
	move.w	#$2300,sr
	
	rts


timer_a_opentop_checker
	move.w	#$2100,sr			;Enable HBL
	stop	#$2100				;Wait for HBL
	move.w	#$2700,sr			;Stop all interrupts
	clr.b	$fffffa19.w			;Stop Timer Affff

    clr.b   $fffffa1b.w         													;6
    bset    #0,$fffffa07.w          												;7
    bset    #0,$fffffa13.w          												;7
	move.l	#timer_b_curtain_checker,$120													;6
	move.b	#29,$fffffa21.w															;5
	bclr	#3,$fffffa17.w															;7
    move.b  #8,$fffffa1b.w          												;5		---> 43

	REPT 84-43
		nop
	ENDR

	clr.b	$ffff820a.w				;60 Hz
	REPT 9
		nop
	ENDR
	move.b	#2,$ffff820a.w			;50 Hz	
	rte

timer_b_curtain_checker
	movem.l	d0-d7,-(sp)
    clr.b   $fffffa1b.w         ;Timer B control (stop)
    move.l	#timer_b_openbottom_checker,$120
    move.b  #198,$fffffa21.w        ;Timer B data (number of scanlines to next interrupt)
	bclr	#3,$fffffa17.w			;Automatic end of interrupt
    move.b  #8,$fffffa1b.w          ;Timer B control (event mode (HBL))
    movem.l	currentPalette,d0-d7
    REPT 52/2
    	or.l	d7,d7
    ENDR
    movem.l	d0-d7,$ffff8240
    movem.l	(sp)+,d0-d7
    rte


timer_b_openbottom
	move.w	#$2100,sr
	stop	#$2100
	rept 96/2
		or.l	d7,d7
	endr
	clr.b	$ffff820a.w			;60 Hz
	dcb.w	5,$4e71				;
	move.b	#2,$ffff820a.w			;50 Hz	
	rte


timer_b_openbottom_checker
	move.w	#$2100,sr
	stop	#$2100
	movem.l	d0-d7/a0,-(sp)			;76 => 19
	movem.l	blackPal,d0-d7			;80 => 20
	lea		$ffff8240,a0			;8	=> 2
	dcb.w	96-19-20-2-18,$4e71
	movem.l	d1-d7,$ffff8244			;72 => 18
	clr.b	$ffff820a.w			;60 Hz
	dcb.w	5-3,$4e71				;
	move.l	d0,(a0)
	move.b	#2,$ffff820a.w			;50 Hz	
	IFEQ USEA7
	move.w	#0,a7free
	ENDC
	movem.l	(sp)+,d0-d7/a0
	rte

a7free	dc.w	0


cycleBuffersConsumer	macro
	lea		maskList,a0
	add.w	maskListOffConsumer,a0
	move.w	(a0),d0
	add.w	#2,maskListOffConsumer
	cmp.w	#8,maskListOffConsumer
	bne		.ok
		move.w	#0,maskListOffConsumer
.ok
	move.w	#GENERATE_SCANLINE_OFFSET,d1
	sub.w	#$2000,d0
	sub.w	d0,d1
	move.l	#getNextScanLine1,d2
	sub.l	#drawStart,d2
	move.l	#scanLineCode,a0
	add.w	d2,a0
	move.w	d1,8(a0)

	lea		currentDrawListPointer_consumer,a0			;12
	move.l	a0,a1										;4
	move.l	(a0)+,d0									;12
	move.l	(a0)+,(a1)+									;20
	move.l	(a0)+,(a1)+									;20
	move.l	(a0)+,(a1)+									;20
	move.l	d0,(a1)+									;12

	endm
;	move.l	currentDrawListPointer_consumer,d0
;	move.l	backupDrawListPointer1_consumer,currentDrawListPointer_consumer
;	move.l	backupDrawListPointer2_consumer,backupDrawListPointer1_consumer
;	move.l	backupDrawListPointer3_consumer,backupDrawListPointer2_consumer
;	move.l	d0,backupDrawListPointer3_consumer
;	rts


effect_vbl_checker
	pushall
			schedule_timerA_topBorder	; schedule open top border with timer a
	jsr		doPalette
	subq.w	#1,borderWaits
	bge		.kkk
		move.w	#3,borderWaits
		move.l	#currentPalette,fadeTarget
		subq.w	#1,borderSteps
		lea		blackPal,a0
		jsr		calcFades
.kkk
	movem.l	blackPal,d0-d7
	movem.l	d0-d7,$ffff8240

	IFEQ	USEA7
	move.w	#-1,a7free
	ELSE
	ENDC

	IFEQ	USEBUFFERS
	ELSE
		jsr		resetDrawListStructNew		; reset the structure
		jsr		populateDrawListStruct		; populate the struct with current frame
		move.w	#0,(a6)+

	ENDC

	IFEQ	STATISTICS
		jsr		doStatistics
	ENDC

	lea		currentMyBufferPointers_consumer,a0
	move.l	a0,a1
	move.l	(a0)+,a6
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	a6,(a1)+
;	movem.l	currentMyBufferPointers_consumer,d0-d3
;	move.l	d0,a6
;	movem.l	d1-d3/a6,currentMyBufferPointers_consumer
	movem.l	(a6)+,a0
	movem.l	(a6)+,a1
	movem.l	(a6)+,a2
	movem.l	(a6)+,a3
	movem.l	(a6)+,a4
	movem.l	(a6)+,a5


	IFEQ	genlower
		jsr		scanLineCode			; generate the scanlines
	ELSE
		move.b	#0,$ffffc123
		jsr		drawUniqueLinesNew		
	ENDC


	; consumer.display
			raster	$770
	jsr		copyUniqueLinesNew2			; copy the generated scanlines
	jsr		music+8
			raster	$444
	IFEQ USEBUFFERS
			 	cycleBuffersConsumer
		addq.w	#1,bufferLeft
	ENDC

	nop
	nop
	jsr		testTextShit

	move.l 	screenpointer2,d0
	lsr.w	#8,d0
	move.l	d0,$ff8200							; put new screenpointer in effect
			screenswap										; swap screenpointers		


	tst.w	borderSteps
	bge		.noEnd
		add.w	#7*4*6,textShitOffset
		move.w	#$2700,sr
		move.l	#effect_vbl_end_checker,$70
		move.l	#timer_a_opentop,$134.w			;Install our own Timer A
		move.w	#$2300,sr
.noEnd

	popall
.end
;	move.w	#$777,$ffff8240
	rte

textShitOffset	dc.w	0


testTextShit
	move.l	screenpointer2,a0
	lea		textShitBuffer,a1
	add.w	textShitOffset,a1
	add.l	#222*160+160-56,a0
y set 0
	REPT 6
x set y
		movem.l	(a1)+,d0-d6
		and.l	d0,(a0)+
		and.l	d0,(a0)+
		and.l	d1,(a0)+
		and.l	d1,(a0)+
		and.l	d2,(a0)+
		and.l	d2,(a0)+
		and.l	d3,(a0)+
		and.l	d3,(a0)+
		and.l	d4,(a0)+
		and.l	d4,(a0)+
		and.l	d5,(a0)+
		and.l	d5,(a0)+
		and.l	d6,(a0)+
		and.l	d6,(a0)+
		lea		160-56(a0),a0			;
y set y+160
	ENDR
	rts

testTextShit2
	move.l	screenpointer2,a0
	lea		textShitBuffer+3*7*4*6,a1
	add.l	#222*160+160-48,a0
y set 0
	REPT 6
x set y
		movem.l	(a1)+,d0-d5
		and.l	d0,(a0)+
		and.l	d0,(a0)+
		and.l	d1,(a0)+
		and.l	d1,(a0)+
		and.l	d2,(a0)+
		and.l	d2,(a0)+
		and.l	d3,(a0)+
		and.l	d3,(a0)+
		and.l	d4,(a0)+
		and.l	d4,(a0)+
		and.l	d5,(a0)+
		and.l	d5,(a0)+
		lea		160-48(a0),a0			;
y set y+160
	ENDR
	rts

;textShitBuffer	ds.b	7*4*6*4		;672			168*3 + 144
; 6*3*7*4 + 6*6*4		;504 + 144 = 648

;prepTextShit
;	lea		textShit+128,a0
;	lea		textShitBuffer,a1
;.y set 0	
;	REPT 6*3
;.x set .y
;		REPT 7
;			move.l	.x(a0),(a1)+
;.x set .x+8
;		ENDR
;.y set .y+160
;	ENDR
;
;	REPT 6
;.x set .y
;		REPT 6
;			move.l	.x(a0),(a1)+
;.x set .x+8
;		ENDR
;.y set .y+160
;	ENDR
;
;	lea		textShitBuffer,a0		;648
;	move.b	#0,$ffffc123
;	rts


borderWaits	dc.w	3250-250
borderSteps	dc.w	8


effect_vbl_end_checker
	pushall
			schedule_timerA_topBorder	; schedule open top border with timer a
	jsr		sixPlanesPalette
;	move.w	#0,$ffff8240
	lea		currentMyBufferPointers_consumer,a0
	move.l	a0,a1

	move.l	(a0)+,a6				;12
	move.l	(a0)+,(a1)+				;20
	move.l	(a0)+,(a1)+				;20
	move.l	(a0)+,(a1)+				;20
	move.l	a6,(a1)+				;12

	move.l	(a6)+,a0
	move.l	(a6)+,a1
	move.l	(a6)+,a2
	move.l	(a6)+,a3
	move.l	(a6)+,a4
	move.l	(a6)+,a5

	jsr		scanLineCode				; generate the scanlines
	jsr		music+8
	jsr		copyUniqueLinesNew2			; copy the generated scanlines
		 	cycleBuffersConsumer
	addq.w	#1,bufferLeft

	jsr		testTextShit2
	move.l 	screenpointer2,d0
	lsr.w	#8,d0
	move.l	d0,$ff8200							; put new screenpointer in effect
			screenswap										; swap screenpointers

	popall
.end
;	move.w	#$777,$ffff8240		
	rte





bufferLeft	dc.w	4



doStatistics
		move.w	nr_of_unique,d0
		move.w	nr_of_switches,d1
		move.w	top_unique,d2
		move.w	top_switches,d3
		cmp.w	d2,d0
		ble		.ok1
			move.w	d0,top_unique
.ok1
		cmp.w	d3,d1
		ble		.ok2
			move.w	d1,top_switches
.ok2
		subq.w	#1,times
		bgt		.ok3
			moveq	#0,d0
			moveq	#0,d1			
			move.w	top_unique,d0
			move.w	top_switches,d1
.ok3
	rts


;4,3,5,2,1,0


checker_xoff4	dc.w	0
checker_xoff3	dc.w	0
checker_xoff5	dc.w	0
checker_xoff2	dc.w	0
checker_xoff1	dc.w	0
checker_xoff0	dc.w	0


checker_yoff4	dc.w	checker_yoff4_start
checker_yoff3	dc.w	checker_yoff3_start
checker_yoff5	dc.w	checker_yoff5_start
checker_yoff2	dc.w	checker_yoff2_start
checker_yoff1	dc.w	320*8
checker_yoff0	dc.w	320*8


xoff4	dc.w	10
xoff3	dc.w	8
xoff5	dc.w	6
xoff2	dc.w	4
xoff1	dc.w	2
xoff0	dc.w	0

	include zoom3b.s

checkerSizeOff	dc.w	34

myXposList2	equ $a000+2720

fivePlanesPaletteColors	
	dc.w	$700
	dc.w	$121
	dc.w	$441
	dc.w	$651
	dc.w	$762
	dc.w	$764
	dc.w	$000

	dc.w	$112
	dc.w	$121
	dc.w	$441
	dc.w	$651
	dc.w	$662
	dc.w	$664
	dc.w	$000

	dc.w	$112
	dc.w	$121
	dc.w	$441
	dc.w	$551
	dc.w	$662
	dc.w	$664
	dc.w	$001

	dc.w	$112
	dc.w	$121
	dc.w	$441
	dc.w	$441
	dc.w	$552
	dc.w	$553
	dc.w	$001

	dc.w	$112
	dc.w	$121
	dc.w	$331
	dc.w	$331
	dc.w	$442
	dc.w	$442
	dc.w	$112

	dc.w	$112
	dc.w	$111
	dc.w	$221
	dc.w	$221
	dc.w	$332
	dc.w	$332
	dc.w	$112

	dc.w	$112
	dc.w	$112
	dc.w	$112
	dc.w	$112
	dc.w	$222
	dc.w	$222
	dc.w	$112

	dc.w	$112
	dc.w	$112
	dc.w	$112
	dc.w	$112
	dc.w	$112
	dc.w	$112
	dc.w	$112





;---
;	dc.w	$700
;	dc.w	$121
;	dc.w	$441
;	dc.w	$651
;	dc.w	$762
;	dc.w	$764
;	dc.w	$000
;
;	dc.w	$711
;	dc.w	$222
;	dc.w	$442 ;
;	dc.w	$651 ;
;	dc.w	$763 ;
;	dc.w	$765
;	dc.w	$111
;
;	dc.w	$722
;	dc.w	$232
;	dc.w	$443 ; 
;	dc.w	$652 ;
;	dc.w	$763 ;
;	dc.w	$765
;	dc.w	$222
;
;	dc.w	$733
;	dc.w	$333
;	dc.w	$553 ; 
;	dc.w	$653 ;
;	dc.w	$764 ;
;	dc.w	$666
;	dc.w	$333
;
;	dc.w	$744
;	dc.w	$343
;	dc.w	$554 ;
;	dc.w	$654 ;
;	dc.w	$665 ;
;	dc.w	$666
;	dc.w	$444
;
;	dc.w	$755
;	dc.w	$455
;	dc.w	$555 ;
;	dc.w	$655 ;
;	dc.w	$665 ;
;	dc.w	$666
;	dc.w	$555
;
;	dc.w	$766
;	dc.w	$666
;	dc.w	$666 ;
;	dc.w	$666 ;
;	dc.w	$666 ;
;	dc.w	$667  
;	dc.w	$666
;
;	dc.w	$667
;	dc.w	$667
;	dc.w	$667
;	dc.w	$667
;	dc.w	$667
;	dc.w	$667
;	dc.w	$667

checkerSizeListPointer	dc.l	checkerSizesList0

checkerSizeListList	
	dc.l	checkerSizesList1
	dc.l	checkerSizesList2
	dc.l	checkerSizesList5
	dc.l	checkerSizesList3
	dc.l	checkerSizesList4
;	dc.l	checkerSizesList0

checkerSizeListOff	dc.w	0


checkerSizePointer			dc.l	checker_size1
checkerYOffsetPointer		dc.l	checker_yoff1

checkerYOffsetList
	dc.l	checker_yoff1
	dc.l	checker_yoff2
	dc.l	checker_yoff5
	dc.l	checker_yoff3
	dc.l	checker_yoff4


sizeWaiter	dc.w	360+40
c2Done	dc.w	-1
c5Done	dc.w	-1
c3Done	dc.w	-1
c4Done	dc.w	-1


prevSize	dc.w	0
sizeDelta	dc.w	0


delta0
delta8
	move.l	checkerYOffsetPointer,a0
	add.w	#-1*8,(a0)
	rts
delta16
delta24
	sub.w	#16,sizeDelta
	move.l	checkerYOffsetPointer,a0
	add.w	#-2*8,(a0)
	rts
delta32
delta40
	sub.w	#32,sizeDelta
	move.l	checkerYOffsetPointer,a0
	add.w	#-4*8,(a0)
	rts

delta48
delta56
	sub.w	#48,sizeDelta
	move.l	checkerYOffsetPointer,a0
	add.w	#-6*8,(a0)
	rts

deltaCode
	dc.l	delta0
	dc.l	delta0
	dc.l	delta8
	dc.l	delta8
	dc.l	delta16
	dc.l	delta16
	dc.l	delta24
	dc.l	delta24
	dc.l	delta32
	dc.l	delta32
	dc.l	delta40
	dc.l	delta40
	dc.l	delta48
	dc.l	delta48
	dc.l	delta56
	dc.l	delta56
nextOff	dc.w	0

spare	dc.w	0

myEorList	
	dc.w	%000100*STRUCTSIZE
	dc.w	0
	dc.w	0

_debug	dc.w	0

fivePlanesMovement
	; first zoom back layer, layer 0 is invisible

	subq.w	#1,sizeWaiter
	bge		.skip1


	; move.l	currentResizeRout,a0
	; jsr		(a0)						; checker1rout... etc


	; idea would be to calculate the distance since previous, and adjust the y_offset accordingly
	; so we have 
	;	oldSize
	;	currentSize
	;		sub.w	oldSize,currentSize
	;		if diff > 0
	;			add diff to totaldiff
	;			if totaldiff = 0; nothing
	;			if totaldiff = 8; nothing
	;			if totaldiff = 16; yoff -8 + totaldif = 0;
	;			etc
	move.l	checkerSizeListPointer,a6				; get current size list for zooming
	move.w	checkerSizeOff,d6						; get current offset
	move.w	(a6,d6.w),d6							; zooming table + offset = size
	move.l	checkerSizePointer,a6					; get the current checker_size pointer
	move.w	d6,(a6)									; set the current checker_size to the designated address
	move.w	d6,d1									; save checker_size
	move.l	checkerYOffsetPointer,a1
	move.w	(a1),d2
	move.w	prevSize,d0								; get the checkersize of the previous frame
	move.w	d6,prevSize								; set the new checkersize value for the next frame
	sub.w	d0,d1									; determine the size increase, delta = new - old
	beq		.no
;		move.b	#0,$ffffc123
		move.l	#128*8,d5			;128
		lsr.w	#1,d1				;size/2
		sub.w	d1,d5				;128-size/2
		sub.w	d2,d5
		divs	d6,d5
		add.w	d5,d5
		add.w	d5,d5
		add.w	d5,d5

		tst.w	spare
		bne		.rs
			move.w	#1,spare	
			jmp		.rs2
.rs
			move.w	#0,spare
			addq.w	#8,d5
.rs2
		sub.w	d5,(a1)

		bge		.no
			add.w	d6,(a1)
			tst.w	nextOff
			bne		.no2
			eor.w	#%000100*STRUCTSIZE,checkerMask
			jmp		.no
.no2			
			cmp.w	#4,nextOff
			bne		.no3
				nop
				jmp		.no
.no3
			eor.w	#%000010*STRUCTSIZE,checkerMask
.no
	add.w	#2,checkerSizeOff
	cmp.w	#STEPS*2,checkerSizeOff
	blt		.skip2
		move.w	#0,checkerSizeOff
		lea		checkerSizeListList,a0
		add.w	checkerSizeListOff,a0
		move.l	(a0),checkerSizeListPointer
		add.w	#4,checkerSizeListOff
		cmp.w	#24,checkerSizeListOff
		bne		.skip2

			lea		checkerYOffsetList,a0
			move.l	(a0),checkerYOffsetPointer
			tst.w	nextOff
			bne		.noNextOff
;				move.b	#0,$ffffc123
				move.w	#0,spare
				move.w	#26,checkerSizeOff
				move.w	#0,checkerSizeListOff
				move.w	#1,c2Done
				move.w	#1,c5Done
				move.w	#1,c3Done
				lea		checkerSizeListList,a0			; reset stuff
				add.w	checkerSizeListOff,a0
				move.l	(a0),checkerSizeListPointer
				jmp		.next
.noNextOff	
			cmp.w	#4,nextOff
			bne		.nextOff3
				move.w	#0,spare
				move.w	#6,checkerSizeOff
				move.w	#4,checkerSizeListOff
				move.l	checkerYOffsetPointer,a0
				move.w	(a0),d0
				move.w	d0,prevSize
				lea		checkerSizeListList,a0			; reset stuff
				add.w	checkerSizeListOff,a0
				move.l	(a0),checkerSizeListPointer
				move.l	checkerSizeListPointer,a0
				move.w	(a0),d1
				move.w	#1,c2Done
				move.w	#1,c5Done
				jmp		.next
.nextOff3
				move.w	#0,checkerSizeOff
				move.w	#8,checkerSizeListOff
				move.l	checkerYOffsetPointer,a0
				move.w	(a0),d0
				move.w	d0,prevSize
				lea		checkerSizeListList,a0			; reset stuff
				add.w	checkerSizeListOff,a0
				move.l	(a0),checkerSizeListPointer
				move.l	checkerSizeListPointer,a0
				move.w	(a0),d1
				move.w	#1,c2Done
.next
			add.w	#4,nextOff						; init +4

			move.l	#checker_size1,checkerSizePointer

			add.w	#4,checkerSizeListOff

	move.w	checkerMask,d7				; mask

	lea		my16versions,a0
	lea		myXposList2,a6
	move.l	a0,a1
	move.l	a0,a2
	move.l	a0,a3
	move.l	a0,a4
	move.l	a0,a5
	moveq	#0,d0



	; OFFSETS INTO SOURCE
	apply_XOff_to_ScanlineSource 0		; invisible 325
	apply_XOff_to_ScanlineSource 1
	apply_XOff_to_ScanlineSource 2
	apply_XOff_to_ScanlineSource 5
	apply_XOff_to_ScanlineSource 3
	apply_XOff_to_ScanlineSource 4

			jmp		.x
;			move.w	#40,sizeWaiter
;			jmp		.skip2
.skip1
	move.w	checker_size1,prevSize

.skip2


	tst.w	c2Done
	beq		.ok2
	cmp.w	checker_size2,d6
	ble		.ok2
		subq.w	#1,_moarhax
		lea		checker_size2,a0
		move.l	a0,checkerSizePointer
		lea		checker_yoff2,a1
		move.l	a1,checkerYOffsetPointer
		move.w	checker_yoff2,d0
		move.w	checker_yoff1,checker_yoff2
		move.w	d0,checker_yoff1
		move.w	#0,c2Done
.ok2	
	
	tst.w	c5Done
	beq		.ok5
	cmp.w	checker_size5,d6
	ble		.ok5
		lea		checker_size5,a0
		move.l	a0,checkerSizePointer
		lea		checker_yoff5,a1
		move.l	a1,checkerYOffsetPointer
		move.w	checker_yoff5,d0
		move.w	checker_yoff2,checker_yoff5
		move.w	d0,checker_yoff2
		move.w	#0,c5Done
.ok5


	tst.w	c3Done
	beq		.ok3
	cmp.w	checker_size3,d6
	ble		.ok3
		lea		checker_size3,a0
		move.l	a0,checkerSizePointer
		lea		checker_yoff3,a1
		move.l	a1,checkerYOffsetPointer
		move.w	checker_yoff3,d0
		move.w	checker_yoff5,checker_yoff3
		move.w	d0,checker_yoff5
		move.w	#0,c3Done
.ok3

	tst.w	c4Done
	beq		.ok4
	cmp.w	checker_size4,d6
	ble		.ok4
		lea		checker_size4,a0
		move.l	a0,checkerSizePointer
		lea		checker_yoff4,a1
		move.l	a1,checkerYOffsetPointer
		move.w	checker_yoff4,d0
		move.w	checker_yoff3,checker_yoff4
		move.w	d0,checker_yoff3
		move.w	#0,c4Done
.ok4






	lea		my16versions,a0
	lea		myXposList2,a6
	move.l	a0,a1
	move.l	a0,a2
	move.l	a0,a3
	move.l	a0,a4
	move.l	a0,a5
	moveq	#0,d0



	; OFFSETS INTO SOURCE
	apply_XOff_to_ScanlineSource 0		; invisible 325
	apply_XOff_to_ScanlineSource 1
	apply_XOff_to_ScanlineSource 2
	apply_XOff_to_ScanlineSource 5
	apply_XOff_to_ScanlineSource 3
	apply_XOff_to_ScanlineSource 4
	; a0,a1,a2,a3,a4,a5 done now

;	move.w	#30,checkerSizeOff

	; X MOVEMENT
	move.w	checkerMask,d7				; mask
	; check boundaries	
	moveq	#0,d2
;	increaseAndCheckBoundNormal 0
	moveq	#0,d2
;	increaseAndCheckBoundNormal 1
	moveq	#0,d2
;	increaseAndCheckBoundNormal 2
	moveq	#0,d2
;	increaseAndCheckBoundNormal 5
	moveq	#0,d2
;	increaseAndCheckBoundNormal 3
	moveq	#0,d2
;	increaseAndCheckBoundNormal 4	

;	move.w	checker_ymovement0,d1
;	increase_YOff_and_CheckBound 0
;	move.w	checker_size1,d5
;	move.w	checker_yoff1,d6
	move.w	#0,d1
	increase_YOff_and_CheckBound 1
	move.w	checker_ymovement2,d1
	increase_YOff_and_CheckBound 2
	move.w	checker_ymovement3,d1
	increase_YOff_and_CheckBound 5
	move.w	checker_ymovement4,d1
	increase_YOff_and_CheckBound 3
	move.w	checker_ymovement5,d1
	increase_YOff_and_CheckBound 4
.x
	tst.w	_moarhax
	bne		.kkk
		or.w	#%000010*STRUCTSIZE,d7
		subq.w	#1,_moarhax
		add.w	#80,a1
.kkk
	move.w	d7,checkerMask

.end
	move.l	currentMyBufferPointers_producer,a6
	movem.l	a0-a5,(a6)

	movem.l	currentMyBufferPointers_producer,d0-d3
	move.l	d0,d4
	movem.l	d1-d4,currentMyBufferPointers_producer
	rts

fivePlanesPalette
	movem.w	paletteOrder,d0-d5	; order
	lea		fivePlanesPaletteColors,a1	; colors
	add.w	paletteColorsOff,a1

	subq.w	#1,paletteFadeWaiter
	bge		.kk
		move.w	#5,paletteFadeWaiter
		sub.w	#14,paletteColorsOff
		bge		.kk
			move.w	#0,paletteColorsOff
.kk

	subq.w	#1,paletteFadeWaiterReverse
	bge		.kk2
		move.w	#9999,paletteFadeWaiter
		move.w	#5,paletteFadeWaiterReverse
		add.w	#14,paletteColorsOff
		cmp.w	#8*14,paletteColorsOff
		bne		.kk2
			move.w	#7*14,paletteColorsOff


			move.w	#$4e71,printText

			move.w	#0,yoffset
			move.w	#10*160,screenOffset
			move.w	#40,xtimes
			move.w	#15,ytimes
			move.w	#100,textWaiter
			move.w	#0,textSourcePosition
			move.w	#0,textTargetPosition
			move.l	#text5,textPointer
			move.w	#900,_shitwaiter
			move.l	#endFade,fadeTarget
			move.w	#10,asdasd
			add.w	#7*4*6,textShitOffset
			move.w	#0,_lastScreen
			move.w	#$2700,sr
			move.l	#effect5_vbl,$70
			move.w	#$2300,sr


.kk2

	lea		$ffff8242,a2

	move.w	(a1,d0.w),d0		; color
	move.w	(a1,d1.w),d1		; color
	move.w	(a1,d2.w),d2		; color
	move.w	(a1,d3.w),d3		; color
	move.w	(a1,d4.w),d4		; color
	move.w	(a1,d5.w),d5		; color
	move.w	12(a1),d6

	subq.w	#1,flashTimer4
	bge		.skip4
		move.w	#10,flashTimer4
		subq.w	#1,flashTimes4
		blt		.skip4
			move.w	flashTimes4,d0
			and.w	#1,d0
			beq		.normal4
				move.w	d5,flash4Overrule
				add.w	#$011,flash4Overrule
				jmp		.skip4
.normal4
				move.w	#-1,flash4Overrule
.skip4
	subq.w	#1,flashTimer3
	bge		.skip3
		move.w	#10,flashTimer3
		subq.w	#1,flashTimes3
		blt		.skip3
			move.w	flashTimes3,d0
			and.w	#1,d0
			beq		.normal3
				move.w	d4,flash3Overrule
				add.w	#$011,flash3Overrule
				jmp		.skip3
.normal3
				move.w	#-1,flash3Overrule
.skip3

	subq.w	#1,flashTimer2
	bge		.skip2
		move.w	#10,flashTimer2
		subq.w	#1,flashTimes2
		blt		.skip2
			move.w	flashTimes2,d0
			and.w	#1,d0
			beq		.normal2
				move.w	d3,flash2Overrule
				add.w	#$011,flash2Overrule
				jmp		.skip2
.normal2
				move.w	#-1,flash2Overrule
.skip2

	subq.w	#1,flashTimer1
	bge		.skip1
		move.w	#10,flashTimer1
		subq.w	#1,flashTimes1
		blt		.skip1
			move.w	flashTimes1,d0
			and.w	#1,d0
			beq		.normal1
				move.w	d2,flash1Overrule
				add.w	#$011,flash1Overrule
				jmp		.skip1
.normal1
				move.w	#-1,flash1Overrule
.skip1


	subq.w	#1,flashTimer0
	bge		.skip0
		move.w	#10,flashTimer0
		subq.w	#1,flashTimes0
		blt		.skip0
			move.w	flashTimes0,d0
			and.w	#1,d0
			beq		.normal0
				move.w	d1,flash0Overrule
				add.w	#$110,flash0Overrule
				jmp		.skip0
.normal0
				move.w	#-1,flash0Overrule
.skip0


	tst.w	flash4Overrule
	blt		.no4
		move.w	flash4Overrule,d5
.no4
	tst.w	flash3Overrule
	blt		.no3
		move.w	flash3Overrule,d4
.no3
	tst.w	flash2Overrule
	blt		.no2
		move.w	flash2Overrule,d3
.no2
	tst.w	flash1Overrule
	blt		.no1
		move.w	flash1Overrule,d2
.no1
	tst.w	flash0Overrule
	blt		.no0
		move.w	flash0Overrule,d1
.no0

	;; here we do the flash to indicate number of 
;	move.w	#$700,d5


	move.w	d6,(a2)+			; l1 = c1
	move.w	d1,(a2)+			; l2 = c2,c3
	move.w	d1,(a2)+
	move.w	d2,(a2)+			; l3 = c4,c5
	move.w	d2,(a2)+
	move.w	d3,(a2)+			; l4 = c6,c7
	move.w	d3,(a2)+

	move.w	d4,(a2)+			; l5 = c8
	move.w	d5,(a2)+			; l6 = c9
	move.w	d4,(a2)+
	move.w	d5,(a2)+			
	move.w	d4,(a2)+
	move.w	d5,(a2)+			
	move.w	d4,(a2)+
	move.w	d5,(a2)+	

	movem.l	$ffff8240,d0-d7
	movem.l	d0-d7,currentPalette
	move.w	12(a1),currentPalette
	rts

_moarhax		dc.w	2


plane2Waiter	dc.w	190
plane3Waiter	dc.w	270
plane4Waiter	dc.w	350	
plane5Waiter	dc.w	430	

flashTimer0		dc.w	90
flashTimes0		dc.w	5
flash0Overrule	dc.w	-1

flashTimer1		dc.w	90
flashTimes1		dc.w	5
flash1Overrule	dc.w	-1

flashTimer2		dc.w	90+80
flashTimes2		dc.w	5
flash2Overrule	dc.w	-1

flashTimer3		dc.w	90+160
flashTimes3		dc.w	5
flash3Overrule	dc.w	-1


flashTimer4		dc.w	90+240
flashTimes4		dc.w	5
flash4Overrule	dc.w	-1

dummyTA
dummyTB
	rte

fourPlanesPalette
	movem.w	paletteOrder,d0-d5	; order
	lea		fourPlanesPaletteColors,a1	; colors
	add.w	paletteColorsOff,a1

	subq.w	#1,paletteFadeWaiter
	bge		.kk
		move.w	#5,paletteFadeWaiter
		sub.w	#14,paletteColorsOff
		bge		.kk
			move.w	#0,paletteColorsOff
.kk

	subq.w	#1,paletteFadeWaiterReverse
	bge		.kk2
		move.w	#9999,paletteFadeWaiter
		move.w	#5,paletteFadeWaiterReverse
		add.w	#14,paletteColorsOff
		cmp.w	#8*14,paletteColorsOff
		bne		.kk2
			move.w	#7*14,paletteColorsOff


			move.w	#$4e71,printText

			move.w	#0,yoffset
			move.w	#10*160,screenOffset
			move.w	#40,xtimes
			move.w	#15,ytimes
			move.w	#100,textWaiter
			move.w	#0,textSourcePosition
			move.w	#0,textTargetPosition
			move.l	#text4,textPointer
			move.w	#800,_shitwaiter
			move.l	#endFade,fadeTarget
			move.w	#10,asdasd
			add.w	#7*4*6,textShitOffset

			move.w	#$2700,sr
			move.l	#effect5_vbl,$70
			move.w	#$2300,sr


.kk2


	lea		$ffff8242,a2

	move.w	(a1,d0.w),d0		; color
	move.w	(a1,d1.w),d1		; color
	move.w	(a1,d2.w),d2		; color
	move.w	(a1,d3.w),d3		; color
	move.w	(a1,d4.w),d4		; color
	move.w	(a1,d5.w),d5		; color
	move.w	12(a1),d6

	subq.w	#1,flashTimer4
	bge		.skip4
		move.w	#20,flashTimer4
		subq.w	#1,flashTimes4
		blt		.skip4
			move.w	flashTimes4,d0
			and.w	#1,d0
			beq		.normal4
				move.w	d5,flash4Overrule
				add.w	#$222,flash4Overrule
;				add.w	#$401,flash4Overrule
				jmp		.skip4
.normal4
				move.w	#-1,flash4Overrule
.skip4
	subq.w	#1,flashTimer3
	bge		.skip3
		move.w	#20,flashTimer3
		subq.w	#1,flashTimes3
		blt		.skip3
			move.w	flashTimes3,d0
			and.w	#1,d0
			beq		.normal3
				move.w	d4,flash3Overrule
				add.w	#$112,flash3Overrule
;				add.w	#$401,flash3Overrule
				jmp		.skip3
.normal3
				move.w	#-1,flash3Overrule
.skip3

	subq.w	#1,flashTimer2
	bge		.skip2
		move.w	#20,flashTimer2
		subq.w	#1,flashTimes2
		blt		.skip2
			move.w	flashTimes2,d0
			and.w	#1,d0
			beq		.normal2
				move.w	d3,flash2Overrule
				add.w	#$111,flash2Overrule
;				add.w	#$401,flash2Overrule
				jmp		.skip2
.normal2
				move.w	#-1,flash2Overrule
.skip2

	subq.w	#1,flashTimer1
	bge		.skip1
		move.w	#20,flashTimer1
		subq.w	#1,flashTimes1
		blt		.skip1
			move.w	flashTimes1,d0
			and.w	#1,d0
			beq		.normal1
				move.w	d2,flash1Overrule
				add.w	#$111,flash1Overrule
;				add.w	#$401,flash1Overrule
				jmp		.skip1
.normal1
				move.w	#-1,flash1Overrule
.skip1

	tst.w	flash4Overrule
	blt		.no4
		move.w	flash4Overrule,d5
.no4
	tst.w	flash3Overrule
	blt		.no3
		move.w	flash3Overrule,d4
.no3
	tst.w	flash2Overrule
	blt		.no2
		move.w	flash2Overrule,d3
.no2
	tst.w	flash1Overrule
	blt		.no1
		move.w	flash1Overrule,d2
.no1

	;; here we do the flash to indicate number of 
;	move.w	#$700,d5


	move.w	d6,(a2)+			; l1 = c1
	move.w	d6,(a2)+			; l2 = c2,c3
	move.w	d6,(a2)+
	move.w	d2,(a2)+			; l3 = c4,c5
	move.w	d2,(a2)+
	move.w	d3,(a2)+			; l4 = c6,c7
	move.w	d3,(a2)+

	move.w	d4,(a2)+			; l5 = c8
	move.w	d5,(a2)+			; l6 = c9
	move.w	d4,(a2)+
	move.w	d5,(a2)+			
	move.w	d4,(a2)+
	move.w	d5,(a2)+			
	move.w	d4,(a2)+
	move.w	d5,(a2)+	

	movem.l	$ffff8240,d0-d7
	movem.l	d0-d7,currentPalette
	move.w	12(a1),currentPalette
	rts


fourPlanesPaletteColors	

    dc.w    $700
    dc.w    $070
    dc.w    $544 ; background
    dc.w    $434
    dc.w    $223
    dc.w    $112 ; foreground
    dc.w    $0

    dc.w    $700
    dc.w    $070
    dc.w    $433
    dc.w    $334
    dc.w    $223
    dc.w    $112;023
    dc.w    $0

    dc.w    $700
    dc.w    $070
    dc.w    $333
    dc.w    $323
    dc.w    $223
    dc.w    $112;023
    dc.w    $0

    dc.w    $700
    dc.w    $070
    dc.w    $322
    dc.w    $223
    dc.w    $113
    dc.w    $112;023
    dc.w    $001

    dc.w    $700
    dc.w    $070
    dc.w    $222
    dc.w    $212
    dc.w    $113
    dc.w    $112;023
    dc.w    $002

    dc.w    $700
    dc.w    $070
    dc.w    $222
    dc.w    $212
    dc.w    $113
    dc.w    $112;022
    dc.w    $112

    dc.w    $112
    dc.w    $112
    dc.w    $112
    dc.w    $112
    dc.w    $112
    dc.w    $112;012
    dc.w    $112

    dc.w    $112
    dc.w    $112
    dc.w    $112
    dc.w    $112
    dc.w    $112
    dc.w    $112
    dc.w    $112




 
fourPlanesMovement	
	move.w	#135*8,checker_size4
	move.w	#94*8,checker_size3
	move.w	#60*8,checker_size5
	move.w	#34*8,checker_size2

	move.w	#325*8,checker_size1
	move.w	#325*8,checker_size0

	lea		my16versions,a0
	lea		myXposList2,a6
	move.l	a0,a1
	move.l	a0,a2
	move.l	a0,a3
	move.l	a0,a4
	move.l	a0,a5
	moveq	#0,d0


	; OFFSETS INTO SOURCE
	apply_XOff_to_ScanlineSource 0
	apply_XOff_to_ScanlineSource 1
	apply_XOff_to_ScanlineSource 2
	apply_XOff_to_ScanlineSource 3
	apply_XOff_to_ScanlineSource 4
	apply_XOff_to_ScanlineSource 5
	; a0,a1,a2,a3,a4,a5 done now

;	move.w	#30,checkerSizeOff

	; X MOVEMENT
	move.w	checkerMask,d7				; mask
	; check boundaries	
	moveq	#0,d2
	increaseAndCheckBoundNormal 0
	moveq	#0,d2
	increaseAndCheckBoundNormal 1
	moveq	#1*8,d2
	subq.w	#1,plane2Waiter
	blt		.no02
		moveq	#0,d2
.no02
	increaseAndCheckBoundNormal 2
	moveq	#-2*8,d2
	subq.w	#1,plane3Waiter
	blt		.no03
		moveq	#0,d2
.no03
	increaseAndCheckBoundNormal 5
	moveq	#0,d2
	increaseAndCheckBoundNormal 3
	moveq	#0,d2
	increaseAndCheckBoundNormal 4


	move.w	checker_ymovement0,d1
	increase_YOff_and_CheckBound 0
	move.w	checker_ymovement1,d1
	increase_YOff_and_CheckBound 1
	move.w	checker_ymovement2,d1
	increase_YOff_and_CheckBound 2
	move.w	checker_ymovement3,d1
	increase_YOff_and_CheckBound 5
	move.w	checker_ymovement4,d1

	move.w	#3*8,d1
	subq.w	#1,plane4Waiter
	blt		.no04
		moveq	#0,d1
.no04
	increase_YOff_and_CheckBound 3
	move.w	checker_ymovement5,d1
	move.w	#-4*8,d1
	subq.w	#1,plane5Waiter
	blt		.no05
		moveq	#0,d1
.no05

	increase_YOff_and_CheckBound 4

	move.w	d7,checkerMask

.end
	IFNE	genlower
		move.b	#0,$ffffc123
	ENDC
;		move.b	#0,$ffffc123
	move.l	currentMyBufferPointers_producer,a6
	movem.l	a0-a5,(a6)

	movem.l	currentMyBufferPointers_producer,d0-d3
	move.l	d0,d4
	movem.l	d1-d4,currentMyBufferPointers_producer
	rts

checker_ymovement0	dc.w	0
checker_ymovement1	dc.w	0
checker_ymovement2	dc.w	0
checker_ymovement3	dc.w	0
checker_ymovement4	dc.w	0
checker_ymovement5	dc.w	0

checker_xmovement0	dc.w	0
checker_xmovement1	dc.w	0
checker_xmovement2	dc.w	0
checker_xmovement3	dc.w	0
checker_xmovement4	dc.w	0
checker_xmovement5	dc.w	0


currentMovementRout	dc.l	fourPlanesMovement
currentPaletteRout	dc.l	fourPlanesPalette

doMovement
	move.l	currentMovementRout,a0
	jmp		(a0)

doPalette
	move.l	currentPaletteRout,a0
	jmp		(a0)
	


sixPlanesMovement
preparePointersIntoSourceScanLines

	move.w	checkerSizeOff,d6


;checker_size4				equ $2000-14
;checker_size3				equ $2000-12
;checker_size5				equ $2000-10
;checker_size2				equ $2000-8
;checker_size1				equ $2000-6
;checker_size0				equ $2000-4

	lea		checkerSizesList4,a6
	lea		checker_size4,a5
	move.w	(a6,d6.w),(a5)+
	lea		checkerSizesList3,a6
	move.w	(a6,d6.w),(a5)+
	lea		checkerSizesList5,a6
	move.w	(a6,d6.w),(a5)+
	lea		checkerSizesList2,a6
	move.w	(a6,d6.w),(a5)+
	lea		checkerSizesList1,a6
	move.w	(a6,d6.w),(a5)+
	lea		checkerSizesList0,a6
	move.w	(a6,d6.w),(a5)+

	lea		my16versions,a0
	lea		myXposList2,a6
	move.l	a0,a1
	move.l	a0,a2
	move.l	a0,a3
	move.l	a0,a4
	move.l	a0,a5
	moveq	#0,d0


	; OFFSETS INTO SOURCE
	apply_XOff_to_ScanlineSource 0
	apply_XOff_to_ScanlineSource 1
	apply_XOff_to_ScanlineSource 2
	apply_XOff_to_ScanlineSource 3
	apply_XOff_to_ScanlineSource 4
	apply_XOff_to_ScanlineSource 5
	; a0,a1,a2,a3,a4,a5 done now

	add.w	#2,checkerSizeOff
	cmp.w	#STEPS*2,checkerSizeOff
	bne		.okxxx
		move.w	#0,checkerSizeOff

		movem.w	checker_xoff4,d0-d5	; this is already done by the apply_xoffbla
		movem.w	d1-d5,checker_xoff4

		movem.w	checker_yoff4,d0-d5
		movem.w	d1-d5,checker_yoff4

		movem.w	xoff4,d0-d5
		movem.w	d1-d5,xoff4

		movem.w	checker_size4,d0-d5
		movem.w	d1-d5,checker_size4

		move.w	checkerSizesList0,checker_size0

	lea		checkerMaskList,a6
	move.w	checkerMask,d7
	lsr.w	#5,d7
	move.w	(a6,d7.w),checkerMask
.okxxx


	; X MOVEMENT
	lea		deltaMove,a6
	move.w	checkerMask,d7
	move.w	#512,d6

	tst.w	borderSteps
	bge		.noy
		subq.w	#1,_moreWaiter
		bge		.noy
		move.w	#-1,_moreWaiter
;	jmp		.nox
	; check boundaries	
	move.w	#2*1,d1
	increaseAndCheckBound 0
	move.w	#2*1,d1
	increaseAndCheckBound 1
	move.w	#2*2,d1
	increaseAndCheckBound 2
	move.w	#2*2,d1
	increaseAndCheckBound 5
	move.w	#2*2,d1
	increaseAndCheckBound 3
	move.w	#2*1,d1
	increaseAndCheckBound 4
.nox
;	jmp		.noy
	lea		deltaMoveY,a6
	add.w	d6,d6

	move.w	#2*1,d1
	increase_YOff_and_CheckBound_Offset 0
	move.w	#2*1,d1
	increase_YOff_and_CheckBound_Offset 1
	move.w	#2*1,d1
	increase_YOff_and_CheckBound_Offset 2
	move.w	#2*1,d1
	increase_YOff_and_CheckBound_Offset 5
	move.w	#2*1,d1
	increase_YOff_and_CheckBound_Offset 3
	move.w	#2*1,d1
	increase_YOff_and_CheckBound_Offset 4
.noy
.end
	move.w	d7,checkerMask

	move.l	currentMyBufferPointers_producer,a6
	movem.l	a0-a5,(a6)

	movem.l	currentMyBufferPointers_producer,d0-d3
	movem.l	d1-d3/a6,currentMyBufferPointers_producer

	rts

_moreWaiter	dc.w	80+150

times	dc.w	2000

currentMyBufferPointers_producer	dc.l	myBufferPointers1
backupBufferPointers1_producer		dc.l	myBufferPointers2
backupBufferPointers2_producer		dc.l	myBufferPointers3
backupBufferPointers3_producer		dc.l	myBufferPointers4

currentMyBufferPointers_consumer	dc.l	myBufferPointers1
backupBufferPointers1_consumer		dc.l	myBufferPointers2
backupBufferPointers2_consumer		dc.l	myBufferPointers3
backupBufferPointers3_consumer		dc.l	myBufferPointers4

myBufferPointers1		ds.l	6
myBufferPointers2		ds.l	6
myBufferPointers3		ds.l	6
myBufferPointers4		ds.l	6



copyUniqueLinesNew2
	move.l	currentDrawListPointer_consumer,a0

.startNew		
	move.w	(a0)+,d7		; move index of datastruct
	beq		.endNew			; if 0, then quit
		move.w	d7,a1
		move.w	(a1)+,d7		; if we get here, we know for sure that we're not fucked.copyLoadRegsNew
		move.l	a1,usp
.firstColumn
	move.l	(a1)+,a6
	move.w	(a1)+,d6
			raster	$700
	movem.l	120(a6),d0-d5/a2-a5
			raster	$007
	jmp		.fillStartColumn(pc,d6)
.fillStartColumn
y set (160-1)*160


	IFEQ GENERATEINSCREEN
size set 159
	ELSE
size set 160
	ENDC
		REPT size
			movem.l	d0-d5/a2-a5,y+120(a6)			; copy 10 regs = 40 bytes, is 1/4th of a scanline
y set y-160
		ENDR
			raster	$330
	cmp.w	a1,d7
	beq		.nextColumn80
	move.l	(a1)+,a6
	move.w	(a1)+,d6
;---------------------------------------------------
.jmpStart
	jmp		.fillStartColumn2(pc,d6)
.fillStartColumn2
y set (160-1)*160
		REPT 160
			movem.l	d0-d5/a2-a5,y+120(a6)			; copy 10 regs = 40 bytes, is 1/4th of a scanline
y set y-160
		ENDR
			raster	$330
	cmp.w	a1,d7
	beq		.nextColumn80
	move.l	(a1)+,a6
	move.w	(a1)+,d6
	jmp		.jmpStart

.nextColumn80
	move.l	usp,a1
	move.l	(a1)+,a6
	move.w	(a1)+,d6
	movem.l	80(a6),d0-d5/a2-a5
			raster	$007
	jmp		.fillSecondColumn(pc,d6)
.fillSecondColumn
y set (160-1)*160
		REPT size
			movem.l	d0-d5/a2-a5,y+80(a6)			; copy 10 regs = 40 bytes, is 1/4th of a scanline
y set y-160
		ENDR
			raster	$044
	cmp.w	a1,d7
	beq		.nextColumn40
	move.l	(a1)+,a6
	move.w	(a1)+,d6
;---------------------------------------------------
.jmpStart2
			raster	$007
	jmp		.fillSecondColumn2(pc,d6)
.fillSecondColumn2
y set (160-1)*160
		REPT 160
			movem.l	d0-d5/a2-a5,y+80(a6)			; copy 10 regs = 40 bytes, is 1/4th of a scanline
y set y-160
		ENDR
			raster	$044
	cmp.w	a1,d7
	beq		.nextColumn40
	move.l	(a1)+,a6
	move.w	(a1)+,d6
	jmp		.jmpStart2				;12		TODO test with unrolled loops, there is a max depth of this.....

.nextColumn40
	move.l	usp,a1
	move.l	(a1)+,a6
	move.w	(a1)+,d6
	movem.l	40(a6),d0-d5/a2-a5
			raster	$007
	jmp		.fillThirdColumn(pc,d6)
.fillThirdColumn
y set (160-1)*160
		REPT size
			movem.l	d0-d5/a2-a5,y+40(a6)			; copy 10 regs = 40 bytes, is 1/4th of a scanline
y set y-160
		ENDR
			raster	$770
	cmp.w	a1,d7
	beq		.lastColumn
		move.l	(a1)+,a6
		move.w	(a1)+,d6
;---------------------------------------------------
.jmpStart3
			raster	$007
	jmp		.fillThirdColumn2(pc,d6)
.fillThirdColumn2
y set (160-1)*160
		REPT 160
			movem.l	d0-d5/a2-a5,y+40(a6)			; copy 10 regs = 40 bytes, is 1/4th of a scanline
y set y-160
		ENDR
			raster	$770
	cmp.w	a1,d7
	beq		.lastColumn
		move.l	(a1)+,a6
		move.w	(a1)+,d6
		jmp		.jmpStart3
;---------------------------------------------------
.lastColumn
	move.l	usp,a1
	move.l	(a1)+,a6
	move.w	(a1)+,d6
	movem.l	0(a6),d0-d5/a2-a5
			raster	$007
	jmp		.fillLastColumn(pc,d6)
.fillLastColumn
y set (160-1)*160
		REPT size
			movem.l	d0-d5/a2-a5,y+0(a6)			; copy 10 regs = 40 bytes, is 1/4th of a scanline
y set y-160
		ENDR
			raster	$555
	cmp.w	a1,d7
	beq		.startNew
		move.l	(a1)+,a6
		move.w	(a1)+,d6
;---------------------------------------------------
.jmpStart4
			raster	$007
	jmp		.fillLastColumn2(pc,d6)
.fillLastColumn2
y set (160-1)*160
		REPT 160
			movem.l	d0-d5/a2-a5,y+0(a6)			; copy 10 regs = 40 bytes, is 1/4th of a scanline
y set y-160
		ENDR
			raster	$555
	cmp.w	a1,d7
	beq		.startNew
		move.l	(a1)+,a6
		move.w	(a1)+,d6
		jmp		.jmpStart4
.endNew
	rts

checkerMask	dc.w	0


;checker_xoff0	dc.w	0
;checker_xoff1	dc.w	0
;checker_xoff2	dc.w	0
;checker_xoff5	dc.w	0
;checker_xoff3	dc.w	0
;checker_xoff4	dc.w	0

; --->
; 000001 -> 000010		0->1
; 000010 -> 000100		1->2
; 000100 -> 100000		2->5
; 100000 -> 001000		5->3
; 001000 -> 010000		3->4
; 010000 -> 000000		4-> gone


checkerMaskList
	dc.w	%000000*STRUCTSIZE			;000000			
	dc.w	%000010*STRUCTSIZE			;000001
	dc.w	%000100*STRUCTSIZE			;000010
	dc.w	%000110*STRUCTSIZE			;000011
	dc.w	%100000*STRUCTSIZE			;000100
	dc.w	%100010*STRUCTSIZE			;000101
	dc.w	%100100*STRUCTSIZE			;000110
	dc.w	%100110*STRUCTSIZE			;000111
	dc.w	%010000*STRUCTSIZE			;001000
	dc.w	%010010*STRUCTSIZE			;001001
	dc.w	%010100*STRUCTSIZE			;001010		
	dc.w	%010110*STRUCTSIZE			;001011
	dc.w	%110000*STRUCTSIZE			;001100
	dc.w	%110010*STRUCTSIZE			;001101
	dc.w	%110100*STRUCTSIZE			;001110
	dc.w	%110110*STRUCTSIZE			;001111

	dc.w	%000000*STRUCTSIZE			;010000			
	dc.w	%000010*STRUCTSIZE			;010001
	dc.w	%000100*STRUCTSIZE			;010010
	dc.w	%000110*STRUCTSIZE			;010011
	dc.w	%100000*STRUCTSIZE			;010100
	dc.w	%100010*STRUCTSIZE			;010101
	dc.w	%100100*STRUCTSIZE			;010110
	dc.w	%100110*STRUCTSIZE			;010111
	dc.w	%010000*STRUCTSIZE			;011000
	dc.w	%010010*STRUCTSIZE			;011001
	dc.w	%010100*STRUCTSIZE			;011010		
	dc.w	%010110*STRUCTSIZE			;011011
	dc.w	%110000*STRUCTSIZE			;011100
	dc.w	%110010*STRUCTSIZE			;011101
	dc.w	%110100*STRUCTSIZE			;011110
	dc.w	%110110*STRUCTSIZE			;011111

	dc.w	%001000*STRUCTSIZE			;100000			
	dc.w	%001010*STRUCTSIZE			;100001
	dc.w	%001100*STRUCTSIZE			;100010
	dc.w	%001110*STRUCTSIZE			;100011
	dc.w	%101000*STRUCTSIZE			;100100
	dc.w	%101010*STRUCTSIZE			;100101
	dc.w	%101100*STRUCTSIZE			;100110
	dc.w	%101110*STRUCTSIZE			;100111
	dc.w	%011000*STRUCTSIZE			;101000
	dc.w	%011010*STRUCTSIZE			;101001
	dc.w	%011100*STRUCTSIZE			;101010		
	dc.w	%011110*STRUCTSIZE			;101011
	dc.w	%111000*STRUCTSIZE			;101100
	dc.w	%111010*STRUCTSIZE			;101101
	dc.w	%111100*STRUCTSIZE			;101110
	dc.w	%111110*STRUCTSIZE			;101111

	dc.w	%001000*STRUCTSIZE			;110000			
	dc.w	%001010*STRUCTSIZE			;110001
	dc.w	%001100*STRUCTSIZE			;110010
	dc.w	%001110*STRUCTSIZE			;110011
	dc.w	%101000*STRUCTSIZE			;110100
	dc.w	%101010*STRUCTSIZE			;110101
	dc.w	%101100*STRUCTSIZE			;110110
	dc.w	%101110*STRUCTSIZE			;110111
	dc.w	%011000*STRUCTSIZE			;111000
	dc.w	%011010*STRUCTSIZE			;111001
	dc.w	%011100*STRUCTSIZE			;111010		
	dc.w	%011110*STRUCTSIZE			;111011
	dc.w	%111000*STRUCTSIZE			;111100
	dc.w	%111010*STRUCTSIZE			;111101
	dc.w	%111100*STRUCTSIZE			;111110
	dc.w	%111110*STRUCTSIZE			;111111

maskList
	dc.w	$2000
	dc.w	$3000
	dc.w	$4000
	dc.w	$5000

maskListOff					dc.w	0
currentMaskAddresValue		dc.w	$2000
maskListOffConsumer			dc.w	0




populateDrawListStruct
	; - set up register sources, by size and xoff
	;		a0,a1,a2,a3		scanline data pointers and offset selection from preshift	; replace a0 with d4, use a0 for some list
	;		a4 is drawstructlist
	;		a5 local var
	;		a6	myYList

	;		d0,d1,d2,d3		local offsets, lines remaining
	;		d5 				y value offset
	;		d6				number of lines to be filled
	;		d7 				bitmask

	IFEQ	USEA7
.waiter
;	tst.w	a7free
;	beq		.okgo
;		add.w	#$001,$ffff8240
;	jmp		.waiter
.okgo
	ENDC
	move.w	checkerMask,d7
	or.w	currentMaskAddresValue,d7					; drawlistStruct address hardcoded; todo: SMC


	; original sizes
	move.w	checker_size0,a3				
	move.w	checker_size1,a1
	IFEQ	USEA7
		move.w	checker_size2,a2
		move.w	checker_size5,a6
		move.l	a6,usp
	ELSE
		move.w	checker_size2,a0
		move.l	a0,usp
	ENDC

	; localsizes
	move.l	myHaxListPointer,d0
	move.l	d0,d1
	move.l	d0,d2
	move.l	d0,d3
	move.l	d0,d4
	move.l	d0,d5

	move.w	checker_yoff0,d0
	move.w	checker_yoff1,d1
	move.w	checker_yoff2,d2
	move.w	checker_yoff3,d3
	move.w	checker_yoff4,d4
	move.w	checker_yoff5,d5

	move.l	currentDrawListPointer_producer,a6

	; use y-offset to determine inverted and final local sizes
	; currently omitted
	move.l	a7,savedA7
	IFEQ	USEA7
	move.l	screenpointer2,a7			; harhar
	ELSE
		IFEQ	USEBUFFERS
			move.l	currentScreenPointer_producer,a2
		ELSE
			move.l	screenpointer2,a2
		ENDC
	ENDC

smchax
	move.w	#100*8,d6					; number of lines to be filled	*2, because we premult by 2
	; in use:
	;	usp,a0,a4,a5,a6
	;	d0,d1,d2,d3,d4,d5,d6,d7
	;	a1,a2,a3

	IFEQ	STATISTICS
		move.w	#0,nr_of_unique
		move.w	#0,nr_of_switches
	ENDC
	jmp		determineSmallestNumber6

;savedA7	dc.l	0



shiftChecker16Places
	lea		lines,a0						; unpack this to #40*2*2*256*2
	lea		my16versions,a1
	move.l	#40*2*2*NUMBER_OF_LINES,d0		; this is the offset per 16 versions
; first we copy the inital version
	move.w	#NUMBER_OF_LINES-1,d6
.copy
	REPT 20									; 
	move.l	(a0)+,(a1)+
	ENDR
	sub.w	#20*4,a0
	REPT 20
		move.l	(a0)+,d1
		not.l	d1
		move.l	d1,(a1)+
	ENDR
	dbra	d6,.copy

; now we have the first 256 entires copies, restore a0
	lea	my16versions,a0		; this contains the first 512 lines of 40 bytes
	move.w	#15-1,d7
.doOneX
	move.w	#NUMBER_OF_LINES-1,d6
.doShift
	moveq	#0,d0
	roxr.w	d0
	; roxr one line
	REPT 40
	move.w	(a0)+,d0
	roxr.w	d0
	move.w	d0,(a1)+
	ENDR
	moveq	#0,d0
	roxr.w	d0
	; roxr the negative one
	REPT 40
	move.w	(a0)+,d0
	roxr.w	d0
	move.w	d0,(a1)+
	ENDR

	dbra	d6,.doShift
	dbra	d7,.doOneX
	rts

copySmallestNumber
	lea		treestart,a0		;source
	lea		determineSmallestNumber6,a1						;dest
	move.l	#treeend,d7
	sub.l	#treestart,d7
	lsr.w	#1,d7
	subq.w	#1,d7
.copy
		move.w	(a0)+,(a1)+
		dbra	d7,.copy
	rts

copyDrawCode
	lea 	drawStart,a0
	lea		scanLineCode,a1
	move.l	#drawEnd,d7
	sub.l	#drawStart,d7
	lsr.w	#1,d7
	subq.w	#1,d7
.copy
		move.w	(a0)+,(a1)+
		dbra	d7,.copy
	rts

;;;;;;;;;; INTRO CODE

init_effect_fade

	IFEQ	GENERATEFONT
		jsr		prepFont
	ENDC

	jsr		music


	move.w	#$2700,sr
	move.l	#faderout,$70
	move.w	#$2300,sr

.waitloop
		jsr		init_checkerBoard
		jsr		dePackAmiga
	tst.w	_faded
	bne		.waitloop


.waitloop2
		nop
	tst.w	_textDone
	bne		.waitloop2

	jsr		copyImage
	move.w	#$4e71,printText
	move.w	#$4e71,doTextHighLight

	move.w	#0,yoffset
	move.w	#0,screenOffset
	move.w	#40,xtimes
	move.w	#15,ytimes
	move.w	#0,textSourcePosition
	move.w	#0,textTargetPosition
	move.l	#text,textPointer

	move.w	#$2700,sr
	move.l	#effect_vbl,$70
	move.w	#$2300,sr

.wait2
	tst.w	effect2_waiter
	bne		.wait2


	rts

effect2_waiter	dc.w	-1


_textDone	dc.w	1

init_effect2
		move.w	#$2700,sr
		move.l	#effect2_vbl,$70
		move.w	#$2300,sr

.wait
	tst.w	effect3_waiter
	bne		.wait

			move.w	#0,yoffset
			move.w	#90*160,screenOffset
			move.w	#40,xtimes
			move.w	#2,ytimes
			move.w	#0,textSourcePosition
			move.w	#0,textTargetPosition
			move.l	#text3,textPointer
			move.w	#1,textWaiter
			move.w	#$4e71,printText			; nop it out
			move.w	#$4e71,calcFades			; nop it out
			move.l	#endFade,fadeTarget
			move.w	#130,_shitwaiter
			jsr		updateFontPal
			move.w	#$2700,sr
			move.l	#effect3_vbl,$70
			move.w	#$2300,sr

.wait2
	tst.w	effect4_waiter
	bne		.wait2

	rts

dePackAmiga
	nop
	lea		amigacrk,a0
	move.l	screenpointer,a1
	add.l	#201*160,a1
	jsr		cranker


	lea		ataricrk,a0
	move.l	screenpointer,a1
	lea		atari,a1
	jsr		cranker
	move.w	#$4e75,dePackAmiga
	rts

_faded				dc.w	-1
_fadeoff			dc.w	0
_fadecolors			equ		14
_fadepal			dc.w	$777,$776,$765,$763,$752,$740,$730,$620,$510,$400,$300,$200,$100,$0
_fadecounterconst	equ		2
_fadecounter		dc.w	_fadecounterconst
_fadedramawaiter	dc.w 	100
_vblflag			dc.w	1
_shitwaiter			dc.w	30

faderout
	pushall
	subq.w	#1,_shitwaiter
	bge		.ok
	jsr		music+8
.ok
	tst.w	_faded
	beq		.text
	move.w	#0,_vblflag
	move.w	_fadeoff,d0
	cmp.w	#(_fadecolors-1)*2,d0
	bne		.notready
		subq.w	#1,_fadedramawaiter
		bne		.nofade
			move.w	#0,_faded
			move.l	#blackPal,fadeTarget

			popall
		rte
.notready
	subq.w	#1,_fadecounter
	bne		.nofade2
		move.w	#_fadecounterconst,_fadecounter
		addq.w	#2,d0
		lea		_fadepal,a0
		move.w	(a0,d0),d1
		lea		$ffff8240,a1
		move.w	#16-1,d7
.l
			move.w	d1,(a1)+
		dbra	d7,.l
		move.w	d0,_fadeoff
.nofade2
	popall
	rte

.text
		lea		$ffff8242,a0
		jsr		printText
	subq.w	#1,xxwaiter
	bge		.kkk
		lea		$ffff8240,a0
		jsr 	calcFades
		move.w	#5,xxwaiter
		subq.w	#1,xxtimes
		bge		.kkk
			move.w	#0,_textDone
			move.l	screenpointer,a0
			add.l	#201*160+4,a0
			move.l	a0,fadeTarget
.kkk
	popall
	rte


.nofade

	popall
	rte
xxtimes		dc.w	9
xxwaiter	dc.w	200
fadeTarget	dc.l	0

endFade2
	rept 7
		dc.w	$112
	endr



calcFades:
	nop
	move.l	fadeTarget,a1
	move.w	#16-1,d6
gogoFade
	move.w	#$700,d0
	move.w	#$070,d3
	move.w	#$007,d4
	move.w	#$100,d5
	move.w	#$10,a4
loop	
	move.w	(a0),a2		; whole palette word
	move.w	a2,d1		; red
	move.w	(a1)+,a3		; destination
.dored
	move.w	a2,d1
	move.w	a3,d7
	and.w	d0,d1
	and.w	d0,d7
	cmp.w	d1,d7
	bgt		.doPlusRed
	blt		.doMinusRed
.okRed
	; we're at the same thing, dont do anything
	jmp		.doGreen
.doMinusRed
	sub.w	d5,d1
	jmp		.doGreen
.doPlusRed
	add.w	d5,d1
.doGreen
	move.w	a2,d2
	move.w	a3,d7
	and.w	d3,d2
	and.w	d3,d7
	cmp.w	d2,d7
	bgt		.doPlusGreen
	blt		.doMinusGreen
.okGreen
	jmp		.doBlue
.doMinusGreen
	sub.w	a4,d2
	jmp		.doBlue
.doPlusGreen
	add.w	a4,d2
.doBlue
	or.w	d2,d1
	move.w	a2,d2
	move.w	a3,d7
	and.w	d4,d2
	and.w	d4,d7
	cmp.w	d2,d7
	bgt		.doPlusBlue
	blt		.doMinusBlue
.okBlue
	jmp		.doNext
.doMinusBlue
	subq.w	#1,d2
	jmp		.doNext
.doPlusBlue
	addq.w	#1,d2
.doNext
	or.w	d2,d1
	move.w	d1,(a0)+
	dbra	d6,loop
	rts



timer_a_opentop
	move.w	#$2100,sr			;Enable HBL
	stop	#$2100				;Wait for HBL
	move.w	#$2700,sr			;Stop all interrupts
	clr.b	$fffffa19.w			;Stop Timer Affff

    clr.b   $fffffa1b.w         													;6
    bset    #0,$fffffa07.w          												;7
    bset    #0,$fffffa13.w          												;7
    move.l	#timer_b_openbottom,$120	; schedule timer b to open lower			
    move.b  #227,$fffffa21.w        
	bclr	#3,$fffffa17.w															;7
    move.b  #8,$fffffa1b.w          												;5		---> 43

	addq.w	#1,$466

	REPT 84-43-4
		nop
	ENDR

	clr.b	$ffff820a.w				;60 Hz
	REPT 9
		nop
	ENDR
	move.b	#2,$ffff820a.w			;50 Hz	
	rte

waiter			dc.w	50
atariWaiter		dc.w	290
fadeOutWaiter	dc.w	750
fadeOutTimer	dc.w	100
textWaiter		dc.w	900
textDelay		dc.w	10


greenColors
	dc.w	$0
	dc.w	$020
	dc.w	$131
	dc.w	$341
	dc.w	$451
	dc.w	$463
	dc.w	$574
	dc.w	$777

redColors
	dc.w	$000,$200,$400,$511,$522,$644,$755,$766

timer_b_background_green
	pushall
		movem.l	greenColors,d0-d3
		movem.l	d0-d3,$ffff8240+8*2
	    clr.b   $fffffa1b.w         	
	    move.l	#timer_b_background_red,$120	; schedule timer b to open lower
	    move.b  #13,$fffffa21.w        
		bclr	#3,$fffffa17.w			
	    move.b  #8,$fffffa1b.w 	
	popall
	rte

timer_b_background_red
	pushall
	    clr.b   $fffffa1b.w         	
	    movem.l	redColors,d0-d3
	    movem.l	d0-d3,$ffff8240+8*2
	popall
	rte


effect_vbl
	pushall
	addq.w	#1,$466
	jsr		music+8

	move.w	#$0,$ffff8240				; set black background

	tst.w	textWaiter
	bge		.noTB
	    clr.b   $fffffa1b.w         	
	    bset    #0,$fffffa07.w          
	    bset    #0,$fffffa13.w          
	    move.l	#timer_b_background_green,$120	; schedule timer b to open lower
	    move.b  #3*13,$fffffa21.w        
		bclr	#3,$fffffa17.w			
	    move.b  #8,$fffffa1b.w   
.noTB

	subq.w	#1,waiter
	bge		.kkk
		lea		$ffff8240,a0
		jsr 	calcFades
		move.w	#5,waiter
.kkk

	subq.w	#1,fadeOutWaiter
	bge		.kkk2
		move.l	#blackPal,fadeTarget
		subq.w	#1,fadeOutTimer
		bge		.kkk2
			jsr		clearScreen
.kkk2

	jsr		amigaAtariCode
	jsr		smfxCode
.skip

	subq.w	#1,textWaiter
	bge		.skip2
		subq.w	#1,textDelay
			move.w	#$4e75,calcFades
			jsr		printText
			jsr		doTextHighLight
			move.w	#10,textDelay
.skip2

	subq.w	#1,transitionWaiter
	bge		.noVBL
		move.w	#0,effect2_waiter
.noVBL

	move.l	screenpointer,d0
	lsr.w	#8,d0
	move.l	d0,$ffff8200

	popall
	rte

transitionWaiter	dc.w	1600

timer_b_start	dc.w	1

effect2_vbl
	pushall
	addq.w	#1,$466
	jsr		music+8

	clr.b   $fffffa1b.w         	
	bset    #0,$fffffa07.w          
	bset    #0,$fffffa13.w          
	move.l	#timer_b_top,$120	; schedule timer b to open lower
	move.w	timer_b_start,d0
	move.b  d0,$fffffa21.w        
	bclr	#3,$fffffa17.w			
	move.b  #8,$fffffa1b.w   

	tst.w	timer_b_red_line
	bgt		.tt
	movem.l	redColors,d0-d3
	jmp		.xx
.tt
	movem.l	greenColors,d0-d3
.xx
	movem.l	d0-d3,$ffff8240+8*2

	jsr		clearLine

	popall
	rte



effect3_vbl
	addq.w	#1,$466
	pushall
	lea		music,a0
	jsr		8(a0)

	clr.b   $fffffa1b.w         	
	bset    #0,$fffffa07.w          
	bset    #0,$fffffa13.w          
	move.l	#timer_b_top2,$120	; schedule timer b to open lower
	move.w	timer_b_start,d0
	move.b  d0,$fffffa21.w        
	bclr	#3,$fffffa17.w			
	move.b  #8,$fffffa1b.w  	

	move.w	#0,$ffff8240
	subq.w	#1,textWaiter
	bge		.kkk
		jsr	printText
.kkk
	subq.w	#1,_shitwaiter
	bge		.lll
		move.w	#6,_shitwaiter
		lea		$ffff8240,a0
		jsr		calcFades
		subq.w	#1,asdasd
		bge		.lll
			move.w	#0,effect4_waiter
.lll

	popall
	rte

asdasd	dc.w	10
effect4_waiter	dc.w	-1



clearScreen200
	nop
	move.l	screenpointer,a6
.smc	
	add.l	#32084,a6
	moveq	#0,d0
	move.l	d0,d1
	move.l	d0,d2
	move.l	d0,d3
	move.l	d0,d4
	move.l	d0,d4
	move.l	d0,d5
	move.l	d0,d6
	move.l	d0,a0
	move.l	d0,a1
	move.l	d0,a2
	move.l	d0,a3
	move.l	d0,a4
	move.l	d0,a5
	;d0-d6 => 7
	;a0-a5 => 6 --> 13 -> 52	61
	move.w	#78/2-1,d7
.l
	REPT 8
		movem.l	d0-d6/a0-a5,-(a6)
	ENDR
	dbra	d7,.l
	subq.w	#1,.ccounter
	bge		.ttt
	move.w	#$4e75,clearScreen200
	move.w	#32084,.smc+2
	move.w	#1,.ccounter
	rts
.ttt
	move.w	#32084/2,.smc+2
.end
	rts
.ccounter	dc.w	1
.tcounter	dc.w	1

clearTop
	nop
	move.w	bgCol,d0
	lea		$ffff8242,a0
	rept 15
		move.w	d0,(a0)+
	endr
	move.l	screenpointer,a0
	moveq	#0,d0
	rept 20
		move.l	d0,(a0)+
		move.l	d0,(a0)+
	endr
	move.w	#$4e75,clearTop
	rts

effect5_vbl
	addq.w	#1,$466
	pushall
	lea		music,a0
	jsr		8(a0)

	move.l	#dummyTA,$134

	clr.b   $fffffa1b.w         	
	bset    #0,$fffffa07.w          
	bset    #0,$fffffa13.w          
	move.l	#timer_b_top2,$120	
	move.w	timer_b_start,d0
	move.b  d0,$fffffa21.w        
	bclr	#3,$fffffa17.w			
	move.b  #8,$fffffa1b.w  	

	jsr		clearTop
	jsr		clearScreen200

	subq.w	#1,textWaiter
	bge		.kkk
		jsr	printText
.kkk

	subq.w	#1,_shitwaiter
	bge		.lll
		move.w	#6,_shitwaiter
		lea		$ffff8240,a0
		jsr		calcFades
		subq.w	#1,asdasd
		bge		.lll
			tst.w	_lastScreen
			beq		.lastScreen
			move.l	#fivePlanesMovement,currentMovementRout
			move.l	#fivePlanesPalette,currentPaletteRout
			move.w	#10,paletteFadeWaiter
			move.w	#1050,paletteFadeWaiterReverse

			move.w	#154*8,checker_size4
			move.w	#116*8,checker_size3
			move.w	#86*8,checker_size5
			move.w	#60*8,checker_size2
			move.w	#40*8,checker_size1
			move.w	#150*8,checker_size0

			move.w	#20*8,checker_yoff0			
			move.w	#27*8,checker_yoff1
			move.w	#37*8,checker_yoff2	
			move.w	#86*8,checker_yoff5	
			move.w	#71*8,checker_yoff3	
			move.w	#52*8,checker_yoff4	

			move.w	#$4e71,clearTop
			move.w	#$4e71,clearScreen200

			move.w	#0,checker_ymovement0
			move.w	#0,checker_ymovement1
			move.w	#0,checker_ymovement2
			move.w	#0,checker_ymovement3
			move.w	#0,checker_ymovement4
			move.w	#0,checker_ymovement5

			move.w	#0,checker_xoff4
			move.w	#0,checker_xoff3
			move.w	#0,checker_xoff5
			move.w	#0,checker_xoff2
			move.w	#0,checker_xoff1
			move.w	#0,checker_xoff0
			move.w	#%000110*STRUCTSIZE,checkerMask

			move.w	#90,flashTimer0
			move.w	#5,flashTimes0
			move.w	#-1,flash0Overrule

			move.w	#90+80,flashTimer1
			move.w	#5,flashTimes1
			move.w	#-1,flash1Overrule

			move.w	#90+160,flashTimer2
			move.w	#5,flashTimes2
			move.w	#-1,flash2Overrule

			move.w	#90+240,flashTimer3
			move.w	#5,flashTimes3
			move.w	#-1,flash3Overrule

			move.w	#90+320,flashTimer4
			move.w	#5,flashTimes4
			move.w	#-1,flash4Overrule


			move.w	#$2700,sr
			move.l	#timer_a_opentop_checker,$134.w			;Install our own Timer A
			move.l	#effect_vbl_checker,$70
			move.w	#$2300,sr
			jmp		.lll
.lastScreen
			move.w	#30,checkerSizeOff
			move.l	#sixPlanesMovement,currentMovementRout
			move.l	#sixPlanesPalette,currentPaletteRout
			move.w	#10,paletteFadeWaiter
			move.w	#32000,paletteFadeWaiterReverse


			move.w	#40*7*2*7,paletteColorsOff

			move.w	#checker_size0_start,checker_size0		
			move.w	#checker_size1_start,checker_size1
			move.w	#checker_size2_start,checker_size2
			move.w	#checker_size5_start,checker_size5
			move.w	#checker_size3_start,checker_size3
			move.w	#checker_size4_start,checker_size4

			move.w	#17*8,checker_yoff0	
			move.w	#34*8,checker_yoff1	
			move.w	#50*8,checker_yoff2	
			move.w	#78*8,checker_yoff5	
			move.w	#112*8,checker_yoff3	
			move.w	#180*8,checker_yoff4	
			move.w	#0,checker_xoff4
			move.w	#0,checker_xoff3
			move.w	#0,checker_xoff5
			move.w	#0,checker_xoff2
			move.w	#0,checker_xoff1
			move.w	#0,checker_xoff0
			move.w	#%100001*STRUCTSIZE,checkerMask
			move.w	#$2700,sr
			move.l	#timer_a_opentop_checker,$134.w			;Install our own Timer A
			move.l	#effect_vbl_checker,$70
			move.w	#$2300,sr

.lll

	move.l	screenpointer,d0
	lsr.w	#8,d0
	move.l	d0,$ffff8200

	popall


	rte

_lastScreen	dc.w	-1

timer_b_top2
	move.w	bgCol,$ffff8240
	pushd0
	move.w	#200,d0
	sub.w	timer_b_start,d0
	sub.w	timer_b_start,d0
	clr.b   $fffffa1b.w         	
	move.l	#timer_b_bot2,$120	; schedule timer b to open lower
	move.b  d0,$fffffa21.w        
	move.b  #8,$fffffa1b.w   
	popd0
	rte

timer_b_bot2
	clr.b   $fffffa1b.w         	
	REPT 120/2
		or.l	d7,d7
	ENDR
	move.w	#0,$ffff8240

		sub.w	#2,timer_b_start
		cmp.w	#1,timer_b_start
		bge		.noTi
			move.w	#1,timer_b_start
.noTi
	rte


; greenstart: 3*13
; greenend:	  3*13 + 8

bgCol				dc.w	0
timer_b_red_line	dc.w	4*13-1

timer_b_top
	move.w	bgCol,$ffff8240	

	tst.w	timer_b_red_line
	ble		.timer_b
		pushd0
		clr.b   $fffffa1b.w         	
		move.l	#timer_b_red,$120	; schedule timer b to open lower
		move.w	timer_b_red_line,d0
		move.b  d0,$fffffa21.w        
		move.b  #8,$fffffa1b.w   
		popd0
		REPT 80/2
			or.l	d7,d7
		ENDR
		move.w	#0,$ffff8240
		rte
.timer_b
	cmp.w	#99,timer_b_start
	beq		.timer_b_nb
	pushd0
	move.w	#199,d0
	sub.w	timer_b_start,d0
	sub.w	timer_b_start,d0
	clr.b   $fffffa1b.w         	
	move.l	#timer_b_bot,$120	; schedule timer b to open lower
	move.b  d0,$fffffa21.w        
	move.b  #8,$fffffa1b.w   
	popd0

	REPT 70/2
		or.l	d7,d7
	ENDR
	move.w	#0,$ffff8240
	rte


.timer_b_nb
	pushd0
	move.w	#199,d0
	sub.w	timer_b_start,d0
	sub.w	timer_b_start,d0
	clr.b   $fffffa1b.w         	
	move.l	#timer_b_bot,$120	; schedule timer b to open lower
	move.b  d0,$fffffa21.w        
	move.b  #8,$fffffa1b.w   
	popd0
	rte	

timer_b_red
	movem.l	d0-d3,-(sp)
	move.w	#199,d0
	sub.w	timer_b_start,d0
	sub.w	timer_b_start,d0
	sub.w	timer_b_red_line,d0
	clr.b   $fffffa1b.w         	
	move.l	#timer_b_bot,$120	; schedule timer b to open lower
	move.b  d0,$fffffa21.w        
	move.b  #8,$fffffa1b.w   
	movem.l	redColors,d0-d3
	movem.l	d0-d3,$ffff8240+8*2
	movem.l	(sp)+,d0-d3
	rte	


timer_b_lines_off	dc.w	0

timer_b_bot
	move.w	bgCol,$ffff8240
	clr.b   $fffffa1b.w         	
	REPT 114/2+1
		or.l	d7,d7
	ENDR
	move.w	#0,$ffff8240
	sub.w	#1,linesPalWaiter
	bge		.herp
		subq.w	#2,palLinesOff
		blt		.noPals
		pusha0
		lea		palLines,a0
		add.w	palLinesOff,a0
		move.w	(a0),bgCol
		move.w	#5,linesPalWaiter
		popa0
		jmp		.herp

.noPals	
		pusha0

		sub.w	#2,timer_b_red_line
		add.w	#2,timer_b_start
		cmp.w	#99,timer_b_start
		ble		.noTi
			move.w	#99,timer_b_start
			move.w	#0,effect3_waiter
.noTi
		popa0
.herp
	rte

effect3_waiter	dc.w	-1


linesPalWaiter	dc.w	5
palLinesOff		dc.w	14



clearLine	
	move.l	screenpointer,a0
	move.w	#199,d0
	sub.w	timer_b_start,d0
	sub.w	timer_b_start,d0
	move.w	timer_b_start,d1
	muls	#160,d1
	add.w	d1,a0
	move.l	a0,a1
	muls	#160,d0
	add.w	d0,a1
	moveq	#0,d1
	add.w	#160,a0
	move.w	#2-1,d7
.l
	move.w	#20-1,d6
.ll
		move.l	d1,-(a0)
		move.l	d1,-(a0)
		move.l	d1,(a1)+
		move.l	d1,(a1)+
		dbra	d6,.ll
	dbra	d7,.l
	rts


copyImage
	move.l	screenpointer,a0
	add.l	#201*160,a0
	add.w	#128,a0
	move.l	screenpointer,a1
	move.w	#200-1,d7
.loop
	REPT 20
		move.l	(a0)+,(a1)+
		move.l	(a0)+,(a1)+
	ENDR
	dbra	d7,.loop
	rts

clearScreen
	nop
	move.l	screenpointer,a0
	add.w	#160*200,a0
	moveq	#0,d0
	move.l	d0,d1
	move.l	d0,d2
	move.l	d0,d3
	move.l	d0,d4
	move.l	d0,d5
	move.l	d0,d6
	move.l	d0,a1
	move.l	d0,a2
	move.l	d0,a3
	move.l	d0,a4
	move.l	d0,a5			;12 * 4 =48
	move.w	#66-1,d7
.loop
	REPT 10								; 10*48 = 480 * 66= 31680
		movem.l	d0-d6/a1-a5,-(a0)
	ENDR
	dbra	d7,.loop		;31680 done, 320 left, 320/48 = 7
	REPT 7
		movem.l	d0-d6/a1-a5,-(a0)
	ENDR
	move.w	#$4e75,clearScreen
	rts


actionListOffset	dc.w	0

amigaAtariCode
	lea		music,a3
	moveq	#0,d0
	move.b	$b8(a3),d0
	move.b	#0,$b8(a3)
	cmp.w	#1,d0
	bne		.ok

	move.l	screenpointer,a0			;dest
	add.w	#114*160,a0
	lea		atari,a2
	lea		actionList,a1
	add.w	actionListOffset,a1

	move.w	(a1)+,d0			; offset
	add.w	d0,a2
	add.w	#64,d0
	add.w	d0,a0

	move.w	(a1)+,d0			; y offset
	beq		.do22
		move.w	d0,d1
		muls	#96,d0
		add.w	d0,a2
		muls	#160,d1
		add.w	d1,a0
.do32
	move.w	#32-1,d7
	jmp		.go
.do22
	move.w	#22-1,d7
.go	
		move.l	(a2)+,(a0)+
		move.l	(a2)+,(a0)+
		move.l	(a2)+,(a0)+
		move.l	(a2)+,(a0)+
		lea		160-64-16(a2),a2
		lea		160-16(a0),a0
	dbra	d7,.go
	add.w	#4,actionListOffset
	cmp.w	#16*4,actionListOffset
	bne		.ok
		move.w	#$4e75,amigaAtariCode
		move.w	#0,actionListOffset
.ok
	rts

;smfx	incbin	"gfx/smfx.neo"

;smfxBuffer	ds.b	9*8*75			;5400

;prepSmfx
;	lea		smfx+128,a0
;	lea		smfxBuffer,a1
;.y set 0
;	REPT 75
;.x set .y
;		REPT 9
;			move.l	.x(a0),(a1)+
;			move.l	.x+4(a0),(a1)+
;.x set .x+8
;		ENDR
;.y set .y+160
;	ENDR	
;	lea		smfxBuffer,a0
;	move.b	#0,$ffffc123
;	rts



; 2	2 	2	3
;----------------
;1	|9	|5	|12	|
;----------------
;8	|2	|10	|4	|
;----------------
;6	|7	|3	|11	|
;----------------


actionList2_12	
	dc.w	0,0,1			; x,y
	dc.w	1,1,1
	dc.w	2,2,1
	dc.w	3,1,0
	dc.w	2,0,1
	dc.w	0,2,1
	dc.w	1,2,1
	dc.w	0,1,1
	dc.w	1,0,1
	dc.w	2,1,1
	dc.w	3,2,0
	dc.w	3,0,0

smfxCode
	cmp.w	#$4e75,amigaAtariCode
	bne		.end
		lea		music+$b8,a0
		moveq	#0,d0
		move.b	(a0),d0
		beq		.end
			move.b	#0,(a0)
			move.l	screenpointer,a0
			add.w	#49*160,a0
			lea		smfxBuffer,a1
			lea		actionList2_12,a2
			add.w	actionListOffset,a2
			move.w	(a2)+,d0	;x
			lsl.w	#4,d0		;*16
			add.w	d0,a0		
			add.w	d0,a1
			move.w	(a2)+,d0	;y
			move.w	d0,d1
			muls	#160*25,d0
			add.w	d0,a0
			muls	#72*25,d1
			add.w	d1,a1
			move.w	#25-1,d7
			move.w	(a2)+,d6
			bne		.do2
.do3
		
.x set 0
				REPT 3
					move.l	(a1)+,(a0)+
					move.l	(a1)+,(a0)+
.x set .x+8
				ENDR
			lea		72-24(a1),a1
			lea		160-24(a0),a0
			dbra	d7,.do3
			jmp		.continue

.do2
.x set 0
				REPT 2
					move.l	(a1)+,(a0)+
					move.l	(a1)+,(a0)+
.x set .x+8
				ENDR
			lea		72-16(a1),a1
			lea		160-16(a0),a0
			dbra	d7,.do2

.continue
			add.w	#6,actionListOffset
			cmp.w	#12*6,actionListOffset
			bne		.end
				move.w	#$4e75,smfxCode

.end
	rts

updateFontPal
	lea		fontPal2,a0
	lea		fontPal,a1
	move.w	#4-1,d7
.l
	move.l	(a0)+,(a1)+
	dbra	d7,.l
	rts

printText
	nop
	movem.l	fontPal,d0-d3
	movem.l	d0-d3,$ffff8240
	lea		fontBuffer,a0
	move.l	textPointer,a1					; a1 is text
	add.w	textSourcePosition,a1	; offset into text

	moveq	#0,d0					; clear reg
	move.b	(a1),d0					; get value of character
	sub.w	#46,d0					; base on 0

	muls	#13*3,d0

	add.w	d0,a0
	move.l	screenpointer,a3
	add.w	screenOffset,a3
	add.w	yoffset,a3

	move.w	textTargetPosition,d1	; this is the offset into the target screen
	add.w	d1,d1
	lea		shiftOffset,a2
	add.w	d1,a2
	add.w	(a2)+,a3

x set 0
	REPT 13
z set x
		REPT 3
			move.b	(a0)+,z(a3)
z set z+2
		ENDR
x set x+160
	ENDR
	add.w	#1,textSourcePosition
	add.w	#1,textTargetPosition

	subq.w	#1,xtimes
	bgt		.ok
		move.w	#0,textTargetPosition
		move.w	#40,xtimes
		add.w	#13*160,yoffset
		subq.w	#1,ytimes
		bgt		.ok
			move.w	#$4e75,printText
			move.w	#$4e75,doTextHighLight
.ok
	rts

doTextHighLight
	nop
	move.l	screenpointer,a0
	add.w	#3*13*160,a0
	move.w	#-1,d0
x set 136+6
	move.w	#13*12-1,d7
.loop
		move.w	d0,x(a0)
		move.w	d0,x+8(a0)
		move.w	d0,x+16(a0)
		lea		160(a0),a0
	dbra	d7,.loop
	rts

yoffset	dc.w	0
xtimes	dc.w	40
ytimes	dc.w	4

textPointer		dc.l	text2
screenOffset	dc.w	80*160


textSourcePosition	dc.w	0
textTargetPosition	dc.w	0


	SECTION DATA

; screens in data, so we use one screen to store all image shit to save sapce
				ds.b	256
screen1			ds.b	276*160+256			;44160		; 44160; 32000 for screen
											;32000-		;		12160 left for amiga unpack
											;12160		;		32128 is amig aunpack size: 20k LEFT
											;--> 32128	;
											;19968 needed
											;19159					;;---> 44160
				ds.b	970					; 44160-970 = 43190	- 19160 = 24030
amigacrk		incbin	"gfx/amiga.crk"					; 20000				19k				19159 packed	32128 unpacked		; 22k done
											; 24030 left....
				even
atari
				ds.b	3300							; 24030 - 3300 = 20730 - 4960 = 15770
ataricrk		incbin 	"gfx/atari2.crk"				; 4960  packed  8256 unpacked
				even
				ds.b	16972-160-600-64-80-16-84-NUMBER_OF_LINES*8-5496 ;
						;120 + 600 + 64 + 1950 + 80 + 16 + 84 + 2048 = 4962


smfxBuffer	incbin	"gfx/smfx.bin"


text2
			dc.b	"______________WHAT_IS_THIS;_____________"		;120
			dc.b	"_______A_CHECKERBOARD_COMPETITION;______"			
			dc.b	"________________________________________"	;13			
			dc.b	"___________CHALLENGE_ACCEPTED:__________"			

text			
			dc.b	"????????????????????????????????????????"
			dc.b	"__________AMIGA_______ATARI_ST____POWER_"
			dc.b	"????????????????????????????????????????"
			dc.b	"CPU_______7_MHZ_______8_MHZ_______PASS__"
			dc.b	"PIXELS____320^256_____320^200_____FAIL__"
			dc.b	"OVERSCAN__YES_[X]Y\___NO__________FAIL__"
			dc.b	"BITPLANES_5_OR_6______4___________FAIL__"
			dc.b	"COLORS____32_OR_64____16__________FAIL__"
			dc.b	"PALETTE___4096________512_________FAIL__"
			dc.b	"RASTERS___HARDWARE____SOFTWARE____FAIL__"
			dc.b	"SCR_SPLIT_HARDWARE____NO__________FAIL__"
			dc.b	"SCROLLING_HARDWARE____NO__________FAIL__"
			dc.b	"SPRITES___YES_________NO__________FAIL__"
			dc.b	"BLITTER___YES_________NO__________FAIL__"
			dc.b	"SOUNDCHIP_PAULA_______YM_2149_____FAIL__"			;600

text3		dc.b	"_________ATARI_AINT_NO_COMMODORE________"	;80
			dc.b	"___AND_YET_WE_HAVE_COMPETED_FOR_AGES____"			

actionList																;64
	dc.w	0,22	;1
	dc.w	16,54	;2
	dc.w	32,22	;3
	dc.w	48,54	;4
	dc.w	48,0	;5
	dc.w	64,22	;6
	dc.w	80,54	;7
	dc.w	80,0	;8
	dc.w	80,22	;9
	dc.w	64,54	;10
	dc.w	64,0	;11
	dc.w	48,22	;12
	dc.w	32,0	;13
	dc.w	32,54	;14
	dc.w	16,22	;15
	dc.w	0,54	;16

; TODO: genreate this
myHaxList									; when done together thisis: 256*8 = 2048 b
o set 0
x set 0
	REPT NUMBER_OF_LINES					;214*8
		dc.w	(-o+160*2)*3
		dc.w	x
		dc.w	x
		dc.w	(-o+160*2)*3
o set o+2
x set x+160
	ENDR

myXposList_start
;	include	data/offset16Vertable.s
	include	data/offset16Vertable2.s							;2680
; 22*16*8		= 2816 --> 										;2816 => 5496
; move this to lower; free ze bytes!
myXposList
x set 20+2*7
	REPT 22
bufferoff	set 0
		REPT 16
			dc.l	x+bufferoff
			dc.l	x+bufferoff
bufferoff	set bufferoff+40*2*2*NUMBER_OF_LINES
		ENDR	
x set x-2
	ENDR
myXposList_end
endscreen

fontBuffer		incbin	"gfx/font3bpl.bin"						;1950

fontPal															;16
		dc.w	$000,$201,$312,$422,$532,$543,$554,$565
fontPal2
		dc.w	$000,$223,$334,$434,$544,$655,$765,$777

shiftOffset								; 21 * 4 = 84b
x set 0
	REPT 21
		dc.w	x
		dc.w	x+1
x set x+8
	ENDR


text4

			dc.b	"___INTERLEAVED_BITPLANES_ARE_A_BITCH____"	;0
			dc.b	"________________________________________"	;1
			dc.b	"BUT_WHAT_WE_LACK_IN_HARDWARE_WE_MAKE_UP_"	;2
			dc.b	"______WITH_STUBBORNESS_AND_SKILLS_______"	;3
			dc.b	"________________________________________"	;4
			dc.b	"_EVERY_ATARIAN_WILL_CLAIM_THAT_THEY_CAN_"	;5
			dc.b	"MATCH_ANY_AMIGA_EFFECT_OR_EVEN_DO_BETTER"	;6
			dc.b	"________________________________________"	;7
			dc.b	"AND_WE_HAVE_SPEND_MANY_YEARS_TRYING_TO__"	;8
			dc.b	"____TURN_THIS_IDLE_HOPE_INTO_REALITY____"	;9
			dc.b	"________________________________________"	;10
			dc.b	"LETS_SEE_HOW_CLOSE_WE_CAN_GET_THIS_TIME_"	;11
			dc.b	"________________________________________"	;12
			dc.b	"________________________________________"	;13
			dc.b	"________________________________________"	;14
			dc.b	"________________________________________"	;15


text5	
			dc.b	"_NO_BLITTER_NO_PER_SCANLINE_ADDRESSING__"	;0
			dc.b	"___________WHAT_ARE_WE_TO_DO;___________"	;1
			dc.b	"________________________________________"	;2
			dc.b	"WE_SALUTE_OUR_AMIGA_6_BITPLANE_OVERLORDS"	;4
			dc.b	"________________________________________"	;7
			dc.b	"SCOOPEX_GHOSTOWN_LEMON=_DEKADENCE_OXYRON"	;5
			dc.b	"___INSANE_SPACEBALLS_LOONIES_PACIF:C____"	;6
			dc.b	"________________________________________"	;7
			dc.b	"________________________________________"	;7
			dc.b	"_________THE_ENEMY_OF_CREATIVITY________"	;9
			dc.b	"______IS_THE_ABSENCE_OF_LIMITATIONS_____"	;10
			dc.b	"________________________________________"	;11
			dc.b	"_________BE_COOL_STAY_OLDSCHOOL_________"	;12
			dc.b	"________________________________________"	;13
			dc.b	"________________________________________"	;13
			dc.b	"________________________________________"	;14
			dc.b	"________________________________________"	;15


	include		lib/cranker.s			; thnx amiga :)
	even

	IFEQ	GENERATEFONT
prepFont
	lea		font+128,a0
	lea		fontBuffer,a1
	; its organized 8x13, we will organize them
	move.w	#20-1,d7
.loop
y set 0
	REPT 13
		move.b	y+0(a0),(a1)+
		move.b	y+2(a0),(a1)+
		move.b	y+4(a0),(a1)+
y set y+160
	ENDR
	add.w	#1,a0
y set 0
	REPT 13
		move.b	y+0(a0),(a1)+
		move.b	y+2(a0),(a1)+
		move.b	y+4(a0),(a1)+
y set y+160
	ENDR
	add.w	#7,a0
	dbra	d7,.loop
	; first 40 chars done
	add.w	#12*160,a0	; 12 lines left to skip
	move.w	#5-1,d7
.loop2
y set 0
	REPT 13
		move.b	y+0(a0),(a1)+
		move.b	y+2(a0),(a1)+
		move.b	y+4(a0),(a1)+
y set y+160
	ENDR
	add.w	#1,a0
y set 0
	REPT 13
		move.b	y+0(a0),(a1)+
		move.b	y+2(a0),(a1)+
		move.b	y+4(a0),(a1)+
y set y+160
	ENDR
	add.w	#7,a0
	dbra	d7,.loop2
	lea		fontBuffer,a0
	move.b	#0,$ffffc123

	rts
font			incbin	"gfx/6x4c.neo"		
	ENDC

copyXoffAndXPosList
	lea		myXposList,a0
	lea		myXposList2,a1

	move.l	#myXposList_end,d0
	sub.l	a0,d0
	lsr.w	#1,d0
	subq.w	#1,d0
.loop
		move.w	(a0)+,(a1)+				; copy the x table
	dbra	d0,.loop

	lea		myXposList_start,a0
	lea		myXposList,a1
	move.l	a1,d0
	sub.l	a0,d0
	lsr.w	#1,d0
	subq.w	#1,d0
	lea		myXposList2,a0
.loop2
		move.w	-(a1),-(a0)				; xopy the y table
	dbra	d0,.loop2
	rts

	SECTION DATA
calcAndSetColor	macro
	lsr.w	#3,d0		; shift down 8
	sub.w	#30,d0		; remove 30
	divs	#14,d0		; divide by 10
	add.w	d0,d0
	move.w	(a0,d0),(a1)+	; first color
	endm

generatePaletteColors
	lea		paletteColors_Zoom,a0
	lea		zoomPalette,a1
	lea		checkerSizesList0,a2
	lea		checkerSizesList1,a3
	lea		checkerSizesList2,a4
	lea		checkerSizesList5,a5
	lea		checkerSizesList3,a6
	move.l	a6,d1
	move.l	#checkerSizesList4,d6

	move.w	#40-1,d7
.loop
	moveq	#0,d0
	move.w	(a2)+,d0	; get current offset
			calcAndSetColor
	moveq	#0,d0
	move.w	(a3)+,d0
			calcAndSetColor
	moveq	#0,d0
	move.w	(a4)+,d0
			calcAndSetColor
	moveq	#0,d0
	move.w	(a5)+,d0
			calcAndSetColor
	move.l	d1,a6
	moveq	#0,d0
	move.w	(a6)+,d0
	move.l	a6,d1
			calcAndSetColor
	move.l	d6,a6
	moveq	#0,d0
	move.w	(a6)+,d0
	move.l	a6,d6
			calcAndSetColor
	move.w	#0,(a1)+
	dbra	d7,.loop
	rts

zoomPalette		ds.w	40*7*8

paletteColors_Zoom
	dc.w	$001			;0
	dc.w	$101			;1
	dc.w	$102			;2
	dc.w	$202			;3
	dc.w	$302			;4
	dc.w	$403			;5
	dc.w	$503			;6
	dc.w	$502			;7
	dc.w	$501			;8
	dc.w	$601			;9
	dc.w	$611			;10
	dc.w	$621			;11
	dc.w	$631			;12		
	dc.w	$731			;13	
	dc.w	$741			;14	
	dc.w	$751			;15
	dc.w	$751			;16
	dc.w	$752			;17
	dc.w	$753			;18
	dc.w	$763			;19
	dc.w	$773			;20	
	dc.w	$774			;21
	dc.w	$775			;22
	dc.w	$776			;23
	dc.w	$777			;24
	dc.w	$777			;24
	dc.w	$777			;24
	dc.w	$777			;24


lines	
	include		data/lines7.s								

	include		lib.s

deltaMoveY
	include		"data/resulty.s"

deltaMove
	include		"data/resultx.s"

paletteOrder
	dc.w	0
	dc.w	2
	dc.w	4
	dc.w	6
	dc.w	8
	dc.w	10

endFade
	dc.w	$000
	rept 15
		dc.w	$112
	endr

palLines														;16
	dc.w	$112
	dc.w	$224
	dc.w	$445
	dc.w	$667
	dc.w	$445
	dc.w	$223
	dc.w	$112
	dc.w	$000

paletteFadeWaiter			dc.w	10
paletteFadeWaiterReverse	dc.w	900	

paletteColorsOff	dc.w	7*14
zoomPaletteOff		dc.w	10*7*2

sixPlanesPalette
zoomNoFadeRout
	movem.w	paletteOrder,d0-d5	; order
	lea		zoomPalette,a1
	add.w	zoomPaletteOff,a1
	add.w	paletteColorsOff,a1

	subq.w	#1,paletteFadeWaiter
	bge		.kk
		move.w	#10,paletteFadeWaiter
		sub.w	#7*40*2,paletteColorsOff
		bge		.kk
			move.w	#0,paletteColorsOff
.kk
	add.w	#7*2,zoomPaletteOff
	cmp.w	#7*2*40,zoomPaletteOff
	bne		.okx
		move.w	#0,zoomPaletteOff
.okx
	lea		$ffff8242,a2

	move.w	(a1)+,d0
	move.w	(a1)+,d1
	move.w	(a1)+,d2
	move.w	(a1)+,d3
	move.w	(a1)+,d4
	move.w	(a1)+,d5

	move.w	d0,(a2)+			; l1 = c1
	move.w	d1,(a2)+			; l2 = c2,c3
	move.w	d1,(a2)+
	move.w	d2,(a2)+			; l3 = c4,c5
	move.w	d2,(a2)+
	move.w	d3,(a2)+			; l4 = c6,c7
	move.w	d3,(a2)+

	move.w	d4,(a2)+			; l5 = c8
	move.w	d5,(a2)+			; l6 = c9
	move.w	d4,(a2)+
	move.w	d5,(a2)+			
	move.w	d4,(a2)+
	move.w	d5,(a2)+			
	move.w	d4,(a2)+
	move.w	d5,(a2)+	

	subq.w	#1,paltimes
	bgt		.ok
			movem.w	paletteOrder,d0-d5
			move.w	d5,paletteOrder
			movem.w	d0-d4,paletteOrder+2
		move.w	#STEPS,paltimes
.ok
	lea		$ffff8240,a0
	lea		currentPalette,a1
	rept 8
		move.l	(a0)+,(a1)+
	endr	
	move.w	12(a1),currentPalette
	rts

paltimes	dc.w	STEPS-10

music			incbin	"msx/2f.snd"
textShitBuffer	incbin	"gfx/overlay3.bin"

palette
	dc.w	$001
	dc.w	$002
	dc.w	$112
	dc.w	$113
	dc.w	$223
	dc.w	$224
	dc.w	$334
	dc.w	$335
	dc.w	$445
	dc.w	$446
	dc.w	$556
	dc.w	$557
	dc.w	$777

	SECTION BSS
; general stuff
	IFEQ	STANDALONE
screenpointer				ds.l	1
screenpointer2				ds.l	1

; drawList structure pointers, this is the stuff that is in higher memory, and represent a 
; 50 entry list of poitners to lower memory for frame calculation and scanline generation, but also copying
; this needs to have 2 versions, a producer pointer list and a consumer pointer list
; where the producer are:;
;	- sorting/smallest number code
;	- scanline generation code
; consumer is:
;	- copying line code
currentDrawListPointer_producer		ds.l	1
backupDrawListPointer1_producer		ds.l	1
backupDrawListPointer2_producer		ds.l	1
backupDrawListPointer3_producer		ds.l	1
currentScreenPointer_producer		ds.l	1
backupsScreenPointer_producer		ds.l	1

currentDrawListPointer_consumer		ds.l	1
backupDrawListPointer1_consumer		ds.l	1
backupDrawListPointer2_consumer		ds.l	1
backupDrawListPointer3_consumer		ds.l	1

drawListPointers					ds.w	50
drawListPointers1					ds.w	50
drawListPointers2					ds.w	50
drawListPointers3					ds.w	50

blackPal							ds.w	16
currentPalette						ds.w	16

myHaxListPointer					ds.l	1

storedLower							ds.b	30

my16versions						ds.b	40*2*2*NUMBER_OF_LINES*16
	ENDC
