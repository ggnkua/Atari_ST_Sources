
CHECK_VBL_COUNT					equ 1
CHECK_VBL_NAZI					equ 1
CHECK_VBL_OVERFLOW				equ 1
DO_PART_2						equ 1

MYM_PART2_SONG_POS_END			equ	$2e											; we need to skip the player, since the dumping has been done, but the
MYM_PART2_CHAN1_PATTR_END		equ $51											;	actual player hasnt advanced its position yet, so we modify this here
MYM_PART2_CHAN2_PATTR_END		equ $b2
MYM_PART2_CHAN3_PATTR_END		equ $aa

MYM_PART2_SONG_POS_NEXT_END		equ $2f
MYM_PART2_CHAN1_PATTR_NEXT_END	equ $a9
MYM_PART2_CHAN2_PATTR_NEXT_END	equ $b2
MYM_PART2_CHAN3_PATTR_NEXT_END	equ $a8




; DEMO Outline:
;	0	TOS INIT	- 1vbl	our regular drop from tos to black background										
;	1	LIFELINE	- 1vbl	refer back to execution and pulse; as a Triptych									
;	2a	MOTUS		- 1vbl	demo name announcement, fadeing in horizontal letters								
;	2b	SMFX		- 1vbl	group name annoucement, using the same M from motus, in stylized letters			
;	3	VHS/DIAG	- 1vbl	smfx is back, with a sineflower, more stylized, to save the scene					
;	4	PRODUCTIVE	- 1vbl	we have a message for you, be productive! 											
;	5a	C2P VOXEL	- 2vbl	punch opcodes and explore new territories											
;	5b	C2P PLASMA	- 2vbl	push pixels and define aestetics													
;	5c	C2P ROTOZOOM- 2vbl	square waves and create the flow ....  but most importantly!						
;	6a	CHECKER		- 1vbl	a flythrough to keep up the pace to get to the conclusion of our message!			
;	6b	ZOOMER		- 1vbl	meet deadlines																		
;	6c	SMFX logo	- 1vbl	SMFX squashes the deadlinesg														
;	7	ENVMAP		- 2vbl	fullscreen picture with 1:1 envmapped 2 vbl object present							
;	8	GREETINGS	- 1vbl	tunnel effect with greetings														
;	9a	TAPETEXT	- 2vbl	a rotating zooming in texured tape that comes into position							
;	9b	TAPELINT	- 1vbl	smfx logo that rolls up into a tape													
;	10	LENS		- 1vbl	fullscreen picture with 1:1 offsmap effect											
;	11	TUNNEL		- 3vbl	moving 960x200 map of tunnel														
;	12	POLYGON		- 2/3v	various texturemapped polygons	
;	13	OUTTRO		- 1vbl	endmessage and
;	------------------------- order no longer determined


; general settings:
SHOW_CPU						equ 1			; 0 = show cpu time, where available, 1 = normal view
USE_MYM_DUMP					equ 0
USE_SNDH						equ 0
;---------------- EFFECT LIST
;---------------- EFFECT LIST
;---------------- EFFECT LIST

;----------- 0	TOS INIT START
TOS_START						equ 0				;													 INDICATE		ACTUAL		TOTAL		FRAMES COUNTED
TOS_START_EFFECT_FRAMES			equ 480				;														~0:10		(9.6s)					524
;----------- 0	TOS INIT END

;----------- 1	LIFELINE START
LIFELINE						equ 0				; 
LIFELINE_EFFECT_FRAMES			equ 1000-10-12		;														0:20		(20s)		29.6s		1527
;----------- 1	LIFELINE END


;----------- 2a	HORIZONTAL SPLIT MOTUS START
HORSPLIT_MOTUS					equ 0				;0 = display, 1 = skip
HORSPLIT_MOTUS_EFFECT_FRAMES	equ 180				;														0:05		(3.6s)		33.2s		1715
WAITER_O						equ 40-3
WAITER_T						equ 50
WAITER_U						equ 80
WAITER_S						equ 91 ;91
;----------- 2a	HORIZONTAL SPLIT MOTUS END
;----------- 2b SMFX LOGO
SMFX_MOTUS						equ 0				; 
;SMFX_MOTUS_EFFECT_FRAMES		equ 320-150				;														0:05		(3.8s)
SMFX_MOTUS_EFFECT_FRAMES		equ 320-129+30-5 ;30				;													0:05		(3.8s)		38s		1966
;SMFX_WAITER_S					equ SMFX_WAITER_X+39
;SMFX_WAITER_F					equ 4
;SMFX_WAITER_X					equ SMFX_WAITER_F+8

