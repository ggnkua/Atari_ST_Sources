
;+
; gparmfc() - get the current drive parameters for the C code
;
; gparmfc(addcyl, addhd, addspt, buf)
; char *addcyl;		$4(sp).l	/* the address of #cyl */
; char *addhd;		$8(sp).l	/* the address of #hd */
; char *addspt;		$c(sp).l 	/* the address of #spt */
; char *buf;		$10(sp).l	/* the address of the date buffer */
; 
; returns: put the values of #cyl, #hd, #spt into the given addresses 
;-
	.globl _gparmfc
_gparmfc:
	move.l $10(sp),-(sp); push the buffer address into the stack
	bsr	   _gcparm		;
	adda   #4,sp		; clean up stack
	move.l $4(sp),a0	; a0 -> data buffer
	move.w d0,(a0)		; move the #cyl into its addr
	move.l $8(sp),a0	; a0 -> data buffer
	move.w d1,(a0)		; move the #hd into its addr
	move.l $c(sp),a0	; a0 -> data buffer
	move.w d2,(a0)		; move the #spt into its addr
	rts

