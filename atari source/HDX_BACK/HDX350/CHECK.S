;+
;  CHECK.S - check for existence of different components in system.
;-

.include	"defs.h"
.include	"68030.s"

REGBASE	equ	1			; most are on odd part of data bus
bSCSI	equ	$FFFF8780+REGBASE

;+
; chkscsi() - Check if SCSI exists
;
; Uses: d0, d1, d2, a0, a1
;-
	.globl	_chkscsi
_chkscsi:				; check if SCSI exists
	move.l	#0,savssp		; no stack pointer is saved yet
	move.l	#1,-(sp)		; find out what mode processor is in
	move.w	#$20,-(sp)		; Super(1L)
	trap	#1
	addq.w	#6,sp			; clean up stack
	tst.w	d0			; in Supervisor mode already?
	bne.s	tscsi			; if so, go test for SCSI
	clr.l	-(sp)			; else go to Supervisor mode
	move.w	#$20,-(sp)		; Super(0L)
	trap	#1
	addq.w	#6,sp			; clean up stack
	move.l	d0,savssp		; save original stack pointer
tscsi:	clr.w	result			; assume SCSI doesn't exist
	movea.l	BERR,a0			; save original bus error vector
	move.l	#nscsi,BERR		; install our own vector
	movea.l	sp,a1			; save current stack pointer
	move.b	bSCSI,d1		; try to access the SCSI bus
	move.w	#1,result		; if no bus error, SCSI exists
nscsi:	move.l	a0,BERR			; restore original bus error vector
	move.l	a1,sp			; restore stack pointer
chkret:	tst.l	savssp			; were we in User mode when started?
	beq.s	tend			; if not, just return
	move.l	savssp,-(sp)		; go back to User mode 
	move.w	#$20,-(sp)		; Super(savssp)
	trap	#1
	addq.w	#6,sp			; clean up stack
tend:	move.w	result,d0		; d0 = result
	rts


;+
; chkcache() - Check if '030 cache exists
;
; Uses: d0, d1, d2, a0, a1
;-
	.globl	_chkcache
_chkcache:				; check if '030 cache exists
	move.l	#0,savssp		; no stack pointer is saved yet
	move.l	#1,-(sp)		; find out what mode processor is in
	move.w	#$20,-(sp)		; Super(1L)
	trap	#1
	addq.w	#6,sp			; clean up stack
	tst.w	d0			; in Supervisor mode already?
	bne.s	tcache			; if so, go test for cache
	clr.l	-(sp)			; else go to Supervisor mode
	move.w	#$20,-(sp)		; Super(0L)
	trap	#1
	addq.w	#6,sp			; clean up stack
	move.l	d0,savssp		; save original stack pointer
tcache:	clr.w	result			; assume cache doesn't exist
	movea.l	IINS,a0			; save orig illegal instrn vector
	move.l	#ncache,IINS		; install our own vector
	movea.l	sp,a1			; save current stack pointer
	movecacrd0			; does a cache exist?
	move.w	#1,result		; if so, set result
ncache:	move.l	a0,IINS			; restore orig illegal instrn vector
	move.l	a1,sp			; restore stack pointer
	bra	chkret


.bss
savssp:	ds.l	1			; stack pointer
result:	ds.w	1
