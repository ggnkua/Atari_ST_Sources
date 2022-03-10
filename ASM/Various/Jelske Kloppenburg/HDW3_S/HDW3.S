	TTL	"$Id: hdw3.s,v 1.3 1991/09/18 14:35:10 mario Exp $"
*
* Wait for hard disk to spin up
*
* $Log: hdw3.s,v $
* Revision 1.3  1991/09/18  14:35:10  mario
* Added return code at program exit.
*
* Revision 1.2  1991/09/17  15:12:12  mario
* Let the header be done by the assembler.
*
* Revision 1.1  1991/09/17  09:42:38  mario
* Initial revision
*
* Author: mario@tisu1.ti.informatik.uni-frankfurt.de Schulz
*		inspired by Jelske kloppenburg@gmd.de
*
* Send test_unit_ready SCSI command to every target at ACSI.
*
* timeout receiving command == target unavailable
* timeout receiving status == non-standard SCSI (i.e. MegafileXX)
*	wait for status to come with long timeout
* return status check -> rerun test_unit_ready until it succeeds or
*	maximum retry count it reached
*
* To be done:
* 	If the device returns the check flag, a request_sense should
*	be done to check what it really does.
*
* Turn on progress messages with debug not equal to 0
*
debug		equ	1
extended_debug	equ	0
*
* Tuneable parameters section
*
IWait		equ	50	; Initial delay time 250ms
HighTarg	equ	0	; Highest target to be tested (max. 7)
*
ToCycle		equ	80	; Cycles for status timeout (for M60)
ToWait		equ	40	; Cycle time for status timeout 200ms
*
* Do not tweak to often, this might delay the work done for spin-up
BusyCycle	equ	20	; Cycles for busy indication
BusyWait	equ	200	; Cycle time for busy indication 1000ms
*
* Long command waits give delays for unavailable devices, but if some
* device is pretty busy, you might loose synchronisation for the
* command bytes, you had to issue the (unavailable) software reset
* for the SCSI bus. 100ms for an Atari device should be enough!
* Some SCSI device may need 500ms - if the tests for device
* presence take too long, simply turn them off via "HighTarg".
CmdWait		equ	50	; Time for cmd ack 250ms
StatWait	equ	100	; Time for status byte 500ms
*
gpip		equ	$FFFFFA01	; MFP[GPIP]
diskctrl	equ	$FFFF8604	; Controller access reg
dmamode		equ	$FFFF8606	; DMA Mode Reg
flock		equ	$43E		; DMA lock
_hz_200		equ	$4BA		; 200hz counter
*
	ORG	$0	; Start of bootsector
	bra.b	entry
	dc.b	"hdwait"
*
	ORG	$1e	; Bootsector program strarts at 0x1e
entry:	movem.l	d1-a5,-(sp)
	link	a6,#-2
	pea	WaitMes(PC)
	move.w	#9,-(a7)	; ConWS
	trap	#1
	addq.l	#6,a7
*
* Initial Delay
*
	move.l	#IWait,d0		; Initial delay
	bsr	Wait
*
* Start checks
*
	st	flock		; lock VBL interrupts
	clr.w	d5		; Start with target 0
Chk:	clr.w	-2(a6)		; n = 0
SamChk:	bsr	TstTarg		; expect status in d0
	IF	debug
	bsr	DispRes		; Show result on screen
	ENDIF
	cmpi.w	#-1,d0		; Target did not respond
	bne	Case2
*
NxtChk:	addi.w	#1,d5		; next target
	cmpi.w	#HighTarg,d5	; last one
	bhi	Exit
	bt	Chk
*
* This might be a MEGAFILE spinning up, so wait for status to show up
*
Case2:	cmpi.w	#-2,d0		; Target timeout sending status
	bne	Case3
Case2a:	bsr	IncPg
	cmpi.w	#ToCycle,-2(a6)	; status timeout cycles
	beq	NxtChk
	move.l	#ToWait,d0	; status timeout time
	bsr	IntW
	bne	Case2a		; still timeout
	clr.w	-2(a6)
	move.w	diskctrl,d0	; fall to case3 with valid status
*
* Now we have got a valid status byte
*
Case3:	cmpi.b	#0,d0		; Target responded with ready
	beq 	NxtChk
	bsr	IncPg		; Target not ready (usually check cond)
	cmpi.w	#BusyCycle,-2(a6)
	beq	NxtChk		; Number of busy cycles
	move.l	#BusyWait,d0	; Wait time
	bsr	Wait
	bt	SamChk		; Check same target again
