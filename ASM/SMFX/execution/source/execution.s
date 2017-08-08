;------------ DEMOSYSTEM
DEMOSYSTEM EQU 2017

;------------ MACRO/CONSTANTS
TRUE		equ 0
true		equ 0
FALSE		equ 1
false		equ 1

; general demo stusff
FRAMECOUNT	equ	false			; do you want to count frames in vbl?
LOADMUSIC	equ false			; do you want to load music from file?
PLAYMUSIC	equ true

dointro			equ true

loadDoorsPalette	equ false
loadSyncSinePalette	equ false

useym				equ true

rasters			equ false


;----------- INCLUDED MACROS
	incdir	lib
	incdir	fx
	include	lib/macro.s					; load macro shit, shorthands and whatever

;------- DEMO CODE START
	SECTION TEXT	
	; init
			allocateStackAndShrink								; segments, shrink, superexec
	jsr		checkMachineTypeAndSetStuff							; machine check
	jsr		saveAndKillTimers									; turn off timers	s
	jsr		disableMouse										; turn off mouse
	jsr		backupPalAndScrMemAndResolutionAndSetLowRes			; save screen address and other display properties

	REPT 160
		nop			; hax I suck
	ENDR

	IFEQ	LOADMUSIC
		move.l	#musicfilename2,d0
		move.l	#music2,d1
		jsr		loadFile
		tst.w	fail
		bne		exit
	ENDC

	
	jsr		setScreen64kAligned									; set 2 screens at 64k aligned
	jsr		setAlignPointers																																								

	lea		music,a0
	move.l	alignpointer10,a1
	jsr		d_lz77

	move.l	alignpointer10,sndh_pointer

	jsr		initMusic


	move.w	#$2700,sr
	move.l	#default_vbl,$70
	move.w	#$2300,sr


;;;;;;;;;; main part
	move.l	screenpointer,savedscreenpointer
	move.l	screenpointer2,savedscreenpointer2

	IFEQ	dointro
	; tos intro
	jsr		init_tosIntro
	move.w	#0,nextScene
	jsr		clearBuffer
			checkDemoExit

	; pulse intro
	jsr		init_pulseStartEffect
	move.w	#0,nextScene
	jsr		clearBuffer
			checkDemoExit

	ELSE
	move.l	screenpointer,savedscreenpointer
	move.l	screenpointer2,savedscreenpointer2
	add.l	#96*160,screenpointer
	move.l	alignpointer1,d0
	add.l	#96*160,d0
	move.l	d0,screenpointer2
	ENDC

	; title screen
	jsr		init_title_screen
	move.w	#0,nextScene
	jsr		clearBuffer
			checkDemoExit

	; syncsine bobs transition
	jsr		init_sync_sine
	move.w	#0,nextScene	
	jsr		clearBuffer
			checkDemoExit

	; rotozoom
	jsr		init_rotozoom
	move.w	#0,nextScene
	jsr		clearBuffer
			checkDemoExit

	; doors
	jsr		init_linerout
	move.w	#0,nextScene
	jsr		clearBuffer
			checkDemoExit

	;checkerboard
	move.l	sndh_pointer,a0
	move.b	#0,$b8(a0)
	jsr		init_checker_board
	move.w	#0,nextScene
	jsr		clearBuffer
			checkDemoExit

	; pic
	move.l	sndh_pointer,a0
	move.b	#0,$b8(a0)
	jsr		brainhurts_init
	move.w	#0,nextScene
	jsr		clearBuffer
			checkDemoExit

	; METABALLS
	move.l	sndh_pointer,a0
	move.b	#0,$b8(a0)
	jsr		init_meta
	move.w	#0,nextScene
	jsr		clearBuffer
			checkDemoExit
	
	move.w	#$2700,sr
	move.l	#musicVbl,$70
	move.w	#$2300,sr

	; got style?
	move.l	sndh_pointer,a0
	move.b	#0,$b8(a0)
	jsr		init_style
	move.w	#0,nextScene
	jsr		clearBuffer
			checkDemoExit

	move.l	sndh_pointer,a0
	move.b	#0,$b8(a0)
	; greetings
	jsr		init_greetings
	move.w	#0,nextScene
	jsr		clearBuffer
			checkDemoExit

	move.w	#$2700,sr
	move.l	#newDummy,$120
	move.l	#newDummy,$134
	move.l	#tmpVbl,$70
	move.w	#$2300,sr
	; tridi

	move.l	sndh_pointer,a0
	move.b	#0,$b8(a0)
	jsr		tridi_eor_prec
	move.w	#0,nextScene
	jsr		clearBuffer

	move.l	sndh_pointer,a0
	move.b	#0,$b8(a0)
	jsr		init_endpic	
			checkDemoExit


;;;;;;;;; exit
exit
	; exit
			resetTimers
	jsr		restorePalAndScreenMemAndResolution
	jsr		restoreTimers
	jsr		stopMusic
	jsr 	restoresForMachineTypes
	jsr		enableMouse
	rts

musicVbl
	addq.w	#1,$466.w
	pusha0
	move.l	sndh_pointer,a0
	jsr		8(a0)
	popa0
	rte


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;framecounter_vbl
;	pushall
;	subq.w	#1,framecounter
;	bge		.ok	
;		move.w	#-1,nextScene	
;		move.w	#9999,framecounter
;.ok
;
;
;	move.l	sndh_pointer,a0
;	jsr		8(a0)
;	moveq	#0,d0
;	move.b	$b8(a0),d0
;	cmp.b	#-1,d0
;	bne	.noz
;		move.w	#-1,nextScene
;		move.b	#0,$b8(a0)
;.noz
;
;	popall
;	rte

