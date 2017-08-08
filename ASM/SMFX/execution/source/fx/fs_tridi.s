;		- but then the normals and the colornormals are desed for screen screen3 as well, and it takes 2 frames to display
;			- so we need to ahve a normalpaletts double buffer, so its delayed one frame
;
; - sequencing of objects
;	- List of objects, and their times
;
; - move object according to timer a (height)
;
; todo:
;	- generate clear routs
;	- generate fill routs


	IFD DEMOSYSTEM
		IFD	STANDALONE
		ELSE
STANDALONE 					equ 1
		ENDC
	ELSE
STANDALONE					equ 0
	ENDC


	IFEQ STANDALONE
TRUE 						equ 0
true 						equ 0
FALSE 						equ 1
false 						equ 1
FRAMECOUNT					equ 1
benchmark					equ false	
PLAYMUSIC					equ 1
playmusicinvbl				equ 1
rasters 					equ true
useym						equ true
	ENDC




realclear					equ true
timer_b						equ true
lowerMemSize				equ 	$10000-lowerMemStart
lowerMemStart				equ		$600
max_nr_vertices				equ 	100		; do we need more than 100?
vertice_size				equ		6		; visibility,x,y
max_nr_edges				equ		50		; do we need more than 50?		
edge_size					equ		6		; visiblity,vertex1,vertex2
max_nr_faces				equ		40		; do we need more than 40?
face_size					equ		20		; just a guess
curLowerMemory				set		lowerMemStart											;$600
projectedVertices			equ		curLowerMemory											;$600 with $256 size
curLowerMemory 				set 	curLowerMemory+max_nr_vertices*vertice_size				;$600+$256
eorEdgesLower				equ		curLowerMemory											;$856 with $128 size
curLowerMemory				set		curLowerMemory+max_nr_edges*edge_size					;$856+$128
;cullVerticesLower			equ		curLowerMemory											;$980 with $256 size
;curLowerMemory				set		curLowerMemory+max_nr_cullvertices*cullvertices_size	;$980+$256
eorFacesLower				equ		curLowerMemory											;$1236 with $320 size
curLowerMemory				set		curLowerMemory+max_nr_faces*face_size					;$1556

pps equ projectedVertices			; $1000


scanLineWidth				equ 230


; optcul = 1, lower = 0: 773 frames
; optcul = 1, lower = 1: 742 frames
; optcul = 0, lower = 1: 680 frames
; optcul = 0, lower = 0: 723 frames
; mask1: 222		; lower=off
; mask2: 213		; lower=off
; mask3: 176		; lower=off
; mask4: 223		; lower=off

optcul				equ TRUE				; this is overloaded, TRUE implies: DONT mark vertices, MARK edges, and use faces based on eoredges, instead of directed edges
old					equ 1
    section	TEXT

    IFEQ	STANDALONE
	include ../lib/macro.s
		allocateStackAndShrink								; stack + superexec
	; INIT SETUP CODE ---------------------------------------
	jsr	saveAndKillTimers									; kill timers and save them
	jsr	disableMouse										; turn off mouse
	jsr	backupPalAndScrMemAndResolutionAndSetLowRes			; save screen address and other display properties
	jsr	checkMachineTypeAndSetStuff							; check machine type, disable cache
	jsr	setScreen64kAligned									; set 2 screens at 64k aligned
	jmp	.yes
	ds.b	2<<8											; such that we dont have code that's being executed in our lower memory
.yes




.init
    jsr		init_aligned_blocks								; initialize the common pointers for the memory area

	move.w	#$2700,sr										; 
	move.l 	#default_vbl,$70								; set default vbl
	move.w	#$2300,sr										; 
;	; END SET DEFAULT ---------------------------------------
;


	jsr		music_ym_init
	jsr		tridi_eor_prec




	;----- DO EFFECT ----------------------------------------
waitloop				
	IFEQ benchmark									;
		subq.l	#1,_turbocounter
		bne		waitloop
		moveq	#0,d0
		move.w	_vblcounter,d0
		move.b	#0,$ffffc123
	ENDC
	cmp.b 	#$39,$fffffc02.w								; spacebar to exit
	bne		waitloop										;
	;----- END ----------------------------------------------
