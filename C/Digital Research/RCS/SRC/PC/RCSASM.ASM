;***************************************************************************
;modified for the medium model large code: add 2 to the offset of parameter*
;11/02/87 by Mei Chung							   *
;***************************************************************************
; Copyright 1999 by Caldera Thin Clients, Inc.
; This software is licenced under the GNU Public License
; Please see LICENSE.TXT for further information.
PGROUP	GROUP	CODE

CODE	SEGMENT	BYTE PUBLIC 'CODE'
	ASSUME	CS:PGROUP
;
	PUBLIC	SEG_OFF, B_MOVE, MAGNIFY
;
;************************************************************************
;		LONG							*
;	address = seg_off(WORD)						*
;		returns bx = offset					*
;			ax = segment					*
;************************************************************************
SEG_OFF:
		push	bp
		mov	bp, sp
		mov	bx, 4 + 2[bp]		;large code +2
		mov	ax, bx
		and	bx, 000fh		;make it an offset
		mov	cl, 4
		shr	ax, cl			;make it a segment
		pop	bp
		ret
;	
;************************************************************************
;	b_move(&from, count, &to);					*
;		&from:		ADDR	4[bp]				*
;		count:		WORD	8[bp]				*
;		&to:		ADDR	10[bp]				*
;************************************************************************
B_MOVE:
	push	bp
	mov	bp, sp
	mov	bx, ds

; Move from the source to the destination.
	mov	cx, 8 + 2[bp]		; large code +2
	les	di, 10 + 2[bp]		; es:di = address of destination
	lds	si, 4 + 2[bp]		; ds:si = address of source
	rep	movsb			; move bytes

; Restore and exit.
	mov	ds, bx
	pop	bp
	ret
;
;***********************************************************
;MAGNIFY(src_mp, dst_mp, npix)
;expand bits to bytes from source to dest
;***********************************************************
MAGNIFY:
	push	bp
	mov	bp,sp
	mov	bx,8000h
	mov	cx,12 + 2[bp]
	shr	cx,1
	push	ds
	push	es
	lds	si,4 + 2[bp]
	les	di,8 + 2[bp]
	mov	dx,[si]
	inc	si
	inc	si
magloop:
	xor	ax,ax
	test	dx,bx
	jz	hi0
	not	ah
;	dec	ah		;this is for white lines around fat pels
hi0:	ror	bx,1
	test	dx,bx
	jz	low0
	not	al
;	dec	al
low0:	stosw
	ror	bx,1
	jc	next_source
	loop	magloop
	jmp	magdone
;
next_source:
	mov	dx,[si]
	inc	si
	inc	si
	loop	magloop
;
magdone:
	pop	es
	pop	ds
	pop	bp
	ret
;

CODE ENDS
END
