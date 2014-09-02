	.text
*********************************
*				*
*	Test RS232 		*
*	 			*
*********************************

*	May 22, 87  restore baud rate before return
*	Feb 3, 87  madmac
*	Nov 27 86	Recode for simplicity

*	Tests RS232 regardless of consol flags.
*	This version uses count-down timeout instead of timer interrupt
*	RS232 is done at 7 bps rates (*256 data bytes)
*	+ 1(*256) times with interrupts at 9600 bps

*	On completion:
* Erflg0:
*	bit 3		bit 2		bit 1		bit 0
*	data mismatch	framing 	parity		overrun

*	bit7   		bit6   		bit 5    	bit 4	
*	rcv err int	xmt err int	rcv int		rcv t-o

* Erflg1:
*	bit 3		bit 2		bit 1		bit 0
*	xmt t-o		RTS/CTS 	DCD/DTR		RI/DTR

*	bit 7		bit 6		bit 5		bit 4
*							xmt-rcv short

	.text

rs232tst:
	clr.b	erflg0
	clr.b	erflg1

*	Test RS232
	movea.l	#rs232m,a5
	bsr	dsptst
	move.b	consol,-(a7)	
	bset	#1,consol	;disable terminal I/O

	lea	psgwr,a0
	move.b	#$7,psgsel	;select i/o enable 
	move.b	#$c0,(a0)	;output
	move.b  #$e,psgsel 	;select port a
	move.b	#$18,(a0)	;DTR, RTS high

* set DTR, look for interrupt on RI	
	bset	#6,intflg	;interrupt 14 flag 
	moveq	#14,d0		;ring indicator
	bsr	enabint		;enable int
	bclr.b	#4,(a0)		;DTR low
	bsr	wait	  	;wait decent interval
	btst	#6,intflg
	beq.s	dtr1
	bset	#0,erflg1
dtr1:	moveq	#14,d0
	bsr	disint		;disable RI int
	bset.b	#4,(a0)		;DTR high

* set DTR, look for int on DCD
	bset	#1,intflg
	moveq	#1,d0
	bsr	enabint		;enable DCD int
	bclr.b	#4,(a0)		;DTR low
	bsr	wait
	btst	#1,intflg
	beq.s	dtr2
	bset	#1,erflg1
dtr2:	moveq	#1,d0
	bsr	disint		;disable DCD int

* set RTS, look for int on CTS
	bset	#2,intflg
	moveq	#2,d0
	bsr	enabint
	bclr.b	#3,(a0) 	 ;RTS low
	bsr	wait
	btst	#2,intflg    	 ;test CTS
	beq.s	ctsfin
	bset	#2,erflg1

*	Test data transfer
ctsfin:
	moveq	#2,d0
	bsr	disint		;disable CTS

*	Test RS232 transmit and receive
*	1. Poll status registers for send and receive status
*	   9600 bps. Data = 'no loopback' message
*	2. Poll using short message, 300,600,...19200 bps.
*	3. Test interrupts. Interrupt routine increments 
*	   a variable and sends it. Check that interrupt occurs 256 times.

*---
*	1. No interrupts
*	Test using "no loopback connector" message at 9600 bps
*	in case terminal is connected.

	moveq	#2,d0		;9600 bps
	bsr	setbps
	move.w	#1000,d7	;timeout for 9600 bps
	lea	loopm,a5
	bsr	xmtrcv
	tst.b	erflg0
	bne	rserror

*---
*	2. Do 7 times for 300-19200 bps
	move.b	#$9c,ucr(a0)	;set control reg. with odd parity checking
	lea	rsmsgs,a5
	move.l	#32000,d7
	move.b	#64,index1	;start at 300 bps

repeat:	move.b	index1,d0
	bsr	setbps		;set bps

	bsr	xmtrcv		;test
	tst.b	erflg0
	beq.s	rpt1

	move.b	index1,d0
	bsr	dsprate		;display rate
	bra	rserror		;display error

rpt1:	move.b	index1,d1
	lsr.b	#1,d1
	move.b	d1,index1
	tst.b	index1
	bne.s	repeat		;until all rates done
	
*---
*	3. Test interrupts

*	Enable RS232 interrupts: 9-12
	moveq	#9,d0
rsint1:	bsr	enabint
	addq	#1,d0
	cmpi.b	#13,d0
	bne.s	rsint1

