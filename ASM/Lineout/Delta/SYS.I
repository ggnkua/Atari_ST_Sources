; system rout library, by earx.

System.init:
	bsr.s	getCpu
	move.w	d0,cpu_model
	rts

; Reads system's cpu cookie. Beware, must be in supervisor mode.
; OUTPUT:
; d0.l=cpu type
getCpu:	clr.l	d0
	movea.l	$05A0.w,a0
	tst.l	a0
	beq.s	.end
.loop:	cmpi.l	#"_CPU",(a0)
	beq.s	.found
	addq	#8,a0
	bra.s	.loop
.found:	move.l	4(a0),d0
.end:	rts

; Flushes and disables the instruction cache.
; Also saves the cacr in old_cacr.
flushAndDisableICache:
	movec	cacr,d0
	move.l	d0,old_cacr

	bset	#11,d0					; clear d cache 030
	bclr	#8,d0					; d cache 030 off
	bclr	#31,d0					; d cache 040 off

	bset	#3,d0					; clear i cache 030
	bclr	#4,d0					; i burst 030 off
	bclr	#0,d0					; i cache 030 off
	bclr	#15,d0					; i cache 040 off 
	movec	d0,cacr

	cmpi.w	#40,cpu_model
	blt.s	.end

	dc.w	$f4f8					; cpusha bc
;	cpusha	bc					; Flush both 040/060 caches!

.end:	rts

; Restores saved cacr state.
; PRE: cacr is saved in old_cacr
restoreCache:
	move.l	old_cacr,d0
	movec	d0,cacr
	rts

	bss

cpu_model:
	ds.w	1
old_cacr:
	ds.l	1