.exit

	move.w	#$2700,sr
	move.l	#dummyvbl,$70.w				;Install our own VBL
	move.l	#dummy,$68.w				;Install our own HBL (dummy)
	move.l	#dummy,$134.w				;Install our own Timer A (dummy)
	move.l	#dummy,$120.w				;Install our own Timer B
	move.l	#dummy,$114.w	ss			;Install our own Timer C (dummy)
	move.l	#dummy,$110.w				;Install our own Timer D (dummy)
	move.l	#dummy,$118.w				;Install our own ACIA (dummy)
	clr.b	$fffffa07.w					;Interrupt enable A (Timer-A & B)
	clr.b	$fffffa13.w					;Interrupt mask A (Timer-A & B)
	clr.b	$fffffa09.w					;Interrupt enable B (Timer-C & D)
	clr.b	$fffffa15.w					;Interrupt mask B (Timer-C & D)
	move.w	#$2300,sr

;	jsr	restoreLowerMem
	jsr restoresForMachineTypes
	jsr	restorePalAndScreenMemAndResolution
	jsr	stopMusic
	jsr	restoreTimers
	jsr	enableMouse
	rts

; ***************************************** END MAINLOOP ************
;;;;;;;;;;;;;;;;;;;;;;;; VBL / DISPLAY CODE ;;;;;;;;;;;;;;;;;;;;;;;;;	
		even
swapscreens_c2p:
	move.l	screenpointer,d0
	move.l	screenpointer2,screenpointer
	move.l	screenpointer3,screenpointer2
	move.l	d0,screenpointer3
	rts	


		ENDC
_timer_b_place	dc.w	1

tridi_eor_prec
	; INIT TRIDI STUFF --------------------------------------
	jsr		tridi_effect_eor_prec_init							; init the tridi effect
	jsr		genXTableFill

		jsr	setCubeObject
		jsr	initObject

;	jsr		prepRealTime
	move.l	screenpointer2,oldPointer

	move.l	screenpointer,a0
	move.l	screenpointer2,a1
	move.l	screenpointer3,a2
	move.w	#254-1,d7
	moveq	#0,d0
.ol
		REPT 27
			move.l	d0,(a0)+
			move.l	d0,(a0)+
			move.l	d0,(a1)+
			move.l	d0,(a1)+
			move.l	d0,(a2)+
			move.l	d0,(a2)+
		ENDR

	dbra	d7,.ol


	move.w	#21*50,framecounter
	; END TRIDI INIT ----------------------------------------
	swapscreens												; because of ....
	move.w	#$2700,sr										;
;	move.l	#tridi_effect_eor_prec,$70							; set effect vbl
	move.l	#tridi_effect_eor_prec_mainloop,$70							; set effect vbl
	clr.b	$fffffa1b.w				;Timer B control (stop)
	move.l	#timer_a_opentop_tridi,$134.w			;Install our own Timer A
	move.l	#timer_b_fullscreen,$120.w			;Install our own Timer B
	bset	#0,$fffffa07.w			;Interrupt enable A (Timer B)
	bset	#0,$fffffa13.w			;Interrupt mask A (Timer B)
    move.b  #1,$fffffa21.w        ;Timer B data (number of scanlines to next interrupt)
	bclr	#3,$fffffa17.w			;Automatic end of interrupt
	move.b	#8,$fffffa1b.w			;Timer B control (event mode (HBL))
	move.w	#$2300,sr


.wait
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; mainloop
			wait_for_vbl
	move.w	#$0,$ffff8240
	jsr		checkLowerBorder
	jsr		doPalette_tridi
	jsr		copyRealTime
	move.w	_oldx,_olderx

	jsr		advanceRotationStep	

	jsr		morph								;
	jsr		calculateRotatedProjectionExpLogMatrix
	jsr		calculateRotatedProjectionExpLog					; calculate new vertices projection for new step
	jsr		cullByNormals
	jsr		clear4BPL
	jsr		drawEorLines									; draw the edges for eor-filling


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	subq.w	#1,tridiframes
	cmp.w	#255,tridiframes
	bne		.ok
		move.w	#-1,nextScene
		move.l	#tmpVbl,$70
