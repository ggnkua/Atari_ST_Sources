	listing off

;*************************************************************************
; some basic macros for easier programming
; Stephan Junker 13.04.1993
;*************************************************************************

 ifndef basicmacros

basicmacros	equ 1

;-------------------------------------------------------------------------

SetNewPC MACRO NewPC
LastSavedPC* SET $
  ORG NewPC
 ENDM

RestorePC MACRO
  ORG LastSavedPC
 ENDM

;-------------------------------------------------------------------------

MessageOrg MACRO
  segment code
codeLab:
  MESSAGE "Code address is \{codeLab}"
  segment data
dataLab:
  MESSAGE "Data address is \{dataLab}"
  segment bitdata
bitLab:
  MESSAGE "Bit address is \{bitLab}"
  segment xdata
xdatLab:
  MESSAGE "XData address is \{xdatLab}"
  ENDM

;-------------------------------------------------------------------------

push.w	MACRO Low
	push Low
	push Low+1
	ENDM

pop.w	MACRO Low
	pop Low+1
	pop Low
	ENDM

add.b	macro	src,dest
	mov	a,dest
	add	a,src
	mov	dest,a
	endm

add.w	macro	src,dest
	add.b	src,dest
	mov	a,dest+1
	addc	a,src+1
	mov	dest+1,a
	endm

addi.w	macro	src,dest
	add.b	src#256,dest
	mov	a,dest+1
	addc	a,src/256
	mov	dest+1,a
	endm

sub	macro	src,sb
	clr	c
	subb	src,sb
	endm

sub.b	macro	src,dest
	mov	a,dest
	sub	a,src
	mov	dest,a
	endm

sub.w	macro	src,dest
	sub.b	src,dest
	mov	a,dest+1
	subb	a,src+1
	mov	dest+1,a
	endm

subi.w	macro	src,dest
	sub.b	src#256,dest
	mov	a,dest+1
	subb	a,src/256
	mov	dest+1,a
	endm

tst.b	macro	test
	mov	a,test
	endm

tst.w	macro	test
	mov	a,test
	jnz	toendm
	mov	a,test+1
toendm	endm

cmp.b	macro	src,dest
	IF "dest" <> "A"
		mov	a,dest
	ENDIF
	sub	a,src
	endm

cmp.w	macro	src,dest
	mov	a,dest+1
	sub	a,src+1
	jnz	toendm
	cmp.b	src,dest
toendm	endm

cmpi.w	macro	src,dest
	mov	a,dest+1
	sub	a,src/256
	jnz	toendm
	cmp.b	src#256,dest
toendm	endm

bhs	macro	to
	jnc	to
	endm

bhs.w	macro	to
	jc	toendm
	ajmp	to
toendm	endm

bhs.l	macro	to
	jc	toendm
	ljmp	to
toendm	endm

blo	macro	to
	jc	to
	endm

blo.w	macro	to
	jnc	toendm
	ajmp	to
toendm	endm

blo.l	macro	to
	jnc	toendm
	ljmp	to
toendm	endm

bhi	macro	to
	jz	toendm
	jnc	to
toendm	endm

bhi.w	macro	to
	jz	toendm
	jc	toendm
	ajmp	to
toendm	endm

bhi.l	macro	to
	jz	toendm
	jc	toendm
	ljmp	to
toendm	endm

bls	macro	to
	jc	to
	jz	to
toendm	endm

bls.w	macro	to
	jz	toto
	jnc	toendm
toto	ajmp	to
toendm	endm

bls.l	macro	to
	jz	toto
	jnc	toendm
toto	ljmp	to
toendm	endm

 endif

	listing =