; ALT:
SMFX_WAITER_S					equ SMFX_WAITER_X+48
SMFX_WAITER_F					equ 3
SMFX_WAITER_X					equ SMFX_WAITER_F+48
;----------- 2b SMFX LOGO END



;----------- 3	VHS DIAGONAL
VHS_DIAGONAL					equ 0				;0 = display, 1 = skip
;VHS_DIAGONAL_EFFECT_FRAMES		EQU 338+1172				;	338 frames needed for transition			0:30		(30s)		1:08.2
VHS_DIAGONAL_EFFECT_FRAMES		EQU 338+849+192-30+13				;	338 frames needed for transition		0:30		(30s)		1:08.2		3566
SINEFLOWER_DISPLAY_LEFT			equ 1				; 0 = display left, 1 = display right
SINEFLOWER_MANUAL_VALUES		equ	1				; 0 = manual, 1 = set values
;----------- 3	SINEFLOWER END


;----------- 4  IN BETWEEN SCREEN
AFTER_FLOWER					equ 0
AFTER_FLOWER_EFFECT_FRAMES		equ 350+30-2										;															3981

BE_PRODUCTIVE_FADE_WAITER		equ 40 ;35
BE_PRODUCTIVE_FADE_SPEED		equ 8 ;6				; higher is slower


; mymdumping transition stuff		
MYM_DUMP1_START					equ AFTER_FLOWER_EFFECT_FRAMES-32			;30; 33; 26, finetuning for MYM dump starting, where -20 is current finetune value, range <= 0
MYM_DUMP1_NR_PATTERNS			equ 14											; dump duration in patterns, patterns * rows * speed = 16*64*3 = 3072
; starting positions for dump, this is where the dumper must start
MYM_DUMP1_SONG_POS				equ	$12											; when dumping starts, use this song position
MYM_DUMP1_CHAN1_PATTR			equ $88											; when dumping starts, channel 1 is using this pattern
MYM_DUMP1_CHAN2_PATTR			equ $6e											; when dumping starts, channel 2 is using this pattern
MYM_DUMP1_CHAN3_PATTR			equ $8D											; when dumping starts, channel 3 is using this pattern

MYM_DUMP1_SONG_POS_NEXT			equ $13											; when current song pattern is done, this is the next pattern
MYM_DUMP1_CHAN1_PATTR_NEXT		equ $59											; when song pattern is done, this is next pattern for channel 1
MYM_DUMP1_CHAN2_PATTR_NEXT		equ $6d											; when song pattern is done, this is next pattern for channel 1
MYM_DUMP1_CHAN3_PATTR_NEXT		equ $89											; when song pattern is done, this is next pattern for channel 1

; adjusting player settings for continuing playing, after the dumper has done

MYM_DUMP1_SONG_POS_END			equ	$20											; we need to skip the player, since the dumping has been done, but the
MYM_DUMP1_CHAN1_PATTR_END		equ $11											;	actual player hasnt advanced its position yet, so we modify this here
MYM_DUMP1_CHAN2_PATTR_END		equ $6b
MYM_DUMP1_CHAN3_PATTR_END		equ $96

MYM_DUMP1_SONG_POS_NEXT_END		equ $21
MYM_DUMP1_CHAN1_PATTR_NEXT_END	equ $50
MYM_DUMP1_CHAN2_PATTR_NEXT_END	equ $5B
MYM_DUMP1_CHAN3_PATTR_NEXT_END	equ $93
;----------- 4	IN BETWEEN SCEEN END


;----------- 5	MOTUS MOTUS MOTUS PART																		~1:00					2:18.2			
MOTUS_C2P							equ 0				; 0 = display, 1 = skip
; SHARED CONSTANTS	
DO_SOLID							EQU 1				; solid bars, bugged
VERTICAL_MOVEMENT_SPEED				equ	3				; how fast they move, constant speed

; VOXEL CONSTANTS	
VOXEL_EFFECT_VBL					EQU 11*25			; 25fps effect, number of seconds to display outside transitions								4797
VOXEL_UNDERLINE_WAIT				EQU 349				; 350 vbl until first underline/hightlight shows
VOXEL_USEFILES						EQU 1				; data/c2pvoxel/hmc1.bmp and data/c2pvocxel/hm1.neo	;
FREE_MOVE							EQU 1				; 0 = manual voxel, 1 = set values
PLAYMUSIC							EQU 0
FLASH								EQU 1				; flash whole screen for picture introduction, bugged
DITHER								EQU 0				; some setting, not sure ;)				
; P LASMA CONSTANTS	
PLASMA_EFFECT_VBL					EQU 10*25			; 25fps effect, number of seconds to display outside transitions								5694
PLASMA_UNDERLINE_WAIT				EQU 359	
PLASMA_PANEL_IN_WAIT_VBL			EQU 195				; 160 nr of vbl waiting before plasma gets drawn, you have to guess :P
PLASMA_PANEL_OUT_SHORTEN_VBL		EQU	7			; nr of vbls you want the panel OUT EARLIER 0 = latest possible, if you want later, extend the effect
SHARE_COLOUR						EQU 1				; some setting, not sure :)

