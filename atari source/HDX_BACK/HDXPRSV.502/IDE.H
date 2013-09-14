;+
; Edit History
;
; Sep-05-90	ml.	Definitions of constants for the IDE disk interface
;			(wrt PrairieTek 120 drive.)
;-



; Command codes for IDE disk interface

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



; IDE disk interface I/O locations for Read functions

bIDE	equ	$FFF00000+REGBASE	; base address

IDEDR	equ	bIDE-REGBASE+($00*REGLSTEP); Data Register (16-bit reg)
IDEER	equ	bIDE+($01*REGLSTEP)	; Error Register
IDESC	equ	bIDE+($02*REGLSTEP)	; Sector Count
IDESN	equ	bIDE+($03*REGLSTEP)	; Sector Number
IDECL	equ	bIDE+($04*REGLSTEP)	; Cylinder Low
IDECH	equ	bIDE+($05*REGLSTEP)	; Cylinder High (2 bits)
IDESDH	equ	bIDE+($06*REGLSTEP)	; SDH register
IDESR	equ	bIDE+($07*REGLSTEP)	; Status Register
IDEASR	equ	bIDE+($0E*REGLSTEP)	; Alternate Status Register
IDEDAR	equ	bIDE+($0F*REGLSTEP)	; Drive Address Register



; IDE disk interface I/O locations for Write functions

;IDEDR	equ	bIDE-REGBASE+($00*REGLSTEP); Data Register (16-bit reg)
IDEWPR	equ	bIDE+($01*REGLSTEP)	; Write Precomp Register (not used)
;IDESC	equ	bIDE+($02*REGLSTEP)	; Sector Count
;IDESN	equ	bIDE+($03*REGLSTEP)	; Sector Number
;IDECL	equ	bIDE+($04*REGLSTEP)	; Cylinder Low
;IDECH	equ	bIDE+($05*REGLSTEP)	; Cylinder High (2 bits)
;IDESDH	equ	bIDE+($06*REGLSTEP)	; SDH register
IDECR	equ	bIDE+($07*REGLSTEP)	; Command Register
IDEDOR	equ	bIDE+($0E*REGLSTEP)	; Digital Output Register



; Byte offset from beginning of buffer return by the Identify command

NCYL	equ	2		; offset to # of fixed cylinders
NHEAD	equ	6		; offset to # of heads
NSPT	equ	12		; offset to # of physical sectors/track
MDLNUM	equ	54		; offset to model number of drive
EMDL	equ	94		; offset to end of model number
CONMDL	equ	MDLNUM+26	; offset to Conner's model number
CPNCYL	equ	260		; offset to # of cylinders (Conner)
CPNHEAD	equ	262		; offset to # of heads (Conner)
CPNSPT	equ	263		; offset to # of sectors/track (Conner)

; Default drive parameters of Conner Peripherals - CP2024
CP20NCYL	equ	615	; # of cylinders
CP20NHEAD	equ	4	; # of heads
CP20NSPT	equ	17	; # of sectors/track


; Address of the Programmable Sound Generator Port A

PSGA	equ	$ffff8802
IDERST	equ	6

.if	!DRIVER

IDERDY	    equ	    1000    ; delay to wait for IDE drive to be ready

.endif	;DRIVER
