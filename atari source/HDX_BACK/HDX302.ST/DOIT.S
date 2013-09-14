;+
; Edit History
;
; May-18-89	ml.	Started this.
; Aug-21-89	ml.	Added format code.
;-

.include	"defs.h"


;+
; doscmd() - send a simple command (no DMA involved)
;
; Passed:
;	d0.w = physical unit number
;	d2.w = command length (NCMD or LCMD)
;-
	.globl	_doscmd
	.extern	_smplacsi
	.extern	_smplscsi
_doscmd:
	btst	#3,d0			; SCSI unit?
	bne.s	.0			; if so, use the SCSI protocol
	bsr	_smplacsi		; else, use the ACSI protocol
	bra.s	dosend
.0:	bsr	_smplscsi
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
	.extern	_rcvscsi
_dorcmd:
	btst	#3,d0			; SCSI unit?
	bne.s	.0			; if so, use the SCSI protocol
	bsr	_rcvacsi		; else, use the ACSI protocol
	bra.s	dorend
.0:	bsr	_rcvscsi
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
	.extern	_wrtscsi
_dowcmd:
	btst	#3,d0			; SCSI unit?
	bne.s	.0			; if so, use the SCSI protocol
	bsr	_wrtacsi		; else, use the ACSI protocol
	bra.s	dowend
.0:	bsr	_wrtscsi
dowend:	rts

	

.if	!DRIVER				; not to be included in driver

;+
; doformat() - format unit
;
; Passed:
;	d0.w = physical unit number
;	d2.w = command length (NCMD or LCMD)
;-
	.globl	_doformat
	.extern	_fmtacsi
	.extern	_fmtscsi
_doformat:
	btst	#3,d0			; SCSI unit?
	bne.s	.0			; if so, use the SCSI protocol
	bsr	_fmtacsi		; else, use the ACSI protocol
	bra.s	dofend
.0:	bsr	_fmtscsi
dofend:	rts


;+
; dostunit() - start or stop unit
;
; Passed:
;	d0.w = physical unit number
;	d2.w = command length (NCMD or LCMD)
;-
	.globl	_dostunit
	.extern	_stacsi
	.extern	_stscsi
_dostunit:
	btst	#3,d0			; SCSI unit?
	bne.s	dostend			; if so, use the SCSI protocol
;	bne.s	.0			; if so, use the SCSI protocol
	bsr	_stacsi			; else, use the ACSI protocol
;	bra.s	dostend
;.0:	bsr	_stscsi
dostend:
	rts

.endif	;!DRIVER