timer_a_opentop
	move.w	#$2100,sr			;Enable HBL
	stop	#$2100				;Wait for HBL
	move.w	#$2700,sr			;Stop all interrupts
	clr.b	$fffffa19.w			;Stop Timer Affff
	REPT 84
		nop
	ENDR

	clr.b	$ffff820a.w				;60 Hz
	REPT 9
		nop
	ENDR
	move.b	#2,$ffff820a.w			;50 Hz	
	rte


setAlignPointers

	move.l	screenpointer2,d0
	move.l	d0,h2
	move.l	h2,h1
	sub.l	#$10000,h1
	move.l	#$10000,d1

	add.l	d1,d0
	move.l	d0,alignpointer1
	add.l	d1,d0
	move.l	d0,alignpointer2
	add.l	d1,d0
	move.l	d0,alignpointer3
	add.l	d1,d0
	move.l	d0,alignpointer4
	add.l	d1,d0
	move.l	d0,alignpointer5
	add.l	d1,d0
	move.l	d0,alignpointer6
	add.l	d1,d0
	move.l	d0,alignpointer7
	add.l	d1,d0
	move.l	d0,alignpointer8
	add.l	d1,d0
	move.l	d0,alignpointer9
	add.l	d1,d0
	move.l	d0,alignpointer10
	rts


	IFEQ LOADMUSIC
loadFile
				move.l	d0,-(SP)
                move.w  #$3D,-(SP)
                trap    #1
                addq.l  #6,SP
                tst.l   D0              ;opened ok?
                bgt.s   .openok

                bra     .getout

.openok:        	
				move.w  D0,handle       ;read the file
				move.l	d1,-(SP)
                move.l  #1024*128,-(SP)
                move.w  handle(PC),-(SP)
                move.w  #$3F,-(SP)
                trap    #1
                lea     12(SP),SP
                tst.l   D0              ;read everything?
                bgt.s   .readok
.getout
				move.w	#$700,$ffff8240
				move.w	#-1,fail
				add.l	#16,sp
				rts

.readok:         
				move.w  handle(PC),-(SP) ;close file
                move.w  #$3E,-(SP)
                trap    #1
                addq.l  #4,SP	
	rts
fail			ds.w	1
handle			ds.w	1
	ENDC


	SECTION DATA
	include	lib/lib.s
	SECTION DATA

music2
	incbin	msx/exec95b.snd				
	IFEQ	LOADMUSIC
	ds.b	128*1024
	ENDC
	even

memberListSource	
	incbin	"fx/endpic/memberlist.bin"


endpic1			incbin	"fx/endpic/endpic1.l77"			;39840 / 31496
endpic2			incbin	"fx/endpic/endpic2f.l77"		;39840 / 28272
	even


clearBuffer
	lea		bssBuffer,a0
	moveq	#0,d0
	REPT 300/4
		move.l	d0,(a0)+
	ENDR
	rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; part 0:		TOS START
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;			
	include		fx/tosinit.s				; fin			
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;s
; part 1:		WHERE WERE WE -> PULSE INTRO -> WE ARE HERE NOW
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	include		fx/pulseintro.s				; -9.5 kb if packing transition and roto texture
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; part 2:		TITLE SCREEN	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	include		fx/title.s					; -5kb if packed title pic
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; part 3:		OLDSCHOOL SCREEN + WE NEVER LEFT
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	include		fx/syncsine.s				; fin
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; part 4:		CREDITS (rotozoomer)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	include		fx/rotoz.s					; can pack some shit, but troublesome
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; part 5a: 		DOORS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	include		fx/linerout.s				; fin
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; part 5b: 		PERSPECTIVE BARS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	include		fx/bars.s					; -4.9kb if packing rasters and exec logo
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; part 5c: 		ZOOM
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	include		fx/scale.s					; fin
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; part 6:		CHECKERBOARD
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	include		fx/checker.s				; I can generate code and pack shit here, ~7-8kb saved
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; part 7:		PICTURE
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	include		fx/brainhurts.s				; fin
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; part 8:		C2P METABALLS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	include		fx/metapl.s					; fin
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; part 9:		EXECUTION STYLE - FUCK YOU NERDS, WE GOT STYLE
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	include		fx/style.s					;-8.5kb lz77
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; part 10:		GREETINGS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	include		fx/greetings.s				; fin
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; part 11:		TRIDI REALTIME
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	include 	fx/fs_tridi.s
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; part 12:
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	include		fx/endpic.s
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	SECTION DATA

	; music stuff
	IFEQ	LOADMUSIC
musicfilename2				dc.b	"msx\main.snd",0
musicfilename				dc.b	"msx\intro.snd",0
	even
	ENDC

	nop



	SECTION BSS
s
screen1						ds.b	65536+65536
screen2						ds.b	65536
block1						ds.b	65536
block2						ds.b	65536
block3						ds.b	65536
block4						ds.b	65536
block5						ds.b	65536
block6						ds.b	65536
block7						ds.b	65536
block8						ds.b	65536
block9						ds.b	65536
block10						ds.b	65536					;	--> 13*65536 = 851968

screenpointer				ds.l	1	
screenpointer2				ds.l	1
screenpointer3				ds.l	1

savedscreenpointer			ds.l	1
savedscreenpointer2			ds.l	1

h1							ds.l	1
h2							ds.l	1

specialpointer				ds.l	1

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
demo_exit					ds.w	1
nextScene					ds.w	1


bssBuffer					ds.b	1280		

	SECTION DATA
