
		section text

resident_ker:	equ	0

		include	'gt\sndkernl.s'
		include	'gt\gt2playr.s'

		section text

; --------------------------------------------------------------
; ------------- Graoumf Tracker Pause/Unpause ------------------
; --------------------------------------------------------------

gt_pause:	move.l	.var,d0
		bne.s	.ok
		bsr	gtkpl_pause_module
		move.l	#1,.var
		rts

.ok:		bsr	gtkpl_cont_module
		move.l	#0,.var
		rts

.var:		ds.l	1

; --------------------------------------------------------------
; ------------- Graoumf Tracker Init ---------------------------
; --------------------------------------------------------------

gt_init:	move.l	#gtkpl_info_track,-(sp)
		move.w	#NBRVOIES_MAXI,-(sp)
		sndkernel	kernel_on	
		addq.l	#6,sp
		bsr	gtkpl_player_on		

		;pea	module_gt2		
		;pea	module_gt2
		move.l	filebuffer,-(sp)
		move.l	filebuffer,-(sp)

		move.w	#0,-(sp)		
		bsr	gtkpl_convert_module
		lea	10(sp),sp
		pea	0.l			
		pea	repeatbuffer		

		;pea	module_gt2
		move.l	filebuffer,-(sp)

		bsr	gtkpl_make_rb_module
		lea	12(sp),sp
		rts


; --------------------------------------------------------------
; ------------- Graoumf Tracker ON -----------------------------
; --------------------------------------------------------------

gt_on:		clr.w	-(sp)			
		clr.w	-(sp)
		pea	repeatbuffer

		;pea	module_gt2
		move.l	filebuffer,-(sp)

		bsr	gtkpl_new_module
		lea	12(sp),sp
		rts


; --------------------------------------------------------------
; ------------- Graoumf Tracker OFF ----------------------------
; --------------------------------------------------------------

gt_off:		bsr	gtkpl_stop_module
		rts


; --------------------------------------------------------------
; ------------- Graoumf Tracker Exit ---------------------------
; --------------------------------------------------------------

gt_exit:	bsr		gtkpl_stop_module
		bsr		gtkpl_player_off
		sndkernel	kernel_off
		rts

		section	bss

;module_gt2:	ds.b	2000000
;		ds.b	50000


gtkpl_info_track:	ds.b	nbrvoies_maxi*next_t		;maximum channels info
repeatbuffer:		ds.b	nbrsamples_maxi*1024		;gt repeatbuffer


		section	text