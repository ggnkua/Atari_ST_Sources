;
;
;
;
; BINMAIN.S
; the main code program to drive the effects
;
;
;
; both BINMAIN.S and STARTUP.S must contain certain routines
; and macros to drive the basic stuff such as vbls and interrupts
; that the INCLUDE.S parts share. using a macro means can can use
; different code for the same source
;
;
;
;

; routines 2 and 3 are called with
; d0 = number of routine as given in SHARED.S
; d1 = number of call as given in SHARED.S
;

			output	e:\test\data\prg\binmain.prg
			opt	nodebug

binmain			equ	1

binmain_start:
			bra.w	binmain_handle_main_start
			bra.w	binmain_handle_routine_call
			bra.w	binmain_handle_routine_message
			bra.w	binmain_handle_main_end

binmain_handle_main_start:
			bsr	include_init
			move.w	#T6_GetMonitor,d0
			trap	#6
			jsr	scr_set_monitor
			rts

binmain_handle_main_end:
			bsr	include_deinit
			rts

binmain_handle_routine_call:
			pea	(a0)
			bsr	binmain_get_routine_address
			jsr	([a6,d1.l])
			move.l	(a7)+,a0
			rts

binmain_handle_routine_message:
			bsr	binmain_get_routine_address
			move.l	main_message_list(a6),a1
			illegal			;! this incorrect!
			jsr	(a1)
			rts

; d0 = number of routine
binmain_get_routine_address:
			move.l	(binmain_fx_list,pc,d0.l*4),a6
			rts


;
; startup code goes here:
;
; we need a list of all the effects in the code
; the *numbers* corresponding to this list go in SHARED.S
;

binmain_fx_list:
			dc.l	fx1_codestart		;0
			dc.l	foet_codestart		;1

;--------------------------------------------------------------
			include	includes.s
			even
;--------------------------------------------------------------

;--------------------------------------------------------------
;			FX INCLUDES
;--------------------------------------------------------------
			
			include	fx\backlit\fx1.s
			include	fx\backlit\foet.s