*	Set RS232 back to 9600 bps
	moveq	#rs96,d0
	bsr	setbps

*	Start with 0, let interrupt routines handle xfer of 256 bytes
*	Crude interrupt routine, only care that we get a count of 255
*	   when done.
	clr.b	xmtbyt
	clr.b	rcvbyt	
	clr.b	rsistat
	move.w	#54000,d3	;time-out value
	move.b	xmtbyt,udr(a0)	;send byte 
rcvint:	cmpi.b	#$ff,rcvbyt	;wait until all bytes done...
	beq.s	ridone
	subi.w	#1,d3
	bne.s	rcvint
	bset	#5,erflg0	;no irq 
	moveq	#10,d0
	bsr	disint		;disable transmit routine
	moveq	#12,d0
	bsr	disint		;disable receive routine
	bra	rserror

*	Check transmit underrun (normal terminating condition)
ridone:	bsr	wait
	btst	#6,rsostat	;transmit underrun?
	bne.s	ur1
	bset	#6,erflg1	;didn't happen
ur1:	moveq	#9,d0
	bsr	disint		;disable transmit overrun
	moveq	#10,d0
	bsr	disint		;disable transmit routine
	moveq	#12,d0
	bsr	disint		;disable receive routine

*	Test receiver overrun int
or1:	tst.b	tsr(a0)		
	bpl	or1
	move.b	#$55,udr(a0)	;send byte
or2:	btst	#7,rsr(a0)
	beq.s	or2		;wait until rcv'd	
	move.b	#$aa,udr(a0)	;send another without reading previous
	bsr	wait
	tst.b	udr(a0)		;read rcv to set overrun bit
	bsr	wait		;wait for the int
	btst	#6,rsistat
	bne.s	or3		;should have got overrun
	bset	#7,erflg1

or3:	moveq	#11,d0		
	bsr	disint		

	tst.b	udr(a0)		;read rcv to assure empty
	tst.b	rsr(a0)		;read status too
	
*-----------------------------------------------------------------
*	End of RS232 test. Check for errors, display PASS or FAIL
	move.b	erflg0,d0
	or.b	erflg1,d0
	bne.s	rserror

	tst.b	erflg0		;should have an error
	beq.s	rspass

*	Display error
rserror:
	moveq	#0,d1		;message offset
	moveq	#0,d0		;bit specifier
	move.b	erflg1,d2
	lsl.w	#8,d2
	move.b	erflg0,d2	;combined error flags
	lea	rsermsg,a0
rse2:	btst	d0,d2		;if bit set, display error msg
	beq.s	rse1
	move.l	0(a0,d1),a5	;get message
	bsr	dspmsg
rse1:	addq	#4,d1		;check all error bits
	addq	#1,d0
	cmp	#n_of_e,d0
	bne.s	rse2
	
rsfail:	bsr	rsinit		;restore normal bit rate
	movea.l	#falmsg,a5
	move.w	#red,palette
	bra.s	rsret

*	------------
*	RS232 passed
	
rspass:	movea.l	#pasmsg,a5

********************************
*	return to caller
rsret:	move.b	#t_SERIAL,d0
	bsr	dsppf	
	move.b	(a7)+,consol
	move	rsrate,d0
	bsr	setbps		;restore rate
	rts			;back to dispatcher

*-------------------------------
*	Send and receive a message, polling xmt,rcv registers
*	If nothing received, keep sending
*	Entry:	a5=message, d7=timeout
*	Exit:	erflg0=error

xmtrcv:	lea	mfp,a0
	move.b	rsr(a0),d0	;read status to clear it
	move.b	udr(a0),d0	;read data too
	clr.l	d0

xmtt:	move.l	d7,d3		;get timeout
xmt1:	tst.b	tsr(a0)
	bmi	xmt2		;br if empty
	subi.w	#1,d3
	bne.s	xmt1
	bset	#3,erflg1	;transmit timeout 
	bra.s	xmtdon

xmt2:	move.b	0(a5,d0),d1	;get next byte
	addq	#1,d0
	cmpi.b	#eot,d1
	beq.s	xmtdon

	move.b	d1,udr(a0)	;send byte

*	Get a byte
	move.w	d7,d3
xmt3:	subi.w	#1,d3
	bne.s	xmt4
	bset	#4,erflg0	;flag not recvd
	bra.s	xmtt		;keep transmitting

