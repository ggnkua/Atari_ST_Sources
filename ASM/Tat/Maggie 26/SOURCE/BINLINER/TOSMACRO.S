;
;
;
;
; TOSMACRO.S
;
; macros specific to TOS
;
;
;
;
;

init_dsp	MACRO
		JSR	dsp_library+0
		ENDM

init_dsp_routine MACRO
		LEA	(\1),A0
		JSR	dsp_library+4
		LEA	(\2).W,A0
		JSR	dsp_library+8
		ENDM

install_vbl	MACRO
		move.l	#\1,my_vbl
		ENDM

loadfile	MACRO
		move.l	\2,a1
		lea	.file(pc),a0
		jsr	load_file
		bra.s	\@
.file		dc.b	'e:\\test\\data\\'
		dc.b	\1
		even
\@
		ENDM

test_if_done	MACRO
		move.w	ts_done_flag,d0
		ENDM

malloc		MACRO
		move.l	#\1,d0
		jsr	mal_malloc
		ENDM

mfree		MACRO
		move.l	\1,a0
		jsr	mal_mfree
		ENDM

add_vbl		MACRO
		move.l	\1,my_vbl
		ENDM

sub_vbl		MACRO
		move.l	#0,my_vbl
		ENDM

		section	text