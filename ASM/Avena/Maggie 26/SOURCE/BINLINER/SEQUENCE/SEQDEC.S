;-----------------------------------------------------------------------
;
;
;
; Sequencer declarations - March 1997
; IMPORTANT NOTE: Changes in these declarations must be mirrored
;     by changes in seq.s
;
; These declarations are shared by both the effect sequencer code
;     and the main demo sequencer!
;
;
;
;-----------------------------------------------------------------------
system			macro
			dc.l	"SYS_"
			endm
music			macro
			dc.l	"MUSI"
			endm
load			macro
			dc.l	"LOAD"
			dc.l	\1
			endm
execute			macro
			dc.l	"EXEC"
			dc.l	\1
			dc.w	\2,\3
			dc.l	\4
			endm
term			macro
			dc.l	"END_"
			dc.l	\1
			endm
wait			macro
			dc.l	"WAIT"
			dc.l	\1,\2
			endm
fade			macro
			dc.l	"FADE"
			endm
quit			macro
			dc.l	"QUIT"
			endm
clear			macro
			dc.l	"CLR_"
			endm

;-----------------------------------------------------------------------
			rsreset
seq_end			rs.b	1
seq_wait		rs.b	1
seq_set_rot		rs.b	1
seq_set_rotmov		rs.b	1
seq_set_lrot		rs.b	1
seq_set_lrotmov		rs.b	1
seq_set_view		rs.b	1
seq_set_viewmov		rs.b	1
seq_close		rs.b	1
seq_set_rout		rs.b	1
seq_init_rout		rs.b	1
seq_set_misc		rs.b	1	;sets miscellaneous variables
seq_wait_music		rs.b	1	;waits for music
seq_set_camera		rs.b	1	;set camera position
seq_set_cameramov	rs.b	1	;set camera movement
seq_send_object		rs.b	1	;send object from object list

seq_set_obj		rs.b	1	;set object position
seq_set_objmov		rs.b	1	;set object movement

;-----------------------------------------------------------------------

s_end			macro
			dc.w	seq_end
			endm
s_wait			macro
			dc.w	seq_wait
			dc.w	\1		;pause length
			endm
s_setrot		macro
			dc.w	seq_set_rot
			dc.w	\1,\2,\3
			endm
s_setrotmov		macro
			dc.w	seq_set_rotmov
			dc.w	\1,\2,\3
			endm
s_setlrot		macro
			dc.w	seq_set_lrot
			dc.w	\1,\2,\3
			endm
s_setlrotmov		macro
			dc.w	seq_set_lrotmov
			dc.w	\1,\2,\3
			endm
s_setview		macro
			dc.w	seq_set_view
			dc.w	\1,\2,\3
			endm
s_setviewmov		macro
			dc.w	seq_set_viewmov
			dc.w	\1,\2,\3
			endm
s_setcamera		macro
			dc.w	seq_set_camera
			dc.w	\1,\2,\3
			endm
s_setcameramov		macro
			dc.w	seq_set_cameramov
			dc.w	\1,\2,\3
			endm
s_close			macro
			dc.w	seq_close
			endm
s_setrout		macro
			dc.w	seq_set_rout
			dc.w	\1		;routine number
			endm
s_initrout		macro
			dc.w	seq_init_rout
			endm
s_setmisc		macro
			dc.w	seq_set_misc
			dc.w	\1		;misc number TIMES FOUR
			dc.l	\2		;misc value
			endm
s_waitmusic		macro
			dc.w	seq_wait_music
			dc.w	\1		;music pattern
			dc.w	\2		;music step
			endm
s_sendobject		macro
			dc.w	seq_send_object
			dc.w	\1		;object number
			endm


;-----------------------------------------------------------------------
;
; Individual miscellaneous declarations
;
; THESE **MUST** USE RS.L 

;-----------------------------------------------------------------------
			rsreset
envcube_distort_size	rs.l	1
envcube_distort_speed	rs.l	1

;-----------------------------------------------------------------------
			rsreset
morph_distort_flag	rs.l	1

;-----------------------------------------------------------------------
			rsreset
tree_speed_1		rs.l	1
tree_speed_2		rs.l	1
tree_data_1		rs.l	1
tree_data_2		rs.l	1

;-----------------------------------------------------------------------
			rsreset
bee_wings		rs.l	1
bee_screenshake		rs.l	1
bee_cracks		rs.l	1
;-----------------------------------------------------------------------
			rsreset
inside_texture_new	rs.l	1		;(0 if no texture)
inside_clearscreen	rs.l	1
inside_wobble		rs.l	1
inside_anim_size	rs.l	1