.ok

	move.l	_paletteNormalPointer,d0
	move.l	_paletteNormalPointer2,_paletteNormalPointer
	move.l	d0,_paletteNormalPointer2

.waitfill
	tst.w	filldone
	bne		.waitfill
	move.w	#-1,filldone
	jsr		moveObject										; we move our object
	jsr		swapscreens_c2p
	jsr		calcOffset
	jsr		cycleTimerB
	tst.w	nextScene
	beq		.wait

	rts

filldone	dc.w	-1

tridiframes	dc.w	1536-25	;+192+30-92
tmpVbl
	pushall
		jsr		music_ym_play
	popall
	rte

sndhVbl
	pushall
		move.l	sndh_pointer,a0
		jsr		8(a0)
	popall
	rte

_oldery	dc.w	0*4
_olderx	dc.w	scanLineWidth*4

timer_a_opentop_tridi
	move.w	#$2100,sr			;Enable HBL
	stop	#$2100				;Wait for HBL
	move.w	#$2700,sr			;Stop all interrupts
	clr.b	$fffffa19.w			;Stop Timer A
	REPT 42
		or.l	d7,d7
	ENDR

	clr.b	$ffff820a.w			;60 Hz
	REPT 9
		nop
	ENDR
	move.b	#2,$ffff820a.w			;50 Hz
	rte



_timer_b_direction	dc.w	0
changeTimerBOffset	macro
	tst.w	_timer_b_direction
	bne		.up
.down
;	addq.w	#1,_timer_b_place
	cmp.w	#220,_timer_b_place
	beq		.changeUp
	jmp		.done
.up
	subq.w	#1,_timer_b_place
	cmp.w	#2,_timer_b_place
	beq		.changeDown
	jmp		.done

.changeDown
	move.w	#0,_timer_b_direction
	jmp		.done

.changeUp
	move.w	#1,_timer_b_direction
.done
	endm

tridi_effect_eor_prec_mainloop
	move.l	screenpointer2,$ffff8200
			schedule_timerA_topBorder
			changeTimerBOffset
	pushd0
	IF scanLineWidth=160
	ELSE
	clr.b	$fffffa1b.w			;Timer B control (stop)
	bset	#0,$fffffa07.w			;Interrupt enable A (Timer B)
	bset	#0,$fffffa13.w			;Interrupt mask A (Timer B)
	move.w	_timer_b_place,d0
	move.b	d0,$fffffa21.w		;Timer B data (number of scanlines to next interrupt)
	move.b	#8,$fffffa1b.w			;Timer B control (event mode (HBL))
	bclr	#3,$fffffa17.w			;Automatic end of interrupt
	ENDC
	popd0
	addq.w	#1,$466.w		
		pushall
		jsr		music_ym_play
		popall
	rte
hsLeftBorder	macro
	move.b	d7,(a5)					;		move.b	d7,$ffff8260.w			;2 Left border
	move.w	d7,(a5)					;		move.w	d7,$ffff8260.w			;2
	endm
hsRightBorder	macro
	move.w	d7,(a6)					;		move.w	d7,$ffff820a.w			;2 Right border
	nop																		;1
	move.b	d7,(a6)					;		move.b	d7,$ffff820a.w			;2
	endm
hsStabilize	macro
	move.b	d7,(a5)					;		move.b	d7,$ffff8260.w			;2 Stabilizer
	nop
	move.w	d7,(a5)					;		move.w	d7,$ffff8260.w			;2
	endm

terminate	macro
;;;; template
	REPT 142

	hsLeftBorder
	move.w	#$666,$ffff8240
		REPT 90-4
			nop
		ENDR
	hsRightBorder
		REPT 12
			nop
		ENDR
	hsStabilize
		REPT 12
			nop
		ENDR
	ENDR
	move.w	#$333,$ffff8240
	popall
	rte
	endm

timer_b_fullscreen
	clr.b	$fffffa1b.w			;Timer B control (stop)
	pushall


	moveq	#2,d7				;D7 used for the overscan code	;4		1
	lea		$ffff8260,a5										;8		2
	lea		$ffff820a,a6										;8		2
	move.w	_timer_b_place,d2			;3

	move.w	#$2100,sr
	stop	#$2100
	move.w	#$2700,sr	

	moveq	#0,d0
	lea		$ffff8209.w,a0		;Hardsync
	move.b	(a0),d0
	moveq	#127,d1				;
