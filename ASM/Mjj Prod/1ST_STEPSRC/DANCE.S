;=============================================================================
; DANCE DANCE DANCE !!
;  Tobe / MJJ PROD
;  DHS 10 years online compo
;-----------------------------------------------------------------------------
; DANCE.S : main file
;  need	MATH.S
;		TABLES.S
;		SYS.S
;		SCREEN.S
;		DRAW.S
;		RENDER.S
;=============================================================================

dance_sid:		equ				1

;=============================================================================
				SECTION TEXT
;=============================================================================


;-----------------------------------------------------------------------------
; demo_entry : entry point
;-----------------------------------------------------------------------------

demo_entry:
	bsr			super_mode
	bsr			demo_main
	bsr			user_mode
	bra			demo_quit

;-----------------------------------------------------------------------------
; demo_main : enter demo
;-----------------------------------------------------------------------------

demo_main:
	move.l		#$10000,		d0			; STE cookie value
	bsr			sys_detect					; check cookie
	tst.w		d0
	beq			demo_main_quit				; not STE, exit

	bsr			sys_backup					; backup sys
	bsr			scr_init					; init screen
	bsr			sys_setup					; init sys
	bsr			calc_tables					; generate tables

	; *** INTRO ***

	bsr			intro_init
	moveq		#0,				d0
demo_main_0:
	bsr			intro_main
;	not.w		$FFFF8240.W
	cmpi.w		#2,				d0
	beq			demo_main_end
	tst.w		d0
	beq.s		demo_main_0
	bsr			intro_fini

	; *** MJJ ***

	bsr			mjj_init
	moveq		#0,				d0
demo_main_1:
	bsr			mjj_main
;	not.w		$FFFF8240.W
	cmpi.w		#2,				d0
	beq			demo_main_end
	tst.w		d0
	beq.s		demo_main_1
	bsr			mjj_fini

	; *** BUBBLES ***

	bsr			bubbles_init
	moveq		#0,				d0
demo_main_2:
	bsr			bubbles_main
;	not.w		$FFFF8240.W
	cmpi.w		#2,				d0
	beq			demo_main_end
	tst.w		d0
	beq.s		demo_main_2
	bsr			bubbles_fini

	; *** HYPNO ***

	bsr			hypno_init
	moveq		#0,				d0
demo_main_3:
	bsr			hypno_main
;	not.w		$FFFF8240.W
	cmpi.w		#2,				d0
	beq			demo_main_end
	tst.w		d0
	beq.s		demo_main_3
	bsr			hypno_fini

	; *** GLOKY ***
	
	bsr			style_init
	moveq		#0,				d0
demo_main_4:
	bsr			style_main
	cmpi.w		#2,				d0
	beq			demo_main_end
	tst.w		d0
	beq.s		demo_main_4
	bsr			style_fini

	clr.b		$FFFF820F.W
	jsr			gloky_start
	move.b		#64,			$FFFF820F.W
	bsr			scr_black
	bsr			scr_clear					; clear
	bsr			scr_swap
	bsr			scr_clear
	cmpi.w		#2,				d0
	beq			demo_main_end

	; *** NOISE ***

	bsr			noise_init
	moveq		#0,				d0
demo_main_5:
	bsr			noise_main
;	not.w		$FFFF8240.W
	cmpi.w		#2,				d0
	beq			demo_main_end
	tst.w		d0
	beq.s		demo_main_5
	bsr			noise_fini

	; *** EXIT ***

	bsr			exit_init
	moveq		#0,				d0
demo_main_6:
	bsr			exit_main
	cmpi.w		#2,				d0
	beq			demo_main_end
	tst.w		d0
	beq.s		demo_main_6
	bsr			exit_fini

demo_main_end:
	bsr			sys_restore					; restore sys

demo_main_quit:
	rts

;-----------------------------------------------------------------------------
; demo_space : wait for spacebar release
;-----------------------------------------------------------------------------

demo_space:
	cmp.b		#185,			$FFFFFC02.W
	bne.s		demo_space
	rts

;-----------------------------------------------------------------------------
; demo_exit : exit demo
;-----------------------------------------------------------------------------

demo_quit:
	clr.w		-(sp)						; exit0()
	trap		#1

;-----------------------------------------------------------------------------
; super_mode : switch to super mode
;-----------------------------------------------------------------------------

super_mode:
	clr.l		-(sp)
	move.w		#$20,			-(sp)		; super()
	trap		#1
	addq.l		#6,				sp
	move.l		d0,user_stack
	rts

;-----------------------------------------------------------------------------
; user_mode : switch to user mode
;-----------------------------------------------------------------------------

user_mode:
	move.l		user_stack,		-(sp)
	move.w		#$20,			-(sp)		; super()
	trap		#1
	addq.l		#6,				sp
	rts


;=============================================================================
;				INCLUDES
;=============================================================================


				INCLUDE "MATH.S"			; fast integer maths
				INCLUDE "TABLES.S"			; usefull tables
				INCLUDE "SYS.S"				; system managment
				INCLUDE "SCREEN.S"			; screen managment
				INCLUDE "DRAW.S"			; primitives
				INCLUDE "RENDER.S"			; rendering
				
				INCLUDE "INTRO.S"
				INCLUDE "MJJ.S"
				INCLUDE "HYPNO.S"
				INCLUDE "BUBBLES.S"
				INCLUDE "GLOKY.S"
				INCLUDE "DEMO1H2.S"
				INCLUDE "NOISE.S"
				INCLUDE "EXIT.S"


;=============================================================================
				SECTION DATA
;=============================================================================


sin_table:		INCBIN "SIN.BIN"
cos_table:		INCBIN "COS.BIN"

	IF dance_sid
sid_drv:		INCBIN "SID_DRV.BIN"
sid_tvs:		INCBIN "OVERPLAY.TVS"
sid_tri:		INCBIN "OVERPLAY.TRI"
	ELSE
mus_drv:		INCBIN "ZIK.MUS"
	ENDIF

intro_gfxs:		INCBIN "INTRO.BIN"			; letters bitmaps
hypno_gfxs:		INCBIN "HYPNO.BIN"			; letters too
bubbles_gfxs:	INCBIN "BUBBLES.BIN"		; more letters ?
noise_gfxs:		INCBIN "FUNKY.BIN"			; no more letters !
mjj_graph:		INCBIN "MJJ7LAST.PI1"
gloky_graph:	INCBIN "GLOKY15.PI1"
dhs_graph:		INCBIN "DHS.PI1"


;=============================================================================
				SECTION BSS
;=============================================================================


user_stack:		ds.l			1			; user stack ptr


;=============================================================================
				END
;=============================================================================