ROTO_EFFECT_VBL						equ 20*50-36-40-15+2-12	; special case, this one is in vbls																6667, +2 for ymdump offset fix, +0 for sineflower framereduction
ROTO_PANEL_IN_WAIT_VBL				equ 60				; number of frames delay before panel comes in
ROTO_PANEL_OUT_VBL					equ 755
ROTO_UNDERLINE_WAIT					equ 670		
;----------- 5 MOTUS MOTUS MOTUS PART END

;----------- 6	CHECKER EFFECFT																				~0:20						2:38			8004
CHECKER								equ 0					
CHECKER_EFFECT_CYCLES				equ 160 ;145
CHECKER_EFFECT_VBL					equ 56+8*CHECKER_EFFECT_CYCLES

CHECKER_FADEOUT_START_DELAY_VBL		equ 120				;140
CHECKER_FADEOUT_BLACK_VBL			equ 3				;3
CHECKER_FADEOUT_VBLSKIP_PER_STEP	equ 4				;2
CHECKER_CYCLE_STEPS					equ 8				; lower is faster

CHECKER_FLASH_WAITER_VBL			equ 70
CHECKER_FLASH_INTERVAL_VBL			equ 34



PACKEDSTUFF 						EQU 0
DEADLINES_EFFECT_VBL				equ 270				;																								8275
DEADLINES_CRUSH_DELAY				equ 48

DEADLINES_HOLES						equ 1
;----------- 6	CHECKER EFFECT ENDs


;------------ 7 OMGOMG MOTUS
OMG									EQU 0
OMG_EFFECT_VBL						EQU 550+165+19										;						0:08									9705
;------------ 7 OMGOMG MOTUS END

; options next:
; 
;------------ 8 GREETINGS 
GREETINGS_TUNNEL					EQU	0												;																10666
GREETINGS_TUNNEL_EFFECT_VBL			EQU 1210
;------------ 8 GREETINGS END


;------------ 9 TAPELINT
TAPETEXT							equ 0
TAPETEXT_INTRO_DELAY_VBL			equ	25									; @505: adjust this to change how long delay BEFORE tape introduced													
TAPETEXT_EFFECT_FRAMES				equ 130+TAPETEXT_INTRO_DELAY_VBL				;														0:03									10861
TAPELINT							equ 0
TAPELINE_FADEIN_VBL_WAIT			equ 14						; @505: adjust this to change how long delay BEFORE fadein of tapelint happens
TAPELINT_EFFECT_FRAMES				equ 650+TAPELINE_FADEIN_VBL_WAIT				;														0:12									11521
TAPE_LINT_STATIC_VBL				equ 200+TAPELINE_FADEIN_VBL_WAIT
TAPELINT_MOVEOUT_FRAMES				equ 84
TAPE_UNDERLINE_WAIT_VBL				equ 60											; frames before border opens
TAPE_UNDERLINE_ACTIVE_VBL			equ	250											; frames between border open and fadeout (+close)


; mymdumping transition stuff		
MYM_DUMP2_START					equ TAPELINT_EFFECT_FRAMES-176;94; 33; 26, finetuning for MYM dump starting, where -20 is current finetune value, range <= 0
MYM_DUMP2_NR_PATTERNS			equ 40										; dump duration in patterns, patterns * rows * speed = 16*64*3 = 3072
; starting positions for dump, this is where the dumper must start
MYM_DUMP2_SONG_POS				equ	$3A											; when dumping starts, use this song position
MYM_DUMP2_CHAN1_PATTR			equ $D8											; when dumping starts, channel 1 is using this pattern
MYM_DUMP2_CHAN2_PATTR			equ $53  										; when dumping starts, channel 2 is using this pattern
MYM_DUMP2_CHAN3_PATTR			equ $39											; when dumping starts, channel 3 is using this pattern

MYM_DUMP2_SONG_POS_NEXT			equ $3B											; when current song pattern is done, this is the next pattern
MYM_DUMP2_CHAN1_PATTR_NEXT		equ $14											; when song pattern is done, this is next pattern for channel 1
MYM_DUMP2_CHAN2_PATTR_NEXT		equ $12											; when song pattern is done, this is next pattern for channel 1
MYM_DUMP2_CHAN3_PATTR_NEXT		equ $13											; when song pattern is done, this is next pattern for channel 1

