;+
;	test the drive is a SCSI drive or not.
;-

REGBASE	equ		$1
BSCSI	equ		$FFFF8780 + REGBASE
BERR	equ		$8

		.extern	_ttscsi

		.globl	_t_scsi
_t_scsi:
		sf		_ttscsi				; assume SCSI doesn't exist
		movea.l	BERR, a0			; save the original bus error vector
		move.l	#tscsi, BERR		; install our vector
		movea.l	sp, a1				; save the stack pointer
		move.b 	BSCSI, d0			; check the SCSI exist or not
		st		_ttscsi				; SCSI exists
tscsi:	move.l 	a0, BERR			; restore original bus error vector
		move.l 	a1, sp				; restore stack pointer
		rts

