	TTL	'INT - Vblank interrupt handler'

SYSID	EQU	1	* VMS = 0, ARIUM = 1

EEGDEFAULT	EQU	$C81B
EECDEFAULT	EQU	$0800
TRAP_CODE	EQU	1
DOG_LIMIT	EQU	$0080		* 4 second watchdog timeout

	IFEQ	SYSID

	INCLUDE 'inc:hrdwmap.i'

	ENDC

	IFNE	SYSID

	INCLUDE prog/inc/hrdwmap.i

	ENDC

*
*	This section is OVERLAY VARIABLES shared by OS and GAME
*
	 SECTION 10
	 XDEF	button,auxsw,joystick,frame
	 XDEF	pots,potval,sys_cntl,motor_bits,sync
button	 DS.W	1		* button data
auxsw	 DS.W	1		* Aux switch data
joystick DS.W	1		* joystick data
frame	 DS.W	1
pots	 DS.B	2		* Real pot values
potval	 DS.B	2		* Scaled pot values
sys_cntl
	 DS.W	1		* SYS_CNTL output shadow
motor_bits:
	 DS.B	1		* Motor/Soleniod/VCR output shadow
sync:	 DS.B	1

	PAGE
	SECTION	14
*
*	Section 14 is used as variable area.  That's where C puts em.
*
	XDEF	rframe,frcntr,ucode_done
rframe:	DS.W	1			* Interrupt frame count
srbuf:	DS.W	8			* 8 Words for SR stack
sridx:	DS.W	1			* SR index into buffer (0-7)
old_cntl DS.W	1			* Last SYS_CNTL output shadow
forgnd:	DS.B	1			* Forground execute flag
moframe: DS.B	1			* MO control frame count
frcntr:	DS.B	1			* Frame overrun counter
ucode_done:
	DS.B	1			* ucode done flag
dogs:	DS.B	1			* Watchdog overrun counter

	PAGE
	SECTION	13
*
*	Section 13 is used for constant tables.
*

*
* 	Motion Object control frame tables for different update rates
*
frtbl60:
	DC.W	$1000,$1800,$3000,$3800			* 60hz
	DC.W	$1000,$1800,$3000,$3800

frtbl30:
	DC.W	$0000,$0800,$1800,$1800			* 30hz
	DC.W	$0000,$2800,$3800,$3800

frtbl20:
	DC.W	$0000,$0800,$0800,$0800,$1800,$1800	* 20hz
	DC.W	$0000,$2800,$2800,$2800,$3800,$3800



*****************************************
* External routines			*
*****************************************
	XREF	modriv
	XREF	main
	XREF	imess
	XREF	start
	XREF	rotate
	XREF	new_horizon
	XREF	int_disp
	XREF	erc_vbex
	XREF	color_anim
	XREF	rot_check
	XREF	ttl_test

*****************************************
* External variables			*
*****************************************
	XREF	scan_data
	XREF	horizon_line,horizon_ptr
	XREF	fade_case
	XREF	pf_scroll
	XREF	doing_pf

	IFNE	EDIT_ON
	XREF	bar_on
	ENDC

*****************************************
* Globals defined here			*
*****************************************
	XDEF	trap
	XDEF	rts,rts1
	XDEF	iniint,inton,intoff,pioff,pion

	PAGE
	SECTION	9
*****************************************
* TRAP HARWARE ERRORS			*
*****************************************
ILGL	EQU	$80000

	IFNE	TRAP_CODE
trap:	JMP	ILGL		; Mapped guarded access
	ENDC

	IFEQ	TRAP_CODE
trap:	RTS			; No trapping in production
	ENDC

*****************************************
* Enable, init and disable interrupts	*
*****************************************

pioff:	MOVEM.L	D0/A0,-(SP)
	LEA	srbuf,A0	;Get SR buffer addrs
	MOVE.W	sridx,D0	;Get index
	ADD.W	D0,D0
	MOVE.W	SR,0(A0,D0.W)	;Save SR in temp stack
	ADDI.W	#1,sridx	;Bump index
	MOVEM.L	(SP)+,D0/A0	;Restore registers
	