; adjusting player settings for continuing playing, after the dumper has done

MYM_DUMP2_SONG_POS_END			equ	$52											; we need to skip the player, since the dumping has been done, but the
MYM_DUMP2_CHAN1_PATTR_END		equ $49											;	actual player hasnt advanced its position yet, so we modify this here
MYM_DUMP2_CHAN2_PATTR_END		equ $4a
MYM_DUMP2_CHAN3_PATTR_END		equ $4b

MYM_DUMP2_SONG_POS_NEXT_END		equ $53
MYM_DUMP2_CHAN1_PATTR_NEXT_END	equ $4c
MYM_DUMP2_CHAN2_PATTR_NEXT_END	equ $4a
MYM_DUMP2_CHAN3_PATTR_NEXT_END	equ $4d



;------------ 9 TAPELINT END

;----------- 10	LENS EFFECFT
LENS								equ 0				; 0 = display, 1 = skip			433 frames				0:09									12223
LENS_AFTER_EFFECT_FADEWAITER		equ 61				; make this shorter to display the picture shorter after effect is done
;----------- 10	LENS EFFECT ENDs


;------------ 11 TUNNEL
TUNNEL								equ 0
TUNNEL_EFFECT_FRAMES				equ 1368-8-8
TUNNEL_EFFECT_FRAMES_MOVE_WAIT		equ 60				; number of effect frames (1 effect frame ~ 3 vbl), before movement starts
TUNNEL_POETRY_START_SPEED			equ $24000				; 16.16 to determine speed
TUNNEL_POETRY_BREAK_SPEED 			equ $980
;------------ 11 TUNNEL END

;------------ 12 3D TEXTURE
POLYGON								equ 0
POLYGON_EFFECT_VBL					equ 2650-490																									;		13319
POLYGON_TORUS_SELECT				equ 1
;------------ 12 3D TEXTURE END

OUTTRO								equ 0
OUTTRO_FRAMES_UNTIL_NORMAL_SND		equ 1000
OUTTRO_HEART_SPEED					equ $aD00
OUTTRO_HEART_FADE_SPEED				equ 1

CREDITS_FADE_SPEED_VBL				equ 3
CREDITS_WAITER_OFF					equ 24
CREDITS_SPKR_WAITER					equ	CREDITS_WAITER_OFF+22
CREDITS_MOD_WAITER					equ CREDITS_WAITER_OFF+48*2+1
CREDITS_505_WAITER					equ CREDITS_WAITER_OFF+48*4
CREDITS_XIA_WAITER					equ CREDITS_WAITER_OFF+48*6

OUTTRO_FRAMES_UNTIL_SCROLLER		equ CREDITS_WAITER_OFF+48*8+48+1
OUTTRO_SCROLLER_SPEED				equ 3
OUTTRO_HIGHLIGHT_OFFSET_VBL			equ 1
OUTTRO_CINEMASCOPE					equ 0

DEMOSYSTEM equ 19
	IFD DEMOSYSTEM
		IFD	STANDALONE
		ELSE
STANDALONE 					equ 1
		ENDC
	ELSE
STANDALONE					equ 0
	ENDC

TRUE	equ	0
FALSE	equ 1
true	equ 0
false	equ 1


	incdir	gfx
	incdir	lib
	incdir	msx
	incdir	res/smfx


checkvbl macro
	IFEQ	CHECK_VBL_COUNT
	moveq	#0,d0
	move.w	cummulativeCount,d0
	move.b	#0,$ffffc123
	ENDC
	endm

vblNazi	macro
	IFEQ	CHECK_VBL_NAZI
		IFNE	DO_PART_2
	cmp.w	#\1,cummulativeCount
	beq		.ok\@
		; omg someone haxxed it
		lea		$ffff8240,a0
		move.l	#$00700070,d0
		REPT 8
			move.l	d0,(a0)+
		ENDR
		moveq	#0,d0
		move.w	#\1,d0
		moveq	#0,d1
		move.w	cummulativeCount,d1
		move.b	#0,$ffffc123
.ok\@
		ENDC
	ENDC
	endm

    section	TEXT

	include macro.s
resetVBL	macro
	move.w	#$2700,sr
	move.l	#.vblWait\@,$70.w
	move.w	#$2300,sr
	move.w	#0,$466.w
.x\@
	tst.w	$466.w
	beq		.x\@
	move.w	#0,$466.w
	jmp		.next\@