.sync:		
		cmp.b	(a0),d0
	beq.s	.sync				;
	move.b	(a0),d0				;
	sub.b	d0,d1				;
	lsr.l	d1,d1				;

	and.w	#%1,d2						;2
	beq		.special					;2

	rept 17
		nop
	endr

.special
	rept 5
		or.l 	d7,d7
	endr
	IFEQ STANDALONE
		nop
	ENDC
	move.l	screenpointer2,a3										;20			5
	lea		3*160(a3),a3											;8			2
	add.w	object_y_offset3,a3										;16			4

	lea		x_table_eor,a0											;8			3		12 if not pc
	add.w	_vertices_xoff,a0										;20			5
	add.w	_vertices_xoff,a0										;20			5
	move.l	(a0)+,a1												;12			3
	add.l	(a0)+,a3												;16			4

	add.l	_savedy,a3												;20			6		24 if not pc
	lea		scanLineWidth(a3),a4									;8			2
	jmp		(a1)													;8			2 --> 35 nops



checkLowerBorder
	move.w	place3,d0		; timer b place
	sub.w	#55+31,d0
	blt		.end
		add.w	#1,d0
		; here we have shizzle
		lea		x_table_eor,a0											;8			3		12 if not pc
		add.w	_vertices_xoff,a0										;20			5
		add.w	_vertices_xoff,a0										;20			5
		move.l	(a0)+,a0			; base line
		add.w	d0,d0
		add.w	d0,d0
		neg.w	d0
		move.l	(a0,d0.w),a0		; target label
		move.l	a0,d0
		add.w	#4,d0
		move.l	d0,d1
		add.w	#4,d1

		move.l	4(a0),restoreContents1+2		; contents
		move.l	8(a0),restoreContents2+2		; contents
		move.l	d0,restoreContents1+6
		move.l	d1,restoreContents2+6
		move.w	#$4EF9,4(a0)
		move.l	#lowerBorder,6(a0)
		move.l	a0,thejump+2
.end
	rts
	; at least 1 = 3
	; 142 lines = 145
	; so 45


; approach;
;	-> determine where to open border
;	-> smc the stuff one line before
;
;		____. left border opening
;	  /
;-----|-------------line before
;---------- lower border cut
;
;

; load label, add 4 (skip left border opening), 
;	save instruction
;	insert jump		jmp(a6)		2 bytes
;

savedAddress		dc.l	0
savedOpcode			ds.b	6

lowerBorder
	REPT 90-3			; - 3 for jump, jump entry
		nop
	ENDR

	hsRightBorder
	REPT 12-1
		nop
	ENDR


		move.b	d7,$ffff8260.w			;3 Stabilizer
		move.w	d7,$ffff8260.w			;3

		dcb.w	8,$4e71
		move.w	d7,$ffff820a.w			;3 left border

		;-----------------------------------

		move.b	d7,$ffff8260.w			;3 lower border
		move.w	d7,$ffff8260.w			;3
		move.b	d7,$ffff820a.w			;3

	REPT 90-14-6-1+3	; - jump
		nop
	ENDR
restoreContents1
		move.l	#$123456,$50000.l			;28 / 7
restoreContents2
		move.l	#$123456,$50000.l				;28 / 7 
;		move.w	#$200,$ffff8240

	hsRightBorder
	REPT 12
		nop
	ENDR
	hsStabilize
	REPT 12-3
		nop
	ENDR
thejump	
	jmp		$123345678		;12



init_aligned_blocks
	move.l	screenpointer2,d0
	add.l	#$10000,d0
	move.l	d0,alignpointer1
	add.l	#$10000,d0
	move.l	d0,alignpointer2
	add.l	#$10000,d0
	move.l	d0,alignpointer3
	add.l	#$10000,d0
	move.l	d0,alignpointer4
	add.l	#$10000,d0
	move.l	d0,alignpointer5
	add.l	#$10000,d0
	move.l	d0,alignpointer6
	add.l	#$10000,d0
	move.l	d0,alignpointer7
	add.l	#$10000,d0
	move.l	d0,alignpointer8
	add.l	#$10000,d0
	move.l	d0,alignpointer9
	add.l	#$10000,d0
	move.l	d0,alignpointer10
	add.l	#$10000,d0
	rts

