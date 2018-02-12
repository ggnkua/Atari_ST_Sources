;**************************************************************************
;
; MC68681.s
;
; This is a companion file to RS232DEV.CPP
;
; This file handles all of the interrupts from the chip
; It also has the handler in it for all of the vaious spurious exceptions
;
; Interrupt handlers call C functions in various files
; Interrupt handler calls :
;  EnterInterrupt
;  ExitInterrupt
;  HandleGetIrq
;  HandlePutIrq
;
; copyright (c) 1995 by Jim Patchell
;
;*************************************************************************
;

	.OPTION	target=68000,flags=gG
	.OPTION	char=1,short=2,int=2,long=4,float=4,double=8
	.OPTION	ldouble=8,ptrd=4,ptrf=4,sizeof=4,cver=0x430
;	equates
	XDEF	_EnableInterrupt,_DisableInterrupt
	XREF _EnterInterrupt
	XDEF _rs232_irq
	XREF	_ImrShadow
	.FREF	_ExitInterrupt,2	;this function removes two bytes

	XREF	START

MR1A:			EQU	0xffe00001	/*	mode control register A	*/
MR2A:			EQU	0xffe00001	/*	same address, different reg	*/
SRA:			EQU 0xffe00003	/*	status register port A	*/
RBA:			EQU 0xffe00007	/*	recieve buffer A	*/
IPCR:			EQU 0xffe00009	/*	input change register	*/
ISR:			EQU 0xffe0000b	/*	interrupt status register	*/
CUR:			EQU 0xffe0000d	/*	counter mode		*/
CLR:			EQU 0xffe0000f	/*	counter mode		*/
MR1B:			EQU 0xffe00011	/* mode control register B	*/
MR2B:			EQU 0xffe00011	/* same address, different reg	*/
SRB:			EQU 0xffe00013	/*	status register port B	*/
RBB:			EQU 0xffe00017	/*	recieve buffer B	*/
IVR:			EQU 0xffe00019	/*	interrupt vector reg	*/
IPUL:			EQU	0xffe0001b	/*	input port, unlatched	*/
START_COUNTER:	EQU	0xffe0001d
STOP_COUNTER:	EQU	0xffe0001f
BITSET:			EQU	0xffe0001d
BITRESET:		EQU	0xffe0001f

/* WRITE locations, where different from READ	*/

CSRA:			EQU	0xffe00003	/*	clock select register A	*/
CRA:			EQU	0xffe00005	/*	command register A	*/
TBA:			EQU	0xffe00007	/*	transmit buffer A	*/
ACR:			EQU	0xffe00009	/*	Auxiliary Control Register	*/
IMR:			EQU	0xffe0000b	/*	interrupt mask register	*/
CTUR:			EQU	0xffe0000d	/*	counter/timer upper reg	*/
CTLR:			EQU	0xffe0000f	/*	counter/timer lower reg	*/
CSRB:			EQU	0xffe00013	/*	clock select register B	*/
CRB:			EQU	0xffe00015	/*	command reg B	*/
TRB:			EQU	0xffe00017	/*	transmit register B	*/
OPCR:			EQU	0xffe0001b	/*	output port config register	*/
OPRBS:			EQU	0xffe0001d	/*	output port bit set command	*/
OPRRS:			EQU	0xffe0001f	/*	output port bit reset command	*/

RS232_VEC:	EQU	0x00000100	/*	user vector 64	*/


EXCEPTION_VEC:	EQU	0x08
; equates for data structures

BUFFER:	EQU	0       ;pointer to buffer area
HEAD:	EQU	4       ;head pointer
TAIL:	EQU	6       ;tail pointer
SIZE:	EQU	8       ;size of buffer
NCHARS:	   = 10     ;number of characters in buffer
HIGH:	=	12		;high water mark
LOW:	=	14      ;low water mark
EOTCHAR: = 16
TIMEOUT: = 18
IOEVENT: = 20
UARTDREG:	= 24	;address of data register
STATUSREG:	= 28	;address of status register
BITSETREG:	= 32	;address of bit set register
BITRSETREG:	= 36	;address of bit reset register
MODEREG:	= 40	;address of mode register
COMMANDREG:	= 44    ;address of command register
PUTIRQMSK:	= 48	;mask for IMR for put
GETIRQMSK:	= 50	;mask for IMR for get
DSRBIT:		= 52	;mask for bit set register for DSR

	SECTION	ram
isr_temp:	DS.B	1

	SECTION code
_EnableInterrupt:
	andi	#0xf8ff,sr		;	enable interrupts
	rts

_DisableInterrupt:
	ori		#0x07ff,sr		;disable interrupts
	rts

_rs232_irq:
	movem.l	d0-d7/a0-a6,-(a7)	;save context on the stack
	jsr		_EnterInterrupt		;indicate we are in an interrupt
	move.b	ISR,d0				;get status of interrupts
	and.b	_ImrShadow,d0		;mask off unwanted status bits
	move.b	d0,isr_temp			;save a copy of interrupt status