.vblWait\@
	addq.w	#1,$466.w
	addq.w	#1,cummulativeCount
		pushall

		clr.b	$fffffa1b.w			;Timer B control (stop)
		bset	#0,$fffffa07.w			;Interrupt enable A (Timer B)
		bset	#0,$fffffa13.w			;Interrupt mask A (Timer B)
		move.l	#timer_b_open_curtain_stable,$120.w
		move.b	#188,$fffffa21.w		;Timer B data
		move.b	#4,$fffffa1b.w			;Timer B control (delay mode)
		bclr	#3,$fffffa17.w			;Automatic end of interrupt


		tst.w	doBlack
		bne		.white\@
.black\@
		move.l	#0,d0
		lea		$ffff8240,a0
		REPT 8
			move.l	d0,(a0)+
		ENDR
		move.w	#0,timer_b_open_curtain_stable_col+2	
		jmp		.done\@
.white\@
		move.l	#$7770777,d0
		lea		$ffff8240,a0
		REPT 8
			move.l	d0,(a0)+
		ENDR
		move.w	#0,$ffff8240
		move.w	#$777,timer_b_open_curtain_stable_col+2
.done\@

    	jsr		musicPlayer+8
    	popall
	move.l	screen2,$ffff8200
	rte
.next\@
	jsr		clearMem
	endm


resetVBLYM	macro

	move.w	#$2700,sr
	move.l	#.vblWait\@,$70.w
	move.w	#$2300,sr
	move.w	#0,$466.w
.x\@
	tst.w	$466.w
	beq		.x\@
	move.w	#0,$466.w
	jmp		.next\@
.vblWait\@
	addq.w	#1,$466.w
	addq.w	#1,cummulativeCount
		pushall
		clr.b	$fffffa1b.w			;Timer B control (stop)
		bset	#0,$fffffa07.w			;Interrupt enable A (Timer B)
		bset	#0,$fffffa13.w			;Interrupt mask A (Timer B)
		move.l	#timer_b_open_curtain_stable,$120.w
		move.b	#188,$fffffa21.w		;Timer B data
		move.b	#4,$fffffa1b.w			;Timer B control (delay mode)
		bclr	#3,$fffffa17.w			;Automatic end of interrupt


		tst.w	doBlack
		bne		.white\@
.black\@
		move.l	#0,d0
		lea		$ffff8240,a0
		REPT 8
			move.l	d0,(a0)+
		ENDR
		move.w	#0,timer_b_open_curtain_stable_col+2	
		jmp		.done\@
.white\@
		move.l	#$7770777,d0
		lea		$ffff8240,a0
		REPT 8
			move.l	d0,(a0)+
		ENDR
		move.w	#0,$ffff8240
		move.w	#$777,timer_b_open_curtain_stable_col+2
.done\@


				jsr		replayMymDump
    	popall
	rte
.next\@
	jsr		clearMem
	move.l	screen2,$ffff8200

	endm




 			initAndRun	motus_demo
 			ds.b	8000
motus_demo
;	move.l	#e0,d0
;	move.l	#e1,d1
;	move.l	#e2,d2
;	move.l	#e3,d3
;	move.l	#e4,d4
;	move.l	#e5,d5
;	move.l	#e6,d6
;	move.l	#e7,d7
;	move.l	#e8,a0
;	move.l	#e9,a1
;	move.l	#e10,a2
;	move.l	#e11,a3
;	move.l	#e12,a4
;	move.l	#e13,a5
;	move.l	#e14,a6
;	sub.l	d1,d0
;	sub.l	d2,d1
;	sub.l	d3,d2
;	sub.l	d4,d3
;	sub.l	d5,d4	
;	sub.l	d6,d5
;	sub.l	d7,d6
;	sub.l	a0,d7
;	sub.l	a1,a0
;	sub.l	a2,a1
;	sub.l	a3,a2
;	sub.l	a4,a3
;	sub.l	a5,a4
;	sub.l	a6,a5

	move.l  $84.w,old_trap1+2
	move.l  #my_trap1,$84.w
	move.w	#2687,mymFrames			;14*64*3 2688

	tst.w	musicInit
	bne		.skipMusicInit
		IFNE	USE_SNDH
			initMusic	musicmyv,musicmys,musicmysend
		ELSE
			jsr		musicPlayer
		ENDC
		move.w	#-1,musicInit
.skipMusicInit

	move.l	#musicVbl,$70
	jsr		init_demo		; can be removed

	IFEQ	DO_PART_2
	move.w	#1000,d7
