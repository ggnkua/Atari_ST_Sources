;
; Some utilities macros to help you...
; This library needs MACROSYS.S.
;
; Author : Pierre-Jean Goulier.
;


charhex	MACRO			; To search for an hexa character.
				; charex D? (<> D0).
				; => D0 : hexa char.
	move.b	\1,d0
	cmp.b	#9,d0
	bgt.s	ch1\@
	add.b	#'0',d0
	bra.s	ch2\@
ch1\@	sub.b	#10,d0
	add.b	#'A',d0
ch2\@	nop
	ENDM
	

printhex MACRO			; To display a hexa register (<> D0).
				; printhex(.b/.w/.l) reg
				; D0-D3 are used.
	IFC	'B','\0'	
	move.b	\1,d0
	and	#$FF,d0
	move.b	d0,d1
	ror.b	#4,d0
	and	#$F,d0
	charhex d0
	cconout d0
	move.b	d1,d0
	and	#$F,d0
	charhex d0
	cconout d0
	ENDIF
	IFC	'W','\0'
	move	\1,d0
	and	#$FFFF,d0
	move	#12,d2
	move	#3,d3
phex\@	ror	d2,d0
	move	d0,d1
	and	#$F,d0
	charhex	d0
	cconout	d0
	move	d1,d0
	dbra	d3,phex\@
	ENDIF
	IFC	'L','\0'
	move.l	\1,d0
	move	#28,d2
	move	#7,d3
phex\@	ror.l	d2,d0
	move.l	d0,d1
	and	#$F,d0
	charhex	d0
	cconout	d0
	move.l	d1,d0
	dbra	d3,phex\@
	ENDIF
	ENDM
	
printbin MACRO			; To display a binary register (<> D0).
				; printbin(.b/.w/.l) reg
				; D0-D3 are used.
	IFC	'B','\0'
	move.b	\1,d0
	move	#7,d1
	ENDIF
	IFC	'W','\0'
	move	\1,d0
	move	#15,d1
	ENDIF
	IFC	'L','\0'
	move.l	\1,d0
	move	#31,d1
	ENDIF
	move.l	d0,d2
pbin2\@	move	#'0',d3
	btst	d1,d0
	beq	pbin1\@
	addq	#1,d3
pbin1\@	cconout	d3
	move.l	d2,d0
	dbra	d1,pbin2\@
	ENDM
	
printdec MACRO			; To display a decimal register (<> D0).
				; printdec(.b/.w/.l) reg
				; D0-D4 are used.
				; Nb maxi with .l : 655359999 ($270FFFFF)
	IFC	'B','\0'
	move.b	\1,d0
	move.l	#100,d1
	move.l	#2,d2
	ENDIF
	IFC	'W','\0'
	move	\1,d0
	move.l	#10000,d1
	move.l	#4,d2
	ENDIF
	IFC	'L','\0'
	move.l	\1,d0
	move.l	#10000,d1
	divu	d1,d0
	move.l	d0,d3
	clr.l	d0
	move	d3,d0
	move.l	#4,d2
	moveq	#1,d4
	ENDIF
	
pdec3\@	divs	d1,d0
	beq	pdec1\@
	add	#'0',d0
	move.l	d0,-(sp)
	cconout d0
	move.l	(sp)+,d0
	sub	#'0',d0
	bra	pdec2\@
pdec1\@	move.l	d0,-(sp)
	cconout #'0'
	move.l	(sp)+,d0
pdec2\@	swap	d0
	ext.l	d0
	divu	#10,d1
	dbra	d2,pdec3\@
	
	IFC	'L','\0'
	tst	d4
	beq	pdec4\@
	swap	d3
	move	d3,d0
	move.l	#1000,d1
	move	#3,d2
	subq	#1,d4
	bra	pdec3\@
pdec4\@	nop
	ENDIF
	ENDM
	
inc	MACRO			; Incrementation.
				; Data register, address register or absolute address.
				; inc(.b/.w/.l)
	IFC	'','\1'
	FAIL	Missing operand !!
	MEXIT
	ENDIF
	addq.\0	#1,\1
	ENDM
	
dec	MACRO			; Decrementation.
				; Data register, address register or absolute address.
				; dec(.b/.w/.l)
	IFC	'','\1'
	FAIL	Missing operand !!
	MEXIT
	ENDIF
	subq.\0	#1,\1
	ENDM

init_prg	MACRO		; Program initialisation.
				; What does it need, to free the rest, stack setting.
				; init_prg pile
				; => D0 : if <> 0, oops, caution !
				; => D1 : program size.
	movea.l	4(sp),a5
	move.l	$c(a5),d0
	add.l	$14(a5),d0
	add.l	$1c(a5),d0
	addi.l	#$100,d0
	addi.l	\1,d0
	move.l	d0,d1
	add.l	a5,d1
	andi.l	#-2,d1
	movea.l	d1,sp
	mshrink	a5,d0
	ENDM
	
init_prgres	MACRO		; Resident program initialisation.
				; No stack, no Mshrink !
				; => D0 : program size to keep.
	movea.l	4(sp),a5
	move.l	$c(a5),d0
	add.l	$14(a5),d0
	add.l	$1c(a5),d0
	addi.l	#$100,d0
	ENDM
	