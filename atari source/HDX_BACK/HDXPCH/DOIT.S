;+
; Edit History
;
; May-18-89	ml.	Started this.
; Aug-21-89	ml.	Added format code.
;-

.include	"defs.h"

.extern	_spscsixst

;+
; doscmd() - send a simple command (no DMA involved)
;
; Passed:
;	d0.w = physical unit number
;	d2.w = command length (NCMD or LCMD)
;-
	.globl	_doscmd
	.extern	_smplacsi
	.extern	_smplspscsi
	.extern	_smplscsi
_doscmd:
	btst	#3,d0			; SCSI unit?
	bne.s	.0			; if so, use the SCSI protocol
	bsr	_smplacsi		; else, use the ACSI protocol
	bra.s	dosend
.0:	tst.b	_spscsixst		; Sparrow SCSI?
	beq.s	.1			; if not, it's regular SCSI
	bsr	_smplspscsi
	bra.s	dosend
.1:	bsr	_smplscsi
dosend:	rts


;+
; dorcmd() - send a command which will receive data from the target
;
; Passed:
;	d0.w = physical unit number
;	d1.l = transfer length (in bytes)
;	d2.w = command length (NCMD or LCMD)
;	a0.l = buffer address
;-
	.globl	_dorcmd
	.extern	_rcvacsi
	.extern	_rcvspscsi
	.extern	_rcvscsi
_dorcmd:
	btst	#3,d0			; SCSI unit?
	bne.s	.0			; if so, use the SCSI protocol
	bsr	_rcvacsi		; else, use the ACSI protocol
	bra.s	dorend
.0:	tst.b	_spscsixst		; Sparrow SCSI?
	beq.s	.1			; if not, it's regular SCSI
	bsr	_rcvspscsi
	bra.s	dorend
.1:	bsr	_rcvscsi
dorend:	rts

	
;+
; dowcmd() - send a command which will write data to the target
;
; Passed:
;	d0.w = physical unit number
;	d1.l = transfer length (in bytes)
;	d2.w = command length (NCMD or LCMD)
;	a0.l = buffer address
;-
	.globl	_dowcmd
	.extern	_wrtacsi
	.extern	_wrtspscsi
	.extern	_wrtscsi
_dowcmd:
	btst	#3,d0			; SCSI unit?
	bne.s	.0			; if so, use the SCSI protocol
	bsr	_wrtacsi		; else, use the ACSI protocol
	bra.s	dowend
.0:	tst.b	_spscsixst		; Sparrow SCSI?
	beq.s	.1			; if not, it's regular SCSI
	bsr	_wrtspscsi
	bra.s	dowend
.1:	bsr	_wrtscsi
dowend:	rts

	