intoff:	MOVE.W	#INTDIS,SR	; Disable IRQ and communications interrupt
	RTS

pion:	MOVEM.L	D0/A0,-(SP)	;Save regs
	LEA	srbuf,A0	;Get SR buffer addrs
	MOVE.W	sridx,D0	;Get index
	SUBQ.W	#1,D0		;Pre-dec index
	MOVE.W	D0,sridx	;Save new index
	ADD.W	D0,D0
	MOVE.W	0(A0,D0.W),SR	;Save SR in temp stack
	MOVEM.L	(SP)+,D0/A0	;Restore registers
	RTS

iniint:	CLR.W	sridx		;Clear SR buffer index
	CLR.W	rframe		;Clear frame counters
	CLR.B	moframe
	MOVE.W	#RES_BITS,sys_cntl
	MOVE.B	#2,frcntr
inton:	MOVE.W	#INTEN,SR	;Enable interrupts
	RTS

rts:	MOVEQ	#0,D0		;Clear return code
	RTS			;Just return

rts1:	MOVEQ	#1,D0		;return TRUE
	RTS			;Just return

	XDEF	reset
reset:	RESET			;This will reset the program
	SUBA.L 	A0,A0
	MOVE.L	(A0)+,SP
	MOVE.L	(A0),A0
	JMP	(A0)

	PAGE
*****************************************
* 	IRQ PROCESSING			*
*****************************************
	XDEF	gamevb
gamevb:	MOVEM.L	D0-D1/A0-A1,-(SP)	;Push regs

	LEA	frtbl30,A0		;Use 30hz control table
	MOVEQ.L	#0,D0			;Clear D0
	MOVE.B	moframe,D0		;Get current real frame count
	MOVE.L	D0,D1			;Save moframe
	LSL.W	#2,D0

	ADDQ.L	#1,D1			;Next moframe
	ANDI.L	#3,D1
.vb30:	MOVE.B	D1,moframe

	MOVE.W	sys_cntl,D1		;Get sys control shadow
	ANDI.W	#MO_CLR,D1		;Clear mo control bits
	OR.W	0(A0,D0.W),D1		;Get mo control bits
	MOVE.W	D1,SYS_CNTL		;First hardware store
	MOVE.W	D1,old_cntl		;Save last sys_cntl state
	ANDI.W	#MO_CLR,D1		;Clear mo control bits
	OR.W	2(A0,D0.W),D1		;Get second mo control bits
	MOVE.W	D1,SYS_CNTL		;Second store
	ORI.W	#RES_BITS,D1		;Enable all reset bits
	MOVE.W	D1,sys_cntl		;Shadow current state

	ADDI.W	#1,rframe
	ADDI.B	#1,sync
*					;Do 60hz routines
	JSR	erc_vbex		;Do eerom stuff
	JSR	rot_check		;Check color rotation
	JSR	color_anim		;Color animation
	JSR	imess			;do message processing

	MOVE.W	sys_cntl,D0		;Check for MOGO start
	EOR.W	D0,old_cntl
	MOVE.W	old_cntl,D0
	ANDI.W	#MO_GO,D0
	BNE.S	.vb10

	IFNE	EDIT_ON
	TST.B	bar_on			;If bar is on
	BEQ.S	no_bar
	MOVE.W	STRIPE0,STRIPE1		;Continue last color
	MOVE.W	#0,STRIPE0		;Blacken first
no_bar:
	ENDC

	MOVEQ	#0,D0			;Do motor/soleniod control
	MOVE.B	motor_bits,D0
	MOVE.W	D0,XCR
	ANDI.W	#MOTOR2_OFF,D0		;Turn off the solenoid only
	MOVE.B	D0,motor_bits
	BRA	.IRQX			;Exit now
*
* Every 30 hz only
*
.vb10:	MOVEQ	#0,D0			;Do motor/soleniod control
	MOVE.B	motor_bits,D0
	MOVE.W	D0,XCR
	ANDI.W	#MOTORS_OFF,D0		;Turn off the motors
	MOVE.B	D0,motor_bits

	MOVE.B	#0,ucode_done		;Flag ucode not done

	IFNE	EDIT_ON
	TST.B	bar_on			;If bar is on
	BEQ.S	no_bar1
	MOVE.W	#0,STRIPE0		;Blacken timing stripes
	MOVE.W	#0,STRIPE1