init_yblock_aligned_fs
	move.l	y_block_pointer_fs,a1
	move.l	#200-1,d7
	moveq	#0,d0
	move.w	#scanLineWidth,d6
	swap	d6
	move.w	#scanLineWidth,d6
.loop
	move.l	d0,(a1)+
	add.l	d6,d0
	dbra	d7,.loop
	rts


clearPoint
	move.l	#16384/4/4/4/4-1,d7
	moveq	#0,d0
.cl
	REPT 256
		move.l	d0,(a0)+
	ENDR
	dbra	d7,.cl
	rts


tridi_effect_eor_prec_init
	; TRIDI INIT --------------------------------------------
	move.l	alignpointer3,a0
	jsr		clearPoint
	move.l	alignpointer4,a0
	jsr		clearPoint
	move.l	alignpointer5,a0
	jsr		clearPoint


	move.l	alignpointer1,screenpointer3

	move.l	alignpointer2,y_block_pointer_fs
	move.l	alignpointer3,explog_logpointer
	move.l	alignpointer5,explog_expointer
	move.l	alignpointer9,rotation_perspectivePointer
	;	move.l	explog_logpointer,d0
	;	add.l	#2048,d0
	move.l	alignpointer8,divtablepointer					; 2 big
	move.l	alignpointer10,lowerMemStore
	jsr		copyAndClearLowerMem

    jsr		initEorPointers									; initialize pointers for the eor filling stuff

 	jsr		init_yblock_aligned_fs								; make some 64k aligned boundary for y block 
 	jsr		init_exp_log									; initalize exp-log tables also in lower memory
	jsr		initZTable										; initalize z-table
   
	jsr		initDivTable									; initialize the divtable

	move.w	#8,_stepSpeedX									; x-rotation speed
	move.w	#4,_stepSpeedY									; y-rotation speed
	move.w	#2,_stepSpeedZ									; z-rotation speed

	; 54 min; 252 max
;	move.w	#54*4,_vertices_xoff							; offset for x
	move.w	#(418/2+80)*4,_vertices_xoff
	move.w	#0,_currentStepX

	move.w	_vertices_xoff,_oldx

	move.w	#70*4,_vertices_yoff							; offset for y


	; TRIDI INIT END ----------------------------------------
	rts

magicYOff	dc.w	0


copyAndClearLowerMem
	lea		lowerMemStart,a0
	move.l	lowerMemStore,a1
	move.w	#16384/4/4/4-1,d7
.copy	
	REPT 64
	move.l	(a0)+,(a1)+
	ENDR
	dbra	d7,.copy
	move.w	#$4e75,copyAndClearLowerMem
	rts

restoreLowerMem
	move.l	lowerMemStore,a0
	lea		lowerMemStart,a1
	move.w	#16384/4/4/4-1,d7
.copyBack
	REPT 64
	move.l	(a0)+,(a1)+
	ENDR
	dbra	d7,.copyBack
	rts


doRaster macro
	IFEQ rasters
	move.w	#\1,$ffff8240
	ENDC
	endm

objectWaiter	dc.w	200



_morphSize		dc.w	0
_morphDirection	dc.w	1
_morphWaiter	dc.w	790

morph	
	subq.w	#1,_morphWaiter
	bge		.nono

	move.l	currentMorphRout,a0
	tst.w	_morphDirection
	bgt		.plus
.minus
		jsr	morphStepMinus
		jmp	(a0)
.plus
		jsr	morphStepPlus
		jmp	(a0)
.nono
	rts


morphStepPlus
 	move.w	_morphSize,d0
 	cmp.w	_morphSize_max,d0
 	beq		.flip
 		add.w	#1,d0
 		move.w	d0,_morphSize
 		rts
.flip
	neg.w	_morphDirection
 	rts

morphStepMinus
 	move.w	_morphSize,d0
 	cmp.w	#1,d0
 	beq		.flip
 		subq.w	#1,d0
 		move.w	d0,_morphSize
 		rts
