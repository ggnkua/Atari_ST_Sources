;	list
	opt	o+
; The Auto Mono Emulator. V5.00 By Mick West.  November 20th 1988.
; V5.01 By JCM l'optimiseur fou
; Routine to make the ST think it is in mono mode. Needs TOS in ROM
; Makes the system think that there is a mono screen, but actually
; be updating a medium real screen from this under Vblank interrupt
; The XBIOS calls Physbase,Setscreen and Getrez are revectored.
; Put in an Auto Folder
; Works with any TOS in the entire world - hopefully

; bugs :
;	- MONST2 n'accepte pas l'‚mulation...
;
START
	bra	GETPARAM
;
; START of the TSR
;
;This is the new XBIOS routine
XBIOS:
	pea	(A0)			;Save A0
	lea	4(SP),A0		;offset over the stack
	BTST	#5,(A0)			;Test if called from user mode
	BNE.s	NOTUSER			;Skip if it is
	MOVE.L	USP,A0			;Otherwise get A0 = User stack
	SUBq.L	#6,A0			;Offset it as if it were the SSP
NOTUSER:
	MOVE	6(A0),D0		;Get XBIOS instruction code
	SUBQ	#2,D0			;If it is _PHYSBASE
	BEQ.s	PHYSBASE		;then jump to new PHYSBASE routine
	SUBQ	#4-2,D0			;If it is _GETREZ
	BEQ.s	GETREZ			;then jump to new GETREZ routine
	SUBQ	#5-4,D0			;If it is NOT _SETSCREEN
	BNE.s	NORM_XBIOS		;Then continue with the normal XBIOS
	moveq	#-1,d0
	MOVE	d0,16(A0)		;Else alter rez.W to -1 (No change)
	cmp.L	12(A0),D0		;Get the ploc.L parameter
					;If it is -1 
	BEQ.s	NORM_XBIOS		;then continue with normal XBIOS
	MOVE.L	12(a0),MONO+2		;Otherwise, new value goes to MONO
	MOVE.L	D0,12(A0)		;Set ploc.L to -1 (no change)
					;then norm BIOS deals with lloc.L
NORM_XBIOS:
	MOVE.L	(SP)+,A0		;Tidy the stack up
XBIOSPOKE:
	JMP	0.L			 ;And jump into the normal XBIOS
PHYSBASE:
	MOVE.L	MONO+2(pc),D0		;Get address of mono screen
	MOVE.L	(SP)+,A0		;Tidy stack
	RTE				;Return mono screen location
GETREZ:
	MOVEq	#2,D0			;Pretend we are in mono resolution
	MOVE.L	(SP)+,A0		;Tidy the stack
	RTE				;Return code for mono resolution

;This is the new VBLANK routine
VBLANK:
	move.b	#1,$ffff8260.w		;against trashy programs
;	MOVE	#$0333,$ffFF8242.w	;Set up colours, grey for thin lines
;	MOVE	#$333,$ffFF8244.w	;(1 vert mono pixel = 1 grey med pix)
	BTST	#0,$ffFF8241.w		;Check inverted
	BEQ.s	INVERT			;Jump if so
;	MOVE	#$777,$ffFF8240.w	;White background (normal)
;	clr	$ffFF8246.w		;Black ink
	move.l	#$07770333,$ffff8240.w
	move.l	#$03330000,$ffff8244.w
	BRA.s	NOINVERT
INVERT:
;	CLR	$FFFF8240.W		;Black background (inverted)
;	MOVE	#$777,$FFFF8246.W	;White ink
	move.l	#$00000333,$ffff8240.w
	move.L	#$03330777,$ffff8244.w
NOINVERT:
	MOVEM.L	D0-D2/A0-A2,-(SP)	;Save all registers used
	moveq	#0,D0
	move.l	d0,a0
	MOVEP	$ffFF8201(A0),D0	;Video base
	aSL.L	#8,D0			;All times 256
					;Is the address of the Real screen
MED:	MOVE.L	#0,A1			;A1 = real medium screen
	CMP.L	A1,D0			;Check if the real screen has moved
	BEQ.s	MEDOK			;Skip this if not
					;Get the new real screen address
	MOVE.L	D0,MONO+2			;Set MONO From this
	MOVE.L	A1,D0			;And put the real screen back 
	LSR	#8,D0			;to its origional position
	MOVE.l	D0,$ffFF8200.w
MEDOK:
MONO:	MOVE.L	#0,A0			;A0 = virtual mono screen
	lea	80(a0),A2		;A2 = mono start plus 80, on to next line
					;Offset in both screens in bytes
MONOPOS	MOVE	#0,D2			;Get position in the screen RAM
	ADD	D2,A0			;Offset position in mono screen
	ADD	D2,A2			;And the other mono position
	ADD	D2,A1			;Offset pos in real medium screen
MONOCOUNT:
	move	#200-1,d0		;Count of pairs done so far
MONOLINES:
	MOVEQ	#0,D1			;Otherwise get preset speed
	TST	$43E.w			;Test flock system variable
	Beq.S	COPYMOVE		;Set speed to 20 if using disk drive
	MOVEq	#20-1,D1		;default 20 lines / Vblank
