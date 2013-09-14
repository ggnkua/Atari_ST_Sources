;+
; initblit() - initialize the BLiTTER chip for 512 bytes I/O transfer
;
; Passed:
;	a0.l = destination address if read; source address if write
;	d0.w = flag to tell whether it's a read or a write
;-
initblit:
	lea	bBLiTTER,a1		; a1 -> BLiTTER register map
	tst.b	d0			; read or write?
	bne.s	ib0			; (write)
	move.l	#IDEDR,SRCADDR(a1)	; source addr = IDE data register
	move.l	a0,DESTADDR(a1)		; destination addr = given buffer
	move.w	#2,DESTXINC(a1)		; words read
	moveq	#0,d0
	move.w	d0,SRCXINC(a1)		; never increment source X
	bra.s	ib1
					; initialize BLiTTER to write to disk
ib0:	move.l	a0,SRCADDR(a1)		; source addr = write buffer
	move.l	#IDEDR,DESTADDR(a1)	; destination addr = IDE data reg
	move.w	#2,SRCXINC(a1)		; words write
	moveq	#0,d0
	move.w	d0,DESTXINC(a1)		; never increment destination X

ib1:	move.w	d0,SRCYINC(a1)		; never increment source Y
	move.w	d0,DESTYINC(a1)		; never increment destination Y
	move.b	d0,SKEW(a1)		; no skew
	moveq	#$ff,d0
	move.l	d0,ENDMASK1(a1)		; change all bits at destination
	move.w	d0,ENDMASK3(a1)		; change all bits at destination
	move.w	#$203,HOP(a1)		; set HOP and OP to source
	move.w	#256,XCNT(a1)		; num of words to transfer
	rts


;+
; restart() - restart the BLiTTER
;
; Passed:
;	a1.l = base address of BLiTTER
;-
restart:
	nop
	tas	BUSY(a1)	; restart BLiTTER and test if busy
	bmi.s	restart		; quit if not busy
	rts


;+
; readbuf() - reads 512 bytes (128 longs) of data from the sector
;		buffer.
;
; Comments:
;	A tower of 8 move.l is used to try to speed up the transfer.
;
; Passed:
;	a0.l = buffer to store data read from sector buffer
;
;	if BLiTTER code
;	a1.l = base address of BLiTTER
;-
readbuf:
	move.w	#1,YCNT(a1)	; one destination line
	move.b	#$80,BUSY(a1)	; start the BLiTTER
	bsr	restart
	addq.l	#2,DESTADDR(a1)	; advance to next word of destination
	rts


;+
; wrtbuf() - writes 512 bytes (128 longs) of data to sector buffer.
;
; Passed:
;	a0.l = buffer with data to write to sector buffer
;-
wrtbuf:
	move.w	#1,YCNT(a1)	; one destination line
	move.b	#$80,BUSY(a1)	; start the BLiTTER
	bsr	restart
	addq.l	#2,SRCADDR(a1)	; advance to next word of source
	rts