.flip
	neg.w	_morphDirection
 	rts 

ytab
yyy set 0
	rept 200
		dc.w	yyy
yyy set yyy+160
	endr

_diry		dc.w	0
_dirx		dc.w	0
_oldy		dc.w	0
_oldx		dc.w	0

_timer_b_place2	dc.w	1
_timer_b_place3	dc.w	1
_timer_b_place4	dc.w	1
_timer_b_place5	dc.w	1
_timer_b_place6	dc.w	1
object_y_offset2	dc.w	0
object_y_offset3	dc.w	00
object_y_offset4	dc.w	00
object_y_offset5	dc.w	00

place4	dc.w	0
place3	dc.w	0
place2	dc.w	0
place1	dc.w	0

_vertices_xoff4	dc.w	0
_vertices_xoff3	dc.w	0
_vertices_xoff2	dc.w	0
_vertices_xoff1	dc.w	0

cycleTimerB
	move.w	_timer_b_place2,_timer_b_place					;6
	move.w	_timer_b_place3,_timer_b_place2					;6
	move.w	_timer_b_place4,_timer_b_place3					;6
	move.w	object_y_offset2,object_y_offset				;6
	move.w	object_y_offset3,object_y_offset2				;6
	move.w	object_y_offset4,object_y_offset3				;6
	move.w	object_y_offset5,object_y_offset4				;6			==> 42 nops

	move.w	place2,place3
	move.w	place1,place2
	move.w	place,place1
	rts

calcOffset
	move.w	place,d0
	move.w	d0,_timer_b_place4
	subq.w	#1,d0
	add.w	d0,d0
	lea		ytab,a0
	move.w	(a0,d0.w),object_y_offset5
	rts

oldplace	dc.w	0

moveObject
	move.w	place,oldplace
	move.w	_diry,d0
	beq		.upy
.downy
	move.w	place,d0
	add.w	#1,d0
	move.w	d0,place
	cmp.w	#84+32,d0
	blt		.ok
	move.w	#0,_diry
	jmp		.ok
.upy
	move.w	place,d0
	sub.w	#1,d0
	move.w	d0,place
	cmp.w	#1,d0
	bgt		.ok
		move.w	#1,_diry
.ok


	move.w	_dirx,d0
	beq		.leftx
.rightx
	move.w	_vertices_xoff,d0
	move.w	d0,_oldx
	addq.w	#8,d0
	move.w	d0,_vertices_xoff
	cmp.w	#383*4,d0
	blt		.done
	move.w	#0,_dirx
	neg.w	_stepSpeedX
	jmp		.done
.leftx
	move.w	_vertices_xoff,d0
	move.w	d0,_oldx
	subq.w	#8,d0
	move.w	d0,_vertices_xoff
	cmp.w	#70*4,d0
	bgt		.done
	neg.w	_stepSpeedX
	move.w	#1,_dirx
.done
	rts
zzzz	dc.w	20


place	dc.w	55+20

noMorph
	rts

dummyNew
	rte

copyRealTime
	move.l	oldPointer,a2						;16			4
	move.l	screenpointer,a0					;20			5
	add.w	#3*160+120*230,a0					;8			2
	add.w	object_y_offset2,a0					;16			4
	move.w	_timer_b_place,d0					;12			3

	add.w	d0,d0
	move.w	d0,d1	;2
	add.w	d0,d0
	add.w	d0,d1	;2+4
	add.w	d0,d0
	add.w	d0,d0
	add.w	d0,d0
	add.w	d0,d1	;2+4+32
	add.w	d0,d0
	add.w	d0,d1	;2+4+32+64
	add.w	d0,d0
	add.w	d0,d1	;2+4+32+64+128				;48			12

	sub.w	d1,a0								;8			2
	move.l	a0,oldPointer						;20			5
	lea		realtimebuffer,a1					;12			3
	add.w	realtimeOff,a1

	move.w	#0,d0								;8			2
y set 230-64
	REPT 6
o set y
	REPT 5
		move.w	(a1)+,o(a0)						;16			4
		move.w	d0,o(a2)						;12			3	-> 7 
o set o+8
	ENDR
