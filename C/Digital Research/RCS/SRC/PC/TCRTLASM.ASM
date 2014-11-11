;/*	TCRTLASM.ASM	4/18/84 - 10/24/84	Lee Jay Lorenzen	*/
;/*	modified for MASM	    01/31/85	Tom Rolander		*/
;
;
; Copyright 1999 by Caldera Thin Clients, Inc.
; This software is licenced under the GNU Public License
; Please see LICENSE.TXT for further information.
PGROUP	GROUP	CODE

DGROUP	GROUP	DATA

DATA	SEGMENT PARA PUBLIC 'DATA'
DATA	ENDS

CODE	SEGMENT	BYTE PUBLIC 'CODE'
	ASSUME	CS:PGROUP
	ASSUME	DS:DGROUP

	PUBLIC	cxc33, cxm33, cxd33
;
;
cxc33:
	push	bx
	push	dx
	cmp	ax,cx
	jnz	cxc1
	shr	bx,1
	shr	dx,1
	cmp	bx,dx
	jnz	cxc1
	pop	dx
	pop	bx
	cmp	bx,dx
	jmp	cxc2
cxc1:
	pop	dx
	pop	bx
cxc2:
	ret
;
;
cxd33:
	xchg	ax,bx
	mov	cx,dx
	jcxz	div0
	cmp	cx,1
	jne	not_div1
	xchg	ax,bx
	xor	cx,cx
	mov	dx,cx
	ret
not_div1:
	xor	dx,dx
	xchg	ax,bx
	push	ax
	div	cx
	mov	di,ax
	mul	cx
	pop	dx
	sub	dx,ax
	mov	ax,bx
	div	cx
	sub	cx,cx
	mov	bx,ax
	mov	ax,di
	ret
div0:
	mov	ax,-1
	mov	bx,ax
	ret
;
;
cxm33:
	push	dx
	mul	dx
	pop	dx
	push	ax
	mov	ax,bx
	push	dx
	mul	cx
	mov	cx,ax
	mov	ax,bx
	pop	dx
	mul	dx
	add	dx,cx
	pop	cx
	add	dx,cx
	mov	bx,ax
	mov	ax,dx
	ret
;
;
public	umul_div
public	mul_div

;
;***************************************************************************
;
; MUL_DIV (m1,m2,d1)
;
;	 ( ( ( m1 * 2 * m2 ) / d1 ) + 1 ) / 2	
;	m1 = signed 16 bit integer
;	m2 = unsigned 15 bit integer
;	d1 = signed 16 bit integer
;
;***************************************************************************
MUL_DIV:
	push	bp		;save the callers bp
	mov	bp,sp
	mov	ax,06[bp]
	shl	ax,1		; m2 * 2
	mov	bx,04[bp]
	imul	bx		; m2 * 2 * m1
	mov	bx,08[bp]
	idiv	bx		; m2 * 2 * m1 / d1
	and	ax,ax		; set flags
	js	mul_div_neg
	inc	ax
	shr	ax,1		; m2 * 2 * m1 / d1 +1 / 2
	pop	bp
	ret
mul_div_neg:
	add	ax,-1
	neg	ax
	shr	ax,1
	neg	ax		; m2 * 2 * m1 / d1 -1 / 2
	pop	bp
	ret
;
;***************************************************************************
;
; UMUL_DIV (m1,m2,d1)
;
;	 ( ( ( m1 * 2 * m2 ) / d1 ) + 1 ) / 2	
;	m1 = usigned 16 bit integer
;	m2 = unsigned 15 bit integer
;	d1 = usigned 16 bit integer
;
;***************************************************************************
UMUL_DIV:
	push	bp		;save the callers bp
	mov	bp,sp
	mov	ax,06[bp]
	shl	ax,1		; m2 * 2
	mov	bx,04[bp]
	mul	bx		; m2 * 2 * m1
	mov	bx,08[bp]
	div	bx		; m2 * 2 * m1 / d1
	inc	ax
	shr	ax,1		; m2 * 2 * m1 / d1 +1 / 2
	pop	bp
	ret

CODE	ENDS

	end
