;+
; Edit History
;
; Sep-05-90	ml.	Definitions of constants for the AT disk interface
;			(wrt PrairieTek 120 drive.)
;-



; Command codes for AT disk interface

RECAL		equ	$10		; Recalibrate
READ		equ	$20		; Read Sector(s)
WRITE		equ	$30		; Write Sector(s)
VERIFY		equ	$40		; Read Verify Sector(s)
FMTTRK		equ	$50		; Format Track
SEEK		equ	$70		; Seek
DIAG		equ	$90		; Execute Drive Diagnostic
INITPARM	equ	$91		; Initialize Drive Parameters
RSBUF		equ	$e4		; Read Sector Buffer
WSBUF		equ	$e8		; Write Sector Buffer
IDENTIFY	equ	$ec		; Identify Drive
					; Standby Commands
STANDBY		equ	$e0		; go to STANDBY mode
ACTIVE		equ	$e1		; go to ACTIVE mode
SBWTO		equ	$e2		; StandBy mode With Time-Out
AWTO		equ	$e3		; Active mode With Time-Out
SSC		equ	$e5		; Set Sector Count wrt current mode
SBRES		equ	$e6		; StandBy until RESet



; Command Modifiers

NO_RETRIES	equ	$01		; no retries
LCMD		equ	$02		; long command



; Time-outs
D_WORST		equ	2000		; worst case delay (10s)



GPIP		equ	$fffffa01

; AT disk interface I/O locations for Read functions

bAT	equ	$FFF00000+REGBASE	; base address

ATDR	equ	bAT-REGBASE+($00*REGLSTEP); Data Register (16-bit reg)
ATER	equ	bAT+($01*REGLSTEP)	; Error Register
ATSC	equ	bAT+($02*REGLSTEP)	; Sector Count
ATSN	equ	bAT+($03*REGLSTEP)	; Sector Number
ATCL	equ	bAT+($04*REGLSTEP)	; Cylinder Low
ATCH	equ	bAT+($05*REGLSTEP)	; Cylinder High (2 bits)
ATSDH	equ	bAT+($06*REGLSTEP)	; SDH register
ATSR	equ	bAT+($07*REGLSTEP)	; Status Register
ATASR	equ	bAT+($0E*REGLSTEP)	; Alternate Status Register
ATDAR	equ	bAT+($0F*REGLSTEP)	; Drive Address Register



; AT disk interface I/O locations for Write functions

;ATDR	equ	bAT-REGBASE+($00*REGLSTEP); Data Register (16-bit reg)
ATWPR	equ	bAT+($01*REGLSTEP)	; Write Precomp Register (not used)
;ATSC	equ	bAT+($02*REGLSTEP)	; Sector Count
;ATSN	equ	bAT+($03*REGLSTEP)	; Sector Number
;ATCL	equ	bAT+($04*REGLSTEP)	; Cylinder Low
;ATCH	equ	bAT+($05*REGLSTEP)	; Cylinder High (2 bits)
;ATSDH	equ	bAT+($06*REGLSTEP)	; SDH register
ATCR	equ	bAT+($07*REGLSTEP)	; Command Register
ATDOR	equ	bAT+($0E*REGLSTEP)	; Digital Output Register



; Bit assignments in Error Register

BBK		equ	7		; 1: bad block detected
UNC		equ	6		; 1: non-correctable data error
;		equ	5		; not used
IDNF		equ	4		; 1: requested ID not found
;		equ	3		; not used
ABRT		equ	2		; 1: aborted command error
TK0		equ	1		; 1: track 0 not found error
DMNF		equ	0		; 1: data mark not found



; Bit assignments in Status Register

BSY		equ	7		; 1: drive busy
DRDY		equ	6		; 1: drive ready
DWF		equ	5		; 1: write fault detected
DSC		equ	4		; 1: actuator on track
DRQ		equ	3		; 1: ready to transfer
CORR		equ	2		; 1: data error corrected
IDX		equ	1		; 1: disk revolution completed
ERR		equ	0		; 1: error occurred

	
; Byte indices into buffer return by the Identify command

NCYL	equ	2		; Number of fixed cylinders
NHEAD	equ	6		; Number of heads
NSPT	equ	12		; Number of physical sectors/track