y set y+230
	ENDR

	

	rts

realtimeOff	dc.w	0

oldPointer	dc.l	0

	SECTION DATA
	include		fx/tridi/cube.s
	include		fx/tridi/eorfill_fs.s

	include		fx/tridi/explog.s
	include		fx/tridi/rotation_fs.s


	SECTION DATA

ym_regdump
	incbin		msx/tridi.ym
ym_regdump_end




;;;;;;; YM SHIT
; Atari ST/e synclock demosystem
; January 6, 2008
;
; ym.s
;
; Playback of YM3 files created by various YM-recorders.
; Uses no interupt and not so much CPU.
; About 42k register data per minute music.


music_ym_init:
		move.l	#ym_regdump+4,ym_reg_file_adr
		move.l	#ym_regdump_end-ym_regdump-4,d0
		divu.w	#14,d0
		move.l	d0,ym_length
;		clr.l	ym_counter
		move.l	#92,ym_counter
		rts		


music_ym_play:
		move.l	ym_reg_file_adr,a0													;4
		lea.l	14(a0),a0															;2
		
		lea.l	$ffff8800.w,a1														;2
		lea.l	$ffff8802.w,a2														;2

		lea.l	ym_counter,a3														;2

		move.l	(a3),d0																;3
		add.l	#32,d0																;4
		move.l	ym_length,d1														;4
		cmp.l	d0,d1																;2
		bge.s	.ok																	;2
		clr.l	(a3)

.ok:	
		add.l	(a3),a0					;correct pos								;4
		addq.l	#1,(a3)					;next pos									;5

		move.l	ym_length,d0				;length of each regdump					;4
		move.l	d0,d1																;1

		clr.b	(a1)					;reg 0										;4
		move.b	(a0),(a2)				;											;4

		move.b	#1,(a1)					;reg 1										;4
		move.b	(a0,d1.l),(a2)				;										;6
		

		moveq.l	#2,d2					;2-6										;1
		moveq.l	#5-1,d7																;1
.loop:		
		add.l	d0,d1																;2
		move.b	d2,(a1)																;3
		move.b	(a0,d1.l),(a2)														;6
		addq.b	#1,d2																;1
		dbra	d7,.loop															;3/4

		move.b	d2,(a1)					;7											;3
		move.b	(a1),d6					;get old reg								;2
		and.b	#%11000000,d6				;erase soundbits, save i/o				;2
		add.l	d0,d1					;next register in dumpfile					;2
		move.b	(a0,d1.l),d7				;get reg7 from dumpfile					;4
		and.b	#%00111111,d7				;erase i/o								;2
		or.b	d6,d7					;or io to regdata							;1
		move.b	d2,(a1)					;7											;3
		move.b	d7,(a2)					;store										;3


		moveq.l	#8,d2					;8-12
		moveq.l	#5-1,d7
.loop2:		
		add.l	d0,d1
		move.b	d2,(a1)
		move.b	(a0,d1.l),(a2)
		addq.b	#1,d2
		dbra	d7,.loop2

		add.l	d0,d1					;reg 13
		cmp.b	#$ff,(a0,d1.l)				;
		beq.s	.no13					;
		move.b	d2,(a1)					;
		move.b	(a0,d1.l),(a2)				;
.no13:

.no:		rts						;


music_ym_exit:	
		lea.l	$ffff8800.w,a0				;exit player
		lea.l	$ffff8802.w,a1
		move.b	#8,(a0)
		clr.b	(a1)
		move.b	#9,(a0)
		clr.b	(a1)
		move.b	#10,(a0)
		clr.b	(a1)
		rts


ym_counter:	dc.l	0
ym_length:	dc.l	0
ym_reg_file_adr:dc.l	0

		even


realtimebuffer	incbin	fx/tridi/dutchrealtimef.bin
;
;prepRealTime
;	lea		realtime+128,a0
;	lea		realtimebuffer,a1
;y set 0
;	REPT 6*3
;o set y
;		REPT 5
;			move.w	o(a0),(a1)+
;o set o+8
;		ENDR
;y set y+160
;	ENDR
;	lea		realtimebuffer,a1			; 6*4*2
;
;	move.b	#0,$ffffc123
;	rts