.www
	wait_for_vbl
	dbra	d7,.www
		jsr		searchMysMyvInSND

		jmp		part2
	ENDC

	IFEQ	TOS_START
		move.w	#TOS_START_EFFECT_FRAMES,effect_vbl_counter
		jsr		init_tos_start
		jsr		tos_start_mainloop
				checkvbl
				vblNazi $0000020C
	ENDC

	IFEQ	LIFELINE
				resetVBL
		move.w	#LIFELINE_EFFECT_FRAMES,effect_vbl_counter
		jsr		init_lifeline
		jsr		lifeline_mainloop
				checkvbl
				vblNazi	$000005EA
	ENDC

	IFEQ	HORSPLIT_MOTUS
				resetVBL
		move.w	#HORSPLIT_MOTUS_EFFECT_FRAMES,effect_vbl_counter
		jsr		init_title
		jsr		title_mainloop
				checkvbl
				vblNazi	$000006A6
	ENDC

	IFEQ	SMFX_MOTUS
		move.w	#SMFX_MOTUS_EFFECT_FRAMES,effect_vbl_counter
		jsr		init_smfx_motus
		jsr		smfx_motus_mainloop
				checkvbl
				vblNazi	$0000079A
	ENDC

	IFEQ	VHS_DIAGONAL
 		move.w	#VHS_DIAGONAL_EFFECT_FRAMES,effect_vbl_counter
		jsr		init_diagvhs
		jsr		diagvhs_mainloop
				checkvbl
;				vblNazi	$00000DE4				;+1 for hatari, not steem,
	ENDC

	IFEQ	AFTER_FLOWER
		move.w	#AFTER_FLOWER_EFFECT_FRAMES,effect_vbl_counter
		jsr		init_after_flower
		jsr		after_flower_mainloop
				checkvbl
				vblNazi	$00000F81+1
	ENDC

	IFEQ	MOTUS_C2P
		jsr		init_voxel								; do the voxel stuff
				checkvbl
				vblNazi	$000012B1+1
		jsr		init_plasma								; do the plasma stuff
				checkvbl
				vblNazi	$00001632+1
		jsr		init_rotozoom							; do the rotozoom stuff
				checkvbl
				vblNazi	$000019F9-3
	ENDC

	IFEQ	CHECKER
		move.w	#CHECKER_EFFECT_VBL,effect_vbl_counter
		jsr		init_checker
		jsr		checker_mainloop
				checkvbl
				vblNazi	$00001F32-3
		jsr		init_deadlines
		move.w	#DEADLINES_EFFECT_VBL,effect_vbl_counter
		jsr		deadlines_mainloop
				checkvbl
				vblNazi	$00002041-3
	ENDC



	IFEQ	OMG
		move.w	#OMG_EFFECT_VBL,effect_vbl_counter
		jsr		init_envmap
		jsr		envmap_mainloop
				checkvbl
				vblNazi	$000025F0
	ENDC

part2
	IFEQ	DO_PART_2
;		jsr		searchMysMyvInSND
		; advanace the player
		lea		advanceSNDData,a0

		move.b	#MYM_PART2_SONG_POS_END,(a0)+
		move.b	#MYM_PART2_CHAN1_PATTR_END,(a0)+
		move.b	#MYM_PART2_CHAN2_PATTR_END,(a0)+
		move.b	#MYM_PART2_CHAN3_PATTR_END,(a0)+

		move.b	#MYM_PART2_SONG_POS_NEXT_END,(a0)+
		move.b	#MYM_PART2_CHAN1_PATTR_NEXT_END,(a0)+
		move.b	#MYM_PART2_CHAN2_PATTR_NEXT_END,(a0)+
		move.b	#MYM_PART2_CHAN3_PATTR_NEXT_END,(a0)+

		jsr		advanceSNDPos

		jsr		init_envmap_pointers
		lea		omgcrk,a0
		move.l	omgpointer,a1
		jsr		cranker		; load the omg screen
		move.l	screenpointer,a0
		move.l	screenpointer2,a1
		move.l	omgpointer,a2
		add.w	#160,a2
		add.w	#160+32,a0
		add.w	#160+32,a1
		move.w	#199-1,d7
.cp
		REPT 40
			move.l	(a2)+,d0
			move.l	d0,(a1)+
			move.l	d0,(a0)+
		ENDR
		dbra	d7,.cp

		move.w	#500,effect_vbl_counter
		move.l	screenpointer2,$ffff8200
	  	move.b	#0,musicPlayer+$b8

	  	jsr		genMaskLeftRight

		move.w	#$777,timer_b_open_curtain+2
		move.l	#envmap_out_vbl,$70

