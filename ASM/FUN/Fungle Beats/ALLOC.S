; Speicherverwaltung

	TEXT

; _MALLOC amount  (ret: d0.l  Anfangsadresse oder bei amount=-1: Gr”že gr”žter Block)
_MALLOC	MACRO
	move.l	\1,d0
	bsr	malloc
	ENDM

; _MFREE saddr^
_MFREE	MACRO
	pea	\1
	move.w	#$49,-(sp)
	trap	#1
	addq.l	#6,sp
;	error_w
	ENDM

; _MSHRINK saddr^,newsize
_MSHRINK MACRO
	move.l	\2,-(sp)
	pea	\1
	clr	-(sp)
	move	#$4a,-(sp)
	trap	#1
	lea	$c(sp),sp
;	error_w
	ENDM

_MEMINIT MACRO
	ENDM
	
_MEMDEINIT MACRO
	ENDM
	
; d0 (s. amount, Profibuch)
malloc:	move.l	d0,-(sp)
	move.w	#$48,-(sp)
	trap	#1
	addq.l	#6,sp
	tst.l	d0
	bne.s	.e
	moveq	#-39,d0
;	error_l
.e	rts	