COPYMOVE:				;combine and move two mono lines
	rept	40
	MOVE	(A0)+,(A1)+		;Move one Mono line to one Medium
	MOVE	(A2)+,(A1)+		;line on both colour planes times 40
	endr

	lea	80(a0),A0		;both need moving down another line
	lea	80(a2),A2		;in the mono screen
	ADD	#160,D2			;move down one medium/two mono lines
					;count medium lines done
					;Done 200 medium/ 400 mono ?
	dbra	d0,NOT200		;if not then skip
	moveq	#0,D2			;otherwise reset ram offset
	lea	-32000(a0),A0		;MONO position back to top of screen
	lea	-32000(a1),A1		;and the same for MEDIUM
	lea	-32000(a2),A2		;and the other MONO position
	move	#200-1,d0		;reset the counter
NOT200:
	DBF	D1,COPYMOVE		;loop round MONOLINES times
	move	d0,MONOCOUNT+2
	MOVE	D2,MONOPOS+2
	MOVEM.L	(SP)+,D0-D2/A0-A2	;Restore all registers
VBLANKPOKE:
	JMP	0.L			 ;Jump to normal VBLANK routine
;
; end of the TSR...
;
INIT:
	MOVE	#2,(SP)			;Hardware and Software to mono
	pea	-1.w
	pea	-1.w
	MOVE	#5,-(SP)
	TRAP	#14			;Set high resolution
	lea	12(sp),SP

	pea	SUPER(PC)
	MOVE	#38,-(SP)
	TRAP	#14
	ADDQ	#6,SP

	CLR	-(SP)			;Exit ok for GEM
	pea	32256+256+XEND-START	;Length of program + data space
	MOVE	#$31,-(SP)		;terminate and stay resident (TSR)
	TRAP	#1			;Finished this AUTO program
XEND:

SUPER:
;	move	#$2700,sr
	MOVE.L	$B8.w,XBIOSPOKE+2	;Get the old XBIOS address and
	MOVE.L	$70.w,VBLANKPOKE+2	;VBLANK and insert into new versions
	MOVE.L	$44E.w,MONO+2		;Set MONO

;	move.l	#NEWVBL,$70.w
;	move	#$2300,sr
;	clr.b	WAITVBL+1
;WAITVBL:MOVEQ	#0,D0
;	BEQ.S	WAITVBL
;	MOVE.B	#1,$FFFF8260.W

	MOVE.L	#XBIOS,$B8.w		;Set up the new XBIOS vector
	MOVE.L	#VBLANK,$70.w		;And the new VBLANK vector
	RTS
;NEWVBL:	ST	WAITVBL+1
;	RTE

GETPARAM
	MOVE	#4,-(SP)
	TRAP	#14			;Get screen Resolution
	subq	#2,D0			;If not high then carry on
	BNE.s	NOTHIGH
	clr	(SP)			;return ok to,GEM
	TRAP	#1			;Then exit back to desktop
NOTHIGH:
	addq	#2,sp

	pea	MESSAGE(pc)		;Address of start of message
	MOVE	#9,-(SP)		;Print startup message
	TRAP	#1
	ADDQ.L	#6,SP
INLOOP:
	pea	INPUT(pc)
	MOVE	#9,-(SP)		;Print input message
	TRAP	#1
	ADDQ.L	#6,SP
	MOVE.B	#3,MESSAGE		;Input length = 3
	pea	MESSAGE(pc)
	MOVE	#10,-(SP)
	TRAP	#1			;Input number
	ADDQ.L	#6,SP
	MOVEq	#40,D0			;Default = 40
	move.b	MESSAGE+1(pc),d1
	BEQ.s	DEFAULT			;If len=0
	subq.B	#2,d1			;len of 1 not allowed
	BNE.s	INLOOP
	CLR	D0
	MOVE.B	MESSAGE+2(pc),D0	;first digit
	SUB.b	#48,D0
	CMP.b	#10,D0
	BHS.s	INLOOP			;Too High (>100) or too low
	MULU	#10,D0
	MOVE.B	MESSAGE+3(pc),D1	;second digit
	SUB.b	#48,D1
	CMP.b	#10,D1
	Bhs.s	INLOOP			;Too high or too low
	ADD.b	D1,D0
	TST	D0
	beq.s	INLOOP
	CMP	#80,D0
	Bhi.s	INLOOP			;Check less than 80
DEFAULT:
;
; init variables...
;
	SUBQ	#1,D0
	MOVE.B	d0,MONOLINES+1		;Fourty lines per Vblank is default
	lea	XEND(pc),a2
	MOVE.L	A2,D0			;A2 = start of free memory
	ADD.L	#255,D0			;Force it to a 512 byte boundry
	clr.b	d0
	move.l	d0,MED+2		;‚cran r‚serv‚

	bra	INIT

MESSAGE:
	DC.B	27,'E','The Mono Emulator - Mick West 1988',13,10
	DC.B	'V5.00. Should be in AUTO Folder',13,10
	DC.B	'Will run with any TOS',13,10,13,10
	DC.B	'This is Shareware',13,10
	DC.B	'Send Money and Problems to:',13,10
	DC.B	'Mick West',13,10
	DC.B	'27 Lynton Drive,',13,10
	DC.B	'Shipley,',13,10
	DC.B	'BD18 3DJ',13,10
	DC.B	'ENGLAND',13,10,13,10
	DC.B	'Feel free to give away copies of this',13,10
	DC.B	'But please copy the whole folder',13,10,13,10,0
INPUT:
	DC.B	13,10
	DC.B	'Enter speed (10 to 80, Return = 40) ',0
