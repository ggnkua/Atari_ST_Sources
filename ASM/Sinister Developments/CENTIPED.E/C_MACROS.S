MAX_VAL1	equ	20	; Max x and y mushie
MAX_VAL2	equ	25	; Coordinates

init	equ	150	; Number of initial mushies

MIN_Y	equ	152	; Min Y coord allowed
MAX_Y	equ	192	; Max Y coord allowed
MAX_Y2	equ	184	; Max Y coord allowed again!

MAX_X	equ	304	; Max X coord allowed

X_START	equ	160	; X coord of start pos
Y_START	equ	192	; Y coord of start pos

B_SPEED	equ	5	; Speed bullet moves at
SC_SPEED	equ	2	; Speed scorpion moves at
SN_SPEED	equ	1	; Speed snail moves at
FLY_SPEEDX	equ	2	; Speed fly moves at
FLY_SPEEDY	equ	2	; Speed fly moves at
BEE_SPEEDX	equ	2	; Speed bee1 moves at
BEE_SPEEDY	equ	2	; Speed bee1 moves at

SCR_TIME	equ	25	; no of frames score stays on screen
WAVE_TIME	equ	20*50	; no of seconds a wave lasts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Macro to multiply given register ;
; by 40. D6 gets trashed.          ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

mul_160	MACRO
	add.w	\1,\1
	lea	mul160,a0
	move.w	(a0,\1.w),\1
2	ENDM

mul_20	MACRO
	add.w	\1,\1
	add.w	\1,\1
	add.w	\1,\2
	lsl.w	#2,\1
	add.w	\1,\2
2	ENDM

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Macro to simplify calling build sprite ;
; parms are - graphic name               ;
;             scanlines in graphic       ;
;             rotation increment         ;
;             masked or not_masked       ;             
;             optional clipping, rclip   ;
;             ,lclip or nclip or blank   ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

build_spr	MACRO
	lea	\1,a6
	IFC	'nclip','\5'
	lea	\1_tab,a2
	ENDC

	IFC	'','\5'
	lea	\1_tab,a2
	ENDC

	IFC	'lclip','\5'
	lea	\1_tab_lc,a2
	ENDC

	IFC	'rclip','\5'
	lea	\1_tab_rc,a2
	ENDC

	move.w	#\2-1,scanlines
	move.w	#\3,interval
	IFC	'not_masked','\4'
	sf	mask_flag	
	ENDC
	IFC	'masked','\4'
	st	mask_flag	
	ENDC
	IFC	'nclip','\5'
	bsr	build_sprite_routes
	ENDC
	IFC	'','\5'
	bsr	build_sprite_routes
	ENDC
	IFC	'lclip','\5'
	bsr	build_lclip_sprites
	ENDC
	IFC	'rclip','\5'
	bsr	build_rclip_sprites
	ENDC

	ENDM

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Macro to simplify incrementing scores ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

add2score	MACRO
	IFNE	\1<11
	moveq	#\1,d2
	lea	score+7,a0
	ENDC
	IFNE	\1=100
	moveq	#1,d2
	lea	score+5,a0
	ENDC
	IFNE	\1=500
	moveq	#5,d2
	lea	score+5,a0
	ENDC
	IFNE	\1=1000
	moveq	#1,d2
	lea	score+4,a0
	ENDC

	bsr	add_points
	ENDM