;realtimebuffer	ds.b	2*5*6*3

;realtime	incbin	"fx/tridi/dutch realtime.neo"




	IFEQ STANDALONE
	include		../lib/lib.s

music
	rept 20
		nop
	endr
	rts
	even	
	ENDC

	SECTION BSS
; general stuff


    IFEQ	STANDALONE

screenpointer				ds.l	1
screenpointer2				ds.l	1
screenpointer3				ds.l	1
screenpointershifter		ds.l	1
screenpointer2shifter		ds.l	1

screen1:					ds.b	65536+65536
screen2:					ds.b	65536
align1:						ds.b	65536
align2:						ds.b	65536
align3:						ds.b	65536
align4:						ds.b	65536
align5:						ds.b	65536
align6:						ds.b	65536
align7:						ds.b	65536
align8:						ds.b	65536
align9:						ds.b	65536
align10:						ds.b	65536
align11:						ds.b	65536


; aligned stuff
alignpointer1				ds.l	1
alignpointer2				ds.l	1
alignpointer3				ds.l	1
alignpointer4				ds.l	1
alignpointer5				ds.l	1
alignpointer6				ds.l	1	
alignpointer7				ds.l	1	
alignpointer8				ds.l	1	
alignpointer9				ds.l	1	
alignpointer10				ds.l	1	

framecounter				ds.w	1
_vblcounter 				ds.w 	1
y_block_pointer				ds.l	1
nextScene					ds.w	1

	ENDC
y_block_pointer_fs			ds.l	1
multablepointer				ds.l	1
divtablepointer				ds.l	1
number_of_vertices: 		ds.w	1
number_of_edges				ds.w	1
number_of_faces				ds.w	1
number_of_cullvertices		ds.w	1
currentMorphRout			ds.l	1
_morphSize_max				ds.w	1
lowerMemStore				ds.l	1


;import bpy
;import os
;os.system("cls")
;
;print("#"*72)
;alignpointer11
;S=bpy.data.scenes['Scene']
;
;def DumpObject(strObj, numFrame, strName):
;    C1=S.objects[strObj]
;    Vs1=C1.data.vertices
;    S.frame_set(numFrame)
;    print("-"*40)
;    print(strName)
;    #print("Frame: "+str(S.frame_current).zfill(3))
;    print("-"*40)
;
;    # Dump mesh
;    thisMesh=C1.to_mesh(S, True, "PREVIEW")
;    print("  Vertices:")
;    for i in range(len(thisMesh.vertices)):
;        v=thisMesh.vertices[i]
;        numX=v.co[0]
;        numY=v.co[1]
;        numZ=v.co[2]
;        strX=str(round(numX, 5))
;        strY=str(round(numY, 5))
;        strZ=str(round(numZ, 5))
;        print(str(i).zfill(3)+","+strX+","+strY+","+strZ)
;    print("  Polygons:")
;    P=S.objects[strObj].data.polygons
;    for i in range(len(P)):
;        thisP=P[i]
;        boolFirst=True
;        strVerts=""
;        for j in range(len(thisP.vertices)):
;            thisV=thisP.vertices[j]
;            if not boolFirst:
;                strVerts+=","
;            strVerts+=str(thisV)
;            boolFirst=False
;        thisNormal=thisP.normal
;        strNormal=str(round(thisNormal[0], 5))
;        strNormal+=","+str(round(thisNormal[1], 5))
;        strNormal+=","+str(round(thisNormal[2], 5))
;        #print(" "*9+"Normal: "+strNormal)
;        print(str(i).zfill(3)+","+strVerts+";"+strNormal)
;    # Clean up
;    bpy.data.meshes.remove(thisMesh)
;
;#DumpObject("Cube001", 0, "Cube 1, start")
;#DumpObject("Cube001", 99, "Cube 1, end")
;
;#DumpObject("Cube002", 100, "Cube 2, start")
;#DumpObject("Cube002", 199, "Cube 2, end")
;
;#DumpObject("Cube-2-Dodecahedron", 0, "Cube 1, start")
;
;DumpObject("trans1a", 0, "Shape 1a, minimal")
;DumpObject("trans1b", 0, "Shape 1b, minimal")

