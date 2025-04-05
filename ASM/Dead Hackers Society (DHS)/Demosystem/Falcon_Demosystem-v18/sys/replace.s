; Falcon demosystem
;
; Replace shell
; 
; replace.s


; Guidelines -----------------------------------------------------------------;
;
; * All functions must be called with the function number in D0.
;
; * All functions except GET_VERSION, return either REPLACE_OK for success or 
;   REPLACE_ERROR for failure in D0.
;
; * All registers are saved except for D0 which is always used for return 
;   value.
;
; * When using non FPU-mode, the LFO sinus wave is replaced by a triangle wave.
;
;-----------------------------------------------------------------------------;

;// Return values

REPLACE_OK:	equ	1
REPLACE_ERROR:	equ	0

;// Function numbers

;-----------------------------------------------------------------------------;
; In:      Pointer to filter table in a0, or set a0 to 0 for using FPU to calc 
;          filter table.
; Out:     REPLACE_OK / REPLACE_ERROR
; Note:    -
;-----------------------------------------------------------------------------;

REPLACE_INITIALIZE:		equ	0

;-----------------------------------------------------------------------------;
; In:      -
; Out:     REPLACE_OK / REPLACE_ERROR
; Note:    -
;-----------------------------------------------------------------------------;

REPLACE_EXIT:			equ	1

;-----------------------------------------------------------------------------;
; In:      -
; Out:     REPLACE_OK
; Note:    -
;-----------------------------------------------------------------------------;

REPLACE_START_INTERRUPT:	equ	2

;-----------------------------------------------------------------------------;
; In:      Pointer to module in a0.
; Out:     REPLACE_OK / REPLACE_ERROR
; Note:    -
;-----------------------------------------------------------------------------;

REPLACE_INITIALIZE_MODULE:	equ	3

;-----------------------------------------------------------------------------;
; In:      -
; Out:     REPLACE_OK
; Note:    -
;-----------------------------------------------------------------------------;

REPLACE_PLAY_SONG:		equ	4

;-----------------------------------------------------------------------------;
; In:      -
; Out:     REPLACE_OK
; Note:    -
;-----------------------------------------------------------------------------;

REPLACE_STOP_SONG:		equ	5

;-----------------------------------------------------------------------------;
; In:      -
; Out:     Pointer in a0 to a 20 character long string of module title.
;          String is NOT null-terminated.
;          REPLACE_OK
; Note:    -
;-----------------------------------------------------------------------------;

REPLACE_GET_MODULE_TITLE:	equ	6

;-----------------------------------------------------------------------------;
; In:      -
; Out:     Pointer in a0 to a 20 character long string of module composer.
;          String is NOT null-terminated.
;          REPLACE_OK
; Note:    -
;-----------------------------------------------------------------------------;

REPLACE_GET_MODULE_COMPOSER:	equ	7

;-----------------------------------------------------------------------------;
; In:      -
; Out:     REPLACE_OK / REPLACE_ERROR
; Note:    Call this function to clear the delay buffers.
;-----------------------------------------------------------------------------;

REPLACE_CLEAR_ECHO:		equ	8

;-----------------------------------------------------------------------------;
; In:      -
; Out:     REPLACE_OK
; Note:    Deallocates memory buffers used by the module.
;-----------------------------------------------------------------------------;

REPLACE_REMOVE_MODULE:		equ	9

;-----------------------------------------------------------------------------;
; In:      -
; Out:     Replace version number as a 4 charater "string" in d0. For 
;          example "0.28".
; Note:    -
;-----------------------------------------------------------------------------;

REPLACE_GET_VERSION:		equ	10

;-----------------------------------------------------------------------------;
; In:      Volume value in D1, range 0-127
; Out:     REPLACE_OK
; Note:    Must be set after REPLACE_INITIALIZE_MODULE.
;-----------------------------------------------------------------------------;

REPLACE_SET_VOLUME:		equ	11

;-----------------------------------------------------------------------------;
; In:      -
; Out:     REPLACE_OK
; Note:    It's not recomended to call this function while plyaing a module.
;          By disabling the delay, the player will use less cpu power.
;          (Delay is the ping-pong echo effect)
;-----------------------------------------------------------------------------;

REPLACE_DELAY_DISABLE:		equ	12

;-----------------------------------------------------------------------------;
; In:      -
; Out:     REPLACE_OK
; Note:    It's not recomended to call this function while plyaing a module.
;          By enabeling the delay, the player will use more cpu power.
;          (Delay is the ping-pong echo effect)
;-----------------------------------------------------------------------------;

REPLACE_DELAY_ENABLE:		equ	13

;-----------------------------------------------------------------------------;
; In:      -
; Out:     Value ranging from 0 to 511 in the lower word of D0
; Note:    Returns the current cpu load. Note that this is the CPU load for the 
;          last frame calculated.
;-----------------------------------------------------------------------------;

REPLACE_GET_CPU_LOAD:		equ	14

;-----------------------------------------------------------------------------;
; In:      -
; Out:     Number of voices currently playing in D0.
; Note:    -
;-----------------------------------------------------------------------------;

REPLACE_GET_NUMBER_OF_VOICES:	equ	15

;-----------------------------------------------------------------------------;
; In:      -
; Out:     REPLACE_OK
; Note:    Stops the DMA playback buffer interrupt. This function does NOT have 
;          to be called prior to REPLACE_EXIT. REPLACE_START_INTERRUPT can be 
;          called sequentially to this function.
;-----------------------------------------------------------------------------;

REPLACE_STOP_INTERRUPT:		equ	16


ace_use_fpu:	equ	1

		section	text


ace_init:
	ifne	ace_use_fpu
		move.l	#0,a0					;FPU (no incbin table)
	else
		lea	filter,a0				;No FPU (200k table incbin)
	endc
		moveq.l	#REPLACE_INITIALIZE,d0
		jsr	replace+28

		lea	ace_module,a0
		moveq.l	#REPLACE_INITIALIZE_MODULE,d0
		jsr	replace+28

		;moveq.l	#REPLACE_DELAY_DISABLE,d0	;Disable delay for much faster replay
		;jsr	replace+28				;
 
		moveq.l	#15,d1
		moveq.l	#REPLACE_SET_VOLUME,d0
		jsr	replace+28

		rts


ace_start:	moveq.l	#REPLACE_START_INTERRUPT,d0
		jsr	replace+28

		moveq.l	#REPLACE_PLAY_SONG,d0
		jsr	replace+28

		rts



ace_stop:
		moveq.l	#REPLACE_STOP_SONG,d0
		jsr	replace+28

		moveq.l	#REPLACE_EXIT,d0
		jsr	replace+28

		rts


		section	data


replace:	incbin	'sys/replace.bin'
		even
		ds.b	54

	ifeq	ace_use_fpu
filter:		incbin	'sys/f32.dat'
		even
	endc


		section	text