xmt4:	move.b	rsr(a0),d6	;check receive status
	bpl	xmt3		;wait till full

	bsr	rstatus		;collect status errors

	move.b	udr(a0),d2	;get data
	cmp.b	d2,d1
	beq.s	xmt5
	bset	#3,erflg0
xmt5:	bra.s	xmtt

xmtdon:	rts

*-------------------------------
*	Check Receiver status 
*	Set erflg bits
*	d6=rcv status
rstatus:
	btst	#4,d6		;frame error?
	beq.s	rstat1
	bset	#2,erflg0
	
rstat1:	btst	#5,d6		;parity error?
	beq.s	rstat2
	bset	#1,erflg0

rstat2:	btst	#6,d6		;overrun?
	beq	rstat3
	bset	#0,erflg0
rstat3:	rts

*-------------------------------
*	Display RS232 rate
*	d0 = 1,2,4,...64 (clock divide value)
dsprate:
	andi.b	#$7f,d0		;avoid disaster
	lea	ratetb1,a0
	clr.l	d1
drate1:	cmp.b	0(a0,d1),d0	;compare with table
	beq	drate2		;get offset 0-6
	addq	#1,d1
	cmp	#7,d1
	bne.s	drate1
	rts			;not found

drate2:	lea	ratemsg,a0
	lsl	#2,d1		;offset 0-6 -> 0-24
	move.l	0(a0,d1),a5	
	bsr	dspmsg
	rts

********************************
	.data

*	data for timer D: 19.2k, 9600,...,300 bps
bpstbl:	dc.b	1,2,4,8,16,32,64

rsermsg: dc.l	e_over		;erflg0 0
	dc.l	e_parity	;1
	dc.l	e_frame		;2
	dc.l	e_match		;3
	dc.l	e_rcv_to	;4
	dc.l	e_int_to	;5
	dc.l	e_te_int	;6
	dc.l	e_re_int	;7
	dc.l	e_ri		;erflg1 0
	dc.l	e_dcd		;1
	dc.l	e_rts		;2
	dc.l	e_xmt_to	;3
	dc.l	e_shrt		;4
n_of_e	equ	(*-rsermsg)/4

*********************************
*				*
*	Messages		*
*				*
*********************************	

ratetb1: dc.b	1,2,4,8,16,32,64
ratemsg: dc.l	bps192
	dc.l	bps96
	dc.l	bps48
	dc.l	bps24
	dc.l	bps12
	dc.l	bps6
	dc.l	bps3
bps192:	dc.b	'19.2k bps',eot
bps96:	dc.b	'9600 bps ',eot
bps48:	dc.b	'4800 bps ',eot
bps24:	dc.b	'2400 bps ',eot
bps12:	dc.b	'1200 bps ',eot
bps6:	dc.b	'600 bps  ',eot
bps3:	dc.b	'300 bps  ',eot

loopm:	dc.b	'No loopback connector',cr,lf,eot
rsmsgs:	dc.b	$55,$aa,0,$ff,$e5,$d1,eot
rs232m:	dc.b	'Testing RS232 loopback',cr,lf,eot
rsbutn:	dc.b	'Hold down button (or remove loopback), and press key.',cr,lf
	dc.b	'Press ESC to skip this test.',cr,lf,eot
e_rcv_to: dc.b	'S0 RS232 not received',cr,lf,eot
e_match: dc.b	'S1 RS232 data mismatch',cr,lf,eot
e_frame: dc.b	'S2 RS232 framing',cr,lf,eot
e_parity: dc.b	'S3 RS232 parity',cr,lf,eot
e_over:	dc.b	'S4 RS232 data overrun',cr,lf,eot
e_int_to: dc.b	'S5 RS232 IRQ',cr,lf,eot
e_xmt_to: dc.b	'S6 RS232 transmit error (68901)',cr,lf,eot
e_te_int: dc.b	'S7 RS232 Transmit error interrupt',cr,lf,eot
e_re_int: dc.b	'S8 RS232 Receive error interrupt',cr,lf,eot
e_ri:	dc.b	'S9 RS232 RI-DTR not connected',cr,lf,eot
e_dcd:	dc.b	'SA RS232 DCD-DTR not connected',cr,lf,eot
e_rts:	dc.b	'SB RS232 RTS-CTS not connected',cr,lf,eot
e_shrt:	dc.b	'SC RS232 input shorted to output',cr,lf,eot