.ww
		tst.w	$466.w
		beq		.ww
		move.w	#0,$466.w
		subq.w	#1,effect_vbl_counter
		bge		.ww


	ENDC

	IFEQ	GREETINGS_TUNNEL
		move.w	#GREETINGS_TUNNEL_EFFECT_VBL,effect_vbl_counter
		jsr		init_greetings
				checkvbl
				vblNazi	$00002AAB
	ENDC
		move.w	#-1,doBlack
				resetVBL

	IFEQ	TAPETEXT
		move.w	#TAPETEXT_EFFECT_FRAMES,effect_vbl_counter
		jsr		init_tapetext
		jsr		tapetext_mainloop
				checkvbl
				vblNazi	$00002B4F
	ENDC
	IFEQ	TAPELINT																;15 seconds
		move.w	#TAPELINT_EFFECT_FRAMES,effect_vbl_counter
		jsr		init_tapelint2
		jsr		tapelint2_mainloop
				checkvbl
				vblNazi	$00002E3A
	ENDC

		move.w	#-1,doBlack
		resetVBLYM
	IFEQ	LENS																	;15 seconds
		jsr		init_lens
				checkvbl
				vblNazi	$00003116
	ENDC


;		resetVBLYM
	IFEQ	TUNNEL
		move.w	#TUNNEL_EFFECT_FRAMES,effect_vbl_counter
		jsr		init_tunnel
				checkvbl
				vblNazi	$00003116
	ENDC

	IFEQ	POLYGON																	;20
		move.w	#POLYGON_EFFECT_VBL,effect_vbl_counter
		jsr		init_polygons
		jsr		polygons_mainloop
				checkvbl
;				vblNazi	$00003983
	ENDC

	IFEQ	OUTTRO
		jsr		init_outtro
	ENDC

.demostart
.x
		move.l	screenpointer2,$ffff8200
;    cmp.b   #$39,$fffffc02.w                                ; spacebar to exit
;    bne     .x                                       ;
		jmp		.x

	rts

musicVbl
	addq.w	#1,$466.w
	addq.w	#1,cummulativeCount
	pushall
	jsr		musicPlayer+8
	popall
	rte


musicVbl2
	addq.w	#1,$466.w
	addq.w	#1,cummulativeCount
	pushall
	clr.b	$fffffa1b.w			;Timer B control (stop)
	bset	#0,$fffffa07.w			;Interrupt enable A (Timer B)
	bset	#0,$fffffa13.w			;Interrupt mask A (Timer B)
	move.b	#1,$fffffa21.w		;Timer B data (number of scanlines to next interrupt)
	move.l	#timer_b_open_curtain,$120.w
	bclr	#3,$fffffa17.w			;Automatic end of interrupt
	move.b	#8,$fffffa1b.w			;Timer B control (event mode (HBL))
	jsr		musicPlayer+8
	popall
	rte


init_demo
	move.l	#memBase+65536,d0
	sub.w	d0,d0
	move.l	d0,screenpointer
	move.l	d0,screen1
	add.l	#$10000,d0
	move.l	d0,screenpointer2
	move.l	d0,screen2
	add.l	#$10000,d0
    move.w  #$2700,sr	
    move.l  #musicVbl,$70
    move.w  #$2300,sr


    move.w  #0,$466
.w  tst.w   $466.w
    beq     .w
    	move.w	#0,$466
    	move.w	#0,cummulativeCount

    rts

		;Start up Timer B each VBL
		clr.b	$fffffa1b.w			;Timer B control (stop)
		bset	#0,$fffffa07.w			;Interrupt enable A (Timer B)
		bset	#0,$fffffa13.w			;Interrupt mask A (Timer B)
		move.l	#timer_b_open_curtain_stable,$120.w
		move.b	#188,$fffffa21.w		;Timer B data
		move.b	#4,$fffffa1b.w			;Timer B control (delay mode)
		bclr	#3,$fffffa17.w			;Automatic end of interrupt


timer_b_open_curtain_stable
		movem.l	d1-d2/a0,-(sp)

		move.w	#$2100,sr
		stop	#$2100
		move.w	#$2700,sr
	
		lea	$ffff8209.w,a0			;Hardsync
		moveq	#127,d1
.sync:		tst.b	(a0)
		beq.s	.sync
		move.b	(a0),d2
		sub.b	d2,d1
		lsr.l	d1,d1
		clr.b	$fffffa1b.w			;Timer B control (stop)

		dcb.w	59-6,$4e71
timer_b_open_curtain_stable_col
		move.w	#$777,$ffff8240.w


		movem.l	(sp)+,d1-d2/a0
		move.l	#timer_b_close_curtain_stable,$120.w
		move.b	#198,$fffffa21.w		;Timer B data (number of scanlines to next interrupt)
		move.b	#8,$fffffa1b.w			;Timer B control (event mode (HBL))
		rte

timer_b_close_curtain_stable:	
		move.w	#$2700,sr
		movem.l	d0/a0,-(sp)

		moveq	#96,d0				;Hardsync with branch offset
		lea	$ffff8209.w,a0