no_bar1:
	ENDC

	TST.B	pf_scroll		;Is scrolling enabled?
	BEQ.S	.vb20			;No, skip the scroller
	JSR	new_horizon		;Set horizon line
	JSR	dump_scroll

.vb20:	TST.B	forgnd			;Is forground executing?
	BNE.S	.overrun
*	MOVE.W	#0,$FF6300		;No overrun flag
	CLR.B	frcntr			;Clear frame overrun
	MOVE.B	#$80,forgnd		;Flag forground in process
	MOVE.W	#INTEN,SR		;Enable all interrupts
	MOVE.W	D0,WDOG			;stop watchdog resets
	CLR.W	dogs			;Clear puppie count
	JSR	main			;No, execute main prog
	CLR.B	forgnd			;Unflag forground

	TST.B	doing_pf		;If playfield is active
	BRA.S	IRQX

.overrun:
	MOVE.W	dogs,D0			;Get dog count
	ADDQ.W	#1,D0			;Inc watchdog counter
	CMPI.W	#DOG_LIMIT,D0		;If over limit
	BGE.S	.nodog			;Don't reset watchdog
	MOVE.W	D0,WDOG			;Else, stop watchdog resets
.nodog:
	MOVE.W	D0,dogs			;Store count
*	MOVE.W	#1,$FF6300

.IRQX:	ADDI.B	#1,frcntr
	MOVEM.L	(SP)+,D0-D1/A0-A1	;restore registers
	RTE

	PAGE
	XDEF	dump_scroll
dump_scroll:
	MOVEM.L	D2/D3,-(SP)		* Save regs
	MOVEQ	#0,D0			* Clear work regs
	MOVEQ	#0,D1
	MOVEQ	#0,D2
	LEA	scan_data,A0		* PF buffer

	MOVE.W	horizon_line,D0		* Goto horizon line
	MOVE.L	D0,D2
	ASL.L	#2,D2			* Array size is 6 bytes
	ASL.L	#1,D0
	ADD.L	D0,D2

	MOVEQ	#0,D0
	MOVE.W	horizon_line,D0		* Get minor array index
	ANDI.W	#7,D0
	MOVEQ	#7,D1
	SUB.W	D0,D1

	MOVE.W	#SCANLINES-1,D0		* Get major array index
	SUB.W	horizon_line,D0
	LSR.L	#3,D0

	MOVE.L	horizon_ptr,A1		* Get current horizon pointer

.d10:	MOVE.W	0(A0,D2.L),D3		* Copy H array
	ORI.W	#$8000,D3		* Load enable
	MOVE.W	D3,(A1)			* Store H array

	MOVE.W	2(A0,D2.L),D3		* Copy V array
	ORI.W	#$8000,D3		* Load enable
	MOVE.W	D3,2(A1)		* Store V array

	ADDQ	#6,D2			* Next scanline
	ADDA.L	#4,A1			* Output goes by 4
	DBF	D1,.d10

	ADDA.L	#96,A1			* Skip alphas
	MOVEQ	#7,D1
	DBF	D0,.d10

	MOVEM.L	(SP)+,D2/D3		* Restore regs
dsexit:
	RTS

	SECTION	0
*
* Configuration section for OS linkage
*
	IFEQ	SYSID
	XREF	lnktime
	ENDC
	IFNE	SYSID
	XREF	rr_today
	ENDC

	JMP	start		(00)	* Init game
	JMP	gamevb		(06)	* Game irq addrs
	JMP	ttl_test	(0C)	* Playfield test

	IFEQ	SYSID
	DC.L	lnktime		(12)	* will contain link time (used by os)
	ENDC
	IFNE	SYSID
	DC.L	rr_today	(12)	* will contain link time (used by os)
	ENDC

	DC.W	EEGDEFAULT	(16)	* Default game options
	DC.W	EECDEFAULT	(18)	* Default coin options

	DC.W	0		(1A)	* CKSUM0

	JMP		err	(1C)	* error routine

	XDEF	CPYRT

	END