*
* Increment progress message on screen
*
IncPg:	addq.w	#1,-2(a6)	; n++
	move.w	-2(a6),d4
	ext.l	d4
	divu	#10,d4		; n /= 10
	move.b	#'0',d3
	add.b	d3,d4		; high digit
	lea	WaitMesZ(pc),a4
	move.b	d4,(a4)		; to message
	swap	d4		; n %= 10
	add.b	d3,d4		; low digit
	lea	WaitMesE(pc),a4
	move.b	d4,(a4)		; to message
	pea	WaitMes(pc)
	move.w	#9,-(a7)	; ConWs
	trap	#1
	addq.l	#6,a7
	rts
*
* Test target device
*
TstTarg:clr.w	d4		; cmd word counter
	move.w	d5,d6
	asl.w	#5,d6		; First command byte Target,Test Unit Ready
	swap	d6
	move.w	#$8a,d6
	move.w	#$88,dmamode	; Command to come
NxtWd:	addi.w	#1,d4
	move.l	d6,diskctrl
	cmpi.w	#6,d4
	beq	CmdSucc
	ext.l	d6		; Clear for next word
	move.l	#CmdWait,d0	; wait time for command ack
	bsr	IntW		; Expect result in zero flag
	beq	NxtWd
	move.w	#-1,d0		; Timeout sending command bytes
	rts
* Status byte after last command takes more time
CmdSucc:move.l	#StatWait,d0	; wait time for status byte
	bsr	IntW
	beq	EndTst
	move.w	#-2,d0		; Timeout getting status byte
	rts
EndTst:	move.w	diskctrl,d0	; return status byte
	rts
*
* Wait short amount of time given in d0.l
*
Wait:	add.l	_hz_200,d0
WLoop:	cmp.l	_hz_200,d0
	bhi	WLoop
	rts
*
* Wait for interrupt or timeout
* Supply timeout time in d0 (0.005secs)
*
IntW:	add.l	_hz_200,d0
MFPTst:	btst	#$5,gpip
	bne	ctime
	clr.w	d0		; return true for interrupt
	rts
ctime:	cmp.l	_hz_200,d0
	bhi	MFPTst
	move.w	#-1,d0		; return false for timeout
	rts
*
* Display result message for debug purposes
* Status to be displayed in d0
*
	IF	debug
DispRes:movem.l	d0-a6,-(sp)
	move.b	#'0',d4
	add.b	d5,d4
	lea	TNo(pc),a4
	move.b	d4,(a4)
	lea	TSt(pc),a4
	cmpi.w	#-1,d0
	bne	DCase2
	move.b	#'N',(a4)	; N: Not available
	bt	DoDisp
DCase2:	cmpi.w	#-2,d0
	bne	DCase3
	move.b	#'T',(a4)	; T: Status byte timeout
	bt	DoDisp
DCase3:	cmpi.b	#0,d0
	bne	DCase4
	move.b	#'0',(a4)	; 0: Status OK
	bt	DoDisp
DCase4:	move.b	#'B',(a4)	; B: Busy
*
DoDisp:
	IF	extended_debug
	lea	ExtSt(pc),a4
	move.w	#7,d1
zz:	btst	d1,d0
	bne	z1
	move.b	#'0',(a4)+
	bt	z0
z1:	move.b	#'1',(a4)+
z0:	subq.w	#1,d1
	bcc	zz
	ENDIF
	pea	Progr(pc)
	move.w	#9,-(a7)
	trap	#1
	addq.l	#6,a7
	movem.l	(sp)+,d0-a6
	rts
	ENDIF
*
* End program
*
Exit:	move.w	#$80,dmamode	; Revert to FDC
	sf	flock		; enable VBL interrupts
	unlk	a6
	movem.l	(sp)+,d1-a5
	clr.w	d0		; Return Zero
	rts
*
	EVEN	;          Row  Column
WaitMes:
	IFF	extended_debug
	dc.b	$1B,'Y',32+2,32+3
	ENDIF
	dc.b	"hdwait "
WaitMesZ:dc.b	' '
WaitMesE:dc.b	' ',$0D,$0A,0
	IF	debug
	EVEN	;          Row  Column
Progr:
	IFF	extended_debug
	dc.b	$1b,'Y',32+4,32+3
	ENDIF
	dc.b	"Target "
TNo:	dc.b	'?'
	dc.b	" Status "
TSt:	dc.b	'?'
	IF	extended_debug
	dc.b	' '
ExtSt:	dc.b	"LLLLLLLL"
	ENDIF
	dc.b	$0d,$0a,0
	ENDIF
*
	END
