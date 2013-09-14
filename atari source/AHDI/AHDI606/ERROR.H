;+
; BIOS error codes
;-
EDRVNR		equ	-2		; driver not ready
ESEEK		equ	-6		; seek error
EWRITF		equ	-10		; write fault
EREADF		equ	-11		; read fault
EWRPRO		equ	-13		; write on write-protected media
E_CHNG		equ	-14		; media change detected
CRITRETRY	equ	$00010000	; "retry" return code


;+
; Controller error codes for ACSI and SCSI drives
;-
CHKSTATUS	equ	2		; check condition status
DRVNRDY		equ	$4		; drive not ready
WRTPRTD		equ	$27		; write on write-protected media
MDMCHGD		equ	$28		; media change detected


;+
; Bit assignments in Error Register of IDE drive
;-
BBK		equ	7		; 1: bad block detected
UNC		equ	6		; 1: non-correctable data error
;		equ	5		; not used
IDNF		equ	4		; 1: requested ID not found
;		equ	3		; not used
ABRT		equ	2		; 1: aborted command error
TK0		equ	1		; 1: track 0 not found error
DMNF		equ	0		; 1: data mark not found


;+
; Bit assignments in Status Register
;-
BSY		equ	7		; 1: drive busy
DRDY		equ	6		; 1: drive ready
DWF		equ	5		; 1: write fault detected
DSC		equ	4		; 1: actuator on track
DRQ		equ	3		; 1: ready to transfer
CORR		equ	2		; 1: data error corrected
IDX		equ	1		; 1: disk revolution completed
ERR		equ	0		; 1: error occurred

	

