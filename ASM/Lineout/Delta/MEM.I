; memory management object.

; Resets internal administration.
Mem.init:
	clr.l	Mem.max
	rts

; Takes max mem needed out of all register calls. The returned block is
; longword aligned.
; OUTPUT:
; d0.l: blockaddress (0: failed)
Mem.take:
; Increase blocksize to account for alignment.
	move.l	Mem.max,d0
	addq.l	#3,d0

; Allocate block.
	move.l	d0,-(sp)
	move.w	#$48,-(sp)
	trap	#1
	addq	#6,sp
	tst.l	d0
	beq.s	.end

; Save address, for eventual freeing up of block.
	move.l	d0,Mem.adr

; Align address to longword.
	addq.l	#3,d0
	andi.w	#%1111111111111100,d0

.end:	rts

; INPUT:
; d0.l=size of block (bytes)
Mem.register:
	cmp.l	Mem.max,d0
	bls.s	.end
	move.l	d0,Mem.max
.end:	rts

; Frees up all taken mem.
Mem.free:
	move.l	Mem.max,-(sp)
	move.w	#$49,-(sp)
	trap	#1
	addq	#6,sp
	rts

; OUTPUT:
; d0.l: block address
Mem.getBlock:
	move.l	Mem.adr,d0
	rts

	bss

Mem.max:ds.l	1					; allocated size
Mem.adr:ds.l	1					; address of allocated block