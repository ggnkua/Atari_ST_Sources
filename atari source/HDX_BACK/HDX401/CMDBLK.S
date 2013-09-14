;+
; Edit History
;
; May-19-89	ml.	Started this with.
; Sep-14-89	ml.	Make sure transfer length in d1 for rqsense()
;			is non-0 before entering _dorcmd().  Else there
;			will a divide by zero in _dorcmd().
;-

.include	"defs.h"

.extern	_doscmd		; do a simple command.  No DMA involved.
.extern	_dorcmd		; do a receive command.  DMA data back.
.extern	_dowcmd		; do a write command.  DMA data away.


;+
; OPCODES for standard SCSI and ACSI commands
;-
TSTUNT	equ	$00
RZUNT	equ	$01
RQSEN	equ	$03
FMTUNT	equ	$04
RABLK	equ	$07
READ	equ	$08
WRITE	equ	$0a
SEEK	equ	$0b
INQRY	equ	$12
MDSEL	equ	$15
RLEAS	equ	$17
MDSEN	equ	$1a
STUNIT	equ	$1b
RDIAG	equ	$1c
SDIAG	equ	$1d
RMEDIA	equ	$1e
RDCAP	equ	$25		; SCSI only
XREAD	equ	$28		; SCSI only
XWRT	equ	$2a		; SCSI only
XSEEK	equ	$2b		; SCSI only
VERIFY	equ	$2f		; SCSI only
RDDFCT	equ	$37		; SCSI only
WRTBUF	equ	$3b		; SCSI only
RDBUF	equ	$3c		; SCSI only

;+
; EQUATES
;-
NCMD		equ	6	; normal command length (6 bytes)
LCMD		equ	10	; extended command length (10 bytes)

;+
; DECLARATIONS
;-
		.globl	_cmdblk
_cmdblk:	dcb.b	10,0	; command block
.even


;+
; untrdy() - set up and send command block of the TEST UNIT READY command.
;
; untrdy(pdev)
; WORD	pdev;		$4(sp).w
;-
	.globl	_untrdy
_untrdy:
	bsr	clrcmdblk		; clear command block
	lea	_cmdblk,a0		; a0 -> beginning of command block
	move.b	#TSTUNT,(a0)		; byte 0 = TSTUNT opcode
					; byte 1-5 = reserved
	move.w	$4(sp),d0		; d0 = physical unit number
	moveq	#NCMD,d2		; d2 = length of command
	bsr	_doscmd			; send the command
	rts


;+
; rqsense() - set up and send command block of the REQUEST SENSE command.
;	      (only the lsb of len is used)
;
; rqsense(pdev, len, buf)
; WORD	pdev;		$4(sp).w	; physical unit number
; WORD	len;		$6(sp).w	; amount of sense data (in bytes)
; BYTE	*buf;		$8(sp).l	; buffer for sense data
;-
	.globl	_rqsense
