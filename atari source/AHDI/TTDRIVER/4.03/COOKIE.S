;+
; Cookie.s contains routines that deal with the cookie jar which is put in
; ROM starting with TOS 1.6 (TOS for the STE)
;
; 07-Sep-1989	ml.	Started this.
;-

include	"sysvar.h"

;+
; Getcookie() - To find a cookie and its value
;
; int getcookie(cookie, p_value)
; LONG	cookie;		4(sp).l
; LONG	*p_value;	8(sp).l
;
; Returns:
;	    0: if cookie is NOT found in the cookie jar.
;	non-0: if cookie is found, and places its value in the
;		longword pointed to by p_value.
;
; Comments:
;	If p_value is NULL, the value won't be put anywhere, but still
; returns a return code.
;
; Trashes: d0, d1, a0, a1
;-
	.globl	_getcookie
_getcookie:
	move.l	d3,-(sp)	; save d3
	clr.l	oldssp		; assume already in Super mode
	move.l	#1,-(sp)	; Super(1L)
	move.w	#$20,-(sp)
	trap	#1
	addq.w	#6,sp		; clean up stack
	tst.w	d0		; in Super mode already?
	bne.s	.0		; if so, fine
	clr.l	-(sp)		; else go to Super mode
	move.w	#$20,-(sp)	; Super(0L)
	trap	#1
	addq.w	#6,sp		; clean up stack
	move.l	d0,oldssp	; save original stack pointer

.0:	moveq	#0,d3		; assume there is no cookie jar
	tst.l	_p_cookie	; does cookie jar exist?
	beq.s	.3		; if cookie jar does not exist, return error
	
	move.l	8(sp),d0	; d0 = target cookie
	move.l	_p_cookie,a0	; a0 = addr of beginning of cookie jar
.1:	move.l	(a0),d1		; d1 = next cookie in the cookie jar
	beq.s	.3		; if no more cookie, return
	cmp.l	d1,d0		; else is it the cookie that we want?
	beq.s	.2		; if so, ==> cookie found
	addq.w	#8,a0		; a0 = address of next cookie
	bra.s	.1

.2:	moveq	#1,d3		; cookie found
	tst.l	$c(sp)		; p_value == NULL?
	beq.s	.3		; if so, don't return cookie value
	movea.l	$c(sp),a1	; a1 -> cookie value
	move.l	4(a0),(a1)	; return cookie value also
	
.3:	tst.l	oldssp		; need to go back to user mode?
	beq.s	getcend		; if not, return
	move.l	oldssp,-(sp)	; else go back to user mode
	move.w	#$20,-(sp)	; Super(oldssp)
	trap	#1
	addq.w	#6,sp		; clean up stack
getcend:
	move.l	d3,d0		; return with appropiate return code
	move.l	(sp)+,d3	; restore d3
	rts

oldssp:	dc.l	0

