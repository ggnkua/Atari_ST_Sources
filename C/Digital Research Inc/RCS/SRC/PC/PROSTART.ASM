;/*	PROSTART.ASM	05/03/84 -  01/05/85	Lee Lorenzen		*/
;/*	added check for "GEMAES"    01/29/85	Tom Rolander		*/
;/*	modified for MASM	    01/31/85	Tom Rolander		*/
;
; Copyright 1999 by Caldera Thin Clients, Inc.
; This software is licenced under the GNU Public License
; Please see LICENSE.TXT for further information.
PGROUP	GROUP	CODE

DGROUP	GROUP	DATA,PROEND

DATA	SEGMENT PARA PUBLIC 'DATA'
	EXTRN	_VER:BYTE
	EXTRN	_PSP:WORD
PARABEG	dw	0
PARAEND	dw	0
gemaesmsg db	"GEMAES not present in memory."
	db	"$"
memerrmsg db	"Unable to free memory."
	db	"$"
terminmsg db	0dh,0ah
	db	"Execution terminated."
	db	"$"
DATA	ENDS

PROEND	SEGMENT PARA PUBLIC 'DATA'
;
	EXTRN	PROGEND:WORD
;
PROEND	ENDS
;

CODE	SEGMENT	BYTE PUBLIC 'CODE'

	ASSUME	CS:PGROUP
	ASSUME	DS:DGROUP

GLOBAMNT	equ	0
;
;
	EXTRN	GEMAIN:NEAR

	PUBLIC	MAIN
MAIN:
;
;	check for Lattice C 2.1x which already frees up memory

	mov	al,_VER+10
	cmp	al,'2'
	jg	afterfree
	jl	freemem
chknxtdig:
	mov	al,_VER+12
	cmp	al,'0'
	jg	afterfree
;
;	free up any memory we're not using
;		es points at our psp
;
freemem:
	mov	ax,_PSP+2
	mov	PARABEG,ax
	mov	ax,offset dgroup:PROGEND
	add	ax, GLOBAMNT
	add	ax,15
	mov	cl,4
	shr	ax,cl
	mov	cx,ax			; cx = our data size in paragraphs
	mov	bx,ds
	add	bx,cx
	mov	PARAEND,bx
;
;
free_ex:
	mov	ax,PARABEG
	mov	es,ax
	mov	bx,PARAEND
	sub	bx,ax
	mov	ah,4ah
	int	21h
	mov	dx,offset memerrmsg
	jc	errormsg		;jump if set block fails
;
;
afterfree:
;
; check for presence of GEMAES before calling the application
	xor	ax,ax
	mov	es,ax
	mov	bx,es:[3bch]
	mov	ax,es:[3beh]
	mov	es,ax
	mov	di,2
	add	di,bx
	mov	si,offset gemaesmsg
	mov	cx,6
	rep	cmpsb
	jz	runapplication
	mov	dx,offset gemaesmsg
errormsg:
	mov	ah,9
	int	21h
	mov	dx,offset terminmsg
	mov	ah,9
	int	21h
	mov	ax,-1
	jmp	terminate

runapplication:
	mov	ax,ds
	mov	es,ax
	call	GEMAIN

terminate:
	ret			;return to cs

CODE	ENDS
;
	END