.sync:		cmp.b	(a0),d0
		beq.s	.sync
		move.b	(a0),d0
		move.w	d0,.jump+2			;SMC bra.w below
.jump:		bra.w	timer_b_open_curtain_stable

.wait:		dcb.w	134,$4e71 

		move.w	#$000,$ffff8240.w

		movem.l	(sp)+,d0/a0
		rte


killMusic
	move.l	#$08000000,$ffff8800.w		;Silence!
	move.l	#$09000000,$ffff8800.w
	move.l	#$0a000000,$ffff8800.w
	rts



clearMem
	move.l	screen1,a0
	move.l	screen2,a1
	move.w	#200-1,d7
	moveq	#0,d0
.l
		REPT 20
			move.l	d0,(a0)+
			move.l	d0,(a0)+
			move.l	d0,(a1)+
			move.l	d0,(a1)+
		ENDR
	dbra	d7,.l
	rts



my_trap1:	
                movea.l SP,A0
                add.l  #6,A0 ;that's either 6 or 8 (68000/68030)
 
;				cmpi.w  #$48,(A0)       ;malloc?
;				beq.s   do_malloc
;				cmpi.w  #$68,(A0)       ;mxalloc?
;				bne.s   no_malloc
 
do_malloc:      movea.l 2(A0),A0        ;requested memory amount
                move.l  malloc_ptr(PC),D0 ;the pointer to memory we're going to give
                move.l	d0,d1
                and.l	#1,d1
                beq		.ok
                	add.l	#1,d0
.ok
                lea     0(A0,D0.l),A0   ;advance our pointer as many bytes as those reserved
                move.l  A0,malloc_ptr   ;save the pointer for next malloc
                rte                     ;and go back to program
 
no_malloc:      cmpi.w  #$49,(A0)       ;mfree?
                bne.s   no_mfree
                rte                     ;do nothing
 
no_mfree:
old_trap1       
                jmp     $1234567              ;jump to O/S' vector
 
                ds.b	4

malloc_ptr:     DC.L memBase+15*65536

	section DATA

	; generic parts
        include     lib/lib.s
        include		lib/cranker.s
		include		lib/mymdump.s
		include		musicplayer.s




        IFEQ USE_SNDH														; WARNING NEEDS RECOMPILE IF YOU CHANGE TRACK :)
musicPlayer																	; 505/nils edit this incbin to the snd you want to use
snd
	incbin	"msx/MOTUS.SND"
	even
        ELSE
		ENDC


_sintable512	include	"data/sintable_amp32768_steps512.s"
_c2pTab			include	"data/c2ptab.s"

		; C2P part data

	section DATA
stillBuffer1	dc.l	0
stillBuffer2	dc.l	0
stillBuffer3	dc.l	0

frameCounter	dc.w	0
effectCounter	dc.w	0	
vblCounter		dc.w	0
												; SIZE			; BSS USE				; TIME

e19	
		include		outtro.s
e18
		include		polygon.s
e17
		include		tunnel.s
e16
        include		lens.s						;~50000		; ~700k extra bss										0:15
e15
		include		tapelint2.s					; ~44202	a5											12
e14
		include		tapetext.s					; ~32740	a4	
e13
        include		vtunnel.s
e12
		include		envmap.s					; ~41784	a3											8			3:03											3												
e11
		include		deadlines.s					; ~8392		a2
e10	
		include		checker.s					; ~24640	a1	
myZoomAnimationPointer
e9
		include		c2protoz.s					; ~37582	a0											20			135s
e8
		include		c2pplasma.s					; ~11308	d7											20			115s
e7
		include		c2pvoxel.s					; ~34458	d6											20			95s
e6
		include		after_flower.s				; ~14052	d5	; <64k						7s			75s
peep
e5
        include		diagvhs.s					; ~43056	d4	; ~770k						30s			68s
e4
        include		smfx_motus.s				;  ~7926	d3	; <64k						36			4s			38s
e3 
        include		horsplit.s					;  ~5612	d2	; <64k						29			4s			34s
e2
		include		lifeline.s					; ~10900	d1	; <64k						22			20s			30s
e1		
		include		tos_start.s					;  ~2652	d0	; -
e0





	section BSS

    rsreset



memBase             ds.b    940*1024
screenpointer		ds.l	1
screenpointer2		ds.l	1
screenpointer3		ds.l	1
screen1             ds.l    1
screen2             ds.l    1
effect_vbl_counter	ds.w	1
musicInit			ds.w	1
mymFrames			ds.w	1
cummulativeCount	ds.w	1
doBlack				ds.w	1
