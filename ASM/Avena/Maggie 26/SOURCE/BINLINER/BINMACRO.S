;
;
;
;
; BINMACRO.S
;
; macros specific to binmain
;
;
;
;
;
init_dsp	MACRO
		ENDM

init_dsp_routine MACRO
		LEA	(\1),A0
		JSR	dsp_library+4
		LEA	(\2).W,A0
		JSR	dsp_library+8
		ENDM

install_vbl	MACRO
		ENDM

loadfile	MACRO
		lea	.file(pc),a0
		move.l	\2,a1
		; load file here!
		moveq	#T6_Load,d0
		trap	#6
		bra.s	\@
.file		dc.b	\1
		even
\@
		ENDM

test_if_done	MACRO
		moveq	#T6_TestIfDone,d0
		trap	#6
		tst.w	d0
		ENDM

malloc		MACRO
		move.l	#\1,d1
		move.w	#T6_Malloc,d0
		trap	#6
		ENDM

mfree		MACRO
		move.l	\1,a0
		move.w	#T6_Mfree,d0
		trap	#6
		ENDM

add_vbl		MACRO
		move.l	\1,a0
		moveq	#T6_InstallVBL,d0
		trap	#6
		ENDM

sub_vbl		MACRO
		move.l	#0,a0
		moveq	#T6_InstallVBL,d0
		trap	#6
		ENDM