;
;----------------------------------------------------------------------
; determine which interrupts were activated and call them
;----------------------------------------------------------------------
;
	btst.b	#5,isr_temp			;* port B recive
	beq.s	L7					;highest priority
	move.w	#1,-(a7)			;push device number on stack
	jsr		_HandleGetInterrupt	;call interrupt handler
	addq.l	#2,a7				;clean up stack

L7:
	btst.b	#4,isr_temp         ;port B transmit
	beq.s	L6
	move.w	#1,-(a7)			;push device number on stack
	jsr		_HandlePutInterrupt	;call interrupt handler
	addq.l	#2,a7

L6:
	btst.b	#0,isr_temp			;*	port a transmit
	beq.s	L5
	move.w	#0,-(a7)			;push device number on stack
	jsr		_HandlePutInterrupt	;call interrupt handler
	addq.l	#2,a7				;clean up stack

L5:
	btst.b	#1,isr_temp			; check interrupt status for UART port a
	beq.s	L8
	move.w	#0,-(a7)			;push device number on stack
	jsr		_HandleGetInterrupt	;call interrupt handler
	addq.l	#2,a7				;clean up stack

L8:
	btst.b	#3,isr_temp			;check for a timer interrupt
	beq.s	L11
	jsr		_the_timer			;goto timer interrupt handler
	move.b	STOP_COUNTER,d0		;dummy read, clear interrupt

L11:
	btst.b	#7,isr_temp
	beq.s	L4
	jsr		_port_change		;goto port change handler

L4:
	move.w	60(a7),d0				;get status register
	andi.w	#0x0700,d0				;mask off junk
	asr.w 	#8,d0					;shift over 8 bits
	move.w	d0,-(a7)				;push onto stack
	jsr		_ExitInterrupt		;call routine to exit interrupt
	movem.l	(a7)+,d0-d7/a0-a6	;restore context from stack
	rte

;**********************************************************
; Misc interrupt routines
;**********************************************************

	XREF	_p_error
	XDEF buss_error,address_error
	XDEF illegal,zero_div,chk_instr,trapv_instr
buss_error:
	movem.l	d0-d7/a0-a6,-(a7)			;save processor context
	moveq #2,d0
	bra.s	goto_error
address_error:
	movem.l	d0-d7/a0-a6,-(a7)			;save processor context
	moveq #3,d0
	bra.s	goto_error
illegal:
	movem.l	d0-d7/a0-a6,-(a7)			;save processor context
	moveq #4,d0
	bra.s goto_error
zero_div:
	movem.l	d0-d7/a0-a6,-(a7)			;save processor context
	moveq #5,d0
	bra.s goto_error
chk_instr:
	movem.l	d0-d7/a0-a6,-(a7)			;save processor context
	moveq #6,d0
	bra.s goto_error
trapv_instr:
	movem.l	d0-d7/a0-a6,-(a7)			;save processor context
	moveq #7,d0
	bra.s goto_error

	XDEF privilege,trace,line_a,line_f,reserved

privilege:
	movem.l	d0-d7/a0-a6,-(a7)			;save processor context
	moveq #8,d0
	bra.s goto_error
trace:
	movem.l	d0-d7/a0-a6,-(a7)			;save processor context
	moveq #9,d0
	bra.s goto_error
line_a:
	movem.l	d0-d7/a0-a6,-(a7)			;save processor context
	moveq #10,d0
	bra.s goto_error
line_f:
	movem.l	d0-d7/a0-a6,-(a7)			;save processor context
	moveq #11,d0
	bra.s goto_error
reserved:
	movem.l	d0-d7/a0-a6,-(a7)			;save processor context
	moveq #12,d0
	bra.s goto_error

	XDEF unitialized,spurious,autovector,trap_instr,user_vecs

unitialized:
	movem.l	d0-d7/a0-a6,-(a7)			;save processor context
	moveq #15,d0
	bra.s goto_error
spurious:
	movem.l	d0-d7/a0-a6,-(a7)			;save processor context
	moveq #24,d0
	bra.s goto_error
autovector:
	movem.l	d0-d7/a0-a6,-(a7)			;save processor context
	moveq #25,d0
	bra.s goto_error
trap_instr:
	movem.l	d0-d7/a0-a6,-(a7)			;save processor context
	moveq #32,d0
	bra.s goto_error
user_vecs:
	movem.l	d0-d7/a0-a6,-(a7)			;save processor context
	move.w #64,d0
goto_error:
	move.l	a7,d1
	add.l	#60,d1						;point stack to where it was
	move.l	d1,-(a7)
	move.w	d0,-(a7)
	jsr	_p_error
	jmp	START				;Attempt to Reboot