_rqsense:
	bsr	clrcmdblk		; clear command block
	lea	_cmdblk,a0		; a0 -> beginning of command block
	move.b	#RQSEN,(a0)		; byte 0 = RQSEN opcode
	move.b	$7(sp),4(a0)		; byte 4 = allocation length 
					; byte 1-3 and 5 = reserved
	moveq	#4,d1			; request at least 4 bytes
	cmp.w	$6(sp),d1		; requesting < 4 bytes?
	bcc.s	.0			; if so, request 4 bytes
	move.w	$6(sp),d1		; else d1 = requested len (in #bytes)
.0:	move.w	$4(sp),d0		; d0 = physical unit number
	moveq	#NCMD,d2		; d2 = length of command
	movea.l	$8(sp),a0		; a0 = buffer for sense data
	bsr	_dorcmd			; send the command
	rts


.if	!DRIVER				; not to be included in driver

;+
; format() - set up and send command block of the FORMAT UNIT command.
;
; format(pdev, interleave)
; WORD	pdev;		$4(sp).w
; WORD	interleave	$6(sp).w
;-
	.globl	_format
	.extern	_doformat
_format:
	bsr	clrcmdblk		; clear command block
	lea	_cmdblk,a0		; a0 -> beginning of command block
	move.b	#FMTUNT,(a0)		; byte 0 = FMTUNT opcode
	move.b	$6(sp),3(a0)		; byte 3 = interleave (msb)
	move.b	$7(sp),4(a0)		; byte 4 = interleave (lsb)
					; byte 1-2 = unused; byte 5 = reserved
	move.w	$4(sp),d0		; d0 = physical unit number
	moveq	#NCMD,d2		; d2 = length of command
	bsr	_doformat		; send the command
	rts

.endif	;!DRIVER

;+
; hread() - set up and send command block of the READ command.
;
; hread(sectnum, count, buf, pdev)
; LONG	sectnum		4(sp).l
; WORD	count		8(sp).w
; BYTE	*buf;		$a(sp).l	$b(sp)=high $c(sp)=mid $d(sp)=low
; WORD	pdev;		$e(sp).w
;-
	.globl	_hread
_hread:	lea	_cmdblk,a0		; a0 -> beginning of command block
	move.b	#READ,(a0)+		; byte 0 = READ opcode
	move.b	5(sp),(a0)+		; byte 1 = msb of logical block addr
	move.b	6(sp),(a0)+		; byte 2 = logical block addr
	move.b	7(sp),(a0)+		; byte 3 = lsb of logical block addr
	move.b	9(sp),(a0)+		; byte 4 = transfer length (in blocks)
	clr.b	(a0)			; byte 5 = control byte
	move.w	$e(sp),d0		; d0 = physical unit number
	moveq	#0,d1			; clear d1
	move.w	8(sp),d1		; d1 = transfer length (in bytes)
	lsl.l	#8,d1			;    = # blocks * 512
	add.l	d1,d1
	moveq	#NCMD,d2		; d2 = length of command
	movea.l	$a(sp),a0		; a0 = read buffer
	bsr	_dorcmd			; send the command
	rts


;+
; hwrite() - set up and send command block of the WRITEcommand.
;
; hwrite(sectnum, count, buf, pdev)
; LONG	sectnum		4(sp).l
; WORD	count		8(sp).w
; BYTE	*buf;		$a(sp).l	$b(sp)=high $c(sp)=mid $d(sp)=low
; WORD	pdev;		$e(sp).w
;-
	.globl	_hwrite
_hwrite:
	lea	_cmdblk,a0		; a0 -> beginning of command block
	move.b	#WRITE,(a0)+		; it's a read; byte 0 = READ opcode
	move.b	5(sp),(a0)+		; byte 1 = msb of logical block addr
	move.b	6(sp),(a0)+		; byte 2 = logical block addr
	move.b	7(sp),(a0)+		; byte 3 = lsb of logical block addr
	move.b	9(sp),(a0)+		; byte 4 = transfer length (in blocks)
	clr.b	(a0)			; byte 5 = control byte
	move.w	$e(sp),d0		; d0 = physical unit number
	moveq	#0,d1			; clear d1
	move.w	8(sp),d1		; d1 = transfer length (in bytes)
	lsl.l	#8,d1
	add.l	d1,d1
	moveq	#NCMD,d2		; d2 = length of command
	movea.l	$a(sp),a0		; a0 = write buffer
	bsr	_dowcmd			; send the command
	rts


;+
; inquiry() - set up and send command block of the INQUIRY command.
;
; inquiry(pdev, len, buf)
; WORD	pdev;		$4(sp).w	; physical unit number
; WORD	len;		$6(sp).w	; amount requested (in bytes)
; BYTE	*buf;		$8(sp).l	; buffer for inquiry data
;-
	.globl	_inquiry
_inquiry:
	bsr	clrcmdblk		; clear command block
	lea	_cmdblk,a0		; a0 -> beginning of command block
	move.b	#INQRY,(a0)		; byte 0 = INQRY opcode
	move.b	$7(sp),4(a0)		; byte 4 = allocation length 
					; byte 1-3 and 5 = reserved
	move.w	$4(sp),d0		; d0 = physical unit number
	moveq	#0,d1			; clear d1
	move.w	$6(sp),d1		; d1.l = transfer length (in bytes)
	moveq	#NCMD,d2		; d2 = length of command
	movea.l	$8(sp),a0		; a0 = buffer for sense data
	bsr	_dorcmd			; send the command
	rts


.if	!DRIVER				; not to be included in driver

;+
; mdselect() - set up and send command block of the MODE SELECT command.
;
; mdselect(pdev, len, buf)
; WORD	pdev;		$4(sp).w	; physical unit number
; WORD	len;		$6(sp).w	; parameter list length (in bytes)
; BYTE	*buf;		$8(sp).l	; buffer for inquiry data
;-
	.globl	_mdselect
_mdselect:
	bsr	clrcmdblk		; clear command block
	lea	_cmdblk,a0		; a0 -> beginning of command block
	move.b	#MDSEL,(a0)		; byte 0 = MDSEL opcode
	move.b	$7(sp),4(a0)		; byte 4 = parameter list length 
					; byte 1-3 and 5 = reserved
	move.w	$4(sp),d0		; d0 = physical unit number
	moveq	#0,d1			; clear d1
	move.w	$6(sp),d1		; d1.l = transfer length (in #bytes)
	moveq	#NCMD,d2		; d2 = length of command
	movea.l	$8(sp),a0		; a0 = buffer for sense data
	bsr	_dowcmd			; send the command
	rts


;+
; mdsense() - set up and send command block of the MODE SENSE command.
;
; mdsense(pdev, pcode, pcf, len, buf)
; WORD	pdev;		$4(sp).w	; physical unit number
; WORD	pcode;		$6(sp).w	; page code (must be 0 if ACSI)
; WORD	pcf;		$8(sp).w	; pcf value (must be 0 if ACSI)
; WORD	len;		$a(sp).w	; parameter list length (in bytes)
; BYTE	*buf;		$c(sp).l	; buffer for inquiry data
;-
	.globl	_mdsense
_mdsense:
	bsr	clrcmdblk		; clear command block
	move.w	8(sp),d0		; d0 = pcf value
	lsl.w	#6,d0			; shift pcf value to bit 6 and 7
	or.b	7(sp),d0		; d0 = pcf value | pcode
	lea	_cmdblk,a0		; a0 -> beginning of command block
	move.b	#MDSEN,(a0)		; byte 0 = MDSEN opcode
	move.b	d0,2(a0)		; byte 2 = pcf | pcode
	move.b	$b(sp),4(a0)		; byte 4 = allocation length 
					; byte 1,3 and 5 = reserved
	move.w	$4(sp),d0		; d0 = physical unit number
	moveq	#0,d1			; clear d1
	move.w	$a(sp),d1		; d1 = transfer length (in #bytes)
	moveq	#NCMD,d2		; d2 = length of command
	movea.l	$c(sp),a0		; a0 = buffer for sense data
	bsr	_dorcmd			; send the command
	rts


;+
; stunit() - set up and send command block of the START/STOP UNIT command.
;
; stunit(pdev, flag)
; WORD	pdev;		$4(sp).w	; physical unit number
; WORD	flag;		$6(sp).w	; 0 - stop unit; 1 - start unit;
;-
	.globl	_stunit
	.extern	_dostunit
_stunit:
	bsr	clrcmdblk		; clear command block
	lea	_cmdblk,a0		; a0 -> beginning of command block
	move.b	#STUNIT,(a0)		; byte 0 = STUNIT opcode
	move.b	$7(sp),4(a0)		; byte 4 = reserved + start/stop 
					; byte 1-3 and 5 = reserved
	move.w	$4(sp),d0		; d0 = physical unit number
	moveq	#NCMD,d2		; d2 = length of command
	bsr	_dostunit		; send the command
	rts



;+
; readcap() - set up and send command block of the EXTENDED READ command.
;
; readcap(pdev, pmi, sectnum, buf)
; WORD	pdev;		4(sp).w
; WORD	pmi;		6(sp).w		(only low byte is used)
; LONG	sectnum;	8(sp).l
; BYTE	*buf;		$c(sp).l	$d(sp)=high $e(sp)=mid $f(sp)=low
;-
	.globl	_readcap
_readcap:
	lea	_cmdblk,a0		; a0 -> beginning of command block
	move.b	#RDCAP,(a0)+		; byte 0 = RDCAP opcode
	clr.b	(a0)+			; byte 1 = log unit # + reserved
	move.l	8(sp),(a0)+		; byte 2-5 = logical block addr
	clr.b	(a0)+			; byte 6 = reserved
	clr.b	(a0)+			; byte 7 = reserved
	move.b	7(sp),(a0)+		; byte 8 = partial medium indicator
	clr.b	(a0)			; byte 9 = reserved
	move.w	$4(sp),d0		; d0 = physical unit number
	moveq	#8,d1			; d1 = transfer length (in bytes)
	moveq	#LCMD,d2		; d2 = length of command
	movea.l	$c(sp),a0		; a0 = data buffer
	bsr	_dorcmd			; send the command
	rts

.endif	;!DRIVER


;+
; xtdread() - set up and send command block of the EXTENDED READ command.
;
; xtdread(sectnum, count, buf, pdev)
; LONG	sectnum		4(sp).l
; WORD	count		8(sp).w
; BYTE	*buf;		$a(sp).l	$b(sp)=high $c(sp)=mid $d(sp)=low
; WORD	pdev;		$e(sp).w
;-
	.globl	_xtdread
_xtdread:
	lea	_cmdblk,a0		; a0 -> beginning of command block
	move.b	#XREAD,(a0)+		; byte 0 = XREAD opcode
	clr.b	(a0)+			; byte 1 = unit number + reserved
	move.l	4(sp),(a0)+		; byte 2-5 = logical block addr
	clr.b	(a0)+			; byte 6 = reserved
	move.b	8(sp),(a0)+		; byte 7 = transfer length (msb)
	move.b	9(sp),(a0)+		; byte 8 = transfer length (lsb)
	clr.b	(a0)			; byte 9 = reserved
	move.w	$e(sp),d0		; d0 = physical unit number
	moveq	#0,d1			; clear d1
	move.w	8(sp),d1		; d1 = transfer length (in bytes)
	lsl.l	#8,d1
	add.l	d1,d1
	moveq	#LCMD,d2		; d2 = length of command
	movea.l	$a(sp),a0		; a0 = read buffer
	bsr	_dorcmd			; send the command
	rts


;+
; xtdwrt() - set up and send command block of the EXTENDED READ command.
;
; xtdwrt(sectnum, count, buf, pdev)
; LONG	sectnum		4(sp).l
; WORD	count		8(sp).w
; BYTE	*buf;		$a(sp).l	$b(sp)=high $c(sp)=mid $d(sp)=low
; WORD	pdev;		$e(sp).w
;-
	.globl	_xtdwrt
_xtdwrt:
	lea	_cmdblk,a0		; a0 -> beginning of command block
	move.b	#XWRT,(a0)+		; byte 0 = XWRT opcode
	clr.b	(a0)+			; byte 1 = unit number + reserved
	move.l	4(sp),(a0)+		; byte 2-5 = logical block addr
	clr.b	(a0)+			; byte 6 = reserved
	move.b	8(sp),(a0)+		; byte 7 = transfer length (msb)
	move.b	9(sp),(a0)+		; byte 8 = transfer length (lsb)
	clr.b	(a0)			; byte 9 = reserved
	move.w	$e(sp),d0		; d0 = physical unit number
	moveq	#0,d1			; clear d1
	move.w	8(sp),d1		; d1 = transfer length (in bytes)
	lsl.l	#8,d1
	add.l	d1,d1
	moveq	#LCMD,d2		; d2 = length of command
	movea.l	$a(sp),a0		; a0 = write buffer
	bsr	_dowcmd			; send the command
	rts


;+
; clrcmdblk()
;
; Clear the 10-byte command block
;-
clrcmdblk:
	lea	_cmdblk,a0		; a0 = ptr to command block
	clr.l	(a0)+
	clr.l	(a0)+
	clr.w	(a0)
	rts



